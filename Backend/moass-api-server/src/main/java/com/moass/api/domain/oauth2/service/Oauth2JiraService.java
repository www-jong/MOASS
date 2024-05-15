package com.moass.api.domain.oauth2.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.moass.api.domain.oauth2.dto.JiraProxyRequestDto;
import com.moass.api.domain.oauth2.dto.TokenResponseDto;
import com.moass.api.domain.oauth2.entity.JiraToken;
import com.moass.api.domain.oauth2.repository.JiraTokenRepository;
import com.moass.api.global.auth.dto.UserInfo;
import com.moass.api.global.config.PropertiesConfig;
import com.moass.api.global.exception.CustomException;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.ExchangeStrategies;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Slf4j
@Service
public class Oauth2JiraService {

    private final WebClient jiraAuthWebClient;

    private final WebClient jiraApiWebClient;
    private final JiraTokenRepository jiraTokenRepository;
    private final PropertiesConfig propertiesConfig;

    public Oauth2JiraService(WebClient.Builder webClientBuilder, JiraTokenRepository jiraTokenRepository, PropertiesConfig propertiesConfig) {
        log.info("Oauth2JiraService 초기화");
        this.jiraAuthWebClient = webClientBuilder.baseUrl("https://auth.atlassian.com").build();
        ExchangeStrategies strategies = ExchangeStrategies.builder()
                .codecs(configurer -> configurer.defaultCodecs().maxInMemorySize(16 * 1024 * 1024)) // 16MB로 설정
                .build();
        this.jiraApiWebClient = webClientBuilder.baseUrl("https://api.atlassian.com")
                .exchangeStrategies(strategies)
                .build();
        this.jiraTokenRepository = jiraTokenRepository;
        this.propertiesConfig = propertiesConfig;
    }

    public Mono<JiraToken> exchangeCodeForToken(String code, String state) {
        return jiraAuthWebClient.post()
                .uri("/oauth/token")
                .bodyValue(prepareTokenRequest(code))
                .retrieve()
                .bodyToMono(TokenResponseDto.class)
                .flatMap(response -> storeTokenAndCloudId(state, response));
    }

    private Mono<JiraToken> storeTokenAndCloudId(String userId, TokenResponseDto response) {
        return jiraApiWebClient.get()
                .uri("/oauth/token/accessible-resources")
                .header("Authorization", "Bearer " + response.getAccessToken())
                .retrieve()
                .bodyToMono(List.class)
                .flatMap(resources -> {
                    String cloudId = extractCloudId(resources);
                    if (cloudId == null) {
                        return Mono.error(new RuntimeException("cloudId를 가져오는데 실패했습니다."));
                    }
                    return jiraApiWebClient.get()
                            .uri(String.format("/ex/jira/%s/rest/api/3/myself", cloudId))
                            .header("Authorization", "Bearer " + response.getAccessToken())
                            .retrieve()
                            .bodyToMono(JsonNode.class)
                            .flatMap(userInfo -> {
                                String emailAddress = userInfo.path("emailAddress").asText();
                                log.info("User Email: {}", emailAddress);

                                return jiraTokenRepository.findByUserId(userId)
                                        .flatMap(existingToken -> {
                                            existingToken.setCloudId(cloudId);
                                            existingToken.setJiraEmail(emailAddress);
                                            existingToken.setAccessToken(response.getAccessToken());
                                            existingToken.setRefreshToken(response.getRefreshToken());
                                            existingToken.setExpiresAt(LocalDateTime.now().plusHours(1));
                                            return jiraTokenRepository.save(existingToken);
                                        })
                                        .switchIfEmpty(Mono.defer(() -> {
                                            JiraToken newToken = JiraToken.builder()
                                                    .userId(userId)
                                                    .cloudId(cloudId)
                                                    .jiraEmail(emailAddress)
                                                    .accessToken(response.getAccessToken())
                                                    .refreshToken(response.getRefreshToken())
                                                    .build();

                                            return jiraTokenRepository.save(newToken);
                                        }));
                            });
                });
    }

    private String extractCloudId(List<Map<String, Object>> resources) {
        if (resources.isEmpty()) {
            return null;
        }
        return (String) resources.get(0).get("id");
    }

    private Mono<JiraToken> storeToken(String userId, TokenResponseDto response) {
        log.info(String.valueOf(response));
        JiraToken token = JiraToken.builder()
                .userId(userId)
                .accessToken(response.getAccessToken())
                .refreshToken(response.getRefreshToken())
                .build();

        return jiraTokenRepository.save(token);
    }

    private Map<String, Object> prepareTokenRequest(String code) {
        Map<String, Object> formData = new HashMap<>();
        formData.put("grant_type", "authorization_code");
        formData.put("client_id", propertiesConfig.getJiraClientId());
        formData.put("client_secret", propertiesConfig.getJiraClientSecret());
        formData.put("code", code);
        formData.put("redirect_uri", propertiesConfig.getJiraRedirectUri());
        return formData;
    }

    public Mono<JiraToken> getTokenByUserId(String userId) {
        log.info("리프레시 확인");
        return jiraTokenRepository.findByUserId(userId)
                .flatMap(token -> {
                    if (token.getExpiresAt().isBefore(LocalDateTime.now())) {
                        log.info("시간초과로 리프레쉬됨");
                        return refreshAccessToken(token)
                                .flatMap(refreshedToken -> jiraTokenRepository.save(refreshedToken));
                    } else {
                        return Mono.just(token);
                    }
                })
                .switchIfEmpty(Mono.error(new CustomException("연동된 Jira 계정이 없습니다.", HttpStatus.FORBIDDEN)));
    }

    private Map<String, Object> prepareRefreshTokenRequest(String refreshToken) {
        Map<String, Object> formData = new HashMap<>();
        formData.put("grant_type", "refresh_token");
        formData.put("client_id", propertiesConfig.getJiraClientId());
        formData.put("client_secret", propertiesConfig.getJiraClientSecret());
        formData.put("refresh_token", refreshToken);
        return formData;
    }

    private Mono<JiraToken> refreshAccessToken(JiraToken token) {
        return jiraAuthWebClient.post()
                .uri("/oauth/token")
                .bodyValue(prepareRefreshTokenRequest(token.getRefreshToken()))
                .retrieve()
                .bodyToMono(TokenResponseDto.class)
                .flatMap(response -> {
                    JiraToken refreshedToken = JiraToken.builder()
                            .jiraTokenId(token.getJiraTokenId())
                            .userId(token.getUserId())
                            .cloudId(token.getCloudId())
                            .jiraEmail(token.getJiraEmail())
                            .accessToken(response.getAccessToken())
                            .refreshToken(response.getRefreshToken() != null ? response.getRefreshToken() : token.getRefreshToken())
                            .expiresAt(LocalDateTime.now().plusHours(1))
                            .build();

                    return Mono.just(refreshedToken);
                });
    }


    public Mono<String> getJiraConnectUrl(UserInfo userInfo) {
        return Mono.just("https://auth.atlassian.com" +
                "/authorize?audience=api.atlassian.com&client_id=" +
                propertiesConfig.getJiraClientId() +
                "&scope=offline_access%20read%3Ajira-user%20read%3Ajira-work%20write%3Ajira-work&redirect_uri=" +
                propertiesConfig.getJiraRedirectUri() + "&state=" + userInfo.getUserId() + "&response_type=code&prompt=consent");
    }

    public Mono<JiraToken> deleteJiraConnect(UserInfo userInfo) {
        return jiraTokenRepository.findByUserId(userInfo.getUserId())
                .flatMap(token -> jiraTokenRepository.delete(token)
                        .then(Mono.just(token)))
                .switchIfEmpty(Mono.error(new CustomException("연동된 Jira 계정이 없습니다.", HttpStatus.FORBIDDEN)));
    }

    public Mono<JsonNode> proxyRequestToJira(String userId, JiraProxyRequestDto jiraProxyRequestDto) {
        return getTokenByUserId(userId)
                .flatMap(token -> {
                    if(token.getUserId()==null){
                        return Mono.error(new CustomException("토큰이 없습니다.", HttpStatus.UNAUTHORIZED));
                    }
                    String fullUrl = String.format("/ex/jira/%s%s", token.getCloudId(), jiraProxyRequestDto.getUrl());
                    log.info(fullUrl);
                    WebClient.RequestHeadersSpec<?> requestSpec;

                    switch (jiraProxyRequestDto.getMethod().toUpperCase()) {
                        case "POST":
                            requestSpec = jiraApiWebClient.post()
                                    .uri(fullUrl)
                                    .header("Authorization", "Bearer " + token.getAccessToken());
                            break;
                        case "GET":
                        default:
                            requestSpec = jiraApiWebClient.get()
                                    .uri(fullUrl)
                                    .header("Authorization", "Bearer " + token.getAccessToken());
                            break;
                    }

                    return requestSpec.retrieve()
                            .onStatus(status -> !status.is2xxSuccessful(), clientResponse -> clientResponse.bodyToMono(String.class)
                                    .flatMap(errorBody -> Mono.error(new CustomException(
                                            String.format("내부 서버 에러: %s from %s %s",
                                                    clientResponse.statusCode(),
                                                    jiraProxyRequestDto.getMethod(),
                                                    fullUrl),
                                            HttpStatus.INTERNAL_SERVER_ERROR
                                    ))))
                            .bodyToMono(JsonNode.class);
                });
    }

    public Mono<String> isConnected(String userId) {
        return jiraTokenRepository.findByUserId(userId)
                .flatMap(token -> {
                    if (token.getJiraEmail() != null) {
                        return Mono.just(token.getJiraEmail());
                    } else {
                        return Mono.just("null");
                    }
                })
                .switchIfEmpty(Mono.just("null"));
    }


}
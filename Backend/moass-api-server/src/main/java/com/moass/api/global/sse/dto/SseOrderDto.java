package com.moass.api.global.sse.dto;

import lombok.Data;

@Data
public class SseOrderDto {

    private String command="order";

    private String type;

    private String message;

    public SseOrderDto(String type, String message) {
        this.type = type;
        this.message = message;
    }

}
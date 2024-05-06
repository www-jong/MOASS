package com.moass.ws.service;

import com.moass.ws.dto.BoardRequestDto;
import com.moass.ws.dto.BoardResponseDto;
import com.moass.ws.entity.Board;
import com.moass.ws.entity.User;
import com.moass.ws.repository.BoardRepository;
import com.moass.ws.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;

import java.util.*;

@Service
@RequiredArgsConstructor
public class BoardServiceImpl implements BoardService {

    private final Map<Integer, Set<User>> boards = new HashMap<>();
    private final SimpMessagingTemplate template;
    private final BoardRepository boardRepository;
    private final UserRepository userRepository;

    public void createBoard(Integer userId) {
        Board board = boardRepository.save(new Board());

        Set<User> users = new HashSet<>();
        users.add(userRepository.findById(userId).orElseThrow());
        boards.put(board.getBoardId(), users);

        template.convertAndSend("/topic/board/" + board.getBoardId(), BoardResponseDto.builder()
                .boardId(board.getBoardId())
                .users(users)
                .build());
    }

    public void enterBoard(BoardRequestDto dto) {
        boards.get(dto.getBoardId()).add(userRepository.findById(dto.getUserId()).orElseThrow());

        template.convertAndSend("/topic/board" + dto.getBoardId(), BoardResponseDto.builder()
                .boardId(dto.getBoardId())
                .users(boards.get(dto.getBoardId()))
                .build());
    }

    public void quitBoard(BoardRequestDto dto) {
        boards.get(dto.getBoardId()).remove(userRepository.findById(dto.getUserId()).orElseThrow());

        template.convertAndSend("/topic/board" + dto.getBoardId(), BoardResponseDto.builder()
                .boardId(dto.getBoardId())
                .users(boards.get(dto.getBoardId()))
                .build());
    }
}

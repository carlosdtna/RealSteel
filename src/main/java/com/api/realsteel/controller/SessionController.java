package com.api.realsteel.controller;

import com.api.realsteel.entity.SessionEntity;
import com.api.realsteel.repository.SessionRepository;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/sessions")
@CrossOrigin
public class SessionController {

    private final SessionRepository sessionRepository;

    public SessionController(SessionRepository sessionRepository) {
        this.sessionRepository = sessionRepository;
    }

    @PostMapping
    public SessionEntity createSession(@RequestBody SessionEntity session) {
        return sessionRepository.save(session);
    }

    @GetMapping("/user/{userId}")
    public List<SessionEntity> getSessionsByUser(@PathVariable Long userId) {
        return sessionRepository.findByUser_UserId(userId);
    }

    @GetMapping
    public List<SessionEntity> getAllSessions() {
        return sessionRepository.findAll();
    }

    @GetMapping("/{id}")
    public SessionEntity getSessionById(@PathVariable Long id) {
        return sessionRepository.findById(id).orElse(null);
    }
}
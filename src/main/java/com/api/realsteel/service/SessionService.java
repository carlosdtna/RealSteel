package com.api.realsteel.service;

import java.time.LocalDateTime;
import java.util.List;

import org.springframework.stereotype.Service;

import com.api.realsteel.entity.RoutineEntity;
import com.api.realsteel.entity.SessionEntity;
import com.api.realsteel.entity.UserEntity;
import com.api.realsteel.error.ResourceNotFoundException;
import com.api.realsteel.repository.RoutineRepository;
import com.api.realsteel.repository.SessionRepository;
import com.api.realsteel.repository.UserRepository;

@Service
public class SessionService {

    private final SessionRepository sessionRepository;
    private final UserRepository userRepository;
    private final RoutineRepository routineRepository;

    public SessionService(SessionRepository sessionRepository, UserRepository userRepository, RoutineRepository routineRepository) {
        this.sessionRepository = sessionRepository;
        this.userRepository = userRepository;
        this.routineRepository = routineRepository;
    }

    public SessionEntity createSession(String userId, LocalDateTime fecha, Long rutinaId, Integer duracion, Integer calorias) {
        UserEntity user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with id " + userId));

        SessionEntity session = new SessionEntity();
        session.setUser(user);
        session.setFecha(fecha);
        session.setDuracion(duracion);
        session.setCalorias(calorias);

        if (rutinaId != null) {
            RoutineEntity routine = routineRepository.findById(rutinaId)
                    .orElseThrow(() -> new ResourceNotFoundException("Routine not found with id " + rutinaId));
            session.setRoutine(routine);
        }

        return sessionRepository.save(session);
    }

    public List<SessionEntity> getAllSessions() {
        return sessionRepository.findAll();
    }

    public List<SessionEntity> getSessionsByUser(String userId) {
        // Validate user exists
        userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with id " + userId));
        return sessionRepository.findByUser_UserId(userId);
    }

    public SessionEntity getSessionById(Long sessionId) {
        return sessionRepository.findById(sessionId)
                .orElseThrow(() -> new ResourceNotFoundException("Session not found with id " + sessionId));
    }

    public void deleteSession(Long sessionId) {
        SessionEntity existing = getSessionById(sessionId);
        sessionRepository.delete(existing);
    }
}

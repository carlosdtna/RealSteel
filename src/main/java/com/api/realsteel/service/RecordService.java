package com.api.realsteel.service;

import java.time.LocalTime;
import java.util.List;

import org.springframework.stereotype.Service;

import com.api.realsteel.entity.ExerciseEntity;
import com.api.realsteel.entity.RecordEntity;
import com.api.realsteel.entity.SessionEntity;
import com.api.realsteel.error.ResourceNotFoundException;
import com.api.realsteel.repository.ExerciseRepository;
import com.api.realsteel.repository.RecordRepository;
import com.api.realsteel.repository.SessionRepository;

@Service
public class RecordService {

    private final RecordRepository recordRepository;
    private final SessionRepository sessionRepository;
    private final ExerciseRepository exerciseRepository;

    public RecordService(RecordRepository recordRepository,
                         SessionRepository sessionRepository,
                         ExerciseRepository exerciseRepository) {
        this.recordRepository = recordRepository;
        this.sessionRepository = sessionRepository;
        this.exerciseRepository = exerciseRepository;
    }

    public RecordEntity createRecord(Long sessionId, Long exerciseId, Double peso, Integer repeticiones, LocalTime horaRegistro) {
        SessionEntity session = sessionRepository.findById(sessionId)
                .orElseThrow(() -> new ResourceNotFoundException("Session not found with id " + sessionId));
        ExerciseEntity exercise = exerciseRepository.findById(exerciseId)
                .orElseThrow(() -> new ResourceNotFoundException("Exercise not found with id " + exerciseId));
        RecordEntity record = new RecordEntity();
        record.setSession(session);
        record.setExercise(exercise);
        record.setPeso(peso);
        record.setRepeticiones(repeticiones);
        record.setHoraRegistro(horaRegistro);
        return recordRepository.save(record);
    }

    public List<RecordEntity> getRecordsBySession(Long sessionId) {
        // Validate session exists
        sessionRepository.findById(sessionId)
                .orElseThrow(() -> new ResourceNotFoundException("Session not found with id " + sessionId));
        return recordRepository.findBySession_SessionId(sessionId);
    }
}

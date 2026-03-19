package com.api.realsteel.service;

import com.api.realsteel.entity.RoutineEntity;
import com.api.realsteel.repository.RoutineRepository;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class RoutineService {

    private final RoutineRepository routineRepository;

    public RoutineService(RoutineRepository routineRepository) {
        this.routineRepository = routineRepository;
    }

    public RoutineEntity createRoutine(RoutineEntity routine) {
        routine.setFechaCreacion(LocalDateTime.now());
        return routineRepository.save(routine);
    }

    public List<RoutineEntity> getUserRoutines(Long userId) {
        return routineRepository.findByUser_UserId(userId);
    }
}
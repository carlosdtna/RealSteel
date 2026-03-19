package com.api.realsteel.service;

import com.api.realsteel.entity.ExerciseEntity;
import com.api.realsteel.entity.RoutineEntity;
import com.api.realsteel.entity.RoutineExerciseEntity;
import com.api.realsteel.error.ResourceNotFoundException;
import com.api.realsteel.repository.ExerciseRepository;
import com.api.realsteel.repository.RoutineExerciseRepository;
import com.api.realsteel.repository.RoutineRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class RoutineExerciseService {

    private final RoutineExerciseRepository routineExerciseRepository;
    private final RoutineRepository routineRepository;
    private final ExerciseRepository exerciseRepository;

    public RoutineExerciseService(RoutineExerciseRepository routineExerciseRepository,
                                  RoutineRepository routineRepository,
                                  ExerciseRepository exerciseRepository) {
        this.routineExerciseRepository = routineExerciseRepository;
        this.routineRepository = routineRepository;
        this.exerciseRepository = exerciseRepository;
    }

    public RoutineExerciseEntity addExerciseToRoutine(Long routineId, Long exerciseId, String diaSemana, Integer orden) {
        RoutineEntity routine = routineRepository.findById(routineId)
                .orElseThrow(() -> new ResourceNotFoundException("Routine not found with id " + routineId));
        ExerciseEntity exercise = exerciseRepository.findById(exerciseId)
                .orElseThrow(() -> new ResourceNotFoundException("Exercise not found with id " + exerciseId));

        RoutineExerciseEntity entity = new RoutineExerciseEntity();
        entity.setId(new com.api.realsteel.entity.RoutineExerciseId(routineId, exerciseId, diaSemana));
        entity.setRoutine(routine);
        entity.setExercise(exercise);
        entity.setOrden(orden);
        return routineExerciseRepository.save(entity);
    }

    public List<RoutineExerciseEntity> getByRoutineId(Long routineId) {
        // validate routine exists
        routineRepository.findById(routineId)
                .orElseThrow(() -> new ResourceNotFoundException("Routine not found with id " + routineId));
        return routineExerciseRepository.findByRoutine_RutinaId(routineId);
    }
}

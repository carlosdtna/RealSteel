package com.api.realsteel.service;

import com.api.realsteel.entity.ExerciseEntity;
import com.api.realsteel.repository.ExerciseRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class ExerciseService {

    private final ExerciseRepository exerciseRepository;

    public ExerciseService(ExerciseRepository exerciseRepository) {
        this.exerciseRepository = exerciseRepository;
    }

    public List<ExerciseEntity> getAllExercises() {
        return exerciseRepository.findAll();
    }

    public ExerciseEntity saveExercise(ExerciseEntity exercise) {
        return exerciseRepository.save(exercise);
    }
}
package com.api.realsteel.service;

import java.util.List;

import org.springframework.stereotype.Service;

import com.api.realsteel.entity.ExerciseEntity;
import com.api.realsteel.error.ResourceNotFoundException;
import com.api.realsteel.repository.ExerciseRepository;

@Service
public class ExerciseService {

    private final ExerciseRepository exerciseRepository;

    public ExerciseService(ExerciseRepository exerciseRepository) {
        this.exerciseRepository = exerciseRepository;
    }

    public List<ExerciseEntity> getAllExercises() {
        return exerciseRepository.findAll();
    }

    public ExerciseEntity getExerciseById(Long id) {
        return exerciseRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Exercise not found with id " + id));
    }

    public ExerciseEntity createExercise(ExerciseEntity exercise) {
        return exerciseRepository.save(exercise);
    }

    public ExerciseEntity updateExercise(Long id, ExerciseEntity update) {
        ExerciseEntity existing = getExerciseById(id);
        if (update.getNombre() != null) existing.setNombre(update.getNombre());
        if (update.getGrupoMuscular() != null) existing.setGrupoMuscular(update.getGrupoMuscular());
        if (update.getDescripcion() != null) existing.setDescripcion(update.getDescripcion());
        if (update.getImagenUrl() != null) existing.setImagenUrl(update.getImagenUrl());
        return exerciseRepository.save(existing);
    }

    public void deleteExercise(Long id) {
        ExerciseEntity existing = getExerciseById(id);
        exerciseRepository.delete(existing);
    }
}

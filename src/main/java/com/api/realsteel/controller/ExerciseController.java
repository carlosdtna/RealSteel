package com.api.realsteel.controller;

import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.api.realsteel.dto.ExerciseRequest;
import com.api.realsteel.entity.ExerciseEntity;
import com.api.realsteel.service.ExerciseService;

import jakarta.validation.Valid;

@RestController
@RequestMapping("/exercises")
@CrossOrigin
public class ExerciseController {

    private final ExerciseService exerciseService;

    public ExerciseController(ExerciseService exerciseService) {
        this.exerciseService = exerciseService;
    }

    @GetMapping("/getAll")
    public List<ExerciseEntity> getExercises() {
        return exerciseService.getAllExercises();
    }

    @GetMapping("/{id:\\d+}")
    public ExerciseEntity getExerciseById(@PathVariable Long id) {
        return exerciseService.getExerciseById(id);
    }

    @PostMapping
    public ResponseEntity<ExerciseEntity> createExercise(@Valid @RequestBody ExerciseRequest request) {
        ExerciseEntity exercise = new ExerciseEntity();
        exercise.setNombre(request.getNombre());
        exercise.setGrupoMuscular(request.getGrupoMuscular());
        exercise.setDescripcion(request.getDescripcion());
        exercise.setImagenUrl(request.getImagenUrl());
        return new ResponseEntity<>(exerciseService.createExercise(exercise), HttpStatus.CREATED);
    }

    @PutMapping("/{id:\\d+}")
    public ExerciseEntity updateExercise(@PathVariable Long id, @Valid @RequestBody ExerciseRequest request) {
        ExerciseEntity update = new ExerciseEntity();
        update.setNombre(request.getNombre());
        update.setGrupoMuscular(request.getGrupoMuscular());
        update.setDescripcion(request.getDescripcion());
        update.setImagenUrl(request.getImagenUrl());
        return exerciseService.updateExercise(id, update);
    }

    @DeleteMapping("/{id:\\d+}")
    public ResponseEntity<Void> deleteExercise(@PathVariable Long id) {
        exerciseService.deleteExercise(id);
        return ResponseEntity.noContent().build();
    }
}

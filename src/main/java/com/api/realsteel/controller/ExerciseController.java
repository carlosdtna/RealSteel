package com.api.realsteel.controller;

import com.api.realsteel.entity.ExerciseEntity;
import com.api.realsteel.repository.ExerciseRepository;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/exercises")
@CrossOrigin
public class ExerciseController {

    private final ExerciseRepository exerciseRepository;

    public ExerciseController(ExerciseRepository exerciseRepository) {
        this.exerciseRepository = exerciseRepository;
    }

    @GetMapping
    public List<ExerciseEntity> getExercises() {
        return exerciseRepository.findAll();
    }

    @PostMapping
    public ExerciseEntity createExercise(@RequestBody ExerciseEntity exercise) {
        return exerciseRepository.save(exercise);
    }
}
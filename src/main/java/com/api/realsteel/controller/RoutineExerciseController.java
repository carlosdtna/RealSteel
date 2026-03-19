package com.api.realsteel.controller;

import com.api.realsteel.entity.RoutineExerciseEntity;
import com.api.realsteel.repository.RoutineExerciseRepository;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/routine-exercises")
@CrossOrigin
public class RoutineExerciseController {

    private final RoutineExerciseRepository repository;

    public RoutineExerciseController(RoutineExerciseRepository repository) {
        this.repository = repository;
    }

    @PostMapping
    public RoutineExerciseEntity addExercise(@RequestBody RoutineExerciseEntity entity) {
        return repository.save(entity);
    }

    @GetMapping("/routine/{id}")
    public List<RoutineExerciseEntity> getByRoutine(@PathVariable Long id) {
        return repository.findByRoutine_RutinaId(id);
    }
}
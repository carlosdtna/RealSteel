package com.api.realsteel.controller;

import com.api.realsteel.dto.CreateRoutineExerciseRequest;
import com.api.realsteel.entity.RoutineExerciseEntity;
import com.api.realsteel.service.RoutineExerciseService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/routine-exercises")
@CrossOrigin
public class RoutineExerciseController {

    private final RoutineExerciseService routineExerciseService;

    public RoutineExerciseController(RoutineExerciseService routineExerciseService) {
        this.routineExerciseService = routineExerciseService;
    }

    @PostMapping("/routine/{routineId}")
    public ResponseEntity<RoutineExerciseEntity> addExerciseToRoutine(@PathVariable Long routineId,
                                                                     @Valid @RequestBody CreateRoutineExerciseRequest request) {
        RoutineExerciseEntity created = routineExerciseService.addExerciseToRoutine(
                routineId,
                request.getExerciseId(),
                request.getDiaSemana(),
                request.getOrden());
        return new ResponseEntity<>(created, HttpStatus.CREATED);
    }

    @GetMapping("/routine/{routineId}")
    public List<RoutineExerciseEntity> getByRoutine(@PathVariable Long routineId) {
        return routineExerciseService.getByRoutineId(routineId);
    }
}

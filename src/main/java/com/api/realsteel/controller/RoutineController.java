package com.api.realsteel.controller;

import com.api.realsteel.dto.CreateRoutineRequest;
import com.api.realsteel.entity.RoutineEntity;
import com.api.realsteel.service.RoutineService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/routines")
@CrossOrigin
public class RoutineController {

    private final RoutineService routineService;

    public RoutineController(RoutineService routineService) {
        this.routineService = routineService;
    }

    @PostMapping
    public ResponseEntity<RoutineEntity> createRoutine(@Valid @RequestBody CreateRoutineRequest request) {
        RoutineEntity routine = new RoutineEntity();
        routine.setNombre(request.getNombre());

        RoutineEntity created = routineService.createRoutine(request.getUserId(), routine);
        return new ResponseEntity<>(created, HttpStatus.CREATED);
    }

    @GetMapping({"", "/all"})
    public List<RoutineEntity> getAllRoutines() {
        return routineService.getAllRoutines();
    }

    @GetMapping("/user/{userId}")
    public List<RoutineEntity> getUserRoutines(@PathVariable String userId) {
        return routineService.getUserRoutines(userId);
    }

    @GetMapping("/{id:\\d+}")
    public RoutineEntity getRoutineById(@PathVariable Long id) {
        return routineService.getRoutineById(id);
    }

    @PutMapping("/{id:\\d+}")
    public RoutineEntity updateRoutine(@PathVariable Long id, @Valid @RequestBody CreateRoutineRequest request) {
        RoutineEntity update = new RoutineEntity();
        update.setNombre(request.getNombre());
        return routineService.updateRoutine(id, update);
    }

    @DeleteMapping("/{id:\\d+}")
    public ResponseEntity<Void> deleteRoutine(@PathVariable Long id) {
        routineService.deleteRoutine(id);
        return ResponseEntity.noContent().build();
    }
}

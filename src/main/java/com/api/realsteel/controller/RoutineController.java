package com.api.realsteel.controller;

import com.api.realsteel.entity.RoutineEntity;
import com.api.realsteel.repository.RoutineRepository;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/routines")
@CrossOrigin
public class RoutineController {

    private final RoutineRepository routineRepository;

    public RoutineController(RoutineRepository routineRepository) {
        this.routineRepository = routineRepository;
    }

    @PostMapping
    public RoutineEntity createRoutine(@RequestBody RoutineEntity routine) {
        return routineRepository.save(routine);
    }

    @GetMapping("/user/{userId}")
    public List<RoutineEntity> getUserRoutines(@PathVariable Long userId) {
        return routineRepository.findByUser_UserId(userId);
    }
}
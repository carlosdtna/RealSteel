package com.api.realsteel.controller;

import com.api.realsteel.dto.CreateRecordRequest;
import com.api.realsteel.entity.RecordEntity;
import com.api.realsteel.service.RecordService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/records")
@CrossOrigin
public class RecordController {

    private final RecordService recordService;

    public RecordController(RecordService recordService) {
        this.recordService = recordService;
    }

    @PostMapping("/session/{sessionId}")
    public ResponseEntity<RecordEntity> createRecord(@PathVariable Long sessionId,
                                                     @Valid @RequestBody CreateRecordRequest request) {
        RecordEntity created = recordService.createRecord(
                sessionId,
                request.getExerciseId(),
                request.getPeso(),
                request.getRepeticiones(),
                request.getHoraRegistro());
        return new ResponseEntity<>(created, HttpStatus.CREATED);
    }

    @GetMapping("/session/{sessionId}")
    public List<RecordEntity> getSessionRecords(@PathVariable Long sessionId) {
        return recordService.getRecordsBySession(sessionId);
    }
}

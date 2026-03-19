package com.api.realsteel.controller;

import com.api.realsteel.entity.RecordEntity;
import com.api.realsteel.repository.RecordRepository;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/records")
@CrossOrigin
public class RecordController {

    private final RecordRepository recordRepository;

    public RecordController(RecordRepository recordRepository) {
        this.recordRepository = recordRepository;
    }

    @PostMapping
    public RecordEntity createRecord(@RequestBody RecordEntity record) {
        return recordRepository.save(record);
    }

    @GetMapping("/{sessionId}")
    public List<RecordEntity> getSessionRecords(@PathVariable Long sessionId) {
        return recordRepository.findBySession_SessionId(sessionId);
    }
}
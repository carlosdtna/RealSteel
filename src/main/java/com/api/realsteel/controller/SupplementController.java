package com.api.realsteel.controller;

import com.api.realsteel.dto.SupplementRequest;
import com.api.realsteel.entity.SupplementEntity;
import com.api.realsteel.service.SupplementService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/supplements")
@CrossOrigin
public class SupplementController {

    private final SupplementService supplementService;

    public SupplementController(SupplementService supplementService) {
        this.supplementService = supplementService;
    }

    @PostMapping("/create")
    public ResponseEntity<SupplementEntity> createSupplement(@Valid @RequestBody SupplementRequest request) {
        SupplementEntity supplement = new SupplementEntity();
        supplement.setNombre(request.getNombre());
        supplement.setDescripcion(request.getDescripcion());
        supplement.setLinkCompra(request.getLinkCompra());
        return new ResponseEntity<>(supplementService.createSupplement(supplement), HttpStatus.CREATED);
    }

    @GetMapping("/getAll")
    public List<SupplementEntity> getAllSupplements() {
        return supplementService.getAllSupplements();
    }

    @GetMapping("/{id}")
    public SupplementEntity getSupplementById(@PathVariable Long id) {
        return supplementService.getSupplementById(id);
    }

    @PutMapping("/{id}")
    public SupplementEntity updateSupplement(@PathVariable Long id, @Valid @RequestBody SupplementRequest request) {
        SupplementEntity update = new SupplementEntity();
        update.setNombre(request.getNombre());
        update.setDescripcion(request.getDescripcion());
        update.setLinkCompra(request.getLinkCompra());
        return supplementService.updateSupplement(id, update);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteSupplement(@PathVariable Long id) {
        supplementService.deleteSupplement(id);
        return ResponseEntity.noContent().build();
    }
}

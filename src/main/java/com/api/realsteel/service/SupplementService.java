package com.api.realsteel.service;

import java.util.List;

import org.springframework.stereotype.Service;

import com.api.realsteel.entity.SupplementEntity;
import com.api.realsteel.error.ResourceNotFoundException;
import com.api.realsteel.repository.SupplementRepository;

@Service
public class SupplementService {

    private final SupplementRepository supplementRepository;

    public SupplementService(SupplementRepository supplementRepository) {
        this.supplementRepository = supplementRepository;
    }

    public SupplementEntity createSupplement(SupplementEntity supplement) {
        return supplementRepository.save(supplement);
    }

    public List<SupplementEntity> getAllSupplements() {
        return supplementRepository.findAll();
    }

    public SupplementEntity getSupplementById(Long id) {
        return supplementRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Supplement not found with id " + id));
    }

    public SupplementEntity updateSupplement(Long id, SupplementEntity update) {
        SupplementEntity existing = getSupplementById(id);
        if (update.getNombre() != null) existing.setNombre(update.getNombre());
        if (update.getDescripcion() != null) existing.setDescripcion(update.getDescripcion());
        if (update.getLinkCompra() != null) existing.setLinkCompra(update.getLinkCompra());
        return supplementRepository.save(existing);
    }

    public void deleteSupplement(Long id) {
        SupplementEntity existing = getSupplementById(id);
        supplementRepository.delete(existing);
    }
}

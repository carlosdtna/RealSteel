package com.api.realsteel.repository;

import com.api.realsteel.entity.SupplementEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface SupplementRepository extends JpaRepository<SupplementEntity, Long> {
}

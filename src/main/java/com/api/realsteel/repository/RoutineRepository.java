package com.api.realsteel.repository;

import com.api.realsteel.entity.RoutineEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface RoutineRepository extends JpaRepository<RoutineEntity, Long> {

    List<RoutineEntity> findByUser_UserId(String userId);

}
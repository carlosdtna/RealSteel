package com.api.realsteel.repository;

import com.api.realsteel.entity.RoutineExerciseEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface RoutineExerciseRepository extends JpaRepository<RoutineExerciseEntity, Long> {

    List<RoutineExerciseEntity> findByRoutine_RutinaId(Long rutinaId);

}
package com.api.realsteel.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;

@Entity
@Table(name = "routine_exercises")
public class RoutineExerciseEntity {

    @EmbeddedId
    private RoutineExerciseId id;

    private Integer orden;

    @JsonIgnore
    @MapsId("rutinaId")
    @ManyToOne
    @JoinColumn(name = "rutina_id")
    private RoutineEntity routine;

    @MapsId("ejercicioId")
    @ManyToOne
    @JoinColumn(name = "ejercicio_id")
    private ExerciseEntity exercise;

    public RoutineExerciseEntity() {}

    public RoutineExerciseId getId() {
        return id;
    }

    public void setId(RoutineExerciseId id) {
        this.id = id;
    }

    public String getDiaSemana() {
        return id != null ? id.getDiaSemana() : null;
    }

    public void setDiaSemana(String diaSemana) {
        if (id == null) {
            id = new RoutineExerciseId();
        }
        id.setDiaSemana(diaSemana);
    }

    public Integer getOrden() {
        return orden;
    }

    public void setOrden(Integer orden) {
        this.orden = orden;
    }

    public RoutineEntity getRoutine() {
        return routine;
    }

    public void setRoutine(RoutineEntity routine) {
        this.routine = routine;
    }

    public ExerciseEntity getExercise() {
        return exercise;
    }

    public void setExercise(ExerciseEntity exercise) {
        this.exercise = exercise;
    }
}
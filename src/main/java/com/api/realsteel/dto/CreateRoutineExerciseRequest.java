package com.api.realsteel.dto;

import jakarta.validation.constraints.NotNull;

public class CreateRoutineExerciseRequest {

    @NotNull(message = "El exerciseId es obligatorio")
    private Long exerciseId;

    @NotNull(message = "El día de la semana es obligatorio")
    private String diaSemana;

    private Integer orden;

    public Long getExerciseId() {
        return exerciseId;
    }

    public void setExerciseId(Long exerciseId) {
        this.exerciseId = exerciseId;
    }

    public String getDiaSemana() {
        return diaSemana;
    }

    public void setDiaSemana(String diaSemana) {
        this.diaSemana = diaSemana;
    }

    public Integer getOrden() {
        return orden;
    }

    public void setOrden(Integer orden) {
        this.orden = orden;
    }
}

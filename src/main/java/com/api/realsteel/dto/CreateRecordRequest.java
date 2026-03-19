package com.api.realsteel.dto;

import jakarta.validation.constraints.NotNull;

import java.time.LocalTime;

public class CreateRecordRequest {

    @NotNull(message = "El peso es obligatorio")
    private Double peso;

    @NotNull(message = "Las repeticiones son obligatorias")
    private Integer repeticiones;

    @NotNull(message = "La hora del registro es obligatoria")
    private LocalTime horaRegistro;

    @NotNull(message = "El exerciseId es obligatorio")
    private Long exerciseId;

    public Double getPeso() {
        return peso;
    }

    public void setPeso(Double peso) {
        this.peso = peso;
    }

    public Integer getRepeticiones() {
        return repeticiones;
    }

    public void setRepeticiones(Integer repeticiones) {
        this.repeticiones = repeticiones;
    }

    public LocalTime getHoraRegistro() {
        return horaRegistro;
    }

    public void setHoraRegistro(LocalTime horaRegistro) {
        this.horaRegistro = horaRegistro;
    }

    public Long getExerciseId() {
        return exerciseId;
    }

    public void setExerciseId(Long exerciseId) {
        this.exerciseId = exerciseId;
    }
}

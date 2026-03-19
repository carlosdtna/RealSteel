package com.api.realsteel.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;

import java.io.Serializable;
import java.util.Objects;

@Embeddable
public class RoutineExerciseId implements Serializable {

    @Column(name = "rutina_id")
    private Long rutinaId;

    @Column(name = "ejercicio_id")
    private Long ejercicioId;

    @Column(name = "dia_semana")
    private String diaSemana;

    public RoutineExerciseId() {
    }

    public RoutineExerciseId(Long rutinaId, Long ejercicioId, String diaSemana) {
        this.rutinaId = rutinaId;
        this.ejercicioId = ejercicioId;
        this.diaSemana = diaSemana;
    }

    public Long getRutinaId() {
        return rutinaId;
    }

    public void setRutinaId(Long rutinaId) {
        this.rutinaId = rutinaId;
    }

    public Long getEjercicioId() {
        return ejercicioId;
    }

    public void setEjercicioId(Long ejercicioId) {
        this.ejercicioId = ejercicioId;
    }

    public String getDiaSemana() {
        return diaSemana;
    }

    public void setDiaSemana(String diaSemana) {
        this.diaSemana = diaSemana;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof RoutineExerciseId)) return false;
        RoutineExerciseId that = (RoutineExerciseId) o;
        return Objects.equals(rutinaId, that.rutinaId) && Objects.equals(ejercicioId, that.ejercicioId) && Objects.equals(diaSemana, that.diaSemana);
    }

    @Override
    public int hashCode() {
        return Objects.hash(rutinaId, ejercicioId, diaSemana);
    }
}

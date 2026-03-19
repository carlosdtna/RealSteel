package com.api.realsteel.dto;

import jakarta.validation.constraints.NotNull;

import java.time.LocalDateTime;

public class CreateSessionRequest {

    @NotNull(message = "La fecha de la sesión es obligatoria")
    private LocalDateTime fecha;

    private Long rutinaId;

    private Integer duracion;

    private Integer calorias;

    public LocalDateTime getFecha() {
        return fecha;
    }

    public void setFecha(LocalDateTime fecha) {
        this.fecha = fecha;
    }

    public Long getRutinaId() {
        return rutinaId;
    }

    public void setRutinaId(Long rutinaId) {
        this.rutinaId = rutinaId;
    }

    public Integer getDuracion() {
        return duracion;
    }

    public void setDuracion(Integer duracion) {
        this.duracion = duracion;
    }

    public Integer getCalorias() {
        return calorias;
    }

    public void setCalorias(Integer calorias) {
        this.calorias = calorias;
    }
}

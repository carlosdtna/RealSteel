package com.api.realsteel.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public class CreateRoutineRequest {

    @NotBlank(message = "El nombre de la rutina es obligatorio")
    private String nombre;

    @NotNull(message = "El userId es obligatorio")
    private String userId;

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }
}

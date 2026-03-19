package com.api.realsteel.dto;

import jakarta.validation.constraints.NotBlank;

public class ExerciseRequest {

    @NotBlank(message = "El nombre del ejercicio es obligatorio")
    private String nombre;

    @NotBlank(message = "El grupo muscular es obligatorio")
    private String grupoMuscular;

    private String descripcion;

    private String imagenUrl;

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public String getGrupoMuscular() {
        return grupoMuscular;
    }

    public void setGrupoMuscular(String grupoMuscular) {
        this.grupoMuscular = grupoMuscular;
    }

    public String getDescripcion() {
        return descripcion;
    }

    public void setDescripcion(String descripcion) {
        this.descripcion = descripcion;
    }

    public String getImagenUrl() {
        return imagenUrl;
    }

    public void setImagenUrl(String imagenUrl) {
        this.imagenUrl = imagenUrl;
    }
}

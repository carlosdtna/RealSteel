package com.api.realsteel.dto;

import jakarta.validation.constraints.NotBlank;

public class SupplementRequest {

    @NotBlank(message = "El nombre es obligatorio")
    private String nombre;

    @NotBlank(message = "La descripcion es obligatoria")
    private String descripcion;

    private String linkCompra;

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public String getDescripcion() {
        return descripcion;
    }

    public void setDescripcion(String descripcion) {
        this.descripcion = descripcion;
    }

    public String getLinkCompra() {
        return linkCompra;
    }

    public void setLinkCompra(String linkCompra) {
        this.linkCompra = linkCompra;
    }
}

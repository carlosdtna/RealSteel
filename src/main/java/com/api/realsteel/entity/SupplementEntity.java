package com.api.realsteel.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "supplements")
public class SupplementEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long supplementId;

    private String nombre;

    private String descripcion;

    private String linkCompra;

    public SupplementEntity() {
    }

    public Long getSupplementId() {
        return supplementId;
    }

    public void setSupplementId(Long supplementId) {
        this.supplementId = supplementId;
    }

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
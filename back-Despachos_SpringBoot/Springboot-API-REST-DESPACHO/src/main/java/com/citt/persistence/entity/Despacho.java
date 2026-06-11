package com.citt.persistence.entity;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import jakarta.validation.constraints.*;
import java.time.LocalDate;

@Entity
@Data
@AllArgsConstructor
@NoArgsConstructor
public class Despacho {
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Long idDespacho;
    @NotNull(message = "Fecha de despacho es obligatoria")
    @DateTimeFormat(iso = DateTimeFormat.ISO.DATE)  // Especifica el formato de fecha
    private LocalDate fechaDespacho;
    @NotBlank(message = "La patente del camión es obligatoria")
    @Pattern(regexp = "^[A-Z]{2}[A-Z0-0]{2}[0-9]{2}$|^[A-Z]{4}[0-9]{2}$", message = "Formato de patente inválido")
    private String patenteCamion;
    @Min(value = 1, message = "El número de intento debe ser al menos 1")
    private int intento;
    @NotNull(message = "El ID de compra es obligatorio")
    private Long idCompra;
    @NotBlank(message = "La dirección de compra es obligatoria")
    private String direccionCompra;
    @Positive(message = "El valor de compra debe ser mayor a cero")
    private Long valorCompra;
    private boolean despachado = false;
}
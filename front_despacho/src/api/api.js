// src/api/api.js
import axios from "axios";

// Configuración de la instancia base
const api = axios.create({
  baseURL: "http://192.168.3.20/api/v1", // Centralizas la IP aquí
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json'
  }
});

// Funciones para Despachos
export const getDespachos = () => api.get("/despachos");
export const crearDespacho = (data) => api.post("/despachos", data);

// Funciones para Ventas
export const actualizarVenta = (id, data) => api.put(`/ventas/${id}`, data);
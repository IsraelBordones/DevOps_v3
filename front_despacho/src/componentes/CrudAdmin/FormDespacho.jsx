import { useState } from "react";
import { useForm } from "react-hook-form";
import Swal from "sweetalert2";
import { crearDespacho, actualizarVenta } from "../../api/api"; // Importación de funciones centralizadas

export const FormDespacho = ({ venta, onClose }) => {
  const { register, handleSubmit, formState: { errors } } = useForm();
  const [submitting, setSubmitting] = useState(false); // Estado para evitar múltiples clics

  const onSubmit = async (data) => {
    setSubmitting(true);
    
    const jsonData = {
      fechaDespacho: data.fechaDespacho,
      patenteCamion: data.patenteCamion,
      intento: 0,
      entregado: false,
      idCompra: venta.idVenta,
      direccionCompra: venta.direccionCompra,
      valorCompra: venta.valorCompra,
    };

    const jsonDataSales = {
      despachoGenerado: true,
    };

    try {
      // Usamos las llamadas centralizadas configuradas en api.js
      await actualizarVenta(venta.idVenta, jsonDataSales);
      await crearDespacho(jsonData);

      await Swal.fire({
        title: "Despacho registrado 🛻!",
        text: "El despacho ha sido generado con éxito en la base de datos",
        icon: "success",
        confirmButtonText: "Aceptar",
      });
      
      onClose(); // Cerramos el modal solo si la operación fue exitosa
    } catch (error) {
      console.error("Error en la solicitud:", error);
      Swal.fire({
        title: "Error",
        text: "Hubo un problema al registrar el despacho. Por favor, intente nuevamente.",
        icon: "error",
        confirmButtonText: "Cerrar",
      });
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <>
      <form
        onSubmit={handleSubmit(onSubmit)}
        className="flex flex-col justify-center text-center px-24 text-xl"
      >
        <div className="mx-auto text-3xl font-bold mb-10 text-teal-600">
          Ingreso de orden de despacho
        </div>

        {/* Fecha de despacho */}
        <div className="mb-5">
          <label className="block font-bold mb-2">Fecha de despacho</label>
          <input
            type="date"
            className={`border rounded-lg block w-full p-1 ${errors.fechaDespacho ? 'border-red-500' : 'border-gray-300'}`}
            {...register("fechaDespacho", { required: "La fecha es obligatoria" })}
          />
          {errors.fechaDespacho && <span className="text-red-500 text-sm">{errors.fechaDespacho.message}</span>}
        </div>

        {/* Patente de camión */}
        <div className="mb-5">
          <label className="block font-bold mb-2">Patente de camión</label>
          <input
            type="text"
            placeholder="Ej: ABCD12"
            className={`border rounded-lg block w-full p-1 ${errors.patenteCamion ? 'border-red-500' : 'border-gray-300'}`}
            {...register("patenteCamion", { required: "La patente es obligatoria" })}
          />
          {errors.patenteCamion && <span className="text-red-500 text-sm">{errors.patenteCamion.message}</span>}
        </div>

        {/* Datos de lectura (deshabilitados) */}
        <div className="mb-5">
          <label className="block font-bold mb-2 text-gray-500">Orden de compra asociado</label>
          <input
            type="number"
            disabled
            value={venta.idVenta}
            className="border border-gray-200 rounded-lg block w-full bg-gray-50 text-slate-400 p-1"
          />
        </div>

        <div className="mb-5">
          <label className="block font-bold mb-2 text-gray-500">Dirección de entrega</label>
          <input
            type="text"
            disabled
            value={venta.direccionCompra}
            className="border border-gray-200 rounded-lg block w-full bg-gray-50 text-slate-400 p-1"
          />
        </div>

        <div className="mb-5">
          <label className="block font-bold mb-2 text-gray-500">Valor de compra</label>
          <input
            type="number"
            disabled
            value={venta.valorCompra}
            className="border border-gray-200 rounded-lg block w-full bg-gray-50 text-slate-400 p-1"
          />
        </div>

        <button
          className={`py-6 px-14 rounded-lg font-bold mb-14 text-white transition-colors ${
            submitting ? 'bg-gray-400 cursor-not-allowed' : 'bg-teal-600 hover:bg-teal-700'
          }`}
          type="submit"
          disabled={submitting}
        >
          {submitting ? "Procesando..." : "Asignar despacho"}
        </button>
      </form>
    </>
  );
};
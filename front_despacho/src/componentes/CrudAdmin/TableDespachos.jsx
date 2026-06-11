import { useState, useEffect } from "react";
import { Modal } from "./Modal";
import { FormCierreDespacho } from "./FormCierreDespacho";
import { getDespachos } from "../../api/api"; 

export const TableDespachos = () => {
  const [despachos, setDespachos] = useState([]);
  const [loading, setLoading] = useState(true); 
  const [openModal, setOpenModal] = useState(false);
  const [despachoSeleccionado, setDespachoSeleccionado] = useState(null);

  const fetchDespachos = async () => {
    try {
      setLoading(true);
      const response = await getDespachos();
      setDespachos(response.data);
    } catch (error) {
      console.error("Error al obtener los despachos:", error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchDespachos();
  }, []);

  const handleAbrirModal = (despacho) => {
    setDespachoSeleccionado(despacho);
    setOpenModal(true);
  };

  return (
    <>
      <section className="mb-8 p-4">
        {loading ? (
          <div className="py-10 text-center text-teal-600 font-bold">Cargando despachos...</div>
        ) : (
          /* Contenedor Grid en lugar de Tabla */
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {despachos.map((despacho) => (
              /* Diseño de la Tarjeta equivalente al card.css del profesor */
              <div 
                key={despacho.idDespacho} 
                className="bg-[#1e293b] p-[20px] rounded-[12px] shadow-[0_10px_20px_rgba(0,0,0,0.3)] text-white flex flex-col justify-between"
              >
                <div>
                  <h3 className="text-xl font-bold mb-2">Despacho N° {despacho.idDespacho}</h3>
                  <p className="text-gray-300 text-sm mb-1"><strong>Compra:</strong> {despacho.idCompra}</p>
                  <p className="text-gray-300 text-sm mb-1"><strong>Dirección:</strong> {despacho.direccionCompra}</p>
                  <p className="text-gray-300 text-sm mb-1"><strong>Fecha:</strong> {despacho.fechaDespacho}</p>
                  <p className="text-gray-300 text-sm mb-1"><strong>Patente:</strong> {despacho.patenteCamion}</p>
                  <p className="text-gray-300 text-sm mb-1">
                    <strong>Estado:</strong> {despacho.entregado ? "Entregado" : "Pendiente"}
                  </p>
                  <p className="text-gray-300 text-sm"><strong>Intentos:</strong> {despacho.intento}</p>
                </div>

                {/* Acciones de la Tarjeta (Equivalente a .card-actions) */}
                <div className="flex justify-between mt-[10px] pt-4">
                  <button
                    onClick={() => handleAbrirModal(despacho)}
                    className="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700 transition-colors"
                  >
                    Cerrar despacho
                  </button>
                  {/* Si tuvieras un botón de eliminar, iría aquí con clase bg-red-600 para imitar su .danger */}
                </div>
              </div>
            ))}
          </div>
        )}
      </section>

      <Modal
        onClose={() => setOpenModal(false)}
        open={openModal}
      >
        {despachoSeleccionado && (
          <FormCierreDespacho
            despacho={despachoSeleccionado}
            onClose={() => {
              setOpenModal(false);
              fetchDespachos(); 
            }}
          />
        )}
      </Modal>
    </>
  );
};
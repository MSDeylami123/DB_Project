// src/pages/SupportReservations.jsx
import { useEffect, useState } from "react";
import api from "../api";

export default function SupportReservations() {
  const [reservations, setReservations] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [cancellingId, setCancellingId] = useState(null); // track cancellation in progress

  useEffect(() => {
    const fetchReservations = async () => {
      try {
        const res = await api.get("/support/reservations");
        setReservations(res.data);
      } catch (err) {
        setError(err.response?.data?.message || err.message);
      } finally {
        setLoading(false);
      }
    };

    fetchReservations();
  }, []);

  const handleCancel = async (reservationId) => {
    if (!window.confirm("Are you sure you want to cancel this reservation?")) return;

    setCancellingId(reservationId);
    try {
      await api.post("/support/reservations/cancel", { ReservationID: reservationId });

      // Update local state
      setReservations((prev) =>
        prev.map((r) =>
          r.ReservationID === reservationId
            ? { ...r, ReservationStatus: "Canceled" }
            : r
        )
      );
    } catch (err) {
      alert(err.response?.data?.message || err.message);
    } finally {
      setCancellingId(null);
    }
  };

  if (loading) return <p className="p-4">Loading reservations...</p>;
  if (error) return <p className="p-4 text-red-500">{error}</p>;
  if (reservations.length === 0) return <p className="p-4">No reservations found.</p>;

  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold mb-4">All Reservations</h1>
      <div className="grid gap-4">
        {reservations.map((resv) => (
          <div
            key={resv.ReservationID}
            className="shadow-md p-4 border rounded bg-white"
          >
            <p><strong>Reservation ID:</strong> {resv.ReservationID}</p>
            <p><strong>User:</strong> {resv.FirstName} {resv.LastName}</p>
            <p><strong>Ticket ID:</strong> {resv.TicketID}</p>
            <p><strong>Origin:</strong> {resv.Origin}</p>
            <p><strong>Destination:</strong> {resv.Destination}</p>
            <p><strong>Departure Time:</strong> {resv.DepartureTime}</p>
            <p><strong>Vehicle Type:</strong> {resv.VehicleType}</p>
            <p><strong>Status:</strong> {resv.ReservationStatus}</p>
            <p><strong>Reserved At:</strong> {resv.ReservationTime}</p>
            <p><strong>Expires At:</strong> {resv.ExpirationTime}</p>

            {resv.ReservationStatus !== "Canceled" && (
              <button
                className="mt-2 bg-red-500 text-white px-2 py-1 rounded disabled:opacity-50"
                disabled={cancellingId === resv.ReservationID}
                onClick={() => handleCancel(resv.ReservationID)}
              >
                {cancellingId === resv.ReservationID ? "Cancelling..." : "Cancel Reservation"}
              </button>
            )}
          </div>
        ))}
      </div>
    </div>
  );
}

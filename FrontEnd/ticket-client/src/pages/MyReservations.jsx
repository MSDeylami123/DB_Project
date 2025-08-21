import { useEffect, useState } from "react";
import api from "../api";

export default function MyReservations() {
  const [reservations, setReservations] = useState({ active: [], history: [] });
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [paying, setPaying] = useState(null); // store reservation being paid
  const [paymentMethods, setPaymentMethods] = useState({}); // store selected payment method per reservation

  const methods = ["Wallet", "Bank Card", "Cryptocurrency"];

  // Fetch reservations
  useEffect(() => {
    const fetchReservations = async () => {
      try {
        const res = await api.get("/reservations/my");
        setReservations(res.data);
      } catch (err) {
        setError(err.response?.data?.message || err.message);
      } finally {
        setLoading(false);
      }
    };

    fetchReservations();
  }, []);

  // Handle payment method change
  const handleMethodChange = (reservationID, method) => {
    setPaymentMethods((prev) => ({ ...prev, [reservationID]: method }));
  };

  // Pay for a reservation
  const handlePay = async (reservationID) => {
    const selectedMethod = paymentMethods[reservationID] || "Wallet"; // default to Wallet
    setPaying(reservationID);
    try {
      const res = await api.post("/reservations/pay", {
        reservationID,
        paymentMethod: selectedMethod,
      });

      alert(res.data.message);
      // Refresh reservations after payment
      const updated = await api.get("/reservations/my");
      setReservations(updated.data);
    } catch (err) {
      alert(err.response?.data?.message || err.message);
    } finally {
      setPaying(null);
    }
  };

  if (loading) return <p className="p-4">Loading reservations...</p>;
  if (error) return <p className="p-4 text-red-500">{error}</p>;

  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold mb-4">My Reservations</h1>

      <h2 className="text-xl font-semibold mt-4">Active Reservations</h2>
      {reservations.active.length === 0 ? (
        <p>No active reservations.</p>
      ) : (
        <div className="grid gap-4">
          {reservations.active.map((resv) => (
            <div
              key={resv.ReservationID}
              className="shadow-md p-4 border rounded bg-white"
            >
              <p><strong>Reservation ID:</strong> {resv.ReservationID}</p>
              <p><strong>Ticket ID:</strong> {resv.TicketID}</p>
              <p><strong>Status:</strong> {resv.ReservationStatus}</p>
              <p><strong>Expires At:</strong> {resv.ExpirationTime}</p>
              <p><strong>Created At:</strong> {resv.ReservationTime}</p>

              <label>
                Payment Method:{" "}
                <select
                  value={paymentMethods[resv.ReservationID] || "Wallet"}
                  onChange={(e) =>
                    handleMethodChange(resv.ReservationID, e.target.value)
                  }
                  className="border rounded px-2 py-1 ml-2"
                >
                  {methods.map((method) => (
                    <option key={method} value={method}>
                      {method}
                    </option>
                  ))}
                </select>
              </label>

              <button
                className="mt-2 bg-blue-500 text-white px-3 py-1 rounded"
                onClick={() => handlePay(resv.ReservationID)}
                disabled={paying === resv.ReservationID}
              >
                {paying === resv.ReservationID ? "Processing..." : "Pay"}
              </button>
            </div>
          ))}
        </div>
      )}

      <h2 className="text-xl font-semibold mt-8">Reservation History</h2>
      {reservations.history.length === 0 ? (
        <p>No past reservations.</p>
      ) : (
        <div className="grid gap-4">
          {reservations.history.map((resv) => (
            <div
              key={resv.ReservationID}
              className="shadow-md p-4 border rounded bg-gray-100"
            >
              <p><strong>Reservation ID:</strong> {resv.ReservationID}</p>
              <p><strong>Ticket ID:</strong> {resv.TicketID}</p>
              <p><strong>Status:</strong> {resv.ReservationStatus}</p>
              <p><strong>Expires At:</strong> {resv.ExpirationTime}</p>
              <p><strong>Created At:</strong> {resv.ReservationTime}</p>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}

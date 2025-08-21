import { useEffect, useState } from "react";
import api from "../api";

export default function MyPurchases() {
  const [tickets, setTickets] = useState({ upcoming: [], used: [], canceled: [] });
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [penalty, setPenalty] = useState({});
  const [penaltyError, setPenaltyError] = useState(null);
  const [activePenaltyId, setActivePenaltyId] = useState(null); // track which reservation we clicked
  const [cancelError, setCancelError] = useState(null);
  const [cancelSuccess, setCancelSuccess] = useState(null);

  useEffect(() => {
    const fetchPurchasedTickets = async () => {
      try {
        const res = await api.get("/reservations/purchased");
        setTickets(res.data);
      } catch (err) {
        setError(err.response?.data?.message || err.message);
      } finally {
        setLoading(false);
      }
    };

    fetchPurchasedTickets();
  }, []);

  const checkPenalty = async (reservationId) => {
    try {
      setPenaltyError(null);
      setActivePenaltyId(reservationId); // mark this card as active
      const res = await api.get(`/reservations/penalty/${reservationId}`);
      setPenalty((prev) => ({ ...prev, [reservationId]: res.data })); // store by id
    } catch (err) {
      setPenaltyError(err.response?.data?.message || err.message);
    }
  };

  const cancelReservation = async (reservationId) => {
    try {
      setCancelError(null);
      setCancelSuccess(null);

      // ✅ Send reservationID in the POST body, not URL
      const res = await api.post(`/reservations/cancel`, {
        reservationID: reservationId
      });

      setCancelSuccess(res.data.message);

      // Update UI: remove from upcoming, add to canceled
      setTickets((prev) => {
        const updatedUpcoming = prev.upcoming.filter(t => t.ReservationID !== reservationId);
        const canceledTicket = prev.upcoming.find(t => t.ReservationID === reservationId);
        return {
          ...prev,
          upcoming: updatedUpcoming,
          canceled: canceledTicket ? [...prev.canceled, canceledTicket] : prev.canceled,
        };
      });

      // Reset penalty display
      setActivePenaltyId(null);
    } catch (err) {
      setCancelError(err.response?.data?.message || err.message);
    }
  };

  if (loading) return <p className="p-4">Loading purchased tickets...</p>;
  if (error) return <p className="p-4 text-red-500">{error}</p>;

  const renderTickets = (ticketArray, isUpcoming = false) =>
    ticketArray.length === 0 ? (
      <p>No tickets in this category.</p>
    ) : (
      <div className="grid gap-4">
        {ticketArray.map((ticket) => (
          <div
            key={ticket.ReservationID}
            className="shadow-md p-4 border rounded bg-white"
          >
            <p><strong>Reservation ID:</strong> {ticket.ReservationID}</p>
            <p><strong>Ticket ID:</strong> {ticket.TicketID}</p>
            <p><strong>Origin:</strong> {ticket.Origin}</p>
            <p><strong>Destination:</strong> {ticket.Destination}</p>
            <p><strong>Departure:</strong> {ticket.DepartureTime}</p>
            <p><strong>Vehicle:</strong> {ticket.VehicleType}</p>
            <p><strong>Payment Status:</strong> {ticket.PaymentStatus}</p>
            <p><strong>Payment Time:</strong> {ticket.PaymentTime}</p>

            {/* Show "Check Penalty" button only for upcoming & paid tickets */}
            {isUpcoming && ticket.PaymentStatus === "Successful" && (
              <>
                <button
                  onClick={() => checkPenalty(ticket.ReservationID)}
                  className="mt-2 px-4 py-1 bg-yellow-500 text-white rounded"
                >
                  Check Penalty
                </button>

                {/* Show penalty result ONLY for this reservation */}
                {activePenaltyId === ticket.ReservationID && penalty[ticket.ReservationID] && (
                  <div className="mt-4 p-3 border rounded bg-yellow-50">
                    <h3 className="text-lg font-bold">Cancellation Penalty</h3>
                    <p><strong>Hours Left:</strong> {penalty[ticket.ReservationID].HoursLeft} hrs</p>
                    <p><strong>Ticket Price:</strong> ${penalty[ticket.ReservationID].Price}</p>
                    <p><strong>Penalty Percentage:</strong> {penalty[ticket.ReservationID].PenaltyPercentage}%</p>
                    <p><strong>Refund Amount:</strong> ${penalty[ticket.ReservationID].RefundAmount}</p>

                    {/* Cancel button */}
                    <button
                      onClick={() => cancelReservation(ticket.ReservationID)}
                      className="mt-3 px-4 py-1 bg-red-600 text-white rounded"
                    >
                      Confirm Cancel Reservation
                    </button>
                  </div>
                )}
              </>
            )}
          </div>
        ))}
      </div>
    );

  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold mb-4">My Purchased Tickets</h1>

      <h2 className="text-xl font-semibold mt-4">Upcoming Tickets</h2>
      {renderTickets(tickets.upcoming, true)}

      {penaltyError && <p className="text-red-500 mt-4">{penaltyError}</p>}
      {cancelError && <p className="text-red-500 mt-4">{cancelError}</p>}
      {cancelSuccess && <p className="text-green-600 mt-4">{cancelSuccess}</p>}

      <h2 className="text-xl font-semibold mt-8">Used Tickets</h2>
      {renderTickets(tickets.used)}

      <h2 className="text-xl font-semibold mt-8">Canceled Tickets</h2>
      {renderTickets(tickets.canceled)}
    </div>
  );
}

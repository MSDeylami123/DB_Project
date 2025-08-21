// src/pages/CancelledPayments.jsx
import { useEffect, useState } from "react";
import api from "../api";

export default function CancelledPayments() {
  const [payments, setPayments] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchCancelledPayments = async () => {
      try {
        const res = await api.get("/support/payments/cancelled");
        setPayments(res.data);
      } catch (err) {
        setError(err.response?.data?.message || err.message);
      } finally {
        setLoading(false);
      }
    };

    fetchCancelledPayments();
  }, []);

  if (loading) return <p className="p-4">Loading cancelled payments...</p>;
  if (error) return <p className="p-4 text-red-500">{error}</p>;
  if (payments.length === 0) return <p className="p-4">No cancelled or failed payments found.</p>;

  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold mb-4">Cancelled / Failed Payments</h1>
      <div className="grid gap-4">
        {payments.map((payment) => (
          <div
            key={payment.PaymentID}
            className="shadow-md p-4 border rounded bg-white"
          >
            <p><strong>Payment ID:</strong> {payment.PaymentID}</p>
            <p><strong>User:</strong> {payment.FirstName} {payment.LastName}</p>
            <p><strong>Reservation ID:</strong> {payment.ReservationID}</p>
            <p><strong>Amount:</strong> ${payment.Amount}</p>
            <p><strong>Payment Method:</strong> {payment.PaymentMethod}</p>
            <p><strong>Status:</strong> {payment.PaymentStatus}</p>
            <p><strong>Payment Time:</strong> {payment.PaymentTime}</p>
          </div>
        ))}
      </div>
    </div>
  );
}

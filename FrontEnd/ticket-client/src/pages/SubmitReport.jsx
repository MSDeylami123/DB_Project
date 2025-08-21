// src/pages/SubmitReport.jsx
import { useState } from "react";
import api from "../api";

export default function SubmitReport() {
  const [ticketID, setTicketID] = useState("");
  const [reservationID, setReservationID] = useState("");
  const [category, setCategory] = useState("");
  const [reportText, setReportText] = useState("");
  const [loading, setLoading] = useState(false);
  const [successMessage, setSuccessMessage] = useState(null);
  const [errorMessage, setErrorMessage] = useState(null);

  const categories = [
    "Payment Issue",
    "Travel Delay",
    "Unexpected Cancellation"
  ];

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setErrorMessage(null);
    setSuccessMessage(null);

    // Basic frontend validation
    if (!ticketID || !reservationID || !category || !reportText) {
      setErrorMessage("Ticket ID, Reservation ID, Category, and Report Text are all required.");
      setLoading(false);
      return;
    }

    try {
      const res = await api.post("/reports/submit", {
        ticketID: parseInt(ticketID),
        reservationID: parseInt(reservationID),
        reportCategory: category,
        reportText: reportText
      });

      setSuccessMessage(res.data.message);
      setTicketID("");
      setReservationID("");
      setCategory("");
      setReportText("");
    } catch (err) {
      setErrorMessage(err.response?.data?.message || err.message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="p-6 max-w-xl mx-auto">
      <h1 className="text-2xl font-bold mb-4">Submit a Report</h1>

      {errorMessage && <p className="text-red-500 mb-4">{errorMessage}</p>}
      {successMessage && <p className="text-green-600 mb-4">{successMessage}</p>}

      <form onSubmit={handleSubmit} className="space-y-4">
        <div>
          <label className="block font-semibold">Ticket ID</label>
          <input
            type="number"
            value={ticketID}
            onChange={(e) => setTicketID(e.target.value)}
            className="w-full border p-2 rounded"
            required
          />
        </div>

        <div>
          <label className="block font-semibold">Reservation ID</label>
          <input
            type="number"
            value={reservationID}
            onChange={(e) => setReservationID(e.target.value)}
            className="w-full border p-2 rounded"
            required
          />
        </div>

        <div>
          <label className="block font-semibold">Report Category</label>
          <select
            value={category}
            onChange={(e) => setCategory(e.target.value)}
            className="w-full border p-2 rounded"
            required
          >
            <option value="">-- Select Category --</option>
            {categories.map((cat) => (
              <option key={cat} value={cat}>{cat}</option>
            ))}
          </select>
        </div>

        <div>
          <label className="block font-semibold">Report Text</label>
          <textarea
            value={reportText}
            onChange={(e) => setReportText(e.target.value)}
            className="w-full border p-2 rounded"
            rows={5}
            required
          />
        </div>

        <button
          type="submit"
          disabled={loading}
          className="px-4 py-2 bg-blue-600 text-white rounded"
        >
          {loading ? "Submitting..." : "Submit Report"}
        </button>
      </form>
    </div>
  );
}

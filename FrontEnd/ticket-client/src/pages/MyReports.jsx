// src/pages/MyReports.jsx
import { useEffect, useState } from "react";
import api from "../api";

export default function MyReports() {
  const [reports, setReports] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchReports = async () => {
      try {
        const res = await api.get("/reports/my");
        setReports(res.data);
      } catch (err) {
        setError(err.response?.data?.message || err.message);
      } finally {
        setLoading(false);
      }
    };

    fetchReports();
  }, []);

  if (loading) return <p className="p-4">Loading your reports...</p>;
  if (error) return <p className="p-4 text-red-500">{error}</p>;

  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold mb-4">My Submitted Reports</h1>

      {reports.length === 0 ? (
        <p>No reports submitted yet.</p>
      ) : (
        <div className="grid gap-4">
          {reports.map((report) => (
            <div
              key={report.ReportID}
              className="shadow-md p-4 border rounded bg-white"
            >
              <p><strong>Report ID:</strong> {report.ReportID}</p>
              <p><strong>Ticket ID:</strong> {report.TicketID || "-"}</p>
              <p><strong>Reservation ID:</strong> {report.ReservationID || "-"}</p>
              <p><strong>Category:</strong> {report.ReportCategory}</p>
              <p><strong>Text:</strong> {report.ReportText}</p>
              <p><strong>Status:</strong> {report.ProcessingStatus}</p>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}

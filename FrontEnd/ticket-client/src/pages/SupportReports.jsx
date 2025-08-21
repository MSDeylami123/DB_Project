import { useEffect, useState } from "react";
import api from "../api";

export default function SupportReports() {
  const [reports, setReports] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [answers, setAnswers] = useState({}); // top-level answers state
  const [submittingId, setSubmittingId] = useState(null);

  useEffect(() => {
    const fetchAllReports = async () => {
      try {
        const res = await api.get("/support/admin/reports");
        setReports(res.data);
      } catch (err) {
        setError(err.response?.data?.message || err.message);
      } finally {
        setLoading(false);
      }
    };
    fetchAllReports();
  }, []);

  const handleAnswer = async (reportId) => {
    const answer = answers[reportId];
    if (!answer) return;

    setSubmittingId(reportId);
    try {
      await api.post("/support/admin/reports/respond", {
        ReportID: reportId,
        ProcessingStatus: "Reviewed",
        Answer: answer,
      });

      setReports((prev) =>
        prev.map((r) =>
          r.ReportID === reportId
            ? { ...r, Answer: answer, ProcessingStatus: "Reviewed" }
            : r
        )
      );

      setAnswers((prev) => ({ ...prev, [reportId]: answer })); // keep updated
    } catch (err) {
      alert(err.response?.data?.error || err.message);
    } finally {
      setSubmittingId(null);
    }
  };

  if (loading) return <p className="p-4">Loading reports...</p>;
  if (error) return <p className="p-4 text-red-500">{error}</p>;
  if (reports.length === 0) return <p className="p-4">No reports submitted yet.</p>;

  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold mb-4">All Submitted Reports</h1>
      <div className="grid gap-4">
        {reports.map((report) => (
          <div
            key={report.ReportID}
            className="shadow-md p-4 border rounded bg-white"
          >
            <p><strong>Report ID:</strong> {report.ReportID}</p>
            <p><strong>User ID:</strong> {report.UserID}</p>
            <p><strong>Ticket ID:</strong> {report.TicketID}</p>
            <p><strong>Reservation ID:</strong> {report.ReservationID}</p>
            <p><strong>Category:</strong> {report.ReportCategory}</p>
            <p><strong>Text:</strong> {report.ReportText}</p>
            <p><strong>Status:</strong> {report.ProcessingStatus}</p>
            {report.Answer && <p><strong>Answer:</strong> {report.Answer}</p>}

            {/* Answer form */}
            <div className="mt-2">
              <textarea
                className="border p-1 w-full"
                placeholder="Write your answer..."
                value={answers[report.ReportID] || report.Answer || ""}
                onChange={(e) =>
                  setAnswers((prev) => ({
                    ...prev,
                    [report.ReportID]: e.target.value,
                  }))
                }
                rows={3}
              />
              <button
                className="mt-1 bg-blue-500 text-white px-2 py-1 rounded disabled:opacity-50"
                disabled={submittingId === report.ReportID || !(answers[report.ReportID]?.trim())}
                onClick={() => handleAnswer(report.ReportID)}
              >
                {submittingId === report.ReportID ? "Submitting..." : "Submit Answer"}
              </button>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

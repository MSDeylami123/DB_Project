import React, { useState, useEffect } from "react";
import { useParams } from "react-router-dom";
import api from "../api";

function TicketDetails() {
  const { id } = useParams(); // get ticket ID from URL
  const [ticket, setTicket] = useState(null);
  const [error, setError] = useState("");

  useEffect(() => {
    const fetchTicket = async () => {
      try {
        const res = await api.get(`/tickets/${id}`);
        setTicket(res.data);
      } catch (err) {
        setError(err.response?.data?.message || "Failed to fetch ticket details");
      }
    };

    fetchTicket();
  }, [id]);

  if (error) return <p style={{ color: "red" }}>{error}</p>;
  if (!ticket) return <p>Loading ticket details...</p>;

  return (
    <div>
      <h1>Ticket Details</h1>
      <p><strong>Ticket ID:</strong> {ticket.ticketID}</p>
      <p><strong>Origin:</strong> {ticket.origin}</p>
      <p><strong>Destination:</strong> {ticket.destination}</p>
      <p><strong>Departure:</strong> {new Date(ticket.departureTime).toLocaleString()}</p>
      <p><strong>Arrival:</strong> {new Date(ticket.arrivalTime).toLocaleString()}</p>
      <p><strong>Price:</strong> ${ticket.price}</p>
      <p><strong>Vehicle Type:</strong> {ticket.vehicleType}</p>
      <p><strong>Travel Class:</strong> {ticket.travelClass}</p>
      <p><strong>Capacity:</strong> {ticket.capacity}</p>

      {ticket.airlineName && (
        <>
          <p><strong>Airline:</strong> {ticket.airlineName}</p>
          <p><strong>Flight Number:</strong> {ticket.flightNumber}</p>
        </>
      )}

      {ticket.trainOperator && (
        <>
          <p><strong>Train Operator:</strong> {ticket.trainOperator}</p>
          <p><strong>Train Number:</strong> {ticket.trainNumber}</p>
        </>
      )}

      {ticket.busCompany && <p><strong>Bus Company:</strong> {ticket.busCompany}</p>}

      {ticket.facilities && <p><strong>Facilities:</strong> {ticket.facilities}</p>}
    </div>
  );
}

export default TicketDetails;

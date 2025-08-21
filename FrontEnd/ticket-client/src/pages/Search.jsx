import React, { useState } from "react";
import { Link } from "react-router-dom";
import api from "../api";

function Search() {
  const [formData, setFormData] = useState({
    origin: "",
    destination: "",
    date: "",
    vehicleType: "",
    filters: {
      price_min: "",
      price_max: "",
      departure_after: "",
      class: "",
    },
  });

  const [results, setResults] = useState([]);
  const [error, setError] = useState("");

  const handleChange = (e) => {
    const { name, value } = e.target;

    // Handle nested filters
    if (name.startsWith("filters.")) {
      const filterKey = name.split(".")[1];
      setFormData((prev) => ({
        ...prev,
        filters: { ...prev.filters, [filterKey]: value },
      }));
    } else {
      setFormData((prev) => ({ ...prev, [name]: value }));
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError("");

    try {
      const token = localStorage.getItem("token");
      const response = await api.post(
        "/tickets/search",
        formData,
        {
          headers: {
            Authorization: `Bearer ${token}`,
          },
        }
      );

      setResults(response.data.tickets);
    } catch (err) {
      setError(err.response?.data?.message || "Error searching tickets");
    }
  };

// Reserve ticket
  const handleReserve = async (ticketID) => {
    setError("");
    try {
      const token = localStorage.getItem("token");
      const response = await api.post(
        "/reservations/reserve",
        { ticketID },
        {
          headers: { Authorization: `Bearer ${token}` },
        }
      );

      alert(response.data.message);
    } catch (err) {
      setError(err.response?.data?.message || "Error reserving ticket");
    }
  };

  return (
    <div>
      <h1>Search Tickets</h1>

      <form onSubmit={handleSubmit}>
        <input
          type="text"
          name="origin"
          placeholder="Origin"
          value={formData.origin}
          onChange={handleChange}
        />
        <input
          type="text"
          name="destination"
          placeholder="Destination"
          value={formData.destination}
          onChange={handleChange}
        />
        <input
          type="date"
          name="date"
          value={formData.date}
          onChange={handleChange}
        />
        <select
          name="vehicleType"
          value={formData.vehicleType}
          onChange={handleChange}
        >
          <option value="">Select Vehicle</option>
          <option value="Plane">Plane</option>
          <option value="Train">Train</option>
          <option value="Bus">Bus</option>
        </select>

        <h3>Filters</h3>
        <input
          type="number"
          name="filters.price_min"
          placeholder="Min Price"
          value={formData.filters.price_min}
          onChange={handleChange}
        />
        <input
          type="number"
          name="filters.price_max"
          placeholder="Max Price"
          value={formData.filters.price_max}
          onChange={handleChange}
        />
        <input
          type="time"
          name="filters.departure_after"
          value={formData.filters.departure_after}
          onChange={handleChange}
        />
        <select
          name="filters.class"
          value={formData.filters.class}
          onChange={handleChange}
        >
          <option value="">Any Class</option>
          <option value="Economy">Economy</option>
          <option value="Business">Business</option>
          <option value="First">First</option>
        </select>

        <button type="submit">Search</button>
      </form>

      {error && <p style={{ color: "red" }}>{error}</p>}

      <h2>Results</h2>
      {results.length === 0 ? (
        <p>No tickets found</p>
      ) : (
        <ul>
          {results.map((ticket) => (
            <li key={ticket.ticketID}>
            Ticket ID: <Link to={`/tickets/${ticket.ticketID}`} style={{ color: "blue", textDecoration: "underline" }}>
                {ticket.ticketID}
            </Link>
            <br />
            {ticket.origin} → {ticket.destination} | {ticket.vehicleType} | {ticket.travelClass} | ${ticket.price}
            <br />
            Departure: {new Date(ticket.departureTime).toLocaleString()} | Arrival:{" "}
            {new Date(ticket.arrivalTime).toLocaleString()}
            <br />
            <button onClick={() => handleReserve(ticket.ticketID)}>
                Reserve
            </button>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}

export default Search;

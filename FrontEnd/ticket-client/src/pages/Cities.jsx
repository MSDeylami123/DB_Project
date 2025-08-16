import React, { useEffect, useState } from "react";
import api from "../api";

function Cities() {
  const [cities, setCities] = useState({ origins: [], destinations: [] });
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  useEffect(() => {
    const fetchCities = async () => {
      try {
        const res = await api.get("/tickets/cities");
        setCities(res.data);
      } catch (err) {
        console.error(err);
        setError("Failed to fetch cities");
      } finally {
        setLoading(false);
      }
    };

    fetchCities();
  }, []);

  if (loading) return <p>Loading cities...</p>;
  if (error) return <p>{error}</p>;

  return (
    <div>
      <h2>Available Cities</h2>
      <div>
        <h3>Origins:</h3>
        <ul>
          {cities.origins.map((city, index) => (
            <li key={index}>{city}</li>
          ))}
        </ul>
      </div>
      <div>
        <h3>Destinations:</h3>
        <ul>
          {cities.destinations.map((city, index) => (
            <li key={index}>{city}</li>
          ))}
        </ul>
      </div>
    </div>
  );
}

export default Cities;

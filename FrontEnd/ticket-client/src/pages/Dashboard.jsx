import React from "react";

function Dashboard() {
  const email = localStorage.getItem("userEmail"); // optional

  const handleLogout = () => {
    localStorage.removeItem("token");
    localStorage.removeItem("userEmail");
    window.location.href = "/login"; // redirect to login
  };

  return (
    <div>
      <h1>Welcome {email || "User"}!</h1>
      <p>This is your dashboard. You can access Flights, Reservations, etc. from here.</p>
      <button onClick={handleLogout}>Logout</button>
    </div>
  );
}

export default Dashboard;

import React from "react";
import { Link } from "react-router-dom";

// Passenger-specific dashboard
function PassengerDashboard() {
  return (
    <div>
      <h2>Passenger Options</h2>
      <ul>
        <li><Link to="/cities">View Cities</Link></li>
        <li><Link to="/update-profile">Update Profile</Link></li>
        <li><Link to="/search">Search Tickets</Link></li>
        <li><Link to="/reservations/my">My Reservations</Link></li>
        <li><Link to="/reservations/purchased">My Purchases</Link></li>
        <li><Link to="/reports/my">My Reports</Link></li>
        <li><Link to="/reports/submit">Submit Report</Link></li>
      </ul>
    </div>
  );
}

// Support-specific dashboard
function SupportDashboard() {
  return (
    <div>
      <h2>Support Options</h2>
      <ul>
        <li><Link to="/reports/all">View All Reports</Link></li>
      </ul>
      <ul>
        <li><Link to="/reservations/all">View All Reservations</Link></li>
      </ul>
      <ul>
        <li><Link to="/cancelled">View All Cancelled Payments</Link></li>
      </ul>
    </div>
  );
}

// Main Dashboard component
function Dashboard() {
  const email = localStorage.getItem("userEmail");
  const userType = localStorage.getItem("userType") || "Passenger";

  const handleLogout = () => {
    localStorage.removeItem("token");
    localStorage.removeItem("userEmail");
    localStorage.removeItem("userType");
    window.location.href = "/login"; // keep your current logic
  };

  return (
    <div>
      <h1>Welcome {email || "User"}!</h1>
      <p>User type: {userType}</p>

      {userType === "Passenger" ? <PassengerDashboard /> : <SupportDashboard />}

      <button onClick={handleLogout}>Logout</button>
    </div>
  );
}

export default Dashboard;

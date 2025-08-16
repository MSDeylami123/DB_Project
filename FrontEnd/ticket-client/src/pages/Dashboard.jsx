import React from "react";
import { Link } from "react-router-dom";

function Dashboard() {
  const email = localStorage.getItem("userEmail"); // optional
  const userType = localStorage.getItem("userType") || "Passenger";
  const handleLogout = () => {
    localStorage.removeItem("token");
    localStorage.removeItem("userEmail");
    localStorage.removeItem("userType");
    window.location.href = "/login"; // redirect to login
  };

  return (
    <div>
      <h1>Welcome {email || "User"}!</h1>
      <p>User type: {userType}</p>

      {userType === "Passenger" && (
        <div>
          <h2>Passenger Options</h2>
          <ul>
            <li>
              <Link to="/cities">View Cities</Link>
            </li>
            <li>
              <Link to="/update-profile">Update Profile</Link>
            </li>
          </ul>
        </div>
      )}

      {userType === "Support" && (
        <div>
          <h2>Support Options</h2>
          {/* You can add support-specific links here */}
        </div>
      )}
      
      <button onClick={handleLogout}>Logout</button>
    </div>
  );
}

export default Dashboard;

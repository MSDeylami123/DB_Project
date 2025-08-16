import React from "react";
import { Navigate } from "react-router-dom";

function ProtectedRoute({ children }) {
  const token = localStorage.getItem("token");

  if (!token) {
    // not logged in → redirect to login
    return <Navigate to="/login" replace />;
  }

  // logged in → render the page
  return children;
}

export default ProtectedRoute;

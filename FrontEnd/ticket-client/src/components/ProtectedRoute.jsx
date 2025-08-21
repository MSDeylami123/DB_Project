import React from "react";
import { Navigate } from "react-router-dom";

/**
 * Props:
 * - children: the page to render
 * - allowedRoles: array of roles allowed to access this route (optional)
 */
const ProtectedRoute = ({ children, allowedRoles }) => {
  const token = localStorage.getItem("token");
  const userType = localStorage.getItem("userType");

  // Not logged in → redirect to login
  if (!token) {
    return <Navigate to="/login" replace />;
  }

  // If allowedRoles is provided and user role is not in the list → redirect
  if (allowedRoles && !allowedRoles.includes(userType)) {
    return <Navigate to="/dashboard" replace />;
  }

  // Authorized → render page
  return children;
};

export default ProtectedRoute;

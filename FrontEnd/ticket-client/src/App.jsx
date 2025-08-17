import { BrowserRouter as Router, Routes, Route, Link } from "react-router-dom";
import Login from "./pages/Login";
import OTPLogin from "./pages/OTPLogin";
import Dashboard from "./pages/Dashboard";
import ProtectedRoute from "./components/ProtectedRoute";
import SignUp from "./pages/SignUp";
import Cities from "./pages/Cities";
import UpdateProfile from "./pages/UpdateProfile";
import Search from "./pages/Search";
import TicketDetails from "./pages/TicketDetails";

import "./App.css";

function App() {
  return (
    <Router>
      <div className="App">
        <h1>Ticket Reservation System</h1>
        <nav>
          <Link to="/signup">Sign Up</Link> |{" "}
          <Link to="/login">Password Login</Link> |{" "}
          <Link to="/otp-login">OTP Login</Link>
        </nav>

        <Routes>
          <Route path="/signup" element={<SignUp />} />
          <Route path="/login" element={<Login />} />
          <Route path="/otp-login" element={<OTPLogin />} />
          
          <Route path="/update-profile" element={
            <ProtectedRoute>
              <UpdateProfile />
            </ProtectedRoute>
          } />
          <Route path="/dashboard" element={
            <ProtectedRoute>
              <Dashboard />
            </ProtectedRoute>
          } />
          <Route path="/cities" element={
            <ProtectedRoute>
              <Cities />
            </ProtectedRoute>
          } />
          <Route path="/search" element={
            <ProtectedRoute>
              <Search />
            </ProtectedRoute>
          } />
          <Route path="/tickets/:id" element={
            <ProtectedRoute>
              <TicketDetails />
            </ProtectedRoute>
          } />
        </Routes>
      </div>
    </Router>
  );
}

export default App;

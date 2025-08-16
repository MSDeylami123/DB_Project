import { BrowserRouter as Router, Routes, Route, Link } from "react-router-dom";
import Login from "./pages/Login";
import OTPLogin from "./pages/OTPLogin";
import Dashboard from "./pages/Dashboard";
import ProtectedRoute from "./components/ProtectedRoute";
import SignUp from "./pages/SignUp";
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
          <Route path="/dashboard" element={
            <ProtectedRoute>
              <Dashboard />
            </ProtectedRoute>
          } />
        </Routes>
      </div>
    </Router>
  );
}

export default App;

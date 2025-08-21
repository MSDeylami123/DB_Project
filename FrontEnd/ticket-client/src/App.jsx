import { BrowserRouter as Router, Routes, Route, Link } from "react-router-dom";
import Login from "./pages/Login";
import OTPLogin from "./pages/OTPLogin";
import SignUp from "./pages/SignUp";
import Dashboard from "./pages/Dashboard";
import Cities from "./pages/Cities";
import UpdateProfile from "./pages/UpdateProfile";
import Search from "./pages/Search";
import TicketDetails from "./pages/TicketDetails";
import MyReservations from "./pages/MyReservations";
import MyPurchases from "./pages/MyPurchases";
import MyReports from "./pages/MyReports";
import SubmitReport from "./pages/SubmitReport";
import SupportReports from "./pages/SupportReports";
import SupportReservations from "./pages/SupportReservations";
import CancelledPayments from "./pages/CancelledPayments";
import ProtectedRoute from "./components/ProtectedRoute";
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

          {/* Dashboard accessible to both roles */}
          <Route
            path="/dashboard"
            element={
              <ProtectedRoute allowedRoles={["Passenger", "Support"]}>
                <Dashboard />
              </ProtectedRoute>
            }
          />

          {/* Passenger-only routes */}
          <Route
            path="/update-profile"
            element={
              <ProtectedRoute allowedRoles={["Passenger"]}>
                <UpdateProfile />
              </ProtectedRoute>
            }
          />
          <Route
            path="/cities"
            element={
              <ProtectedRoute allowedRoles={["Passenger"]}>
                <Cities />
              </ProtectedRoute>
            }
          />
          <Route
            path="/search"
            element={
              <ProtectedRoute allowedRoles={["Passenger"]}>
                <Search />
              </ProtectedRoute>
            }
          />
          <Route
            path="/tickets/:id"
            element={
              <ProtectedRoute allowedRoles={["Passenger"]}>
                <TicketDetails />
              </ProtectedRoute>
            }
          />
          <Route
            path="/reservations/my"
            element={
              <ProtectedRoute allowedRoles={["Passenger"]}>
                <MyReservations />
              </ProtectedRoute>
            }
          />
          <Route
            path="/reservations/purchased"
            element={
              <ProtectedRoute allowedRoles={["Passenger"]}>
                <MyPurchases />
              </ProtectedRoute>
            }
          />
          <Route
            path="/reports/my"
            element={
              <ProtectedRoute allowedRoles={["Passenger"]}>
                <MyReports />
              </ProtectedRoute>
            }
          />
          <Route
            path="/reports/submit"
            element={
              <ProtectedRoute allowedRoles={["Passenger"]}>
                <SubmitReport />
              </ProtectedRoute>
            }
          />

          {/* Support-only route */}
          <Route
            path="/reports/all"
            element={
              <ProtectedRoute allowedRoles={["Support"]}>
                <SupportReports />
              </ProtectedRoute>
            }
          />
          <Route
            path="/reservations/all"
            element={
              <ProtectedRoute allowedRoles={["Support"]}>
                <SupportReservations />
              </ProtectedRoute>
            }
          />
          <Route
            path="/cancelled"
            element={
              <ProtectedRoute allowedRoles={["Support"]}>
                <CancelledPayments />
              </ProtectedRoute>
            }
          />
        </Routes>
      </div>
    </Router>
  );
}

export default App;

import { useState } from "react";
import { useNavigate } from "react-router-dom";
import api from "../api";

function OTPLogin() {
  const [email, setEmail] = useState("");
  const [otp, setOtp] = useState("");
  const [step, setStep] = useState(1);
  const [message, setMessage] = useState("");
  const navigate = useNavigate();

  const requestOtp = () => {
    api.post("/otp/request-otp", { contact: email })
      .then(() => {
        setStep(2);
        setMessage("📩 OTP sent! Check backend console for code (dev only).");
      })
      .catch(err => setMessage("❌ Failed to send OTP"));
  };

  const verifyOtp = () => {
    api.post("/otp/verify-otp", { contact: email, otp })
      .then((res) => {
        localStorage.setItem("token", res.data.token);
        localStorage.setItem("userEmail", email);
        setMessage("✅ OTP login successful!");
        navigate("/dashboard"); // redirect after login
      })
      .catch(err => setMessage("❌ OTP verification failed"));
  };

  return (
    <div>
      <h2>OTP Login</h2>
      <input type="email" placeholder="Email" value={email} onChange={e => setEmail(e.target.value)} />
      {step === 1 && <button onClick={requestOtp}>Request OTP</button>}
      {step === 2 && (
        <>
          <input type="text" placeholder="Enter OTP" value={otp} onChange={e => setOtp(e.target.value)} />
          <button onClick={verifyOtp}>Verify OTP</button>
        </>
      )}
      <p>{message}</p>
    </div>
  );
}

export default OTPLogin;

import { useState } from "react";
import { useNavigate } from "react-router-dom";
import api from "../api";

function SignUp() {
  const [firstName, setFirstName] = useState("");
  const [lastName, setLastName] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [userType, setUserType] = useState("Passenger"); // default
  const [message, setMessage] = useState("");
  const navigate = useNavigate();

  const handleSignUp = async (e) => {
    e.preventDefault();
    try {
      const res = await api.post("/users/signup", {
        firstName,
        lastName,
        email,
        password,
        userType
      });
      setMessage("✅ Sign up successful! You can now log in.");
      navigate("/login"); // redirect to login after signup
    } catch (err) {
      console.error(err);
      setMessage("❌ Sign up failed: " + err.response?.data?.error);
    }
  };

  return (
    <div>
      <h2>Sign Up</h2>
      <form onSubmit={handleSignUp}>
        <input type="text" placeholder="First Name" value={firstName} onChange={e => setFirstName(e.target.value)} required />
        <input type="text" placeholder="Last Name" value={lastName} onChange={e => setLastName(e.target.value)} required />
        <input type="email" placeholder="Email" value={email} onChange={e => setEmail(e.target.value)} required />
        <input type="password" placeholder="Password" value={password} onChange={e => setPassword(e.target.value)} required />
        <select value={userType} onChange={e => setUserType(e.target.value)}>
          <option value="Passenger">Passenger</option>
          <option value="Support">Support</option>
        </select>
        <button type="submit">Sign Up</button>
      </form>
      <p>{message}</p>
    </div>
  );
}

export default SignUp;

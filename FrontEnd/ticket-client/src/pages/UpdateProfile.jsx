import { useState } from "react";
import { useNavigate } from "react-router-dom";
import api from "../api";

function UpdateProfile() {
  const [form, setForm] = useState({
    firstName: "",
    lastName: "",
    phone: "",
    city: "",
  });
  const [message, setMessage] = useState("");
  const navigate = useNavigate();

  const handleChange = (e) => {
    setForm({ ...form, [e.target.name]: e.target.value });
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    api.put("/users/update-profile", form)
      .then(() => {
        setMessage("✅ Profile updated successfully!");
        setTimeout(() => navigate("/dashboard"), 1500);
      })
      .catch(() => setMessage("❌ Failed to update profile"));
  };

  return (
    <div>
      <h2>Update Profile</h2>
      <form onSubmit={handleSubmit}>
        <input
          type="text"
          name="firstName"
          placeholder="First Name"
          value={form.firstName}
          onChange={handleChange}
        />
        <br />
        <input
          type="text"
          name="lastName"
          placeholder="Last Name"
          value={form.lastName}
          onChange={handleChange}
        />
        <br />
        <input
          type="text"
          name="phone"
          placeholder="Phone"
          value={form.phone}
          onChange={handleChange}
        />
        <br />
        <input
          type="text"
          name="city"
          placeholder="City"
          value={form.city}
          onChange={handleChange}
        />
        <br />
        <button type="submit">Update</button>
      </form>
      <p>{message}</p>
    </div>
  );
}

export default UpdateProfile;

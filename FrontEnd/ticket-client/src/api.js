import axios from "axios";

const api = axios.create({
  baseURL: "http://127.0.0.1:5000", // Change to your backend URL
});

export default api;

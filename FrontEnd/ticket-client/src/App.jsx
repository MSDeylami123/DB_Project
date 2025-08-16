import { useEffect, useState } from "react";
import axios from "axios";
import "./App.css";

function App() {
  const [message, setMessage] = useState("Loading...");

  useEffect(() => {
    axios
      .get("http://127.0.0.1:5000/") // replace with your backend API URL
      .then((res) => {
        setMessage(res.data);
      })
      .catch((err) => {
        console.error(err);
        setMessage("Error fetching data");
      });
  }, []);

  return (
    <div className="App">
      <h1>Backend Message:</h1>
      <p>{message}</p>
    </div>
  );
}

export default App;

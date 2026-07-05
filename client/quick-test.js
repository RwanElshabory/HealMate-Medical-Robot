const axios = require("axios");

async function quickTest() {
  try {
    console.log("Testing backend connection...");
    const res = await axios.get("http://localhost:5000/health");
    console.log("Backend is running:", res.data);
  } catch (err) {
    console.log("Error:", err.message);
    if (err.code === 'ECONNREFUSED') {
      console.log("Backend not running on port 5000");
    }
  }
}

quickTest();
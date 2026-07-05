require("dotenv").config();
const axios = require("axios");
const crypto = require("crypto");
const https = require("https");

const API_URL = process.env.API_URL || "http://localhost:5000";
const JWT_SECRET = process.env.JWT_SECRET;
const AES_KEY = Buffer.from(process.env.AES_KEY, "hex");
const IV_LENGTH = 16;

class MedicalRobotClient {
  constructor() {
    this.token = null;
    this.deviceId = this.generateDeviceId();
    this.isMobile = true;
  }

  generateDeviceId() {
    return "device_" + crypto.randomBytes(8).toString("hex");
  }

  encrypt(data) {
    const iv = crypto.randomBytes(IV_LENGTH);
    const cipher = crypto.createCipheriv("aes-256-cbc", AES_KEY, iv);

    let encrypted = cipher.update(JSON.stringify(data));
    encrypted = Buffer.concat([encrypted, cipher.final()]);

    const combined = Buffer.concat([iv, encrypted]);
    return combined.toString("base64");
  }

  async login(username, password, role) {
    try {
      const response = await axios.post(`${API_URL}/api/auth/login`, {
        username,
        password,
        role
      }, {
        headers: {
          "x-device-id": this.deviceId,
          "user-agent": this.isMobile ? "MobileApp/1.0" : "WebBrowser/1.0"
        },
        httpsAgent: new https.Agent({ rejectUnauthorized: false })
      });

      this.token = response.data.token;
      console.log(`[Client] Logged in as ${role}: ${username}`);
      return response.data;
    } catch (err) {
      throw new Error(`Login failed: ${err.response?.data?.error || err.message}`);
    }
  }

  generateJTI() {
    return crypto.randomBytes(16).toString("hex");
  }

  async sendCommand(command, params = {}) {
    if (!this.token) {
      throw new Error("Not logged in. Call login() first.");
    }

    const payload = {
      jwt_token: this.token,
      command,
      params,
      jti: this.generateJTI(),
      timestamp: Date.now()
    };

    const encryptedData = this.encrypt(payload);

    try {
      const response = await axios.post(`${API_URL}/api/command`, {
        encryptedData
      }, {
        headers: {
          "x-device-id": this.deviceId,
          "user-agent": this.isMobile ? "MobileApp/1.0" : "WebBrowser/1.0"
        },
        httpsAgent: new https.Agent({ rejectUnauthorized: false })
      });

      console.log(`[Client] Command sent: ${command}`, response.data);
      return response.data;
    } catch (err) {
      throw new Error(`Command failed: ${err.response?.data?.error || err.message}`);
    }
  }

  async move(direction = "forward") {
    return this.sendCommand("move", { direction });
  }

  async rotate(direction = "left") {
    return this.sendCommand("rotate", { direction });
  }

  async stop() {
    return this.sendCommand("stop", {});
  }

  async status() {
    return this.sendCommand("status", {});
  }

  async emergency() {
    return this.sendCommand("emergency", {});
  }
}

async function demo() {
  const client = new MedicalRobotClient();

  console.log("=== Medical Robot Client Demo ===\n");

  try {
    console.log("1. Login as Doctor...");
    await client.login("doctor1", "password", "doctor");
    
    console.log("\n2. Send move command...");
    await client.move("forward");

    console.log("\n3. Send rotate command...");
    await client.rotate("right");

    console.log("\n4. Check status...");
    await client.status();

    console.log("\n5. Stop robot...");
    await client.stop();

    console.log("\n=== Demo Complete ===");
  } catch (err) {
    console.error(`Error: ${err.message}`);
  }
}

if (require.main === module) {
  demo();
}

module.exports = MedicalRobotClient;
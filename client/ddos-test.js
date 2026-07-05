console.log("=== DDoS Flood Test (Standalone) ===\n");

const crypto = require("crypto");
const axios = require("axios");

const API_URL = "http://localhost:5000";
const STATIC_AES_KEY = Buffer.from("1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef", "hex");
const IV_LENGTH = 16;

let serverPublicKey = null;
const sessionKeys = new Map();

async function fetchServerPublicKey() {
  if (serverPublicKey) return serverPublicKey;
  try {
    const res = await axios.get(API_URL + "/api/auth/publickey");
    serverPublicKey = res.data.publicKey;
    console.log("Got server public key");
    return serverPublicKey;
  } catch (err) {
    return null;
  }
}

function encryptWithDynamicKey(data, aesKey) {
  const iv = crypto.randomBytes(IV_LENGTH);
  const cipher = crypto.createCipheriv("aes-256-cbc", aesKey, iv);
  let encrypted = cipher.update(JSON.stringify(data));
  encrypted = Buffer.concat([encrypted, cipher.final()]);
  return Buffer.concat([iv, encrypted]).toString("base64");
}

async function login(username, password, role, deviceId) {
  let ephemeralKey = crypto.randomBytes(32);
  
  const publicKey = await fetchServerPublicKey();
  
  let encryptedAesKey = null;
  if (publicKey) {
    const encrypted = crypto.publicEncrypt(
      { key: publicKey, padding: crypto.constants.RSA_PKCS1_OAEP_PADDING, oaepHash: "sha256" },
      ephemeralKey
    );
    encryptedAesKey = encrypted.toString("base64");
  }
  
  const res = await axios.post(API_URL + "/api/auth/login", {
    username, password, role, encryptedAesKey
  }, {
    headers: { "x-device-id": deviceId, "user-agent": "MobileApp/1.0" }
  });
  
  if (res.data.keyExchange === "completed") {
    sessionKeys.set(res.data.token, ephemeralKey);
  }
  
  return res.data.token;
}

async function sendCommand(token, command, params, deviceId) {
  const sessionKey = sessionKeys.get(token);
  const aesKey = sessionKey || STATIC_AES_KEY;
  
  const jti = crypto.randomUUID();
  const timestamp = Date.now();
  const nonce = crypto.randomBytes(8).toString("hex");
  const payload = { jwt_token: token, command, params, jti };
  const encrypted = encryptWithDynamicKey(payload, aesKey);
  
  return axios.post(API_URL + "/api/command", { encryptedData: encrypted }, {
    headers: {
      "authorization": "Bearer " + token,
      "x-device-id": deviceId,
      "x-nonce": nonce,
      "x-timestamp": timestamp,
      "user-agent": "MobileApp/1.0"
    }
  });
}

async function runDDoSTest() {
  console.log("╔══════════════════════════════════════════════════════════╗");
  console.log("║     DDoS / ANOMALY DETECTION - PROOF OF CONCEPT           ║");
  console.log("╚══════════════════════════════════════════════════════════╝\n");
  
  console.log("Testing anomaly detection by flooding with 20 rapid commands...");
  console.log("Threshold: Max 3 commands per second per user\n");

  const token = await login("nurse1", "password", "nurse", "device_ddos");
  console.log("Login: SUCCESS\n");

  console.log("Sending 20 RAPID commands...\n");
  console.log("+--------+----------+---------------------------------+");
  console.log("| #      | Status   | Response                        |");
  console.log("+--------+----------+---------------------------------+\n");

  let successCount = 0;
  let anomalyCount = 0;

  for (let i = 1; i <= 20; i++) {
    try {
      await sendCommand(token, "rotate", { angle: i * 10 }, "device_ddos");
      console.log("| " + String(i).padEnd(7) + " | SUCCESS | Command accepted            |");
      successCount++;
    } catch (err) {
      let response = "Error";
      if (err.response?.status === 429) {
        if (err.response.data?.error === "Anomaly Detected") {
          response = "ANOMALY BLOCKED!";
          anomalyCount++;
        } else {
          response = "Rate Limited";
        }
      }
      console.log("| " + String(i).padEnd(7) + " | 429     | " + response.padEnd(30) + "|");
    }
  }

  console.log("\n+--------+----------+---------------------------------+\n");

  console.log("=== RESULTS ===");
  console.log("Commands accepted: " + successCount);
  console.log("Anomaly blocked:   " + anomalyCount);
  console.log("");
  
  if (anomalyCount > 0) {
    console.log("✅ SUCCESS! Anomaly Detection is WORKING!");
    console.log("The system detected and blocked the DDoS attack after " + successCount + " commands.");
    console.log("Humanly impossible to send " + (successCount + anomalyCount) + " commands in 1 second!");
  } else {
    console.log("❌ FAILED - No anomaly detected");
  }
}

runDDoSTest().catch(console.error);
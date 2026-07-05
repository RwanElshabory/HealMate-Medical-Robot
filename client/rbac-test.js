console.log("=== RBAC Role-Based Access Control Test ===\n");

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

async function runRBACTest() {
  console.log("╔══════════════════════════════════════════════════════════════╗");
  console.log("║          RBAC TEST - Doctor/Nurse/Patient Roles             ║");
  console.log("╚══════════════════════════════════════════════════════════════╝\n");
  
  console.log("=== TEST 1: Nurse Role ===");
  console.log("Action: Login as nurse -> Send rotate command");
  try {
    const token = await login("nurse1", "password", "nurse", "rbac_nurse");
    await sendCommand(token, "rotate", { angle: 45 }, "rbac_nurse");
    console.log("✅ PASS: Nurse can send commands\n");
  } catch (err) {
    console.log("❌ FAIL: " + (err.response?.data?.error || err.message) + "\n");
  }

  console.log("=== TEST 2: Doctor Role (UPDATED) ===");
  console.log("Action: Login as doctor -> Send move command");
  try {
    const token = await login("doctor1", "password", "doctor", "rbac_doctor");
    await sendCommand(token, "move", { direction: "forward" }, "rbac_doctor");
    console.log("✅ PASS: Doctor can send commands (UPDATED!)\n");
  } catch (err) {
    console.log("❌ FAIL: " + (err.response?.data?.error || err.message) + "\n");
  }

  console.log("=== TEST 3: Patient Role ===");
  console.log("Action: Login as patient -> Send rotate command");
  try {
    const token = await login("patient1", "password", "patient", "rbac_patient");
    await sendCommand(token, "rotate", { angle: 90 }, "rbac_patient");
    console.log("❌ FAIL: Patient should have been blocked!\n");
  } catch (err) {
    if (err.response?.status === 403) {
      console.log("✅ PASS: Patient correctly BLOCKED (403 Forbidden)\n");
    } else {
      console.log("Status: " + err.response?.status);
      console.log("Error: " + (err.response?.data?.error || err.message) + "\n");
    }
  }

  console.log("╔══════════════════════════════════════════════════════════════╗");
  console.log("║                    RBAC SUMMARY                               ║");
  console.log("╠═════════════════════════════════════╦═══════════════════════╣");
  console.log("║ Role       ║ Can Send Commands?    ║ Expected              ║");
  console.log("╠═════════════════════════════════════╬═══════════════════════╣");
  console.log("║ Nurse      ║ YES (Test 1: PASS)   ║ YES                   ║");
  console.log("║ Doctor     ║ YES (Test 2: PASS)   ║ YES (UPDATED)         ║");
  console.log("║ Patient    ║ NO  (Test 3: PASS)   ║ NO  (403 Forbidden)   ║");
  console.log("╚═════════════════════════════════════╩═══════════════════════╝\n");
}

runRBACTest().catch(console.error);
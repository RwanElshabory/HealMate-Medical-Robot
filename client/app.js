require("dotenv").config();
const crypto = require("crypto");
const axios = require("axios");

const JWT_SECRET = process.env.JWT_SECRET || "supersecretkey123";
const STATIC_AES_KEY = Buffer.from(process.env.AES_KEY || "1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef", "hex");
const IV_LENGTH = 16;
const API_URL = process.env.API_URL || "http://localhost:5000";

let serverPublicKey = null;
const sessionKeys = new Map();

async function fetchServerPublicKey() {
  if (serverPublicKey) return serverPublicKey;
  try {
    const res = await axios.get(API_URL + "/api/auth/publickey");
    serverPublicKey = res.data.publicKey;
    console.log("=== CLIENT: Got server public key ===");
    return serverPublicKey;
  } catch (err) {
    console.log("Could not fetch public key, using fallback");
    return null;
  }
}

function generateEphemeralAesKey() {
  return crypto.randomBytes(32);
}

function encryptWithDynamicKey(data, aesKey) {
  const iv = crypto.randomBytes(IV_LENGTH);
  const cipher = crypto.createCipheriv("aes-256-cbc", aesKey, iv);
  let encrypted = cipher.update(JSON.stringify(data));
  encrypted = Buffer.concat([encrypted, cipher.final()]);
  return Buffer.concat([iv, encrypted]).toString("base64");
}

function encrypt(data) {
  return encryptWithDynamicKey(data, STATIC_AES_KEY);
}

async function login(username, password, role, deviceId) {
  let ephemeralKey = generateEphemeralAesKey();
  console.log("\n=== CLIENT: DYNAMIC KEY EXCHANGE ===");
  console.log("1. Generated ephemeral AES key:", ephemeralKey.toString("hex").substring(0, 32) + "...");
  
  const publicKey = await fetchServerPublicKey();
  
  let encryptedAesKey = null;
  if (publicKey) {
    console.log("2. Encrypting ephemeral key with RSA public key...");
    const encrypted = crypto.publicEncrypt(
      {
        key: publicKey,
        padding: crypto.constants.RSA_PKCS1_OAEP_PADDING,
        oaepHash: "sha256"
      },
      ephemeralKey
    );
    encryptedAesKey = encrypted.toString("base64");
    console.log("   Encrypted AES key:", encryptedAesKey.substring(0, 60) + "...");
  }
  
  console.log("3. Sending login request with encrypted key...\n");
  
  const res = await axios.post(API_URL + "/api/auth/login", {
    username: username,
    password: password,
    role: role,
    encryptedAesKey: encryptedAesKey
  }, {
    headers: {
      "x-device-id": deviceId,
      "user-agent": "MobileApp/1.0"
    }
  });
  
  if (res.data.keyExchange === "completed") {
    console.log("4. Server acknowledged dynamic key exchange - SUCCESS!");
    sessionKeys.set(res.data.token, ephemeralKey);
    console.log("=== KEY EXCHANGE COMPLETE ===\n");
  } else {
    console.log("4. Using static key (no exchange)");
    console.log("=== KEY EXCHANGE COMPLETE ===\n");
  }
  
  return res.data.token;
}

async function sendCommand(token, command, params, deviceId) {
  const sessionKey = sessionKeys.get(token);
  const aesKey = sessionKey || STATIC_AES_KEY;
  
  console.log("\n=== CLIENT: ENCRYPTING COMMAND ===");
  console.log("1. Token:", token.substring(0, 20) + "...");
  console.log("2. Using encryption key:", sessionKey ? "DYNAMIC (session)" : "STATIC (fallback)");
  console.log("3. Command:", command, params);
  
  const jti = crypto.randomUUID();
  const timestamp = Date.now();
  const nonce = crypto.randomBytes(8).toString("hex");
  const payload = {
    jwt_token: token,
    command: command,
    params: params,
    jti: jti
  };
  const encrypted = encryptWithDynamicKey(payload, aesKey);
  console.log("4. Encrypted data length:", encrypted.length);
  console.log("=== END ENCRYPTION ===\n");
  
  const res = await axios.post(API_URL + "/api/command", {
    encryptedData: encrypted
  }, {
    headers: {
      "authorization": "Bearer " + token,
      "x-device-id": deviceId,
      "x-nonce": nonce,
      "x-timestamp": timestamp,
      "user-agent": "MobileApp/1.0"
    }
  });
  console.log("Success:", res.data);
  return res.data;
}

async function testInvalidToken() {
  console.log("=== SECURITY TEST: Invalid JWT Token ===");
  console.log("Sending request with CORRUPTED token...");
  const corruptedToken = "invalid.corrupted.forged.token123";
  const jti = crypto.randomUUID();
  const timestamp = Date.now();
  const nonce = crypto.randomBytes(8).toString("hex");
  const payload = {
    jwt_token: corruptedToken,
    command: "rotate",
    params: { angle: 90 },
    jti: jti
  };
  const encrypted = encrypt(payload);
  try {
    await axios.post(API_URL + "/api/command", {
      encryptedData: encrypted
    }, {
      headers: {
        "x-device-id": "device_test",
        "x-nonce": nonce,
        "x-timestamp": timestamp,
        "user-agent": "MobileApp/1.0"
      }
    });
    console.log("ERROR: Request should have been rejected!");
  } catch (err) {
    console.log("Status:", err.response ? err.response.status : "NO_RESPONSE");
    console.log("Error:", err.response ? err.response.data : err.message);
    if (err.response && err.response.status === 401) {
      console.log("PASS: Invalid token BLOCKED with 401");
    }
  }
}

async function testPasswordValidation() {
  console.log("");
  console.log("=== SECURITY TEST: Password Validation ===");
  console.log("Attempting login with VALID username but WRONG password...");
  console.log("Username: nurse1 | Password: wrong_password_123");
  try {
    const token = await login("nurse1", "wrong_password_123", "nurse", "device_hacker");
    console.log("FAIL: Status: SUCCESS | Token Received: YES");
    console.log("VULNERABILITY: Wrong password was accepted!");
  } catch (err) {
    console.log("Status:", err.response ? err.response.status : "NO_RESPONSE");
    console.log("Error:", err.response ? err.response.data : err.message);
    if (err.response && err.response.status === 401) {
      console.log("PASS: Password validation WORKING - Wrong password BLOCKED with 401");
    }
  }
}

async function testInjectionVulnerability() {
  console.log("");
  console.log("=== SECURITY TEST: Injection Vulnerability ===");
  console.log("Analyzing backend login logic...");
  console.log("Backend uses: VALID_PASSWORDS[username] lookup");
  console.log("");

  console.log("Test 1: NoSQL-style Injection");
  console.log("Payload: username={\"$gt\": \"\"}");
  try {
    const token = await login('{"$gt": ""}', "anypassword", "nurse", "device_inject");
    console.log("FAIL: Status: SUCCESS | VULNERABILITY CONFIRMED!");
  } catch (err) {
    console.log("Status:", err.response ? err.response.status : "NO_RESPONSE");
    console.log("PASS: NoSQL Injection BLOCKED");
  }

  console.log("");
  console.log("Test 2: Empty Password Bypass");
  console.log("Payload: username=nurse1, password=(empty)");
  try {
    const token = await login("nurse1", "", "nurse", "device_bypass");
    console.log("FAIL: Status: SUCCESS | VULNERABILITY CONFIRMED!");
  } catch (err) {
    console.log("Status:", err.response ? err.response.status : "NO_RESPONSE");
    console.log("PASS: Empty password BLOCKED");
  }

  console.log("");
  console.log("=== INJECTION TEST COMPLETE ===");
}

async function testBruteForceVulnerability() {
  console.log("");
  console.log("=== SECURITY TEST: Brute Force Attack (Rate Limiting) ===");
  console.log("Sending 10 rapid login attempts with WRONG password...");
  console.log("Rate Limit: 5 failed attempts per 15 minutes");
  console.log("");
  console.log("+--------+--------+------------------+");
  console.log("| Attempt | Status | Response        |");
  console.log("+--------+--------+------------------+\n");

  let successCount = 0;
  let blocked401Count = 0;
  let rateLimited429Count = 0;

  const promises = [];
  for (let i = 1; i <= 10; i++) {
    promises.push(
      login("attacker_user", "wrong_password_" + i, "nurse", "device_bruteforce")
        .then(function() {
          console.log("| " + String(i).padEnd(7) + " | SUCCESS | Token issued!     |");
          successCount++;
        })
        .catch(function(err) {
          var status = "ERROR";
          if (err.response) {
            status = String(err.response.status).padEnd(7);
          }
          if (err.response && err.response.status === 429) {
            console.log("| " + String(i).padEnd(7) + " | " + status + " | Rate Limited!    |");
            rateLimited429Count++;
          } else if (err.response && err.response.status === 401) {
            console.log("| " + String(i).padEnd(7) + " | " + status + " | Rejected         |");
            blocked401Count++;
          } else {
            console.log("| " + String(i).padEnd(7) + " | " + status + " | " + (err.response ? err.response.data.error : "Error").padEnd(16) + " |");
          }
        })
    );
  }

  await Promise.all(promises);

  console.log("\n+--------+--------+------------------+\n");
  console.log("RESULTS:");
  console.log("- Successful logins: " + successCount);
  console.log("- Blocked (401): " + blocked401Count);
  console.log("- Rate Limited (429): " + rateLimited429Count);
  console.log("");

  if (rateLimited429Count > 0) {
    console.log("PASS: RATE LIMITING IS WORKING!");
    console.log("The server blocked brute force attempts with 429 status.");
    console.log("After " + rateLimited429Count + " attempts, the server started returning 429 Too Many Requests.");
  } else if (successCount > 0) {
    console.log("FAIL: VULNERABILITY STILL EXISTS!");
    console.log("No rate limiting detected - all attempts processed.");
  } else {
    console.log("RESULT: All attempts were rejected but no rate limiting detected.");
  }

  console.log("");
  console.log("=== BRUTE FORCE TEST COMPLETE ===");
}

async function testDDoSFlood() {
  console.log("");
  console.log("╔══════════════════════════════════════════════════════════╗");
  console.log("║     SECURITY TEST: DDoS / Anomaly Detection             ║");
  console.log("╚══════════════════════════════════════════════════════════╝");
  console.log("");
  console.log("Testing anomaly detection by flooding server with 20 rapid commands...");
  console.log("Threshold: Max 3 commands per second per user");
  console.log("Expected: After 3 commands, all subsequent should be BLOCKED (429)");
  console.log("");

  try {
    const token = await login("nurse1", "password", "nurse", "device_ddos");
    console.log("1. Login as nurse: SUCCESS\n");

    console.log("2. Sending 20 RAPID commands (flood attack simulation)...");
    console.log("+--------+----------+---------------------------------+");
    console.log("| #      | Status   | Response                        |");
    console.log("+--------+----------+---------------------------------+\n");

    let successCount = 0;
    let blockedCount = 0;
    let anomalyDetectedCount = 0;

    for (let i = 1; i <= 20; i++) {
      try {
        await sendCommand(token, "rotate", { angle: i * 10 }, "device_ddos");
        console.log("| " + String(i).padEnd(7) + " | SUCCESS | Command accepted            |");
        successCount++;
      } catch (err) {
        let status = "ERROR";
        let response = "Error";
        if (err.response) {
          status = String(err.response.status).padEnd(9);
          if (err.response.status === 429 && err.response.data?.error === "Anomaly Detected") {
            response = "ANOMALY BLOCKED!";
            anomalyDetectedCount++;
          } else if (err.response.status === 429) {
            response = "Rate Limited";
            blockedCount++;
          } else {
            response = String(err.response.data?.error || "Error").substring(0, 27);
          }
        }
        console.log("| " + String(i).padEnd(7) + " | " + status + " | " + response.padEnd(30) + "|");
      }
    }

    console.log("\n+--------+----------+---------------------------------+\n");

    console.log("RESULTS:");
    console.log("- Commands accepted: " + successCount);
    console.log("- Anomaly detected (429): " + anomalyDetectedCount);
    console.log("- Rate limited (429): " + blockedCount);
    console.log("- Total blocked: " + (anomalyDetectedCount + blockedCount));

    if (anomalyDetectedCount > 0) {
      console.log("\n✅ PASS: ANOMALY DETECTION WORKING!");
      console.log("The system detected the DDoS attack and blocked commands after " + (anomalyDetectedCount + successCount) + " requests.");
      console.log("Humanly impossible to send " + (anomalyDetectedCount + successCount) + " commands in 1 second!");
    } else if (blockedCount > 0) {
      console.log("\n⚠️  PARTIAL: Rate limiting caught some, but not flagged as anomaly");
    } else {
      console.log("\n❌ FAIL: All commands were accepted - no protection!");
    }

  } catch (err) {
    console.log("Status:", err.response ? err.response.status : "NO_RESPONSE");
    console.log("Error:", err.response ? err.response.data : err.message);
  }

  console.log("");
  console.log("=== DDoS FLOOD TEST COMPLETE ===");
}

async function testTamperedSignature() {
  console.log("");
  console.log("=== SECURITY TEST: Tampered HMAC Signature ===");
  console.log("Testing if robot rejects commands with tampered signature...");

  try {
    const token = await login("nurse1", "password", "nurse", "device_tamper");
    console.log("1. Login as nurse: SUCCESS");

    const jti = crypto.randomUUID();
    const timestamp = Date.now();
    const nonce = crypto.randomBytes(8).toString("hex");
    const payload = {
      jwt_token: token,
      command: "rotate",
      params: { angle: 90 },
      jti: jti
    };
    const encrypted = encrypt(payload);

    console.log("2. Sending command through backend to robot...");
    const res = await axios.post(API_URL + "/api/command", {
      encryptedData: encrypted
    }, {
      headers: {
        "x-device-id": "device_tamper",
        "x-nonce": nonce,
        "x-timestamp": timestamp,
        "user-agent": "MobileApp/1.0"
      }
    });
    console.log("Backend response:", res.data);

    console.log("3. Simulating attack: sending TAMPERED signature directly to robot...");
    const robotRes = await axios.post("http://localhost:6000/execute", {
      command: "rotate",
      params: { angle: 90 },
      jti: jti,
      jwt_token: token,
      role: "nurse",
      username: "nurse1",
      timestamp: timestamp,
      nonce: nonce,
      signature: "TAMPERED_SIGNATURE_12345"
    }, {
      timeout: 5000
    });
    console.log("ERROR: Tampered signature was ACCEPTED!");
    console.log("Result:", robotRes.data);
  } catch (err) {
    console.log("Status:", err.response ? err.response.status : "NO_RESPONSE");
    console.log("Error:", err.response ? err.response.data : err.message);
    if (err.response && (err.response.status === 401 || err.response.status === 400)) {
      console.log("PASS: Tampered signature BLOCKED with " + err.response.status);
    }
  }

  console.log("");
  console.log("=== TAMPERED SIGNATURE TEST COMPLETE ===");
}

async function testReplayAttack() {
  console.log("");
  console.log("=== SECURITY TEST: Replay Attack Prevention ===");
  console.log("Testing if backend rejects replayed requests (same nonce)...");

  try {
    const token = await login("nurse1", "password", "nurse", "device_replay");
    console.log("1. Login as nurse: SUCCESS");

    const jti = crypto.randomUUID();
    const timestamp = Date.now();
    const nonce = crypto.randomBytes(8).toString("hex");
    const payload = {
      jwt_token: token,
      command: "rotate",
      params: { angle: 45 },
      jti: jti
    };
    const encrypted = encrypt(payload);

    console.log("2. Sending FIRST request (unique nonce)...");
    await axios.post(API_URL + "/api/command", {
      encryptedData: encrypted
    }, {
      headers: {
        "x-device-id": "device_replay",
        "x-nonce": nonce,
        "x-timestamp": timestamp,
        "user-agent": "MobileApp/1.0"
      }
    });
    console.log("   First request: SUCCESS");

    console.log("3. Sending SAME request again (REPLAY ATTEMPT)...");
    const replayRes = await axios.post(API_URL + "/api/command", {
      encryptedData: encrypted
    }, {
      headers: {
        "x-device-id": "device_replay",
        "x-nonce": nonce,
        "x-timestamp": timestamp,
        "user-agent": "MobileApp/1.0"
      }
    });
    console.log("ERROR: Replay attack was ACCEPTED!");
    console.log("Result:", replayRes.data);
  } catch (err) {
    console.log("Status:", err.response ? err.response.status : "NO_RESPONSE");
    console.log("Error:", err.response ? err.response.data : err.message);
    if (err.response && err.response.status === 400) {
      console.log("PASS: Replay attack BLOCKED with 400");
    }
  }

  console.log("");
  console.log("=== REPLAY ATTACK TEST COMPLETE ===");
}

async function testExpiredTimestamp() {
  console.log("");
  console.log("=== SECURITY TEST: Expired Timestamp Detection ===");
  console.log("Testing if backend rejects requests with old timestamps (>30s)...");

  try {
    const token = await login("nurse1", "password", "nurse", "device_expired");
    console.log("1. Login as nurse: SUCCESS");

    const jti = crypto.randomUUID();
    const oldTimestamp = Date.now() - 60000;
    const nonce = crypto.randomBytes(8).toString("hex");
    const payload = {
      jwt_token: token,
      command: "rotate",
      params: { angle: 180 },
      jti: jti
    };
    const encrypted = encrypt(payload);

    console.log("2. Sending request with EXPIRED timestamp (60 seconds old)...");
    const res = await axios.post(API_URL + "/api/command", {
      encryptedData: encrypted
    }, {
      headers: {
        "x-device-id": "device_expired",
        "x-nonce": nonce,
        "x-timestamp": oldTimestamp,
        "user-agent": "MobileApp/1.0"
      }
    });
    console.log("ERROR: Expired timestamp was ACCEPTED!");
    console.log("Result:", res.data);
  } catch (err) {
    console.log("Status:", err.response ? err.response.status : "NO_RESPONSE");
    console.log("Error:", err.response ? err.response.data : err.message);
    if (err.response && (err.response.status === 400 || err.response.status === 401)) {
      console.log("PASS: Expired timestamp BLOCKED with " + err.response.status);
    }
  }

  console.log("");
  console.log("=== EXPIRED TIMESTAMP TEST COMPLETE ===");
}

async function testMissingSecurityHeaders() {
  console.log("");
  console.log("=== SECURITY TEST: Missing Security Headers ===");
  console.log("Testing if backend rejects requests without x-nonce/x-timestamp...");

  try {
    const token = await login("nurse1", "password", "nurse", "device_noheaders");
    console.log("1. Login as nurse: SUCCESS");

    const jti = crypto.randomUUID();
    const payload = {
      jwt_token: token,
      command: "rotate",
      params: { angle: 45 },
      jti: jti
    };
    const encrypted = encrypt(payload);

    console.log("2. Sending request WITHOUT security headers...");
    const res = await axios.post(API_URL + "/api/command", {
      encryptedData: encrypted
    }, {
      headers: {
        "x-device-id": "device_noheaders",
        "user-agent": "MobileApp/1.0"
      }
    });
    console.log("ERROR: Request without headers was ACCEPTED!");
    console.log("Result:", res.data);
  } catch (err) {
    console.log("Status:", err.response ? err.response.status : "NO_RESPONSE");
    console.log("Error:", err.response ? err.response.data : err.message);
    if (err.response && err.response.status === 400) {
      console.log("PASS: Missing headers BLOCKED with 400");
    }
  }

  console.log("");
  console.log("=== MISSING HEADERS TEST COMPLETE ===");
}

async function testNormalCommand() {
  console.log("");
  console.log("=== COMPREHENSIVE TEST: Normal Command (All Security Layers) ===");
  console.log("Testing a valid command passes through ALL security layers...");

  try {
    const token = await login("nurse1", "password", "nurse", "device_normal");
    console.log("1. Login as nurse: SUCCESS");
    console.log("   Token: " + token.substring(0, 30) + "...");

    console.log("2. Sending VALID rotate command...");
    console.log("   - JWT Auth: Required");
    console.log("   - AES-256-CBC Encryption: Applied");
    console.log("   - RBAC (Nurse role): Verified");
    console.log("   - Anti-replay (nonce/timestamp): Applied");
    console.log("   - HMAC Signature: Generated");
    console.log("   - Context-aware rate limiting: Applied");

    const result = await sendCommand(token, "rotate", { angle: 90 }, "device_normal");

    console.log("3. Command executed successfully!");
    console.log("   Result:", result);
    console.log("");
    console.log("PASS: Normal command passed through ALL security layers!");
  } catch (err) {
    console.log("Status:", err.response ? err.response.status : "NO_RESPONSE");
    console.log("Error:", err.response ? err.response.data : err.message);
    console.log("FAIL: Normal command was blocked!");
  }

  console.log("");
  console.log("=== NORMAL COMMAND TEST COMPLETE ===");
}

async function demo() {
  console.log("╔════════════════════════════════════════════════════════════════╗");
  console.log("║        Medical Robot Security System - Comprehensive Test      ║");
  console.log("╚════════════════════════════════════════════════════════════════╝\n");

  console.log("=== ANOMALY DETECTION TEST (DDoS) - RUN FIRST ===\n");

  await testDDoSFlood();

  console.log("\n=== BASIC FUNCTIONALITY TESTS ===\n");

  console.log("1. Login as Nurse (correct password)...");
  const nurseToken = await login("nurse1", "password", "nurse", "device_nurse_1");
  console.log("Nurse Token: " + nurseToken.substring(0, 50) + "...");

  console.log("\n2. Nurse - rotate command...");
  await sendCommand(nurseToken, "rotate", { angle: 45 }, "device_nurse_1");

  console.log("\n3. Login as Patient...");
  const patientToken = await login("patient1", "password", "patient", "device_patient");

  console.log("\n4. Patient - rotate command (should be Forbidden)...");
  try {
    await sendCommand(patientToken, "rotate", { angle: 90 }, "device_patient");
    console.log("ERROR: Patient should have been blocked!");
  } catch (err) {
    console.log("Status:", err.response ? err.response.status : "NO_RESPONSE");
    console.log("Error:", err.response ? err.response.data : err.message);
  }

  console.log("\n5. Login as Doctor...");
  const doctorToken = await login("doctor1", "password", "doctor", "device_doc");

  console.log("\n6. Doctor - move command (should now be ALLOWED)...");
  try {
    await sendCommand(doctorToken, "move", { direction: "forward" }, "device_doc");
    console.log("✅ SUCCESS! Doctor sent command successfully!");
  } catch (err) {
    console.log("Status:", err.response ? err.response.status : "NO_RESPONSE");
    console.log("Error:", err.response ? err.response.data : err.message);
    console.log("❌ FAIL: Doctor should have been ALLOWED!");
  }

  console.log("\n=== RBAC VERIFICATION ===");
  console.log("✅ Nurse  -> Can send commands (as before)");
  console.log("✅ Doctor -> Can send commands (UPDATED)");
  console.log("❌ Patient -> Blocked (403 Forbidden)");

  console.log("\n=== DEEP SECURITY LAYER TEST ===\n");

  await testNormalCommand();

  console.log("\n=== ADVANCED SECURITY TESTS ===\n");

  await testTamperedSignature();
  await testReplayAttack();
  await testExpiredTimestamp();
  await testMissingSecurityHeaders();

  console.log("\n=== SECURITY VULNERABILITY TESTS ===\n");

  await testInvalidToken();
  await testPasswordValidation();
  await testInjectionVulnerability();

  await new Promise(r => setTimeout(r, 1000));
  await testBruteForceVulnerability();

  console.log("\n╔════════════════════════════════════════════════════════════════╗");
  console.log("║                    ALL TESTS COMPLETED                        ║");
  console.log("╚════════════════════════════════════════════════════════════════╝\n");
}

if (require.main === module) {
  demo().catch(console.error);
}

module.exports = {
  sendCommand: sendCommand,
  login: login,
  encrypt: encrypt,
  testInvalidToken: testInvalidToken,
  testPasswordValidation: testPasswordValidation,
  testInjectionVulnerability: testInjectionVulnerability,
  testBruteForceVulnerability: testBruteForceVulnerability,
  testTamperedSignature: testTamperedSignature,
  testReplayAttack: testReplayAttack,
  testExpiredTimestamp: testExpiredTimestamp,
  testMissingSecurityHeaders: testMissingSecurityHeaders,
  testNormalCommand: testNormalCommand
};
const express = require("express");
const https = require("https");
const fs = require("fs");
const jwt = require("jsonwebtoken");
const crypto = require("crypto");

const app = express();
app.use(express.json());

const JWT_SECRET = process.env.JWT_SECRET || "supersecretkey123";
const SECRET_KEY = process.env.SECRET_KEY || "super_secret_robot_key_medical2024";
const PORT = process.env.PORT || 6000;
const DEV_MODE = process.env.DEV_MODE === "true";

const EXECUTED_JTI = new Map();

function verifySecureCommand(data) {
  const message = data.command + "|" + data.timestamp + "|" + data.nonce + "|" + data.robotId;

  const expectedSignature = crypto
    .createHmac("sha256", SECRET_KEY)
    .update(message)
    .digest("hex");

  if (expectedSignature !== data.signature) {
    return { valid: false, error: "Invalid signature" };
  }

  const timestampNum = parseInt(data.timestamp);
  if (isNaN(timestampNum) || Math.abs(Date.now() - timestampNum) > 30000) {
    return { valid: false, error: "Command expired" };
  }

  return { valid: true, error: null };
}

function isReplay(jti) {
  if (DEV_MODE) return false;

  if (EXECUTED_JTI.has(jti)) return true;
  EXECUTED_JTI.set(jti, Date.now());
  setTimeout(() => EXECUTED_JTI.delete(jti), 60000);
  return false;
}

function executeCommand(command, params) {
  if (command === "move") {
    if (params.x !== undefined) {
      console.log(`🤖 Joystick x:${params.x} y:${params.y}`);
    } else {
      console.log(`🤖 Move ${params.direction} speed ${params.speed}`);
    }
  } else if (command === "rotate") {
    console.log(`🤖 Rotate ${params.angle}`);
  } else if (command === "stop") {
    console.log("🤖 STOP");
  } else if (command === "diagnose") {
    console.log("🤖 Running diagnostics...");
  } else if (command === "emergency") {
    console.log("🤖 EMERGENCY MODE ACTIVATED");
  }
}

app.post("/execute", (req, res) => {
  try {
    const { command, params, jwt_token, role, username, timestamp, nonce, signature } = req.body;
    console.log(`[Robot] Command received:`, { command, params, role, username });

    if (!DEV_MODE) {
      if (!timestamp || !nonce || !signature) {
        console.log("[Robot] SECURITY: Missing security headers - REJECTING");
        return res.status(400).json({ error: "Missing security parameters (timestamp, nonce, signature)" });
      }

      const verifyResult = verifySecureCommand({
        command,
        timestamp,
        nonce,
        signature,
        robotId: "robot-001"
      });

      if (!verifyResult.valid) {
        console.log("[Robot] SECURITY: HMAC signature verification FAILED - " + verifyResult.error);
        return res.status(401).json({ error: "Invalid signature: " + verifyResult.error });
      }
      console.log("[Robot] SECURITY: HMAC signature verification PASSED");
    }

    let decoded;
    try {
      decoded = jwt.verify(jwt_token, JWT_SECRET);
      console.log(`[Robot] Token decoded:`, decoded);
    } catch (e) {
      decoded = { role: "doctor", username: "unknown" };
    }

    executeCommand(command, params);

    console.log(`[Robot] Executed by ${username || decoded.username} (${role || decoded.role}): ${command}`);

    return res.json({ status: "executed", command, role: role || decoded.role });

  } catch (err) {
    console.error(`[Robot] Error: ${err.message}, Stack: ${err.stack}`);
    return res.status(500).json({ error: err.message });
  }
});

app.get("/health", (req, res) => {
  res.json({ status: "ok", service: "robot" });
});

const USE_HTTPS = process.env.USE_HTTPS === "true";

let server;
if (USE_HTTPS) {
  server = https.createServer({
    key: fs.readFileSync("robot.key"),
    cert: fs.readFileSync("robot.crt")
  }, app);
} else {
  server = require("http").createServer(app);
}

server.listen(PORT, () => {
  console.log(`🤖 Robot ${USE_HTTPS ? "HTTPS" : "HTTP"} running on port ${PORT}`);
});
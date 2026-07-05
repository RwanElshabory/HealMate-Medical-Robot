require("dotenv").config();
const express = require("express");
const https = require("https");
const fs = require("fs");
const jwt = require("jsonwebtoken");
const crypto = require("crypto");
const axios = require("axios");
const cors = require("cors");
const security = require("./security");

const app = express();
app.use(express.json());
app.use(cors());

const PORT = 5000;
const ROBOT_PORT = 6000;

const JWT_SECRET = process.env.JWT_SECRET || "supersecretkey123";
const STATIC_AES_KEY = Buffer.from(process.env.AES_KEY || "1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef", "hex");
const AES_IV = process.env.AES_IV || "1234567890123456";
const IV_LENGTH = 16;

const sessionKeys = new Map();

const MOCK_DATABASE = {
  patients: [
    { id: 1, name: "John Doe", age: 45, doctorId: 1, data: "Confidential medical data for patient 1" },
    { id: 2, name: "Jane Smith", age: 32, doctorId: 1, data: "Confidential medical data for patient 2" },
    { id: 3, name: "Bob Johnson", age: 58, doctorId: 2, data: "Confidential medical data for patient 3" }
  ],
  reports: [
    { id: 1, patientId: 1, doctorId: 1, title: "Blood Test Report", content: "Report content 1" },
    { id: 2, patientId: 2, doctorId: 1, title: "X-Ray Report", content: "Report content 2" },
    { id: 3, patientId: 3, doctorId: 2, title: "MRI Report", content: "Report content 3" }
  ]
};

console.log("=== DYNAMIC KEY EXCHANGE SETUP ===");
let RSA_PUBLIC_KEY, RSA_PRIVATE_KEY;
try {
  RSA_PUBLIC_KEY = fs.readFileSync("rsa_public.pem", "utf8");
  RSA_PRIVATE_KEY = fs.readFileSync("rsa_private.pem", "utf8");
  console.log("Loaded existing RSA key pair");
} catch (e) {
  console.log("Generating new RSA key pair...");
  const { publicKey, privateKey } = crypto.generateKeyPairSync("rsa", {
    modulusLength: 2048,
    publicKeyEncoding: { type: "spki", format: "pem" },
    privateKeyEncoding: { type: "pkcs8", format: "pem" }
  });
  RSA_PUBLIC_KEY = publicKey;
  RSA_PRIVATE_KEY = privateKey;
  fs.writeFileSync("rsa_public.pem", publicKey);
  fs.writeFileSync("rsa_private.pem", privateKey);
  console.log("RSA key pair generated and saved");
}
console.log("=== END KEY EXCHANGE SETUP ===\n");

function getSessionKey(token) {
  return sessionKeys.get(token);
}

function setSessionKey(token, aesKey) {
  sessionKeys.set(token, aesKey);
}

const HOSPITAL_IP_RANGES = ["127.0.0.1", "::1", "192.168.1.", "10.0.0."];

const usedJTI = new Map();

const VALID_PASSWORDS = {
  nurse1: "password",
  doctor1: "password",
  patient1: "password"
};

const rateLimitMap = new Map();
const RATE_LIMIT_MAX = 5;
const RATE_LIMIT_WINDOW_MS = 15 * 60 * 1000;

function checkRateLimit(ip, username) {
  const key = ip + ":" + username;
  const now = Date.now();
  
  if (!rateLimitMap.has(key)) {
    rateLimitMap.set(key, { count: 0, firstAttempt: now, resetAt: now + RATE_LIMIT_WINDOW_MS });
  }
  
  const record = rateLimitMap.get(key);
  
  if (now > record.resetAt) {
    record.count = 0;
    record.firstAttempt = now;
    record.resetAt = now + RATE_LIMIT_WINDOW_MS;
  }
  
  record.count++;
  rateLimitMap.set(key, record);
  
  if (record.count > RATE_LIMIT_MAX) {
    const remainingTime = Math.ceil((record.resetAt - now) / 1000);
    return { blocked: true, remainingTime: remainingTime };
  }
  
  return { blocked: false, remainingAttempts: RATE_LIMIT_MAX - record.count };
}

function isReplay(jti) {
  if (usedJTI.has(jti)) return true;
  usedJTI.set(jti, Date.now());
  setTimeout(() => {
    usedJTI.delete(jti);
  }, 60000);
  return false;
}

function decrypt(data, sessionKey = null) {
  const aesKey = sessionKey || STATIC_AES_KEY;
  const buffer = Buffer.from(data, "base64");
  const iv = buffer.slice(0, IV_LENGTH);
  const encrypted = buffer.slice(IV_LENGTH);
  const decipher = crypto.createDecipheriv("aes-256-cbc", aesKey, iv);
  let decrypted = decipher.update(encrypted);
  decrypted = Buffer.concat([decrypted, decipher.final()]);
  return JSON.parse(decrypted.toString());
}

function decryptWithSessionKey(data, token) {
  const sessionKey = sessionKeys.get(token);
  if (!sessionKey) {
    console.log("[DECRYPT] No session key found, using static key");
    return decrypt(data, null);
  }
  console.log("[DECRYPT] Using dynamic session key for decryption");
  return decrypt(data, sessionKey);
}

function isHospitalIP(ip) {
  if (!ip) return false;
  return HOSPITAL_IP_RANGES.some(range => ip.startsWith(range));
}

function checkRoleAccess(req, decoded) {
  const role = decoded.role;
  const ip = req.ip || req.connection.remoteAddress;
  const userAgent = req.headers["user-agent"] || "";
  const isMobile = /mobile|android|iphone/i.test(userAgent);
  const isHospital = isHospitalIP(ip);

  if (role === "doctor") return true;
  if (role === "nurse") return isHospital;
  if (role === "patient") return isMobile && !isHospital;
  return false;
}

app.post("/api/auth/login", (req, res) => {
  try {
    const { username, password, role, encryptedAesKey } = req.body;
    const clientIP = req.ip || req.connection.remoteAddress;
    
    if (!username || !password || !role) {
      return res.status(400).json({ error: "Missing fields" });
    }
    if (!["doctor", "nurse", "patient"].includes(role)) {
      return res.status(400).json({ error: "Invalid role" });
    }

    const rateLimitResult = checkRateLimit(clientIP, username);
    
    if (rateLimitResult.blocked) {
      res.set("Retry-After", rateLimitResult.remainingTime);
      return res.status(429).json({ 
        error: "Too Many Requests",
        message: "Rate limit exceeded. Try again in " + rateLimitResult.remainingTime + " seconds.",
        remainingAttempts: 0
      });
    }

    const correctPassword = VALID_PASSWORDS[username];
    if (!correctPassword) {
      return res.status(401).json({ error: "Invalid credentials" });
    }
    if (password !== correctPassword) {
      return res.status(401).json({ 
        error: "Invalid credentials",
        remainingAttempts: rateLimitResult.remainingAttempts
      });
    }

    const payload = {
      username,
      role,
      patientId: role === "patient" ? 1 : null,
      doctorId: role === "doctor" || role === "nurse" ? 1 : null,
      deviceId: req.headers["x-device-id"] || "unknown",
      iat: Math.floor(Date.now() / 1000),
      exp: Math.floor(Date.now() / 1000) + 3600
    };

    const token = jwt.sign(payload, JWT_SECRET);

    let sessionKeySet = false;
    if (encryptedAesKey) {
      try {
        console.log("\n=== DYNAMIC KEY EXCHANGE (LOGIN) ===");
        console.log("1. Received encrypted AES key from client");
        console.log("   Encrypted key (base64):", encryptedAesKey.substring(0, 60) + "...");
        
        const encryptedBuffer = Buffer.from(encryptedAesKey, "base64");
        
        console.log("2. Decrypting AES key with RSA private key...");
        const decryptedAesKey = crypto.privateDecrypt(
          {
            key: RSA_PRIVATE_KEY,
            padding: crypto.constants.RSA_PKCS1_OAEP_PADDING,
            oaepHash: "sha256"
          },
          encryptedBuffer
        );
        
        const sessionAesKey = Buffer.from(decryptedAesKey);
        console.log("   AES key decrypted successfully!");
        console.log("   Session AES key (hex):", sessionAesKey.toString("hex").substring(0, 32) + "...");
        
        sessionKeys.set(token, sessionAesKey);
        sessionKeySet = true;
        console.log("3. Session key stored for token:", token.substring(0, 20) + "...");
        console.log("=== KEY EXCHANGE COMPLETE ===\n");
      } catch (keyErr) {
        console.error("Failed to decrypt session key:", keyErr.message);
        return res.status(400).json({ error: "Invalid encrypted key" });
      }
    }

    return res.json({ 
      token, 
      role: payload.role,
      keyExchange: sessionKeySet ? "completed" : "using_static"
    });
  } catch (err) {
    return res.status(500).json({ error: err.message });
  }
});

app.post("/api/command", security.antiReplay, security.contextAware, security.commandRateLimiter, async (req, res) => {
  try {
    const authHeader = req.headers["authorization"];
    const token = authHeader ? authHeader.replace("Bearer ", "") : null;
    
    const { encryptedData } = req.body;
    if (!encryptedData) {
      return res.status(400).json({ error: "Missing encrypted data" });
    }

    const payload = decryptWithSessionKey(encryptedData, token);
    console.log("\n=== COMMAND DECRYPTION ===");
    console.log("1. Encrypted data length:", encryptedData.length);
    console.log("2. Session key used:", sessionKeys.has(token) ? "DYNAMIC" : "STATIC (fallback)");
    console.log("3. Decrypted payload:", JSON.stringify(payload).substring(0, 50) + "...");
    console.log("=== END DECRYPTION ===\n");
    
    const { jwt_token, command, params, jti } = payload;

    if (!jwt_token || !command || !jti) {
      return res.status(400).json({ error: "Missing required fields" });
    }

    const decoded = jwt.verify(jwt_token, JWT_SECRET);
    if (decoded.role !== 'nurse' && decoded.role !== 'doctor') {
      return res.status(403).json({ error: 'Forbidden - Only nurse and doctor roles can send commands' });
    }

    console.log(`[RBAC] ${decoded.role} role authorized to send command`);

    if (isReplay(jti)) {
      return res.status(403).json({ error: "Replay attack detected" });
    }

    const secureCmd = security.generateSecureCommand(command, "robot-001", params);

    const robotResponse = await axios.post(ROBOT_URL + "/execute", {
      command,
      params,
      jti,
      jwt_token: jwt_token,
      role: decoded.role,
      username: decoded.username,
      timestamp: secureCmd.timestamp,
      nonce: secureCmd.nonce,
      signature: secureCmd.signature
    }, {
      httpsAgent: robotAgent,
      timeout: 10000
    });

    return res.json({ status: "success", robot: robotResponse.data });
  } catch (err) {
    if (err.name === "JsonWebTokenError" || err.name === "TokenExpiredError") {
      return res.status(401).json({ error: "Invalid or expired token" });
    }
    if (err.name === "SyntaxError") {
      return res.status(400).json({ error: "Invalid token format" });
    }
    return res.status(500).json({ error: err.message });
  }
});

app.get("/api/auth/publickey", (req, res) => {
  res.json({ publicKey: RSA_PUBLIC_KEY });
});

app.get("/health", (req, res) => {
  res.json({ status: "ok", service: "backend" });
});

const requireRole = (...allowedRoles) => {
  return (req, res, next) => {
    const authHeader = req.headers["authorization"];
    if (!authHeader) {
      return res.status(401).json({ error: "No token provided" });
    }
    
    const token = authHeader.replace("Bearer ", "");
    try {
      const decoded = jwt.verify(token, JWT_SECRET);
      req.user = decoded;
      
      if (!allowedRoles.includes(decoded.role)) {
        return res.status(403).json({ 
          error: "Forbidden",
          message: `Role '${decoded.role}' not authorized. Required roles: ${allowedRoles.join(", ")}`
        });
      }
      
      next();
    } catch (err) {
      return res.status(401).json({ error: "Invalid token" });
    }
  };
};

const chatParticipants = {
  doctor: ["nurse", "patient"],
  nurse: ["doctor", "patient"],
  patient: ["doctor", "nurse"]
};

app.get("/api/data/patients", requireRole("doctor", "nurse", "patient"), (req, res) => {
  const user = req.user;
  
  if (user.role === "patient") {
    const patientData = MOCK_DATABASE.patients.filter(p => p.id === user.patientId);
    if (patientData.length === 0) {
      return res.status(404).json({ error: "Patient data not found" });
    }
    return res.json({ 
      message: "Viewing own data only", 
      access: "READ_ONLY",
      patients: patientData 
    });
  }
  
  if (user.role === "doctor" || user.role === "nurse") {
    const doctorPatients = MOCK_DATABASE.patients.filter(p => p.doctorId === user.doctorId || p.id === user.patientId);
    return res.json({ 
      message: user.role === "doctor" ? "Full access to assigned patients" : "View assigned patients",
      access: user.role === "doctor" ? "FULL" : "PARTIAL",
      patients: doctorPatients 
    });
  }
});

app.post("/api/data/reports", requireRole("doctor", "nurse"), (req, res) => {
  if (req.user.role === "patient") {
    return res.status(403).json({ error: "Patients cannot create reports" });
  }
  
  const newReport = {
    id: MOCK_DATABASE.reports.length + 1,
    patientId: req.body.patientId,
    doctorId: req.user.doctorId || 1,
    title: req.body.title,
    content: req.body.content || "Report content"
  };
  MOCK_DATABASE.reports.push(newReport);
  
  return res.json({ message: "Report created successfully", report: newReport });
});

app.put("/api/data/reports/:id", requireRole("doctor", "nurse"), (req, res) => {
  if (req.user.role === "patient") {
    return res.status(403).json({ error: "Patients cannot modify reports" });
  }
  
  const report = MOCK_DATABASE.reports.find(r => r.id === parseInt(req.params.id));
  if (!report) {
    return res.status(404).json({ error: "Report not found" });
  }
  
  report.title = req.body.title || report.title;
  report.content = req.body.content || report.content;
  
  return res.json({ message: "Report updated successfully", report: report });
});

app.delete("/api/data/reports/:id", requireRole("doctor"), (req, res) => {
  const role = req.user.role;
  
  if (role !== "doctor") {
    return res.status(403).json({ 
      error: "Forbidden",
      message: `Role '${role}' cannot delete reports. Only doctors have delete permission.`
    });
  }
  
  const index = MOCK_DATABASE.reports.findIndex(r => r.id === parseInt(req.params.id));
  if (index === -1) {
    return res.status(404).json({ error: "Report not found" });
  }
  
  MOCK_DATABASE.reports.splice(index, 1);
  
  return res.json({ message: "Report deleted successfully" });
});

app.post("/api/chat/send", requireRole("doctor", "nurse", "patient"), (req, res) => {
  const sender = req.user;
  const { receiverRole, message } = req.body;
  
  if (!chatParticipants[sender.role].includes(receiverRole)) {
    return res.status(403).json({
      error: "Forbidden",
      message: `${sender.role} cannot chat with ${receiverRole}`
    });
  }
  
  const chatMessage = {
    id: Date.now(),
    from: sender.username,
    fromRole: sender.role,
    toRole: receiverRole,
    message: message,
    timestamp: new Date().toISOString()
  };
  
  console.log(`[CHAT] ${sender.role} '${sender.username}' -> ${receiverRole}: ${message}`);
  
  return res.json({ 
    message: "Message sent successfully",
    chat: chatMessage 
  });
});

app.get("/api/chat/history", requireRole("doctor", "nurse", "patient"), (req, res) => {
  const user = req.user;
  const { withRole } = req.query;
  
  if (withRole && !chatParticipants[user.role].includes(withRole)) {
    return res.status(403).json({
      error: "Forbidden",
      message: `${user.role} cannot chat with ${withRole}`
    });
  }
  
  return res.json({
    message: "Chat history retrieved",
    userRole: user.role,
    allowedChatWith: chatParticipants[user.role]
  });
});

console.log("\n=== RBAC ENDPOINTS LOADED ===");
console.log("Data Endpoints:");
console.log("  GET  /api/data/patients    - View patients (per role)");
console.log("  POST /api/data/reports     - Create reports (doctor/nurse)");
console.log("  PUT  /api/data/reports/:id - Update reports (doctor/nurse)");
console.log("  DELETE /api/data/reports/:id - Delete reports (doctor ONLY)");
console.log("Chat Endpoints:");
console.log("  POST /api/chat/send    - Send message (per role)");
console.log("  GET  /api/chat/history - Get history (per role)");
console.log("=============================\n");

const USE_HTTPS = process.env.USE_HTTPS === "true";
const ROBOT_URL = USE_HTTPS ? "https://localhost:" + ROBOT_PORT : "http://localhost:" + ROBOT_PORT;

let robotAgent;
if (USE_HTTPS) {
  robotAgent = new https.Agent({ rejectUnauthorized: false });
}

let server;
if (USE_HTTPS) {
  server = https.createServer({
    key: fs.readFileSync("backend.key"),
    cert: fs.readFileSync("backend.crt")
  }, app);
} else {
  server = require("http").createServer(app);
}

server.listen(PORT, function() {
  console.log((USE_HTTPS ? "HTTPS" : "HTTP") + " Backend running on port " + PORT);
  console.log("Robot URL: " + ROBOT_URL);
});
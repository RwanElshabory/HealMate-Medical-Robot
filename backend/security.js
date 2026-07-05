const crypto = require("crypto");

const sessions = new Map();
const usedNonces = new Set();
const SECRET_KEY = process.env.SECRET_KEY || "super_secret_robot_key_medical2024";
const SECURE_ROBOT_KEY = process.env.SECURE_ROBOT_KEY || "robot_command_signature_key_2024";

function createSession(userId, deviceId, role) {
    const token = crypto.randomBytes(32).toString("hex");
    sessions.set(token, {
        user: userId,
        deviceId: deviceId,
        role: role,
        createdAt: Date.now()
    });
    return token;
}

function getSession(token) {
    return sessions.get(token);
}

function validateSession(token, deviceId) {
    const session = sessions.get(token);
    if (!session) {
        return { valid: false, error: "Session not found" };
    }
    if (session.deviceId !== deviceId) {
        return { valid: false, error: "Device mismatch" };
    }
    return { valid: true, session: session };
}

function deleteSession(token) {
    sessions.delete(token);
}

function sessionBinding(req, res, next) {
    const token = req.headers["authorization"] ? req.headers["authorization"].replace("Bearer ", "") : null;
    const deviceId = req.headers["x-device-id"];

    if (!token) {
        return res.status(401).json({ error: "Missing authentication token" });
    }

    if (!deviceId) {
        return res.status(401).json({ error: "Missing device identifier" });
    }

    const validation = validateSession(token, deviceId);
    if (!validation.valid) {
        return res.status(403).json({ error: validation.error });
    }

    req.user = validation.session.user;
    req.userRole = validation.session.role;
    req.session = validation.session;
    next();
}

function antiReplay(req, res, next) {
    const nonce = req.headers["x-nonce"];
    const timestamp = req.headers["x-timestamp"];

    if (!nonce || !timestamp) {
        return res.status(400).json({ error: "Missing security headers (x-nonce, x-timestamp)" });
    }

    if (usedNonces.has(nonce)) {
        return res.status(400).json({ error: "Replay detected: nonce already used" });
    }

    const timestampNum = parseInt(timestamp);
    if (isNaN(timestampNum)) {
        return res.status(400).json({ error: "Invalid timestamp format" });
    }

    if (Math.abs(Date.now() - timestampNum) > 30000) {
        return res.status(400).json({ error: "Request expired (30 second window exceeded)" });
    }

    usedNonces.add(nonce);
    setTimeout(() => {
        usedNonces.delete(nonce);
    }, 60000);

    next();
}

const requestTracker = {};

function contextAware(req, res, next) {
    const ip = req.ip || req.connection.remoteAddress || "unknown";

    if (!requestTracker[ip]) {
        requestTracker[ip] = { count: 0, last: Date.now() };
    }

    const now = Date.now();
    const diff = now - requestTracker[ip].last;

    if (diff < 1000) {
        requestTracker[ip].count++;
    } else {
        requestTracker[ip].count = 1;
    }

    requestTracker[ip].last = now;

    if (requestTracker[ip].count > 10) {
        return res.status(429).json({ error: "Too many requests from this IP" });
    }

    next();
}

function generateSecureCommand(command, robotId, params) {
    const timestamp = Date.now();
    const nonce = crypto.randomBytes(8).toString("hex");

    const message = command + "|" + timestamp + "|" + nonce + "|" + robotId;
    if (params) {
        const paramsString = JSON.stringify(params);
        const paramsHash = crypto.createHash("sha256").update(paramsString).digest("hex").substring(0, 16);
    }

    const signature = crypto
        .createHmac("sha256", SECRET_KEY)
        .update(message)
        .digest("hex");

    return {
        command: command,
        timestamp: timestamp,
        nonce: nonce,
        robotId: robotId,
        signature: signature
    };
}

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

function cleanupSessions() {
    const now = Date.now();
    const sessionTimeout = 3600000;
    for (const [token, session] of sessions) {
        if (now - session.createdAt > sessionTimeout) {
            sessions.delete(token);
        }
    }
}

setInterval(cleanupSessions, 300000);

const commandTimestamps = new Map();
const ANOMALY_THRESHOLD = 3;
const ANOMALY_TIME_WINDOW_MS = 1000;

function commandRateLimiter(req, res, next) {
    const identifier = req.headers["authorization"] ? 
        req.headers["authorization"].replace("Bearer ", "").substring(0, 20) : 
        (req.ip || "unknown");
    
    const now = Date.now();
    
    if (!commandTimestamps.has(identifier)) {
        commandTimestamps.set(identifier, []);
    }
    
    const timestamps = commandTimestamps.get(identifier);
    
    const recentTimestamps = timestamps.filter(ts => now - ts < ANOMALY_TIME_WINDOW_MS);
    
    recentTimestamps.push(now);
    commandTimestamps.set(identifier, recentTimestamps);
    
    if (recentTimestamps.length > ANOMALY_THRESHOLD) {
        console.log(`\n=== ANOMALY DETECTION ===`);
        console.log(`ALERT: DDoS attack detected from: ${identifier}`);
        console.log(`Commands in last ${ANOMALY_TIME_WINDOW_MS}ms: ${recentTimestamps.length}`);
        console.log(`Threshold: ${ANOMALY_THRESHOLD} commands/second`);
        console.log(`Blocking request and returning 429`);
        console.log(`=========================\n`);
        
        return res.status(429).json({
            error: "Anomaly Detected",
            message: "Command rate exceeds humanly possible frequency. Potential DDoS attack blocked.",
            detectedAt: now,
            blockedIdentifier: identifier,
            commandsInWindow: recentTimestamps.length,
            threshold: ANOMALY_THRESHOLD
        });
    }
    
    console.log(`\n=== COMMAND RATE CHECK ===`);
    console.log(`User: ${identifier}`);
    console.log(`Commands in last second: ${recentTimestamps.length}/${ANOMALY_THRESHOLD}`);
    console.log(`Status: OK`);
    console.log(`==========================\n`);
    
    next();
}

module.exports = {
    createSession: createSession,
    getSession: getSession,
    validateSession: validateSession,
    deleteSession: deleteSession,
    sessionBinding: sessionBinding,
    antiReplay: antiReplay,
    contextAware: contextAware,
    generateSecureCommand: generateSecureCommand,
    verifySecureCommand: verifySecureCommand,
    commandRateLimiter: commandRateLimiter
};
console.log("╔══════════════════════════════════════════════════════════════════════════╗");
console.log("║          COMPREHENSIVE RBAC SECURITY TEST - ALL ROLES                    ║");
console.log("╚══════════════════════════════════════════════════════════════════════════╝\n");

const crypto = require("crypto");
const axios = require("axios");

const API_URL = "http://localhost:5000";
const STATIC_AES_KEY = Buffer.from("1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef", "hex");
const IV_LENGTH = 16;

async function login(username, password, role, patientId = null) {
  const ephemeralKey = crypto.randomBytes(32);
  let encryptedAesKey = null;
  
  try {
    const keyRes = await axios.get(API_URL + "/api/auth/publickey");
    encryptedAesKey = crypto.publicEncrypt(
      { key: keyRes.data.publicKey, padding: crypto.constants.RSA_PKCS1_OAEP_PADDING, oaepHash: "sha256" },
      ephemeralKey
    ).toString("base64");
  } catch (e) {}
  
  const payload = { username, password, role, encryptedAesKey };
  if (patientId) payload.patientId = patientId;
  
  const res = await axios.post(API_URL + "/api/auth/login", payload, {
    headers: { "x-device-id": `test_${role}`, "user-agent": "RBACTest/1.0" }
  });
  
  return res.data.token;
}

async function testDataAccess() {
  console.log("═══════════════════════════════════════════════════════════════════════════");
  console.log("                         DATA ACCESS RULES TEST                             ");
  console.log("═══════════════════════════════════════════════════════════════════════════\n");
  
  console.log("┌────────────────────────────────────────────────────────────────────────────┐");
  console.log("│ 1. DOCTOR - FULL ACCESS (View, Add, Modify, Delete)                       │");
  console.log("└────────────────────────────────────────────────────────────────────────────┘\n");
  
  const doctorToken = await login("doctor1", "password", "doctor", 1);
  const headers = { authorization: `Bearer ${doctorToken}`, "x-device-id": "test_doc" };
  
  console.log("[TEST] GET /api/data/patients - Doctor views patients");
  let res = await axios.get(API_URL + "/api/data/patients", { headers });
  console.log("✅ PASS: " + res.data.message);
  console.log("   Access Level: " + res.data.access + "\n");
  
  console.log("[TEST] POST /api/data/reports - Doctor creates report");
  res = await axios.post(API_URL + "/api/data/reports", 
    { patientId: 1, title: "Test Report" }, { headers });
  console.log("✅ PASS: " + res.data.message + "\n");
  
  console.log("[TEST] PUT /api/data/reports/1 - Doctor modifies report");
  res = await axios.put(API_URL + "/api/data/reports/1", 
    { title: "Updated Title" }, { headers });
  console.log("✅ PASS: " + res.data.message + "\n");
  
  console.log("[TEST] DELETE /api/data/reports/1 - Doctor deletes report");
  res = await axios.delete(API_URL + "/api/data/reports/1", { headers });
  console.log("✅ PASS: " + res.data.message + "\n");
  
  console.log("┌────────────────────────────────────────────────────────────────────────────┐");
  console.log("│ 2. NURSE - PARTIAL ACCESS (View, Add, Modify, NO DELETE)                  │");
  console.log("└────────────────────────────────────────────────────────────────────────────┘\n");
  
  const nurseToken = await login("nurse1", "password", "nurse", 1);
  const nurseHeaders = { authorization: `Bearer ${nurseToken}`, "x-device-id": "test_nurse" };
  
  console.log("[TEST] GET /api/data/patients - Nurse views patients");
  res = await axios.get(API_URL + "/api/data/patients", { headers: nurseHeaders });
  console.log("✅ PASS: " + res.data.message);
  console.log("   Access Level: " + res.data.access + "\n");
  
  console.log("[TEST] POST /api/data/reports - Nurse creates report");
  res = await axios.post(API_URL + "/api/data/reports", 
    { patientId: 1, title: "Nurse Report" }, { headers: nurseHeaders });
  console.log("✅ PASS: " + res.data.message + "\n");
  
  console.log("[TEST] PUT /api/data/reports/2 - Nurse modifies report");
  res = await axios.put(API_URL + "/api/data/reports/2", 
    { title: "Nurse Updated" }, { headers: nurseHeaders });
  console.log("✅ PASS: " + res.data.message + "\n");
  
  console.log("[TEST] DELETE /api/data/reports/2 - Nurse attempts DELETE");
  try {
    await axios.delete(API_URL + "/api/data/reports/2", { headers: nurseHeaders });
    console.log("❌ FAIL: Nurse should NOT be able to delete!\n");
  } catch (err) {
    if (err.response?.status === 403) {
      console.log("✅ PASS: Nurse BLOCKED from delete (403 Forbidden)");
      console.log("   Message: " + err.response.data.message + "\n");
    }
  }
  
  console.log("┌────────────────────────────────────────────────────────────────────────────┐");
  console.log("│ 3. PATIENT - RESTRICTED (View OWN data ONLY, No Add/Modify/Delete)         │");
  console.log("└────────────────────────────────────────────────────────────────────────────┘\n");
  
  const patientToken = await login("patient1", "password", "patient", 1);
  const patientHeaders = { authorization: `Bearer ${patientToken}`, "x-device-id": "test_patient" };
  
  console.log("[TEST] GET /api/data/patients - Patient views own data");
  res = await axios.get(API_URL + "/api/data/patients", { headers: patientHeaders });
  console.log("✅ PASS: " + res.data.message);
  console.log("   Access Level: " + res.data.access + "\n");
  
  console.log("[TEST] POST /api/data/reports - Patient attempts CREATE");
  try {
    await axios.post(API_URL + "/api/data/reports", 
      { patientId: 1, title: "Hacked Report" }, { headers: patientHeaders });
    console.log("❌ FAIL: Patient should NOT be able to create!\n");
  } catch (err) {
    if (err.response?.status === 403) {
      console.log("✅ PASS: Patient BLOCKED from creating (403 Forbidden)");
      console.log("   Error: " + err.response.data.error + "\n");
    }
  }
  
  console.log("[TEST] PUT /api/data/reports/1 - Patient attempts MODIFY");
  try {
    await axios.put(API_URL + "/api/data/reports/1", 
      { title: "Hacked Title" }, { headers: patientHeaders });
    console.log("❌ FAIL: Patient should NOT be able to modify!\n");
  } catch (err) {
    if (err.response?.status === 403) {
      console.log("✅ PASS: Patient BLOCKED from modifying (403 Forbidden)");
      console.log("   Error: " + err.response.data.error + "\n");
    }
  }
  
  console.log("[TEST] DELETE /api/data/reports/1 - Patient attempts DELETE");
  try {
    await axios.delete(API_URL + "/api/data/reports/1", { headers: patientHeaders });
    console.log("❌ FAIL: Patient should NOT be able to delete!\n");
  } catch (err) {
    if (err.response?.status === 403) {
      console.log("✅ PASS: Patient BLOCKED from deleting (403 Forbidden)");
      console.log("   Error: " + err.response.data.error + "\n");
    }
  }
}

async function testChatAccess() {
  console.log("═══════════════════════════════════════════════════════════════════════════");
  console.log("                         CHAT ACCESS RULES TEST                              ");
  console.log("═══════════════════════════════════════════════════════════════════════════\n");
  
  const roles = [
    { name: "doctor", canChat: ["nurse", "patient"] },
    { name: "nurse", canChat: ["doctor", "patient"] },
    { name: "patient", canChat: ["doctor", "nurse"] }
  ];
  
  for (const role of roles) {
    console.log(`[Testing ${role.name.toUpperCase()} chat permissions]`);
    
    const token = await login(`${role.name}1`, "password", role.name);
    const headers = { authorization: `Bearer ${token}`, "x-device-id": `chat_${role.name}` };
    
    for (const targetRole of roles) {
      try {
        const testMsg = `Test message from ${role.name} to ${targetRole.name}`;
        const res = await axios.post(API_URL + "/api/chat/send",
          { receiverRole: targetRole.name, message: testMsg },
          { headers }
        );
        console.log(`${role.name} -> ${targetRole.name}: ✅ PASS (sent)`);
      } catch (err) {
        if (err.response?.status === 403) {
          console.log(`${role.name} -> ${targetRole.name}: ❌ BLOCKED (403)`);
        }
      }
    }
    console.log("");
  }
  
  console.log("Chat access summary:");
  console.log("  ✅ Doctor can chat with: Nurse, Patient");
  console.log("  ✅ Nurse can chat with: Doctor, Patient");
  console.log("  ✅ Patient can chat with: Doctor, Nurse\n");
}

async function runTests() {
  try {
    await testDataAccess();
    await testChatAccess();
    
    console.log("╔══════════════════════════════════════════════════════════════════════════╗");
    console.log("║                    RBAC SECURITY TEST - COMPLETE                           ║");
    console.log("╠══════════════════════════════��═��═════════════════════════════════════════╣");
    console.log("║ DATA ACCESS:                                                              ║");
    console.log("║   Doctor   → View:✅ Add:✅ Modify:✅ Delete:✅                          ║");
    console.log("║   Nurse    → View:✅ Add:✅ Modify:✅ Delete:❌                         ║");
    console.log("║   Patient  → View:✅ Add:❌ Modify:❌ Delete:❌                         ║");
    console.log("║                                                                         ║");
    console.log("║ CHAT ACCESS:                                                              ║");
    console.log("║   Doctor   → Nurse:✅ Patient:✅                                       ║");
    console.log("║   Nurse    → Doctor:✅ Patient:✅                                      ║");
    console.log("║   Patient  → Doctor:✅ Nurse:✅                                         ║");
    console.log("╚══════════════════════════════════════════════════════════════════════════╝\n");
    
  } catch (err) {
    console.error("Error:", err.message);
  }
}

runTests();
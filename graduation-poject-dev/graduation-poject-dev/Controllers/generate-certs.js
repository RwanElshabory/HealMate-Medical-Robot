const crypto = require('crypto');
const fs = require('fs');

function generateSelfSignedCert() {
  const { privateKey, publicKey } = crypto.generateKeyPairSync('rsa', {
    modulusLength: 2048,
    privateKeyEncoding: {
      type: 'pkcs8',
      format: 'pem'
    },
    publicKeyEncoding: {
      type: 'spki',
      format: 'pem'
    }
  });

  const cert = crypto.createSelfSigned({
    keys: [
      { key: privateKey, type: 'pkcs8' },
      { key: publicKey, type: 'spki' }
    ],
    days: 365,
    subject: {
      commonName: 'localhost',
      organization: 'MedicalRobot'
    },
    extensions: [
      {
        name: 'subjectAltName',
        altNames: [
          { type: 2, value: 'localhost' },
          { type: 7, ip: '127.0.0.1' }
        ]
      }
    ]
  });

  return { privateKey, cert };
}

const { privateKey, cert } = generateSelfSignedCert();

fs.writeFileSync('backend/backend.key', privateKey);
fs.writeFileSync('backend/backend.crt', cert);
fs.writeFileSync('robot/robot.key', privateKey);
fs.writeFileSync('robot/robot.crt', cert);

console.log('SSL certificates generated successfully');
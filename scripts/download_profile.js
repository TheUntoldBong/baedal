const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
const https = require('https');
const os = require('os');

const keyId = process.env.APP_STORE_KEY_ID;
const issuerId = process.env.APP_STORE_ISSUER_ID;
const privateKey = process.env.APP_STORE_PRIVATE_KEY;

if (!keyId || !issuerId || !privateKey) {
  console.log('App Store Connect credentials not fully provided in environment.');
  process.exit(0);
}

function b64url(str) {
  return Buffer.from(str).toString('base64').replace(/=/g, '').replace(/\+/g, '-').replace(/\//g, '_');
}

const header = { alg: 'ES256', kid: keyId, typ: 'JWT' };
const now = Math.floor(Date.now() / 1000);
const payload = {
  iss: issuerId,
  iat: now,
  exp: now + 1200,
  aud: 'appstoreconnect-v1'
};

const tokenInput = b64url(JSON.stringify(header)) + '.' + b64url(JSON.stringify(payload));
const sign = crypto.createSign('SHA256');
sign.update(tokenInput);
const sig = sign.sign({ key: privateKey, dsaEncoding: 'ieee-p1363' });
const token = tokenInput + '.' + sig.toString('base64').replace(/=/g, '').replace(/\+/g, '-').replace(/\//g, '_');

https.get('https://api.appstoreconnect.apple.com/v1/profiles?filter[profileType]=IOS_APP_STORE', {
  headers: { 'Authorization': 'Bearer ' + token }
}, res => {
  let data = '';
  res.on('data', chunk => data += chunk);
  res.on('end', () => {
    try {
      const json = JSON.parse(data);
      if (!json.data || json.data.length === 0) {
        console.error('No App Store profiles found on Apple Developer Portal.');
        process.exit(1);
      }

      // Find active profile
      const profile = json.data.find(p => p.attributes.profileState === 'ACTIVE') || json.data[0];
      const uuid = profile.attributes.uuid;
      const name = profile.attributes.name;
      console.log('Using Profile:', name, 'UUID:', uuid);

      const targetDir = path.join(os.homedir(), 'Library', 'MobileDevice', 'Provisioning Profiles');
      fs.mkdirSync(targetDir, { recursive: true });

      const content = Buffer.from(profile.attributes.profileContent, 'base64');
      fs.writeFileSync(path.join(targetDir, `${uuid}.mobileprovision`), content);
      fs.writeFileSync(path.join(targetDir, `${name}.mobileprovision`), content);
      fs.writeFileSync(path.join('ios', 'Baedal_AppStore_Profile_2026.mobileprovision'), content);
      console.log('Provisioning profile written successfully!');
    } catch (e) {
      console.error('Failed to parse Apple API response:', e);
      process.exit(1);
    }
  });
}).on('error', err => {
  console.error('Network request failed:', err);
  process.exit(1);
});

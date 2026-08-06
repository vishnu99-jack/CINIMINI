const fs = require("fs");
const path = require("path");
const { google } = require("googleapis");
const { authenticate } = require("@google-cloud/local-auth");

const SCOPES = [
    "https://www.googleapis.com/auth/youtube.upload"
];

const CREDENTIALS_PATH = path.join(__dirname, "client_secret.json");
const TOKEN_PATH = path.join(__dirname, "token.json");

async function authorize() {
    const auth = await authenticate({
        scopes: SCOPES,
        keyfilePath: CREDENTIALS_PATH,
    });

    const credentials = auth.credentials;

    fs.writeFileSync(
        TOKEN_PATH,
        JSON.stringify(credentials, null, 2)
    );

    console.log("\n====================================");
    console.log("✅ Authorization Successful!");
    console.log("token.json created.");
    console.log("====================================\n");
}

authorize().catch(console.error);
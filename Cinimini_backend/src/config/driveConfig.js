const path = require("path");

// ============================================================
// Google Drive OAuth scopes
// ============================================================

const SCOPES = [
    "https://www.googleapis.com/auth/drive.file"
];

// ============================================================
// OAuth credentials
// ============================================================

const CREDENTIALS_PATH = path.join(
    process.cwd(),
    "credentials.json"
);

// ============================================================
// Saved OAuth token
// ============================================================

const TOKEN_PATH = path.join(
    process.cwd(),
    "token.json"
);

// ============================================================
// Cinimini Google Drive storage folder
// ============================================================

const STORAGE_FOLDER_NAME =
    "CiniminiStorage";

// ============================================================
// Export configuration
// ============================================================

module.exports = {
    SCOPES,
    CREDENTIALS_PATH,
    TOKEN_PATH,
    STORAGE_FOLDER_NAME
};
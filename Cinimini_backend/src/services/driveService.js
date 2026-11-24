const fs = require("fs");
const path = require("path");

const { authenticate } = require("@google-cloud/local-auth");
const { google } = require("googleapis");

const {
    SCOPES,
    CREDENTIALS_PATH,
    TOKEN_PATH,
    STORAGE_FOLDER_NAME
} = require("../config/driveConfig");

let authClient = null;
let storageFolderId = null;

// ============================================================
// LOAD OAUTH CLIENT INFORMATION
// ============================================================

function loadOAuthClientConfig() {

    if (!fs.existsSync(CREDENTIALS_PATH)) {

        throw new Error(
            `credentials.json not found at: ${CREDENTIALS_PATH}`
        );
    }

    const credentials =
        JSON.parse(
            fs.readFileSync(
                CREDENTIALS_PATH,
                "utf8"
            )
        );

    // Google OAuth credentials can be under
    // "installed" or "web".

    const config =
        credentials.installed ||
        credentials.web;

    if (!config) {

        throw new Error(
            "credentials.json does not contain an 'installed' or 'web' OAuth configuration."
        );
    }

    if (
        !config.client_id ||
        !config.client_secret
    ) {

        throw new Error(
            "credentials.json is missing client_id or client_secret."
        );
    }

    return config;
}

// ============================================================
// GOOGLE AUTHENTICATION
// ============================================================

async function getDriveAuth() {

    // --------------------------------------------------------
    // Reuse authentication client during this server process
    // --------------------------------------------------------

    if (authClient) {

        return authClient;
    }

    console.log(
        "\n[DRIVE] Initializing Google authentication..."
    );

    // ========================================================
    // FIRST: Load OAuth application credentials
    // ========================================================

    const oauthConfig =
        loadOAuthClientConfig();

    // ========================================================
    // EXISTING TOKEN
    // ========================================================

    if (fs.existsSync(TOKEN_PATH)) {

        console.log(
            "[DRIVE] Existing token.json found."
        );

        console.log(
            "[DRIVE] Reusing saved Google credentials..."
        );

        const savedCredentials =
            JSON.parse(
                fs.readFileSync(
                    TOKEN_PATH,
                    "utf8"
                )
            );

        // ----------------------------------------------------
        // IMPORTANT:
        // Create OAuth2 client WITH client ID and secret.
        // ----------------------------------------------------

        const client =
            new google.auth.OAuth2(
                oauthConfig.client_id,
                oauthConfig.client_secret,
                oauthConfig.redirect_uris
                    ? oauthConfig.redirect_uris[0]
                    : undefined
            );

        // ----------------------------------------------------
        // Load saved token
        // ----------------------------------------------------

        client.setCredentials(
            savedCredentials
        );

        console.log(
            "[DRIVE] OAuth client configured."
        );

        // ----------------------------------------------------
        // Ask Google for a valid access token.
        //
        // If the current access token is still valid,
        // Google auth will use it.
        //
        // If expired, the refresh token will be used.
        // ----------------------------------------------------

        const tokenInfo =
            await client.getAccessToken();

        if (
            !tokenInfo ||
            !tokenInfo.token
        ) {

            throw new Error(
                "Saved Google credentials could not produce an access token."
            );
        }

        console.log(
            "[DRIVE] Access token obtained from saved credentials."
        );

        // ----------------------------------------------------
        // Update access token in memory
        // ----------------------------------------------------

        client.setCredentials({

            ...client.credentials,

            access_token:
                tokenInfo.token

        });

        // ----------------------------------------------------
        // Save refreshed credentials
        //
        // This keeps expiry_date/access_token current.
        // ----------------------------------------------------

        fs.writeFileSync(
            TOKEN_PATH,
            JSON.stringify(
                client.credentials,
                null,
                2
            )
        );

        console.log(
            "[DRIVE] Saved credentials loaded successfully."
        );

        authClient =
            client;

        return authClient;
    }

    // ========================================================
    // FIRST-TIME GOOGLE OAUTH
    // ========================================================

    console.log(
        "[DRIVE] No token.json found."
    );

    console.log(
        "[DRIVE] Starting one-time Google OAuth..."
    );

    const client =
        await authenticate({

            scopes:
                SCOPES,

            keyfilePath:
                CREDENTIALS_PATH

        });

    // --------------------------------------------------------
    // Get access token
    // --------------------------------------------------------

    const tokenInfo =
        await client.getAccessToken();

    if (
        !tokenInfo ||
        !tokenInfo.token
    ) {

        throw new Error(
            "Google OAuth succeeded, but no access token was obtained."
        );
    }

    client.setCredentials({

        ...client.credentials,

        access_token:
            tokenInfo.token

    });

    console.log(
        "[DRIVE] Access token obtained."
    );

    console.log(
        "[DRIVE] Granted scopes:",
        client.credentials.scope
    );

    // --------------------------------------------------------
    // Save credentials
    // --------------------------------------------------------

    fs.writeFileSync(
        TOKEN_PATH,
        JSON.stringify(
            client.credentials,
            null,
            2
        )
    );

    console.log(
        "[DRIVE] token.json saved."
    );

    authClient =
        client;

    return authClient;
}

// ============================================================
// AUTHENTICATED DRIVE REST REQUEST
// ============================================================

async function driveRequest(
    url,
    method = "GET",
    params = {},
    body = null
) {

    const auth =
        await getDriveAuth();

    console.log(
        `[DRIVE API] ${method} ${url}`
    );

    const requestOptions = {

        url,

        method,

        params

    };

    // GET/HEAD must not contain a body.

    if (
        body !== null &&
        body !== undefined
    ) {

        requestOptions.data =
            body;
    }

    const response =
        await auth.request(
            requestOptions
        );

    return response.data;
}

// ============================================================
// TEST AUTHENTICATION
// ============================================================

async function testDriveAuthentication() {

    console.log(
        "\n[AUTH TEST] Testing authenticated Drive request..."
    );

    const data =
        await driveRequest(

            "https://www.googleapis.com/drive/v3/about",

            "GET",

            {
                fields:
                    "user(displayName,emailAddress),storageQuota"
            }

        );

    console.log(
        "[AUTH TEST] Drive request successful."
    );

    console.log(
        "[AUTH TEST] User:",
        data.user
    );

    return data;
}

// ============================================================
// FIND CINIMINI STORAGE
// ============================================================

async function findStorageFolder() {

    console.log(
        "\n[DRIVE] Searching for CiniminiStorage..."
    );

    const data =
        await driveRequest(

            "https://www.googleapis.com/drive/v3/files",

            "GET",

            {

                q:
                    `name = '${STORAGE_FOLDER_NAME}' ` +
                    `and mimeType = 'application/vnd.google-apps.folder' ` +
                    `and trashed = false`,

                spaces:
                    "drive",

                fields:
                    "files(id,name,mimeType,parents)",

                pageSize:
                    10

            }

        );

    if (
        data.files &&
        data.files.length > 0
    ) {

        const folder =
            data.files[0];

        console.log(
            "[DRIVE] Existing storage folder found:",
            folder.id
        );

        return folder.id;
    }

    console.log(
        "[DRIVE] CiniminiStorage not found."
    );

    return null;
}

// ============================================================
// CREATE CINIMINI STORAGE
// ============================================================

async function createStorageFolder() {

    console.log(
        "\n[DRIVE] Creating CiniminiStorage folder..."
    );

    const data =
        await driveRequest(

            "https://www.googleapis.com/drive/v3/files",

            "POST",

            {

                fields:
                    "id,name,mimeType"

            },

            {

                name:
                    STORAGE_FOLDER_NAME,

                mimeType:
                    "application/vnd.google-apps.folder"

            }

        );

    console.log(
        "[DRIVE] Folder created:",
        data.id
    );

    return data.id;
}

// ============================================================
// GET OR CREATE STORAGE FOLDER
// ============================================================

async function getStorageFolderId() {

    if (storageFolderId) {

        return storageFolderId;
    }

    let folderId =
        await findStorageFolder();

    if (!folderId) {

        folderId =
            await createStorageFolder();
    }

    storageFolderId =
        folderId;

    return folderId;
}

// ============================================================
// GET FILE METADATA
// ============================================================

async function getFileMetadata(
    fileId
) {

    return await driveRequest(

        `https://www.googleapis.com/drive/v3/files/${fileId}`,

        "GET",

        {

            fields:
                "id,name,mimeType,size,parents,createdTime,modifiedTime"

        }

    );
}

// ============================================================
// UPLOAD FILE TO CINIMINI STORAGE
// ============================================================

async function uploadFile(
    filePath,
    fileName,
    mimeType
) {

    const auth =
        await getDriveAuth();

    const folderId =
        await getStorageFolderId();

    console.log(
        `\n[DRIVE] Uploading: ${fileName}`
    );

    console.log(
        `[DRIVE] Storage folder: ${folderId}`
    );

    const metadata = {

        name:
            fileName,

        parents:
            [folderId]

    };

    const boundary =
        "cinimini_boundary_" +
        Date.now();

    const metadataJson =
        JSON.stringify(
            metadata
        );

    const header =
        `--${boundary}\r\n` +
        `Content-Type: application/json; charset=UTF-8\r\n\r\n` +
        `${metadataJson}\r\n` +
        `--${boundary}\r\n` +
        `Content-Type: ${mimeType}\r\n\r\n`;

    const footer =
        `\r\n--${boundary}--`;

    const headerBuffer =
        Buffer.from(header);

    const footerBuffer =
        Buffer.from(footer);

    const fileBuffer =
        fs.readFileSync(
            filePath
        );

    const bodyBuffer =
        Buffer.concat([
            headerBuffer,
            fileBuffer,
            footerBuffer
        ]);

    const response =
        await auth.request({

            url:
                "https://www.googleapis.com/upload/drive/v3/files",

            method:
                "POST",

            params: {

                uploadType:
                    "multipart",

                fields:
                    "id,name,mimeType,size,parents"

            },

            headers: {

                "Content-Type":
                    `multipart/related; boundary=${boundary}`

            },

            data:
                bodyBuffer

        });

    console.log(
        "[DRIVE] Upload successful."
    );

    console.log(
        "[DRIVE] File ID:",
        response.data.id
    );

    console.log(
        "[DRIVE] File name:",
        response.data.name
    );

    return response.data;
}

// ============================================================
// STREAM FILE FROM GOOGLE DRIVE
// ============================================================

async function streamFileFromDrive(
    fileId,
    range = null
) {

    const auth =
        await getDriveAuth();

    console.log(
        `\n[DRIVE STREAM] File: ${fileId}`
    );

    if (range) {

        console.log(
            `[DRIVE STREAM] Range: ${range}`
        );

    }

    // --------------------------------------------------------
    // Get current access token
    // --------------------------------------------------------

    const tokenInfo =
        await auth.getAccessToken();

    if (
        !tokenInfo ||
        !tokenInfo.token
    ) {

        throw new Error(
            "Unable to obtain Google access token for video streaming."
        );
    }

    const headers = {

        Authorization:
            `Bearer ${tokenInfo.token}`,

        "Accept-Encoding":
            "identity"

    };

    // --------------------------------------------------------
    // Forward browser/video-player Range request
    // --------------------------------------------------------

    if (range) {

        headers.Range =
            range;

    }

    // --------------------------------------------------------
    // Google Drive media endpoint
    // --------------------------------------------------------

    const url =
        `https://www.googleapis.com/drive/v3/files/${fileId}?alt=media`;

    console.log(
        "[DRIVE STREAM] Fetching media..."
    );

    const response =
        await fetch(

            url,

            {

                method:
                    "GET",

                headers,

                redirect:
                    "follow"

            }

        );

    console.log(
        `[DRIVE STREAM] Status: ${response.status}`
    );

    console.log(
        `[DRIVE STREAM] Content-Length: ${response.headers.get("content-length")
        }`
    );

    console.log(
        `[DRIVE STREAM] Content-Range: ${response.headers.get("content-range")
        }`
    );

    if (!response.ok) {

        const errorText =
            await response.text();

        console.error(
            "[DRIVE STREAM ERROR]",
            response.status,
            errorText
        );

        throw new Error(
            `Google Drive streaming failed: ${response.status} ${errorText}`
        );
    }

    return response;
}

// ============================================================
// EXPORTS
// ============================================================

module.exports = {

    getDriveAuth,

    testDriveAuthentication,

    getStorageFolderId,

    getFileMetadata,

    uploadFile,

    streamFileFromDrive

};
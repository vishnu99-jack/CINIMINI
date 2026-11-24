const fs = require("fs");
const path = require("path");
const { Blob } = require("buffer");

// ============================================================
// PeerTube Configuration
// ============================================================

const PEERTUBE_URL = process.env.PEERTUBE_URL || "http://localhost:9000";
const PEERTUBE_USERNAME = process.env.PEERTUBE_USERNAME;
const PEERTUBE_PASSWORD = process.env.PEERTUBE_PASSWORD;
const PEERTUBE_CHANNEL_ID = process.env.PEERTUBE_CHANNEL_ID || "1";


// ============================================================
// Internal helper
// ============================================================

async function parseResponse(response) {
    const text = await response.text();

    let data;

    try {
        data = text ? JSON.parse(text) : {};
    } catch {
        data = {
            raw: text
        };
    }

    if (!response.ok) {
        const error = new Error(
            data?.detail ||
            data?.message ||
            data?.error ||
            `PeerTube request failed with status ${response.status}`
        );

        error.status = response.status;
        error.response = data;

        throw error;
    }

    return data;
}


// ============================================================
// Get OAuth client credentials
// ============================================================

async function getOAuthClient() {

    const response = await fetch(
        `${PEERTUBE_URL}/api/v1/oauth-clients/local`
    );

    return await parseResponse(response);
}


// ============================================================
// Get PeerTube access token
// ============================================================

async function getAccessToken() {

    if (!PEERTUBE_USERNAME || !PEERTUBE_PASSWORD) {
        throw new Error(
            "PEERTUBE_USERNAME or PEERTUBE_PASSWORD is missing in .env"
        );
    }

    const client = await getOAuthClient();

    const body = new URLSearchParams({
        client_id: client.client_id,
        client_secret: client.client_secret,
        grant_type: "password",
        username: PEERTUBE_USERNAME,
        password: PEERTUBE_PASSWORD
    });

    const response = await fetch(
        `${PEERTUBE_URL}/api/v1/users/token`,
        {
            method: "POST",
            headers: {
                "Content-Type":
                    "application/x-www-form-urlencoded"
            },
            body
        }
    );

    const data = await parseResponse(response);

    if (!data.access_token) {
        throw new Error(
            "PeerTube authentication succeeded but no access token was returned."
        );
    }

    return data.access_token;
}


// ============================================================
// Upload video to PeerTube
// ============================================================

async function uploadVideo({
    filePath,
    fileName,
    mimeType,
    title,
    description = "",
    category = 10,
    waitTranscoding = false
}) {

    if (!filePath) {
        throw new Error("filePath is required.");
    }

    if (!fs.existsSync(filePath)) {
        throw new Error(
            `Video file not found: ${filePath}`
        );
    }

    if (!title || title.trim().length < 3) {
        throw new Error(
            "Video title must contain at least 3 characters."
        );
    }

    const accessToken = await getAccessToken();

    // --------------------------------------------------------
    // Read video
    // --------------------------------------------------------

    const fileBuffer = await fs.promises.readFile(filePath);

    const videoBlob = new Blob(
        [fileBuffer],
        {
            type: mimeType || "video/mp4"
        }
    );

    // --------------------------------------------------------
    // Multipart form
    // --------------------------------------------------------

    const form = new FormData();

    form.append(
        "videofile",
        videoBlob,
        fileName || path.basename(filePath)
    );

    form.append(
        "channelId",
        String(PEERTUBE_CHANNEL_ID)
    );

    form.append(
        "name",
        title
    );

    if (description && description.trim().length > 0) {
        form.append(
            "description",
            description.trim()
        );
    }

    form.append(
        "category",
        String(category)
    );

    form.append(
        "waitTranscoding",
        String(waitTranscoding)
    );

    // --------------------------------------------------------
    // Upload
    // --------------------------------------------------------

    const response = await fetch(
        `${PEERTUBE_URL}/api/v1/videos/upload`,
        {
            method: "POST",

            headers: {
                Authorization:
                    `Bearer ${accessToken}`
            },

            body: form
        }
    );

    const data = await parseResponse(response);

    // --------------------------------------------------------
    // PeerTube returns:
    //
    // {
    //     video: {
    //         id,
    //         uuid,
    //         shortUUID
    //     }
    // }
    // --------------------------------------------------------

    return {
        success: true,

        peertube: {
            id: data.video?.id,
            uuid: data.video?.uuid,
            shortUUID: data.video?.shortUUID,

            watchUrl:
                `${PEERTUBE_URL}/videos/watch/${data.video?.uuid}`
        },

        raw: data
    };
}


// ============================================================
// Export
// ============================================================

module.exports = {
    getOAuthClient,
    getAccessToken,
    uploadVideo
};
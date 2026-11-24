const http = require("http");

const PORT = 8081;

// ============================================================
// Google Drive file IDs
// ============================================================

const DRIVE_FILES = {
    master:
        "1_ZBMeXm-4y4ELZ0aHjhec9GCIudwTc4k",

    playlist:
        "1odvKKL0pX1GgTii5u2EA2uGMkBozx5JC",

    video:
        "17o39FjAgQWXSV7xoZ7vkJAfXeyFiBFA4",
};

// ============================================================
// Google Drive download URL
// ============================================================

function driveUrl(fileId) {
    return `https://drive.google.com/uc?export=download&id=${fileId}`;
}

// ============================================================
// Fetch a file from Google Drive
// ============================================================

async function fetchDriveFile(fileId, range = null) {
    const headers = {
        "Accept-Encoding": "identity",
    };

    if (range) {
        headers["Range"] = range;
    }

    console.log(
        `\n[DRIVE] GET ${fileId}` +
        (range ? ` | Range: ${range}` : "")
    );

    const response = await fetch(driveUrl(fileId), {
        method: "GET",
        headers,
        redirect: "follow",
    });

    console.log(
        `[DRIVE] Status: ${response.status}`
    );

    console.log(
        `[DRIVE] Content-Length: ${response.headers.get("content-length")}`
    );

    console.log(
        `[DRIVE] Content-Range: ${response.headers.get("content-range")}`
    );

    return response;
}

// ============================================================
// Read HLS playlist from Google Drive
// ============================================================

async function getPlaylist(fileId) {
    const response = await fetchDriveFile(fileId);

    if (!response.ok) {
        throw new Error(
            `Google Drive returned ${response.status}`
        );
    }

    return await response.text();
}

// ============================================================
// Rewrite master.m3u8
// ============================================================

// ============================================================
// Rewrite master.m3u8
// ============================================================

async function serveMaster(res) {
    let content = await getPlaylist(DRIVE_FILES.master);

    console.log("\n[HLS] Original master playlist:");
    console.log(content);

    // The master playlist contains the media playlist filename.
    // Replace ANY .m3u8 URI with our proxy playlist.
    content = content.replace(
        /^[^\s#]+\.m3u8$/gm,
        "/hls/480.m3u8"
    );

    console.log("\n[HLS] Rewritten master playlist:");
    console.log(content);

    res.writeHead(200, {
        "Content-Type": "application/vnd.apple.mpegurl",
        "Cache-Control": "no-store, no-cache, must-revalidate",
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Expose-Headers": "*",
    });

    res.end(content);
}

// ============================================================
// Rewrite 480.m3u8
// ============================================================

// ============================================================
// Rewrite 480.m3u8
// ============================================================

async function servePlaylist(res) {
    let content = await getPlaylist(DRIVE_FILES.playlist);

    console.log("\n[HLS] Original media playlist:");
    console.log(content);

    // Replace every PeerTube fragmented MP4 reference
    // with our proxy endpoint.
    content = content.replace(
        /47b6c23c-2139-407b-aa15-95b55206ff57-480-fragmented\.mp4/g,
        "/hls/video.mp4"
    );

    console.log("\n[HLS] Rewritten media playlist:");
    console.log(content);

    res.writeHead(200, {
        "Content-Type": "application/vnd.apple.mpegurl",
        "Cache-Control": "no-store, no-cache, must-revalidate",
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Expose-Headers": "*",
    });

    res.end(content);
}

// ============================================================
// Proxy fragmented MP4
// ============================================================

async function serveVideo(req, res) {
    const range = req.headers.range || null;

    const response = await fetchDriveFile(
        DRIVE_FILES.video,
        range
    );

    if (!response.ok && response.status !== 206) {
        res.writeHead(response.status);
        res.end(
            `Google Drive returned ${response.status}`
        );
        return;
    }

    const headers = {
        "Content-Type": "video/mp4",
        "Accept-Ranges": "bytes",
        "Access-Control-Allow-Origin": "*",
        "Cache-Control": "public, max-age=3600",
    };

    const contentLength =
        response.headers.get("content-length");

    const contentRange =
        response.headers.get("content-range");

    if (contentLength) {
        headers["Content-Length"] = contentLength;
    }

    if (contentRange) {
        headers["Content-Range"] = contentRange;
    }

    console.log(
        `[PROXY] Returning ${response.status}` +
        (contentRange
            ? ` | ${contentRange}`
            : "")
    );

    res.writeHead(response.status, headers);

    // Stream Google Drive response directly to client.
    if (response.body) {
        const reader = response.body.getReader();

        while (true) {
            const { done, value } = await reader.read();

            if (done) {
                break;
            }

            res.write(Buffer.from(value));
        }
    }

    res.end();
}

// ============================================================
// HTTP server
// ============================================================

const server = http.createServer(async (req, res) => {

    console.log(
        `\n[REQUEST] ${req.method} ${req.url}`
    );

    // --------------------------------------------------------
    // CORS preflight
    // --------------------------------------------------------

    if (req.method === "OPTIONS") {
        res.writeHead(204, {
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Methods":
                "GET, OPTIONS",
            "Access-Control-Allow-Headers":
                "Range, Content-Type",
            "Access-Control-Expose-Headers":
                "Content-Length, Content-Range, Accept-Ranges",
        });

        res.end();
        return;
    }

    try {

        // ----------------------------------------------------
        // Master playlist
        // ----------------------------------------------------

        if (req.url === "/hls/master.m3u8") {
            await serveMaster(res);
            return;
        }

        // ----------------------------------------------------
        // 480p playlist
        // ----------------------------------------------------

        if (req.url === "/hls/480.m3u8") {
            await servePlaylist(res);
            return;
        }

        // ----------------------------------------------------
        // Fragmented MP4
        // ----------------------------------------------------

        if (req.url === "/hls/video.mp4") {
            await serveVideo(req, res);
            return;
        }

        // ----------------------------------------------------
        // Health check
        // ----------------------------------------------------

        if (req.url === "/") {
            res.writeHead(200, {
                "Content-Type": "text/plain",
            });

            res.end(
                "Cinimini Google Drive Video Proxy is running."
            );

            return;
        }

        // ----------------------------------------------------
        // 404
        // ----------------------------------------------------

        res.writeHead(404);
        res.end("Not Found");

    } catch (error) {

        console.error("\n[ERROR]", error);

        if (!res.headersSent) {
            res.writeHead(500, {
                "Content-Type": "text/plain",
            });
        }

        res.end(error.toString());
    }
});

// ============================================================
// Start server
// ============================================================

server.listen(PORT, "0.0.0.0", () => {
    console.log(
        "\n================================================"
    );

    console.log(
        " Cinimini Google Drive Video Proxy"
    );

    console.log(
        "================================================"
    );

    console.log(
        `Server: http://localhost:${PORT}`
    );

    console.log(
        `HLS:    http://localhost:${PORT}/hls/master.m3u8`
    );

    console.log(
        "================================================\n"
    );
});

const {
    streamFileFromDrive
} = require("./driveService");


// ============================================================
// VIDEO ASSET LOOKUP
// Temporary mapping for our successful test video.
// Later, we will retrieve this mapping from Firebase.
// ============================================================

const videoAssets = new Map([
    [
        "e9713faa-0591-460e-a16f-d51063de1dd1",
        {
            masterPlaylistId:
                "1bKkUdg9lfI53XCzamr3q_4Gj-G-MQYdE",

            mediaPlaylistId:
                "1VUWkVfZBCuH1SH9GUCfljeBWToQFJ5bJ",

            videoFileId:
                "1keCyyMKUb_flFYUkUlLN6sEJQVTRmQc-",

            resolution: "564p"
        }
    ]
]);


// ============================================================
// GET VIDEO ASSETS
// ============================================================

function getVideoAssets(videoUUID) {

    const assets = videoAssets.get(videoUUID);

    if (!assets) {

        throw new Error(
            `No Google Drive assets found for video: ${ videoUUID } `
        );

    }

    return assets;
}


// ============================================================
// GET FILE CONTENT FROM GOOGLE DRIVE
// ============================================================

async function getDriveFileContent(fileId) {

    if (!fileId) {

        throw new Error(
            "Google Drive file ID is required."
        );

    }

    console.log(
        `📥 Reading file from Google Drive: ${ fileId } `
    );

    const response =
        await streamFileFromDrive(fileId);

    if (!response || !response.body) {

        throw new Error(
            "Failed to retrieve file content from Google Drive."
        );

    }

    const chunks = [];

    for await (const chunk of response.body) {

        chunks.push(chunk);

    }

    const buffer =
        Buffer.concat(chunks);

    return buffer.toString("utf8");
}


// ============================================================
// READ HLS PLAYLIST
// ============================================================

async function readHLSPlaylist(fileId) {

    console.log(
        "\n🎬 Reading HLS playlist..."
    );

    const content =
        await getDriveFileContent(fileId);

    if (!content.startsWith("#EXTM3U")) {

        throw new Error(
            "The requested file is not a valid HLS playlist."
        );

    }

    console.log(
        "✅ HLS playlist successfully retrieved."
    );

    return content;
}


// ============================================================
// REWRITE PLAYLIST URLS
// ============================================================
function rewritePlaylistUrls(playlistContent, videoUUID, playlistType) {

    let rewrittenContent = playlistContent;

    if (playlistType === "master") {

        rewrittenContent = rewrittenContent.replace(
            /^[^\r\n#][^\r\n]*\.m3u8\s*$/gm,
            "media.m3u8"
        );

    }

    if (playlistType === "media") {

        // Rewrite initialization segment URI
        rewrittenContent = rewrittenContent.replace(
            /URI="[^"]+\.mp4"/g,
            'URI="video.mp4"'
        );

        // Rewrite fragmented MP4 segment references
        rewrittenContent = rewrittenContent.replace(
            /^[^\r\n#][^\r\n]*\.mp4\s*$/gm,
            "video.mp4"
        );

    }

    return rewrittenContent;
}

// ============================================================
// GET MASTER PLAYLIST
// ============================================================

async function getMasterPlaylist(videoUUID) {

    const assets =
        getVideoAssets(videoUUID);

    const playlist =
        await readHLSPlaylist(
            assets.masterPlaylistId
        );

    return rewritePlaylistUrls(
        playlist,
        videoUUID,
        "master"
    );

}


// ============================================================
// GET MEDIA PLAYLIST
// ============================================================

async function getMediaPlaylist(videoUUID) {

    const assets =
        getVideoAssets(videoUUID);

    const playlist =
        await readHLSPlaylist(
            assets.mediaPlaylistId
        );

    return rewritePlaylistUrls(
        playlist,
        videoUUID,
        "media"
    );

}


// ============================================================
// EXPORTS
// ============================================================

module.exports = {

    getVideoAssets,

    getDriveFileContent,

    readHLSPlaylist,

    rewritePlaylistUrls,

    getMasterPlaylist,

    getMediaPlaylist

};


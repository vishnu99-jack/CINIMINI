// ============================================================
// PeerTube Video Status Service
// ============================================================

const {
    getAccessToken
} = require("./peertubeService");


const PEERTUBE_URL =
    process.env.PEERTUBE_URL ||
    "http://localhost:9000";


// ============================================================
// Internal response parser
// ============================================================

async function parseResponse(response) {

    const text =
        await response.text();

    let data;

    try {

        data =
            text
                ? JSON.parse(text)
                : {};

    } catch {

        data = {
            raw: text
        };

    }


    if (!response.ok) {

        const error =
            new Error(

                data?.detail ||
                data?.message ||
                data?.error ||
                `PeerTube request failed with status ${response.status}`

            );

        error.status =
            response.status;

        error.response =
            data;

        throw error;

    }


    return data;

}


// ============================================================
// Get complete video details
// ============================================================

async function getVideoDetails(videoUUID) {

    if (!videoUUID) {

        throw new Error(
            "PeerTube video UUID is required."
        );

    }


    console.log(
        `\n[PEERTUBE STATUS] Checking video: ${videoUUID}`
    );


    // --------------------------------------------------------
    // Get PeerTube authentication token
    // --------------------------------------------------------

    const accessToken =
        await getAccessToken();


    // --------------------------------------------------------
    // Get video details
    // --------------------------------------------------------

    const response =
        await fetch(

            `${PEERTUBE_URL}/api/v1/videos/${videoUUID}`,

            {

                method:
                    "GET",

                headers: {

                    Authorization:
                        `Bearer ${accessToken}`

                }

            }

        );


    return await parseResponse(response);

}


// ============================================================
// Detect HLS streaming playlist
// ============================================================

function isHlsPlaylist(playlist) {

    if (!playlist) {

        return false;

    }


    // --------------------------------------------------------
    // PeerTube represents HLS as type: 1
    //
    // But we also verify the actual playlist structure
    // for safer detection.
    // --------------------------------------------------------

    if (playlist.type === 1) {

        return true;

    }


    // --------------------------------------------------------
    // Fallback:
    // Check whether playlist URL contains .m3u8
    // --------------------------------------------------------

    if (
        typeof playlist.playlistUrl === "string" &&
        playlist.playlistUrl.includes(".m3u8")
    ) {

        return true;

    }


    return false;

}


// ============================================================
// Check video processing state
// ============================================================

async function checkVideoStatus(videoUUID) {

    const video =
        await getVideoDetails(videoUUID);


    // --------------------------------------------------------
    // Video state
    // --------------------------------------------------------

    const state =
        video.state || null;


    const stateId =
        state?.id ?? null;


    const stateLabel =
        state?.label ??
        "Unknown";


    // --------------------------------------------------------
    // Streaming playlists
    // --------------------------------------------------------

    const streamingPlaylists =
        Array.isArray(video.streamingPlaylists)
            ? video.streamingPlaylists
            : [];


    // --------------------------------------------------------
    // Find HLS playlists
    // --------------------------------------------------------

    const hlsPlaylists =
        streamingPlaylists.filter(
            isHlsPlaylist
        );


    const hlsAvailable =
        hlsPlaylists.length > 0;


    // --------------------------------------------------------
    // Extract HLS files
    // --------------------------------------------------------

    const hlsFiles = [];


    for (const playlist of hlsPlaylists) {

        const playlistFiles =
            Array.isArray(playlist.files)
                ? playlist.files
                : [];


        for (const file of playlistFiles) {

            hlsFiles.push({

                id:
                    file.id ?? null,

                resolution:
                    file.resolution?.label ??
                    null,

                resolutionId:
                    file.resolution?.id ??
                    null,

                width:
                    file.width ?? null,

                height:
                    file.height ?? null,

                hasVideo:
                    file.hasVideo ?? false,

                hasAudio:
                    file.hasAudio ?? false,

                size:
                    file.size ?? null,

                fps:
                    file.fps ?? null,

                // Resolution playlist
                playlistUrl:
                    file.playlistUrl ?? null,

                // Fragmented MP4
                fileUrl:
                    file.fileUrl ?? null,

                fileDownloadUrl:
                    file.fileDownloadUrl ?? null

            });

        }

    }


    // --------------------------------------------------------
    // Processing decision
    // --------------------------------------------------------

    // HLS is ready when:
    //
    // 1. Video is published
    // 2. At least one HLS playlist exists
    // 3. At least one HLS video file exists

    const processingCompleted =
        stateId === 1 &&
        hlsAvailable &&
        hlsFiles.length > 0;


    // --------------------------------------------------------
    // Logging
    // --------------------------------------------------------

    console.log(
        "\n[PEERTUBE STATUS RESULT]"
    );

    console.log(
        "State:",
        stateLabel
    );

    console.log(
        "State ID:",
        stateId
    );

    console.log(
        "HLS Available:",
        hlsAvailable
    );

    console.log(
        "HLS Playlists:",
        hlsPlaylists.length
    );

    console.log(
        "HLS Files:",
        hlsFiles.length
    );

    console.log(
        "Processing Completed:",
        processingCompleted
    );


    // ========================================================
    // Return clean result
    // ========================================================

    return {

        success: true,

        videoUUID,

        processing: {

            stateId,

            stateLabel,

            completed:
                processingCompleted

        },


        hls: {

            available:
                hlsAvailable,


            // Master playlists

            playlists:

                hlsPlaylists.map(
                    playlist => ({

                        id:
                            playlist.id ?? null,

                        type:
                            playlist.type ?? null,

                        masterPlaylistUrl:
                            playlist.playlistUrl ?? null,

                        segmentsSha256Url:
                            playlist.segmentsSha256Url ?? null

                    })
                ),


            // Resolution-specific HLS files

            files:
                hlsFiles

        }

    };

}


// ============================================================
// Export
// ============================================================

module.exports = {

    getVideoDetails,

    checkVideoStatus

};
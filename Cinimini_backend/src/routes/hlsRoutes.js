const express = require("express");
const { Readable } = require("stream");

const router = express.Router();

const {
    getVideoAssets,
    getMasterPlaylist,
    getMediaPlaylist
} = require("../services/hlsStreamingService");

const {
    streamFileFromDrive,
    getFileMetadata
} = require("../services/driveService");

// ============================================================
// 1. MASTER PLAYLIST
// GET /api/videos/:videoUUID/hls/master.m3u8
// ============================================================

router.get(
    "/videos/:videoUUID/hls/master.m3u8",
    async (req, res) => {

    try {

        const { videoUUID } = req.params;

        const playlist =
            await getMasterPlaylist(videoUUID);

        res.setHeader(
            "Content-Type",
            "application/vnd.apple.mpegurl"
        );

        res.setHeader(
            "Cache-Control",
            "public, max-age=3600"
        );

        res.send(playlist);

    } catch (error) {

        console.error(
            "[HLS MASTER]",
            error.message
        );

        res.status(500).json({

            success: false,

            message:
                "Failed to retrieve master playlist."

        });
    }
}


);

// ============================================================
// 2. MEDIA PLAYLIST
// GET /api/videos/:videoUUID/hls/media.m3u8
// ============================================================

router.get(
    "/videos/:videoUUID/hls/media.m3u8",
    async (req, res) => {


    try {

        const { videoUUID } = req.params;

        const playlist =
            await getMediaPlaylist(videoUUID);

        res.setHeader(
            "Content-Type",
            "application/vnd.apple.mpegurl"
        );

        res.setHeader(
            "Cache-Control",
            "public, max-age=3600"
        );

        res.send(playlist);

    } catch (error) {

        console.error(
            "[HLS MEDIA]",
            error.message
        );

        res.status(500).json({

            success: false,

            message:
                "Failed to retrieve media playlist."

        });
    }
}


);

// ============================================================
// 3. VIDEO STREAMING WITH HTTP RANGE SUPPORT
// GET /api/videos/:videoUUID/hls/video.mp4
// ============================================================

router.get(
    "/videos/:videoUUID/hls/video.mp4",
    async (req, res) => {

        
    try {

        const { videoUUID } = req.params;

        console.log(
            `\n[HLS STREAM] Video UUID: ${ videoUUID } `
        );

        // Get Google Drive video file ID

        const assets =
            getVideoAssets(videoUUID);

        const videoFileId =
            assets.videoFileId;


        // Get video file size

        const metadata =
            await getFileMetadata(videoFileId);

        const fileSize =
            Number(metadata.size);


        // Read incoming Range header

        const range =
            req.headers.range;


        console.log(
            "[HLS STREAM] Range:",
            range || "Full file request"
        );


        // Request video data from Google Drive

        const driveResponse =
            await streamFileFromDrive(
                videoFileId,
                range
            );


        // Forward HTTP status

        res.status(
            driveResponse.status
        );


        // Forward important headers

        res.setHeader(
            "Content-Type",
            "video/mp4"
        );

        res.setHeader(
            "Accept-Ranges",
            "bytes"
        );


        const contentLength =
            driveResponse.headers.get(
                "content-length"
            );

        const contentRange =
            driveResponse.headers.get(
                "content-range"
            );


        if (contentLength) {

            res.setHeader(
                "Content-Length",
                contentLength
            );

        }


        if (contentRange) {

            res.setHeader(
                "Content-Range",
                contentRange
            );

        }


        // Ensure range response is handled correctly

        if (driveResponse.status === 206) {

            console.log(
                "[HLS STREAM] Partial content response (206)"
            );

        } else {

            res.setHeader(
                "Content-Length",
                fileSize
            );

        }


        // Convert Web ReadableStream to Node.js stream

        const nodeStream =
            Readable.fromWeb(
                driveResponse.body
            );


        // Stream data directly to client

        nodeStream.pipe(res);


        // Handle stream errors

        nodeStream.on(
            "error",
            (error) => {

                console.error(
                    "[HLS STREAM ERROR]",
                    error.message
                );

                if (!res.headersSent) {

                    res.status(500).json({

                        success: false,

                        message:
                            "Video streaming failed."

                    });

                } else {

                    res.destroy(error);

                }

            }
        );


    } catch (error) {

        console.error(
            "[HLS VIDEO]",
            error.message
        );

        if (!res.headersSent) {

            res.status(500).json({

                success: false,

                message:
                    "Unable to stream video."

            });

        }

    }
}


);

module.exports = router;

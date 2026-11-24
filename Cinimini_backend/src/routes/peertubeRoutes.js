const {
    startHLSProcessing,
    getHLSProcessingStatus
} = require("../services/hlsProcessingService");

const express = require("express");
const fs = require("fs");

const router = express.Router();

const {
    uploadVideo
} = require("../services/peertubeService");

const {
    uploadVideoMiddleware
} = require("../middleware/uploadMiddleware");


// ============================================================
// Upload video to PeerTube
// ============================================================

router.post(

    "/peertube/upload",

    uploadVideoMiddleware.single("video"),

    async (req, res) => {

        try {

            // ------------------------------------------------
            // Check uploaded file
            // ------------------------------------------------

            if (!req.file) {

                return res.status(400).json({
                    success: false,
                    message: "Video file is required."
                });

            }


            console.log("\n==========================================");
            console.log("🎬 CINIMINI VIDEO UPLOAD STARTED");
            console.log("==========================================");

            console.log("📁 Temporary file:");
            console.log(req.file.path);


            // ------------------------------------------------
            // Read form fields
            // ------------------------------------------------

            const {

                name,
                title,
                description,
                category,
                privacy

            } = req.body;


            // ------------------------------------------------
            // Determine video title
            // ------------------------------------------------

            const videoTitle =

                title ||
                name ||
                "Cinimini Video";


            // ------------------------------------------------
            // Upload to PeerTube
            // ------------------------------------------------

            console.log("\n⬆️ Uploading video to PeerTube...");

            const result = await uploadVideo({

                filePath:
                    req.file.path,

                fileName:
                    req.file.originalname,

                mimeType:
                    req.file.mimetype,

                title:
                    videoTitle,

                description:
                    description || "",

                category:
                    category
                        ? Number(category)
                        : 10,

                waitTranscoding:
                    false

            });


            console.log("✅ PeerTube upload successful.");

            console.log("PeerTube UUID:");
            console.log(result.peertube.uuid);


            // ============================================================
            // START BACKGROUND HLS PROCESSING
            // ============================================================

            console.log("\n🚀 Starting background HLS processing...");

            startHLSProcessing(result.peertube.uuid);


            // ------------------------------------------------
            // Success response
            // ------------------------------------------------

            return res.status(200).json({

                success: true,

                message:
                    "Video uploaded successfully to PeerTube.",

                video:
                    result.peertube

            });


        } catch (error) {

            console.error(
                "\n❌ PeerTube Upload Error:"
            );

            console.error(error);


            return res.status(
                error.status || 500
            ).json({

                success: false,

                message:
                    "Failed to upload video to PeerTube.",

                error:
                    error.message

            });


        } finally {

            // ------------------------------------------------
            // Delete temporary uploaded file
            // ------------------------------------------------

            if (
                req.file &&
                req.file.path
            ) {

                try {

                    if (
                        fs.existsSync(
                            req.file.path
                        )
                    ) {

                        fs.unlinkSync(
                            req.file.path
                        );

                        console.log(
                            "\n🗑️ Temporary upload file deleted:"
                        );

                        console.log(
                            req.file.path
                        );

                    }

                } catch (cleanupError) {

                    console.error(
                        "\n⚠️ Failed to delete temporary file:"
                    );

                    console.error(
                        cleanupError.message
                    );

                }

            }


            console.log(
                "\n=========================================="
            );

            console.log(
                "🏁 CINIMINI UPLOAD REQUEST COMPLETED"
            );

            console.log(
                "==========================================\n"
            );

        }

    }

);

// ============================================================
// CHECK HLS PROCESSING STATUS
// ============================================================

router.get(
    "/peertube/processing-status/:videoUUID",
    (req, res) => {

        try {

            const {
                videoUUID
            } = req.params;


            const status =
                getHLSProcessingStatus(videoUUID);


            return res.status(200).json(status);


        } catch (error) {

            console.error(
                "❌ Processing Status Error:",
                error
            );


            return res.status(500).json({

                success: false,

                message:
                    "Failed to retrieve HLS processing status.",

                error: error.message

            });

        }

    }
);


module.exports = router;
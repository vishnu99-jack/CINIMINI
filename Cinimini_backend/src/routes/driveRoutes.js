const express = require("express");
const multer = require("multer");
const path = require("path");
const fs = require("fs");

const {
    getStorageFolderId,
    testDriveAuthentication,
    uploadFile
} = require("../services/driveService");

const {
    streamDriveVideo
} = require("../services/videoStreamService");

const router = express.Router();

// ============================================================
// Local upload storage
// ============================================================

const uploadDirectory = path.join(
    process.cwd(),
    "uploads"
);

if (!fs.existsSync(uploadDirectory)) {

    fs.mkdirSync(
        uploadDirectory,
        {
            recursive: true
        }
    );
}

const upload = multer({
    dest: uploadDirectory
});

// ============================================================
// Stream video from Google Drive
// ============================================================

router.get(
    "/video/:fileId/stream",
    async (req, res) => {

        const fileId =
            req.params.fileId;

        const range =
            req.headers.range || null;

        console.log(
            `\n[VIDEO STREAM] Request for: ${fileId}`
        );

        console.log(
            `[VIDEO STREAM] Range: ${range || "none"
            }`
        );

        try {

            await streamDriveVideo(
                fileId,
                range,
                res
            );

        } catch (error) {

            console.error(
                "\n[VIDEO STREAM ERROR]",
                error
            );

            if (!res.headersSent) {

                res.status(500).json({

                    success: false,

                    error:
                        error.message

                });

            } else {

                res.end();

            }
        }
    }
);

// ============================================================
// Test authentication + storage folder
// ============================================================

router.get(
    "/drive/test",
    async (req, res) => {

        try {

            // ------------------------------------------------
            // Test Google authentication
            // ------------------------------------------------

            const authResult =
                await testDriveAuthentication();

            // ------------------------------------------------
            // Find or create CiniminiStorage
            // ------------------------------------------------

            const folderId =
                await getStorageFolderId();

            // ------------------------------------------------
            // Response
            // ------------------------------------------------

            res.json({

                success: true,

                message:
                    "Google Drive authentication and storage folder access successful.",

                user:
                    authResult.user,

                folder: {

                    name:
                        "CiniminiStorage",

                    id:
                        folderId

                }

            });

        } catch (error) {

            console.error(
                "[DRIVE TEST ERROR]",
                error
            );

            res.status(500).json({

                success: false,

                error:
                    error.message

            });

        }
    }
);

// ============================================================
// Upload video to Google Drive
// ============================================================

router.post(
    "/drive/upload",
    upload.single("video"),

    async (req, res) => {

        let uploadedPath = null;

        try {

            // ------------------------------------------------
            // Check uploaded file
            // ------------------------------------------------

            if (!req.file) {

                return res.status(400).json({

                    success: false,

                    error:
                        "No video uploaded."

                });

            }

            // ------------------------------------------------
            // Temporary local file created by Multer
            // ------------------------------------------------

            uploadedPath =
                req.file.path;

            console.log(
                "\n[UPLOAD] Received file:",
                req.file.originalname
            );

            console.log(
                "[UPLOAD] MIME type:",
                req.file.mimetype
            );

            console.log(
                "[UPLOAD] Temporary path:",
                uploadedPath
            );

            console.log(
                "[UPLOAD] Size:",
                req.file.size,
                "bytes"
            );

            // ------------------------------------------------
            // Upload to Google Drive
            // ------------------------------------------------

            const result =
                await uploadFile(
                    uploadedPath,
                    req.file.originalname,
                    req.file.mimetype
                );

            // ------------------------------------------------
            // Response
            // ------------------------------------------------

            res.json({

                success: true,

                message:
                    "Video uploaded to Google Drive.",

                file:
                    result

            });

        } catch (error) {

            console.error(
                "\n[UPLOAD ERROR]",
                error
            );

            if (!res.headersSent) {

                res.status(500).json({

                    success: false,

                    error:
                        error.message

                });

            }

        } finally {

            // ------------------------------------------------
            // Delete temporary local file
            // ------------------------------------------------

            if (
                uploadedPath &&
                fs.existsSync(uploadedPath)
            ) {

                try {

                    fs.unlinkSync(
                        uploadedPath
                    );

                    console.log(
                        "[UPLOAD] Temporary file deleted."
                    );

                } catch (cleanupError) {

                    console.error(
                        "[UPLOAD] Failed to delete temporary file:",
                        cleanupError
                    );

                }
            }
        }
    }
);

// ============================================================
// Export router
// ============================================================

module.exports = router;
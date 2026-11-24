const fs = require("fs");

const {
    uploadVideo
} = require("../services/peertubeService");


// ============================================================
// Upload video to PeerTube
// ============================================================

async function uploadToPeerTube(req, res) {

    let uploadedFile = null;

    try {

        // ----------------------------------------------------
        // Validate file
        // ----------------------------------------------------

        if (!req.file) {

            return res.status(400).json({
                success: false,
                message: "Video file is required."
            });
        }

        uploadedFile = req.file;


        // ----------------------------------------------------
        // Get metadata
        // ----------------------------------------------------

        const title =
            req.body.title ||
            req.file.originalname
                .replace(/\.[^/.]+$/, "");

        const description =
            req.body.description || "";


        console.log(
            `Uploading "${req.file.originalname}" to PeerTube...`
        );


        // ----------------------------------------------------
        // Upload to PeerTube
        // ----------------------------------------------------

        const result = await uploadVideo({

            filePath: req.file.path,

            originalName:
                req.file.originalname,

            title,

            description
        });


        // ----------------------------------------------------
        // Cleanup temporary file
        // ----------------------------------------------------

        try {

            fs.unlinkSync(
                req.file.path
            );

        } catch (cleanupError) {

            console.warn(
                "Could not remove temporary upload file:",
                cleanupError.message
            );
        }


        // ----------------------------------------------------
        // Response
        // ----------------------------------------------------

        return res.status(200).json({

            success: true,

            message:
                "Video uploaded to PeerTube successfully.",

            video: result.video || result

        });

    } catch (error) {

        console.error(
            "PeerTube upload failed:"
        );

        console.error(
            error.response?.data ||
            error.message
        );


        // Cleanup if upload failed

        if (
            uploadedFile &&
            uploadedFile.path
        ) {

            try {

                fs.unlinkSync(
                    uploadedFile.path
                );

            } catch (_) { }
        }


        return res.status(
            error.response?.status || 500
        ).json({

            success: false,

            message:
                "Failed to upload video to PeerTube.",

            error:
                error.response?.data ||
                error.message

        });
    }
}


module.exports = {
    uploadToPeerTube
};
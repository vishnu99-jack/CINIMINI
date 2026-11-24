require("dotenv").config();

const path = require("path");

const {
    uploadVideo
} = require("./src/services/peertubeService");


async function testPeerTubeUpload() {

    try {

        console.log("\n=================================");
        console.log("     PEERTUBE VIDEO UPLOAD TEST");
        console.log("=================================\n");


        // =========================================
        // IMPORTANT:
        // Change this to your actual test video path
        // =========================================

        const videoPath = path.join(
            __dirname,
            "test-video.mp4"
        );


        console.log("📁 Video path:");

        console.log(videoPath);


        console.log("\n⬆️ Uploading video to PeerTube...\n");


        const result = await uploadVideo({

            filePath: videoPath,

            fileName: "test-video.mp4",

            mimeType: "video/mp4",

            title: "Cinimini Integration Test",

            description:
                "Testing Cinimini Backend to PeerTube video upload integration.",

            category: 10,

            waitTranscoding: false
        });


        console.log("=================================");

        console.log("✅ VIDEO UPLOAD SUCCESSFUL");

        console.log("=================================\n");


        console.log("PeerTube ID:");

        console.log(result.peertube.id);


        console.log("\nPeerTube UUID:");

        console.log(result.peertube.uuid);


        console.log("\nWatch URL:");

        console.log(result.peertube.watchUrl);


        console.log("\n=================================\n");


    } catch (error) {

        console.error("\n=================================");

        console.error("❌ VIDEO UPLOAD FAILED");

        console.error("=================================\n");


        console.error(
            error.message
        );


        if (error.response) {

            console.error(
                "\nPeerTube Response:"
            );

            console.error(
                JSON.stringify(
                    error.response,
                    null,
                    2
                )
            );

        }

    }

}


testPeerTubeUpload();
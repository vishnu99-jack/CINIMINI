
const {
    checkVideoStatus
} = require("./peertubeStatusService");

const {
    transferHLSAssetsToDrive
} = require("./hlsTransferService");


// ============================================================
// CONFIGURATION
// ============================================================

const POLL_INTERVAL_MS = 15000; // Check every 15 seconds

const MAX_ATTEMPTS = 120; // Maximum 30 minutes

// Stores processing information temporarily in memory.
const processingJobs = new Map();


// ============================================================
// START HLS PROCESSING
// ============================================================

async function startHLSProcessing(videoUUID) {

    // Prevent duplicate processing.
    if (processingJobs.has(videoUUID)) {

        console.log(
            `⚠️ HLS processing already started: ${ videoUUID } `
        );

        return processingJobs.get(videoUUID);
    }


    // Initial processing status.
    const job = {
        videoUUID,

        status: "PROCESSING",

        attempts: 0,

        startedAt: new Date().toISOString(),

        completedAt: null,

        driveAssets: null,

        error: null
    };


    processingJobs.set(videoUUID, job);


    console.log("\n==========================================");
    console.log("🎬 CINIMINI HLS PROCESSING STARTED");
    console.log("==========================================");

    console.log("Video UUID:", videoUUID);


    // Start background processing.
    processHLSVideo(videoUUID, job);


    return job;
}


// ============================================================
// PROCESS VIDEO IN BACKGROUND
// ============================================================

async function processHLSVideo(videoUUID, job) {

    try {

        while (job.attempts < MAX_ATTEMPTS) {

            job.attempts++;


            console.log(
                `\n⏳ Checking PeerTube processing...`
            );

            console.log(
                `Attempt: ${ job.attempts }/${MAX_ATTEMPTS}`
            );


// ----------------------------------------------------
// CHECK PEERTUBE STATUS
// ----------------------------------------------------

const status = await checkVideoStatus(videoUUID);


console.log(
    "PeerTube State:",
    status.processing.stateLabel
);


// ----------------------------------------------------
// CHECK WHETHER HLS IS READY
// ----------------------------------------------------

if (
    status.processing.completed &&
    status.hls.available
) {

    console.log(
        "\n✅ PeerTube transcoding completed."
    );


    job.status = "TRANSFERRING";


    // ------------------------------------------------
    // TRANSFER HLS ASSETS TO GOOGLE DRIVE
    // ------------------------------------------------

    console.log(
        "\n☁️ Transferring HLS assets to Google Drive..."
    );


    const transferResult =
        await transferHLSAssetsToDrive(videoUUID);


    job.driveAssets = transferResult;


    // ------------------------------------------------
    // CHECK TRANSFER RESULT
    // ------------------------------------------------

    if (transferResult.success) {

        job.status = "COMPLETED";

        job.completedAt =
            new Date().toISOString();


        console.log(
            "\n🎉 HLS PROCESSING COMPLETED SUCCESSFULLY!"
        );

    } else {

        job.status = "FAILED";

        job.error =
            transferResult.message ||
            "Google Drive HLS transfer failed.";


        console.error(
            "\n❌ HLS transfer failed."
        );

    }


    return;

}


// ----------------------------------------------------
// WAIT BEFORE NEXT CHECK
// ----------------------------------------------------

console.log(
    "⏱️ HLS is not ready. Waiting..."
);


await new Promise(resolve => {

    setTimeout(
        resolve,
        POLL_INTERVAL_MS
    );

});

        }


// ====================================================
// MAXIMUM ATTEMPTS REACHED
// ====================================================

job.status = "TIMEOUT";

job.error =
    "PeerTube transcoding did not complete within the expected time.";


console.error(
    "\n⏰ HLS PROCESSING TIMEOUT"
);


    } catch (error) {

    console.error(
        "\n❌ HLS Processing Error:"
    );

    console.error(error);


    job.status = "FAILED";

    job.error = error.message;

}

}


// ============================================================
// GET PROCESSING STATUS
// ============================================================

function getHLSProcessingStatus(videoUUID) {

    const job = processingJobs.get(videoUUID);


    if (!job) {

        return {
            success: false,

            message:
                "No HLS processing job found for this video.",

            videoUUID
        };

    }


    return {

        success: true,

        ...job

    };

}


// ============================================================
// EXPORTS
// ============================================================

module.exports = {

    startHLSProcessing,

    getHLSProcessingStatus

};


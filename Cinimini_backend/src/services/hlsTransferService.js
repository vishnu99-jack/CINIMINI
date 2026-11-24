const fs = require("fs");
const path = require("path");
const os = require("os");
const { pipeline } = require("stream/promises");
const { Readable } = require("stream");
const {
    checkVideoStatus
} = require("./peertubeStatusService");
const {
    uploadFile
} = require("./driveService");
// ==========================================
// CONFIGURATION
// ==========================================
const TEMP_DIRECTORY = path.join(
    os.tmpdir(),
    "cinimini-hls-transfer"
);
// ==========================================
// INITIALIZATION
// ==========================================
async function initializeTempDirectory() {
    await fs.promises.mkdir(
        TEMP_DIRECTORY,
        { recursive: true }
    );
}


// ==========================================
// DOWNLOAD HLS ASSET FROM PEERTUBE
// ==========================================

async function downloadHLSAsset(
    assetUrl,
    destinationPath
) {

    console.log("\n[HLS TRANSFER] Downloading asset:");
    console.log(assetUrl);


    // STEP 1: Get PeerTube access token

    const accessToken =
        await require("./peertubeService").getAccessToken();


    // STEP 2: Download with authentication

    const response = await fetch(
        assetUrl,
        {
            method: "GET",

            headers: {
                Authorization: `Bearer ${ accessToken } `
            }
        }
    );


    // STEP 3: Validate response

    if (!response.ok) {

        throw new Error(
            `HLS asset download failed. ` +
            `HTTP Status: ${ response.status } `
        );

    }


    if (!response.body) {

        throw new Error(
            "HLS asset download returned an empty response."
        );

    }


    // STEP 4: Stream response to temporary file

    await pipeline(
        Readable.fromWeb(response.body),
        fs.createWriteStream(destinationPath)
    );


    // STEP 5: Get downloaded file information

    const fileStats =
        await fs.promises.stat(destinationPath);


    console.log(
        "[HLS TRANSFER] Download completed."
    );

    console.log(
        "[HLS TRANSFER] File size:",
        fileStats.size,
        "bytes"
    );


    return {

        filePath: destinationPath,

        fileSize: fileStats.size

    };

}




// ==========================================
// UPLOAD HLS ASSET TO GOOGLE DRIVE
// ==========================================

async function uploadHLSAssetToDrive(
    assetUrl,
    assetType,
    videoUUID,
    resolution = null
) {

    const originalUrl =
        new URL(assetUrl);


    const originalFileName =
        path.basename(originalUrl.pathname);


    let driveFileName =
        originalFileName;


    if (assetType === "master_playlist") {

        driveFileName =
            `${ videoUUID } -master.m3u8`;

    }


    else if (assetType === "media_playlist") {

        driveFileName =
            `${ videoUUID } -${ resolution }.m3u8`;

    }


    else if (assetType === "fragmented_mp4") {

        driveFileName =
            `${ videoUUID } -${ resolution } -fragmented.mp4`;

    }


    const temporaryFilePath =
        path.join(
            TEMP_DIRECTORY,
            `${ Date.now() } -${ driveFileName } `
        );


    try {

        // STEP 1: Download the asset from PeerTube

        const downloadResult =
            await downloadHLSAsset(
                assetUrl,
                temporaryFilePath
            );


        // STEP 2: Determine MIME type

        let mimeType =
            "application/octet-stream";


        if (
            driveFileName.endsWith(".m3u8")
        ) {

            mimeType =
                "application/vnd.apple.mpegurl";

        }


        else if (
            driveFileName.endsWith(".mp4")
        ) {

            mimeType =
                "video/mp4";

        }


        // STEP 3: Upload to Google Drive

        console.log(
            "\n[HLS TRANSFER] Uploading asset to Drive..."
        );

        console.log(
            "[HLS TRANSFER] Filename:",
            driveFileName
        );


        const driveResult =
            await uploadFile(
                temporaryFilePath,
                driveFileName,
                mimeType
            );


        console.log(
            "[HLS TRANSFER] Drive upload successful."
        );


        // STEP 4: Return asset information

        return {

            success: true,

            assetType,

            resolution,

            fileName: driveResult.name,

            driveFileId: driveResult.id,

            mimeType,

            fileSize: downloadResult.fileSize

        };


    }

    finally {

        // STEP 5: Delete temporary downloaded file

        if (
            fs.existsSync(temporaryFilePath)
        ) {

            await fs.promises.unlink(
                temporaryFilePath
            );

            console.log(
                "[HLS TRANSFER] Temporary file deleted."
            );

        }

    }

}


// ==========================================
// MAIN HLS TRANSFER FUNCTION
// ==========================================

async function transferHLSAssetsToDrive(
    videoUUID
) {

    if (!videoUUID) {

        throw new Error(
            "PeerTube video UUID is required."
        );

    }


    console.log("\n==========================================");

    console.log(
        "       CINIMINI HLS TRANSFER"
    );

    console.log("==========================================");


    console.log(
        "[HLS TRANSFER] Video UUID:",
        videoUUID
    );


    await initializeTempDirectory();


    // ======================================
    // STEP 1: CHECK PEERTUBE STATUS
    // ======================================

    console.log(
        "\n[HLS TRANSFER] Checking PeerTube status..."
    );


    const status =
        await checkVideoStatus(videoUUID);


    if (!status.success) {

        throw new Error(
            "Unable to retrieve PeerTube video status."
        );

    }


    // ======================================
    // STEP 2: CHECK PROCESSING COMPLETION
    // ======================================

    if (
        !status.processing ||
        !status.processing.completed
    ) {

        console.log(
            "[HLS TRANSFER] Video is still processing."
        );


        return {

            success: false,

            status: "PROCESSING",

            message:
                "PeerTube video transcoding is not completed.",

            videoUUID,

            processing: status.processing

        };

    }


    // ======================================
    // STEP 3: CHECK HLS AVAILABILITY
    // ======================================

    if (
        !status.hls ||
        !status.hls.available
    ) {

        console.log(
            "[HLS TRANSFER] HLS assets are not available yet."
        );


        return {

            success: false,

            status: "HLS_NOT_AVAILABLE",

            message:
                "Video processing completed, but HLS assets are not available.",

            videoUUID,

            processing: status.processing

        };

    }


    console.log(
        "\n[HLS TRANSFER] HLS assets are available."
    );


    // ======================================
    // STEP 4: COLLECT HLS ASSET URLS
    // ======================================

    const hlsPlaylists =
        status.hls.playlists || [];


    const hlsFiles =
        status.hls.files || [];


    const assetsToTransfer = [];


    // Master playlists

    for (const playlist of hlsPlaylists) {

        if (
            playlist.masterPlaylistUrl
        ) {

            assetsToTransfer.push({

                url: playlist.masterPlaylistUrl,

                type: "master_playlist"

            });

        }

    }


    // Resolution-specific playlists and fragmented MP4 files

    for (const file of hlsFiles) {

        const resolution =
            file.resolution ||
            `${ file.height } p`;


        if (file.playlistUrl) {

            assetsToTransfer.push({

                url: file.playlistUrl,

                type: "media_playlist",

                resolution

            });

        }


        if (file.fileUrl) {

            assetsToTransfer.push({

                url: file.fileUrl,

                type: "fragmented_mp4",

                resolution

            });

        }

    }


    if (
        assetsToTransfer.length === 0
    ) {

        throw new Error(
            "No transferable HLS assets were found."
        );

    }


    console.log(
        "\n[HLS TRANSFER] Assets identified:",
        assetsToTransfer.length
    );


    // ======================================
    // STEP 5: TRANSFER ASSETS TO DRIVE
    // ======================================

    const transferredAssets = [];

    const failedAssets = [];


    for (
        const asset of assetsToTransfer
    ) {

        try {

            const result =
                await uploadHLSAssetToDrive(
                    asset.url,
                    asset.type,
                    videoUUID,
                    asset.resolution
                );


            transferredAssets.push(
                {

                    ...result,

                    sourceUrl: asset.url

                });


        }

        catch (error) {

            console.error(
                "\n[HLS TRANSFER] Asset transfer failed:"
            );

            console.error(
                asset.url
            );

            console.error(
                error.message
            );


            failedAssets.push(
            {

                assetType: asset.type,

                resolution: asset.resolution,

                sourceUrl: asset.url,

                error: error.message

            });

        }

    }


    // ======================================
    // STEP 6: FINAL RESULT
    // ======================================

    const allAssetsTransferred =
        failedAssets.length === 0 &&
        transferredAssets.length === assetsToTransfer.length;


    console.log("\n==========================================");

    console.log(
        "       HLS TRANSFER SUMMARY"
    );

    console.log("==========================================");


    console.log(
        "Video UUID:",
        videoUUID
    );


    console.log(
        "Total assets:",
        assetsToTransfer.length
    );


    console.log(
        "Transferred:",
        transferredAssets.length
    );


    console.log(
        "Failed:",
        failedAssets.length
    );


    console.log(
        "Status:",
        allAssetsTransferred
            ? "SUCCESS"
            : "PARTIAL / FAILED"
    );


    console.log("==========================================\n");


    return {

        success: allAssetsTransferred,

        status:
            allAssetsTransferred
                ? "COMPLETED"
                : "PARTIAL",

        videoUUID,

        processing: status.processing,

        totalAssets: assetsToTransfer.length,

        transferredCount:
            transferredAssets.length,

        failedCount:
            failedAssets.length,

        assets: transferredAssets,

        failures: failedAssets

    };

}


// ==========================================
// EXPORTS
// ==========================================

module.exports = {

    transferHLSAssetsToDrive,

    downloadHLSAsset,

    uploadHLSAssetToDrive

};


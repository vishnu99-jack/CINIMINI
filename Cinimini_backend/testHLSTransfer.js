require("dotenv").config();
const {
    transferHLSAssetsToDrive
} = require("./src/services/hlsTransferService");


// ==========================================
// TEST CONFIGURATION
// ==========================================

const VIDEO_UUID =
    "77020e45-412e-4ae5-915a-33b3f5a9cf50";


// ==========================================
// RUN HLS TRANSFER TEST
// ==========================================

async function testHLSTransfer() {

    console.log("\n==========================================");

    console.log("       CINIMINI HLS TRANSFER TEST");

    console.log("==========================================");


    try {

        const result =
            await transferHLSAssetsToDrive(
                VIDEO_UUID
            );


        console.log("\n==========================================");

        console.log("       FINAL TEST RESULT");

        console.log("==========================================");


        console.log(
            JSON.stringify(
                result,
                null,
                2
            )
        );


        if (result.success) {

            console.log(
                "\nSUCCESS: All HLS assets transferred to Google Drive!"
            );

        }

        else {

            console.log(
                "\nINCOMPLETE: HLS transfer requires further investigation."
            );

        }

    }

    catch (error) {

        console.error(
            "\nHLS TRANSFER TEST FAILED!"
        );

        console.error(
            error.message
        );

    }

}


// ==========================================
// EXECUTE
// ==========================================

testHLSTransfer();


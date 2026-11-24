require("dotenv").config();

const {
    getVideoDetails,
    checkVideoStatus
} = require("./src/services/peertubeStatusService");


async function test() {

    console.log(
        "\n================================="
    );

    console.log(
        "   PEERTUBE STATUS TEST"
    );

    console.log(
        "=================================\n"
    );


    const videoUUID =
        "77020e45-412e-4ae5-915a-33b3f5a9cf50";


    try {

        // ====================================================
        // Get complete raw PeerTube response
        // ====================================================

        const video =
            await getVideoDetails(videoUUID);


        console.log(
            "\n================================="
        );

        console.log(
            "RAW STREAMING PLAYLISTS"
        );

        console.log(
            "=================================\n"
        );


        console.dir(
            video.streamingPlaylists,
            {
                depth: null
            }
        );


        // ====================================================
        // Run our status analysis
        // ====================================================

        const result =
            await checkVideoStatus(
                videoUUID
            );


        console.log(
            "\n================================="
        );

        console.log(
            "ANALYSED RESULT"
        );

        console.log(
            "=================================\n"
        );


        console.dir(
            result,
            {
                depth: null
            }
        );


    } catch (error) {

        console.error(
            "\n❌ TEST FAILED"
        );

        console.error(
            error.message
        );

    }


    console.log(
        "\n=================================\n"
    );

}


test();
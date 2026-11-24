
require("dotenv").config();

const {
    getMasterPlaylist,
    getMediaPlaylist
} = require("./src/services/hlsStreamingService");


// ============================================================
// TEST HLS PLAYLIST RESOLVER
// ============================================================

async function testHLSResolver() {

    try {

        const videoUUID =
            "e9713faa-0591-460e-a16f-d51063de1dd1";


        console.log("\n==========================================");
        console.log("   CINIMINI HLS RESOLVER TEST");
        console.log("==========================================");


        // ----------------------------------------------------
        // TEST MASTER PLAYLIST
        // ----------------------------------------------------

        console.log("\n🎬 MASTER PLAYLIST");

        const masterPlaylist =
            await getMasterPlaylist(videoUUID);

        console.log("\n" + masterPlaylist);


        // ----------------------------------------------------
        // TEST MEDIA PLAYLIST
        // ----------------------------------------------------

        console.log("\n🎬 MEDIA PLAYLIST");

        const mediaPlaylist =
            await getMediaPlaylist(videoUUID);

        console.log("\n" + mediaPlaylist);


        console.log("\n==========================================");
        console.log("   TEST COMPLETED SUCCESSFULLY");
        console.log("==========================================");


    } catch (error) {

        console.error(
            "\n❌ HLS Resolver Test Failed:"
        );

        console.error(error);

    }

}


// ============================================================
// RUN TEST
// ============================================================

testHLSResolver();

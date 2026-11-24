
require("dotenv").config();

const {
    readHLSPlaylist
} = require("./src/services/hlsStreamingService");


// ============================================================
// TEST HLS PLAYLIST READING
// ============================================================

async function testHLSPlaylist() {

    try {

        console.log("\n==========================================");
        console.log("   CINIMINI HLS PLAYLIST TEST");
        console.log("==========================================");


        // Master playlist Google Drive file ID
        const mediaPlaylistId =
            "1VUWkVfZBCuH1SH9GUCfljeBWToQFJ5bJ";

        const playlist =
            await readHLSPlaylist(mediaPlaylistId);


        console.log("\n==========================================");
        console.log("   MASTER PLAYLIST CONTENT");
        console.log("==========================================\n");


        console.log(playlist);


        console.log("\n==========================================");
        console.log("   TEST SUCCESSFUL");
        console.log("==========================================");


    } catch (error) {

        console.error("\n❌ HLS Playlist Test Failed:");

        console.error(error);

    }

}


// ============================================================
// RUN TEST
// ============================================================

testHLSPlaylist();

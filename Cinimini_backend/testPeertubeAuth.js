require("dotenv").config();

const {
    getOAuthClient,
    getAccessToken
} = require("./src/services/peertubeService");


async function testPeerTubeAuth() {

    try {

        console.log("\n=================================");
        console.log("   PEERTUBE AUTHENTICATION TEST");
        console.log("=================================\n");


        // --------------------------------------
        // Step 1: OAuth Client
        // --------------------------------------

        console.log("1️⃣ Getting OAuth client...");

        const client = await getOAuthClient();

        console.log("✅ OAuth Client received");

        console.log({
            client_id: client.client_id,
            client_secret: client.client_secret
                ? "RECEIVED"
                : "MISSING"
        });


        // --------------------------------------
        // Step 2: Access Token
        // --------------------------------------

        console.log("\n2️⃣ Getting access token...");

        const token = await getAccessToken();

        console.log("✅ Authentication successful!");

        console.log(
            "Token preview:",
            token.substring(0, 20) + "..."
        );


        console.log("\n=================================");
        console.log("      TEST COMPLETED SUCCESSFULLY");
        console.log("=================================\n");


    } catch (error) {

        console.error("\n❌ PEERTUBE AUTH FAILED\n");

        console.error(
            error.message
        );

        if (error.response) {

            console.error(
                "\nPeerTube Response:"
            );

            console.error(
                error.response
            );
        }

    }

}


testPeerTubeAuth();
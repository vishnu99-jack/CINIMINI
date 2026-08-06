const fs = require("fs");
const path = require("path");
const { google } = require("googleapis");

const credentials = require("./client_secret.json");
const token = require("./token.json");

// Desktop OAuth credentials
const { client_id, client_secret, redirect_uris } = credentials.installed;

const oauth2Client = new google.auth.OAuth2(
    client_id,
    client_secret,
    redirect_uris[0]
);

// Load previously generated tokens
oauth2Client.setCredentials(token);

const youtube = google.youtube({
    version: "v3",
    auth: oauth2Client,
});

async function uploadVideo() {
    try {
        const videoPath = path.join(__dirname, "Inevitable.mp4");

        console.log("Uploading video...");
        console.log(videoPath);

        const response = await youtube.videos.insert({
            part: ["snippet", "status"],
            requestBody: {
                snippet: {
                    title: "Cinimini POC Upload",
                    description: "Uploaded using Node.js from Cinimini POC",
                    tags: ["Cinimini", "POC", "Flutter"],
                    categoryId: "22", // People & Blogs
                },
                status: {
                    privacyStatus: "unlisted",
                },
            },
            media: {
                body: fs.createReadStream(videoPath),
            },
        });

        const videoId = response.data.id;

        console.log("\n====================================");
        console.log("🎉 Upload Successful!");
        console.log("====================================");

        console.log("Video ID:", videoId);
        console.log("Watch URL:");
        console.log(`https://youtu.be/${videoId}`);
        console.log("Thumbnail:");
        console.log(`https://i.ytimg.com/vi/${videoId}/hqdefault.jpg`);
    } catch (err) {
        console.error("\nUpload Failed!\n");

        if (err.response && err.response.data) {
            console.error(JSON.stringify(err.response.data, null, 2));
        } else {
            console.error(err);
        }
    }
}

uploadVideo();
const fs = require("fs");
const { google } = require("googleapis");



const credentials = require("./client_secret.json");
const token = require("./token.json");

const { client_id, client_secret, redirect_uris } = credentials.installed;

const oauth2Client = new google.auth.OAuth2(
    client_id,
    client_secret,
    redirect_uris[0]
);

oauth2Client.setCredentials(token);

const youtube = google.youtube({
    version: "v3",
    auth: oauth2Client
});

async function uploadVideo(videoPath, title, description) {

    const response = await youtube.videos.insert({

        part: ["snippet", "status"],

        requestBody: {

            snippet: {

                title: title,

                description: description,

                categoryId: "22",

                tags: [
                    "Cinimini",
                    "Short Film"
                ]

            },

            status: {

                privacyStatus: "unlisted"

            }

        },

        media: {

            body: fs.createReadStream(videoPath)

        }

    });

    return {

        videoId: response.data.id,

        watchUrl:
            `https://youtu.be/${response.data.id}`,

        embedUrl:
            `https://www.youtube.com/embed/${response.data.id}`,

        thumbnail:
            `https://i.ytimg.com/vi/${response.data.id}/hqdefault.jpg`

    };

}

module.exports = {

    uploadVideo

};
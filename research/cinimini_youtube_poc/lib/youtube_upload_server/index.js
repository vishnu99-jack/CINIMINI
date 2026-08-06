const express = require("express");
const multer = require("multer");
const { uploadVideo } = require("./youtubeService");

const app = express();

const PORT = 3000;

const upload = multer({
    dest: "uploads/"
});

// Store uploaded files temporarilynpm install open
app.post("/upload", upload.single("video"), async (req, res) => {

    try {

        console.log("========== VIDEO RECEIVED ==========");

        console.log(req.file);

        const result = await uploadVideo(

            req.file.path,

            req.file.originalname,

            "Uploaded from Cinimini"

        );

        res.json({

            success: true,

            message: "Video uploaded successfully!",

            ...result

        });

    } catch (error) {

        console.error(error);

        res.status(500).json({

            success: false,

            message: "Video upload failed.",

            error: error.message

        });

    }

});

try {
    fs.unlinkSync(req.file.path);
    console.log("Temporary file deleted.");
} catch (err) {
    console.error("Failed to delete temporary file:", err);
}

// Home Route
app.get("/", (req, res) => {
    res.send("Hello Cinimini! YouTube Upload Server is Running 🚀");
});

// Upload Route
app.post("/upload", upload.single("video"), (req, res) => {

    console.log("========== VIDEO RECEIVED ==========");

    console.log(req.file);

    res.json({
        success: true,
        message: "Video received successfully!",
        fileName: req.file.originalname,
        size: req.file.size
    });

});

app.listen(PORT, () => {
    console.log(`Server running at http://localhost:${PORT}`);
});
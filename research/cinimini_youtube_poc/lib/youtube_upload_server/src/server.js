const express = require("express");
const multer = require("multer");

const app = express();

const PORT = 3000;

// Store uploaded files temporarily
const upload = multer({
    dest: "uploads/"
});

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
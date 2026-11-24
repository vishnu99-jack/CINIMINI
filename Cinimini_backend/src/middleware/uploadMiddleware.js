const multer = require("multer");
const path = require("path");
const fs = require("fs");


// ============================================================
// Upload Directory
// ============================================================

const uploadDirectory = path.join(
    __dirname,
    "../../uploads"
);


// Create uploads directory automatically

if (!fs.existsSync(uploadDirectory)) {

    fs.mkdirSync(
        uploadDirectory,
        {
            recursive: true
        }
    );

}


// ============================================================
// Multer Storage Configuration
// ============================================================

const storage = multer.diskStorage({

    destination: (req, file, cb) => {

        cb(
            null,
            uploadDirectory
        );

    },


    filename: (req, file, cb) => {

        // Create a unique filename

        const uniqueName =
            `${Date.now()}-${Math.round(Math.random() * 1E9)}`;


        const extension =
            path.extname(file.originalname).toLowerCase();


        cb(
            null,
            `${uniqueName}${extension}`
        );

    }

});


// ============================================================
// File Filter
// ============================================================

const fileFilter = (req, file, cb) => {

    const allowedExtensions = [

        ".mp4",
        ".mov",
        ".avi",
        ".mkv",
        ".webm",
        ".m4v"

    ];


    const extension =
        path.extname(
            file.originalname
        ).toLowerCase();


    console.log("\n==========================================");
    console.log("📁 CINIMINI VIDEO UPLOAD");
    console.log("==========================================");

    console.log(
        "Original Name:",
        file.originalname
    );

    console.log(
        "MIME Type:",
        file.mimetype
    );

    console.log(
        "Extension:",
        extension
    );

    console.log("==========================================\n");


    // Validate by file extension
    //
    // We intentionally do not depend only on MIME type because
    // curl / mobile clients may send different MIME values.

    if (allowedExtensions.includes(extension)) {

        return cb(
            null,
            true
        );

    }


    return cb(
        new Error(
            "Only supported video files are allowed."
        ),
        false
    );

};


// ============================================================
// Multer Configuration
// ============================================================

const uploadVideoMiddleware = multer({

    storage,

    fileFilter,

    limits: {

        // Maximum video upload size: 2 GB

        fileSize:
            2 * 1024 * 1024 * 1024

    }

});


// ============================================================
// Export
// ============================================================

module.exports = {

    uploadVideoMiddleware,

    uploadDirectory

};
require("dotenv").config();

const express = require("express");
const cors = require("cors");
const hlsRoutes = require("./routes/hlsRoutes");
const driveRoutes = require("./routes/driveRoutes");
const peertubeRoutes = require("./routes/peertubeRoutes");


const app = express();

const PORT =
    process.env.PORT || 3000;


// ============================================================
// Middleware
// ============================================================

app.use(cors());

app.use(express.json());



// ============================================================
// Routes
// ============================================================

app.use(
    "/api",
    driveRoutes
);

app.use(
    "/api",
    peertubeRoutes
);

app.use(
    "/api",
    hlsRoutes
);

// ============================================================
// Health check
// ============================================================

app.get(
    "/",
    (req, res) => {

        res.json({

            success: true,

            message:
                "Cinimini Backend is running."

        });
    }
);


// ============================================================
// Start server
// ============================================================

app.listen(

    PORT,

    "0.0.0.0",

    () => {

        console.log(
            "\n=========================================="
        );

        console.log(
            "       CINIMINI BACKEND SERVER"
        );

        console.log(
            "=========================================="
        );

        console.log(
            `Server: http://localhost:${PORT}`
        );

        console.log(
            `Drive:  http://localhost:${PORT}/api/drive/test`
        );

        console.log(
            `PeerTube: http://localhost:${PORT}/api/peertube/upload`
        );

        console.log(
            "==========================================\n"
        );
    }
);
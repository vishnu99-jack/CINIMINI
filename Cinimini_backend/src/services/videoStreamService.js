const { Readable } = require("stream");

const {
    streamFileFromDrive,
    getFileMetadata
} = require("./driveService");

// ============================================================
// Parse HTTP Range header
// ============================================================

function parseRange(rangeHeader, totalSize) {

    if (!rangeHeader) {
        return null;
    }

    if (!rangeHeader.startsWith("bytes=")) {
        return null;
    }

    const rangeValue =
        rangeHeader
            .substring(6)
            .split(",")[0]
            .trim();

    const parts =
        rangeValue.split("-");

    if (parts.length !== 2) {
        return null;
    }

    let start =
        parts[0] === ""
            ? null
            : Number(parts[0]);

    let end =
        parts[1] === ""
            ? null
            : Number(parts[1]);

    // --------------------------------------------------------
    // Suffix range
    // Example: bytes=-500
    // --------------------------------------------------------

    if (start === null) {

        if (
            end === null ||
            Number.isNaN(end)
        ) {
            return null;
        }

        const suffixLength =
            Math.min(end, totalSize);

        start =
            totalSize - suffixLength;

        end =
            totalSize - 1;
    }

    // --------------------------------------------------------
    // Open-ended range
    // Example: bytes=1000-
    // --------------------------------------------------------

    else if (end === null) {

        end =
            totalSize - 1;
    }

    // --------------------------------------------------------
    // Validate
    // --------------------------------------------------------

    if (
        Number.isNaN(start) ||
        Number.isNaN(end)
    ) {
        return null;
    }

    // Clamp end
    if (end >= totalSize) {
        end =
            totalSize - 1;
    }

    // Invalid
    if (
        start < 0 ||
        start >= totalSize ||
        start > end
    ) {
        return {
            invalid: true
        };
    }

    return {
        start,
        end
    };
}

// ============================================================
// Stream video from Google Drive
// ============================================================

async function streamDriveVideo(
    fileId,
    range,
    res
) {

    console.log(
        `\n[VIDEO SERVICE] Streaming file: ${fileId}`
    );

    console.log(
        `[VIDEO SERVICE] Requested range: ${range || "none"
        }`
    );

    // ========================================================
    // Get metadata
    // ========================================================

    const metadata =
        await getFileMetadata(fileId);

    const totalSize =
        Number(metadata.size);

    const mimeType =
        metadata.mimeType || "video/mp4";

    const fileName =
        metadata.name || fileId;

    console.log(
        `[VIDEO SERVICE] File: ${fileName}`
    );

    console.log(
        `[VIDEO SERVICE] MIME: ${mimeType}`
    );

    console.log(
        `[VIDEO SERVICE] Size: ${totalSize} bytes`
    );

    if (
        !Number.isFinite(totalSize) ||
        totalSize <= 0
    ) {

        throw new Error(
            "Google Drive returned an invalid file size."
        );
    }

    // ========================================================
    // Parse range
    // ========================================================

    const requestedRange =
        parseRange(
            range,
            totalSize
        );

    // ========================================================
    // Invalid range
    // ========================================================

    if (
        requestedRange &&
        requestedRange.invalid
    ) {

        console.log(
            "[VIDEO SERVICE] Invalid range."
        );

        res.status(416);

        res.setHeader(
            "Content-Range",
            `bytes */${totalSize}`
        );

        res.setHeader(
            "Accept-Ranges",
            "bytes"
        );

        res.end();

        return;
    }

    // ========================================================
    // Build Drive range
    // ========================================================

    let driveRange = null;

    if (requestedRange) {

        driveRange =
            `bytes=${requestedRange.start}-${requestedRange.end}`;

        console.log(
            `[VIDEO SERVICE] Forwarding range: ${driveRange}`
        );
    }

    // ========================================================
    // Request video from authenticated Drive
    // ========================================================

    const driveResponse =
        await streamFileFromDrive(
            fileId,
            driveRange
        );

    console.log(
        `[VIDEO SERVICE] Drive status: ${driveResponse.status
        }`
    );

    if (!driveResponse.ok) {

        const errorText =
            await driveResponse.text();

        throw new Error(
            `Google Drive returned ${driveResponse.status}: ${errorText}`
        );
    }

    // ========================================================
    // Determine actual response range
    // ========================================================

    let start = 0;
    let end = totalSize - 1;

    if (requestedRange) {

        start =
            requestedRange.start;

        end =
            requestedRange.end;
    }

    // ========================================================
    // Read Drive Content-Range
    // ========================================================

    const driveContentRange =
        driveResponse.headers.get(
            "content-range"
        );

    if (driveContentRange) {

        console.log(
            `[VIDEO SERVICE] Drive Content-Range: ${driveContentRange
            }`
        );

        const match =
            driveContentRange.match(
                /bytes\s+(\d+)-(\d+)\/(\d+|\*)/
            );

        if (match) {

            start =
                Number(match[1]);

            end =
                Number(match[2]);
        }
    }

    // ========================================================
    // Calculate content length
    // ========================================================

    const contentLength =
        end - start + 1;

    // ========================================================
    // Response headers
    // ========================================================

    res.setHeader(
        "Content-Type",
        mimeType
    );

    res.setHeader(
        "Accept-Ranges",
        "bytes"
    );

    res.setHeader(
        "Access-Control-Allow-Origin",
        "*"
    );

    res.setHeader(
        "Access-Control-Expose-Headers",
        "Content-Length, Content-Range, Accept-Ranges"
    );

    res.setHeader(
        "Cache-Control",
        "public, max-age=3600"
    );

    res.setHeader(
        "Content-Length",
        contentLength
    );

    // ========================================================
    // Partial response
    // ========================================================

    if (requestedRange) {

        res.status(206);

        res.setHeader(
            "Content-Range",
            `bytes ${start}-${end}/${totalSize}`
        );

        console.log(
            "[VIDEO SERVICE] Returning 206"
        );

        console.log(
            `[VIDEO SERVICE] Content-Range: bytes ${start
            }-${end}/${totalSize}`
        );

        console.log(
            `[VIDEO SERVICE] Content-Length: ${contentLength
            }`
        );
    }

    // ========================================================
    // Full response
    // ========================================================

    else {

        res.status(200);

        console.log(
            "[VIDEO SERVICE] Returning 200"
        );

        console.log(
            `[VIDEO SERVICE] Content-Length: ${totalSize
            }`
        );
    }

    // ========================================================
    // Stream Drive response
    // ========================================================

    if (!driveResponse.body) {

        throw new Error(
            "Google Drive returned no response body."
        );
    }

    // ========================================================
    // IMPORTANT
    //
    // Google fetch() gives us a Web ReadableStream.
    // Convert it to Node Readable.
    // ========================================================

    const nodeStream =
        Readable.fromWeb(
            driveResponse.body
        );

    // ========================================================
    // Handle client disconnect
    // ========================================================

    res.on(
        "close",
        () => {

            if (!res.writableEnded) {

                console.log(
                    "[VIDEO SERVICE] Client disconnected."
                );

                nodeStream.destroy();
            }
        }
    );

    // ========================================================
    // Stream chunk-by-chunk
    //
    // This is intentionally similar to the original
    // working Cinimini Drive proxy.
    // ========================================================

    for await (
        const chunk of nodeStream
    ) {

        if (res.destroyed) {

            console.log(
                "[VIDEO SERVICE] Response destroyed."
            );

            break;
        }

        res.write(chunk);
    }

    // ========================================================
    // Finish response
    // ========================================================

    if (!res.writableEnded) {

        res.end();
    }

    console.log(
        "[VIDEO SERVICE] Stream completed."
    );
}

// ============================================================
// EXPORT
// ============================================================

module.exports = {
    streamDriveVideo
};
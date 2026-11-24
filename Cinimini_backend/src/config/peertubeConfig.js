const PEERTUBE_URL =
    process.env.PEERTUBE_URL || "http://localhost:9000";

const PEERTUBE_API_URL =
    `${PEERTUBE_URL}/api/v1`;

const PEERTUBE_USERNAME =
    process.env.PEERTUBE_USERNAME;

const PEERTUBE_PASSWORD =
    process.env.PEERTUBE_PASSWORD;

const PEERTUBE_CHANNEL_ID =
    Number(process.env.PEERTUBE_CHANNEL_ID || 1);

module.exports = {
    PEERTUBE_URL,
    PEERTUBE_API_URL,
    PEERTUBE_USERNAME,
    PEERTUBE_PASSWORD,
    PEERTUBE_CHANNEL_ID
};
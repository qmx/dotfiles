module.exports = {
    defaultBrowser: "Brave Browser",
    handlers: [
        {
            match: /^https?:\/\/classroom\.google\.com.*$/,
            browser: "Firefox"
        },
        {
            match: /^https?:\/\/.*\.?google\.com.*$/,
            browser: "Google Chrome"
        },
        {
            match: /^https?:\/\/.*\.?github\.com.*$/,
            browser: "Safari"
        },
        {
            match: /^https?:\/\/.*\.?amazon\.com.*$/,
            browser: "Safari"
        },
        {
            match: /^https?:\/\/.*\.?tailscale\.com.*$/,
            browser: "Google Chrome"
        }
    ]
}
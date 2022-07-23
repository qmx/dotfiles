module.exports = {
    defaultBrowser: "Brave Browser",
    rewrite: [
        {
            match: ({url}) => url.host.endsWith("twitter.com"),
            url: ({url}) => {
                return {
                    ...url,
                    host: "nitter.net"
                }
            }
        }
    ],
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
            match: /^https?:\/\/.*\.?fly\.io.*$/,
            browser: "Safari"
        },
        {
            match: /^https?:\/\/.*\.?tailscale\.com.*$/,
            browser: "Google Chrome"
        },
        {
            match: /^https?:\/\/.*\.?youtu\.be.*$/,
            browser: "Google Chrome"
        }
    ]
}
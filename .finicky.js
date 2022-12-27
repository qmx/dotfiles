const CHROME_DOMAINS = [
  "youtu.be",
  "youtube.com",
  "google.com",
  "goo.gl",
  "tailscale.com",
];

const SAFARI_DOMAINS = ["fly.io", "github.com", "amazon.com"];

module.exports = {
  defaultBrowser: "Brave Browser",
  rewrite: [
    {
      match: ({ url }) => url.host.endsWith("twitter.com"),
      url: ({ url }) => {
        return {
          ...url,
          host: "nitter.net",
        };
      },
    },
  ],
  handlers: [
    {
      match: ({ url }) => {
        for (let domain of CHROME_DOMAINS) {
          if (url.host.endsWith(domain)) {
            return true;
          }
        }
        return false;
      },
      browser: "Google Chrome",
    },
    {
      match: ({ url }) => {
        for (let domain of SAFARI_DOMAINS) {
          if (url.host.endsWith(domain)) {
            return true;
          }
        }
        return false;
      },
      browser: "Safari",
    },
  ],
};

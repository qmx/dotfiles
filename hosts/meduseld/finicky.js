const CHROME_DOMAINS = [
  "amazon.com",
  "goo.gl",
  "google.com",
  "tailscale.com",
  "youtu.be",
  "youtube.com",
  "printables.com",
  "makerworld.com"
];

const BRAVE_DOMAINS = [
  "facebook.com",
  "twitter.com",
  "x.com"
];

const SAFARI_DOMAINS = [
  "apple.com",
  "cursor.sh",
  "cursor.com",
  "fly.io",
  "github.com"
];

module.exports = {
  defaultBrowser: "Brave Browser",
  rewrite: [
    // {
    //   match: ({ url }) => url.host.endsWith("twitter.com") || url.host === "x.com",
    //   url: ({ url }) => {
    //     return {
    //       ...url,
    //       host: "twiiit.com",
    //     };
    //   },
    // },
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
    {
      match: ({ url }) => {
        for (let domain of BRAVE_DOMAINS) {
          if (url.host.endsWith(domain)) {
            return true;
          }
        }
        return false;
      },
      browser: "Brave Browser",
    },
  ],
};

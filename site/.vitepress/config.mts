// The site of the repository on GitHub Pages
// (https://abap2ui5-addons.github.io/range-filter/), built by
// `npm run site` into build/site and deployed by
// .github/workflows/deploy-pages.yaml.
import { defineConfig } from "vitepress";

const REPO = "https://github.com/abap2UI5-addons/range-filter";

export default defineConfig({
  title: "range-filter",
  description: "Select-options with saved variants for abap2UI5 apps - generated from any table.",
  lang: "en",
  base: "/range-filter/",
  outDir: "../build/site",
  cleanUrls: true,
  head: [["link", { rel: "icon", type: "image/png", href: "/range-filter/favicon.png" }]],
  themeConfig: {
    logo: "/favicon.png",
    nav: [
      { text: "Guide", link: "/guide" },
      { text: "range-filter or abap-cloud-gui?", link: "/which" },
      {
        text: "Links",
        items: [
          { text: "Samples", link: `${REPO}/tree/main/src/00` },
          { text: "abap-cloud-gui", link: "https://abap2ui5-addons.github.io/abap-cloud-gui/" },
          { text: "abap2UI5", link: "https://abap2ui5.github.io/" },
        ],
      },
    ],
    socialLinks: [{ icon: "github", link: REPO }],
    editLink: { pattern: `${REPO}/edit/main/site/:path`, text: "Edit this page on GitHub" },
    search: { provider: "local" },
    footer: {
      message: "MIT licensed - part of <a href=\"https://github.com/abap2UI5-addons\">abap2UI5-addons</a>",
      copyright: "<a href=\"https://github.com/abap2UI5/abap2UI5\">abap2UI5</a>",
    },
  },
});

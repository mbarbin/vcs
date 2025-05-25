import { themes as prismThemes } from 'prism-react-renderer';
import type { Config } from '@docusaurus/types';
import type * as Preset from '@docusaurus/preset-classic';

const config: Config = {
  title: 'volgo-vcs',
  tagline: 'A Versatile OCaml Library for Git Operations',
  favicon: 'img/favicon.ico',

  // Set the production url of your site here
  url: 'https://mbarbin.github.io',
  // Set the /<baseUrl>/ pathname under which your site is served
  // For GitHub pages deployment, it is often '/<projectName>/'
  baseUrl: '/vcs/',

  // GitHub pages deployment config.
  // If you aren't using GitHub pages, you don't need these.
  organizationName: 'mbarbin', // Usually your GitHub org/user name.
  projectName: 'vcs', // Usually your repo name.

  trailingSlash: true,

  onBrokenLinks: 'throw',
  onBrokenMarkdownLinks: 'warn',

  // Even if you don't use internationalization, you can use this field to set
  // useful metadata like html lang. For example, if your site is Chinese, you
  // may want to replace "en" with "zh-Hans".
  i18n: {
    defaultLocale: 'en',
    locales: ['en'],
  },

  presets: [
    [
      'classic',
      {
        docs: {
          sidebarPath: './sidebars.ts',
          // Please change this to your repo.
          // Remove this to remove the "edit this page" links.
          editUrl: 'https://github.com/mbarbin/vcs/tree/main/doc/',
        },
        blog: {
          showReadingTime: true,
          // Please change this to your repo.
          // Remove this to remove the "edit this page" links.
          editUrl: 'https://github.com/mbarbin/vcs/tree/main/doc/',
        },
        theme: {
          customCss: './src/css/custom.css',
        },
      } satisfies Preset.Options,
    ],
  ],

  markdown: {
    mermaid: true,
  },

  themes: ['@docusaurus/theme-mermaid'],

  themeConfig: {
    // Replace with your project's social card
    image: 'img/ocaml-vcs.png',
    navbar: {
      hideOnScroll: true,
      title: 'volgo-vcs',
      logo: {
        alt: 'Site Logo',
        src: 'img/ocaml-vcs.png',
      },
      items: [
        {
          type: 'docSidebar',
          sidebarId: 'tutorialsSidebar',
          position: 'left',
          label: 'Tutorials',
        },
        {
          type: 'docSidebar',
          sidebarId: 'guidesSidebar',
          position: 'left',
          label: 'Guides',
        },
        {
          type: 'docSidebar',
          sidebarId: 'referenceSidebar',
          position: 'left',
          label: 'Reference',
        },
        {
          type: 'docSidebar',
          sidebarId: 'explanationSidebar',
          position: 'left',
          label: 'Explanation',
        },
        { to: '/blog/', label: 'Blog', position: 'right' },
        {
          href: 'https://github.com/mbarbin/vcs',
          label: 'GitHub',
          position: 'right',
        },
      ],
    },
    docs: {
      sidebar: {
        hideable: true,
        autoCollapseCategories: true,
      },
    },
    footer: {
      style: 'dark',
      links: [
        {
          title: 'Docs',
          items: [
            {
              label: 'Tutorials',
              to: '/docs/tutorials/',
            },
            {
              label: 'Guides',
              to: '/docs/guides/',
            },
            {
              label: 'Reference',
              to: '/docs/reference/odoc/',
            },
            {
              label: 'Explanation',
              to: '/docs/explanation/',
            },
          ],
        },
        {
          title: 'More',
          items: [
            {
              label: 'Blog',
              to: '/blog',
            },
            {
              label: 'GitHub',
              href: 'https://github.com/mbarbin/vcs',
            },
          ],
        },
      ],
      copyright: `Copyright © ${new Date().getFullYear()} Mathieu Barbin. Built with Docusaurus.`,
    },
    prism: {
      theme: prismThemes.github,
      darkTheme: prismThemes.dracula,
      additionalLanguages: ['bash', 'diff', 'json', 'ocaml'],
    },
    algolia: {
      // The application ID provided by Algolia
      appId: 'SK93BEXKXL',
      // Public API key: it is safe to commit it
      apiKey: '3696b679996f24295fa2f4a80bbc366b',
      indexName: 'mbarbinio',
      // Optional: see doc section below
      contextualSearch: true,
      // Optional: Specify domains where the navigation should occur through
      // window.location instead on history.push. Useful when our Algolia
      // config crawls multiple documentation sites and we want to navigate
      // with window.location.href to them.
      // externalUrlRegex: 'external\\.com|domain\\.com',
      // Optional: Replace parts of the item URLs from Algolia. Useful when
      // using the same search index for multiple deployments using a
      // different baseUrl. You can use regexp or string in the `from` param.
      // For example: localhost:3000 vs myCompany.com/docs
      // replaceSearchResultPathname: {
      //  from: '/docs/', // or as RegExp: /\/docs\//
      //  to: '/',
      // },
      // Optional: Algolia search parameters
      searchParameters: {},
      // Optional: path for search page that enabled by default (`false` to disable it)
      searchPagePath: 'search',
      //... other Algolia params
    },
  } satisfies Preset.ThemeConfig,
};

export default config;

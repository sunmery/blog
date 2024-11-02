import {themes as prismThemes} from 'prism-react-renderer';
import type {Config} from '@docusaurus/types';
import type * as Preset from '@docusaurus/preset-classic';

const config: Config = {
  title: 'Mandala日记本',
  tagline: '又菜又爱玩',
  favicon: 'img/favicon.ico',

  // Set the production url of your site here
  // url: 'https://lookeke.com',
  url: 'https://lookeke.cn',
  // Set the /<baseUrl>/ pathname under which your site is served
  // For GitHub pages deployment, it is often '/<projectName>/'
  baseUrl: '/',

  // GitHub pages deployment config.
  // If you aren't using GitHub pages, you don't need these.
  organizationName: 'GitHub', // Usually your GitHub org/user name.
  projectName: 'mandala/blog', // Usually your repo name.

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
          editUrl:
              'https://github.com/facebook/docusaurus/tree/main/packages/create-docusaurus/templates/shared/',
        },
        blog: {
          showReadingTime: true,
          // Please change this to your repo.
          // Remove this to remove the "edit this page" links.
          editUrl:
              'https://github.com/facebook/docusaurus/tree/main/packages/create-docusaurus/templates/shared/',
        },
        theme: {
          customCss: './src/css/custom.css',
        },
      } satisfies Preset.Options,
    ],
  ],

  themeConfig: {
    // Replace with your project's social card
    image: 'img/docusaurus-social-card.jpg',
    navbar: {
      title: 'Mandala日记本',
      logo: {
        alt: 'My Site Logo',
        src: 'img/ico.png',
        href: 'https://www.lookeke.top',
      },
      items: [
        {
          type: 'docSidebar',
          sidebarId: 'tutorialSidebar',
          position: 'left',
          label: 'Side',
        },
        {
          to: '/docs/Backend',
          label: 'Backend',
          position: 'left'
        },
        {
          to: '/docs/DevOps',
          label: 'DevOps',
          position: 'left'
        },
        {
          to: '/docs/Flow',
          label: 'Flow',
          position: 'left'
        },
        {
          to: '/docs/Frontend',
          label: 'Frontend',
          position: 'left'
        },
        {
          to: '/docs/Mac',
          label: 'Mac',
          position: 'left'
        },
        {
          to: '/docs/Microservice',
          label: 'Microservice',
          position: 'left'
        },
        {
          to: '/docs/SE',
          label: 'Software Engineering ',
          position: 'left'
        },
        {
          to: '/docs/Windows',
          label: 'Windows',
          position: 'left'
        },
        {
          to: '/docs/Other',
          label: 'Other',
          position: 'left'
        },
        {
          href: 'https://github.com/Mandala-lab',
          label: 'GitHub',
          position: 'right',
        },
        {
          href: 'https://juejin.cn/user/2172290708810744',
          label: '掘金',
          position: 'right',
        },

      ],
    },
    footer: {
    //   links:[
    //     {
    //       title:'安全性',
    //       items:[
    //         {
    //           label:'举报',
    //           to:'/',
    //         }
    //       ]
    //     }
    //   ],
      style: 'dark',
      copyright: `Copyright © ${new Date().getFullYear()} Mandala Lab.`,
    },
    prism: {
      theme: prismThemes.github,
      darkTheme: prismThemes.dracula,
    },
  } satisfies Preset.ThemeConfig,
};

export default config;

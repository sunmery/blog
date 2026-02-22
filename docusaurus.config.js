"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
var prism_react_renderer_1 = require("prism-react-renderer");
var config = {
    title: 'Sunery日记',
    tagline: 'Sunery日记',
    favicon: 'img/favicon.ico',
    // Set the production url of your site here
    // url: 'https://lookeke.com',
    // url: 'https://lookeke.cn',
    url: 'https://www.sumery.cn',
    // Set the /<baseUrl>/ pathname under which your site is served
    // For GitHub pages deployment, it is often '/<projectName>/'
    baseUrl: '/',
    // GitHub pages deployment config.
    // If you aren't using GitHub pages, you don't need these.
    organizationName: 'GitHub', // Usually your GitHub org/user name.
    projectName: 'mandala/blog', // Usually your repo name.
    // 统计数据
    headTags: [
        // Declare some json-ld structured data
        {
            tagName: 'script',
            attributes: {
                src: 'https://cloud.umami.is/script.js',
                'data-website-id': "9cd4126f-5d30-48a4-b6f4-8396b8ce50d8"
            },
        },
    ],
    onBrokenLinks: 'throw',
    onBrokenMarkdownLinks: 'warn',
    // Even if you don't use internationalization, you can use this field to set
    // useful metadata like html lang. For example, if your site is Chinese, you
    // may want to replace "en" with "zh-Hans".
    i18n: {
        defaultLocale: 'zh-Hans',
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
                    editUrl: 'https://github.com/facebook/docusaurus/tree/main/packages/create-docusaurus/templates/shared/',
                },
                blog: {
                    showReadingTime: true,
                    // Please change this to your repo.
                    // Remove this to remove the "edit this page" links.
                    editUrl: 'https://github.com/facebook/docusaurus/tree/main/packages/create-docusaurus/templates/shared/',
                },
                theme: {
                    customCss: './src/css/custom.css',
                },
            },
        ],
    ],
    themeConfig: {
        // Replace with your project's social card
        image: 'img/docusaurus-social-card.jpg',
        navbar: {
            title: 'Sunery日记',
            logo: {
                alt: 'My Site Logo',
                src: 'img/ico.png',
                // href: 'https://www.sumery.cn',
                href: '/',
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
                    to: '/docs/OS/Mac',
                    label: 'Mac',
                    position: 'left'
                }, {
                    to: '/docs/OS/Windows',
                    label: 'Windows',
                    position: 'left'
                },
                {
                    to: '/docs/Microservice',
                    label: 'Microservice',
                    position: 'left'
                },
                {
                    to: '/docs/Network',
                    label: 'Network',
                    position: 'left'
                },
                {
                    to: '/docs/SE',
                    label: 'Software Engineering ',
                    position: 'left'
                },
                {
                    to: '/docs/OS/Windows',
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
            copyright: "Copyright \u00A9 2022 - ".concat(new Date().getFullYear(), " Sumery."),
            links: [
                {
                    items: [
                        {
                            html: "\u5907\u6848\u53F7: <a href=\"https://beian.miit.gov.cn\" target=\"_parent\">\u6842ICP\u59072022004535\u53F7-5</a>"
                        },
                        {
                            html: "\u516C\u5B89\u8054\u7F51\u5907\u6848\u4FE1\u606F: <a href=\"https://beian.mps.gov.cn/#/query/webSearch?code=45060002450628\" rel=\"noreferrer\" target=\"_blank\">\u6842\u516C\u7F51\u5B89\u590745060002450628\u53F7</a>"
                        }
                    ]
                }
            ]
        },
        prism: {
            theme: prism_react_renderer_1.themes.github,
            darkTheme: prism_react_renderer_1.themes.dracula,
        },
    },
};
exports.default = config;

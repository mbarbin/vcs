import type { SidebarsConfig } from '@docusaurus/plugin-content-docs';

/**
 * Creating a sidebar enables you to:
 - create an ordered group of docs
 - render a sidebar for each doc of that group
 - provide next/previous navigation

 The sidebars can be generated from the filesystem, or explicitly defined here.

 Create as many sidebars as you want.
 */
const sidebars: SidebarsConfig = {

  tutorialsSidebar: [
    {
      type: 'category',
      label: 'Tutorials',
      items: [
        { type: 'doc', id: 'tutorials/README', label: 'Introduction' },
      ],
    },
  ],

  guidesSidebar: [
    {
      type: 'category',
      label: 'Guides',
      items: [
        { type: 'doc', id: 'guides/README', label: 'Introduction' },
        { type: 'doc', id: 'guides/cli-output-format', label: 'CLI Output Format' },
      ],
    },
  ],

  referenceSidebar: [
    {
      type: 'category',
      label: 'Reference',
      items: [
        { type: 'doc', id: 'reference/odoc', label: 'OCaml Packages' },
        { type: 'doc', id: 'reference/platform-repositories', label: 'Platform Repositories' },
      ],
    },
  ],

  explanationSidebar: [
    {
      type: 'category',
      label: 'Explanation',
      items: [
        { type: 'doc', id: 'explanation/README', label: 'Introduction' },
        { type: 'doc', id: 'explanation/traits', label: 'Traits' },
        { type: 'doc', id: 'explanation/mercurial-compatibility', label: 'Mercurial Compatibility' },
        { type: 'doc', id: 'explanation/parametrization-axes', label: 'Parametrization Axes' },
        { type: 'doc', id: 'explanation/exploratory-tests', label: 'Exploratory tests' },
      ],
    },
  ],
};

export default sidebars;

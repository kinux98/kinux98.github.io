# Donghyeon Kwon — Personal Website

Source code for [kinux98.github.io](https://kinux98.github.io/), a Jekyll-based academic and research portfolio built with the al-folio theme.

## Content management

- **Profile / homepage:** `_pages/about.md`
- **Publications:** `_bibliography/papers.bib`
- **News and announcements:** `_news/`
- **Professional experience, awards, and service:** `_includes/`
- **Site settings and social links:** `_config.yml`
- **Images and downloadable documents:** `assets/`

## Local development

Install Ruby 3.3, Bundler, Python 3, and ImageMagick. Then run:

```bash
bundle install
bundle exec jekyll serve
```

Visit `http://localhost:4000`. The CI build also installs `nbconvert` and uses PurgeCSS to reduce the generated CSS.

## Deployment

1. Push changes to the `main` branch.
2. The [Deploy site workflow](https://github.com/kinux98/kinux98.github.io/actions/workflows/deploy.yml) builds the site with Jekyll.
3. On success, the workflow publishes `_site/` to the `gh-pages` branch.
4. GitHub Pages serves the published `gh-pages` branch at [kinux98.github.io](https://kinux98.github.io/).

If the site does not update, inspect the latest **Deploy site** workflow run first. A failed build leaves the previously published website online. In GitHub **Settings → Pages**, the publishing source should remain **Deploy from a branch → gh-pages → /(root)** for this workflow.

## Source of truth

Edit content in `main`, not `gh-pages`. The latter is generated output that can be overwritten on the next successful deployment.

## Homepage visual design

The homepage uses a dedicated editorial-style design layer, without replacing Jekyll or the publication system:

- \`_layouts/about.liquid\` — landing page structure and semantic sections.
- \`_includes/portfolio-nav.liquid\` — responsive navigation and theme toggle.
- \`assets/css/portfolio.css\` — homepage-only design tokens, cards, typography, and breakpoints.
- \`_includes/{experiences,educations,services,honors}.html\` — reusable content panels.
- \`_bibliography/papers.bib\` — publication source of truth (unchanged).

Styling is loaded **only** on the homepage via \`_includes/head.liquid\`; other Jekyll pages retain their existing template. The theme toggle remains compatible with the site's existing \`theme.js\`. No new JavaScript framework is required.

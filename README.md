# Donghyeon Kwon — research website

A small Jekyll site for biography, publications, news, and academic background.
The interface uses one stylesheet and one optional theme script. No Bootstrap,
jQuery, icon fonts, remote fonts, npm build, Python packages, or theme overrides.

## Edit content

| Content | Source |
| --- | --- |
| Biography | `_pages/about.md` |
| Current role, experience, education, reviewing and honors | `_data/profile.yml` |
| Publications and paper links | `_bibliography/papers.bib` |
| Publication figures | `assets/img/publication_preview/` |
| News archive | `_news/` |
| Name, contact profiles and site URL | `_config.yml` |
| CV | `assets/pdf/Donghyeon_Kwon_CV.pdf` |
| Layout and appearance | `_layouts/`, `assets/css/site.css` |

`assets/pdf/Resume.pdf` is retained as an existing personal document, but the
navigation points to the maintained CV. Do not replace it with a demo resume.

## Local development

Use Ruby 3.3 and Bundler (the lockfile records the tested gem versions):

```sh
bundle install
bundle exec jekyll serve
```

Open `http://localhost:4000`. Python 3.9+ is needed only for the output checker:

```sh
JEKYLL_ENV=production bundle exec jekyll build
python3 scripts/check_site.py _site
node --check assets/js/theme.js
```

Node is only used for a syntax check; the website has no Node dependencies.
The lockfile supports Linux x86-64 and Apple Silicon. On another platform, use
`bundle lock --add-platform YOUR_PLATFORM` and commit the resulting lockfile.

## Build and deployment

A pull request builds and validates the site without publishing it. The
`site-preview` artifact contains the exact tested output. Pushes to `main`
publish that output to `gh-pages`, using the existing GitHub Pages branch source.
Keep **Settings → Pages → Deploy from a branch → gh-pages → /(root)**.

Builds use Ubuntu 24.04 and Ruby 3.3. Concurrency prevents older builds from
publishing over newer ones. Deployment requires a successful build, an HTML
structure check, local link/anchor checks, publication completeness checks,
and JavaScript syntax validation. External websites are not checked offline.

Before merging visual changes, inspect the generated site at desktop and mobile
widths, light/dark themes, keyboard navigation, and with JavaScript disabled.
BibTeX disclosure uses native HTML and works without JavaScript.

## Scope of the cleanup

The al-folio demo blog, sample projects, Einstein CV/sample data, demo media,
unused layouts and Sass, JavaScript integrations, citation scraping, Docker
publishing workflows, and theme-maintenance workflows have been removed. The
publication bibliography, news source records, personal PDFs, portrait, and
figures used by the publications are retained. Existing `/publications/`,
`/news/`, individual news URLs, `/cv/`, and `/experience/exp1/` remain available.

The Git history is not rewritten: removed template material can be retrieved
from the preceding commits. The original MIT license is retained.

## Design references

The design prioritizes readable research content over portfolio decoration:

- Minimal Light academic theme: https://minimal-light-theme.yliu.me/
- Berkeley, personal academic webpage guidance: https://townsendcenter.berkeley.edu/blog/personal-academic-webpages-how-tos-and-tips-better-site
- NN/g, aesthetic and minimalist design: https://www.nngroup.com/articles/aesthetic-minimalist-design/
- W3C, page structure: https://www.w3.org/WAI/tutorials/page-structure/

These informed the information hierarchy; no third-party theme code was copied.

## Subtle visual emphasis (November 2026)

A single muted blue-teal accent now supports the text-first design. The homepage
uses a small discipline kicker, research-interest labels, a subtle highlight for
the most recent paper, clearer paper links, and a light career timeline. The
portrait caption remains *Taken in Prague, Czech Republic*; the portrait stays
visible on mobile. The theme control works in light, dark and system modes.

The accent and layout choices were informed by academic website guidance from
Berkeley (restrained accent colors and typography) and the example research
presentation of Minimal Light. The goal is to emphasize research content rather
than add decorative logos, background illustrations or external dependencies.


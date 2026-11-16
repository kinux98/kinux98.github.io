# Donghyeon Kwon — research website

A small Jekyll site for biography, publications, news and academic background.
One stylesheet and one optional browser script support light/dark themes. No
Bootstrap, jQuery, icon fonts, remote fonts or npm build dependencies.

## Edit content

| Content | Source |
| --- | --- |
| Biography and military service note | `_pages/about.md` |
| Experience, education, reviewing and honors | `_data/profile.yml` |
| Publications and paper links | `_bibliography/papers.bib` |
| Verified author destinations | `_data/coauthors.yml` |
| Publication figures | `assets/img/publication_preview/` |
| News archive | `_news/` |
| Name, contact profiles and site URL | `_config.yml` |
| CV | `assets/pdf/Donghyeon_Kwon_CV.pdf` |
| Layout and appearance | `_layouts/`, `assets/css/site.css` |

`assets/pdf/Resume.pdf` is retained as an existing personal document. Navigation
points to the maintained CV. The original portrait, publication figures and
personal PDFs are preserved.

## Local development

Use Ruby 3.3 and Bundler:

```sh
bundle install
bundle exec jekyll serve
```

Open `http://localhost:4000`. Validate a production build with Python 3.9+ and Node:

```sh
JEKYLL_ENV=production bundle exec jekyll build
ruby scripts/test_link_targets.rb
python3 scripts/check_site.py _site
python3 scripts/check_link_policy.py _site
node --check assets/js/theme.js
```

Python uses only its standard library. Node is only used for a syntax check.
The lockfile supports Linux x86-64 and Apple Silicon. On other platforms run
`bundle lock --add-platform YOUR_PLATFORM` and commit the lockfile.

## Link policy and author verification

`_plugins/link_targets.rb` adds `target="_blank"` and `rel="noopener noreferrer"`
to navigation links during the Jekyll build, including Markdown, news, internal
pages, section menus and PDFs. It leaves escaped code and script/style content
unchanged. New-tab behavior therefore works without JavaScript. The keyboard
**Skip to content** control stays in the current page; theme buttons and native
BibTeX disclosure are controls, not navigation links. Email links still use the
visitor's configured mail handler. The browser decides whether `_blank` is shown
as a tab or a separate window.

Author mappings use full display names, never surnames alone. The 14 current
authors all have verified identity links: personal websites, academic profiles,
a self-maintained GitHub profile, or the official lab member listing for Inho
Kim (whose individual homepage was not unambiguously verified). Sources for
new or changed mappings are recorded in `_data/coauthors.yml`. Unknown future
authors should not receive guessed destinations; the output check flags them.

## Design and wording

The layout emphasizes research and education, with a muted blue-teal accent,
readable publication rows and a light career timeline. It has no initials logo,
research-keyword chips, discipline kicker or highlighted publication background.
The Prague photo caption remains italic, and the portrait is visible on mobile.

GenGenAI is mentioned as the placement for **Military service obligation**, not
as the headline affiliation. The service note and company link have subdued
styling. `military_service: true` in a career entry enables that contextual style.

## Deployment

A pull request builds and validates the site without publishing. Its
`site-preview` artifact contains the exact tested output. Pushes to `main`
publish that output to `gh-pages`. Keep **Settings → Pages → Deploy from a
branch → gh-pages → /(root)**.

CI runs on Ubuntu 24.04 and Ruby 3.3, checking HTML structure, local targets,
anchors, bibliography completeness, author links, link-target policy and
JavaScript syntax before deployment. External URL availability is not checked
by the offline validator. Concurrency prevents outdated builds from publishing.

Inspect the actual artifact at desktop/mobile widths, light/dark themes,
keyboard navigation and JavaScript-disabled mode before merging visual changes.

## Cleanup history

Unused al-folio demo posts, sample projects, Einstein data, demo media, layouts,
Sass, integrations and Docker/theme-maintenance workflows were removed. The
bibliography, news, personal assets and existing content routes are retained.
Git history is not rewritten; removed template files remain recoverable. The
original MIT license is retained.

## References

- Minimal Light: https://minimal-light-theme.yliu.me/
- Berkeley academic webpage guidance: https://townsendcenter.berkeley.edu/blog/personal-academic-webpages-how-tos-and-tips-better-site
- W3C page structure: https://www.w3.org/WAI/tutorials/page-structure/
- Jekyll hooks: https://jekyllrb.com/docs/plugins/hooks/

No third-party theme code or extra runtime dependencies were added.

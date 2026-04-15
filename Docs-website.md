# Fed-BioMed Website — Developer Documentation

Complete reference for developers who manage or contribute to the Fed-BioMed website.

---

## Table of Contents

1. [Technology Stack](#1-technology-stack)
2. [Prerequisites & First-Time Setup](#2-prerequisites--first-time-setup)
3. [Project Structure](#3-project-structure)
4. [Configuration Files](#4-configuration-files)
5. [Layout System](#5-layout-system)
6. [Includes & Components](#6-includes--components)
7. [Content Management](#7-content-management)
8. [Data Files](#8-data-files)
9. [Styling Architecture (SASS/SCSS)](#9-styling-architecture-sassscss)
10. [Assets](#10-assets)
11. [How to Edit Specific Parts](#11-how-to-edit-specific-parts)
12. [Adding New Content](#12-adding-new-content)
13. [Deployment](#13-deployment)

---

## 1. Technology Stack

| Layer | Technology |
|---|---|
| Static site generator | Jekyll 4.4.1 |
| Build orchestration | Rake (Ruby) |
| CSS pre-processor | SASS/SCSS (via SassC gem and Node sass) |
| CSS framework | Bootstrap 5.3.3 |
| JS bundling | Vendor concatenation via `scripts/compile-vendor.rb` |
| Package manager | npm (Node.js) |
| Image optimisation | libvips via `image_processing` gem |
| Templating language | Liquid (Jekyll default) |

The site is a **pure static site** — no server-side runtime, no database. Every page is a pre-rendered HTML file served from `_site/`.

---

## 2. Prerequisites & First-Time Setup

### System requirements

- Ruby ≥ 3.1 (check with `ruby -v`)
- Bundler (`gem install bundler`)
- Node.js ≥ 18 (check with `node -v`)
- libvips (for image tasks — `brew install vips` on macOS)

### Install dependencies

```bash
# From the /website directory
bundle install      # Ruby gems (Jekyll, plugins, SassC, …)
npm install         # Node packages (Bootstrap, Gulp, sass, …)
```

### Start the development server

```bash
bundle exec rake serve
# or simply:
rake serve
```

This runs `rake prepare` first (SASS entry generation + vendor compilation), then launches Jekyll with live-reload at `http://localhost:4000/test-fbm-site`.

---

## 3. Project Structure

All source files live inside `website/`. The `_site/` directory is the **compiled output** — never edit it directly.

```
website/
├── _config.yml                            # Jekyll configuration
├── Rakefile                               # Build tasks
├── Gemfile / Gemfile.lock                 # Ruby dependencies
├── package.json                           # Node dependencies
│
├── _data/                                 # Global data files (YAML / JSON)
│   ├── theme.yml                          # Site-wide settings (logo, colours, GA, …)
│   ├── navigation.yml                     # Main navbar links
│   ├── footer.yml                         # Footer links and columns
│   ├── team.json                          # Team member profiles
│   ├── social.yml                         # Social media links
│   └── header.yml                         # Generic header config
│
├── _layouts/                              # Page skeleton templates
│   ├── default.html                       # Master layout (wraps everything)
│   ├── post.html                          # News / blog article layout
│   ├── page.html                          # Generic page layout
│   ├── doc.html                           # Documentation layout (with sidebar + TOC)
│   ├── blog/                              # Blog-specific layouts
│   └── project/                           # Real-world project layouts
│
├── _includes/                             # Reusable Liquid partials
│   ├── helpers/                           # <head> helpers: meta, styles, scripts, analytics
│   └── components/                        # UI components (navbar, footer, sections, …) <-- section edited
│       └── .../                           # Other components
│       └── section/                       # Principal components
│           └── about/                     # About page components
│           └── error/                     # Error page components
│           └── faq/                       # FAQ page components
│           └── federated_analytics/       # FA page components
│           └── federated_discovery/       # FD page components
│           └── federated_infrastructure/  # FI page components
│           └── federated_learning/        # FL page components
│           └── home/                      # Homepage components
│           └── project/                   # Project page components
│           └── terms/                     # Terms page components
│
├── _sass/                                 # SCSS source files
│   ├── style.scss                         # Main entry point
│   ├── _user.scss                         # Custom overrides (edit this for custom CSS)
│   ├── _user-variables.scss               # Override Bootstrap / theme variables here
│   ├── _theme-colors.scss                 # Custom colour definitions
│   ├── theme/                             # Theme component SCSS files
│   ├── bootstrap/                         # Full Bootstrap 5 SCSS source
│   ├── colors/                            # One .scss per colour scheme
│   └── fonts/                             # One .scss per font scheme
│
├── _news/                                 # News collection <-- add md files here for new news
├── _realworld_projects/                   # Real-world projects collection <-- add md files here for new use-cases
├── _authors/                              # Author profiles
│
├── assets/
│   ├── css/                               # Compiled CSS (do not hand-edit)
│   ├── js/                                # Compiled/vendored JS
│   ├── img/                               # Images
│   ├── fonts/                             # Web fonts
│   ├── video/                             # MP4 / WebM feature videos
│   └── icons/                             # SVG icon sets
│
├── scripts/
│   ├── generate-sass-entries.rb           # Auto-generates color/font SCSS entry files
│   └── compile-vendor.rb                  # Concatenates vendor CSS and JS files
│
├── index.md                               # Homepage
├── about.md                               # About page
├── project.md                             # Project overview page
├── federated_learning.md                  # Federated Learning feature page
├── federated_infrastructure.md            # Federated Infrastructure feature page
├── federated_discovery.md                 # Federated Discovery feature page
├── federated_analytics.md                 # Federated Analytics feature page
├── realworld-projects.md                  # Real-world projects listing
├── news.md                                # News listing
├── FAQ.md                                 # FAQ page
├── terms.md                               # Terms & conditions
└── 404.md                                 # 404 error page
```

---

## 4. Configuration Files

### `_config.yml` — Jekyll core settings

Key settings you may need to change:

| Key | Current value | Purpose |
|---|---|---|
| `baseurl` | `/test-fbm-site` | Path prefix for all URLs. Set to `""` for production root domain. |
| `url` | `https://fedbiomed.org` | Full base URL of the site |
| `markdown` | `kramdown` | Markdown processor |
| `permalink` | `/blog/:title/` | URL format for blog posts |
| `sass.style` | `compressed` | Output style (`expanded` for debugging) |
| `sass.sourcemap` | `never` | Set to `development` to enable source maps |

**Collections** defined in `_config.yml`:

```yaml
collections:
  realworld_projects:   # /website/_realworld_projects/*.md
    output: true
    permalink: /realworld_projects/:path/
  news:                 # /website/_news/*.md
    output: true
    permalink: /news/:path/
  authors:              # /website/_authors/*.md
    output: true
    permalink: /authors/:path/
```

**Default layouts** (applied automatically by file type):

```yaml
defaults:
  - scope: { path: "" }
    values: { layout: "default" }     # all pages use default.html
  - scope: { path: "", type: "news" }
    values: { layout: "post" }        # news items use post.html
```

**Pagination** is currently **disabled** (`enabled: false`). To enable it, set `enabled: true` and adjust `per_page`.

**Plugins loaded:**
- `jekyll-feed` — generates `/feed.xml`
- `jekyll-seo-tag` — injects `<meta>` SEO tags automatically
- `jekyll-sitemap` — generates `/sitemap.xml`
- `jekyll-paginate-v2` — pagination support
- `jekyll-toc` — table of contents for documentation pages

---

### `_data/theme.yml` — Site-wide visual settings

This is the **primary configuration file** for visual and site identity settings. Change these to rebrand or reconfigure the site.

```yaml
site_name: Fed-BioMed
title: "Fed-BioMed | Collaborative learning in healthcare"
description: "..."

favicon: "/assets/img/favicon.png"

# Retina-ready logos (1x and 2x)
logo_1x: "/assets/img/logo_full.webp"
logo_2x: "/assets/img/logo_full@2x.webp"

# Colour scheme — leave blank for default
# Options: Aqua Fuchsia Grape Green Leaf Navy Orange Pink Purple Red Sky Violet Yellow
color_scheme:

# Font scheme — leave blank for default
# Options: dm, space, thicccboi, urbanist
font_scheme:

# Google Analytics
google_analytics:
  enable: false
  key: "UA-664136761-1"

# Contact form backend (FormSubmit.io)
formsubmit_key: "fedbiomed@inria.fr"

# Alert banner (top of page)
alert:
  type: "Update"
  text: "New version of our product is finally"
  link_text: "here!"
  link_url: "#"
```

---

### `_data/navigation.yml` — Navbar links

Edit this file to add, remove, or reorganise navigation items.

```yaml
main:
  - title: Project
    type: link
    url: /project/

  - title: How it works
    type: dropdown          # renders as a Bootstrap dropdown
    items:
      - title: Federated Infrastructure
        url: /federated_infrastructure/
      # … add more dropdown items here

nav_button:
  text: "Documentation"
  url: "https://fedbiomed.org/latest/getting-started/what-is-fedbiomed/"
  class: "btn btn-primary btn-gradient bg-gradient-dark-button border-0 rounded-xl"
  new_tab: true
```

For a **new top-level link**: add an entry with `type: link`.
For a **new dropdown**: add an entry with `type: dropdown` and a list under `items:`.

---

### `_data/footer.yml` — Footer configuration

Controls the newsletter section, link columns, social icons, and address in the footer. Edit this file to change footer content without touching HTML.

---

### `_data/team.json` — Team members

Array of objects. Each team member has:

```json
{
  "name": "First Last",
  "role": "Job Title",
  "bio": "Short description.",
  "avatar": {
    "src": "/assets/img/team/filename.webp",
    "src2x": "/assets/img/team/filename@2x.webp"
  },
  "social": {
    "github": "https://github.com/…",
    "linkedin": "https://linkedin.com/in/…",
    "website": "https://…"
  }
}
```

To add a team member: add their photo (format 1:1 - square) to `assets/img/team/`, then add an entry to `team.json`.

---

## 5. Layout System

Layouts live in `_layouts/` and are Liquid templates that wrap page content.

### Layout hierarchy

```
default.html               ← master shell (HTML doctype, <head>, modals)
  └── post.html            ← news / blog articles (extends default)
  └── page.html            ← generic pages (extends default)
  └── doc.html             ← documentation (sidebar + TOC, extends default)
  └── blog/standard.html   ← blog list views
  └── project/             ← real-world project detail layouts
```

### `default.html` — Master layout

Injects:
- `_includes/helpers/meta.html` — `<head>` meta tags, favicon
- `_includes/helpers/styles.html` — CSS `<link>` tags
- `_includes/components/navbar/navbar.html` — top navigation
- `{{ content }}` — page body
- `_includes/helpers/scripts.html` — JS `<script>` tags
- Modals: `modal-signin.html`, `modal-signup.html`

### Specifying a layout in a page

In the front matter of any `.md` file:

```yaml
---
layout: default    # or post, page, doc, project/featured_image, …
---
```

### Project detail layouts (in `_layouts/project/`)

| Layout | Use case |
|---|---|
| `featured_image.html` | Full-width featured image above content |
| `banner_image.html` | Banner-style header with image |
| `bg_overlay_text.html` | Hero with text overlaid on background image |
| `with_slider.html` | Project with an image carousel |

---

## 6. Includes & Components

All partials live in `_includes/`. They are included in layouts and pages with:

```liquid
{% include components/navbar/navbar.html %}
{% include helpers/styles.html %}
```

### Key include paths

#### `_includes/helpers/`

| File | Purpose |
|---|---|
| `meta.html` | `<title>`, favicon, Open Graph tags, SEO plugin hook |
| `styles.html` | Links to `plugins.css`, `style.min.css`, fonts, Leaflet, Bootstrap Icons |
| `scripts.html` | `<script>` tags for Bootstrap bundle, `plugins.js`, `theme.js` |
| `analytics.html` | Google Analytics snippet (only injected when `google_analytics.enable: true`) |
| `modal-signin.html` | Sign-in modal markup |
| `modal-signup.html` | Sign-up modal markup |
| `scroll-to-top.html` | Floating back-to-top button |

#### `_includes/components/navbar/`

| File | Purpose |
|---|---|
| `navbar.html` | **Primary navbar** — logo, main menu, mobile offcanvas drawer, Documentation button |
| `navbar-center-logo.html` | Variant with centred logo |
| `navbar-fancy.html` | Decorative variant |
| `offcanvas-info.html` | Content panel inside the mobile drawer |

The navbar reads link data from `_data/navigation.yml` (see §9).

#### `_includes/components/footer/`

| File | Purpose |
|---|---|
| `footer.html` | Footer wrapper — decides which footer partial to include |
| `footer-fedbiomed.html` | **Active footer** — newsletter, 3-column links, social icons, copyright |
| `footer-minimal.html` | Minimal one-line footer (alternative) |

The footer reads from `_data/footer.yml` and `_data/theme.yml`.

#### `_includes/components/sections/`

Section includes are the building blocks of each page. Pages are assembled by including a series of sections in the page's markdown front matter or in a layout.

**Homepage sections (`home/`):**

| Include | Purpose |
|---|---|
| `hero.html` | Hero area with animated video background |
| `problem.html` | Problem statement section |
| `solution.html` | Solution feature highlights |
| `pillars.html` | Core technology pillars grid |
| `how-it-works.html` | Step-by-step process section |
| `installation.html` | Quick installation code snippet |
| `testimonials.html` | Testimonials slider (Swiper.js) |
| `who.html` | Target audience / user personas |
| `map.html` | Geographic map (Leaflet) |

**About page sections (`about/`):**

| Include | Purpose |
|---|---|
| `hero.html` | Page hero |
| `project-overview.html` | Project description block |
| `team.html` | Team member cards (reads from `_data/team.json`) |
| `funding.html` | Sponsor and funding logos |
| `roadmap.html` | Project roadmap timeline |
| `how-to-cite-us.html` | Citation block |
| `contacts.html` | Contact details and map |

**Feature page sections (`federated_learning/`, `federated_infrastructure/`, etc.):**

Each feature page folder contains:
- `header.html` — page-specific hero/header
- `what-is.html` — introductory explanation
- `architecture.html` or `core-components.html` — technical diagram section
- `workflow.html` — process flow
- `security.html` or `privacy.html` — security/privacy notes

---

## 7. Content Management

### Pages (`.md` files at root level)

Each page at the root level is a Markdown file with YAML front matter.

**Minimal front matter:**

```yaml
---
layout: default
title: "Page Title"
description: "Page meta description"
---
```

**How sections are assembled** — pages don't contain HTML directly. Instead, the section includes are listed in the front matter using custom keys, and the layout (or the page itself) calls them. For example, `index.md` uses section keys that the `default.html` layout picks up and includes.

To add a new section to an existing page:
1. Create a new partial in `_includes/components/sections/<page-name>/`
2. Include it in the correct page `.md` or in the layout that assembles it

### News collection (`_news/`)

Each news item is a Markdown file named by date: `YYYY-MM-DD-slug.md`.

**Front matter reference:**

```yaml
---
layout: post
title: "Fed-BioMed v5.4 Release"
date: 2025-01-15
author: fedbiomed-team        # matches an _authors/ file (without .md)
category: Releases            # shown as a badge; also used by archives
tags:
  - release
  - v5
excerpt: "One-sentence summary shown on the news listing page."
featured: true                # shows a 'featured' badge
thumbnail: "/assets/img/news/v5-4-thumbnail.webp"
hero: "/assets/img/news/v5-4-hero.webp"
---

Article content in Markdown…
```

### Real-world projects collection (`_realworld_projects/`)

Each project is a Markdown file.

**Front matter reference:**

```yaml
---
layout: project/featured_image     # or banner_image, bg_overlay_text, with_slider
title: "Project Name"
date: 2025-02-06
category: Research Context
description: "Short project description."
client: "Institution Name"
project_url: "https://…"
thumbnail: "/assets/img/projects/slug-thumb.webp"
hero: "/assets/img/projects/slug-hero.webp"
---

Project content in Markdown…
```

### Authors collection (`_authors/`)

```yaml
---
name: Fed-BioMed Team
position: Core Development Team
avatar:
  src: "/assets/img/team/team-avatar.webp"
  src2x: "/assets/img/team/team-avatar@2x.webp"
---
```

---

## 8. Data Files

Data files in `_data/` are globally available in all Liquid templates as `site.data.<filename>`.

| File | Accessed via | Description |
|---|---|---|
| `theme.yml` | `site.data.theme` | Site identity, logos, colours, GA, alerts |
| `navigation.yml` | `site.data.navigation` | Navbar links |
| `footer.yml` | `site.data.footer` | Footer columns and links |
| `team.json` | `site.data.team` | Team member array |
| `social.yml` | `site.data.social` | Social media URLs |
| `header.yml` | `site.data.header` | Default header settings |

**Liquid usage example:**

```liquid
{% for member in site.data.team %}
  <h3>{{ member.name }}</h3>
  <p>{{ member.role }}</p>
{% endfor %}
```

---

## 9. Styling Architecture (SASS/SCSS)

### Import chain

```
_sass/style.scss                  ← main entry
  ├── bootstrap/scss/functions    ← Bootstrap functions (must be first)
  ├── _theme-colors.scss          ← custom colour variables
  ├── _user-variables.scss        ← override Bootstrap & theme vars HERE
  ├── _variables.scss             ← theme variable defaults
  ├── bootstrap/scss/bootstrap    ← full Bootstrap 5
  ├── theme/_theme.scss           ← all theme component SCSS files
  └── _user.scss                  ← your custom CSS goes HERE (last)
```

### Where to write custom CSS

- **`_sass/_user.scss`** — add any custom rules at the bottom of the SASS chain. These override everything above.
- **`_sass/_user-variables.scss`** — override Bootstrap variables (colours, spacing, breakpoints) and theme variables **before** Bootstrap is imported.

### Colour schemes

Colour schemes live in `_sass/colors/` — one file per scheme (e.g. `navy.scss`, `purple.scss`).

To activate a scheme site-wide, set `color_scheme: Navy` (matching the filename) in `_data/theme.yml`. The `generate-sass-entries.rb` script compiles each scheme into `assets/css/colors/`.

To create a new colour scheme:
1. Copy an existing file (e.g. `_sass/colors/navy.scss`)
2. Rename it to your scheme name
3. Adjust the colour variables
4. Run `rake prepare` to generate the compiled CSS entry
5. Set `color_scheme: YourSchemeName` in `_data/theme.yml`

### Font schemes

Font schemes live in `_sass/fonts/` — one file per font family (`dm.scss`, `space.scss`, `thicccboi.scss`, `urbanist.scss`).

Set `font_scheme: dm` (or other option) in `_data/theme.yml`.

### Theme SCSS files (`_sass/theme/`)

The theme folder contains component-specific SCSS. Relevant files for common customisations:

| File | Covers |
|---|---|
| `_navbar.scss` | Navbar sizing, colours, dropdowns |
| `_footer.scss` | Footer layout and colours |
| `_buttons.scss` | Button variants and gradients |
| `_card.scss` | Card components |
| `_carousel.scss` | Swiper / Bootstrap carousel |
| `_animations.scss` | CSS keyframe animations |
| `_type.scss` | Typography scale |
| `_utilities.scss` | Custom utility classes |

---

## 10. Assets

### Images (`assets/img/`)

| Subdirectory | Contents |
|---|---|
| `team/` | Team member photos (`name.webp`, `name@2x.webp`) |
| `contributors/` | Sponsor / institution logos |
| `news/` | Thumbnails and hero images for news articles |
| `projects/` | Thumbnails and hero images for real-world projects |
| `federated_learning/` | Illustrations for the FL feature page |

**Image conventions:**
- Use WebP format (run `rake convert_to_webp` to batch-convert existing JPG/PNG)
- Provide both 1x and 2x retina variants: `image.webp` and `image@2x.webp`
- Reference images from root with a leading `/`: `"/assets/img/…"`

### Videos (`assets/video/`)

Feature sections use autoplay muted looping videos as background or illustration. Two variant sets exist: `filled/` and `outline/`.

Current video files:
- `what-is-fedbiomed.mp4` — homepage hero
- `federated_learning.mp4`
- `federated_infrastructure.mp4` / `.webm`
- `federated_discovery.mp4` / `.webm`
- `federated_analytics.mp4` / `.webm`
- `logo-alpha.webm` / `.mov`

Provide both `.mp4` and `.webm` for best browser compatibility.

### Icons (`assets/icons/`)

SVG icon sets organised by page/feature. Two visual styles: `filled/` and `outline/`.

### Fonts (`assets/fonts/`)

Web-font files for the available font schemes. Custom fonts go in `assets/fonts/custom/`.

---

## 11. How to Edit Specific Parts

### Change the site logo

1. Replace files at `assets/img/logo_full.webp` and `assets/img/logo_full@2x.webp` with your new logo.
2. Update the paths in `_data/theme.yml` under `logo_1x` / `logo_2x` if the filenames change.

### Change the navbar links

Edit `_data/navigation.yml`. No HTML changes needed.

### Change the footer content

Edit `_data/footer.yml` (links, columns, social) and `_data/theme.yml` (address, email, copyright).

### Change the hero video on the homepage

Replace `assets/video/what-is-fedbiomed.mp4` (and optionally add a `.webm` version for Firefox), or edit the `src` attribute in `_includes/components/sections/home/hero.html`.

### Change the colour scheme site-wide

Set `color_scheme: <SchemeName>` in `_data/theme.yml`. Available options: `Aqua Fuchsia Grape Green Leaf Navy Orange Pink Purple Red Sky Violet Yellow`.

### Edit the team section

Edit `_data/team.json`. Add photos to `assets/img/team/`.

### Edit funding/sponsor logos

Edit `_includes/components/sections/about/funding.html` directly, and add logo files to `assets/img/contributors/`.

### Edit the FAQ

Edit the content in `_includes/components/sections/faq/` or in `FAQ.md` depending on how content is structured.

### Enable Google Analytics

In `_data/theme.yml`:

```yaml
google_analytics:
  enable: true
  key: "G-XXXXXXXXXX"     # your real GA4 measurement ID
```

### Enable the alert banner

In `_data/theme.yml`:

```yaml
alert:
  type: "Update"
  text: "New version is out:"
  link_text: "Read more"
  link_url: "/news/v6-0-release/"
```

The banner is rendered by the navbar component. Leave `text` blank to hide it.

---

## 12. Adding New Content

### Add a news article

1. Create `_news/YYYY-MM-DD-your-slug.md`
2. Fill in front matter (see §8 — News collection)
3. Write the article body in Markdown
4. Add thumbnail and hero images to `assets/img/news/`
5. Run `rake serve` and navigate to `/news/your-slug/` to preview

### Add a real-world project

1. Create `_realworld_projects/YYYY-MM-DD-project-slug.md`
2. Fill in front matter (see §8 — Real-world projects collection)
3. Add thumbnail and hero images to `assets/img/projects/`
4. The project appears automatically on the `/realworld_projects/` listing page

### Add a team member

1. Add photo (`.webp` + `@2x.webp`) to `assets/img/team/`
2. Add entry to `_data/team.json` (see §9 — Data files)

### Add a new top-level page

1. Create `your-page.md` at the root of `website/`
2. Set `layout: default` (or another layout) in front matter
3. Add a link to `_data/navigation.yml` so it appears in the navbar

### Add a new feature page section

1. Create `_includes/components/sections/<page>/my-section.html`
2. Include it in the relevant page layout or in the page's Markdown file

---

## 13. Deployment

### Production build

```bash
# From website/
bundle exec rake build
```

This generates the complete static site in `website/_site/`.

**What changes in production mode (`JEKYLL_ENV=production`):**
- SASS output is compressed (minified CSS)
- Source maps are disabled
- The `jekyll-seo-tag` plugin generates full meta tags
- Google Analytics snippet is injected (if `enable: true` in `theme.yml`)

### Deploying `_site/`

The `_site/` directory is a self-contained static website. Upload it to any static hosting:

- **GitHub Pages** — push to `gh-pages` branch or configure Pages to build from `master`
- **Netlify / Vercel** — point build command to `bundle exec rake build`, publish directory to `website/_site`
- **Apache / Nginx** — rsync `_site/` to the server document root

### `baseurl` setting

The current `baseurl: "/test-fbm-site"` is used for staging. For production on the root domain, set:

```yaml
# _config.yml
baseurl: ""
url: "https://fedbiomed.org"
```

All internal links use `{{ site.baseurl }}` prefixes, so this single change updates every URL.

### Search index

`search-data.json` is generated at build time by Jekyll. It is consumed by the search interface at `search.html`. No extra step is needed.

### Sitemap and feed

`/sitemap.xml` and `/feed.xml` are auto-generated by the `jekyll-sitemap` and `jekyll-feed` plugins on every build.

---

## Quick Reference

| Task | Command |
|---|---|
| Start dev server | `rake serve` |
| Production build | `rake build` |
| Prepare assets only | `rake prepare` |
| Convert images to WebP | `rake convert_to_webp` |
| Watch and compile SASS | `npm run sass:watch` |
| Add team member | Edit `_data/team.json` + add photo to `assets/img/team/` |
| Add news article | Create `_news/YYYY-MM-DD-slug.md` |
| Change nav links | Edit `_data/navigation.yml` |
| Change footer | Edit `_data/footer.yml` |
| Change colours globally | Set `color_scheme` in `_data/theme.yml` |
| Add custom CSS | Edit `_sass/_user.scss` |
| Override Bootstrap vars | Edit `_sass/_user-variables.scss` |

# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is the ownCloud Server documentation repository. It uses **Antora** (static site generator) with **AsciiDoc** (`.adoc`) format. The current component is `server` version `10.4`.

## Build Commands

```bash
# Install dependencies
yarn install

# Build HTML documentation
yarn antora

# Validate internal cross-references (xrefs)
yarn validate

# Lint prose in AsciiDoc files
yarn prose

# Check for broken links (requires built site)
yarn linkcheck

# Serve the built docs locally at http://localhost:8080
yarn serve
```

## Content Structure

Antora organizes content into **modules**, each with a fixed directory layout:

```
modules/<module_name>/
  pages/         # AsciiDoc source files (.adoc)
  assets/images/ # Images
  examples/      # Code examples and included files
  nav.adoc       # Module navigation
```

The four modules are: `ROOT`, `admin_manual`, `user_manual`, `developer_manual`.

## AsciiDoc Conventions

**Internal links** use `xref:` (never Markdown-style links):
```asciidoc
xref:module_name:path/file.adoc#anchor[Link Text]
# module_name: is required only when linking to a different module
```

**Images** (no `assets/images` in path):
```asciidoc
image:path/image_name.png[Alt Text]
# Do NOT use double quotes in alt text — it breaks PDF generation; use single quotes
```

**Include files** from `examples/`:
```asciidoc
include::example$path/file.sh[]
```

**Include partial AsciiDoc pages** (must have `:page-partial:` in their header):
```asciidoc
include::filename.adoc[leveloffset=+1]
```

**occ command examples** (keeps formatting consistent across docs):
```asciidoc
[source,console,subs="attributes+"]
----
{occ-command-example-prefix} maintenance:mode --on
----
```

**Admonitions**: `NOTE:`, `TIP:`, `IMPORTANT:`, `CAUTION:`, `WARNING:` for inline; use `[NOTE]\n====\n...\n====` for block admonitions.

**Menu selections** require `:experimental:` attribute in the page header.

**Titles and section headings** must use Title Case.

**Document attributes** (like `:toc:`, `:experimental:`, `:page-partial:`) must appear directly below the page title with no blank lines between them.

## Renaming or Moving Files

When a page is renamed or relocated, add a `:page-aliases:` attribute to the new file to preserve old URLs (important for SEO):
```asciidoc
= Page Title
:page-aliases: old/path/filename.adoc
```

Also update the path in the relevant `nav.adoc`.

## Key Configuration Files

- **`site.yml`** — Antora playbook: defines content sources (multi-repo), UI bundle, output settings, and AsciiDoc attributes
- **`antora.yml`** — Component descriptor: component name (`server`), version (`10.4`), and nav file list
- **`generator/generate-site.js`** — Custom generator that adds Elasticsearch indexing and rewrites local file URLs to GitHub edit URLs
- **`generator/xref-validator.js`** — Custom generator used by `yarn validate` to check all xrefs
- **`lib/extensions/tabs.js`** — AsciiDoc extension providing the tabset UI widget

## Build Output

- HTML: `public/` (gitignored)
- PDF: `build/` (gitignored)
- Cache: `cache/` (gitignored)

# ownCloud Documentation

**IMPORTANT**

Since April 2026, this repository requires [Commit Signing](https://docs.github.com/articles/about-gpg) and uses [Conventional Commits](https://www.conventionalcommits.org) for commits and the Pull Request title.

**Overview**

1. The platform and tools used to build the documentation is [Antora](./docs/what-is-antora.md).
2. The file format that the documentation is written in is [AsciiDoc](./docs/what-is-asciidoc.md).
3. The <abbr title="User Interface">UI</abbr> & <abbr title="User Experience">UX</abbr> of the documentation can be found at [docs-ui](https://github.com/owncloud/docs-ui)

**Table of Contents**

* [Antora Site Structure for Docs](#antora-site-structure-for-docs)
* [Extensions](#extensions)
* [Documentation Guidelines](#documentation-guidelines)
* [Contributing to the Documentation](#contributing-to-the-documentation)
* [Generating the Documentation](#generating-the-documentation)
* [Common Content and Styling the Documentation](#common-content-and-styling-the-documentation)
* [Best Practices and Tips](#best-practices-and-tips)
* [Target Branch and Backporting](#target-branch-and-backporting)
* [When Does a Change Get Published to the Docs Web Site?](#when-does-a-change-get-published-to-the-docs-web-site)
* [Create a New Version Branch for Docs](#create-a-new-version-branch-for-docs)
* [HTML to PDF](#html-to-pdf)

## Antora Site Structure for Docs

Refer to the [Antora Site Structure for Docs](./docs/antora-site-structure.md) for more information. 

## Extensions

The documentation intensively uses Antora/Asciidoc extensions. These extensions enrich the base functionality with additional and required capabilities. Read the [extensions](./docs/extensions.md) documentation for more information.

## Documentation Guidelines

Refer to the [Documentation Guidelines](./docs/doc-guidelines.md) for more information about backgrounds and processes.

## Contributing to the Documentation

To get started contributing to the documentation, please refer to the [Getting Started Guide](./docs/getting-started.md).

With regard to language and style issues, consult the [Style Guide](./docs/style-guide.md).

Note that the documentation provides a setting for the [IntelliJ AsciiDoc-Antora Plugin](https://intellij-asciidoc-plugin.ahus1.de) to preview a page using the css sourced from `doc.owncloud.com`. The file required containing the necessary configuration is `.asciidoctorconfig`.

## Generating the Documentation

**IMPORTANT**  
We use `node 22 LTS`. In case you used a lower node version for your local doc repos, you must upgrade them **all**. See the link below for details.

**IMPORTANT**  
We use `Antora 3.1.14` and npm instead of yarn. In case you used a lower Antora version for your local doc repos, you must upgrade them **all** by syncing them and running `npm install` in each doc repo.

To generate and view the documentation locally or planning major changes, refer to the [Building the Documentation](./docs/building-the-documentation.md)

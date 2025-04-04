# ownCloud Documentation

[![Build Status](http://drone.owncloud.com/api/badges/owncloud/docs/status.svg?branch=master)](http://drone.owncloud.com/owncloud/docs)

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
We use `node 18.19.0`. In case you used a lower node version for your local doc repos, you must upgrade them **all**. See the link below for details.

**IMPORTANT**  
We use `Antora 3.1.10` and use npm instead of yarn. In case you used a lower Antora version for your local doc repos, you must upgrade them **all** by syncing them and running `npm install` in each doc repo.

To generate and view the documentation locally or planning major changes, refer to the [Building the Documentation guide](./docs/build-the-docs.md).

## Common Content and Styling the Documentation

If you want to suggest an improvement to the ownCloud documentation theme, such as the layout, the header or the footer text, or if you find a bug, all the information that you need is in the `docs-ui` repository. Changes made in `docs-ui` are valid for the whole documentation.

Please read how to test un-merged [docs-ui](./docs/test-ui-bundle.md) changes with content from the ownCloud documentation.

## Best Practices and Tips

Refer to [Best Practices and Tips for writing in AsciiDoc](./docs/best-practices.md) for more information.

To check for broken links manually, see [install and use a broken-link-checker](./docs/checking-broken-links.md).

## Target Branch and Backporting

Please always do your changes in `master` and backport them to the relevant branches.
The **ONLY** reason for doing a PR in a branch directly is, to fix an issue which is
_only_ present in that particular branch! When creating a PR and it is necessary to backport,
document in the PR to which branches a backport is needed.

When backporting, consider using the [backport script](./docs/getting-started.md#backporting)
which eases life a lot and speeds up the process. It is also very beneficial when using the
extended code provided, because a clear naming structure of the backport PR is generated automatically.

## When Does a Change Get Published to the Docs Web Site?

Changes made will get published to the web under the following conditions:

1. A merge in a component to one of the defined version branches triggers as a last step a master branch build.
2. A merge to master triggers a site build which then pushes all versions defined in site.yml.

## Create a New Version Branch for Docs

Please refer to [Create a New Version Branch for Docs](./docs/new-version-branch.md) for more information.

## HTML to PDF

At the moment, creating a pdf is dropped from the build process but can be re-implemented if required.

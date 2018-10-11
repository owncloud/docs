# ownCloud Documentation (v2)

This project is a port of the ownCloud documentation, that was previously generated using [Sphinx-Doc](http://www.sphinx-doc.org), to [Antora](./docs/what-is-antora.md).
Fundamentally, not that much has changed.

All of the same information is still available.
However, here's what has changed:

1. The platform (and tools) used to build the documentation, which is [Antora](./docs/what-is-antora.md).
2. The file format that the documentation is written in, which is [AsciiDoc](./docs/what-is-asciidoc.md).
3. The <abbr title="User Interface">UI</abbr> & <abbr title="User Experience">UX</abbr> of the documentation

## Quick Start Guide

If you're looking for the <abbr title="To Long; Didn't Read">tl;dr</abbr> guide to getting started with the docs, this is it.

1. Either install [the AsciiDoc Live Preview plugin](https://asciidoctor.org/docs/editing-asciidoc-with-live-preview/) for Firefox, Google Chrome, or Opera or [an AsciiDoc Live Preview plugin](https://asciidoctor.org/docs/editing-asciidoc-with-live-preview/#using-a-modern-text-editoride), if your text editor or IDE has one.
2. In a feature branch, branched from master, change the relevant [AsciiDoc](./docs/what-is-asciidoc.md) files.
3. Push your feature branch to the repository and create a PR from it.
4. Make any requested changes.
5. Your PR will be merged.

To generate the documentation, whether in HTML or PDF format, please refer to [the Building the Documentation guide](./docs/build-the-docs.md).

## Styling the Docs

If you find a bug in the look and feel of the ownCloud documentation or want to suggest an improvement, you can find all the information that you need in [the docs-ui repository](https://github.com/owncloud/docs-ui/blob/master/README.adoc).


# ownCloud Documentation (v2)

This project is a port of the ownCloud documentation, that was previously generated using [Sphinx-Doc](http://www.sphinx-doc.org), to [Antora](./docs/what-is-antora.md).
Fundamentally, not that much has changed.

All of the same information is still available.
However, here's what has changed:

1. The platform (and tools) used to build the documentation, which is [Antora](./docs/what-is-antora.md).
2. The file format that the documentation is written in, which is [AsciiDoc](./docs/what-is-asciidoc.md).
3. The <abbr title="User Interface">UI</abbr> & <abbr title="User Experience">UX</abbr> of the documentation

## Contributing to the Docs

If you've been contributing to the previous version of ownCloud's documentation, which used reStructuredText and Sphinx-Doc, here's how to get started contributing to the new version of the documentation.

You need to do a few things to contribute to the documentation:

1. [Install Antora](./docs/install-antora.md).
2. Learn [the AsciiDoc file format's basics](./docs/what-is-asciidoc.md).
3. Update your toolset so that it supports both AsciiDoc and Antora.
4. Learn how to [build the docs](./docs/build-the-docs.md).
5. Create meaningful commits and a PR with your changes.

## Styling the Docs

If you want to change the look and feel of the ownCloud documentation, you can find all the information that you need in [the docs-ui repository](https://github.com/owncloud/docs-ui/blob/master/README.adoc).

## How To Generate PDFs

To generate a PDF version of one or more of the manuals, you need to have `asciidoctor-pdf` installed.
With it installed, run the command below, in the root docs directory, to generate a PDF version of a manual.
The PDF file will be generated in the same directory as where the command is run, and will be named after the configuration file, with a `.pdf` extension.

```console
asciidoctor-pdf \
    book.adoc \
    -a pdf-stylesdir=resources/themes \
    -a pdf-style=owncloud
```


It invokes [asciidoctor-pdf](https://github.com/asciidoctor/asciidoctor-pdf), passing it:

1. [The configuration file](https://github.com/asciidoctor/asciidoctor-pdf/blob/master/docs/theming-guide.adoc) to use. This contains the list of files to use as the PDF's source material, along with front-matter. The front-matter includes details such as whether to render a table of contents, the icon set to use, and the images base directory. See below for details on how to generate the initial configuration file, if it is missing.
2. The custom theme directory and the custom theme file. This ensures that the defaults are overridden, where relevant, to ensure that the generated PDF is as close to the current ownCloud style as possible.

Please be aware that, depending on the size of the manual, PDF generation may take some time.

### How To Generate The PDF Configuration File

Book file generation isn't currently supported by Antora.
As a result, it needs to be done separately.
To save time and effort, you can use [the Antora Tools Phar file](https://github.com/settermjd/antora-tools/releases/download/0.0.1/antora-tools.phar), written specifically for the ownCloud docs.
It provides a single command `antora:create-asciidoc-book-file`, which takes four options:

| Setting | Description |
|---|---|
| `nav-file`     | This is the name of an Antora navigation file. The links in this file are used as the PDF's source matter. The default is `nav.adoc`. |
| `book-file`    | This is the name of the PDF book file to generate from the contents of the Antora navigation file. The default is `book.adoc`. |
| `manual-name`  | This is the name of the manual. At this stage, one of "*Admin Manual*", "*Developer Manual*", or "*User Manual*" are what will be used. |
| `file-version` | This is the file's version. It should be the same as the version of the software that the manual's supporting. For example: `10.1.0`. |

Here’s an example of running it:

```console
php antora-tools.phar antora:create-asciidoc-book-file \
    --nav-file=modules/developer_manual/nav.adoc \
    --book-file=book.dev.adoc \
    --manual-name="ownCloud Developer Manual" \
    --file-version=0.0.1
```

**Note:** At the moment, [the images directory is hardcoded](https://github.com/settermjd/antora-tools/blob/master/src/AntoraTools/Command/GenerateAsciiDocBookFileCommand.php#L17) to `./public/`.
After the book file is changed, this setting needs to be updated to the manual’s image directory root.
For example, to set the image base directory of the developer manual, change it as in the example below.

```asciidoc
:imagesdir: ./public/server/developer_manual/_images/
```

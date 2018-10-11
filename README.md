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

## Contributing to the Docs

If you've been contributing to the previous version of ownCloud's documentation, which used reStructuredText and Sphinx-Doc, here's how to get started contributing to the new version of the documentation.
Unlike the previous version of the documentation, you don't, necessarily, need to install a large number of tools and packages just to review your changes.

### Only Making Text Changes?

If you're only making text changes, then add the AsciiDoc Live Preview plugin:

1. To your [browser](https://asciidoctor.org/docs/editing-asciidoc-with-live-preview/) (The supported browsers are: *Firefox*, *Google Chrome*, or *Opera*).
2. To your [text editor or IDE](https://asciidoctor.org/docs/editing-asciidoc-with-live-preview/#using-a-modern-text-editoride), *if it has one*.

Using one, or both, of these, you can quickly check if the changes you make are what you expect, and if there are any render errors.
If the document renders as expected, then you can commit the changes and push them to the docs repository.

NOTE: Any links to internal files, such as code samples, and images will not render correctly, as the paths do not contain the absolute path to the asset. Links to internal files can only be previewed when the documentation is generated with Antora.

The next section discusses this in more detail.

### Are You Working With Inline Code Examples, Images, and Attachments?

If, however, you're linking to local files, such as inline code examples, images, and attachments, then you need to [install Antora's command-line tools](./docs/install-antora.md).
This is because the Live Preview plugin won’t know the complete path to the local file, so won’t be able to correctly render a link to it.
All other kinds of links should work properly, however.

In this case, you need to use Antora to regenerate the documentation and manually check if there are any broken links or if something looks amiss.
Alternatively, you could use a tool, such as [NPM’s broken-link-checker](https://www.npmjs.com/package/broken-link-checker), to check broken links for you, on the pages that you changed.

Next, you need to learn how to [build the docs](./docs/build-the-docs.md) from the command line and how to review the changes in your browser.

### Now You're Ready to Contribute

Now that you've installed the required tools, you're ready to contribute.
So it’s time to learn [the AsciiDoc basics](./docs/what-is-asciidoc.md).
Then, you can create meaningful commits and a PR with your changes.

## Styling the Docs

If you find a bug in the look and feel of the ownCloud documentation or want to suggest an improvement, you can find all the information that you need in [the docs-ui repository](https://github.com/owncloud/docs-ui/blob/master/README.adoc).

## How To Generate PDFs

To generate the PDF copies of the three manuals (administration, developer, and user), you need to have `asciidoctor-pdf`, and GNU make installed installed.
If they’re installed, run the command below in the root directory of the repository, to generate the manuals.

```console
make pdf
```

**Note:** the custom ownCloud PDF theme references a custom font, *Times New Roman*, in place of the packaged Times Roman font, as Times Roman doesn't support a wide enough character set to render the manuals correctly.

If you have this font available on your system, you need to copy it (all four variants: _normal_, _italic_, _bold_, and _bold-italic_), to the `fonts` directory. If you don't, then you'll have to copy the closest matching font family to _Times New Roman_ that you do have, and then update `resources/themes/owncloud-theme.yml`.

If you want to use your available system fonts, here’s where you can find them:

| Operating System | Font Directory |
|---|---|
| [macOS](https://support.apple.com/en-bh/HT201749) | `/Library/Fonts` |
| [Linux](https://medium.com/source-words/how-to-manually-install-update-and-uninstall-fonts-on-linux-a8d09a3853b0) | `/usr/share/fonts/` or `~/.local/share/fonts` |
| [Windows](https://support.microsoft.com/en-us/help/314960/how-to-install-or-remove-a-font-in-windows) | `%windir%\fonts` |

Alternatively, you can use free fonts, available online from various font directories.
Two of the most well known are [Google Fonts](https://fonts.google.com/) and [Font Squirrel](https://www.fontsquirrel.com/).

---

The PDF files will be generated in the build directory, and will be named after the configuration file.
The build directory is called `build` and is located in the root of the repository.

The Make target invokes [asciidoctor-pdf](https://github.com/asciidoctor/asciidoctor-pdf), passing it:

1. **[The configuration file](https://github.com/asciidoctor/asciidoctor-pdf/blob/master/docs/theming-guide.adoc) to use** (*which you can find more details about below*).
  This contains the list of files to use as the PDF's source material, along with front-matter. The front-matter includes details such as whether to render a table of contents, the icon set to use, and the images base directory. See below for details on how to generate the initial configuration file, if it is missing.
2. **The custom theme directory and the custom theme file.**
  This ensures that the defaults are overridden, where relevant, to ensure that the generated PDF is as close to the current ownCloud style as possible.

**Note:** Depending on the size of the manual, PDF generation may take some time.

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

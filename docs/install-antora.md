# Install Antora

Installing Antora on your local development (virtual) machine doesn't take *too* much time, based on whether you install the tools directly.

**Please note:** if you just want to make text changes, then installing [the AsciiDoc Live Preview Plugin](https://asciidoctor.org/docs/editing-asciidoc-with-live-preview/), whether as a Browser plugin, or as part of your text editor or IDE, may be sufficient for your needs.

## Install The Antora Tools Locally

To install all the Antora tools on your local machine will take a bit of time and effort. Before you get started, make sure that your development machine is one of [the supported hardware platforms](https://docs.antora.org/antora/1.0/supported-platforms/#platforms).

After that, install the system requirements for your platform, whether that's [Linux](https://docs.antora.org/antora/1.0/install/linux-requirements/), [macOS](https://docs.antora.org/antora/1.0/install/macos-requirements/), or [Microsoft Windows](https://docs.antora.org/antora/1.0/install/windows-requirements/). These include the base build tools, Node 8, and NVM.

Your system must have installed `yarn`. If this is not the case, [install yarn](https://yarnpkg.com/lang/en/docs/install) following the installation notes on the referenced site. When `yarn` is installed, type following command in the root of your local docs repository to install all necessary dependencies:

```console
yarn install
```

**Note:** if you identify issues because you have used `yarn install` delete the `node_modules` directory and rerun `yarn install`.

With the dependencies and Antora tools installed, you’re ready to [build the documentation](./build-the-docs.md) locally.

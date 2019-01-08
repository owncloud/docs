# Install Antora

Installing Antora on your local development (virtual) machine doesn't take *too* much time, based on whether you install the tools directly, or use the official Antora Docker container.

**Please note:** if you just want to make text changes, then installing [the AsciiDoc Live Preview Plugin](https://asciidoctor.org/docs/editing-asciidoc-with-live-preview/), whether as a Browser plugin, or as part of your text editor or IDE, may be sufficient for your needs.

## Use The Docker Container

If you’re looking for the simplest path to making Antora available, so that you can build the documentation and preview the documentation locally then, assuming that you have Docker already installed, run the following two commands.

```console
# Install the Antora Docker container in your local Docker registry.
docker pull owncloudci/antora:latest

# Install NPM’s serve command, which is an easy way of serving static content.
yarn global add serve
```

After the commands finishes executing, you’re ready to [build the documentation](./build-the-docs.md).
You can find out more about *Serve* in [the official NPM documentation](https://www.npmjs.com/package/serve#usage).

## Install The Antora Tools Locally

To install all the Antora tools on your local machine will take a little bit of time and effort.
Before you get started, make sure that your development machine is one of [the supported hardware platforms](https://docs.antora.org/antora/1.0/supported-platforms/#platforms).

After that, install the system requirements for your platform, whether that's [Linux](https://docs.antora.org/antora/1.0/install/linux-requirements/), [macOS](https://docs.antora.org/antora/1.0/install/macos-requirements/), or [Microsoft Windows](https://docs.antora.org/antora/1.0/install/windows-requirements/).
These include the base build tools, Node 8, and NVM.

Your system must have installed `yarn`. If this is not the case, [install yarn](https://yarnpkg.com/lang/en/docs/install)
following the installation notes on the referenced site. When `yarn` is installed, type following command
in the root of your local docs repository to install all necessary dependencies:

```console
make setup
```

**Note:** if you identify issues because you have used `yarn install` instead of `make setup` delete
the `node_modules` directory and rerun `make setup`.

With the dependencies and Antora tools installed, you’re ready to [build the documentation](./build-the-docs.md) locally.

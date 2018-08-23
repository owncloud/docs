# Instal Antora

Installing Antora on your local development (virtual) machine doesn't take *too* much time, but there are a number of tools to install.
If you just want to make text changes, then installing the Asciidoc Live Preview Plugin may be sufficient for your needs.

Before you get started, make sure that your development machine is one of [the supported hardware platforms](https://docs.antora.org/antora/1.0/supported-platforms/#platforms).
After that, install the system requirements for your platform, whether that's [Linux](https://docs.antora.org/antora/1.0/install/linux-requirements/), [macOS](https://docs.antora.org/antora/1.0/install/macos-requirements/), or [Microsoft Windows](https://docs.antora.org/antora/1.0/install/windows-requirements/).

With that done, you're now ready to install Antora's two command-line tools; these are the Antora CLI and the default Antora site generator.
To install the Antora CLI, run the command: `npm i -g @antora/cli`.
You can then test that it's installed by running the command: `antora -v`.

To install the default Antora site generator, run the command: `npm i -g @antora/site-generator-default`.
This command installs it globally.
If you want to install it locally, remove the `-g` switch.


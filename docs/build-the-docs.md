# Building the Documentation

## Install Antora's Dependencies

Before you can build the documentation, you need to install the required dependencies. To install them, you need to run `yarn install`. This will install all the dependencies specified in `package.json`.

**Note:** If your environment already has GNU make installed, you can run `make setup` instead.

```console
make setup
```

With the dependencies installed, you are now ready to build (generate) the ownCloud documentation.

## Prepared Yarn Commands

To get all prepared yarn commands run following command:

```console
yarn run

yarn run vv1.15.2
info Commands available from binary scripts: antora, blc, broken-link-checker, crc32, ecstatic, errno, esparse, esvalidate, handlebars, he, hs, http-server, isogit, js-yaml, json5, mime, mkdirp, nopt, opener, os-name, osx-release, printj, semver, sha.js, strip-ansi, supports-color, uglifyjs, write-good, writegood
info Project commands
   - antora
      antora --stacktrace generate --cache-dir cache --redirect-facility disabled --generator ./generator/generate-site.js --clean site.yml
   - linkcheck
      broken-link-checker --filter-level 3 --recursive --verbose
   - prose
      write-good --parse **/*.adoc
   - serve
      http-server public/ -d -i
   - validate
      antora --stacktrace generate --cache-dir cache --redirect-facility disabled --generator ./generator/xref-validator.js --clean site.yml
question Which command would you like to run?:
```
Please see the [documentaion](https://yarnpkg.com/lang/en/docs/cli/run/)
for more information about the the `yarn run` command.

## Generating the Documentation

The documentation can be generated in HTML and PDF formats.

### Generating HTML Documentation

There are two ways to generate the documentation in HTML format:

- Using ownCloud's custom Antora Docker Container
- Running Antora from the Command-Line

#### Using the Docker Container

To build the documentation using the Docker container, from the command line, in the root of the docs directory, run the following command:

```
docker run -ti --rm \
    -v $(pwd):/antora/ \
    -w /antora/ \
    owncloudci/nodejs:11 \
    yarn install

docker run -ti --rm \
    -v $(pwd):/antora/ \
    -w /antora/ \
    owncloudci/nodejs:11 \
    yarn antora
```

If you want to serve your changes locally you have to overwrite the default URL, which points to https://doc.owncloud.com. You can append a custom URL to the command like this:

```
docker run -ti --rm \
    -v $(pwd):/antora/ \
    -w /antora/ \
    owncloudci/nodejs:11 \
    yarn antora --url http://localhost:8080
```

These commands:

- Starts up [ownCloud's NodeJS Docker container](https://hub.docker.com/r/owncloudci/nodejs/)
- Runs Antora's `generate` command, which regenerates the documentation
- You can add the `--pull` option to update the dependent repositories, or any other available flag.

If all goes well, you will _not_ see any console output. If a copy of the container doesn't exist locally, you can pull down a copy, by running `docker pull owncloudci/nodejs:11`. Otherwise, you should see output similar to the following:

```console
Unable to find image 'owncloudci/nodejs:11' locally
11: Pulling from owncloudci/nodejs
3b37166ec614: Already exists
504facff238f: Already exists
ebbcacd28e10: Already exists
c7fb3351ecad: Already exists
2e3debadcbf7: Already exists
a5aa5acbbb21: Already exists
fec54bf92721: Already exists
37568f2dfa71: Pull complete
cec1230fab6b: Pull complete
08e882bea23f: Pull complete
78bc608ac308: Pull complete
Digest: sha256:d7706c693242c65b36b3205a52483d8aa567d09a1465707795d9273c0a99c0c2
Status: Downloaded newer image for owncloudci/nodejs:11
```

#### Using Antora from the Command-Line

Using Yarn, as in the example below, is the easiest way to build the documentation. This project has a predefined target (`antora`) which calls Antora, supplying all of the required options to build the docs, to build the documentation on any branch of [the ownCloud documentation repository](https://github.com/owncloud/docs).

```
yarn antora
```

If you want to serve your changes locally you have to overwrite the default URL, which points to https://doc.owncloud.com. You can append a custom URL to the command like this:

```console
yarn antora --url http://localhost:8080
```

### Viewing The HTML Documentation

Assuming that there are no errors, the next thing to do is to view the result in your browser. In case you have already installed a webserver, you need to make the HTML docmentation available pointing to subdirectory `public` or for easy handling use our predefined Yarn target so that you can view your changes, before committing and pushing the changes to the remote docs repository. You could also use [PHP's built-in webserver](https://secure.php.net/manual/en/features.commandline.webserver.php) as well.

The following example uses our Yarn target, to start it run the following command in the root of your docs repository:

```
yarn serve
```

This starts a simple webserver, using the `public` directory, (re)generated by `antora`, as the document root, listening on `http://localhost:8080`. Open the URL in your browser of choice and you'll see two links, as below.

![Viewing the locally generated Antora documentation](./images/viewing-the-locally-generated-antora-documentation.png)

If you're happy with your changes, as with any other change, create a set of meaningful commits and push them to the remote repository. If you're _not_ satisfied with the changes, however, continue to make further updates, as necessary, and run `antora` afterwards. Your changes will be reflected in the local version of the site that Serve is rendering.

We hope that you can see that contributing to the documentation using Antora is a pretty straight-forward process, and not _that_ demanding.

### Generating PDF Documentation

To generate the documentation in PDF format, you need to have `asciidoctor-pdf` and GNU `make` installed, as PDF generation isn't, _yet_, supported by Antora. To install `asciidoctor-pdf`, please refer to [the official installation instructions](https://asciidoctor.org/docs/asciidoctor-pdf/). To install GNU Make, please refer to the link below for your operating system:

- [Linux](https://www.cyberciti.biz/faq/howto-installing-gnu-c-compiler-development-environment-on-ubuntu/)
- [macOS](http://brewformulas.org/Make)
- [Microsoft Windows](http://gnuwin32.sourceforge.net/install.html)

When installed, run the command below in the root directory of the repository, to generate PDF versions of the _administration_, _developer_ and _user_ manuals.

```console
make pdf
```

`make pdf` invokes [asciidoctor-pdf](https://github.com/asciidoctor/asciidoctor-pdf) and passes it:

1. **The configuration file to use**

    This configuration file, based on [the asciidoctor-pdf theming guide](https://github.com/asciidoctor/asciidoctor-pdf/blob/master/docs/theming-guide.adoc), contains all the essential details required to build a PDF version of one of the manuals.

    This includes the list of files to use as the PDF's source material as well as the required YAML front-matter. The front-matter includes details such as whether to render a table of contents, the icon set to use, and the images base directory.

2. **The custom theme directory and the custom theme file**

    This ensures that the defaults are overridden, where relevant, to ensure that the generated PDF is as close to the current ownCloud style as possible.

### Viewing Build Errors

If an aspect of your change contains invalid AsciiDoc, then you'll see output similar to the example below.

```console
asciidoctor: ERROR: index.adoc: line 25: only book doctypes can contain level 0 sections
```

There, you can see:

- That an error was found
- The file it was found in
- The line of that file where it is located

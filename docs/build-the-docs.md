# Building the Documentation
[link-git]: https://git-scm.com
[link-ruby]: https://www.ruby-lang.org
[link-node]: https://nodejs.org
[link-yarn]: https://yarnpkg.com
[link-git-package]: https://git-scm.com/downloads
[link-nvm]: https://github.com/creationix/nvm
[link-nvm-installation-instructions]: https://github.com/creationix/nvm#installation
[link-prawn-gmagick]: https://github.com/asciidoctor/asciidoctor-pdf#supporting-additional-image-file-formats
[link-makepdf]: https://github.com/owncloud/docs/tree/master/bin/instructions_makepdf.md

**Table of Contents**
1. [Install the Prerequisites](#install-the-prerequisites)
2. [Install Build Dependencies](#install-build-dependencies)
3. [Prepare Your Browser](#prepare-your-browser)
3. [Prepared Yarn Commands](#prepared-yarn-commands)
4. [Generating the Documentation](#generating-the-documentation)
5. [Using the Docker Container](#using-the-docker-container)
6. [Viewing The HTML Documentation](#viewing-the-html-documentation)
7. [Generating PDF Documentation](#generating-pdf-documentation)
8. [TIPS](#tips)

## Install the Prerequisites

Before you can build the ownCloud documentation, you need to install the following software:

- [git][link-git] (command: `git`)
- [ruby][link-ruby] (command: `ruby`)
- [Node][link-node] (command: `node`)
- [Yarn][link-yarn] (command: `yarn`)

### Checking for the Prerequisites on Linux

To check if they are installed on a Linux system, run the following command:

```
dependencies=( git node npm yarn ruby ) && for i in "${dependencies[@]}"; do command -v $i; done;
```

You will see the path to each binary displayed, if it is installed.
For any that you do not see displayed, follow the instructions below to install it.
This is an example output if you have everything installed. Please consider that the home directory, root in this example, is dependent on the user you used during installing and can be different in your installation.

```
/usr/bin/git
/home/your_user/.nvm/versions/node/v14.17.0/bin/node
/home/your_user/.nvm/versions/node/v14.17.0/bin/npm
/usr/bin/yarn
/usr/bin/ruby
```

### Install Prerequisites

If one or more of these commands reports an error, then that prerequisite is not installed.
For any prerequisite that is not installed, follow the instructions below to install it.

#### git

To install git, download and install the [git package][link-git-package] for your operating system, or use your package manager if you are using Linux.

#### Ruby

To install Ruby, enter the following command:

```
sudo apt update 
sudo apt install ruby-full
```
After the installation completes, check the installed Ruby version by executing the following command:

```
ruby --version
```

#### Node

While you can install Node from the official packages, we strongly recommend that you use [NVM][link-nvm] (Node Version Manager) to install and manage Node.
Follow the [NVM installation instructions][link-nvm-installation-instructions] to set up NVM on your machine. Once you've installed NVM, use a terminal and install a Node LTS version:

The following gives you an output of the latest available LTS versions.

```
nvm ls-remote | grep "Latest LTS"

         v4.9.1   (Latest LTS: Argon)
        v6.17.1   (Latest LTS: Boron)
        v8.17.0   (Latest LTS: Carbon)
       v10.24.1   (Latest LTS: Dubnium)
       v12.22.1   (Latest LTS: Erbium)
       v14.17.0   (Latest LTS: Fermium)
```
Then install a suitable LTS version. You can install as many versions as you like or need, see example below.

```
nvm install 10.23.0
nvm install 14.17.0
```

List the installed versions

```
nvm ls
       v10.23.0
       v12.18.2
->     v14.17.0
        v15.5.1
         system
default -> 10.23.0 (-> v10.23.0)
...
```

**Important:** For docs, DO NOT use a version _above_ v10.23.0 and _below_ v14.17.0 as it may later conflict with other dependencies especially with the `yarn serve` command where you will get warnings and it may not work as expected.

**Info:** The backend to push to the web also uses node v14, see the `.drone.star` file. It is recommended to stay with the same release if possible.

Switch to a specific installed version of Node at any time, use the following command:

```
nvm use 14.17.0
```
**Important:** If you have additional concurrent terminals open, you must close these terminals first and reopen them to use the new setup.

To make a particular Node version default in new terminals, type:

```
nvm alias default 14.17.0
```

#### Yarn

To [install yarn](https://yarnpkg.com/lang/en/docs/install) following the installation instructions for your operating system.

## Install Build Dependencies

Before you can build the documentation, you must install Antora's dependencies.
To install them, you just need to run `yarn install` on the command line at the top level of the `docs` directory.
This will install all the dependencies specified in `package.json`, which is located at the top level of the `docs` directory.

It is recommended that you regularly run `yarn install` as from time to time packages are bumped to newer versions.

To generate the documentation in PDF format locally, you need to have `asciidoctor-pdf`. To install `asciidoctor-pdf`, please refer to the [official installation instructions](https://asciidoctor.org/docs/asciidoctor-pdf/#getting-started) or by typing:

```
sudo gem install asciidoctor-pdf
```

You can check the location and version of `asciidoctor-pdf` by invoking following commands:

```
whereis asciidoctor-pdf
asciidoctor-pdf: /usr/local/bin/asciidoctor-pdf

asciidoctor-pdf --version
Asciidoctor PDF 1.6.0 using Asciidoctor 2.0.12 [https://asciidoctor.org]
Runtime Environment (ruby 2.5.1p57 (2018-03-29 revision 63029) [x86_64-linux-gnu]) (lc:UTF-8 fs:UTF-8 in:UTF-8 ex:UTF-8)
```

When running a pdf build, you may get an error when using particular image formats or image formats with can contain special features like interlaced png, gif or tiff ect. To overcome this, you need to install [prawn-gmagick][link-prawn-gmagick]. Use the following commands to do so:

```
sudo apt-get install build-essential
sudo apt-get install libgraphicsmagick1-dev
sudo apt-get install ruby-dev
sudo gem install prawn-gmagick
```

With the dependencies installed, you are now ready to build (generate) the ownCloud documentation.

## Prepare Your Browser

It is very helpful to see how changes to a section will render. Therefore you can install a plugin for your browser to render .adoc files. You may use the `Asciidoctor.js Live Preview` or any other that is available for your browser - just search and install a suitable one. Post installing, check that accessing local files in the plugin settings is allowed.

Note, that rendering in the browser will not properly resolve global variables declared in e.g. `site.yml` or references to other .adoc files. The result shown in the browser may therefore look slightly different to a version that is built via ` yarn antora-local`, but is a good start to catch first typos.  

## Prepared Yarn Commands

To see all, prepared yarn commands run the following command:

```
yarn run

yarn run v1.22.5
info Commands available from binary scripts: antora, blc, broken-link-checker, crc32, ecstatic, errno, esparse, esvalidate, handlebars, he, hs, http-server, isogit, js-yaml, json5, mime, mkdirp, nopt, opener, os-name, osx-release, printj, semver, sha.js, strip-ansi, supports-color, uglifyjs, write-good, writegood
info Project commands
   - antora
      antora --stacktrace generate --cache-dir cache --redirect-facility disabled --generator ./generator/generate-site.js --clean --fetch --attribute format=html site.yml
   - antora-local
      antora --stacktrace generate --cache-dir cache --redirect-facility static --generator ./generator/generate-site.js --clean --fetch --attribute format=html --url http://localhost:8080 site.yml
   - linkcheck
      broken-link-checker --filter-level 3 --recursive --verbose
   - prose
      write-good --parse **/*.adoc
   - serve
      http-server public/ -d -i
   - validate
      antora --stacktrace generate --cache-dir cache --redirect-facility disabled --generator ./generator/xref-validator.js --clean --fetch --attribute format=html site.yml
question Which command would you like to run?:
```
Please see the [documentation](https://yarnpkg.com/lang/en/docs/cli/run/)
for more information about the the `yarn run` command.

The difference when running `antora` versus `antora-local` is that the latter command already defines 
localhost as URL where the documentation is displayed. See also: [Overwrite the Default URL](#overwrite-the-default-url) below.

## Generating the Documentation

The documentation can be generated in HTML and PDF formats.

### Generating HTML Documentation

There are two ways to generate the documentation in HTML format:

- Running Antora from the Command-Line
- Using ownCloud's custom Antora Docker Container


#### Using Antora from the Command-Line

Using Yarn, as in the example below, is the easiest way to build the documentation. This project has a predefined target (`antora`) which calls Antora, supplying all of the required options to build the docs, to build the documentation on any branch of the [ownCloud documentation repository](https://github.com/owncloud/docs).

Note that the build process is essential as it must run error free for a valid documentation. If you push a change with errors, the CI will complain in the Pull request and disallow any merging. For a quick view on the changes made and without having a full build, you can open the changed file in the browser and view it with the installed plug-in which helps finding typos and/or rendering issues quickly. 

```
yarn antora-local
```

Use the following command to view the results in the browser as they will appear on the web.

```
yarn serve
```

## Using the Docker Container

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

- Start up [ownCloud's NodeJS Docker container](https://hub.docker.com/r/owncloudci/nodejs/)
- Run Antora's `generate` command, which regenerates the documentation
- You can add the `--fetch` option to update the dependent repositories, or any other available flag.

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

## Viewing the HTML Documentation

Assuming that there are no errors, the next thing to do is to view the result in your browser. If you have already installed a webserver, you need to make the HTML documentation available pointing to subdirectory `public` or for easy handling use our predefined Yarn target so that you can view your changes, before committing and pushing the changes to the remote docs repository. You could also use [PHP's built-in webserver](https://secure.php.net/manual/en/features.commandline.webserver.php) as well.

The following example uses our Yarn target, to start it run the following command in the root of your docs repository:

```
yarn serve
```

This starts a simple webserver, using the `public` directory, (re)generated by `antora`, as the document root, listening on `http://localhost:8080`. Open the URL in your browser of choice and you'll see two links, as below.

**NOTE:** You will likely get a screen with the message "Page not found". In this case, you have to select the manual to view on the left side of the browser window. For owncloud Server, select _master_ as you usually start working there.

![Viewing the locally generated Antora documentation](./images/viewing-the-locally-generated-antora-documentation.png)

If you're happy with your changes, create a set of meaningful commits and push them to the remote repository. If you're _not_ satisfied, continue to work on the file(s) and start the build process again. Your changes will be reflected in the local version of the site that Serve is rendering.

We hope that you can see that contributing to the documentation using Antora is a pretty straight-forward process, and not _that_ demanding.

## Generating PDF Documentation

Run the command below in the top-level directory of the repository to generate PDF versions of the _administration_, _developer_ and _user_ manuals.

```console
./bin/makepdf -m
Generating version 'master' of the admin manual, dated: March 12, 2021
Generating version 'master' of the developer manual, dated: March 12, 2021
Generating version 'master' of the user manual, dated: March 12, 2021
```

`./bin/makepdf` invokes [asciidoctor-pdf](https://github.com/asciidoctor/asciidoctor-pdf) and passes:

1. **The configuration file to use**

    This configuration file, based on the [asciidoctor-pdf theming guide](https://github.com/asciidoctor/asciidoctor-pdf/blob/master/docs/theming-guide.adoc), contains all the essential details required to build a PDF version of one of the manuals.

    This includes the list of files to use as the PDF's source material as well as the required YAML front-matter. The front-matter includes details such as whether to render a table of contents, the icon set to use, and the images base directory.

2. **The custom theme directory and the custom theme file**

    This ensures that the defaults are overridden, where relevant, to ensure that the generated PDF is as close to the current ownCloud style as possible.

3. **All global variables defined in `site.yml`**

   All global variables (attributes) defined are automatically queried and passed to the PDF build process. 

See the link for more in depth technical and background information about [makepdf][link-makepdf].

### Viewing Build Errors

If an aspect of your change contains invalid AsciiDoc, then you'll see output similar to the example below.

```console
asciidoctor: ERROR: index.adoc: line 25: only book doctypes can contain level 0 sections
```

There, you can see:

- That an error was found
- The file it was found in
- The line of that file where it is located

## TIPS

### Additional Command Line Parameters

You can add additional parameters to the current defined ones. For example, defining the default URL
or additional global attributes. Just add them after the `yarn antora` command. 

### Overwrite the Default URL
If you want to serve your changes locally, you have to overwrite the default URL, which points to https://doc.owncloud.com. You can append a custom URL to the command like this:

```
yarn antora --url http://localhost:8080
 or use
yarn antora-local
```
Overwriting the default URL to local is especially helpful if you also want to check for broken links.

### Searching and Fixing Attribute Errors

It is very beneficial to use command line attributes when searching and fixing attribute errors. This can be
necessary when you get warnings like: `WARNING: skipping reference to missing attribute: <attribute-name>`

- First, you may want to check if the attribute name is used as an attribute at all. Run at the top level of the docs repo:
`grep -rn --exclude-dir={public,.git,node_modules} \{attribute-name`\
If found, check if the attribute definition is made or passed or needs exclusion. 
- If no result is found, it may be the case that the error-causing attribute is not in the master
branch but in another one. This can be identified by adding a custom attribute to the yarn antora command like:\
`--attribute the-erroring-attribute=HUGO` where HUGO can be anything that is not used and easy to grep.
- Finally, run in the `public` directory: `grep -rn HUGO`. You will see exactly in which branch and file the issue occurs.
If it is a branch other than `master` and an ongoing but not merged fix that targets this issue, you have to
merge the changes first, and then backport them to the branch. Do not forget to sync the branch post merging too.
Having done that, re-running `yarn antora` should eliminate that particular missing attribute warning.

### Fixing a Directory Not Found Error

If you get an error like: `Error: ENOENT: no such file or directory, lstat '/var/owncloud/docs/cache/`, you just need
to delete the `cache` directory with the command below (use the error path printed) and restart the build process.

```
rm -r /var/owncloud/docs/cache
```

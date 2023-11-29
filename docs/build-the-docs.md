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
4. [Prepared Yarn Commands](#prepared-yarn-commands)
5. [Generating the Documentation](#generating-the-documentation)
6. [Using the Docker Container](#using-the-docker-container)
7. [Viewing The HTML Documentation](#viewing-the-html-documentation)
<!-- 8. [Generating PDF Documentation](#generating-pdf-documentation) -->
8. [Setting up an Antora Development Environment](#setting-up-an-antora-development-environment)
9. [Using Search in Production or Development](#using-search-in-production-or-development)
10. [TIPS](#tips)

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

You will see the path to each binary displayed, if it is installed. For any that you do not see displayed, follow the instructions below to install it. This is an example output if you have everything installed. Please consider that the home directory, root in this example, is dependent on the user you used during installing and can be different in your installation.

```
/usr/bin/git
/home/<your-user>/.nvm/versions/node/v16.13.2/bin/node
/home/<your-user>/.nvm/versions/node/v16.13.2/bin/npm
/usr/bin/yarn
/usr/bin/ruby
```

### Install Prerequisites

If one or more of these commands reports an error, then that prerequisite is not installed. For any prerequisite that is not installed, follow the instructions below to install it.

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

While you can install Node from the official packages, we strongly recommend that you use [NVM][link-nvm] (Node Version Manager) to install and manage Node. Follow the [NVM installation instructions][link-nvm-installation-instructions] to set up NVM on your machine. Once you've installed NVM, use a terminal and install a Node LTS version:

The following gives you an output of the latest available LTS versions.

```
nvm ls-remote | grep "Latest LTS"

         v4.9.1   (Latest LTS: Argon)
        v6.17.1   (Latest LTS: Boron)
        v8.17.0   (Latest LTS: Carbon)
       v10.24.1   (Latest LTS: Dubnium)
      v12.22.12   (Latest LTS: Erbium)
       v14.21.3   (Latest LTS: Fermium)
       v16.20.2   (Latest LTS: Gallium)
       v18.18.2   (Latest LTS: Hydrogen)
       v20.10.0   (Latest LTS: Iron)
```
Then install a suitable LTS version. You can install as many versions as you like or need, see example below.

```
nvm install 16.13.2
```

List the installed versions

```
nvm ls
       v10.23.0
       v12.18.2
       v14.18.3
        v15.5.1
->     v16.13.2
         system
default -> 16.13.2 (-> v16.13.2)
...
```

**Important:** For docs, DO NOT use a version _above_ v10.23.0 and _below_ v14.17.0 as it may later conflict with other dependencies especially with the `yarn serve` command where you will get warnings and it may not work as expected.

**Info:** The backend to push to the web also uses node v16, see the `.drone.star` file. It is recommended to stay with the same release if possible.

Switch to a specific installed version of Node at any time, use the following command:

```
nvm use 16.13.2
```
**Important:** If you have additional concurrent terminals open, you must close these terminals first and reopen them to use the new setup.

To make a particular Node version default in new terminals, type:

```
nvm alias default 16.13.2
```

#### Yarn

To [install yarn](https://yarnpkg.com/lang/en/docs/install) following the installation instructions for your operating system.

## Install Build Dependencies

Before you can build the documentation, you must install Antora's dependencies. To install them, you just need to run:

```
yarn install
```
on the command line at the top level of the `docs` directory. This will install all the dependencies specified in `package.json`, which is located at the top level of the `docs` directory.

It is recommended that you **regularly** run `yarn install` as from time to time packages are bumped to newer versions.

<!--
To generate the documentation in PDF format locally, you need to have `asciidoctor-pdf`. To install or update `asciidoctor-pdf`, please refer to the [official installation instructions](https://asciidoctor.org/docs/asciidoctor-pdf/#getting-started) or by typing:

```
sudo gem install asciidoctor-pdf
```

You can check the location and version of `asciidoctor-pdf` by invoking following commands:

```
whereis asciidoctor-pdf
asciidoctor-pdf: /usr/local/bin/asciidoctor-pdf

asciidoctor-pdf --version
Asciidoctor PDF 2.0.3 using Asciidoctor 2.0.16 [https://asciidoctor.org]
Runtime Environment (ruby 2.7.0p0 (2019-12-25 revision 647ee6f091) [x86_64-linux-gnu]) (lc:UTF-8 fs:UTF-8 in:UTF-8 ex:UTF-8)
```

When running a pdf build, you may get an error when using particular image formats or image formats with can contain special features like interlaced png, gif or tiff ect. To overcome this, you need to install [prawn-gmagick][link-prawn-gmagick]. Use the following commands to do so:

```
sudo apt-get install build-essential
sudo apt-get install libgraphicsmagick1-dev
sudo apt-get install ruby-dev
sudo gem install prawn-gmagick
```
-->

With the dependencies installed, you are now ready to build (generate) the ownCloud documentation.

## Prepare Your Browser

It is very helpful to see how changes to a page will render without running a build - without including other data  images or attributes defined somewhere else, etc. Therefore you can install a plugin for your browser to render `.adoc` files. You may use the `Asciidoctor.js Live Preview` or any other that is available for your browser - just search and install a suitable one. Post installing, check that _accessing local files_ in the plugin settings is allowed.

The result shown in the browser may look slightly different to a version that is built via ` yarn antora-local`, but is a good start to get an impression and to catch typos made.

## Prepared Yarn Commands

To see all prepared yarn commands, run the following command `yarn run`. This will ouptput all commands with their settings, though this makes readability not easy. See the [yarn documentation](https://yarnpkg.com/lang/en/docs/cli/run/) for more information.

Here is the list of commands and when to use them

**For Production Environments**

The following build commands are used when regular content changes are made or small fixes to the UI are incorporated:

* `yarn antora`  
Used when you want to build the documentation where internal links have as base `doc.owncloud.com`. The  documentation is built for the live environment. Clicking on particular links will then direct to the docs homepage. Use only when you want to check these links or have the CI use them when building. 

* `yarn antora-local`  
**This is the command which you will use the most.** It is used when you want to build the documentation locally where internal links have as base `http://localhost:8080`. The  documentation is fully sourced locally. Ideal for checking with `yarn serve` after content has been updated or added.

* `yarn antora-staging`  
Used when you want to build the documentation where internal links have as base `doc.staging.owncloud.com`. The  documentation is built for the staging environment. Note that you manually have to move the content created in `/public` to the staging web page to access it. Note that you can also view locally with `yarn serve` which is ideal as first preview step.

* `yarn antora-bundle`  
Used when you want to build the documentation where internal links have as base `doc.staging.owncloud.com`. Compared to `antora-staging`, this uses a locally built `ui-bundle`. This build command should be used when you want to test a changed UI before rolling it out.

**For Development Environments**

The following build commands are used when bigger refactoring, changes or major upgrades including the UI are made:

* `yarn antora-dev-local`  
Used when you want to build the documentation where internal links have as base `http://localhost:8080`. Compared to `antora-staging`, it uses a different site.yml file named `site-dev.yml` which sources manuals not from GitHub but locally.

* `yarn antora-dev-bundle`  
Used when you want to build the documentation where internal links have as base `http://localhost:8080`. Compared to `antora-dev-local`, it uses a different site.yml file `site-dev.yml` which sources manuals not from GitHub but locally and uses a locally built `ui-bundle`.

## Generating the Documentation

The documentation can be generated in HTML format. <!-- and PDF formats -->

**IMPORTANT** To build the documentation locally, you must have internet access to get any referenced components or external sources.

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
    owncloudci/nodejs:16 \
    yarn install

docker run -ti --rm \
    -v $(pwd):/antora/ \
    -w /antora/ \
    owncloudci/nodejs:16 \
    yarn antora
```

If you want to serve your changes locally you have to overwrite the default URL, which points to https://doc.owncloud.com. You can append a custom URL to the command like this:

```
docker run -ti --rm \
    -v $(pwd):/antora/ \
    -w /antora/ \
    owncloudci/nodejs:16 \
    yarn antora --url http://localhost:8080
```

These commands:

- Start up [ownCloud's NodeJS Docker container](https://hub.docker.com/r/owncloudci/nodejs/)
- Run Antora's `generate` command, which regenerates the documentation
- You can add the `--fetch` option to update the dependent repositories, or any other available flag.

If all goes well, you will _not_ see any console output. If a copy of the container doesn't exist locally, you can pull down a copy, by running `docker pull owncloudci/nodejs:16`.

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

<!--
## Generating PDF Documentation

Run the command below in the top-level directory of the repository to generate PDF versions of the _administration_, _developer_ and _user_ manuals.

```console
./bin/makepdf -m
Generating version 'master' of the admin manual, dated: March 12, 2021
Generating version 'master' of the developer manual, dated: March 12, 2021
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

-->

### Viewing Build Errors

If an aspect of your change contains invalid AsciiDoc, then you'll see output similar to the example below.

```console
asciidoctor: ERROR: index.adoc: line 25: only book doctypes can contain level 0 sections
```

There, you can see:

- That an error was found
- The file it was found in
- The line of that file where it is located

## Setting up an Antora Development Environment

Setting up an Antora development environment can be necessary when doing tasks outside of classical content addition or updating. It is essential when starting a refactoring, UI changes or implementing new functionalities.

Note that all doc repositories must be local on the same filesystem level. Use any path that fits your needs like:

```
/dev/docs
/dev/docs-ocis
/dev/docs-client-desktop
...
```

There are some important steps when starting such a task. The following steps have to be done for the doc repo you are testing. Note that only the `site.yml` file of the respective repo is used for building the respective component. Other site.yml files are not used in the build process, though they may exist for testing purposes.

* Make a branch in the respective doc repos where you will do the changes necessary and check the output.  
**Do not** create pull requests before you are sure a build returns the correct results.

* If there are more repos affected by the changes intended, you need to select the one repo for building, that includes all repos (components) that will be changed. That repo is the source for the next step.  

* Run `bin/prepare_site_yml` in the repo you are developing on or the one that includes all required repos to get a `site-dev.yml`.  
This file **will not** get published and will always stay local. It is a mirror of the current `site.yml` but the URLs formerly pointing to GitHub and the respective repos will get changed to fetch the components locally.

* Before you start changing, run `yarn install` to have the dependencies updated.
 
* Depending on what you are developing on, either run: `yarn antora-dev-local` or `yarn antora-dev-bundle` from the repo you want to buid from which will use the formerly created `site-dev.yml`.

* Finally, run `yarn serve` to see the result of the build.

* If the changes are fine, create a PR from the respective branches and continue as usual.

* If the changes need to be dropped, run `yarn install` from the master branch in the repos with changes again to revert any dependencies that may have changed.

Note that you may need changes and testing in more than one component like `docs` or `docs-ocis` to get a correct final result.

**IMPORTANT**

Though components get sourced locally when running `yarn antora-dev-xxx`, some content will still get pulled from external sources when defined in a page. This means that, for development, you still must have an internet connection, like when doing normal builds. If an internet connection is not present, errors will be thrown and the build stops.

## Using Search in Production or Development

The search bar is the component on the top right of the documentation where one can enter a term and get matches. If something is found, the matches are displayed as suggestions that can be clicked.

For "normal" changes, search is not necessary and may only complicate building commands and delay building times. To use the search functionality during production or development, see [Prepared Yarn Commands](#prepared-yarn-commands) for details, some prerequisites apply. This is not only true for changes in the documentation, but also for UI changes.

Note that ownCloud currently uses Elasticsearch version 7.x. All internal scripts and builds are therefore aligned to it and *must not* be changed, though you can use any latest minor/patch release.

Follow this procedure to show and use search and populate an index:

1. Create an `es-docker-compose.yml` file with the following content. Note that no security or passwords is needed to be set up as it is only used locally:

    ```
    version: '3'
    services:
      elasticsearch:
        image: elasticsearch:7.17.15
        ports:
          - 9200:9200
          - 9300:9300
        environment:
          - discovery.type=single-node
          - xpack.security.enabled=false
    ```

2. Start the container with the `up -d` command, use `down` to stop it.

    ```
    docker compose -f es-docker-compose.yml up -d
    ```

3. To avoid a CORS Policy error, the browser must be prepared to allow access to the local Elasticsearch container. If this is not prepared, no search is possible and the browser console will return the following error:
    ```
    Access to XMLHttpRequest at 'http://localhost:9200/' from origin 'http://localhost:8080' has been blocked by CORS policy: No 'Access-Control-Allow-Origin' header is present on the requested resource.
    ```
    There are several ways to fix this, only one is shown when using Chrome browsers. Install the plugin named [Allow CORS: Access-Control-Allow-Origin](https://chrome.google.com/webstore/detail/lhobafahddgcelffkeicbaginigeejlf).

4. When building docs, the following environment variables must be added to the build process. Note that you can use any `yarn antora-xxx` command:
    ```
    UPDATE_SEARCH_INDEX=true \
    ELASTICSEARCH_NODE=http://localhost:9200 \
    ELASTICSEARCH_INDEX=docs \
    ELASTICSEARCH_WRITE_AUTH=x:y \
    yarn antora-dev-local
    ```
    Note that `ELASTICSEARCH_WRITE_AUTH` is necessary for building though it does not do any authentication. A value for that envvar must not be omitted but can be any dummy value you like in the format of at minimum two characters separated by a colon.

    Running the build now also returns on the console:
    ```
    elastic: generate search index
    elastic: rebuild search index
    elastic: remove old search index
    elastic: create empty search index
    elastic: upload search index
    ```

5. Optionally, the status of Elasticsearch can be monitored:  
   `http://localhost:9200/_cat/indices?v=`
   ```
   green  open .geoip_databases Ygj4WI-STGmJrSeCfep7Tg 1 0  41 0 38.3mb 38.3mb
   yellow open docs             oag2dCMnS4CiSXX0Ul8plA 1 1 163 0  1.4mb  1.4mb
   ```
   To make a dummy query after the index has been created, type the following as URL in the browser and replace `term` with what you want to search for:
   `http://localhost:9200/_search?q=term`
   ```
   {"took":45,"timed_out":false,"_shards":{"total":1,"successful":1,"skipped":0,"failed":0}, ...
   ```

6. To view the build result either with `yarn serve` (Antora build) or `yarn preview` (UI build) run:
    ```
    ELASTICSEARCH_NODE=http://localhost:9200 \
    ELASTICSEARCH_INDEX=docs \
    ELASTICSEARCH_READ_AUTH=x:y \
    yarn serve
    ```

    Note that for `ELASTICSEARCH_READ_AUTH`, the same applies as for `ELASTICSEARCH_WRITE_AUTH`.

7. Open the build via the browser and enter any search term as required into the search field to see matches returned.

8. Note that building against ownCloud's hosted Elasticsearch is not possible locally though you can use it for previewing the build. To do so, type the following:
    ```
    ELASTICSEARCH_NODE=https://search.owncloud.com \
    ELASTICSEARCH_INDEX=docs \
    ELASTICSEARCH_READ_AUTH=docs:cADL6DDAKEBrkFMrvfxXEtYm \
    yarn serve
    ```

## TIPS

### Additional Command Line Parameters

You can add additional parameters to the currently defined ones or overwrite existing ones, for example, defining the default URL or additional global attributes. Just add them to the `yarn antora` command. 

### Searching and Fixing Attribute Errors

It is very beneficial to use command-line attributes when searching and fixing attribute errors. This can be necessary when you get warnings like: `WARNING: skipping reference to missing attribute: <attribute-name>`.

- First, you may want to check if the attribute name is used as an attribute at all. Run at the top level of the docs repo:
`grep -rn --exclude-dir={public,.git,node_modules} \{attribute-name}`\
If found, check if the attribute definition is made or passed or needs exclusion. 
- If no result is found, it may be the case that the error-causing attribute is not in the master
branch but in another one. This can be identified by adding a custom attribute to the yarn antora command like:\
`--attribute the-erroring-attribute=HUGO` where HUGO can be anything that is not used and easy to grep.
- Finally, run in the `public` directory: `grep -rn HUGO`. You will see exactly in which branch and file the issue occurs.
If it is a branch other than `master` and an ongoing but not merged fix that targets this issue, you have to
merge the changes first, and then backport them to the branch. Do not forget to sync the branch post merging too.
Having done that, re-running `yarn antora` should eliminate that particular missing attribute warning.

### Fixing a Directory Not Found Error

If you get an error like: `Error: ENOENT: no such file or directory, lstat '/var/owncloud/docs/cache/`, you just need to delete the `cache` directory with the command below (use the error path printed) and restart the build process.

```
rm -r /var/owncloud/docs/cache
```

### Manually Restarting CI

In case CI needs to be restarted, which can happen in the rare case it was not triggered post pushing automatically, you need to manually (re)start the CI. This can be done by creating an empty commit and pushing it. To do so, change to the branch in question and follow the git commands below:

```
git commit --allow-empty -m "restart ci"
git push
```

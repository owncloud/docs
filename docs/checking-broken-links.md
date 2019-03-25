# Checking Broken Links

## Preparation

To check broken links you need to prepare with following steps:

1. Make the compiled documentation available for browsing by using a webserver like
   [our Yarn target](./build-the-docs.md#viewing-the-html-documentation), [PHP's built-in webserver](https://secure.php.net/manual/en/features.commandline.webserver.php), Apache or NGINX
2. Install a Broken Link Checker like our Yarn target

Use the broken link checker of your choice, the following are usable examples. The command examples assume that the documentation built is accessible via `http://localhost:8080`.

**Note** You may get false positives because of sample links or addresses pointing to nowhere. This is normal and not a broken link.

**Note** It is a good advice to pipe the output of the results to a file for easy checking.

### Antora xref-validator

The Antora `xref-validator` provided by the Antora core team, is able to check [the native Antora xref links](https://docs.antora.org/antora/1.0/asciidoc/page-to-page-xref/#xref-and-page-id-anatomy). It is automatically installed when you run `yarn install` for the Antora setup in the root of your local clone of the docs repository. It doesn't check external links, but it's still a good start.

To use it, you need to pass the custom generator (in `./generators/xref-validator.js`) to the `generate` command, as in the example below.

#### Using Yarn

This is the easiest way to validate the documentation, using predefined settings.

```console
yarn validate
```

#### Using the Antora Tools On The Command-Line

If you want to use your own settings, run the command passing the necessary parameters manually, as in the example below.

```console
antora generate \
	--generator=./generators/xref-validator.js \
	site.yml
```

#### Example Output

If invalid xrefs are detected, it will output them to the console, You can see that it checks all the content source repositories and lists the file that contains the broken xref:

```console
worktree: /var/www/owncloud/docs | component: server | version: master
  path: modules/admin_manual/nav.adoc | xref: configuration/server/security/password-policy.adoc
  path: modules/admin_manual/pages/configuration/files/external_storage_configuration_gui.adoc | xref: server/import_ssl_cert.adoc
  path: modules/admin_manual/pages/configuration/files/file_sharing_configuration.adoc | xref: server/configuration/server/security/password_policy.adoc
```

### The Broken Link Checker Via Yarn

If you installed the Antora dependencies via `yarn install`, then a broken link checker is available.
You can run it using the following command:

```console
yarn linkcheck http://localhost:8080/server/index.html | grep "BROKEN"
```

#### Example Output

```console
...
├─BROKEN─ http://mechanics.flite.com/blog/2014/07/29/using-innodb-large-prefix-to-avoid-error-1071/ (BLC_UNKNOWN)
├─BROKEN─ http://bucket.hostname.domain/ (ERRNO_ENOTFOUND)
├─BROKEN─ http://hostname.domain/bucket (ERRNO_ENOTFOUND)
├─BROKEN─ https://example.com/owncloud (HTTP_404)
├─BROKEN─ https://example.com/owncloud (HTTP_404)
...
```
Note: in the example output above, only the first entry is a genuine broken link.
All the others in the list are example links, and therefore not broken.

### A general linkchecker utility

A description of ``linkchecker`` can be found [here](https://linkchecker.github.io/linkchecker/index.html) including a link to [github](https://github.com/linkchecker/linkchecker/). Follow this procedure, based on Ubuntu, to install linkchecker, which needs python2.7:

```console
sudo apt-get install python-dev
sudo apt-get install python2.7-dev

pip -V
pip 18.1 from /usr/local/lib/python3.5/dist-packages/pip (python 3.5)

which pip2.7
/usr/local/bin/pip2.7

sudo -H pip2.7 install git+https://github.com/linkchecker/linkchecker.git

linkchecker --version
LinkChecker 9.4.0 released xx.xx.xxxx
Copyright (C) 2000-2014 Bastian Kleineidam
```
Here you can find a [short manual](https://linkchecker.github.io/linkchecker/man1/linkchecker.1.html) for linkchecker. For a full description of commands you can simply type `linkchecker --help` as usual. To run a check without external link check type:

```console
linkchecker --no-status --complete http://localhost:8080
```

To run a full check including links to external sites type:

```console
linkchecker --no-status --complete --check-extern http://localhost:8080
```

#### Example Output

```console
...
URL        `https://www.archlinux.org/packages/community/any/owncloud'
Name       `stable\nversion'
Parent URL http://localhost:5000/server/admin_manual/installation/linux_installation.html, line 1232, col 1
Real URL   https://www.archlinux.org/packages/community/any/owncloud/
Check time 0.434 seconds
Info       Redirected to
           `https://www.archlinux.org/packages/community/any/owncloud/'.
Result     Error: 404 Not Found
...
```

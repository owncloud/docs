# Checking Broken Links

## Introduction

Checking for broken links is a science on its own. External webpages, internal sites and
references to anchors can cause broken links in various ways. While it looks relatively
easy to check for broken anchors, not many free tools provide this functionality.
Various tools behave and report access to links in different ways. Configuration, like the
possibility to define patterns in an elegant way to exclude link searches, is also a rare feature. 
There is no free one-fits-all tool which means you may have to use more than one tool to
differentiate real broken links from false positives or to get results the other tools may not provide.

## Preparation

To check broken links, you need to prepare with the following steps:

1. Make the compiled documentation available for browsing by using a webserver like
   [our Yarn target](./build-the-docs.md#viewing-the-html-documentation), [PHP's built-in webserver](https://secure.php.net/manual/en/features.commandline.webserver.php), Apache or NGINX
2. Build the local docs with ``yarn antora --url http://localhost:8080``
3. Use an already provided or install a Broken Link Checker

Use the broken link checker of your choice, the following are usable examples. The command examples assume that the documentation built is accessible via `http://localhost:8080`.

**Note** You may get false positives because of sample links or addresses pointing to nowhere. This is normal and not a broken link.

**Note** It is good to pipe the output of the results to a file for easy checking.

## Link Checkers provided by the Documentation
### Antora xref-validator

The Antora ``xref-validator`` provided by the Antora core team, is able to check [the native Antora xref links](https://docs.antora.org/antora/1.0/asciidoc/page-to-page-xref/#xref-and-page-id-anatomy). It is automatically installed when you run `yarn install` for the Antora setup in the root of your local clone of the docs repository. It doesn't check external links, but it's still a good start.

### Using Yarn Validate

This is the easiest way and uses the ``xref-validator`` to validate the documentation, using predefined settings.

```console
yarn validate
```

### Using the Validator with Own Settings

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
  path: modules/admin_manual/pages/configuration/files/external_storage/configuration.adoc | xref: server/import_ssl_cert.adoc
  path: modules/admin_manual/pages/configuration/files/file_sharing_configuration.adoc | xref: server/configuration/server/security/password_policy.adoc
```

### Yarn Linkcheck

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

## Publicly Available Linkcheckers

### Linkcheck by Filip Hracek

This is an extremely fast and very comfortable / configurable link checker.

A description of ``linkcheck`` can be found [here](https://github.com/filiph/linkcheck#linkcheck).
Follow [this](https://github.com/filiph/linkcheck#step-1-install-dart) procedure,
to install ``linkcheck``, which needs ``dart``:

Because ``linkcheck`` provides the possibility to use a file to exclude search patterns,
it is good advice to create a file with the following predefined content. In this example,
the file is named ``my_skip_file.txt`` and saved one level below the local docs repository.
Adapt the content to your needs.

```console
# exclude check to sub-pages of owncloud
https://owncloud.org/news
https://owncloud.org/support
https://owncloud.org/install

# do not crawl branches or client repositories
http://localhost:8080/server/10.2
http://localhost:8080/server/10.3
http://localhost:8080/server/10.4
http://localhost:8080/branded_clients
http://localhost:8080/desktop
http://localhost:8080/android
http://localhost:8080/ios

# exclude because these are denied by robots.txt anyway
https://github.com
https://gist.github.com
https://www.samba.org
https://linux.die.net
https://mycloud.org
https://www.google.de
https://www.tscp.org

```

It is good practice to first start checking excluding external pages / sites.
``linkcheck`` will report internal broken links AND broken links to anchors.
Note: you can pipe the result into a file. Just add in ``> ../linkcheck.log``.
The grep filter reduces the output to important ones. 

```console
linkcheck --skip-file ../my_skip_file.txt --no-connection-failures-as-warnings | grep "HTTP 40"
```

Fix any broken internal links found reported.

Continue with checking also external pages / sites:

```console
linkcheck -e --skip-file ../my_skip_file.txt --no-connection-failures-as-warnings | grep "HTTP 40"
```

#### Example Output

```
No URL given, checking http://localhost:8080/
Crawling...

http://localhost:8080/server/admin_manual/appliance/wnd_setup.html
- (1297:3) 'Windows ..' => http://localhost:8080/server/admin_manual/enterprise/external_storage/windows-network-drive_configuration.html#wnd-listen (HTTP 200 but missing anchor)

...

http://localhost:8080/server/admin_manual/configuration/database/linux_database_configuration.html
- (1451:3) 'https://..' => https://mariadb.com/kb/en/mariadb/xtradbinnodb-server-system-variables/%5C#innodb_large_prefix (connection failed)
- (1457:3) 'http://m..' => http://mechanics.flite.com/blog/2014/07/29/using-innodb-large-prefix-to-avoid-error-1071/ (connection failed)
```

In the example output above, the first entry ``HTTP 200 but missing anchor`` highlights a broken link to an anchor.
The second entry ``connection failed`` highlights the possibility that the page may no longer be accessible.
You have to manually check if it is a false-positive or not.

### Linkchecker by Bastian Kleineidam

A description of ``linkchecker`` can be found [here](https://linkchecker.github.io/linkchecker/index.html)
including a link to [github](https://github.com/linkchecker/linkchecker/).
Follow this procedure, based on Ubuntu, to install ``linkchecker``, which needs ``python2.7``:

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

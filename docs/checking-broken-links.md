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

The Antora ``xref-validator`` provided by the Antora core team, is able to check the [native Antora xref links](https://docs.antora.org/antora/1.0/asciidoc/page-to-page-xref/#xref-and-page-id-anatomy). It is automatically installed when you run `yarn install` for the Antora setup in the root of your local clone of the docs repository. It doesn't check external links, but it's still a good start.

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

If you installed the Antora dependencies via `yarn install`, then a broken link checker is available. To run it, you must have one terminal open and run `yarn serve` to start a http server and in another terminal using the following command:

```console
yarn linkcheck http://localhost:8080/server/next | grep "BROKEN"
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

### htmltest by Will Pimblett

This is an extremely fast and very comfortable / configurable link checker written in go.

A description of ``htmltest`` can be found [here](https://github.com/wjdp/htmltest).
Follow [this](https://dart.dev/get-dart) procedure, to install ``dart`` and 
[this](https://github.com/wjdp/htmltest#floppy_disk-installation) link to install ``htmltest``.
A [System-wide Install](https://github.com/wjdp/htmltest#system-wide-install) is recommended.

To check docs, you first need to build the actual docs running ``yarn antora-local``. This creates all necessary files in the ``public`` directory.

Then run ``htmltest -s public`` in the root of docs/ to check the build. Note that it is not mandatory to have a webserver running like ``yarn serve``. The ``-s`` option skips external link checks which speeds up time a lot and reduces the output. To include external links, omit the ``-s`` option.

Note that ``htmltest`` checks the complete public/ directory including all products and all branches built. Due to this fact, you possibly get the same entries for each product/branch affected. As a rule of thumb, first look for `next` or latest branch entries like 10.8, fix the issue, backport it if necessary and restart the procedure.

Note, to reduce false positives like 503 which are being reported by https://www.php.net/ links, filter the results for 404. Some, but only a few 404 results are false positives like `Google Playstore` links, the URL can be accessed on the browser without any issues. 

Note, run ``htmltest public`` which includes checking external links from the master branch to avoid antora build artifacts linking to the branch name.

#### Example Output

```
server/10.8/admin_manual/maintenance/export_import_instance_data.html
  hash does not exist --- server/10.8/admin_manual/maintenance/export_import_instance_data.html --> #what_is_exported
  hash does not exist --- server/10.8/admin_manual/maintenance/export_import_instance_data.html --> #known_limitations
  hash does not exist --- server/10.8/admin_manual/maintenance/export_import_instance_data.html --> ../configuration/server/occ_command.html#data_exporter
  hash does not exist --- server/10.8/admin_manual/maintenance/export_import_instance_data.html --> #known_limitations
```

As you can see in the example above, the file `admin_manual/maintenance/export_import_instance_data.html` has broken anchors. To fix the links, open `admin_manual/pages/maintenance/export_import_instance_data.adoc` (the `pages` directory has to be included in the path, `.html` replaced by `.adoc`), search for the item reported (e.g. `#what_is_exported` and correct it. When searching, replace any references to doc internal pages from `.html` to `.adoc` like `configuration/server/occ_command.html#data_exporter` --> `configuration/server/occ_command.adoc#data_exporter`


### Linkcheck by Filip Hracek

This is an extremely fast and very comfortable / configurable link checker written in go.

A description of ``linkcheck`` can be found [here](https://github.com/filiph/linkcheck#linkcheck).
Follow [this](https://github.com/filiph/linkcheck#step-1-install-dart) procedure,
to install ``linkcheck``, which needs ``dart``:

To run it, you must have one terminal open and run `yarn serve` to start a http server and in another terminal the ``linkcheck`` command:

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

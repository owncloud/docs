# Checking Broken Links

## Preparation

To check broken links you need to prepare with following steps:

1. Make the compiled documenatation available for browsing by using a webserver like 
   [NPM Serve tool](https://www.npmjs.com/package/serve) or [PHP's built-in webserver](https://secure.php.net/manual/en/features.commandline.webserver.php) or Apache or NGINX 
2. Install a Broken Link Checker

Use the broken link checker of your choice, the following two are usable examples.

The command examples assume that the documentation built is accessible via ``http://localhost:5000``.
 
### Installing ``NPM’s broken-link-checker``

Follow the link to [NPM’s broken-link-checker](https://www.npmjs.com/package/broken-link-checker) for installation details.

### Installing ``linkchecker``

A description of ``linkchecker`` can be found [here](https://linkchecker.github.io/linkchecker/index.html) including a link to [github](https://github.com/linkchecker/linkchecker/)

Follow this procedure, based on Ubuntu, to install linkchecker, which needs python2.7

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
Here you can find a [short manual](https://linkchecker.github.io/linkchecker/man1/linkchecker.1.html) for linkchecker.

For a full description of commands type:

``linkchecker --help``

## Using a link checker

The following are example commands, please adopt according your needs.

### ``NPM’s broken-link-checker``

``blc http://localhost:5000 -ro``

### ``linkchecker``

To run a check without external link check type:

``linkchecker --no-status --complete http://localhost:5000``

To run a full check including links to external sites type:

``linkchecker --no-status --complete --check-extern http://localhost:5000``




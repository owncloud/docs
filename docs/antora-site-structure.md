# Antora Site Structure for Docs
[link-asciidoc]: https://docs.asciidoctor.org/asciidoc/latest/
[link-antora]: https://antora.org
[link-playbook]: https://docs.antora.org/antora/latest/playbook/
[link-ui]: https://docs.antora.org/antora-ui-default/
[link-resource-id]: https://docs.antora.org/antora/latest/page/resource-id-coordinates/
[link-standard-directories]: https://docs.antora.org/antora/latest/standard-directories/
[link-antora-yml]: https://docs.antora.org/antora/latest/component-version-descriptor/
[link-site-yml]: https://docs.antora.org/antora/latest/playbook/#whats-an-antora-playbook
[custom-attrib-link]: https://docs.antora.org/antora/latest/page/attributes/#custom-attributes
[antora-ui-link]: https://docs.antora.org/antora-ui-default/
[docs-ui-link]: https://github.com/owncloud/docs-ui

**Table of Contents**
1. [Why Antora](#why-antora)
2. [Scope of Documentation Repositories](#scope-of-documentation-repositories)
3. [Scope of Content Accessibility](#scope-of-content-accessibility)
4. [Structure of Directories](#structure-of-directories)
5. [Scope of Antora Definitions](#scope-of-antora-definitions)
6. [The Antora UI Template](#the-antora-ui-template)

## Why Antora

The main reasons for using [Antora][link-antora] is the following:

1. It uses and extends the [asciidoc][link-asciidoc] text writing format

2. It extends asciidoc with [multi-repo][link-playbook] capabilities. Thus, the writer does not need to care about repos anymore as this is virtualized by Antora and content can be accessed in a standardized way.

3. Antora separates between writing the documentation and the [UI-Template][link-ui] defining how the content is presented.

## Scope of Documentation Repositories

The ownCloud documentation consists of a main repo named `docs` and additional product repos like the clients or others which are included as content sources defined in `site.yml`.

Our setup is made in a way, where each repo can build it's own content individually for testing and checking validity. Only the build of main repo `docs` creates documentation which is pushed to the web. There is one exception, PDF's are created AND pushed via the CI from _each_ content source.


```
main        content source

            docs-client-desktop
docs    --> docs-client-ios-app 
            docs-client-android
            ...

```
Note that the arrow from main to content source is intentionally unidirectional in our setup and should be respected. See more details about the reason below. 

### Scope of the playbook files (site.yml)

In general, only one `site.yml` file is neccessary for the whole environment and its definitions are **available to the whole site**. This `site.yml` file is located in the main repo `docs`. We have additionally for each content source its own `site.yml` for testing purposes only. The scope of these local `site.yml` files is restricted to the respective content source and any definitions made are not availabe outside. 

Due to this fact, you need to re-add all relevant attributes of the main `site.yml` file in the `site.yml` file of the content source which accesses it, else a local build will return warnings about unresolved attributes.

If you have added an attribute in a content source `site.yml` file, you must add this attibute to the main `site.yml` file to avoid a build warning (unresolved attribute) during a build of the entire documentation.

Note that this behaviour is relevant for the playbook `site.yml` files only and does not apply to the component descriptor files `antora.yml`.

## Scope of Content Accessibility

Because Antora is capable of defining additional content sources, you can access content from these resources. The setup is flat, no main/child environment. To access resources, follow the [Resource ID Coordinates][link-resource-id] scheme.

Because of the setup we have made regarding testing, the direction of the arrow is important.


**Possible**
```
docs    --> docs-client-ios-app
            └> index.adoc
```
Main (docs) can access content from any content source (like docs-client-ios-app) and vice versa *at build time* , because docs has referenced the repo (content source) and made it available to all.

**Impossible**
```
docs-client-ios-app    --> docs-client-desktop
                           └> index.adoc

docs-client-ios-app    --> docs
                           └> index.adoc

```
When doing a build of a content source (like the docs-client-ios-app) which is neccesary for testing purposes, any references to another content source or to docs will fail as the referenced content source is unknown. Those references will throw an error/warning. Even if it is not the best approach, use .html references to any other source outside the working repo.

## Structure of Directories

All doc repositories have an identical directory structure. This helps maintaining and accessing content easily.

### The Antora Directory Structure

```
modules/named-module-1/attachment
                      /examples
                      /images
                      /pages
                      /partials

       /named-module-2/attachments
                      /...
       /...
```

Please see [Standard File and Directory Set][link-standard-directories] at `Example 1` for details.

**Note that there is one important exception**:
The navigation file `nav.adoc` is under the `partials` directory and not at the level of the named-module (like ROOT or admin ect). This is necessary because only files which are in a `family directory` can be accessed from outside. This means `docs` can access e.g. `nav.adoc` at any content source like `docs-client-ios-app`.

### Other Necessary Directories

Beside the necessary directories for node, other important directories are:
```
bin/              helper scripts to maintain the documentation
book_templates/   template file(s) to create the pdf file
generator/        scripts needed by antora for the build process
lib/              extension for antora not delivered by node like tabs or remote-include-processor
pdf_web/          output directory of generated pdf files, only used locally!
public/           output directory of generated html files, only used locally!
resources/        themes necessary for creating pdf files
tmp/              temp directory used for htmltest (broken link checking)
```
### Important files

The following files are important to run a build properly; note that node related stuff is not mentioned explicitly:

```
.drone.star       define the build process steps when triggered by a PR
                  necessary for the creation of the pdf file 
antora.yml        contains source files and attributes that only belong
                  to the component (version dependent!)
package.json      define the antora environment und scripts to run at the cli
site.yml          global site definitions including attributes (version independent!)

```

## Scope of Antora Definitions

### Versioning

While you can read more details about [What is antora.yml?][link-antora-yml] and [What is site.yml (the playbook)][link-site-yml], here are some important items:

To manage versions in docs, we use branches. This means that any content based on a variable (attribute) limited to a branch must go into the component description file `antora.yml` and be maintained accordingly. Any attribute that can be used in any branch of a component must be defined in `site.yml`

### Accessibility and Availability of Attributes 

1. The scope of attributes defined in a page is limited to that page only.
2. The scope of attributes defined in `antora.yml` is limited to the branch and component where it is defined. This is also true for attributes that should be accessed from the UI-Template.
3. The scope of attributes defined in `site.yml` is _global_. The term global has two flavours in our setup:
    1. When used in the main repo `docs`, it becomes available to all sources at any time.
    2. When used in a content source, it is only availabe to the content source during a test build.
4. Attributes starting with `page-` are also available to the UI-Template when running a build. The rules above apply. This is important when defining UI content based on attributes. To access these attributes in the UI-Template use `page.attribute.name` where `name` is without leading `page-` For details see [AsciiDoc Attributes in Antora][custom-attrib-link].

## The Antora UI Template

As described on top, Antora separates the writing of text and the [presentation design][antora-ui-link]. Our presentation design is defined in the [docs-ui][docs-ui-link] repository. Any change made in the UI affects the complete documentation, careful tests are mandatory.

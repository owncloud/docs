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

**Table of Contents**
1. [Why Antora](#why-antora)
2. [Scope of Documentation Repositories](#scope-of-documentation-repositories)
3. [Scope of Content Accessibility](#scope-of-content-accessibility)
4. [Structure of Directories](#structure-of-directories)
5. [Scope of Antora Definitions](#scope-of-antora-definitions)

## Why Antora

The main reasons for using [Antora][link-antora] is the following:

1. It uses and extends the [asciidoc][link-asciidoc] text writing format

2. It extends asciidoc with [multi-repo][link-playbook] capabilities. Thus, the writer does not need to care about repos anymore as this is virtualized by Antora and content can be accessed in a standardized way.

3. Antora separates between writing the documentation and the [UI-Template][link-ui] defining how the content is presented.

## Scope of Documentation Repositories

The ownCloud documentation consists of a master repo named `docs` which includes additional product repos like the clients or others (content sources defined in `site.yml`). While each repo can be built individually for testing, only the build of docs creates documentation which is pushed to the web.

```
layer-1     layer-2
master      included repos

            docs-client-desktop
docs    --> docs-client-ios-app 
            docs-client-android
            ...

```

## Scope of Content Accessibility

Because Antora is capable of defining additional resources, you can access content from these resources. To do so, follow the [Resource ID Coordinates][link-resource-id] scheme.

**Possible**
```
docs    --> docs-client-ios-app
            └> index.adoc
```
**Impossible**
```
docs-client-ios-app    --> docs-client-desktop
                           └> index.adoc
```
The reason why you cannot access the above is because `docs-client-ios-app` has no reference to `docs-client-desktop`. Only `docs` has this info defined in its playbook `site.yml`.



## Structure of Directories

All doc repositories have an identical directory structure. This helps maintaining and accessing content easily.

### The Antora Directory Stucture

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

Beside the necessay directories for node, other important directories are:
```
bin/               helper scripts to maintain the documentation
book_templates/    template file(s) to create the pdf file
generator/         scripts needed by antora for the build process
lib/               extension for antora like tabs or kroki etc.
pdf_web/           output directory of generated pdf files, only used locally!
public/            output directory of generated html files, only used locally!
resources/         themes necessary for creating pdf files
tmp/               temp directory used for htmltest (broken link checking)
```
### Important files

The following files are important to run a build properly; note that node related stuff is not mentioned explicitly:

```
.drone.star        define the build process when running via github
antora.yml         contains source files and attributes that only belong
                   to the component (version dependent!)
package.json       define the antora environment und scripts to run at the cli
site.yml           global site definitions including attributes (version independent!)

```

## Scope of Antora Definitions

### Versioning

While you can read more details about [What is antora.yml?][link-antora-yml] and [What is site.yml (the playbook)][link-site-yml], here are some important items:

To manage versions in docs, we use branches. This means that any content based on a variable (attribute) limited to a branch must go into `antora.yml` and be maintained accordingly. Any attribute that can be used in any branch of a component must be defined in `site.yml`

### Accessibility and Availability of Attributes 

1. The scope of attributes defined in a page is limited to that page only.
2. The scope of attributes defined in `antora.yml` is limited to the branch and component where it is defined. This is also true for attributes used in the UI-Template.
3. The scope of attributes defined in `site.yml` is _global_. The term global has two flavours:
    1. When used in a level-2 repo, it stays at that level when you do a local build but becomes globally available when running a master build.
    2. When used in the master repo (level-1), it is super global and valid over all repos when running a build. This is because all the content sources are definied here and included when running the build process.
4. Attributes starting with `page-` are also available to the UI-Template when running a build. The rules above apply. This is important when defining UI content based on attributes. To acess these attributes in the UI-Template use `page.attribute.name` where `name` is without leading `page-` For details see [AsciiDoc Attributes in Antora][custom-attrib-link].

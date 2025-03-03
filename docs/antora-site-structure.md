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

The main reasons for using [Antora][link-antora] are the following:

1. It uses and extends the [asciidoc][link-asciidoc] text writing format.
   * As an example, defining tables is so much easier in asciidoc compared to using markdown.
   * Using attributes (variables), which scope can be easily determined, content can be dynamically defined.

2. It extends asciidoc with [multi-repo][link-playbook] capabilities. This is done in a way where any issues identified can be easily tracked down to the source where this happens.

3. The doc writer does not need to care about repos, or content locations, etc. anymore as this is virtualized by Antora and content can be accessed in a standardized way via [Resource ID Coordinates](https://docs.antora.org/antora/latest/page/resource-id-coordinates/).

4. You can easily extend functionalities with extensions added via `site.yml`.

5. Antora distincts writing the documentation and the [UI-Template][link-ui] defining how the content is presented. This is also done in a way where any change can be tracked down to its source.

## Scope of Documentation Repositories

The ownCloud documentation consists of a building repo named `docs` which has NO content and additional repos like ocis or the clients which are included as content sources defined in `site.yml`.

Our setup is made in a way, where each repo can build it's own content individually for local testing and checking validity. Only the build of the `docs` repo creates documentation which is pushed to the web. There is one exception, when reenabled, PDF's are created AND pushed via the CI from the content source where it applies.

Note that the `docs-main` repo only contains the entry page but no detailed product description. 


```
repo        content source

docs   -->  docs-main
            docs-ocis
            docs-client-desktop
            docs-client-ios-app 
            docs-client-android
            ...

```
Note that the arrow from docs repo to a content source is intentionally unidirectional in our setup and should be respected. See more details about the reason below. 

### Scope of playbook files (site.yml)

In general, only one `site.yml` file is neccessary building the **complete site**. This `site.yml` file is located in the `docs` repo. Additionally, we have for each content source its own `site.yml` for local building, development and testing  purposes only. The scope of these local `site.yml` files are restricted to the respective content source and any definitions made in these are not availabe outside. 

Note that this behaviour is relevant for the playbook `site.yml` files only and does not apply to the component descriptor files `antora.yml` in each content providing repo!

### Scope of attributes (site.yml

With the use of the `load-global-site-attributes` extension, common attributes are not needed to be maintained for each repo individually. These attributes are defined in the docs repo and are, if defined in the content providing repo, sourced from there. In addition, if necessary, you can re-define attributes in a repo which will then overwrite global attributes if exists. This makes local building very comfortable. You can also source for testing 'global' attributes from a local file instead loading it from docs.

If there are any global attributes that need to be updated after a merge of a particular content repo, an additional PR in the docs repo needs to be created to make that change globally available.  

## Scope of Content Accessibility

Because Antora is capable of defining additional content sources, you can access content from these resources. The setup is flat, no main/child environment. To access resources, follow the [Resource ID Coordinates][link-resource-id] scheme.

**IMPORTANT:**\
The following scheme will be bidirectional and restrictions will go away when updating to Antora 3.2 and using the Antora Atlas extension which will provide a content manifest.

Because of the setup we have made regarding testing, the direction of the arrow is important.


**Possible**
```
docs    --> docs-client-ios-app
            └> index.adoc
```
This docs master repo can access content from any content source (like docs-client-ios-app) and vice versa *at build time* , because docs has referenced the repo and made it available as content source to all.

**Impossible**
```
docs-client-ios-app    --> docs-client-desktop
                           └> index.adoc

docs-client-ios-app    --> docs
                           └> index.adoc

```
When doing a build of a content source (like the `docs-client-ios-app`) which is neccesary for testing purposes, any references to another content source or to docs will fail as the referenced content source is unknown. Those references will throw an error/warning. Even if it is not the best approach, use .html references to any other source outside the working repo.

With a futuer release of Antora, it will be possible to use a kind of map to make references in local repos at build time which are not physically included and would return errors or warnings otherwise.

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
bin/              Helper scripts to maintain the documentation
book_templates/   Template file(s) to create the pdf file
ext-antora/       Antora extensions necessary for the build process
ext-asciidoc/     Asciidoc extensions necessary for the build process
pdf_web/          Output directory of generated pdf files, currently unused!
public/           Output directory of generated html files, only used locally!
resources/        Themes necessary for creating pdf files, currently unused!
tmp/              Temp directory used for htmltest (broken link checking)
```
### Important Files

The following files are important to run a build properly.\
Note that Node related stuff is not mentioned explicitly:

```
.drone.star           Define the build process steps when triggered by a PR
package.json          Define the antora environment and scripts to run at the cli
antora.yml            Contains definitions and attributes that only belong
                      to the respective component (version dependent!)
site.yml              Global site definitions, attributes defined overwrite global ones
global-attributes.yml The file containing global attributes used by the extension.
                      Mandatory for the docs repo, optional otherwise (version dependent!)
```

## Scope of Antora Definitions

### Versioning

While you can read more details about [What is antora.yml?][link-antora-yml] and [What is site.yml (the playbook)][link-site-yml], here are some important items:

To manage versions in docs, we use branches. This means that any content based on a variable (attribute) limited to a branch must go into the component description file `antora.yml` and be maintained accordingly. Any attribute that is used in any branch of any component must be defined in the `global-attributes.yml` in the docs repo.

### Accessibility and Availability of Attributes 

1. The scope of attributes defined in a page is limited to that page only.
2. The scope of attributes defined in `antora.yml` is limited to the branch and component where it is defined. This is also true for attributes that should be accessed from the UI-Template.
3. The scope of attributes defined in `site.yml` including defined via the `global-attributes.yml` file are _global_. The term global has two flavours in our setup:
    1. When used in the building repo `docs`, it becomes available to all sources at any time.
    2. When used in a content source, it is only availabe to the content source during a local test build.
4. Attributes starting with `page-` are also available to the UI-Template when running a build. The rules above apply. This is important when defining UI content based on attributes. To access these attributes in the UI-Template use `page.attribute.name` where `name` is without leading `page-` For details see [AsciiDoc Attributes in Antora][custom-attrib-link].

**IMPORTANT**  
If used attributes are not defined during build time, Antora hard stops and files an error. You must fix those issues BEFORE creating the PR - else it never will get green. Also see the CI log for details.

## The Antora UI Template

As described on top, Antora separates the writing of text and the [presentation design][antora-ui-link]. Our presentation design is defined in the [docs-ui][docs-ui-link] repository. Any change made in the UI affects the complete documentation, careful tests are mandatory.

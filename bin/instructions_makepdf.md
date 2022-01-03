# Instructions for makepdf

## Introduction

`makepdf` generates a pdf version from a manual. Dependening on the parametrization on the command line, it builds either a given manual or all available. To create a pdf manual, `asciidoctor-pdf` is used as processor. Compared to the build to html which uses a different software from the same family, the parametrization of `asciidoctor-pdf` can not use the ui-styles, templates and attributes from the html build. In particular with regard to attributes, this can lead to unresolved "variables" which are printed as defined in the build made. To overcome this issue, an additional software (`yamlparse`) based on bash is used to dynamically create an attribute list from `site.yml` and `antora.yml` which is then added as parameter list to the pdf built. Whenever an attribute change is made in one of the `.yml` files, a new pdf build will use these attributes automatically.

## Where are PDF Files Generated to

When running `makepdf` locally, pdf files are generated into the `pdf_web` directory. This is for local viewing purposes only! The folder and the files will not get synced by git - it is exluded via the .gitignore file in the root of the repo. When CI triggers a `makepdf` run, it saves the files to a different location relevant for the webserver. The generated files are quasi-static and will only be overwritten if they exist, but not removed. This means that when having a branch switch, the former pdf file will stay untouched and can be linked - as long it will not get deleted manually! 

##  Manual Usage

To use `makepdf`, call it from the root of the repo. Dependent on the doc repo you use, the list of buildable manuals may differ.

```
bin/makepdf -h

"Usage: ./bin/makepdf [-h] [-e] [-c] [-d] [-m] [-n <${list}>]"

-h ... help"
-e ... Set failure level to ERROR (default: FATAL)
-c ... clean the ${TARGET_PDF_DIRECTORY}/ directory (contains the locally generated pdf builds)
-d ... Debug mode, prints the book to be converted. Only in combination with -m and/or -n
-m ... Build ALL available manuals
-n ... Build manual <name>. Only in combination with -m
```

##  Docker Usage

[//]: <> (More content and details to be added if needed)

When called from Docker use:

```
"commands": [
  "bin/makepdf -m",
],
```

## How a pdf is Built

The general idea of `asciidoctor-pdf` is to create a pdf from a given single file and add options to the build command, see the [CLI Options](https://docs.asciidoctor.org/asciidoctor.js/latest/cli/options/) for details. Because manuals are usually made out of multiple documents, a base document must be created which is then built to pdf. The following method is used: A book template file has to be physically present in the `book_templates/` folder. The following example file shows the basic structure and provides some settings.
```
= ownCloud Administration Manual
:toc:
:toclevels: 2
:homepage: https://github.com/owncloud/docs
:icon-set: octicon
:icons: font
:listing-caption: Listing
:source-highlighter: rouge
:version-label: Version:
:module_base_path: modules/admin_manual/pages/
The ownCloud Team <docs@owncloud.com>
{revnumber}, {revdate}
```
You can adjust the settings as needed. `:module_base_path:` is the path to the base document files of the buildable manuals and must be set accordingly. The script takes the chosen template file, adds based on the table of contents of the manual (`nav.adoc`) include statemens like below
```
include::{module_base_path}index.adoc[leveloffset=+1]

include::{module_base_path}installing.adoc[leveloffset=+1]
...
```
and pipes this as source to the processor. You can define the level how deep you want to render the table of contents with `:toclevels:`. The pdf file created locally is saved in the `pdf_web` directory with a naming defined by the script.

When using the debug mode `-d` of `makepdf` as described above, you see the files specified in the base document to use when generating a pdf.

## Create a New Documentation Repo

In most cases it is a good idea to copy the contents of an existing repo and adopt them to the needs. In particular you need to take care on following folders and files.
 
- Provide book template(s) .adoc file in the `book_templates` directory, adapted them to the requirements.
- Copy the `pdf_web`, `fonts` and `resources` directory.
- Make a copy of an existing `manual_config_pdf` file which must reside on the same level of the makepdf file and adopt its contents according the setup of the new repo. See the description inside the file. It will define the parameters the makepdf script will run for this repo.

### Debugging

You will find in `makedf` the creation of the `param` variable. Some of those lines and others are commented. You can uncomment them based on your debugging requirements to print a console output showing which options are created. This is useful if you test new parameters or if you run into build errors (see below).

## Build Errors

In very rare cases, it can happen that a pdf build produces errors. This should not be neglected but resolved. One issue identified (and solved) was a case when using a multi-line source bash code block which trailed with a `\`. This  code block would not work in bash, should render properly but did not due to a backend bug, see [pdf creation fails when using a codeblock that ends with \ but has no following line with content](https://github.com/asciidoctor/asciidoctor-pdf/issues/1930). In such cases, use the debug mode `-d`, take the file and create a manual build on the command line, adding all attributes and commenting out all includes. Step by step re-enable them and restart the build to see which document is failing. When the problematic file is found, make a copy of the file for backup purposes. Delete all content up to the first section and restart building. Copy back section by section and always do a build. When the problematic section is found do the same thing with the section content. When the issue has been identified, fix it to see if it will build successfully. If a pattern is identifiable, fix all instances and provide those fixes in the backup file. Finally you can drop the debug file and rename the backup file to its original name. A normal build should now succeed.

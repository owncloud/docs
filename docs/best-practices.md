# Best Practices and Tips

This page gives contributors a quick overview of tips and best practices for 
writing in AsciiDoc. It is for sure not complete nor covers all possibilities, but gives a quick
reference for common used writing and formatting tasks. For a complete reference see the
[Asciidoctor Documentation](https://asciidoctor.org/docs/).

**Table of Contents**

* [Initial Reading](#initial-reading)
* [File Locations](#file-locations)
* [Links](#links)
* [Images](#images)
* [Include](#include)
* [Table of Contents](#table-of-contents)
* [Code Blocks](#code-blocks)
* [Literal Text and Blocks](#literal-text-and-blocks)
* [Attributes](#attributes)
* [Admonition](#admonition)
* [Air Quotes](#air-quotes)
* [Preserve Line Breaks](#preserve-line-breaks)
* [Text Formatting](#text-formatting)
* [Keyboard Shortcuts and UI Button Text](#keyboard-shortcuts-and-ui-button-text)
* [Menu Selections](#menu-selections)
* [Lists](#lists)
* [Headers, Titles, Sections, Anchors and Paragraph Titles](#headers-titles-sections-anchors-and-paragraph-titles)
* [Tables](#tables)
* [TabSets](#tabsets)
* [Comments](#comments)
* [Relocating or Renaming Files](#relocating-or-renaming-files)

## Initial Reading

Here is a good starting point to get a quick Antora overview [`Three Core Antora Concepts`](https://matthewsetter.com/antoras-three-core-concepts/)

## File Locations

* All documents are written into the directory `modules`/`module_name`/`pages`/`<path>`
* All images are written into the directory `modules`/`module_name`/`assets/images`/`<path>`
* All examples are written into the directory `modules`/`module_name`/`examples`/`<path>`

When using paths to include, you might need to use the `module_name` when linking to another module,
but you must not use `pages`, `assets/images` or `examples` as the path component, only `<path>`.
See the examples in the relevant sections.

## Links

In a nutshell, there are two kind of links.
- External links (referencing content outside the documentation)
- Internal links (referencing content inside the documentation)


### External Links

Reference: [`Links`](https://asciidoctor.org/docs/asciidoc-syntax-quick-reference/#links)

A `link` follows this style: `http(s)://domain/#section[Printed Name]`

Where `#section` and `[Printed Name]` are optional components.

The `link:` prefix is **only** needed when the target is not a URI. That's because the URI protocol is an implicit 
macro (in other words, http(s): is recognized as a macro prefix of an implicit link).

Example: `https://github.com/owncloud-docker/server#launch-with-plain-docker[in the GitHub repository]`

A URL may not display correctly when it contains characters such as underscores (\_) or carets (\^)
Please see [Troubleshooting Complex URLs](https://asciidoctor.org/docs/user-manual/#complex-urls) how to solve that.

This is an example of an URL containing problematic characters which needs special treatment:
`https://www.owasp.org/index.php/Cross-site_Scripting_(XSS)`

**Strongly** in favour of using attributes which greatly improves readability while authoring the document.

```
= The Page Header
:internal-link-name-url: https://example.com/content/link_can_be_very_long

Text {internal-link-name-url}[highlighted text] text.
```

It is important that `:internal-link-name-url:` is placed directly below the page header.
Any number of these link attributes can be added. Without being mandatory, it has turned
out as a matter of good practice to end your link name with `-url`.

**NOTE** If you want to prevent automatic linking of a URL, prepend it with a backslash (\\).
This will create text but not a clickable link and can be used for example URLs.
This method helps prevent false positives when checking broken links.

Example:

```
This is an example web address: \http://example.com
```
The above example renders as: `This is an example web address: http://example.com`
but there is no link.

### Internal Links

Prefix: `xref:`

Reference: [`Cross Reference`](https://asciidoctor.org/docs/user-manual/#xref)

In a nutshell, an internal link called `Cross Reference` can link to
- a documentation file
- a section title inside a documentation file
- a reference to an anchor set inside a documentation file

All referencable content **must be** inside the directory structure of `modules/`.

An `xref` is written in following example style: `xref:module_name:<path>/file.adoc#section[Printed Name]`

Where `module_name:`, `#section` and `[Printed Name]` are optional components.
`module_name:` is mandatory when referenced content is not in the same module.
`<path>` is the path to your referenced file.

You can reference a section or an anchor inside the same file, another file - even in another module.

Example: `xref:configuration/server/occ_command.adoc#apps-commands[the Market app]`

**Strongly** in favour of this where relevant, using a ToC ([Table of Contents](#table-of-contents)) instead of a list of xref´s.

## Images

Prefix: `image`

Reference: [`Images`](https://asciidoctor.org/docs/asciidoc-syntax-quick-reference/#images)

All images have to be stored in a path under `modules`/`module_name`/`assets/images`/`<path>`

An `image` is written in following example style: `image:<path>/image_name[Alternative Image Text]`

Example: `image:configuration/files/encryption1.png[Encryption]`

**IMPORTANT**
Please be advised, in case you use an Alternative Image Text, not to use double quotes to highlight some text elements.
Double quotes will be rendered properly when the html documentation is built, but creating the pdf will return
a warning that the string can not be parsed and the complete image link is broken. 
You can avoid that by using single quotes and ticks (not backticks!) instead.

Bad:
`image:enterprise/firewall/firewall-3.png[Protecting files tagged with "Confidential" from outside access]`

Good:
`image:enterprise/firewall/firewall-3.png[Protecting files tagged with 'Confidential' from outside access]`

## Include

Prefix: `include`

Reference: [`Include`](https://asciidoctor.org/docs/user-manual/#include-directive)

The include directive provides a way to import content from another file into the current document.

An `include` is written in following example style: `include::<path>/file[<attrlist>]`

When using `asciidoc` files to include, the `<attrlist>` option contains as example the `leveloffset=+1` to correct the level offset of the file included.

You can include example files like scripts or include documentation files.
Both types are used to make the raw documentation files easier to read and to maintain.

### Example Files Like Scripts

When creating example files, these files must be saved into a path of the examples directory: `module_name`/`examples`

The directive consists of following components:
`include::{examplesdir}<additional-path>/file.ext[]`

Example:

`include::{examplesdir}installation/post-installation-steps.sh[]`

`{examplesdir}` will be resolved by the build process automatically

### Example Files of Type `asciidoc`

If you include a standard page (a page that is stored in the pages directory) into another page, you must set the `page-partial` AsciiDoc attribute in the document header of the page being included.

```
= The Page Header
:page-partial:

Page contents.
```

Example:
`include::encryption-types.adoc[leveloffset=+1]`
(the including file in this example is in the same directory as the included file)

## Table of Contents

Prefix: `toc`

Reference: [`Table of Contents (ToC)`](https://asciidoctor.org/docs/user-manual/#user-toc)

A table of contents (ToC) is, if not otherwise defined, an index of section and subsection
titles that can be automatically generated from the pages structure when converting a
document with Asciidoctor.

The easiest way of adding a ToC is shown in the following example.

```
= The Page Header
:toc:

Page contents.
```
Please also see additional directives like:
[`toc-title`](https://asciidoctor.org/docs/user-manual/#user-toc-title),
[`toclevels`](https://asciidoctor.org/docs/user-manual/#user-toc-levels) or
[In-Document Placement](https://asciidoctor.org/docs/user-manual/#manual-placement)

**IMPORTANT** All attributes of kind `:name:` must be direct under the page header without blank lines. 

## Code Blocks

Reference: [`Listing and source code blocks`](https://asciidoctor.org/docs/asciidoc-writers-guide/#listing-and-source-code-blocks)
Reference: [`Building blocks in AsciiDoc`](https://asciidoctor.org/docs/asciidoc-writers-guide/#building-blocks-in-asciidoc)

```
[source, <language>]
----
text
  text
----
```
Optional define the `<language>`

Example:
```
[source,console]
----
subscription-manager repos --enable rhel-server-rhscl-7-rpms
----
```
You can also use `include` in code blocks to include an example.

Example:
```
[source,console]
----
include::example$installation/post-installation-steps.sh[]
----
```

### OCC Examples

When creating examples that show how to use occ, ensure that you use the `occ-command-example-prefix` attribute.
Doing so will keep all examples of its use consistent throughout the documentation.

**Note:** when used within a source code block, as in the following example, `subs="attributes+"` has to be set, otherwise it won't render properly:

```asciidoc
[source,console,subs="attributes+"]
....
{occ-command-example-prefix} -h
....
```

This will print out the following when rendered in the docs:

```html
sudo -u www-data php occ -h
```

## Literal Text and Blocks

Reference: [`Literal Text and Blocks`](https://asciidoctor.org/docs/user-manual/#literal-text-and-blocks)

Literal paragraphs and blocks display the text you write exactly as you enter it. Literal text is treated as pre-formatted text.

Example:
```
....
Checking system health.
- file permissions are ok.
....
```

## Attributes

Reference: [`Document Attributes`](https://docs.asciidoctor.org/asciidoc/latest/attributes/document-attributes/)
Reference: [`Inline Passthroughs`](https://docs.asciidoctor.org/asciidoc/latest/pass/pass-macro/)

Attributes are a way of creating a variable with content which then can be used throughout the document. Using attributes increases
readability a lot and makes it easy to change content one time for all locations used. Attributes are written on top of the page
and have the following form:

Definition:
```
:name-of-an-attribute: value
```

Usage:
```
This is some text {name-of-an-attribute} which continues here.
```

Attributes can also be used in scripts when you want to handover common used values. In this case, you must define the attributes and macros that
are handed over to the script for processing. "macros" is e.g. needed, when using inline passthroughs:

```
[subs=attributes+,+macros]
----
include...
----
```

When you have parts of texts or inside a script where you must render the content as it is, which is necessary for e.g. language constructs,
read the Antora Inline Passthroughs section referenced above.

## Admonition

Reference: [`Admonitions`](https://asciidoctor.org/docs/asciidoc-writers-guide/#admonitions)
Reference: [`Admonition blocks`](https://asciidoctor.org/docs/asciidoc-writers-guide/#admonition-blocks)

An admonition paragraph is rendered in a callout box with the admonition label — ​or its corresponding icon — ​in the gutter.

Asciidoctor provides five admonition style labels: `NOTE`, `TIP`, `IMPORTANT`, `CAUTION` and `WARNING`

### Simple Admonitions

Use this way when you just have to write text.
A simple `admonition` is written in the following style: `<label>:` Text

Example:
```
NOTE: If you have a large ownCloud installation and have
shell access, you should ...
```

### Complex Admonitions

A complex `admonition` can contain special formatting, tables, lists, literal text and blocks
and is written in the following style, where `====` define the begin/end of the admonition block:
```
[<label>]
====
your complex text
====
```
Example:

```
[TIP] 
====
We strongly encourage you to put your server in single user mode before setting up encryption.

To do so, run the following command:

....
sudo -u www-data php occ maintenance:singleuser --on
....
====
```

## Air Quotes

Reference: [`Air Quotes`](https://asciidoctor.org/docs/user-manual/#air-quotes)

If you want to quote sentences or statements but not using an admonition, you can use air quotes.
Air quotes are two double quotes on each line, emulating the gesture of making quote marks with two fingers on each hand.

Example:
```
""
Not everything that is faced can be changed.
But nothing can be changed until it is faced.
""
```

## Preserve Line Breaks

Reference: [`Line Breaks`](https://asciidoctor.org/docs/user-manual/#line-breaks)

Since adjacent lines of text are combined into a single paragraph, you can wrap paragraph text or put each
sentence or phrase on a separate line. The line breaks won’t appear in the output.

If you want the line breaks preserved, use a space followed by the plus sign `+`.
You can use this method also in tables or lists.

Example:
```
This is the first line, +
This is the next line separated by a line break.
```

## Text Formatting

Reference: [`Text Formatting`](https://asciidoctor.org/docs/user-manual/#text-formatting)

There are various ways to emphasize text.
You can use styles like `bold`, `italic`, etc respectively `quote` text.

If you want to print a tick or backtick etc as it is, you must escape it.

Please see the reference link for more details.

## Keyboard Shortcuts and UI Button Text

Reference: [`Keyboard Shortcuts`](https://asciidoctor.org/docs/user-manual/#keyboard-shortcuts)
Reference: [`UI buttonss`](https://asciidoctor.org/docs/user-manual/#ui-buttons)

You can create a button styled text like you want a user to press specific keyboard button(s) or browser text buttons.
The syntax for keyboard shortcuts is: `kbd:[key(+key)*]`
The syntax for UI button text is: `btn:[text]`

Examples:
```
kbd:[F11]
kbd:[Ctrl+T]
kbd:[Ctrl+Shift+N]
kbd:[Show disabled apps]

btn:[OK]
btn:[Open]
```

## Menu Selections

Reference: [`Menu Selections`](https://asciidoctor.org/docs/user-manual/#menu-selections)

**IMPORTANT** You must set the `:experimental:` attribute to enable the UI macros.

Trying to explain to someone how to select a menu item can be a pain. With the menu macro, the symbols do the work.
The syntax for this is: `menu:start[next > next > *]`

Example:
```
Go to menu:Settings[Admin > Apps] and click on kbd:[Show disabled apps]
```

## Lists

Reference: [`Unordered Lists`](https://asciidoctor.org/docs/user-manual/#unordered-lists)

To create a list, use the `*` sign.
You can give your list a title by adding on top of the list a `.` directly followed by the text without a space.
If you want to nest your list, use multiple `*` stars according the nesting level.
When items contain more than one line of text, leave a blank line before the next item to make the list easier to read.
If you want to add additional paragraphs or other block elements, see [`List Continuation`](https://asciidoctor.org/docs/user-manual/#list-continuation) for more details.

Example:
```
.List Title
* level 1
** level 2
*** level 3
**** level 4
***** level 5
* level 1
```
For creating complex list content, such as adding code blocks to a list element, use the following formatting to keep the content correctly linked to the list element:

.Add a source code block as part of a list element's content.
```
* list header
+
--
Your description text for the following command:

[source,console]
----
sudo service apache2 restart
----

NOTE: You MUST run this command with sudo previleges
--
```

## Headers, Titles, Sections, Anchors and Paragraph Titles

**IMPORTANT** Please use [title case](https://www.grammar-monster.com/lessons/capital_letters_title_case.htm)
for titles and sections.

Good: `Examples of Title Case`

Bad: `Examples of title case`

### Headers

Reference: [`Header`](https://asciidoctor.org/docs/user-manual/#doc-header)

The document `header` is a special set of contiguous lines at the start of the document that encapsulates the document title, author and revision information, and document-wide attributes (either built-in or user-defined). The header typically begins with a document title

### Titles

Reference: [`Titles`](https://asciidoctor.org/docs/user-manual/#document-title)

The document `title` resembles a level-0 section title, which is written using a single equal sign `=` followed by at least one space, then the text of the title. The document title must be the first level-0 section title in the document. The only content permitted above the document title are blank lines, comment lines and document-wide attribute entries.

### Sections

Reference: [`Sections`](https://asciidoctor.org/docs/user-manual/#sections)

`Sections` partition the document into a content hierarchy. A section title represents the heading for a section. Section title levels are specified by two to six equal `=` signs. The number of equal signs in front of the title represents the nesting level (using a 0-based index) of the section.

**INFO** Sections automatically create a referencable anchor.

Section numbering should be in single steps. This means you will get a warning when using `=` and then `===`.

Example:
```
= Document Title (Level 0)
== Level 1 Section Title
=== Level 2 Section Title
```
### Anchors

Note: please check for documentation build warnings or use a [broken link checker](./checking-broken-links.md) for broken references to anchors!

#### Referencing Sections with xref

Each section is by design its own reference ID called an `Anchor` which can be referenced with xref in the same or from another document. You can also give the section an own custom ID.

When using [`Auto-generated IDs`](https://asciidoctor.org/docs/user-manual/#auto-generated-ids) some rules apply:
Compared to AsciiDoc's standard, ownCloud has set its own definition:

* All characters are converted to lowercase
* Spaces, hyphens, and periods are substituted by a dash `-`

Example:
```
xref:my-section[Text to Print]
  text

== My Section
  text
```

When using [`Custom IDs`](https://asciidoctor.org/docs/user-manual/#custom-ids), those replace the auto-generated once. These are very useful when you want to define a stable anchor for linking to a section using a cross-reference. The benefit of using custom ID's is, that xref is independent of section text changes which can cause broken links.

Example:
```
xref:custom_id[Text to Print]
  text

[[custom_id]]
== My Section
  text
```

#### Using Anchors Independent of Sections

Reference: [`Defining an Anchor`](https://asciidoctor.org/docs/user-manual/#anchordef)

In the same way creating a custom ID (anchor) for sections, you can create an anchor at any location you want to reference to.

Example:
```
xref:custom_id[Text to Print]
  text

[[custom_id]]
  text
```

### Paragraph Title

Reference: [`Paragraph Title`](https://asciidoctor.org/docs/user-manual/#title)

You can assign a title to any paragraph, list, delimited block, or block macro.
In most cases, the title is displayed immediately above the content.
If the content is a figure or image, the title is displayed below the content.

The title text is rendered in a more visible style and the intention is usually to
highlight the following paragraph inside a section.

**INFO** Compared to sections, a paragraph title does not create a referencable anchor.

A block title is defined on a line above the element. The line must begin with a dot (.)
and be followed immediately by the title text.

Example:
```
.Title for this Paragraph
Text or lists or...
```

## Tables

Reference: [`Tables`](https://asciidoctor.org/docs/user-manual/#tables)

Tables are delimited by `|===` and made up of cells.
Cells are separated by a vertical bar `|`.
There are many ways to create and format tables, please see the reference for more details.
You can also take a look to already created tables in the documentation.

Example with defining table and cell width size plus the use of headers:

```
[width="80%",cols="30%,70%",options="header"]
|=== 
| Header of column 1      | Header of column 2  
| Cell in column 1, row 1 | long Cell in column 2, row 1  
| Cell in column 1, row 2 | long Cell in column 2, row 2
| Cell in column 1, row 3 | long Cell in column 2, row 3
|===
```

This example shows that columns can also be written underneath:
```
[width="90%",cols="20%,80%",options="header",]
|===
| Directory
| Description

| `data/<user>/files_encryption`
| Users’ private keys and all other keys necessary to decrypt the users’ files.

| `data/files_encryption`
| Private keys and all other keys necessary to decrypt the files stored on a system wide external storage.
|===
```

If you want to use block-level content in cells, such as a block image, you need to set the
cell type to `a`, short for "asciidoc", which treats it as a standalone AsciiDoc document.
```
[cols=",,",options="header"]
|===
|Classic theme
|Dark theme
|Light theme
a|image:themes/classic.png[ownCloud iOS App - Classic theme]
a|image:themes/dark.png[ownCloud iOS App - Dark theme]
a|image:themes/light.png[ownCloud iOS App - Light theme]
|===
```

## TabSets

ownCloud has added the AsciiDoc tabset extension for the documentation. With tabsets, you can create tabs inside
your document which is very useful, for example, for scripts in different languages for the same task.

```
[tabs]
====
Tab A::
+
--
Tab A contents
--
Tab B::
+
--
Tab B contents
--
====
```

## Comments

Reference: [`Comments`](https://asciidoctor.org/docs/user-manual/#comments)

If you want to add a comment in your page to remark a writers note which will not be rendered, use two consecutive slashes `//`

Example:
```
// Needs revision as a new release will change the parameter.
```

## Relocating or Renaming Files

The following procedure is necessary to optimize search engines (SEO).
This method will help with updating search engine results over time.

In case you relocate a page to another physical location, or you rename a page,
you have to do two things:

- Correct the path in the navigation
- Add a `:page-aliases:` attribute in the document moved

The page-alias attribute, which you can see in the example below, lists one or more pages that
redirect to the current page. This attribute is given one or more AsciiDoc files that will redirect
to the current page.

Example:
```
= Page Title
:page-aliases: upgrade/service/apache.adoc
```

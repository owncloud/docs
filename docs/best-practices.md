# Best Practices and Tips

This page gives contributors a quick overview of tips and best practices for 
writing in AsciiDoc. It is for sure not complete nor covers all possibilities, but gives a quick
refrence for common used writing and formatting tasks. For a complete reference see the
[Asciidoctor Documentation](https://asciidoctor.org/docs/).

**Table of Contents**

* [Initial Reading](#initial-reading)
* [File Locations](#file-locations)
* [Links](#links)
* [Images](#images)
* [Include](#include)
* [Code Blocks](#code-blocks)
* [Literal Text and Blocks](#literal-text-and-blocks)
* [Admonition](#admonition)
* [Air Quotes](#air-quotes)
* [Preserve Line Breaks](#preserve-line-breaks)
* [Text Formatting](#text-formatting)
* [Keyboard Shortcuts and UI Button Text](#keyboard-shortcuts-and-ui-button-text)
* [Menu Selections](#menu-selections)
* [Lists](#lists)
* [Headers, Titles, Sections and Anchors](#headers-titles-sections-and-anchors)
* [Tables](#tables)
* [Comments](#comments)

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
`<path>` is the path to your refrenced file.

You can reference a section or an anchor inside the same file, another file - even in another module.
 
Example: `xref:configuration/server/occ_command.adoc#apps-commands[the Market app]`

## Images

Prefix: `image`

Reference: [`Images`](https://asciidoctor.org/docs/asciidoc-syntax-quick-reference/#images)

All images have to be stored in a path under `modules`/`module_name`/`assets/images`/`<path>`

An `image` is written in following example style: `image:<path>/image_name[Alternative Image Text]`

Example: `image:configuration/files/encryption1.png[Encryption]`

**IMPORTANT**
Please be adviced, in case you use an Alternative Image Text, not to use double quotes to highlight some text elements.
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

Example: 
`include::{examplesdir}/installation/post-installation-steps.sh[]`
( {examplesdir} will be resolved by the build process automatically)

### Example Files of Type `asciidoc`

If you include a standard page (a page that is stored in the pages directory) into another page, you must set the `page-partial` AsciiDoc attribute in the document header of the page being included.

```
= The Page to be Included
:page-partial:

Page contents.
```

Example:
`include::encryption-types.adoc[leveloffset=+1]`
(the including file in this example is in the same directory as the included file)

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
include::{examplesdir}/installation/post-installation-steps.sh[]
----
```

## Literal Text and Blocks

Reference: [`Literal Text and Blocks`](https://asciidoctor.org/docs/user-manual/#literal-text-and-blocks)

Literal paragraphs and blocks display the text you write exactly as you enter it. Literal text is treated as preformatted text.

Example:
```
....
Checking system health.
- file permissions are ok.
....
```

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
We strongly encourage you to put your server in single user mode
before setting up encryption.

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
You can use styles like `bold`, `italic`, ect respectively `quote` text.

If you want to print a tick or backtick ect as it is, you must escape it.

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

## Headers, Titles, Sections and Anchors

### Headers

Reference: [`Header`](https://asciidoctor.org/docs/user-manual/#doc-header)

The document `header` is a special set of contiguous lines at the start of the document that encapsulates the document title, author and revision information, and document-wide attributes (either built-in or user-defined). The header typically begins with a document title

### Titles

Reference: [`Titles`](https://asciidoctor.org/docs/user-manual/#document-title)

The document `title` resembles a level-0 section title, which is written using a single equal sign `=` followed by at least one space, then the text of the title. The document title must be the first level-0 section title in the document. The only content permitted above the document title are blank lines, comment lines and document-wide attribute entries.

### Sections

Reference: [`Sections`](https://asciidoctor.org/docs/user-manual/#sections)

`Sections` partition the document into a content hierarchy. A section title represents the heading for a section. Section title levels are specified by two to six equal `=` signs. The number of equal signs in front of the title represents the nesting level (using a 0-based index) of the section.

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

Each section is by design it's own refrence ID called an `Anchor` which can be referenced with xref in the same or from another document. You can also give the section an own custom ID.

When using [`Auto-generated IDs`](https://asciidoctor.org/docs/user-manual/#auto-generated-ids) some rules apply:
Compared to AsciiDoc's standard, owncloud has set it's own definition:

* All characters are converted to lowercase
* Spaces, hyphens, and periods are substituted by a dash `-`

Example:
```
xref:my-section[Text to Print]
  text

== My Section
  text
```

When using [`Custom IDs`](https://asciidoctor.org/docs/user-manual/#custom-ids), those replace the auto-generated once. These are very useful when you want to define a stable anchor for linking to a section using a cross reference. The benefit of using custom ID's is, that xref is independent of section text changes which can cause broken links.

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

In the same way creating a custom ID (anchor) for sections, you can create an anchor at any location you want to refrence to.

Example:
```
xref:custom_id[Text to Print]
  text

[[custom_id]]
  text
```

## Tables

Reference: [`Tables`](https://asciidoctor.org/docs/user-manual/#tables)

Tables are delimited by `|===` and made up of cells.
Cells are seperated by a vertical bar `|`.
There are many ways to create and format tables, please see the refrence for more details.
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

## Comments

Reference: [`Comments`](https://asciidoctor.org/docs/user-manual/#comments)

If you want to add a comment in your page to remark a writers note which will not be rendered, use two consecutive slashes `//`

Example:
```
// Needs revision as a new release will change the parameter.
```

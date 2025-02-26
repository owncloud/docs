# Extensions

The documentation uses extensions that are added via the `site.yml` file. Some extensions are mandatory for the build process, some of them are optional. There is an own repository that provides details to each extension used plus lists extensions which are currently not used but are candidates. See the [Useful Antora and Asciidoc Extensions](https://github.com/mmattel/Antora-Asciidoc-Extensions) repository for more details.

## Mandatory Extensions

**Asciidoc**

* Add Tab Sets: `./ext-asciidoc/tabs.js`
* Include Content via URL: `./ext-asciidoc/remote-include-processor.js`
* Convert diagrams to images: `asciidoctor-kroki # integrated via npm`

**Antora**

* Create an Elastic Search Index: `./ext-antora/generate-index.js`
* Load Global Site Attributes: `./ext-antora/load-global-site-attributes.js`

## Optional Extensions

**Antora**

* Print Component Version File Table: `./ext-antora/comp-version.js`
* Print Attributes Used in Playbook: `./ext-antora/attributes-used-in-site-yml.js`
* Print Attributes Used in Component Descriptor: `./ext-antora/attributes-used-in-antora-yml.js`

## UI

Though not an Antora/Asciidoc extension, but required for presenting images:

**docs-ui**

* Medium-Zoom

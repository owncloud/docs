#
# Core configuration, can be overridden via env variables.
#
SHELL ?= bash

BUILD_DIR ?= public
FONTS_DIR ?= fonts
STYLES_DIR ?= resources/themes
CACHE_DIR ?= cache

STYLE ?= owncloud
VERSION ?= 10.0.10
REDIRECTS ?= static
PLAYBOOK ?= site.yml

#
# Print a basic help about the available targets.
#
.PHONY: help
help:
	@echo "Please use \`make <target>' where <target> is one of"
	@echo "  setup        to setup the Antora command-line tools locally via Yarn and NodeJS."
	@echo "  clean        to clean the build directory of any leftover artifacts from the previous build."
	@echo "  validate     to validate all xref links of all manuals defined within configuration."
	@echo "  html         to generate the HTML versions of all manuals defined within configuration."
	@echo "  pdf          to generate the PDF versions of the administration, developer, and user manuals."
	@echo "  check-prose  to lint English prose to support developers"

#
# Installs the Antora command-line tools along with all of its dependencies.
#
.PHONY: setup
setup:
	@echo "Installing Antora's command-line tools locally."
	yarn install

#
# Remove build artifacts from previous builds.
#
.PHONY: clean
clean:
	@echo "Cleaning up any artifacts from the previous build."
	@-rm -rf $(BUILD_DIR)
	@echo

#
# Validate xref links of all manuals.
#
.PHONY: validate
validate:
	@echo "Validating xref links of all manuals defined within configuration"
	-antora generate --pull --cache-dir $(CACHE_DIR) --redirect-facility $(REDIRECTS) --stacktrace --generator ./generators/xref-validator.js $(PLAYBOOK)
	@echo

#
# Generate HTML versions of all manuals.
#
.PHONY: html
html:
	@echo "Building HTML versions of all manuals defined within configuration"
	-antora generate --pull --cache-dir $(CACHE_DIR) --redirect-facility $(REDIRECTS) --stacktrace --generator ./generators/search.js $(PLAYBOOK)
	@echo

#
# Generate PDF versions of the core manuals.
#
.PHONY: pdf
pdf: pdf-admin pdf-developer pdf-user

#
# Generate PDF version of the administration manual.
#
.PHONY: pdf-admin
pdf-admin:
	@echo "Building PDF version of the admin manual"
	asciidoctor-pdf \
		-a pdf-stylesdir=$(STYLES_DIR)/ \
		-a pdf-style=$(STYLE) \
		-a pdf-fontsdir=$(FONTS_DIR) \
		-a examplesdir=modules/administration_manual/examples \
		-a imagesdir=modules/administration_manual/assets/images \
		-a appversion=$(VERSION) \
		--base-dir $(CURDIR) \
		--out-file server/administration_manual/ownCloud_Administration_Manual.pdf \
		--destination-dir $(BUILD_DIR) \
		books/admin.adoc

#
# Generate PDF version of the developer manual.
#
.PHONY: pdf-developer
pdf-developer:
	@echo "Building PDF version of the developer manual"
	asciidoctor-pdf \
		-a pdf-stylesdir=$(STYLES_DIR)/ \
		-a pdf-style=$(STYLE) \
		-a pdf-fontsdir=$(FONTS_DIR) \
		-a examplesdir=modules/developer_manual/examples \
		-a imagesdir=modules/developer_manual/assets/images \
		-a appversion=$(VERSION) \
		--base-dir $(CURDIR) \
		--out-file server/developer_manual/ownCloud_Developer_Manual.pdf \
		--destination-dir $(BUILD_DIR) \
		books/developer.adoc

#
# Generate PDF version of the user manual.
#
.PHONY: pdf-user
pdf-user:
	@echo "Building PDF version of the user manual"
	asciidoctor-pdf \
		-a pdf-stylesdir=$(STYLES_DIR)/ \
		-a pdf-style=$(STYLE) \
		-a pdf-fontsdir=$(FONTS_DIR) \
		-a examplesdir=modules/user_manual/examples \
		-a imagesdir=modules/user_manual/assets/images \
		-a appversion=$(VERSION) \
		--base-dir $(CURDIR) \
		--out-file server/user_manual/ownCloud_User_Manual.pdf \
		--destination-dir $(BUILD_DIR) \
		books/user.adoc

#
# Check the quality of the prose in all files.
#
.PHONY: check-prose
check-prose:
	@echo "Checking quality of the prose in all files"
	@yarn prose

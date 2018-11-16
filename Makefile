# Makefile for the documentation

# 
# Core configuration 
# These can be overridden by variables passed on the command-line or environment variables.
#
BUILDDIR      = build
FONTSDIR      = fonts
STYLESDIR     = resources/themes
STYLE         = owncloud
BASEDIR       = $(shell pwd)
APPVERSION    = 10.0.19
BRANCH        = $(shell git rev-parse --verify HEAD)

.PHONY: help clean pdf

#
# Utility functions to help out with building the manuals.
#
define generate_pdf_manual
	asciidoctor-pdf $(1) \
		-a pdf-stylesdir=$(STYLESDIR)/ \
		-a pdf-style=$(STYLE) \
		-a pdf-fontsdir=$(FONTSDIR) \
		-a examplesdir=$(BASEDIR)/modules/$(3)/examples/ \
		-a imagesdir=$(BASEDIR)/modules/$(3)/assets/images/ \
		-a appversion=$(APPVERSION) \
		--out-file $(2) \
		--destination-dir $(BUILDDIR)
endef

define optimise_pdf_manual
[ -f $(BUILDDIR)/$(1) ] && \
	cd $(BUILDDIR) \
		&& optimize-pdf $(1) \
		&& rm $(1) \
		&& rename 's/\-optimized//' * \
		&& cd -
endef

help:
	@echo "Please use \`make <target>' where <target> is one of"
	@echo "  clean    	to clean the build directory of any leftover artifacts from the previous build."
	@echo "  install    to install the Antora command-line tools."
	@echo "  pdf        to generate the PDF version of the manual."

#
# Remove any build artifacts from previous builds.
#
clean:		
	@echo -e "Cleaning up any artifacts from the previous build."
	@-rm -rf $(BUILDDIR)/*
	@echo 

#
# Generate PDF versions of the administration, developer, and user manuals.
#
pdf: clean
	@echo "Building PDF versions of the three core manuals"
	
	@echo
	@echo -e "- Generating the user manual."
	@$(call generate_pdf_manual,book.user.adoc,user_manual.pdf,user_manual)
	
	@echo -e "- Generating the developer manual."
	@$(call generate_pdf_manual,book.dev.adoc,developer_manual.pdf,developer_manual)

	@echo -e "- Generating the administration manual."
	@$(call generate_pdf_manual,book.admin.adoc,administration_manual.pdf,administration_manual)
	
	@echo
	@echo "Finished building the PDF manuals."
	@echo "The PDF copy of the manuals have been generated in the build directory: $(BUILDDIR)/."

#
# Installs the Antora command-line tools locally, so that users only have to do as little as possible
# to get up and running.
#
install: 
	@echo "Installing Antora's command-line tools (locally)"
	npm install

check_all_files_prose: 
	@echo "Checking quality of the prose in all files"
	write-good --parse modules/{administration,developer,user}_manual/**/*.adoc

FILES=$(shell git diff --staged --name-only $(BRANCH) | grep -E \.adoc$)
check_staged_files_prose: 
	@echo "Checking quality of the prose in the changed files"
	$(foreach file,$(FILES),write-good --parse $(file);)

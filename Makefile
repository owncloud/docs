# Makefile for the documentation

# Core configuration variables
BUILDDIR      = build
FONTSDIR      = fonts
STYLESDIR     = resources/themes
STYLE         = owncloud
BASEDIR       = $(shell pwd)
APPVERSION    = 10.0.19

.PHONY: help clean pdf

# Generate a PDF manual based on a book configuration file.
define generate_pdf_manual
	# Generate a PDF copy of one of the manuals
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

# Optimize a PDF file, making it as small as possible, without sacrificing quality.
define optimise_pdf_manual
[ -f $(BUILDDIR)/$(1) ] && \
	cd $(BUILDDIR) \
		&& optimize-pdf $(1) \
		&& rm $(1) \
		&& rename 's/\-optimized//' * \
		&& cd -
endef

help:		## Output the help message, showing the available targets
	@echo "Please use \`make <target>' where <target> is one of"
	@echo "  pdf        to generate the PDF version of the manual."
	@echo "  clean    	to clean the build directory of any leftover artifacts from the previous build."

clean:		## Remove any build artifacts from previous builds
	@echo "Cleaning out any artifacts from the previous build of the manual"
	@echo
	-rm -rf $(BUILDDIR)/*

pdf: clean	## Build PDF manual
	@echo "Building the latest copy of the manual from the available source files..."
	@echo
	@echo -e "- Generating the user manual."
	@$(call generate_pdf_manual,book.user.adoc,user_manual.pdf,user_manual)
	
	@echo -e "- Generating the developer manual."
	@$(call generate_pdf_manual,book.dev.adoc,developer_manual.pdf,developer_manual)

	@echo -e "- Generating the administration manual."
	@$(call generate_pdf_manual,book.admin.adoc,administration_manual.pdf,administration_manual)
	
	@echo
	@echo "...build finished."
	@echo "The PDF copy of the manuals have been generated in the build directory: $(BUILDDIR)/."

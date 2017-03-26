# Simple Makefile for turning Markdown into HTML.
# Copyright (c) Philip Conrad, 2017. All rights reserved.
# Released under the terms of the MIT License.
posts_dir := posts
infiles   := $(wildcard $(posts_dir)/*.md)
filenames := $(basename $(infiles))
outfiles  := $(foreach a, $(filenames), $(a).html)

.PHONY: help clean dist-clean

%.html: %.markdown
	pandoc -f markdown+yaml_metadata_block \
	       --template custom.html5 \
               --css reset.css \
	       --css style.css \
	       -B header.template \
	       $^ > $@
	       rename 's/\d{4}-\d{2}-\d{2}_//' $@

%.html: %.md
	pandoc -f markdown+yaml_metadata_block \
	       --template custom.html5 \
               --css reset.css \
	       --css style.css \
	       -B header.template \
	       $^ > $@
	       rename 's/\d{4}-\d{2}-\d{2}_//' $@

all: $(infiles) $(outfiles)  ## Feeds folder-local Markdown files to Pandoc.

index.md:
	# Generates an 'archives.md' based on filenames.
	python archive.py $(posts_dir) > $(posts_dir)/index.md

gh-pages: index.md  ## Prepare an HTML directory for use with gh-pages.
	# Ensure Pandoc gets ALL the markdown files.
	$(MAKE) all
	mkdir -p html/
	mv $(posts_dir)/*.html html/
	cp reset.css html/reset.css
	cp style.css html/style.css
	cp -R images html/images

serve:  ## Serve up the site on localhost using a Python webserver.
	python -m SimpleHTTPServer

clean:  ## Clean the current directory of build products.
	rm -f $(posts_dir)/*.html $(posts_dir)/index.md

dist-clean: clean-html  ## Clean current directory and destroy html/ directory.
	rm -rf $(posts_dir)/*.html $(posts_dir)/index.md

clean-html:
	rm -rf html/*.html html/*.css html/images

# Cite: https://gist.github.com/prwhite/8168133#gistcomment-1737630
help:  ## Show this help message.
	@echo 'Usage: make [target] ...'
	@echo
	@echo 'Targets:'
	@# Do fancy regex tricks to catch even lines with prerequisite targets.
	@grep -P '^(.+)\:.*?\ \ ##\ (.+)' ${MAKEFILE_LIST} \
	  | sed -r 's/\: (.+) ##/\: ##/' \
	  | column -t -c 2 -s ':#' \
	  | sed -r 's/^/  /'

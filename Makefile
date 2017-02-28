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
	       $^ >> $@

%.html: %.md
	pandoc -f markdown+yaml_metadata_block \
	       --template custom.html5 \
               --css reset.css \
	       --css style.css \
	       -B header.template \
	       $^ >> $@

all: $(infiles) $(outfiles)  ## Feeds folder-local Markdown files to Pandoc.

archives.md:
	# Generates an 'archives.md' based on filenames.
	python archive.py $(posts_dir) >> $(posts_dir)/archives.md

gh-pages: archives.md  ## Prepare an HTML directory for use with gh-pages.
	# Ensure Pandoc gets ALL the markdown files.
	$(MAKE) all
	mkdir -p html/
	mv $(posts_dir)/*.html html/
	cp reset.css html/reset.css
	cp style.css html/style.css

serve:  ## Serve up the site on localhost using a Python webserver.
	python -m SimpleHTTPServer

clean:  ## Clean the current directory of build products.
	rm -f $(posts_dir)/*.html $(posts_dir)/archives.md

dist-clean:  ## Clean current directory and destroy html/ directory.
	rm -rf $(posts_dir)/*.html html/ $(posts_dir)/archives.md

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

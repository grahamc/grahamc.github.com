---
title: Using `make' to Manage Jekyll
layout: post
disqus_id: 77c919d69586680d60025c6c47605003
---

Recently I switched from using Wordpress to Jekyll. I noticed a general trend
of using `rake` for managing the generation and deployment of the website.
Lately I've become quite fond of straight Makefiles, and ported their concepts
and utilities.

The resulting Makefile is fairly basic, but performs essential operations:

- `clean`: Delete the locally built files
- `build`: Generate the website files locally (automatically runs `clean`)
- `push`: Push the generated files to the remote server. This uses `scp` by
default.
- `new`: Generate a new Markdown document in `_posts`. Pass `TOPIC="foo"` to change the name of the generated post (`new article` by default).

To use this Makefile with Jekyll, just reconfigure the `REMOTEHOST` and
`REMOTEDIR` parameters at the bottom of the file with your own settings.

{% highlight makefile %}
deploy: build push

help:
	@echo "You may provide several parameters, like:"
	@echo "make [target] KEY=\"value\""
	@echo ""
	@echo "The following parameters are available (with the defaults): "
	@echo "REMOTEHOST=$(REMOTEHOST)"
	@echo "REMOTEDIR=$(REMOTEDIR)"
	@echo ""
	@echo "You may provide the TOPIC variable to the 'new' target."
	@echo ""

.PHONY: clean
clean:
	rm -rf _site/*

push:
	scp -r _site/* $(REMOTE)
	growlnotify -m "BLOG: Uploaded."

build: clean
	jekyll
	chmod -R 755 _site/*
	growlnotify -m "BLOG: Built."

serve: clean
	jekyll --server

new:
	echo "---" >> $(FILE)
	echo "title: $(TOPIC)" >> $(FILE)
	echo "layout: post" >> $(FILE)
	echo "published: false" >> $(FILE)
	echo "---" >> $(FILE)
	open $(FILE)

# Change these settings for your own use, for example:
# REMOTEHOST ?= yourwebsite.com
# REMOTEDIR ?= /path/to/your/webroot
# Note the lack of a / on webroot
REMOTEHOST ?= yakko
REMOTEDIR ?= ~/grahamc.com/main/public
REMOTE = $(REMOTEHOST):$(REMOTEDIR)

TOPIC ?= new article
FILE = $(shell date "+./_posts/%Y-%m-%d-$(TOPIC).markdown" | sed -e y/\ /-/)
{% endhighlight %}

> This Makefile also utilizes the Mac program Growl. If you don't use a Mac
> (or don't have Growl, remove the `growlnotify` lines.)
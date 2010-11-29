build: generate sitemap
deploy: build push
server: serve
serve: run

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

.PHONY: digest
digest:
	find ./_site/ -type f \( ! -iname ".*" \) \
	| sed "s/\/_site\///" > _site/DIGEST

sitemap: digest
	./_scripts/build_sitemap.php
	make digest

delremote:
	scp _scripts/remote_clean.sh $(REMOTE)/
	ssh yakko "bash $(REMOTEDIR)/remote_clean.sh"
	ssh yakko "rm $(REMOTEDIR)/remote_clean.sh"
	growlnotify -m "BLOG: Remote Deleted."

push: delremote
	scp -r _site/* $(REMOTE)
	growlnotify -m "BLOG: Uploaded."

generate: clean
	jekyll
	chmod -R 755 _site/*
	growlnotify -m "BLOG: Built."

run:
	jekyll --server

new:
	echo "---" >> $(FILE)
	echo "title: $(TOPIC)" >> $(FILE)
	echo "published: false" >> $(FILE)
	echo "---" >> $(FILE)
	open $(FILE)

REMOTEHOST ?= yakko
REMOTEDIR ?= ~/grahamc.com/main/public
REMOTE = $(REMOTEHOST):$(REMOTEDIR)

TOPIC ?= new article
FILE = $(shell date "+./_posts/%Y-%m-%d-$(TOPIC).markdown" | sed -e y/\ /-/)
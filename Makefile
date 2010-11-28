REMOTEHOST ?= yakko
REMOTEDIR ?= ~/grahamc.com/main/public
REMOTE = $(REMOTEHOST):$(REMOTEDIR)

build: clean generate
exec: clean exec
deploy: clean generate digest sitemap digest delremote push
server: serve

clean:
	rm -rf _site/*

.PHONY: digest
digest:
	find ./_site/ -type f \( ! -iname ".*" \) | sed "s/\/_site\///" > DIGEST

sitemap:
	./_scripts/build_sitemap.php

delremote:
	scp _scripts/remote_clean.sh $(REMOTE)/
	ssh yakko "bash $(REMOTEDIR)/remote_clean.sh"
	ssh yakko "rm $(REMOTEDIR)/remote_clean.sh"
	growlnotify -m "BLOG: Remote Deleted."

push:
	scp -r _site/* $(REMOTE)
	growlnotify -m "BLOG: Uploaded."

generate:
	jekyll
	chmod -R 755 _site/*
	growlnotify -m "BLOG: Built."

serve:
	jekyll --server

TOPIC ?= new article
FILE = $(shell date "+./_posts/%Y-%m-%d-$(TOPIC).markdown" | sed -e y/\ /-/)
new:
	echo "---" >> $(FILE)
	echo "title: $(TOPIC)" >> $(FILE)
	echo "published: false" >> $(FILE)
	echo "---" >> $(FILE)

	open $(FILE)
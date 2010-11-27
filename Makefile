build: clean generate
exec: clean exec

clean:
	rm -rf _site/*

.PHONY: digest
digest:
	find ./_site/ -type f \( ! -iname ".*" \) | sed "s/\/_site\///" > DIGEST

delremote:
	scp DIGEST yakko:~/grahamc.com/main/test/
	ssh yakko "for i in `cat DIGEST`; do rm -r \"~/grahamc.com/main/test/$i\"; done"

push:
	scp -r _site/ yakko:~/grahamc.com/main/test

generate:
	jekyll
	growlnotify -m "Blog built."

exec:
	jekyll --serve

new:
	touch `date "+./_posts/%Y-%m-%d-title-url.markdown"`

build: clean generate
exec: clean exec
deploy: clean generate digest delremote push


clean:
	rm -rf _site/*

.PHONY: digest
digest:
	find ./_site/ -type f \( ! -iname ".*" \) | sed "s/\/_site\///" > DIGEST

delremote:
	scp remote_clean.sh yakko:~/grahamc.com/main/test/
	ssh yakko "bash ~/grahamc.com/main/test/remote_clean.sh"
	ssh yakko "rm ~/grahamc.com/main/test/remote_clean.sh"
	growlnotify -m "BLOG: Remote Deleted."
push:
	scp -r _site/* yakko:~/grahamc.com/main/test
	growlnotify -m "BLOG: Uploaded."

generate:
	jekyll
	growlnotify -m "BLOG: Built."

exec:
	jekyll --serve

new:
	touch `date "+./_posts/%Y-%m-%d-title-url.markdown"`

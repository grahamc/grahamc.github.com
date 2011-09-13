---
title: "How to Create a Secure Git Repository on a Shared Server"
layout: post

disqus_id: f84b8c6a8d9e515416f78cfe493e8813
---

If you're like me, you might like hosting your private repositories yourself
Something about 
[trusting other people](http://news.cnet.com/8301-31921_3-20072755-281/dropbox-confirms-security-glitch-no-password-required/)
with my secure files gives me the willies. I also prefer keeping these files
under version control, so I began exploring setting up a git repository on my
server.

It was pretty easy, `git init --bare secure.git` to initialize a repository
at `./secure.git`. The problem with this, is even if you set the umask to 0077,
the files will become readable by all users after you push. You could re-mask
them to be 0700, but next time you push it'll store new files too permissively.

The solution is fairly easy, but it took a little bit of googling:

`git init --bare --shared=0700 secure.git`.

This causes all files in this repository to only be readable by the user who
owns the directory. If you want your files to be secure, make sure you
initialize your repository with this command, otherwise everyone will be able
to read your PGP keys.

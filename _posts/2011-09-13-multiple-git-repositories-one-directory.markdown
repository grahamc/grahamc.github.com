---
title: "How to have two git repositories in the same directory"
layout: post
excerpt:
    Managing your dotfiles with symlinks sucks, so does copy-paste.
    Keeping ~/ in a .git repository works for me, but I also wanted to version
    my .ssh/ directory, and my PGP files. Since I share my dotfiles, they
    obviously cannot be in the same repository.
---

If you were to
[search GitHub for dotfile repositories](https://github.com/search?q=dotfiles),
you would find *thousands* of them. Just perusing the top few will give you
a wonderful treasure-trove of useful tips and tricks for becoming a true
power user. This resource has truly opened my eyes to things I could be doing
better, faster.

When I struck gold and didn't want to cobble together my files yet again (IE:
every time I reinstall) I decided to begin versioning my dotfiles. I began in
the most obvious of ways: I made my home directory a git repository, ignored
all my files, and only explicitly added all the files I really wanted in there.
This worked for a while, but the files that I truly wish WERE versioned were
not - my SSH and GPG keys, and my SSH configuration. Additionally, I had a few
bash variables which contained private information that I didn't want to make
public.

The obvious solution was to put these into another repository [hosted on my
own server](http://grahamc.com/blog/create-secure-git-repository/) but
integrating that repository into my home directory is what infuriated me.

### Symlinks
The first and common method people seem to be doing is using tools like
[dotty](https://github.com/trym/dotty) or
[homesick](https://github.com/technicalpickles/homesick) to manage the
multiple repositories and setup symlinks automatically.

These tools worked fine for a little while, but they had a severe downside:
**neither of them are designed to be easy to add files back in**. This made it
very difficult to maintain or find files I had forgotten to import; it was
mostly a guess-and-check kind of situation.

They created a reasonable interface to working with themselves, but when it
came down to using **git** like it is supposed to be, it was just an enormous
headache.

Unfortunately the problem with using symlinks in this situation is inherent:
git doesn't know what you're doing, and does its best. I cannot blame git.

### A Proposed Solution
My biggest frustration with these tools were they didn't let git do what it
is good at: **manage my dammed files**. They tried to be smarter than git, and
really quite poorly. It pissed me off a good deal.

My ideal solution was letting git manage itself like I know it can,
but I just needed it to support multiple repositories in one directory.

#### If only...
If only I could have my git repository files located in, say,
`~/.git-repos/private`, but tell it to check my files out into `~/` that would
do it, right?

#### OH WAIT!
Git already provides the tools to do _exactly_ to this!

- **$GIT_DIR** - This tells Git where to look for the .git directory. In this
  way you could be in `/tmp/whatever` and manage your git repository located in
  `/home/grahamc/my-awesome-files`.
- **GIT_WORK_TREE** - This tells Git where the files are that it is tracking.
  Using this your .git directory could be in `/tmp/whatever` and actually have
  all your checked out files be put in to `/home/grahamc/my-awesome-files`.

Now we're getting somewhere!

### The Sexy Solution: `git multi`
That's right, I built it out. Using those two shell variables it was
pretty trivial, didn't require crazy dependencies, or any nasty symlinks.

Go ahead and get [these shell scripts](https://github.com/grahamc/git-multi),
drop them in to your ~/bin (or path, I suppose) and be enlightened.

#### Adding a Repository
`git multi add public git@github.com:youruser/dotfiles.git`

Blammo. Done. That's it. That even checks out the repository and everything.

#### Working on a Repository
`git multi work public`

This command opens up a bash terminal with **$GIT_DIR** and **$GIT_WORK_TREE**
already set and everything. Your git commands work like they were native.
__Wait. Mmmm... it's because they are.__

When you're done and want to commit or push? Just do that.
`git commit; git push origin master`.

For bonus points, add [`grahamc/git-multi`](https://github.com/grahamc/git-multi)
(or your own fork) as an additional repository to your home directory.

Hit me up with a pull request or comments if you have issues.


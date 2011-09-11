---
layout: post
title: Managing Remote SVN Branches in Git-SVN
disqus_id: 43dca0c8685abfc28145c00136c97ecb
---
This was a major problem I've been having with git-svn is how to handle remote
branches. There is lots of documentation on SVN, switching to Git, using
git-svn, but very little seemed to be related to creating remote branches and
then switching to them.

Turns out it was pretty obvious:

To create the branch:
{% highlight bash %}
git svn branch foo
{% endhighlight %}

To switch to the branch:
{% highlight bash %}
git branch foo remotes/foo
{% endhighlight %}

To delete a remote branch you have to do it with SVN's command line tool:
{% highlight bash %}
svn rm http://svn.foobar.org/branches/foo
{% endhighlight %}

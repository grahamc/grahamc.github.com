---
title: Git Workflow
layout: post
---

### Branches and Branching
Development will occur into topical branches to allow for easy merging in case
of an emergency deployment scenario. These branches should be made off of the
latest stable tag.

For example, if the latest release were 2.6.0 - I would branch off of the 2.6.0
tag:
{% highlight bash %}
git branch branch_name 2.6.0
{% endhighlight %}

> Because these branches occur off of stable tags, any issues the branch may
> introduce does not pollute the other work being performed.

#### Naming Branches
For organizational purposes, branches will follow a normalized naming scheme.
The basic scheme is as follows: `<type><number>_<human_name>`

The ticket's ID is used as `<number>` for easy reference, and the
`<human_name>` is simply an easy way for mere mortals to understand what it
is at a glance.

`<type>` is the type of ticket it is. For example:

- `t` for `task`
- `b` for `bug`
- `c` for `chore`

For example, for working on bug #123 where our foobilator was broken, I would
create the branch `b123_broken_foobilator`.

{% highlight bash %}
git branch b123_broken_foobilator
{% endhighlight %}

#### Easy Branch Creation
The long-form method of creating a branch and checking it out is as follows:

{% highlight bash %}
git branch b123_broken_foobilator
git checkout b123_broken_foobilator
{% endhighlight %}

However this can be simplified into a single command:
{% highlight bash %}
git checkout -b b123_broken_foobilator
{% endhighlight %}
> the `-b` flag to `checkout` causes it to create a branch and then check it
> out.

#### Release Branches
The current practice is to create a branch for a release. This will be
replaced by feature branches and conservative usage of `master`.

#### Remote Branches and Development
By default, branches are only local and cannot be accessed outside of the local
computer. To share a branch, it must be explicitly pushed to the remote
repository:

{% highlight bash %}
git push origin b123_broken_foobilator
{% endhighlight %}

> Push the b123_broken_foobilator to the remote server.

Please note that you may need to pull in changes made by other developers
before you are able to push.

#### Checking Out a Remote Branch
To check out a branch which is on GitHub, type:

{% highlight bash %}
git checkout -t origin/b123_broken_foobilator
{% endhighlight %}
> This will check out the remote branch and create a local branch of the same
> name.

### Merging
#### Merging into Master
Prior to merging into `master`, QA should sign off on every ticket
associated with the branch. Additionally, the Integrity server should be
checked to ensure that it is passing all unit and functional tests. At this
point the full suite of available browsers should be tested against. Once
these prerequisites have been met, it may be merged into `master`.

The merge should be performed by a single person designated as the `merge
master`. This is to ensure consistency and "safe" merges.

By keeping a strict, conservative practice of merging into `master` we help
ensure that the branch is always stable and ready to be deployed.


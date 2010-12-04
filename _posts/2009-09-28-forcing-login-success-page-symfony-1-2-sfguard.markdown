--- 
layout: post
title: Forcing Login Success Page, Symfony 1.2 + sfGuard
disqus_id: 3085e8b4d90134f94888747b289f5440
---
Working on my latest project, we needed to force a specific page to be sent to
after login. After quite a bit of searching, I went to the most logical
location for this information: The README. Duh.
[sfGuardPlugin v3.1.3 Readme](http://www.symfony-project.org/plugins/sfGuardPlugin/3_1_3?tab=plugin_readme)

Unfortunately, Symfony's documentation is notoriously sketchy, however this is
verifiably functional.

Add the following to your `app.yml`:
{% highlight yaml %}
all:
  sf_guard_plugin:
    success_signin_url:      '@my_route?param=value'
    success_signout_url:     module/action
{% endhighlight %}

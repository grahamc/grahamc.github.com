---
layout: post
title: Listing Users with Database Access
---

{% highlight mysql %}
SELECT User FROM mysql.db WHERE Db = 'databasename';
{% endhighlight %}

Only issue with this, is it doesn't list the users who have global permissions
(ie: `*.*`).


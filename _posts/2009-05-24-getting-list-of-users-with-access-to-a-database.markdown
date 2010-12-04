--- 
layout: post
title: Listing Users with Database Access
disqus_id: 140265860582cb6edea4f3da746e1626
---
As a part of my server migration, I've begun noting which databases to
transfer, which I can trash, and who owns them. This is pretty eye-opening,
as it lets me know which users I had forgotten to purge as they left my
services.

{% highlight mysql 1 %}
SELECT User FROM mysql.db WHERE Db = 'databasename';
{% endhighlight %}

That will retrieve all of the users that have access to databasename. Thanks
to <a href="http://ishouldbecoding.com">Elazar</a> (on Freenode) for this
solution.

Only issue with this, is it doesn't list the users who have global permissions
(ie: `*.*`). Any ideas on solutions that would include that? Or is there not a
"simpler" way.

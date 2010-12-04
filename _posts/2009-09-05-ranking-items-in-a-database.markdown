--- 
layout: post
title: Ranking Items in a Database
disqus_id: beb99657aa115445a848e3fc65af772e
---
At work recently, I was tasked to create a system that ranked items in a
database, from least to greatest based on a time measurement. Originally
I was quite blinded by the original code, which had used three nested
queries, and a dozen variables of  impenetrable names, a set of code I
won't be posting. Now, this isn't a very hard task - but let me document
the path through with I got to the simple solution. This idea wasn't
immediately obvious to me, or someone else who had quite a bit more
experience on the topic - but here we are.

### The Dataset
The dataset that I'm ranking is much more complex, however the concept is still
the same.

{% highlight mysql %}
CREATE TABLE `response` (
	id INT(11) AUTO_INCREMENT NOT NULL,
	time FLOAT NOT NULL,
	meta VARCHAR(255),
	PRIMARY KEY(id)
);
{% endhighlight %}

### Temporary Tables...Ish.
My first idea was to have a table that would be regenerated every `$increment`
(probably  an hour, maybe a minute when we were small.) These tables would be
pretty simple, just:

{% highlight mysql %}
CREATE TABLE `response_ranking` (
	id INT(11) AUTO_INCREMENT NOT NULL,
	response_id INT(11) NOT NULL,
	PRIMARY KEY(id),
	FOREIGN KEY (response_id) REFERENCES `response` (id)
);
{% endhighlight %}

And then in order to populate the database with the appropriate ranks, we would run:

{% highlight mysql %}
-- Truncate the table
TRUNCATE TABLE response_rank;

-- Put the data into the table in order by time.
INSERT INTO response_rank (response_id, time)
SELECT id AS response_id, time
FROM response
ORDER BY time;
{% endhighlight %}

The SQL code would take the data from the `response` table in order of time,
fastest to slowest, and then insert it into the `response_rank` table. The
`response_rank` table's ID would then directly be their rank amongst that
dataset. The first record would be the fastest, the 257<sup>th</sup> record
is the 257<sup>th</sup> fastest, etc. In order to find the rank for a
particular record, the query is quite simple too:

{% highlight mysql %}
SELECT id AS rank
FROM response_rank
WHERE response_id = ?;
{% endhighlight %}

### Why This is a Bad Idea (tm)
For the number of records I'll have and the size of the site, caching the data
isn't necessary. Adding that level of complexity to a smaller site isn't worth
the potential scalability it may provide.

### How I Did It
Now this may not be the most efficient way to do it, however I imagine it's
much closer to a Good Idea (tm).

Instead of regenerating indexes or pushing massive amounts of data, let's use
a simple database operation which the database can be easily optimized to do,
if it isn't already by adding an index to the time column.

I present to you, *The Better Way*:

{% highlight mysql %}
SELECT count(1) AS rank
FROM response
WHERE time < ?;
{% endhighlight %}

When you run the query, `rank` is exactly the rank within the current dataset,
with nothing waiting to be aggregated into the database, or an index needing
to be regenerated.

Now I know, this is stupidly simple, but it wasn't extremely obvious to me or
my coworker - so maybe someone else is stuck on such a simple problem too.
However, this also may not be the most efficient way to do it either - if
there's a better way, I'd love to know.
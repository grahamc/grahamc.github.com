---
title: NF Relationship Daemon
layout: post
---
## Problem
Our entire platform is based on the idea that an organization follows a strict hierarchy; it governs who can see and access what data and who performs what actions. Unfortunately that's caused us to create dozens of similar queries to get parents, grandparents, children, grandchildren, and siblings. in the midst of aggregating data, tabulating, etc. These queries reside all over the place, and many of them are buggy in one way or another, and very hard to debug (they are huge!)

## Solution
Twitter uses a separate internal webservice to determine the relationship between nodes on their social graph. Their service provides a simple frontend to perform complicated queries. Using this system they can query for all followers of `X`, or all people `X` is following, and retrieve a list of user IDs.

My proposal is to construct a very similar service to provide our relationship API. It would "speak" hierarchy. We would make calls to this internally using a webservice to generate our content.

By building this service we simplify the MySQL queries we write by already knowing which user IDs we're retrieving data for. This will simplify development and reduce bugs. This may also reduce load on the database server through simpler indexes on the data and fewer table joins.

## Our Social Graph

<a href="/resources/2011-01-13-relationships.png" target="_blank"><img src="/resources/2011-01-13-relationships-small.png" /></a>
> This is our social graph when it consists of only users and their managers, per Aharon's proposal.

## Queries

Querying the NFRD (National Field Relationship Daemon) would be performed using serialized JSON objects, as JSON parsing is available in all languages, simple, and also directly usable in a Javascript frontend.

<img src="/resources/2011-01-13-relationships-key.png" />
> The key of query terms.

### A Basic NFRD Query
A query may look like:
{% highlight javascript %}
{
    'return': ['GP', 'P'], // Query `Grandparents` and `Parent`
    'user_id': 17 // For user ID 17 (that's you)
}
{% endhighlight %}
> Requesting the parent and grandparents of user 17

Would result in:
{% highlight javascript %}
{
    'GP': [1, 2, 3],
    'P': 4, // Because there is only ever one parent, 'P' is not a hash
    'All': [1, 2, 3, 4]
}
{% endhighlight %}
> Each query would return each query term individually, as well as an `All` result for each of them grouped together for convenience.

### NFRD Queries Involving Children

Queries involving children are inherently more complicated than parents. Because you have only a direct chain of parents there is no grouping necessary, except for grouping them all together with the `All` result.

While querying children you may want to show each child individually, or all summed, or even each child, while summing all of their children. Accounting for each of the use cases is necessary to build a useful, hierarchical platform.

A query involving children looks the same:
{% highlight javascript %}
{
    'return': ['C', 'GC'], // Query `Children` and `Grandchildren`
    'user_id': 17 // For user ID 17 (that's you)
}
{% endhighlight %}
> Requesting the children and grandchildren of user 17

However would have slightly more complicated results:
{% highlight javascript %}
{
    // These are as you would expect:
    'C': [1, 2, 3], 
    'GC': [4, 5, 6, 7, 8],
    'All': [1, 2, 3, 4, 5, 6, 7, 8]
    
    // The following is a special case for children.
    'children': {
        1: [4, 5] // 5 may even be a child of 4
        2: [6, 7, 8],
        3: [] // Has no children or grandchildren
    }
}
{% endhighlight %}
> The special `children` result allows you to group results by the top-level-child, while also knowing who to aggregate into it.

### Using NFRD with MySQL
Using NFRD with MySQL would be a simple matter of taking the proper result set (ie: `[1, 2, 3]`) and putting them into a `WHERE table.field_user_id IN (1, 2, 3)` statement.

## Technical Implementation Details
While these are still very vague, my intentions are as follows:

- Use MySQL for fault-tolerant storage
- Use a compiled language (Python counts with compiled bytecode)
- Cache the data in memory using a read-through cache
- Use a basic HTTP interface for communication (for JavaScript)
- Would use a nested set or adjacency list in the MySQL database

### Why JSON?
JSON is easy to parse and generate, and is already supported by most languages. JSON is also very fast to parse with PHP, often several times faster than even a serialized array. It could also be possible to call this API directly through Javascript.

### Notes
    Davey Shafik: you would create a lookup table, with a schema like:
    Davey Shafik: user_id, related_id, level
    Davey Shafik: so say that's the user_relationships table
    Davey Shafik: then you could do:
{% highlight mysql %}
        SELECT *
        FROM users
        INNER JOIN
                user_relationships
            ON (
                users.user_id = user_relationships.related_id
                )
        WHERE
                user_id = 17
            AND level IN ('GP', 'P');
{% endhighlight %}

Nested sets work if writes are low, since it is write-heavy, and reading is fast. 



    Graham Christensen: Which is why I was considering this daemon to mangle
    those bits for us.
    Matthew Turland: Well, it will solve your problems insofar as it makes
    pulling data for relationships like grandparents, grandchildren, siblings,
    etc. more efficient.
    Matthew Turland: Are you guys sending entire queries over the wire or are
    you using stored procedures?
    Graham Christensen: they're entire queries
    Matthew Turland: Yeah, that's probably not helping. If you have MySQL 5,
    I'd recommend moving that logic to SPs and calling those from the web
    side.
    Matthew Turland: I would say move this to a web service rather than
    writing your own daemon.
    Matthew Turland: Then you can move it to its own web server(s) if you need
    to, put load balancing or caching in front of it, etc.
    Matthew Turland: You may also want to try Node.JS; I understand you had a
    bad experience with it, but spending some time learning about how to use
    it properly (and scale it!) can help a lot.


#### Reading Material
- http://omniti.com/writes/scalable-internet-architectures
- http://matthewturland.com/tag/forkr/
- http://en.wikipedia.org/wiki/Service-oriented_architecture
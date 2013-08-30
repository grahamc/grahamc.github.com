---
title: "How to delete all (or most) jobs from a beanstalk tube from the shell"
layout: post
bigimg: '/resources/2013-08-30-beanstalk-jobs.png'
---

Sometimes I need to delete lots of jobs from my beanstalk tube. In this
particular case, I had mistakenly added 3x the jobs every day for the last few
weeks. These jobs in the `snitch.site` tube is how ZippyKid keeps track of what
versions of wordpress our customers are using, ensures their configuration is
up to date, and other general housekeeping tasks.

Since we were triple queueing the jobs, it resulted in new sites not getting
updated in our client inventory system. These weren't really causing issues,
but we definitely noticed something was strange. I stumbled across this graph
of the `snitch.site` tube, and that explained it.

Now, Beanstalk doesn't have a built-in way to clear out jobs en masse, and I
wasn't particularly interested in using a library to send a few basic commands.

Instead, what I came up with was a fairly concise `expect` script, which only
uses tools installed on the vast majority of Linux systems:

### The Code

{% highlight bash %}
#!/usr/bin/expect -f
# Filename: beanstalk-purge
set timeout 1

spawn telnet [lindex $argv 0] [lindex $argv 1]
sleep 1
send "use [lindex $argv 2]\n"
expect "USING"

for {set i 1} {$i < [lindex $argv 3]} { incr i 1 } {
    send_user "Proccessing $i\n"
    expect -re {.*} {}
    send "peek-ready\n"
    expect -re {FOUND (\d*) \d*}
    send "delete $expect_out(1,string)\n"
    expect "DELETED"
}
{% endhighlight %}


### Usage

{% highlight bash %}
beanstalk-purge <host> <port> <tube> <count>
{% endhighlight %}

### Example
{% highlight bash %}
beanstalk-purge 127.0.0.1 11300 snitch.site 35000
{% endhighlight %}
> Delete the first 35,000 jobs out of the `snitch.site` tube on the beanstalk
> server located at 127.0.0.1:11300


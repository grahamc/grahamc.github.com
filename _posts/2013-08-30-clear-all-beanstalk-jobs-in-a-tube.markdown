---
title: "How to delete all (or most) jobs from a beanstalk tube from the shell"
layout: post
bigimg: '/resources/2013-08-30-beanstalk-jobs.png'
---

Sometimes I need to delete lots of jobs from my beanstalk tube. In this
particular case, I added 3 `snitch.site` jobs per site every day for the last
few weeks. These jobs are how ZippyKid performs maintenance on Customer
websites. Snitch reports the WordPress version in use, as well as updating
ZippyKid specific configuration.

Since we were triple queueing each site, we weren't able to keep up with the
work. New sites were not getting updated in our client inventory system. No
customers saw any issues, but our internal status portal's data was stale.
I stumbled across this graph of the snitch.site tube, and that explained it.

Now, Beanstalk doesn’t have a built-in way to clear out jobs en masse. I also
wasn’t particularly interested in using a library to send a few basic commands.

Instead, what I came up with was a concise expect script.  The script only uses
tools installed on the vast majority of Linux systems:

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

    beanstalk-purge <host> <port> <tube> <count>

### Example

    beanstalk-purge 127.0.0.1 11300 snitch.site 35000

> Delete the first 35,000 jobs out of the `snitch.site` tube on the beanstalk
> server located at 127.0.0.1:11300


---
layout: post
title: "Sending Mail from a Task, Symfony 1.4; Fatal error: Class 'Swift_Message' not found"
disqus_id: f07ffebb97378ba15bd53760aa73e0c4
excerpt: "Fix the pesky Symfony autoloader issue when sending email from a task."
---

While trying to build and send a fairly complicated e-mail using a template
from within a task. Unfortunately that resulted in a fairly nasty (and
annoying) bug with Symfony's autoloader:

> `Fatal error: Class 'Swift_Message' not found in apps/lib/email/DomainReportMessage.class.php on line 3`

And then the task:

{% highlight php %}
<?php
class emailTestTask extends sfBaseTask {

    /* ... configure() - nothing special */

    protected function execute($arguments = array(),
                                   $options = array()) {

        // initialize the database connection
        $databaseManager = new sfDatabaseManager($this->configuration);
        $db = $databaseManager->getDatabase($options['connection']);
        $connection = $db->getConnection();


        $c = new DomainReportMessage();
        $this->getMailer()->send($c);
    }
}
?>
{% endhighlight %}

The simple fix for this is to add a call to `$this->getMailer()` before you use the `Swift_Message`
class, which seems like a fairly basic issue with symfony's autoloader.

Here is the working code:
{% highlight php %}
<?php
class emailTestTask extends sfBaseTask {

    /* ... configure() - nothing special */

    protected function execute($arguments = array(),
                                   $options = array()) {

        // initialize the database connection
        $databaseManager = new sfDatabaseManager($this->configuration);
        $db = $databaseManager->getDatabase($options['connection']);
        $connection = $db->getConnection();

        $this->getMailer(); // These are the magic words
        $c = new DomainReportMessage();
        $this->getMailer()->send($c);
    }
}
?>
{% endhighlight %}

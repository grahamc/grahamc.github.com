---
title: Testing Symfony and Propel With PHPUnit
layout: post
---

### The Frustrated Narrative
Running PHPUnit alongside of symfony is a fairly easy matter. Including the
ProjectConfiguration file initializes the autoloader, your libraries get
set up, everything is gravy... Except when its not.

When you get into contexts, configurations, applications, database
integration, or nearly anything else that touches even the basic symfony bits,
you drag in the whole symfony stack. *Something* in the stack caused every test
to throw an [unintelligible RuntimeException](/resources/2010-11-30.txt),
with thousands of literal question marks (read: not an encoding error.)

Even through modifying symfony and PHPUnit's sourcecode, running XDebug, not
running XDebug, etc. nothing could convert those question marks into real-life,
intelligible errors. Imagine how silly I felt searching Google for "**phpunit
symfony question marks**" - nothing, as you could imagine, came up.

I had worked through both of the existing Symfony plugins,
[sfPHPUnitPlugin](http://www.symfony-project.org/plugins/sfPhpunitPlugin) and
[sfPHPUnit2Plugin](http://www.symfony-project.org/plugins/sfPHPUnit2Plugin).
One of the is very over-arching and depends on an old version of PHPUnit
(however it did work) and the newer one gave me the same issue.

After a long time of organized debugging, I devolved (as one usually does) to a
series of [shotgun debugging](http://en.wikipedia.org/wiki/Shotgun_debugging).

### How I Solved It
Firstly, you're going to need to use a bootstrap file to initialize the
context. Basic, cut and dry:

{% highlight php %}
<?php
$path = realpath(dirname(__FILE__) . '/../config/');
require_once $path . '/ProjectConfiguration.class.php';

// Initialize the application
$m = ProjectConfiguration::getApplicationConfiguration('frontend',
                                                       'testing', true);

// Now initialize the database bits
sfContext::createInstance($m);
new sfDatabaseManager($m);

error_reporting(E_ALL | E_STRICT);
ini_set('display_errors', true);
?>
{% endhighlight %}
> Drop this into `test/bootstrap.php`. Every time you run phpunit from here, you
> pass the `--bootstrap test/bootstrap.php`

{% highlight xml %}
<phpunit
    colors="true"
    verbose="true"
    convertErrorsToExceptions="true"
    convertNoticesToExceptions="true"
    convertWarningsToExceptions="true"
    stopOnFailure="true"
    processIsolation="false"
    syntaxCheck="true"
    bootstrap="test/bootstrap.php">
    
    <testsuites>
        <testsuite name="Unit Tests">
            <directory>test/unit/</directory>
        </testsuite>
    </testsuites>

    <filter>
        <blacklist>
            <directory suffix=".php">lib/vendor</directory>
            <directory suffix=".php">cache</directory>
            <exclude>
                <directory suffix=".php">lib/vendor</directory>
            </exclude>
        </blacklist>
    </filter>
</phpunit>
{% endhighlight %}
> Typing in `phpunit --bootstrap test/bootstrap.php` is pretty ridiculous, so
> drop this XML into `phpunit.xml`.

That `phpunit.xml` will make it pretty and ensure to exclude the extraneous
files which you don't want included in any coverage data. It will also
specify the bootstrap.php which you just created. At this stage you just
execute `phpunit` and all should be well.

*For the record, I never did discover the cause of the question marks. I did,
discover, however, that the trick is to enable **process isolation**.*
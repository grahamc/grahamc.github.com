--- 
layout: post
title: Sane Pre-Commit Hooks for Symfony + Git
disqus_id: 4 tag:iamgraham.net,2009:sane-pre-commit-hooks-for-symfony-git/1251087513
---
Throughout my history of working with Symfony, I've noticed a trend that
I'll make a minor edit in a database configuration file, forget to actually
regenerate the models and forms, commit the edit, and then find several days
later (when I do want to regenerate the models) that they're breaking. I then
do this little dance of going through the history finding out where exactly I
went wrong.

Today I was  working alongside [Vid Luther](http://www.phpcult.com/blog) and
running into peculiar problems. Lo and behold, it was a minor edit that I had
forgotten to test. Dammit. Company policy is pushups for fuckups, and so
well.. you know.

I began thinking about switching back to Subversion for the pre-commit
hooks, as I stupidly forgot that Git *must* have them too. (The lack of
a centralized server threw me off.) I did a bit of research, found that, in
fact, Git does have them - and in a way that I much prefer. Thus the
development began of, essentially, a locally-run continuous-integration script
to verify that none of the developers (including myself) screw anything up.

Behold, The Symfony Pre-Commit Hook For Git:

{% highlight php %}
#!/usr/bin/env php
<?php
/**
 * @author Graham Christensen <graham@grahamc.com>
 * @license Here, just take it.
 */

// A list of commands you want to run on the entire codebase.
// You could also add in tests
$test_commands = array('./symfony propel:build-sql',
                       './symfony propel:build-model',
                       './symfony propel:build-forms',
                       './symfony propel:build-filters',
                       './symfony propel:insert-sql --no-confirmation',
                       './symfony propel:data-load');

// This is pretty static, since the git repository doesn't move
$repository_parent_directory = realpath(__DIR__ . '/../../');

// Where to put the testing directory. It cleans up after itself, I
// promise. Note: if the testing directory is inside the
// repository's parent directory, it might get stuck in an infinite
// copy loop.
$test_parent_directory = '/tmp/';

// Negotiate a temporary directory that doesn't exist yet, so
// it doesn't get in the way of anything already there.
$i = 0;
do {
    $test_directory = $test_parent_directory
                    . '/git_pre_commit_hook_' . $i++;
} while (file_exists($test_directory));

// Create a testing environment
debug('Copying the working copy from '
      . $repository_parent_directory . ' to ' . $test_directory);
mkdir($test_directory);

// the run_command function is used for easy debugging of what's
// actually being executed.
$pdir = escapeshellarg($repository_parent_directory . '/');
$tdir = escapeshellarg($test_directory);
run_command('cp -r ' . $pdir . ' ' . $tdir;

// Get into it, start running the test commands
chdir($test_directory);

// Iterate over all the commands. This has to happen one by one in
// order to catch the errors as they happen. Also, the debugging
// code is the same.
foreach ($test_commands as $command) {
    // Create error files within the testing directory so they're
    // cleaned up nicely
    $error_file = $test_directory . '/errfile_'
                  . md5($command . mt_rand()) . '.err_log';

    // Pipe ALL of the command's output to the file for convenient
    // error messages.
    $cmd = $command . ' > ' . $error_file . ' 2>&1';
    exec($cmd, $r, $return_code);

    // Symfony doesn't always return something other than 0 when
    // errors occur. Because of that you have to test for both
    // conditions, note that because errorsInLog is second - it is
    // only executed if the first one doesn't pass which saves time
    // if Symfony does what it should be.
    if ($return_code != 0 || errorsInLog($error_file)) {
        // because $error_code isn't always 1 when it fails, set it
        $return_code = 1;
        debug($command . ': Failue.');
        debug(file($error_file));
        break;
    } else {
        debug($command . ': Success.');
    }
}

// Delete the temporary testing location
debug('Removing ' . $test_directory);
chdir($repository_parent_directory);
shell_exec('rm -rf ' . $test_directory);

// Git reads the returning error code. At this point, $return_code
// is either set to 0 by succesfull executions, or 1 by a failure;
// so exit with the correct status.
exit($return_code);

// Check for errors on the provided log file. They don't
// necessarily have a standard format, so check a few things that 
// are generally common.
function errorsInLog($logfile) {
    $emsgs = array();
    $emsgs[] = 'If the exception message is not clear enough, '
             . 'read the output of the task for more information';
    $emsgs[] = 'Some problems occurred when executing the task:';
    $emsgs[] = 'Aborting';
    
    // This could be optimized to fgets the file line by line
    foreach (file($logfile) as $line) {
        foreach ($emsgs as $error) {
            if (strstr($line, $error)) {
                return true;
            }
        }
    }
    return false;
}

// Handle debug messages, recursively if necessary.
function debug($message) {
    if (is_array($message)) {
        foreach ($message as $line) {
            debug($line);
        }
    return;
    }
    echo trim($message) . "\n";
}

// This function could easily be switched out to dump the exact
// command being executed, which can be quite handy.
function run_command($command) {
    shell_exec($command);
}
?>
{% endhighlight %}

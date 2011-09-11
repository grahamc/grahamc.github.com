---
layout: post
title: Forcing SSL and HTTPS with Redirects on Symfony 1.2, 1.3, 1.4
disqus_id: 133 http://iamgraham.net/?p=133
excerpt: "Ensure security of specific URLs using Symfony 1.2, 1.3, and 1.4 to protect from data being leaked."
---
Forcing SSL on certain modules and actions used to be pretty simple with
Symfony's sfSslRequirementPlugin, however since Symfony 1.2 came out - it
isn't necessarily compatible. I took a look around the internet for options,
however I was rather unsatisfied with the options. Because I need to be able
to secure modules and actions, I took it upon myself to create a better way
to secure modules.

The code I wrote It is based off of
[Say No To Flash](http://www.saynotoflash.com/archives/symfony-1-2-redirect-specific-modules-and-actions-to-https-ssl/)'s
filter that they wrote, however I was generally displeased with their method.
t loops over the list twice, and is generally a garble of logic that is a
little bit hard to understand, and could probably be done better.

I was planning on making this system more complicated by specifying if SSL was
enabled or disabled by default, however that became too distorted in the code
to make good, logical sense that was easy to read and maintain.

### Edit your filters.yml File
Open up your `apps/app_name/config/filters.yml` file, and add in after the security filter:

{% highlight yaml %}
sslFilter:
  class: sslFilter
{% endhighlight %}
> This code tells Symfony to load and execute the filter you'll be creating.

It should look something like this:
{% highlight yaml %}
rendering: ~

security:  ~

sslFilter:
  class: sslFilter

cache:     ~

common:    ~

execution: ~
{% endhighlight %}


### Edit your app.yml File
Open the `apps/app_name/config/app.yml` file, and add the following at the end:
{% highlight yaml %}
all:
  ssl:
    strict: true
    modules:
      - { module: some_module }
      - { module: another_module }
      - { module: insecure_module, action: secure_action }
      - { module: insecure_module, action: another_secure_action }
{% endhighlight %}
> In the previous code, the `strict: true` code forces strict checking. Strict
checking means that if someone accesses a URL that isn't specified as secure via
HTTPS, it will redirect them to the HTTP. If strict is set to false, it will allow
them to access any module through HTTPS.

After that, the `- { module: insecure_module, action: another_secure_action }`
code is how you set each module and action. If you want an entire module to be
secure, don't include the action section of that, however you need a line like
that for every module and action you want to secure.

### Create a Filter
Create a file in `apps/app_name/lib/` named `sfSslFilter.class.php`, and put in
it:
{% highlight php %}
<?php
/**
 * @author Graham Christensen
 *          graham@grahamc.com
 */
class sslFilter extends sfFilter {
    public function execute ($filterChain) {
        $context = $this->getContext();
        $request = $context->getRequest();

        // Perform strict checking of security
        // IE: If it's HTTPS and shouldn't be, make it HTTP
        if (sfConfig::has('app_ssl_strict')) {
            $only_explicit = (bool)
                             sfConfig::get('app_ssl_strict');
        } else {
            $only_explicit = false;
        }

        // Get a list of all the modules to check for
        $modules = sfConfig::get('app_ssl_modules');

        // Set the modules variable to an array, this is
        // if it's not configured for this particular environment.
        if (!is_array($modules)) {
            $modules = array();
        }

        // Store the module name and action name into variables
        // to simplify the code, and reduce function calls.
        $module_name = $context->getModuleName();
        $action_name = $context->getActionName();

        // Check if the current request matches a security module
        // If the module or module & action is specified, then
        // ensure it's correctly set.
        $listed = false;
        foreach ($modules as $action) {
            // If the module name is listed
            if ($action['module'] == $module_name) {
                // If the whole module is listed, or the action
                // specifically
                if (!isset($action['action'])
                    || $action_name == $action['action']) {
                    $listed = true;
                    break;
                }
            }
        }

        $is_secure = $request->isSecure();

        // If modules have to be explicitly listed, it is
        // secure, and it's not listed - then redirect
        if ($only_explicit && $is_secure && !$listed) {
            return self::doRedirect($context);
        }

        // If it's not secure, and it's listed as having to be
        if (!$is_secure && $listed) {
            return self::doRedirect($context);
        }

        // Continue on with the chain, but it will only do that if
        // we didn't need to redirect.
        $filterChain->execute();
    }

    public static function doRedirect($context) {
        $request = $context->getRequest();
        $controller = $context->getController();

        // Determine which direction we want to go
        if ($request->isSecure()) {
            // Switch to insecure
            $from = 'https://';
            $to   = 'http://';
        } else {
            // Switch to secure
            $from = 'http://';
            $to   = 'https://';
        }

        $redirect_to = str_replace($from, $to, $request->getUri());
        return $controller->redirect($redirect_to, 0, 301);
    }
}
?>
{% endhighlight %}

The beginning of this is pretty simple, it just gets the configuration settings
outlined in the `app.yml` file, and then goes to town doing it's job.

{% highlight php %}
<?
// Check if the current request matches a security module
// If the module or module & action is specified, then
// ensure it's correctly set.
$listed = false;
foreach ($modules as $action) {
    // If the module name is listed
    if ($action['module'] == $module_name) {
        // If the whole module is listed, or the action
        // specifically
        if (!isset($action['action'])
            || $action_name == $action['action']) {
            $listed = true;
            break;
        }
    }
}
?>
{% endhighlight %}

> That code goes over every module in the app.yml file, and sees if the current
> requests' module matches, or if the module and action matches. If it does, it
> sets $listed to true and exits the loop. This tells the code that it is needs
> to ensure security on the current request.

{% highlight php %}
<?php>
// If modules have to be explicitly listed, it is
// secure, and it's not listed - then redirect
if ($only_explicit && $is_secure && !$listed) {
    return self::doRedirect($context);
}
?>
{% endhighlight %}
> That code ensures that if explicit checking is on and that the request is
> currently using HTTPS and it shouldn't be, it is redirected to become HTTP.

{% highlight php %}
<?php
// If it's not secure, and it's listed as having to be
if (!$is_secure && $listed) {
    return self::doRedirect($context);
}
?>
{% endhighlight %}
> If the module/action is listed as needing to be secure and it isn't, then
> perform the redirect.

{% highlight php %}
<?php
public static function doRedirect($context) {
    $request = $context->getRequest();
    $controller = $context->getController();

    // Determine which direction we want to go
    if ($request->isSecure()) {
        // Switch to insecure
        $from = 'https://';
        $to   = 'http://';
    } else {
        // Switch to secure
        $from = 'http://';
        $to   = 'https://';
    }

    $redirect_to = str_replace($from, $to, $request->getUri());
    return $controller->redirect($redirect_to, 0, 301);
}
?>
{% endhighlight %}
> The previous method is really pretty simple. If doRequest is called, it
> means that the current protocol is not valid. So, if it is HTTP, make it
> tHTTPS. If it's HTTPS, make it HTTP.

### Finishing Up
When you're finishing up, make sure you clear your cache via `./symfony cc` and
then test it on your site. Make sure that your strict option is working, and
you should check each individual module and action to make sure you didn't
forget anything.

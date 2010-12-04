--- 
layout: post
title: Validate a Domain is Valid and Exists, Symfony 1.2
disqus_id: 4a9dc8c34e4adcb1d9110c9ba52206d0
---
After spending good portion of my day validating, parsing, and analyzing URLs
- I find that I've written a small set of tools to ensure consistency, clean,
and sane URLs. After an overhaul on a settings page - I had to integrate much
of this into a simple (to the viewer, anyway) form. To ensure that user-entered
URLs are valid, I've written a custom validator in **Symfony 1.2**
to accomplish this validation.

### Writing a Custom sfValidator
Writing a custom validator really isn't as difficult as you would imagine. Open
up one of the existing ones, and you'll see that. Primarily, you only need to
worry about two methods.

#### configure()
The configure method is where you can specify customization options, making some
required or optional. This method is used to build flexibility into the
validator.

#### doClean()
The doClean method may seem confusing at first, however it's very simple. Upon
failure, throw an exception.

##### How to Signal a Failure
{% highlight php %}
<?php
throw new sfValidatorError($this, 'invalid', array('value' => $value));
?>
{% endhighlight %}

> `invalid` is the name of the message you want to error with, and the options
> array at in the third parameter allow you to replace variables in the
> message.

##### How to Handle a Success

If the validator is successful - you have two options:

- Your validator can act as a filter, and return something different from the
    input value
- Your validator can return exactly what it was passed in.

### Implementing the new sfValidator into an sfForm
This validator is used just like any other:

{% highlight php %}
<?php
$form->setValidator('domain', new sfValidatorDomain());
?>
{% endhighlight %}

{% highlight php %}
<?php
/**
 * @author Graham Christensen <graham@grahamc.com>
*/
class sfValidatorDomain extends sfValidatorBase
{
  /**
   * Configures the current validator.
   *
   *
   * @param array $options    An array of options
   * @param array $messages   An array of error messages
   *
   * @see sfValidatorBase
   */
  protected function configure($options = array(),
                                $messages = array()) {
      // The type of method to use to validate it.
      $this->addOption('clean_type', 'url');

      // List of valid protocol schemes to allow in URLs
      $this->addOption('schemes', array('http', 'https'));

      // The default scheme
      $this->addOption('default_scheme', 'http');

	  // Setup some basic error messages
	  $msg = 'The provided domain does not appear to be valid.';
      $this->addMessage('badform', $msg);
      $this->addMessage('badscheme', $msg);
      $this->addMessage('nohost', $msg);
      $this->addMessage('invalid', $msg);
  }

  /**
   * @see sfValidatorBase
   */
  protected function doClean($value) {
      if ($this->getOption('clean_type') == 'domain') {
          // If it's a domain, then it's simple to check it.
          $domain = $value;
      } else {
          // It's probably a complete URL, so check it in
          // more depth.

          // Verify that it can be parsed as a URL.
          // Note: @'s are bad practice, however if a method is
          // being checked and we can't stop the error, then
          // we want to hide it.

          $parts = @parse_url($value); // May throw a warning

          // If there is no scheme (http, https, etc.) then it's
          // likely that parse_url parsed it incorrectly, so
          // prepend a scheme and try again. if we don't do this,
          // we may get "example.com/foobar" as our path.
          if (!isset($parts['scheme'])) {
              $value = $this->getOption('default_scheme')
                       . '://' . $value;
              $parts = @parse_url($value);
          }

          // If it wasn't parsed, then something was wrong.
          if (!$parts) {
              throw new sfValidatorError($this, 'badform',
                            array('value' => $value));
          }

          // Validate that the scheme provided is valid
          if (!in_array($parts['scheme'],
                        $this->getOption('schemes'))) {
              throw new sfValidatorError($this, 'badscheme',
                            array('value' => $value));
          }

          // Ensure that the host was found
          if (!isset($parts['host'])) {
              throw new sfValidatorError($this, 'nohost',
                            array('value' => $value));
          } else {
              // Finally set the domain for the final, unified
              // verification.
              $domain = $parts['host'];
          }
      }

      // Convert the domain to an IP address
      $ip_address = gethostbyname($domain);

      // Unfortunately, gethostbyname's only response if it
      // fails, is returns the input $domain. Try to convert it
      // to a packed IP address. If that fails, then it isn't a
      // valid domain name.
      if (@inet_pton($ip_address)) {
          return $value;
      }

      // Didn't validate...
    throw new sfValidatorError($this, 'invalid',
                    array('value' => $value));
  }
}
?>
{% endhighlight %}
> Install this into lib/validator/sfValidatorDomain.class.php
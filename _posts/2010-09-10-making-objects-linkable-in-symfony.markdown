---
layout: post
title: Making Objects Linkable in symfony
disqus_id: b2b7a6a0ac85a92f187213879176a1c7
---
While working on a new project, I was exhausted by all the `link_to` writing I
had been doing. It was repetitive, and even though I was using proper
object-based routes - it was still ugly. All of them were formatted the exact
same way, it was just silly. Definitely not DRY.

I started refactoring this by making a helper to link to an object. It was
specific - `link_to_group(NFGroup $group)`, `link_to_user(sfGuardUser $user)`
 and about the third time I wrote a nearly identical helper, I wrote another
helper - `link_to_object(BaseObject $object, $route)`. This wasn't pretty, and
I wanted a simpler solution.

What I ended up with was an interface for objects that I wanted to be linkable.
The interface provided a way to get the route, parameters for the route, and
then used the `__toString()` method on the object for the link text.

{% highlight php %}
<?php
/**
 * Makes an object easy to link to by passing it to the
 * linkableLink helper
 *
 * @author Graham Christensen <graham@grahamc.com>
 */
interface NF_Linkable {
	/**
	 * Get the route
	 * @return string The route
	 */
	public function getRoute();

	/**
	 * Get route parameters
	 * @return array of route parameters
	 */
	public function getParameters();

	/**
	 * Get the text to use as link-text
	 * @return string
	 */
	public function __toString();
}
?>
{% endhighlight %}

> The NF_Linkable interface, allowing it to be easily linked to in a symfony
> view. To use this, place it in lib/NF_Linkable.php

My new helper is named `linkableLink(NF_Linkable $object)` and it will output
a link, nice and simply. The helper is fairly straightforward too:

{% highlight php %}
<?php
/**
 * Link to any object extending NF_Linkable
 * @param NF_Linkable $object
 * @return string
 * @author Graham Christensen <graham@grahamc.com>
 */
function linkableLink(NF_Linkable $object) {
	$url = $object->getRoute() . '?';
	$url .= http_build_query($object->getParameters());

	return link_to($object, $url);
}
?>
{% endhighlight %}


> This is pretty straightforward. It takes the object's route, builds the query
> string from the parameters, and passes it along to symfony's link_to helper.
> For those following along, place this in `lib/helpers/LinkableHelper.php`

To use this is simple enough, using the example of a group's Propel object - we
simply implement the interface's methods:

{% highlight php %}
<?php

/**
 * A group object which is linkable using linkableLink
 *
 * @author Graham Christensen <graham@grahamc.com>
 */
class FieldGroup extends BaseFieldGroup
						implements NF_Linkable {
	/**
	 * Get the route to show a group
	 * @return string
	 */
	public function getRoute() {
		return '@group_show';
	}

	/**
	 * Get the route's parameters for building the final URL
	 * @return array
	 */
	public function getParameters() {
		return array('id' => $this->getId());
	}

	/**
	 * Get the text to appear between in <a>text</a> tags
	 * @return string
	 */
	public function __toString() {
		return $this->getName();
	}
}
?>
{% endhighlight %}

> This is an example of how I use the NF_Linkable interface. This would create
> a link to this particular group using the name as the link text. The URL
> generated would be something like `@group_show?id=1`, which
symfony translates into `group/view/1`

To then use this in your codebase, write a simple view:

{% highlight php %}
<?php
// Get a FieldGroup just for the example
$group = FieldGroupPeer::doSelectOne(new Criteria());

use_helper('Linkable');
echo linkableLink($group);
?>
{% endhighlight %}

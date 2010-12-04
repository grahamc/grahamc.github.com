--- 
layout: post
title: Modifying Form Elements in Symfony 1.2
disqus_id: 98c6ad2c11a0dc406c5f9a27d494c7f4
---
As I found in recent development of an app, I needed to change one of Symfony's
form on the fly (more specifically, I needed to change a drop-down,
`sfWidgetFormSelect`). After some looking, there wasn't much documentation on
this that I could find. My final solution was easy enough:

{% highlight php %}
<?php
$form = new SomeFancyForm();
$new_choices = array('Selection 1', 'Selection 2', 'Selection 3');
$widget = $form->getWidget('select_widget_name');
$widget->setOption('choices', $new_choices);
?>
{% endhighlight %}

Of course, that can easily be adapted to modify any option on any form - just
find the appropriate option you want to adjust. Additionally, you may need to
adjust the validator as well.

Relevant Documentation:

- [sfForm API Documentation](http://www.symfony-project.org/api/1_2/sfForm#method_getwidget)
- [sfWidgetFormSelect API Documentation](http://www.symfony-project.org/api/1_2/sfWidgetFormSelect)

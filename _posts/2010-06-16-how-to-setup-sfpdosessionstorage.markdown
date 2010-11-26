--- 
layout: post
title: How to Setup sfPDOSessionStorage
---
Setting up sfPDOSessionStorage is a fairly simple matter to make sure that
sessions exist on a setup with multiple web-heads. 

Add the following code to your `app/app_name/config/factories.yml` file:

{% highlight yaml %}
all:
    storage:
    class: sfPDOSessionStorage
    param:
      db_table:    session
      database:    propel
      # Optional parameters
      db_id_col:   sess_id
      db_data_col: sess_data
      db_time_col: sess_time
{% endhighlight %}

Make sure your remove all unnecessary references to setting a different storage
mechanism

Now add the following YAML to your config/schema.yml file. This creates the
table structure.
{% highlight yaml %}
# Session
  session:
    _attributes: { phpName: Session }
    sess_id: { type: varchar, size: 64,
               required: true, primaryKey: true }
    sess_data: { type: longvarchar }
    sess_time: { type: INTEGER, size: '11'}
    _indexes: { SESSIONTIME: [sess_time] }
{% endhighlight %}

I try to keep the generated SQL as up to date as possible, so do that now.
{% highlight bash %}
./symfony cc
./symfony propel:build-sql
{% endhighlight %}


If you need to make this change to an existing dataaset, here is the raw SQL
to create the table:
{% highlight mysql %}
CREATE TABLE `sessions`
(
        `sess_id` VARCHAR(64)  NOT NULL,
        `sess_data` TEXT,
        `sess_time` INTEGER(11),
        PRIMARY KEY (`sess_id`),
        KEY `SESSIONTIME`(`sess_time`)
)Type=InnoDB;
{% endhighlight %}
> Note: If the session table is MyISAM, you're going to hurt yourself with
> table-level locking. Making it InnoDB means row-level locking, and much
> better performance. Also, this only scales so far - eventually memcache
> is the solution.
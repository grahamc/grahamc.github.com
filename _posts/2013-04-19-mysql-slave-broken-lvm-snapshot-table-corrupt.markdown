---
title: "Why a MySQL Slave Created from an LVM Snapshot Would Mark Tables Corrupt"
layout: post
excerpt:
  LVM Snapshoting a MySQL server is often the quickest and most error-free
  method of duplicating the data from one database server to another. So how
  could it be that my slaves were coming up corrupted?

---

I was spinning up a new database slave to trail along behind master. Trailing
slaves are for maintenance tasks like snapshots and backups. I've done this
hundreds of times at this point, and have automated the process for a few
organizations now, too.

Unfortunately, this particular snapshot and import was particularly problematic,
with an issue I've never come across before. Here is how I exported the
database:

Open two terminals on the database, one running mysql (`mysql -u root`), the
other running bash.

Flush all IO to disk and prevent future writes from happening. This can
sometimes take a long time, so be careful. It is not a good idea to do this on
a server with high traffic. In MySQL, run:

{% highlight sql %}
FLUSH TABLES WITH READ LOCK
{% endhighlight %}

At this point it is safe to snapshot the disk, which on my machine was:

{% highlight bash %}
lvcreate -L20G -s -n mysqlsnap /dev/VG_MySQL/LV_MySQL
{% endhighlight %}

This snapshot was then transferred to the target slave. MySQL would recover
as expected, and then serve the databases just fine. Note that I trimmed the
following log snippet of sensitive data, and is otherwise exactly what you
should expect to see:

    InnoDB: Log scan progressed past the checkpoint lsn 2026105126787
    130417 20:45:27  InnoDB: Database was not shut down normally!
    InnoDB: Starting crash recovery.
    InnoDB: Reading tablespace information from the .ibd files...
    InnoDB: Restoring possible half-written data pages from the doublewrite
    InnoDB: buffer...
    InnoDB: Doing recovery: scanned up to log sequence number 2026110369280

... snip about 15 similar lines ...

    InnoDB: Doing recovery: scanned up to log sequence number 2026235456602
    130417 20:45:34  InnoDB: Starting an apply batch of log records to the database...
    InnoDB: Progress in percents: 0 1 2 3 4 ... 96 97 98 99
    InnoDB: Apply batch completed
    InnoDB: In a MySQL replication slave the last master binlog file
    InnoDB: position 135547902, file name bin-log.000014
    InnoDB: and relay log file
    InnoDB: position 135548059, file name /var/lib/mysqllogs/relay-log.000048
    InnoDB: Last MySQL binlog file position 0 475524524, file name /var/lib/mysqllogs/binary-log.000245
    130417 20:46:10  InnoDB: Waiting for the background threads to start
    130417 20:46:11 Percona XtraDB (http://www.percona.com) 5.5.30-rel30.2 started; log sequence number 2026235456602
    130417 20:46:15 [Note] Event Scheduler: Loaded 0 events
    130417 20:46:15 [Note] /usr/sbin/mysqld: ready for connections.

### The Problem

As soon a I would run `CHANGE MASTER` on the slave and begin the slaving, it
would mark a table as corrupted:

    130417 20:50:12 [Note] Slave SQL thread initialized, starting replication in log '435510-binary-log.000245' at position 475524524, relay log './relay-log.000001' position: 4
    130417 20:50:12 [Note] Slave I/O thread: connected to master 'replicant@host:3306',replication started in log '435510-binary-log.000245' at position 475524524
    130417 20:50:12 [ERROR] /usr/sbin/mysqld: Table 'dbname/tablename' is marked as crashed and should be repaired
    130417 20:50:12 [ERROR] Slave SQL: Error 'Table 'dbname/tablename' is marked as crashed and should be repaired' on query. Default database: 'dbname'. Query: '...', Error_code: 145
    130417 20:50:12 [Warning] Slave: Table 'dbname/tablename' is marked as crashed and should be repaired Error_code: 145
    130417 20:50:12 [Warning] Slave: Table 'tablename' is marked as crashed and should be repaired Error_code: 1194
    130417 20:50:12 [ERROR] Error running query, slave SQL thread aborted. Fix the problem, and restart the slave SQL thread with "SLAVE START". We stopped at log 'binary-log.000245' position 475539508

> In other words, the table 'dbname.tablename' has gone corrupt.

### The Resolution

I was convinced it had to do with the LVM snapshot, but not so. After consulting
a number of people, and the MySQL manual, I realized I should run

{% highlight sql %}
USE 'dbname';
CHECK TABLE `tablename` FAST QUICK\G
{% endhighlight %}

> `CHECK TABLE` will indicate what is wrong with the table.

In this case, the real issue was very simply a case of the table not being
closed properly, which `CHECK TABLE` takes care of automatically.

What MySQL outputted:

        Table: dbname.tablename
          Op: check
    Msg_type: warning
    Msg_text: 4 clients are using or haven't closed the table properly

        Table: dbname.tablename
          Op: check
    Msg_type: status
    Msg_text: OK

From the documentation of
[MySQL's CHECK TABLE](http://dev.mysql.com/doc/refman/5.1/en/check-table.html):

> In some cases, CHECK TABLE changes the table. This happens if the table is
> marked as “corrupted” or “not closed properly” but CHECK TABLE does not find
> any problems in the table. In this case, CHECK TABLE marks the table as okay.


Running `mysqlcheck -A` on the slave server (and later the master) worked like
a charm.


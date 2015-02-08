---
layout: post
title: Pip Install with Docker and Fixing the ascii decode error
---

When trying to install python packages with pip inside a Docker container, you
may get an error like:

    UnicodeDecodeError: 'ascii' codec can't decode byte 0xe2 in position 72:
    ordinal not in range(128)
    2014/11/14 15:44:47 The command [/bin/sh -c pip install -r
    /tmp/requirements.txt] returned a non-zero code: 1

Just add `ENV LANG en_US.UTF-8` to your Dockerfile before your `pip install`
and it will be okay.


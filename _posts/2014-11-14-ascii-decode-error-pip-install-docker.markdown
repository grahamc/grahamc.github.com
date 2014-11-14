---
layout: post
title: Pip Install with Docker and Fixing the ascii decode error
---

When trying to install python packages with pip inside a Docker container, you
may get an error similar to:

    Command /usr/local/bin/python2 -c "import setuptools,
    tokenize;__file__='/tmp/pip_build_root/scipy/setup.py';exec(compile(getattr(tokenize,
    'open', open)(__file__).read().replace('\r\n', '\n'), __file__, 'exec'))"
    install --record /tmp/pip-oe43Gu-record/install-record.txt
    --single-version-externally-managed --compile failed with error code 1 in
    /tmp/pip_build_root/scipy
    Traceback (most recent call last):
      File "/usr/local/bin/pip", line 11, in <module>
        sys.exit(main())
      File "/usr/local/lib/python2.7/site-packages/pip/__init__.py", line 185, in
    main
        return command.main(cmd_args)
      File "/usr/local/lib/python2.7/site-packages/pip/basecommand.py", line 161, in
    main
        text = '\n'.join(complete_log)
    UnicodeDecodeError: 'ascii' codec can't decode byte 0xe2 in position 72: ordinal
    not in range(128)
    2014/11/14 15:44:47 The command [/bin/sh -c pip install -r
    /tmp/requirements.txt] returned a non-zero code: 1

Be calm. Just add `ENV LANG en_US.UTF-8` to your Dockerfile before your pip
install happens and it will be okay.


+++
title = "JunOS VCF Upgrade Issues"
author = ["Franta Bartik"]
date = "2026-06-22"
description = "How to fix `invalid file` error when upgrading JunOS"
draft = false
+++

At `$WORK`, my efforts to upgrade a Juniper QFX5120-32C virtual chassis were failing and I was not able to figure out why. Because I couldn't find an answer for this without consulting Juniper support, I decided I would share my findings here.

If your `request system software add <file>` keeps failing with `invalid file`, like this:

```sh
{master:1}
user@switch> request system software add /var/tmp/22.3.tgz

Checking pending install on fpc0

Checking pending install on localre
Pushing bundle /var/tmp/22.3.tgz to fpc0

fpc0:
22.3.tgz: truncated gzip input
tar: Error exit delayed from previous errors.
/usr/libexec/ui/package: /var/tmp/22.3.tgz: invalid file
ERROR: No packages added
```

The actual problem is with the secondary/backup switch storage being too full. Just running `request system storage cleanup` will work.

I've also been directed to use `/tmp` instead of `/var/tmp` for storage of the `jinstall*.tgz` file.

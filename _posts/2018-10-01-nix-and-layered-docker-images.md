---
layout: post
title: Docker Layers, Caching, and Nix
tags: nix
---

Nix users value its isolated, repeatable builds and simple sharing of
development environments. Nix makes it easy to go back in time and
rebuild software from years ago without issue.

At the same time, the value of the container ecosystem is huge. Tying
in to the schedulers, orchestration, and monitoring is very valuable.

Nix has been able to generate Docker images for several years now,
however the typical approach to layering with Nix is to generate one
fat image with all of the dependencies. This fat image offers no
sharing, is slow to build, upload, and download.

In this post I talk about how I fix this problem and use Nix to
automatically create multi-layered Docker images, allowing a high
amount of caching between images.

### Docker uses layers

Docker's use of layering is well known, and its benefits are
undeniable: sharing a "base" system is a simple abstraction which
allows extending a well known image with your own code.

A Docker image is a sequence of layers, where each member is a
filesystem diff, adding and removing files from its parent
member:

![](/resources/2018-09-28-docker-images/docker.svg)


### Efficient layering is hard because there are no rules

When there are no restrictions on what a command will do, the only way
to fully capture its effects is to snapshot the full filesystem.

Most package managers will write files to shared global directories
like `/usr`, `/bin`, and `/etc`.

This means that the _only_ way to represent the changes between
installing package A and installing package B is to take a full
snapshot of the filesystem.

As a user you might manually create rules to improve the behavior of
the cache: add your code towards the end of a Dockerfile, or install
common libraries in a single `RUN` instruction, even if you don't want
them all.

These rules make sense: If a Dockerfile adds code and then installs
packages, Docker can't cache the installation because it can't know
that the package installation isn't influenced by the code addition.
Docker also can't know that installing package A has nothing to do
with package B and the changes are separately cachable.

### With restrictions, we can make better optimizations

Nix does have rules.

The most important and relevant rule when considering distribution and
Docker layers is:

> A package build can't write to arbitrary places on the disk.

A build can only write to a specific directory known as `$out`, like
`/nix/store/ibfx7ryqnqf01qfzj4v7qhzhkd2v9mm7-file-5.34`. When you add
a new package to your system, you know it didn't modify `/etc` or
`/bin`.

How does `file` find its dependencies? It doesn't -- they are
hard-coded:

```
$ ldd /nix/store/ibfx7ryqnqf01qfzj4v7qhzhkd2v9mm7-file-5.34/bin/file
	linux-vdso.so.1
	/nix/store/ibfx7ryqnqf01qfzj4v7qhzhkd2v9mm7-file-5.34/lib/libmagic.so.1
	/nix/store/bv6znzsv2qkbcwwa251dx7n5dshz3nr3-zlib-1.2.11/lib/libz.so.1
	/nix/store/fg4yq8i8wd08xg3fy58l6q73cjy8hjr2-glibc-2.27/lib/libc.so.6
	/nix/store/fg4yq8i8wd08xg3fy58l6q73cjy8hjr2-glibc-2.27/lib/ld-linux-x86-64.so.2
```

This provides great, cache-friendly properties:

1. You know exactly what path changed when you added `file`.
2. You know exactly what paths `file` depends on.
3. Once a path is created, it will never change again.

### Think graphs, not layers

If you consider the properties Nix provides, you can see it already
constructs a graph internally to represent software and its
dependencies: it natively has a better understanding of the software
than Docker is interested in.

Specifically, Nix uses a Directed Acyclic Graph to store build output,
where each node is a specific, unique, and immutable path in
`/nix/store`:

![](/resources/2018-09-28-docker-images/nix.svg)

Or to use a real example, Nix itself can render a graph of a package's
dependencies:

![](/resources/2018-09-28-docker-images/file.svg)

### Flattening Graphs to Layers

In a naive world we can simply walk the tree and create a layer out of
each path:

![](/resources/2018-09-28-docker-images/flattened-file.svg)

and this image is valid: if you pulled any of these layers, you
would automatically get all the layers below it, resulting in a
complete set of dependencies.

Things get a bit more complicated for a graph with a wider graph, how
do you flatten something like Bash:

![](/resources/2018-09-28-docker-images/bash.svg)

If we had to flatten this to an ordered sequence, obviously
`bash-interactive-4.4-p23` is at the top, but does `readline-7.0p5`
come next? Why not `bash-4.4p23`?

It turns out we don't have to solve this problem exactly, because I
lied about how Docker represents layers.

#### How Docker _really_ represents an Image

Docker's layers are _content addressable_ and aren't required to
explicitly reference a parent layer. This means a layer for
`readline-7.0p5` and doesn't have to mention that it has any
relationship to `ncurses-6.1` or `glibc-2.27` at all.

Instead each image has a _manifest_ which defines the order:

```json
{
  "Layers": [
    "bash-interactive-4.4-p23",
    "bash-4.4p23",
    "readline-7.0p5",
     ...
  ]
}
```

If you have only built Docker images using a Dockerfile, then you
would expect the way we flatten our graph to be critically important.
If we sometimes picked `readline-7.0p5` to come first and other
times picked `bash-4.4p23` then we may never make cache hits.

However since the _Image_ defines the order, we don't have to solve
this impossible problem: we can order the layers in any way we want
and the layer cache will always hit.

### Docker doesn't support an infinite number of layers

Docker has a [limit of 125 layers][125-layers], but big packages with
lots of dependencies can easily have more than 125 store paths.

It is important that we still successfully build an image if we go
over this limit, but what do we do with the extra layers?

In the interest of shortness, let's pretend Docker only lets you have
**four** layers, and we want to fit five. Out of the Bash example,
which two paths do we combine in to one layer?

 - `bash-interactive-4.4-p23`
 - `bash-4.4p23`
 - `readline-7.0p5`
 - `ncurses-6.1`
 - `glibc-2.27`

#### Smushing Layers

I decided the best solution is to combine the layers which are less
likely to be a cache hit with other software. Picking the most
low level, fundamental paths and making them a separate layer means my
next image will most likely also share some of those layers too.

Ideally it would end up with at least glibc, and ncurses in separate
layers. Visually, it is hard to tell if either readline or bash-4.4p23
would be better served as an individual layer. One of them should be,
certainly.

### My actual solution

My prioritization algorithm is a simple graph-based popularity
contest. The idea is to weight each node more heavily the deeper and
more references they have.

Starting with the dependency graph of Bash from before,

![](/resources/2018-09-28-docker-images/bash-weighted-step0.svg)

we first duplicate nodes in the graph so each node is only pointed to
once:

![](/resources/2018-09-28-docker-images/bash-weighted-step1.svg)

we then replace each leaf node with a counter, starting at 1:

![](/resources/2018-09-28-docker-images/bash-weighted-step2.svg)

each node whose only children are counters are then combined with
their children, and their children’s counters summed, then
incremented:

![](/resources/2018-09-28-docker-images/bash-weighted-step3.svg)

we then repeat the process:

![](/resources/2018-09-28-docker-images/bash-weighted-step4.svg)

we repeat this process until there is only one node:

![](/resources/2018-09-28-docker-images/bash-weighted-step5.svg)

and finally we sort the paths in each popularity bucket by name to
ensure the list is consistently generated to get the paths ordered by
cachability:

 - glibc-2.27: 10
 - ncurses-6.1: 4
 - bash-4.4-p23: 2
 - readline-7.0p5: 2
 - bash-interactive-4.4-p23: 1

This solution has properly put foundational paths which are most
commonly referred to at the top, improving its chances of cache hit.
The algorithm has also put the likely-to-change application right at
the bottom in case the last layers need to be combined.

Let's consider a much larger image. In this image, we set the maximum
number of layers to 120, but the image has 200 store paths. Under this
design the 119 most fundamental store paths will have their own
layers, and we store the remaining 81 paths together in the 120th
layer.

---

With this new approach of automatically layering store paths I can now
generate images with very efficient caching between different
images.

For a practical example of a PHP application with a MySQL database.

First we build a MySQL image:

```nix
# mysql.nix
let
  pkgs = import (builtins.fetchTarball {
    url = "https://github.com/grahamc/nixpkgs/archive/layered-docker-images.tar.gz";
    sha256 = "05a3jjcqvcrylyy8gc79hlcp9ik9ljdbwf78hymi5b12zj2vyfh6";
  }) {};
in pkgs.dockerTools.buildLayeredImage {
  name = "mysql";
  tag = "latest";
  config.Cmd = [ "${pkgs.mysql}/bin/mysqld" ];
  maxLayers = 120;
}
```

```
$ nix-build ./mysql.nix
$ docker load < ./result
```

Then we build a PHP image:

```nix
# php.nix
let
  pkgs = import (builtins.fetchTarball {
    url = "https://github.com/grahamc/nixpkgs/archive/layered-docker-images.tar.gz";
    sha256 = "05a3jjcqvcrylyy8gc79hlcp9ik9ljdbwf78hymi5b12zj2vyfh6";
  }) {};
in pkgs.dockerTools.buildLayeredImage {
  name = "grahamc/php";
  tag = "latest";
  config.Cmd = [ "${pkgs.php}/bin/php" ];
  maxLayers = 120;
}
```

```
$ nix-build ./php.nix
$ docker load < ./result
```

and export the two image layers:

```
$ docker inspect mysql | jq -r '.[] | .RootFS.Layers | .[]' | sort > mysql
$ docker inspect php | jq -r '.[] | .RootFS.Layers | .[]' | sort > php
```

and look at this, the PHP and MySQL images share **twenty** layers:

```
$ comm -1 -2 php mysql
sha256:0296e7b7d4b7d593fc533f06c5cc22f56c99c8ab0ed4301a6c7829ce8b18c6fa
sha256:1114fa18ba6be7e5db7728ae747a6bf0aab48fedf3ed9e95aff1f9ce51903698
sha256:181ca82fe4d920b46488d29b507d432dd121d9b2842cf8c720c0939e03e4d6a0
sha256:190b2db337109cb9692cd004aeed4b06fef0c10c700a9ba7939d73e697e3bbcc
sha256:1c4afa44a489abf7c7fe8fa642647a8a2786bf7581486e6a308e1078484784e6
sha256:424ad95540cb66adb9e16d768ccc7010923a9ca09dda1f56e4a08804c2de12e6
sha256:537b4796037a46b64fa39c42f642925704abbaab475e5c72a8fc15c258dc1e85
sha256:69bf797b6b6763938b98139814d8be884693806e0e5a50ac4fbbf11eb45f4f27
sha256:6c7f6a555dee6eebfc5497e84b1cacb4fff035e2101d8421768c0c2db54e8da2
sha256:7dcff293e9f411c63d6f1365795a89ac0058995de0f192ad9fb103ab56533ed3
sha256:86b1c4990ca1c80ad5dc0977fe37ab0f80e0f95e03fe79769b451d97e9f7a8f3
sha256:9d8278ca2542af2ff9cf2d8de439758f6b3bbb84bbe6b7a44edf8080b73d2949
sha256:a5c8632ba0135b465956281008a4f9c2263232d92c020b56e1d839aaa4b74834
sha256:b9fe88bf1364613ec01968480d7cb305d69e3de78bb4a56e3448298ffcc25139
sha256:c0c9c2eaa522dd31901c49a40577a68e3ae02cc75226a248813134046b299099
sha256:c2f4e79836f999ff389b82b8636b807c2baa5b702509b2991e651508519857d5
sha256:cdfb1dfb3ca2f8df9e87e5fa33b91a402a8b4ad0ede164dbdf4c25aded618ed3
sha256:ffd8e3d222cb85f642677642037a0e7886a565babdc0e229cc83147895a8ed2c
sha256:ffecd238fa95b110a1b5f71034b2bd358358758abb52fd098241200d94111979
```

Where before you wouldn't bother trying to have your application and
database images share layers, with Nix the layer sharing is completely
automatic.

The automatic splitting and prioritization has improved image push and
fetch times by an order of magnitude. Having multiple images allows
Docker to request more than one at a time.

_Thank you Target for having sponsored this work in
[NixOS/nixpkgs#47411](https://github.com/NixOS/nixpkgs/pull/47411)._

[125-layers]: https://github.com/moby/moby/blob/b3e9f7b13b0f0c414fa6253e1f17a86b2cff68b5/layer/layer_store.go#L23-L26

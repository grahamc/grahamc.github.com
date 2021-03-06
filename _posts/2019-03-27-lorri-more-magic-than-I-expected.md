---
layout: post
title: Introducing lorri, your project's nix-env
tags: nix
hold: true
---

<link rel="stylesheet" type="text/css" href="/web-stuff/asci-cust.css" />

Today I'm delighted to write about lorri, a new tool for NixOS, Linux,
and macOS that makes developing with Nix even nicer:

<asciinema-player src="/resources/2019-03-27-lorri-demo.cast" cols="70" rows="30"></asciinema-player>

When people try lorri, I often hear that it is more magical than they
expected.

## What is lorri?

lorri is a nix-shell replacement for project development. lorri is
based around fast [direnv][direnv] integration for robust CLI and
editor integration.

The project is about experimenting with and improving the developer's
experience with Nix. A particular focus is managing your project's
external dependencies, editor integration, and quick feedback.

## How is lorri different from a nix-shell?

Nix's shells are a fantastic tool for environment management, but have
some pain points.

Let's look at three ways lorri changes the experience.

### Channel updates are no big deal

Do you use `import <nixpkgs> {}`? Update your channels and ... Oops!
Your Nix shell is stale! Opening a new `nix-shell` means downloading
all new dependencies before you're able to get back to work.

Not with lorri. When your channel updates, `lorri watch` automatically
begins re-evaluating your project's dependencies. If you enter the
shell before the evaluation completes, the last completed evaluation
is loaded instead. When the new one is ready, your environment updates
automatically.

### `nix-collect-garbage` before a flight? Sure.

Nix shells are not protected from garbage collection. This is good for
one-off shells (`nix-shell -p fortune --run fortune`) but not so nice
for your large project integrating dozens of Nixpkgs dependencies.
Having your gigabytes of project tooling disappear on a low-bandwidth
connection is a nightmare most Nix users know.

During the development of lorri I switched my computer to
[collect garbage every 10 minutes][gc] to expose me to this problem as
often as possible.

lorri captures development dependencies and creates garbage collection
roots automatically. Since switching to lorri I have only rarely found
myself needing to re-fetch my tools.

### Editor integration is a snap

A big hassle for me is editor integration and tools like language
servers.

Adding [direnv][direnv] to the tool stack makes this better: direnv is
like Nix's secret weapon for editor integration. Many editors support
direnv, direnv supports Nix, and boom: many editors support Nix!

Out of the box, however, direnv's Nix integration is slow --
continuously, unnecessarily evaluating Nix expressions. In some
editors the expressions are re-evaluated on every file switch. This
can be very painful, especially if the evaluation takes even half a
second!

lorri's direnv integration doesn't ever call Nix. Instead, the
integration always selects the last cached evaluation, ensuring a
lightning-fast editor and shell experience.

When entering a project directory your tools just appear, ready to
use.


# Using lorri

lorri is used in two parts:

 - direnv integration sets up your shell and editor integration with
   project-specific dependencies
 - `lorri watch` monitors your project and automatically regenerates
   your environment


A typical workflow for me is to spawn a terminal running
`lorri watch`, minimize it, and open a second terminal for my work
shell. If I'm not editing dependencies, sometimes I'll sometimes even
skip the `lorri watch` and just use the cached evaluation.

lorri was built by Tweag for Target, and I am so excited to introduce
it to the public. lorri is beta, open source (Apache-2.0) and
[a tutorial is available at Target/lorri][tutorial]. Give it a try,
and let me know what you think =).

I think you'll like it.

<script src="/web-stuff/asciinema.js"></script>

[direnv]: https://direnv.net/
[gc]: https://github.com/grahamc/nixos-config/commit/8bba3f36ad095357226a04aa7f7ca823f67bd95e
[tutorial]: https://github.com/target/lorri#tutorial

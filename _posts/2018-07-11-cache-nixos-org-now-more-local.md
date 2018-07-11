---
layout: post
title: 🏃💨 cache.nixos.org, now more local!
tags: nix
---


I'm delighted to be able to announce that users all around the world
will now have a great experience when fetching from the NixOS cache.


I heard several times from users in Hong Kong and Singapore that the
cache was "slow", but I didn't know it was **_this_** slow! After
working closely with a team of Nix users in Bangalore, I experienced
first-hand just how eye-wateringly slow it could be.


The NixOS cache is now being served from all of AWS CloudFront edge
locations, significantly reducing latency for users in Asia, Africa,
South America, and Oceania.


By expanding the cache's distribution settings to include all of the
edge locations, performance has been substantially improved build
time:


|                                             |                         | Sydney       |
| ------------------------------------------- | ----------------------- | :----------- |
| **GHC<br/>117.06 MiB**                      | _Before_                | `178.491s`   |
|                                             | _After<br />Cold Cache_ | `73.612s`    |
|                                             | _After<br />Hot Cache_  | `15.707s`    |
|                                             |                         |              |
| **Graphical ISO closure<br/>1660.95 MiB**   | _Before_                | `2326.957s`  |
|                                             | _After<br />Cold Cache_ | `376.014s`   |
|                                             | _After<br />Hot Cache_  | `25.328s`    |


Experiments in Tokyo and Hong Kong produced similar results.


NixOS's cache is stored in AWS S3, and distributed using AWS
CloudFront. This combination gives us the excellent durability
guarantees of S3 combined with the large geographical distribution of
CloudFront.


Until today, the NixOS cache was only served through edge nodes in the
United States, Canada, and Europe.


A big thank-you to Amine Chikhaoui, and Eelco Dolstra for their help
in researching this change and turning on such a massive improvement.

---
layout: post
title: How to use a NixOS Linux Server for Time Machine Backups
tags: nix
---

Several years ago I remember researching this process for Ubuntu, and
[kremalicious.com](https://kremalicious.com/ubuntu-as-mac-file-server-and-time-machine-volume/)
had the best instructions out there. When looking around this time, I
was dismayed to find the process hasn't seemingly improved for most
Linuxes: custom compilation, fakeroots, and the like.

However, I believe NixOS provides the most succinct and reproducible
instructions yet, without even having to muck with `defaults write`.

Incorporate the following in to your `configuration.nix`,
`nixos-rebuild switch`, and you're done:

    {
      networking.firewall.allowedTCPPorts = [
        548 # netatalk
      ];

      services = {
        netatalk = {
          enable = true;

          volumes = {
            "grahamc-time-machine" = {
              "time machine" = "yes";
              path = "/home/grahamc/time-machine";
              "valid users" = "grahamc";
            };
          };
        };

        avahi = {
          enable = true;
          nssmdns = true;

          publish = {
            enable = true;
            userServices = true;
          };
        };
      };
    }

Tested on NixOS 17.03.

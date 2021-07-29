---
layout: post
title: NixOS on the Framework
tags:
  - nix
  - nixos
  - framework
  - hardware

---

<a href="/resources/2021-07-29-framework-nixos.png" target="_blank">![NixOS 21.11 with GNOME running on the Framework laptop.](/resources/2021-07-29-framework-nixos.small.png)</a>

What a treat it is to review the <a href="https://frame.work" target="_blank">Framework</a> laptop a few months before I'll be buying my own.

The Framework promises to be an powerful, high-end ultra thin laptop with the stand-out feature of easy repairs and upgrades. I think they've done it.

Let's install NixOS.

## Live Media

You'll need an install image with Linux 5.13 or newer to have a working Wi-Fi card.

This presents a challenge: the ISOs provided by [https://nixos.org]() today use Linux 5.10.

If you're comfortable installing NixOS without a GUI, you can [fetch a minimal 21.05 ISO with the latest kernel from Hydra](https://hydra.nixos.org/job/nixos/release-21.05/nixos.iso_minimal_new_kernel.x86_64-linux/latest).

### Optionally, Building Our Own Live Media

Building your own customized install media is straightforward. You'll need a Linux machine with Nix.

First, write the following in to a file named `custom-media.nix`:

```nix
{ pkgs, modulesPath, ... }: {
    imports = [
        "${modulesPath}/installer/cd-dvd/installation-cd-graphical-gnome.nix"
    ];

    boot.kernelPackages = pkgs.linuxPackages_latest;
}
```

Then enter a nix-shell with `nixos-generators` and build the media:

```console
$ nix-shell -p nixos-generators
nix-shell$ nixos-generate -I nixpkgs=channel:nixos-unstable --format iso --configuration ./custom-media.nix 
unpacking 'https://nixos.org/channels/nixos-unstable/nixexprs.tar.xz'...
these derivations will be built:
  ...snip...
/nix/store/gnnbjvd916yh1f4svbgrssq94550pbxl-nixos-21.11pre304626.8ecc61c91a5-x86_64-linux.iso/iso/nixos-21.11pre304626.8ecc61c91a5-x86_64-linux.iso
```

Then copy the ISO to my USB disk, which is called `/dev/sda`.

_Note: the `sync` at the end is critical._

```
$ sudo cp /nix/store/gnnbjvd916yh1f4svbgrssq94550pbxl-nixos-21.11pre304626.8ecc61c91a5-x86_64-linux.iso/iso/nixos-21.11pre304626.8ecc61c91a5-x86_64-linux.iso /dev/sda
$ sudo sync
```

## Disabling Secure Boot

1. Reboot
1. Enter the Firmware Configuration (`Fn` + `F2`)
1. Navigate to the _Security_ tab
1. Select _Secure Boot_
1. Select _Enforce Secure Boot_
1. Select _Disabled_
1. Save and reboot with `Fn` + `F10`

_Note: Secure Boot will prevent unsigned software from running. NixOS does not support Secure Boot today._

## Booting Your Media

It appears the machine can boot from any USB port.

1. Reboot
1. Enter the Boot Manager (`Fn` + `F12`)
1. Select your USB disk

## Installing NixOS


Follow the [standard NixOS installation instructions](https://nixos.org/manual/nixos/stable/index.html#sec-installation).

After running `nixos-generate-config`, edit `/mnt/etc/nixos/configuration.nix` and add a few lines:

* `boot.kernelPackages = pkgs.linuxPackages_latest;` - for WiFi support
* `services.fprintd.enable = true;` for fingerprint support

Continue the installation procedure.

Seriously. That's it.

---

# Hardware Review

The review unit they shipped me is pre-release hardware, but well specced out and lovely:

* 11th Gen Intel i7-1185G7, up to 4.8GHz
* 16G of RAM
* Intel(R) Wi-Fi 6 AX210 160MHz, REV=0x420
* 2 USB-C ports, a mini-display port, and a Micro SD slot

Its performance seems quite good, easily good enough for my day to day work. It has no problems driving my 38" ultrawide display.

The machine is silent except when I'm compiling, and it has never felt hot. After a long compilation some areas near the hinge are noticably warm, but the hand rests are still cool.

The keyboard and trackpad feel, to me, perfect. The keys feel crisp but not heavy. The trackpad feels large and precise. That said, click is a bit _too_ clicky.

Hardware switches for the audio and camera are nice, but a bit hard to toggle. The switches are very small and smooth, making it difficult to move. The switches are part of the replacable bezel, and this may be easily fixed.

The power brick is UL Energy Verified and just slightly larger than the Dell XPS 9300 brick.

The Intel Wi-Fi 6 AX210 has integration issues with Linux. Sometimes the wifi firmware crashes on startup, but it seems to be no more frequent than 50/50. Once it is booted, the wifi is rock solid.

## QR Codes on Everything

<a href="/resources/2021-07-29-framework-inside.png" target="_blank">![The inside of the laptop, with dozens of QR codes.](/resources/2021-07-29-framework-inside.small.png)</a>

Everything has a QR code as a link to instructions. And I mean everything: down to the cable connecting the wall to the power brick.

However, many of them don't actually lead anywhere. I wasn't too surprised to see the power cable's QR code was 404ing, but a bit surprised to see the link for RAM replacement 404ing. I am sure this is a work in progress and these QR codes will all work.

## Relative to the XPS 9300

I want the smallest, lightest laptop I can buy, and the Framework is a strong contender here.

This laptop is essentially the same width and thickness: within a milimeter or two. The framework comes in at just 60 grams heavier than the XPS (1330g vs. 1270g.)

One major improvement over the 9300: The fingerprint sensor is supported by recent versions of fprintd out of the box, and no TOD patches are required. The sensor is fast and reliable, whereas the Dell XPS 9300's TOD Goodix drivers are nearly worthless on Linux.

Some aspects of the Framework are a bit more "industrial" feeling:

* The cable from the brick to the wall looks like a desktop PC's cable. Thick, shiny plastic. compared to the more polished, polished, on-brand look of the Dell cable.
* The rubber feet are chunky, and not super sticky.
* Opening the lid is not _super_ easy like on the XPS.

# Ready to Buy

Overall, I am extremely satisfied by Framework. The team seems great, and their values appear to match my own. I'll be pulling out my wallet later this year when my current laptop isn't so new. I think they've fulfilled their promise, and have created a refreshing machine: an ultralight which is servicable.

Yes, please.

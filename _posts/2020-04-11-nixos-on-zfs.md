---
layout: post
title: ZFS Datasets for NixOS
tags: nix
---

The outdated and historical nature of the [Filesystem Hierarchy
Standard](fhs) means traditional Linux distributions have to go to great
lengths to separate "user data" from "system data."

NixOS's filesystem architecture does cleanly separate user data from
system data, and has a much easier job to do.

### Traditional Linuxes

Because FHS mixes these two concerns across the entire hierarchy,
splitting these concerns requires identifying every point across
dozens of directories where the data is the system's or the user's.
When adding ZFS to the mix, the installers typically have to create
over a dozen datasets to accomplish this.

For example, Ubuntu's upcoming ZFS support creates 16 datasets:

```tree
rpool/
├── ROOT
│   └── ubuntu_lwmk7c
│       ├── log
│       ├── mail
│       ├── snap
│       ├── spool
│       ├── srv
│       ├── usr
│       │   └── local
│       ├── var
│       │   ├── games
│       │   └── lib
│       │       ├── AccountServices
│       │       ├── apt
│       │       ├── dpkg
│       │       └── NetworkManager
│       └── www
└── USERDATA
```


Going through the great pains of separating this data comes with
significant advantages: a recursive snapshot at any point in the tree
will create an atomic, point-in-time snapshot of every dataset below.

This means in order to create a consistent snapshot of the system
data, an administrator would only need to take a recursive snapshot
at `ROOT`. The same is true for user data: take a recursive snapshot of
`USERDATA` and all user data is saved.

### NixOS

Because Nix stores all of its build products in `/nix/store`, NixOS
doesn't mingle these two concerns. NixOS's runtime system, installed
packages, and rollback targets are all stored in `/nix`.

User data is not.

This removes the entire complicated tree of datasets to facilitate
FHS, and leaves us with only a few needed datasets.

## Datasets

Design for the atomic, recursive snapshots when laying out the
datasets.

In particular, I don't back up the `/nix` directory. This entire
directory can always be rebuilt later from the system's
`configuration.nix`, and isn't worth the space.

One way to model this might be splitting up the data into three
top-level datasets:

```tree
tank/
├── local
│   └── nix
├── system
│   └── root
└── user
    └── home
```

In `tank/local`, I would store datasets that should almost never be
snapshotted or backed up. `tank/system` would store data that I would
want periodic snapshots for. Most importantly, `tank/user` would
contain data I want regular snapshots and backups for, with a long
retention policy.

From here, you could add a ZFS dataset per user:

```tree
tank/
├── local
│   └── nix
├── system
│   └── root
└── user
    └── home
        ├── grahamc
        └── gustav
```

Or a separate dataset for `/var`:

```tree
tank/
├── local
│   └── nix
├── system
│   ├── var
│   └── root
└── user
```

Importantly, this gives you three buckets for independent and
regular snapshots.

The important part is having `/nix` under its own top-level dataset.
This makes it a "cousin" to the data you _do_ want backup coverage on,
making it easier to take deep, recursive snapshots atomically.

## Properties

* Enable compression with `compression=on`. Specifying `on` instead of
  `lz4` or another specific algorithm will always pick the best
  available compression algorithm.
* The dataset containing journald's logs (where `/var` lives) should
  have `xattr=sa` and `acltype=posixacl` set to allow regular users to
  read their journal.
* Nix doesn't use `atime`, so `atime=off` on the `/nix` dataset is
  fine.
* NixOS requires (as of 2020-04-11) `mountpoint=legacy` for all
  datasets. NixOS does not yet have tooling to require implicitly
  created ZFS mounts to settle before booting, and `mountpoint=legacy`
  plus explicit mount points in `hardware-configuration.nix` will
  ensure all your datasets are mounted at the right time.

I don't know how to pick `ashift`, and usually just allow ZFS to guess
on my behalf.

## Partitioning

I only create two partitions:

1. `/boot` formatted `vfat` for EFI, or `ext4` for BIOS
2. The ZFS dataset partition.

There are spooky articles saying only give ZFS entire disks. The
truth is, you shouldn't split a disk into two active partitions.
Splitting the disk this way is just fine, since `/boot` is rarely
read or written.

> *Note:* If you do partition the disk, make sure you set the disk's
> scheduler to `none`. ZFS takes this step automatically if it does
> control the entire disk.
>
> On NixOS, you an set your scheduler to `none` via:
>
> ```nix
> { boot.kernelParams = [ "elevator=none" ]; }
> ```

# Clean isolation

NixOS's clean separation of concerns reduces the amount of complexity
we need to track when considering and planning our datasets. This
gives us flexibility later, and enables some superpowers like erasing
my computer on every boot, which I'll write about on Monday.


[fhs]: https://en.wikipedia.org/wiki/Filesystem_Hierarchy_Standard

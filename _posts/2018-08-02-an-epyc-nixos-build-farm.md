---
layout: post
title: an EPYC NixOS build farm
tags: nix
---

# EPYC vs m1.xlarge.x86
Nix is a powerful package manager for Linux and other Unix systems that makes package management reliable and reproducible. It provides atomic upgrades and rollbacks, side-by-side installation of multiple versions of a package, multi-user package management and easy setup of build environments.

The Nix community has collected and curated build instructions (“expressions”) for many thousands of packages in the Nix package collection, Nixpkgs. Nixpkgs is a large GitHub repository, which receives over a thousand pull requests each month. Some of these changes can some times cause all of the packages to rebuild.

To test changes to Nixpkgs and release updates for Nix and NixOS, we necessarily created our own build infrastructure. This allows us to give better quality guarantees to our users.

The NixOS infrastructure team runs several types of servers: VMs on AWS, Packet bare metal, macOS systems, among others. We build thousands of packages a day, sometimes reaching many tens of thousands per day.

Some of our builds depend on unique features like KVM which are only available by using bare metal servers, and all of them benefit from numerous, powerful cores.

For over a year now, Packet.net has been generously providing bare metal hardware build resources for the NixOS build farm, and together we were curious how the new EPYC from AMD would compare to the hardware we were already using.

For this benchmark we are comparing Packet’s `m1.xlarge.x86` against Packet’s first EPYC machine, `c2.medium.x86`. Hydra already runs a `m1.xlarge.x86` build machine, so the comparison will be helpful in deciding if we should replace it with EPYC hardware.

AMD EPYC has the chance to reduce our hardware footprint, reduce our need for our AWS scale-out, and improve our turnaround time for time-sensitive security patches.


## System Comparison:
| Check         | m1.xlarge.x86                                        | c2.medium.x86 (EPYC)                                      |
| ------------- | ---------------------------------------------------- | --------------------------------------------------------- |
| NixOS Version | 18.03.132610.49a6964a425                             | 18.03.132610.49a6964a425                                  |
| cost          | $1.70/hr                                             | $1.00/hr                                                  |
| CPU           | 24 Physical Cores @ 2.2 GHz (2 × E5-2650 v4)         | 24 Physical Cores @ 2.2 GHz (1 x AMD EPYC 7401P)          |
| RAM           | 256 GB of ECC RAM                                    | 64 GB of ECC RAM                                          |
|               | https://www.packet.net/bare-metal/servers/m1-xlarge/ | https://www.packet.net/bare-metal/servers/c2-medium-epyc/ |

## Benchmark Methods

All of these tests were run on a fresh Packet.net server running NixOS 18.03 and building Nixpkgs revision `[49a6964a425](https://github.com/NixOS/nixpkgs/tree/49a6964a4250d98644da61f24dcc11ee0b28c4f9)`. For each test, I ran each build five times on each machine with `--check` which forces a local rebuild:


    checkM() {
      nix-build . -A "$1"
      for i in $(seq 1 5); do
        rm result
        nix-collect-garbage
        /run/current-system/sw/bin/time -ao "./timing-$1" nix-build . -A "$1" --check
      done
    }



## Benchmark Results

**Kernel Builds**

NixOS builds a generously featureful kernel by default, and the build can take some time. However, the compilation is well parallelizable across many cores. In what we will further see is a theme, the EPYC beat the Intel CPU with by about five minutes, or about 35% speed-up.

| Test                                            | # | m1.xlarge.x86 (seconds) | EPYC (seconds) | Speed-up |
| ----------------------------------------------- | - | ----------------------- | -------------- | -------- |
| `nix-build '<nixpkgs>' -A linuxPackages.kernel` | 1 | 823.77                  | 535.30         | 35.02%   |
|                                                 | 2 | 821.27                  | 536.94         | 34.62%   |
|                                                 | 3 | 824.92                  | 538.45         | 34.73%   |
|                                                 | 4 | 827.74                  | 537.79         | 35.03%   |
|                                                 | 5 | 827.37                  | 539.98         | 34.74%   |


**NixOS Tests**

The NixOS release process is novel in that package updates happen automatically as an entire cohesive set. We of course test that specific software compiles properly, but we are also able to perform fully automatic integration tests. We test that the operating system can boot, desktop environments work, and even server tests like validating that our MySQL server replication is still working. These tests happen automatically on every release and is a unique benefit to the Nix build system being applied to an operating system.

These tests use QEMU and KVM, and spawn one or more virtual machines running NixOS.

#### Plasma5 and KDE

[The Plasma5 test](https://github.com/NixOS/nixpkgs/blob/49a6964a4250d98644da61f24dcc11ee0b28c4f9/nixos/tests/plasma5.nix) looks like the following:


1. First launches a NixOS VM configured to run the Plasma5 desktop manager.
2. Uses Optical Character Recognition to wait until it sees the system is ready for Alice to log in and then types in her password:
    $machine->waitForText(qr/Alice Foobar/);
    $machine->sendChars("foobar\n");
3. Waits for the Desktop to be showing, which reliably indicates she has finished logging in:
    $machine->waitForWindow("^Desktop ");

4. Launches Dolphin, Konsole, and Settings and waits for each window to appear before continuing:

    $machine->execute("su - alice -c 'DISPLAY=:0.0 dolphin &'");
    $machine->waitForWindow(" Dolphin");
    $machine->execute("su - alice -c 'DISPLAY=:0.0 konsole &'");
    $machine->waitForWindow("Konsole");
    $machine->execute("su - alice -c 'DISPLAY=:0.0 systemsettings5 &'");
    $machine->waitForWindow("Settings");
5. If all of these work correctly, the VM shuts down and the tests pass.

Better than the kernel tests, we’re pushing a 40% improvement.

| Test                                            | # | m1.xlarge.x86 (seconds) | EPYC (seconds) | Speed-up |
| ----------------------------------------------- | - | ----------------------- | -------------- | -------- |
| `nix-build '<nixpkgs/nixos/tests/plasma5.nix>'` | 1 | 185.73                  | 115.23         | 37.96%   |
|                                                 | 2 | 189.53                  | 116.11         | 38.74%   |
|                                                 | 3 | 191.88                  | 115.18         | 39.97%   |
|                                                 | 4 | 189.38                  | 116.05         | 38.72%   |
|                                                 | 5 | 188.98                  | 115.54         | 38.86%   |



#### MySQL Replication

[The MySQL replication test](https://github.com/NixOS/nixpkgs/blob/49a6964a4250d98644da61f24dcc11ee0b28c4f9/nixos/tests/mysql-replication.nix) launches a MySQL master and two slaves, and runs some basic replication tests. NixOS allows you to define replication as part of the regular configuration management, so I will start by showing the machine configuration of a slave:


    {
      services.mysql.replication.role = "slave";
      services.mysql.replication.serverId = 2;
      services.mysql.replication.masterHost = "master";
      services.mysql.replication.masterUser = "replicate";
      services.mysql.replication.masterPassword = "secret";
    }


1. This test starts by starting the master and waiting for MySQL to be healthy:
    $master->start;
    $master->waitForUnit("mysql");
    $master->waitForOpenPort(3306);
2. Continues to start slave1 and slave2 and wait for them to be up:
    $slave1->start;
    $slave2->start;
    $slave1->waitForUnit("mysql");
    $slave2->waitForUnit("mysql");
    $slave1->waitForOpenPort(3306);
    $slave2->waitForOpenPort(3306);
3. It then validates some of the scratch data loaded in to the master has replicated properly to slave2:
    $slave2->succeed("echo 'use testdb; select * from tests' | mysql -u root -N | grep 4");
4. Then shuts down slave2:
    $slave2->succeed("systemctl stop mysql");
5. Writes some data to the master:
    $master->succeed("echo 'insert into testdb.tests values (123, 456);' | mysql -u root -N");
6. Starts slave2, and verifies the queries properly replicated from the master to the slave:
    $slave2->succeed("systemctl start mysql");
    $slave2->waitForUnit("mysql");
    $slave2->waitForOpenPort(3306);
    $slave2->succeed("echo 'select * from testdb.tests where Id = 123;' | mysql -u root -N | grep 456");

Due to the multiple VM nature, and increased coordination between the nodes, we only saw a 30% increase.

| Test                                                      | # | m1.xlarge.x86 (seconds) | EPYC (seconds) | Speed-up |
| --------------------------------------------------------- | - | ----------------------- | -------------- | -------- |
| `nix-build '<nixpkgs/nixos/tests/mysql-replication.nix>'` | 1 | 42.32                   | 29.94          | 29.25%   |
|                                                           | 2 | 43.46                   | 29.48          | 32.17%   |
|                                                           | 3 | 42.43                   | 29.83          | 29.70%   |
|                                                           | 4 | 43.27                   | 29.66          | 31.45%   |
|                                                           | 5 | 42.07                   | 29.37          | 30.19%   |


#### BitTorrent

[The BitTorrent test](https://github.com/NixOS/nixpkgs/blob/49a6964a4250d98644da61f24dcc11ee0b28c4f9/nixos/tests/bittorrent.nix) follows the same pattern of starting and stopping a NixOS VM, but this test takes it a step further and tests with four VMs which talk to each other. I could do a whole post *just* on this test, but in short:


- a machine serving as the tracker, named `$tracker`.
- a client machine, `$client1`
- another client machine, `$client2`
- a router which facilitates some of the incredible things this test is actually doing.

I’m going to gloss over the details here, but:


1. The tracker starts seeding a file:
    $tracker->succeed("transmission-create /tmp/data/test.tar.bz2 -p -t http://${(pkgs.lib.head nodes.tracker.config.networking.interfaces.eth1.ipv4.addresses).address}:6969/announce -o /tmp/test.torrent");
    $tracker->succeed("opentracker -p 6969 >&2 &");
    $tracker->waitForOpenPort(6969);
    my $pid = $tracker->succeed("transmission-cli /tmp/test.torrent -M -w /tmp/data >&2 & echo \$!");
2. Client1 fetches the file from the tracker:
    $client1->succeed("transmission-cli http://tracker/test.torrent -w /tmp >&2 &");
3. Kills the seeding process on tracker so now only Client1 is able to serve the file
    $tracker->succeed("kill -9 $pid");
4. Client2 fetches the file from Client1:
    $client2->succeed("transmission-cli http://tracker/test.torrent -M -w /tmp >&2 &");

If both client1 and client2 receive the file intact, the test passes.

This test sees a much lower performance improvement, largely due to the networked coordination across four VMs.

| Test                                               | # | m1.xlarge.x86 (seconds) | EPYC (seconds) | Speed-up |
| -------------------------------------------------- | - | ----------------------- | -------------- | -------- |
| `nix-build '<nixpkgs/nixos/tests/bittorrent.nix>'` | 1 | 54.22                   | 45.37          | 16.32%   |
|                                                    | 2 | 54.40                   | 45.51          | 16.34%   |
|                                                    | 3 | 54.57                   | 45.34          | 16.91%   |
|                                                    | 4 | 55.31                   | 45.32          | 18.06%   |
|                                                    | 5 | 56.07                   | 45.45          | 18.94%   |

*The remarkable part I left out is Client1 uses UPnP to open a port of the firewall of the router which Client2 uses to read from Client1.*


**Standard Environment**

Our standard build environment, `stdenv`, is at the deepest part of this tree and almost nothing can be built until after it is completed. `stdenv` is like `build-essential` on Ubuntu.

This is an important part of the performance story for us: Nix builds are represented by a tree, where Nix will schedule as many parallel builds as possible as long as its parents are done building. Single core performance is the primary factor impacting how long these builds take. Shaving off even a few minutes means [our entire build cluster](https://hydra.nixos.org/machines) is able to get to share the work sooner.

For this reason, the stdenv test is the one exception to the methodology. I wanted to test a full build from bootstrap to a working standard build environment. To force this, I changed the very root build causing everything “beneath” it to require a rebuild by applying the following patch:


    diff --git a/pkgs/stdenv/linux/default.nix b/pkgs/stdenv/linux/default.nix
    index 63b4c8ecc24..1cd27f216f9 100644
    --- a/pkgs/stdenv/linux/default.nix
    +++ b/pkgs/stdenv/linux/default.nix
    @@ -37,6 +37,7 @@ let

       commonPreHook =
         ''
    +
           export NIX_ENFORCE_PURITY="''${NIX_ENFORCE_PURITY-1}"
           export NIX_ENFORCE_NO_NATIVE="''${NIX_ENFORCE_NO_NATIVE-1}"
           ${if system == "x86_64-linux" then "NIX_LIB64_IN_SELF_RPATH=1" else ""}

The impact on build time here is stunning and makes an enormous difference: almost a full 20 minutes shaved off the bootstrapping time.

| Test                                     | # | m1.xlarge.x86 (seconds) | EPYC (seconds) | Speed-up |
| ---------------------------------------- | - | ----------------------- | -------------- | -------- |
| `nix-build . -A stdenv`                  | 1 | 2,984.24                | 1,803.40       | 39.57%   |
| (after a mass-rebuild change, see below) | 2 | 2,976.10                | 1,808.97       | 39.22%   |
|                                          | 3 | 2,990.66                | 1,808.21       | 39.54%   |
|                                          | 4 | 2,999.36                | 1,808.30       | 39.71%   |
|                                          | 5 | 2,988.46                | 1,818.84       | 39.14%   |

## Conclusion

This EPYC machine has made a remarkable improvement in our build times and is helping the NixOS community push timely security updates and software updates to users and businesses alike. We look forward to expanding our footprint to keep up with the incredible growth of the Nix project.

Thank you to Packet.net for providing this hardware free of charge for this test through their [EPYC Challenge](https://www.packet.net/epyc).

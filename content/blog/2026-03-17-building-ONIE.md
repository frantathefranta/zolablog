+++
title = "Building ONIE"
authors = [ "Franta Bartik" ]
date = "2026-03-17"
description = "Setting up an ONIE build environment in an incus VM"

[taxonomies]
tags=['incus', 'networking']
+++

## Building ONIE

I was trying to help someone install Cumulus Linux on their **DNI 3048UP** switch. However it seems that their ONIE version was too old to install a more recent version of Cumulus than 3.7.16. I used these resources to build an image:

-   [Preparing an ONIE Build Environment](https://opencomputeproject.github.io/onie/developers/building.html#preparing-an-onie-build-environment)
-   [DUE ONIE README.md](https://github.com/CumulusNetworks/DUE/blob/master/templates/onie/README.md)
-   [Building ONIE with DUE](https://www.lucaswilliams.net/index.php/2024/06/12/building-onie-with-due/) (this one was the most useful as it&rsquo;s more recent and deals with EOL&rsquo;d Debian issues)

I chose to set up an `incus` Ubuntu VM, as I have it installed on my NixOS laptop already. In the VM, I built a `due` container for building ONIE images.


### incus specifics

I ran into issues with limited resources (Linux OOM-killer will kill the `genautomata` process). These settings worked for me:

-   Increase memory to **8 GiB** (from 1 GiB)
-   Increase storage to **25 GiB** (from 10 GiB)
-   Increase CPU cores to **4** (from 1)

I chose `ubuntu/noble` arbitrarily, since it was in my shell history. Anything that can use `.deb` or `.rpm` packages should work fine.

``` sh
# I named the VM onie-build
incus launch images:ubuntu/noble --vm onie-build

incus config set onie-build limits.memory=8GiB
incus config device override onie-build root size=25GiB
incus config set onie-build limits.cpu 4

incus exec onie-build -- bash
```



### Setting up an admin user

`due` freaks out if you run it as root, it expects a normal user with `docker` privileges.

``` sh
useradd -m -G docker -s /bin/bash admin
```


### Setting up `due`

I first installed due from the Ubuntu repo to resolve dependencies (docker, etc...), then I downloaded the `.deb` from the **CumulusNetworks/DUE** repo because the `ubuntu/noble` version is too old and can't deal with filesystem patches.

As `root`: 

``` sh
apt update && apt install due
wget https://github.com/CumulusNetworks/DUE/releases/download/v4.1.0/due_4.1.0-1_all.deb
dpkg -i ./due_4.1.0-1_all.deb

# The .deb didn't come with image-patches, so I took them from the repo
git clone https://github.com/CumulusNetworks/DUE.git && cp -r DUE/image-patches /usr/share/due/
```


### Working with `due`

Creating a Debian 9 build container.

As the `admin` user:

``` sh
due --create --platform linux/amd64 --name onie-build-debian-9 --prompt ONIE-9 --tag onie-9 --use-template onie --from debian:9 --description 'ONIE Build Debian 9' --image-patch debian/9/filesystem
due --run -i due-onie-build-debian-9:onie-9 --dockerarg --privileged
```

### (optional) Setting up a local cache

As `root`:
``` sh
mkdir -p /var/cache/onie/download/
cd /var/cache/onie/download/ && wget --recursive --cut-dirs=2 --no-host-directories --no-parent --reject="index.html" "http://mirror.opencompute.org/onie"
```

Then open `due --run` with the `--mount-dir /var/cache/onie/download/:/var/cache/onie/download/` option. 

`make` commands should be executed with `ONIE_USE_SYSTEM_DOWNLOAD_CACHE=TRUE`.


### Building ONIE

Switch I was targeting needed the **2020.05br** branch (you can figure this out from `build-config/scripts/onie-build-targets.json` in the ONIE git repo). 

Execute these commands either as `admin` or in the `due` container:
``` sh
git clone https://github.com/opencomputeproject/onie.git
cd onie
git checkout 2020.05br

# The builder expects these gitconfig values
git config --global user.email "<email>"
git config --global user.name "<name>"
```

You'll know if you need to change the branch if you run into this error when building the image:
``` sh
make: *** No rule to make target 'conf/crosstool/gcc-4.9.2/uClibc-ng-1.0.38/crosstool.x86_64.config', needed by '/home/build/src/onie/build/x-tools/x86_64-g4.9.2-lnx4.9.95-uClibc-ng-1.0.38/build/.config'. Stop.
```


Finally, build ONIE:
``` sh
cd build-config/
# This will use 4 cores to build the image
make -j4 MACHINEROOT=../machine/dni/ MACHINE=dni_3048up all
```

The resulting files will be in `build/images/`. How to install them on the switch is out of the scope of this post, but most switches have instructions in the **INSTALL** file in their directory in the ONIE repo.

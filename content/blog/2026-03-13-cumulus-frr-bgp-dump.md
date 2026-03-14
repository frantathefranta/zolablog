+++
date = 2026-03-13
title = "Dumping BGP MRT in Cumulus Linux"
description = "How-to on obtaining BGP MRT output in Cumulus"
author = "Franta Bartik"

[taxonomies]
tags=['networking', 'bgp']
+++

## Motivation
I wanted to import some real routes from a **PE** router (for an Nvidia AIR simulation) and this seemed like the easiest way about it. I heard about [MRT](https://github.com/Exa-Networks/exabgp/wiki/MRT-Format#what-is-mrt) before, so I searched Cumulus documentation to see if there was an `NVUE` command for this, but it seems like there is not (as of version **5.16**). Cumulus allows you to just use the `vtysh` shell so I did that.

## Procedure
This outlines steps to use a Cumulus router for gathering a BGP table and then using the BGP table in further Cumulus configuration.

### Extracting an MRT file from FRR

I initially used the `vtysh` method because I couldn't find how to do this using `NVUE` CLI. Turns out, there is a way to do it using [_"snippets"_](https://docs.nvidia.com/networking-ethernet-software/cumulus-linux-516/System-Configuration/NVIDIA-User-Experience-NVUE/NVUE-Snippets). 

#### Correct method
An example snippet that dumps the MRT looks like this:

``` yaml
- set:
    system:
      config:
        snippet:
          frr.conf: |
            dump bgp routes-mrt /tmp/routes-mrt
```

You'll then use this as a file in the CLI:

``` sh
nv config patch snippet.yaml
nv config apply
```


#### (most likely) Incorrect method
**USE THE METHOD ABOVE**
This does require entering `configure` mode in **FRR**, but AFAIK it doesn't make any changes in routing behavior (nor should it).
``` sh
fbartik@cumulus:mgmt:~$ sudo vtysh
cumulus# configure
cumulus(config)# dump bgp routes-mrt /tmp/routes-mrt 
```
The `dump` command requires a path, which needs to be somewhere **FRR** can write into (so either `/tmp` or `/etc/frr`). Optionally you can specify an interval (after the path argument, using `strftime` format) for continuous creation of the BGP table output.

### Parsing the MRT file

The first tool that comes up in search is [RIPENCC/bgpdump](https://github.com/RIPE-NCC/bgpdump) (however the version in `nixpkgs` was not built for `aarch64-darwin` at the time). 

I ran into [bgpkit/monocle](https://github.com/bgpkit/monocle) as well, so I used that.

#### Example usage

``` sh
monocle parse ./routes-mrt # Prints all routes
monocle parse -j <peer_IP> ./routes-mrt # Prints routes from a chosen peer
monocle parse -o 13335 ./routes-mrt # Prints routes from a chosen origin ASN
monocle parse -C "13335:*" ./routes-mrt # Prints routes containing BGP communities starting with 13335
```

#### Useful flags

* `--format=json` will print the data in JSON, as the default is a pipe (`|`) separated table.

#### Creating an NVUE configuration from MRT file

This command will print routes from  peer `192.0.2.1` and then turn them into an `nv` command that will add the routes as static in the routing table of VRF `TEST`.
``` sh
monocle parse -j 192.0.2.1 routes-mrt --format json | jq --raw-output '"nv set vrf TEST router static \(.prefix) via blackhole"'
```
`--raw-output` is used because `jq` prints results with double quotes by default, which is not recognized as a command in Cumulus.

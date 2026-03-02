+++
date = 2026-03-01
title = "Figuring out APC NMC2 DHCP issues"
description = "<b>TL;DR:</b> Make sure the UPS's own firewall is not interfering."
author = "Franta Bartik"

[taxonomies]
tags=['Troubleshooting']
+++
**TL;DR:** <mark>Make sure the UPS's own firewall is not interfering.</mark>


I've recently obtained an **APC SMT1000RM2U** UPS with an NMC2 card. The issue I've ran into was that plugging the NMC2 card in my network quickly resulted in depleted DHCP leases in any subnet I tried. First I suspected the problem was caused by settings from the previous owner (sort of right), so I attempted to factory reset the card/UPS using the front panel. Sadly that did not work as it only seems to have reset some things, but not actually any important information from the card/UPS. 

Another reason I thought that the DHCP issues were happening was because some [APC guides say you need to set a special cookie](https://web.archive.org/web/20260113191146/https://www.se.com/us/en/faqs/FA156064/) when sending `DHCP OFFER` messages. However when I added that option in my KEA DHCP server, it still showed same behavior. Also my UPS was on firmware 6.x.x which seems to not need the cookie anyways, but wanted to try it just in case. 

At this point I realized I needed to connect to the serial console port on the NMC2. This is a 2.5mm "jack" that you may recognize from balanced audio outputs. After obtaining first a cable that had a 3.5mm jack on the end, then getting one with a 2.5mm jack and a USB-A port with a built-in serial converter (and them both not working), I caved and got the APC OEM cable (model 940-0299A). This one worked immediately and I could finally log-in over console and see what was up. 

I first tried to set a static IP on the UPS using the `tcpip` command (which is something I've done from the front panel as well and the following behavior should have tipped me off) and tried to ping the IP. It did not work and after digging through the available commands, I realized why. It seems that the previous owner set a firewall on the NMC2 card in such a way that `DHCP OFFER` messages couldn't be `ACK`'d. I remedied that by turning the firewall off using `firewall -S disable`. After that, I could ping the IP of the UPS and it could finally receive a DHCP lease correctly.
I'm wondering if this UPS had a public IP at any point in its life and that was the only way for it to be *"safe"*. My plans for the management for this UPS are to be completely local, which I'll probably achieve by just not giving it a gateway (and by extension the IPv6 router in its subnet won't advertise a default route to it either).

## Additional notes about the UPS

### Setting an IP using the ARP method

Apparently you can set an IP using an `arp` command. First use it to set a static IP on your host, then ping the IP with a byte-specific `ping` command to set it on the NMC2. This did not work, most likely due to the firewall.

### Password reset

1. Open a serial console to the NMC2 card.
2. Press the reset button on the NMC2. The flashing light on the RJ45 port will stop flashing.
3. After 5-7 seconds the light on the RJ45 port will start flashing rapidly, press the reset button again when it happens.
4. You now have 30 seconds to log-in over the serial console connection using `apc:apc`.

### ssh connection settings

The `ssh` server version on the NMC2 is obviously ancient, so these settings need to be passed when connecting (using an OpenSSH client version 10.2):
```shell
ssh apc@apc-pdu01 -o HostKeyAlgorithms=+ssh-rsa -o Ciphers=+aes256-cbc
```

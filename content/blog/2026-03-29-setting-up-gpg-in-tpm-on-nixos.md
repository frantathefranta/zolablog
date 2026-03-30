+++
title = "GPG in TPM on NixOS"
authors = [ "Franta Bartik" ]
date = "2026-03-29"
description = "Setting up a GPG key in TPM on NixOS"

[taxonomies]
tags=['nixos']
+++

## Motivation
I have 3 YubiKeys set up with GPG keys. I wanted to try to have a key inside of the TPM of the NixOS laptop that I use at home. 

## Sources
I've mainly used 2 resources to get all the necessary commands to generate a GPG key in a TPM:
* <https://blog.wrouesnel.com/posts/tpm-secured-gpg-keys/>
* <https://blog.dan.drown.org/gpg-key-in-tpm/> (this is an update on the above blog with important fixes)

## Steps
### Initial Nix config

These are the basic `nix` toggles you need to make to make sure TPM works (and your user can interact with it).
``` nix
  security.tpm2.enable = true;
  security.tpm2.pkcs11.enable = true; # expose /run/current-system/sw/lib/libtpm2_pkcs11.so
  security.tpm2.tctiEnvironment.enable = true; # TPM2TOOLS_TCTI and TPM2_PKCS11_TCTI env variables
  users.users.<user>.extraGroups = [ "tss" ]; # tss group has access to TPM devices
```

### Shell commands
Used variables:
* `userpin` = PIN code that gets used to unlock the GPG key
* `adminpin` = master PIN (unsure about the use, but I set it to about twice as long as `userpin`)

``` shell
$ tpm2_ptool init

$ tpm2_ptool addtoken --pid=1 --label="gpg" --userpin="${userpin}" --sopin="${adminpin}"

$ tpm2_ptool addkey --label="gpg" --key-label="gpg" --userpin="${userpin}" --algorithm=rsa2048
```

### Using `p11` tools

Now, this is where my approach differs from the above sources. AFAICT they have installed the necessary PKCS#11 dependencies on Ubuntu/Fedora, which set up the config files for immediate use. However on NixOS that's not the case (as of March 2026, could change in the future). This is the tweak I had to make:
``` nix
# /etc/pkcs11/modules/tpm_pkcs11 has to exist:
  environment.etc."pkcs11/modules/tpm2_pkcs11".text = ''
    module: ${pkgs.tpm2-pkcs11}/lib/libtpm2_pkcs11.so
    critical: yes
  '';
```
This file will ensure that `p11-kit list-modules` actually works. Without the module loaded, the subsequent commands will fail.

#### Extract the token URI
Run `p11tool --list-token-urls | grep token=gpg` to get a URI that will look similar to this: `pkcs11:manufacturer=STMicro;serial=0123456789012345;token=gpg`. Then use that URI in another `p11tool` command:

``` shell
p11tool --list-privkeys --login --only-urls --set-pin="${userpin}" "${tokenURI}"
```

Finally, you can test whether the key works (`${privateURI}` is the output of the above command):
``` shell
p11tool --test-sign --login --set-pin=${userpin} "${privateURI}"

# Output should look like this:
Signing using RSA-SHA256... ok
Verifying against private key parameters... ok
Verifying against public key in the token... ok
```

### Creating a certificate
Create a file `template.ini`. 
* `${name}` = Your name
* `${email}` = Your email
* For the serial, you can use this date command: `$(date --utc +%Y%m%d%H%M%S)`

``` ini
cn = "${name}"
serial = 20260330032616
expiration_days = 3650
email = "${email}"
signing_key
encryption_key
cert_signing_key
```

Use the template to export a certificate:

``` shell
GNUTLS_PIN="${userpin}" certtool --generate-self-signed --template "template.ini" \
    --load-privkey "${privateURI}" --outfile "${name}.crt"
```

Import the certificate to the TPM (or at least I think that's what's happening):

``` shell
tpm2_ptool addcert --label=gpg --key-label=gpg "${name}.crt"
```

### `home-manager` additions
This is a barebones GPG configuration in `home-manager`.
``` nix
  services.gpg-agent = {
    enable = true;
    enableExtraSocket = true;
    enableScDaemon = true;
    extraConfig = ''
      scdaemon-program ${pkgs.gnupg-pkcs11-scd}/bin/gnupg-pkcs11-scd
    '';
    pinentry.package = pkgs.pinentry-tty # Or your pinentry of choice
  programs.gpg = {
    enable = true;
    settings = {
        trust-model = "tofu+pgp";
    };
  };
  home.file.".gnupg/gnupg-pkcs11-scd.conf" = {
    text = ''
      providers tpm
      provider-tpm-library /run/current-system/sw/lib/libtpm2_pkcs11.so
    '';
  };
```

Install your new `nix` config, restart the `gpg-agent` and then check whether you can see the TPM "card":

``` shell
$ gpg --card-status

gpg: WARNING: server 'scdaemon' is older than us (0.11.0 < 2.4.9)
gpg: Note: Outdated servers may lack important security fixes.
gpg: Note: Use the command "gpgconf --kill all" to restart them.
Application ID ...: <snip>
Application type .: OpenPGP
Version ..........: 11.50
Manufacturer .....: ?
Serial number ....: 06E5165C
Signature PIN ....: forced
Key attributes ...: rsa48 rsa48 rsa48

Please try command "openpgp" if the listing does not look correct
```
(this output is severely abridged). If you are seeing something like `gpg: selecting card failed: No such device` and/or `gpg: OpenPGP card not available: No such device`, make sure your `$GNUPGHOME/.gnupg/gnupg-pkcs11-scd.conf` is correctly formatted and has the right filename.


### Import the key in keyring
You'll need to run `gpg --expert --full-generate-key` to make the key show up in your keyring. The serial is the same as the **Application ID** in `gpg --card-status`.
``` shell
$ gpg --expert --full-generate-key

    Your selection? 14
    Serial number of the card: <snip>
    Available keys:
    (1) <snip>
    Your selection? 1

    Possible actions for this RSA key:
    Current allowed actions:

    (Q) Finished

    Your selection? Q
    Please specify how long the key should be valid.
            0 = key does not expire
        <n>  = key expires in n days
        <n>w = key expires in n weeks
        <n>m = key expires in n months
        <n>y = key expires in n years
    Key is valid for? (0) 0
    Key does not expire at all
    Is this correct? (y/N) y

    GnuPG needs to construct a user ID to identify your key.

    Real name: Franta Bartik
    Email address: fb@franta.us
    Comment: TPM
    You selected this USER-ID:
        "Franta Bartik (TPM) <fb@franta.us>"

    Change (N)ame, (C)omment, (E)mail or (O)kay/(Q)uit? O
```

After this is done, you can use your key for anything you'd use a normal GPG key for.

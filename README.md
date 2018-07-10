# winepak Sdk Images
Sdk and Platform runtimes for winepak based applications.

## Introduction
winepak is structured into the runtime and a few key extensions, these are:

 - org.winepak.Sdk
 - org.winepak.Platform
 - org.winepak.Platform.Compat
 - org.winepak.Platform.Gecko
 - org.winepak.Platform.Mono
 - org.winepak.Platform.Extension
 
The core of winepak is the `org.winepak.Sdk` and `org.winepak.Platform`. The Sdk & Platform contains the core modules for winepak, wine and it's dependencies. Each version of the winepak Sdk & Platform contains specific Wine versions, example:

 - `org.winepak.Platform//3.0` -> Wine 3.0
 - `org.winepak.Platform//3.11-staging` -> Wine staging 3.11

### WoW64
The second import part of winepak is `org.winepak.Platform.Compat`, more specifically `org.winepak.Platform.Compat.i386`. This contains the `i386` (32 bit) build of Wine and the runtime but as a `x86_64` (64 bit) extension. Wine 64 bit is essentially useless unless you have 32 bit wine installed, this is also known as WoW64. Microsoft Windows still requires many 32 bit libraries on a 64 bit platform, meaning you need 32 bit Wine. Flatpak doesn't really like mixing arches by default so we need to include a 32 bit platform in the 64 bit platform. Normally with the `org.freedesktop.Platform` this is done per-application, but because Wine is crippled without a multiarch setup winepak includes the WoW64 parts in the Platform by default.

NOTE: We overwrite the default symlink to `/usr/lib/ld-linux.so.2` to `/usr/lib/i386-linux-gnu/lib/ld-linux.so.2`.

### Geck & Mono
Wine ships its own version of a web browser render (Gecko) and Mono. These can change often and tend to be addons, not always needed. We ship Gecko & Mono as extension points to `org.winepak.Platform.Gecko` and `org.winepak.Platform.Mono` respectively. They are installed by default when the Sdk and/or Platform are installed.

### Extensions
Extensions, located on the `org.winepak.Platform.Extension` mount point, are the final major part of winepak. In order to aid installing commonly used packages (`corefonts`, `d3dx9`, `vcrun20**`, etc...) we ship them as extensions. By default they are mounted in the runtime as `/usr/lib/extension/EXTENSION_NAME/`, where `EXTENSION_NAME` is the name of the extension. Most have install scripts in the `bin/` directory, eg. `/usr/lib/extension/EXTENSION_NAME/bin/EXTENSION_NAME-install64`

It is also recommended to add the the extension point in the application manifest so it's guaranteed to download. Example to ensure `d3dx9` is download we add:

    add-extensions:
      org.winepak.Platform.Extension.d3dx9:
        directory: lib/extension/d3dx9
        version: 3.0
        no-autodownload: false

to the application manifest.

### Applications
Finally applications are built using the Sdk and Platform explained above. See the [applications](https://github.com/winepak/applications) repository for a collection of manifests.

## Building
Remember run all `flatpak` commands as a user, root and `sudo` are not needed. In the following examples we are building and installing to the local flatpak install location using `--user`. The local repository is located at `$HOME/.local/share/flatpak`.

### Setup
First you need the `org.freedesktop.Sdk` and `org.freedesktop.Platform` from [`flathub.org`](https://flathub.org) as we base the winepak Sdk & Platform off them.

    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    flatpak install flathub org.freedesktop.Sdk
    flatpak install flathub org.freedesktop.Platform

### New repo
Next lets create a local repository for building and storing our builds. The local repository directory will be `winepak-repo`. In-order to avoid conflicts with the [official winepak repository](https://winepak.org/) lets call it `winepak-local`:

    flatpak --user remote-add --no-gpg-verify --if-not-exists winepak-local winepak-repo

### Building the runtime
Now we need to build the `org.winepak.Sdk` and `org.winepak.Platform`. In the following we will build the winepak Sdk with Wine 3.0. Depending on the application you may only need 64 bit or 32 bit wine, but this is unlikely. So we'll build both `i386` and `x86_64`. If the runtime will be distributed to others it should be signed with a GPG key using `--gpg-sign=${GPG_KEY}`. If applications and/or runtimes are not signed with GPG they can't be installed at the system level and need to be installed at the user level with `--user`. GPG singing shouldn't be necessary as the official winepak repository is the one that will do the distributing, avoid the hassle and keep yours unsigned for testing.

    flatpak-builder --arch=i386 --ccache --force-clean --repo=winepak-repo builds/sdk/3.0-i386 winepak-sdk-images/org.winepak.Sdk.yml
    flatpak-builder --arch=x86_64 --ccache --force-clean --repo=winepak-repo builds/sdk/3.0-x86_64 winepak-sdk-images/org.winepak.Sdk.yml

Building the Sdk and Platform for each arch can take time.

You can also build other versions of the Sdk in the repository by specifying other manifest, example Wine Staging 3.11:

    flatpak-builder --arch=i386 --ccache --force-clean --repo=winepak-repo builds/sdk/3.11-staging-i386 winepak-sdk-images/org.winepak.Sdk-311-staging.yml
    flatpak-builder --arch=x86_64 --ccache --force-clean --repo=winepak-repo builds/sdk/3.11-staging-x86_64 winepak-sdk-images/org.winepak.Sdk-311-staging.yml

### Install the runtime
Now install the `org.winepak.Sdk` and `org.winepak.Platform`. If you don't build with a GPG key then you will be forced to install the runtime with `--user`.

    flatpak -y --user install winepak-local org.winepak.Sdk/i386/3.0 org.winepak.Sdk/x86_64/3.0
    flatpak -y --user install winepak-local org.winepak.Platform/i386/3.0 org.winepak.Platform/x86_64/3.0

If you built the `staging` branch, install those as well:

    flatpak -y --user install winepak-local org.winepak.Sdk/i386/3.11-staging org.winepak.Sdk/x86_64/3.11-staging 
    flatpak -y --user install winepak-local org.winepak.Platform/i386/3.11-staging org.winepak.Platform/x86_64/3.11-staging

### Building WoW64 Support
In order for Wine 64 bit to be fully functional you need to build something called "WoW64" support, which is a Windows method of loading 32 bit libraries and binaries on a 64 bit environment. The current method to achieve this is building a "*.Compat.i386" extension, which is simply the `i386` `*.Platform` bundle as an extension to the `x86_64` Platform.

To build WoW64 support run:

    flatpak build-commit-from --src-ref=runtime/org.winepak.Platform/i386/3.0 winepak-repo runtime/org.winepak.Platform.Compat.i386/x86_64/3.0

You can also build other versions of the `Compat.i386` in the repository by specifying other manifest, example Wine Staging 3.11:

    flatpak build-commit-from --src-ref=runtime/org.winepak.Platform/i386/3.11-staging winepak-repo runtime/org.winepak.Platform.Compat.i386/x86_64/3.11-staging


### Install WoW64
If you built WoW64 support install those as well:

    flatpak -y --user install winepak-local org.winepak.Platform.Compat.i386/x86_64/3.0

If you built the `staging` branch, install those as well:

    flatpak -y --user install winepak-local org.winepak.Platform.Compat.i386/x86_64/3.11-staging

### Building an application
See [winepak/applications](https://github.com/winepak/applications).


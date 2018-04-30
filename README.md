# Winepak Sdk Images
Platform and SDK runtimes for `winepak` based applications.

## Instructions
Remember run all `flatpak` commands as a user, root and `sudo` are not needed.

### Base
First you need the base `org.freedesktop.Sdk` and `org.freedesktop.Platform` from [`flathub.org`](https://flathub.org).

    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    flatpak install flathub org.freedesktop.Sdk
    flatpak install flathub org.freedesktop.Platform

### New repo
Now we link the repo which stores the `winepak` builds, which will be called `winepak`. It will also create a directory called `winepak` in the directory the command was called.

    flatpak --user remote-add --no-gpg-verify --if-not-exists winepak winepak

### Building the runtime
Now we need to build the `org.winepak.*` runtime. Depending on the application you may need 64bit or 3bit wine, current WoW64 support is missing for 64bit wine. If the runtime will be distrusted it should be signed with a GPG key using `--gpg-sign=${GPG_KEY}`. If applications and/or runtimes are not signed with GPG they can't be installed at the system level and need to be installed at the user level with `--user`.

    flatpak-builder --arch=x86_64 --ccache --keep-build-dirs --force-clean --repo=winepak builds org.winepak.Sdk.json

    flatpak-builder --arch=i386 --ccache --keep-build-dirs --force-clean --repo=winepak builds org.winepak.Sdk.json

Building `wine`, `wine-gecko`, `wine-mono`, and `cabextract` can take a while.

It's also recommended you build the `staging` branch of winepak, which contains patches from [wine-staging](https://github.com/wine-staging/wine-staging). A good amount of applications need the patches from `staging` to work.

    flatpak-builder --arch=x86_64 --ccache --keep-build-dirs --force-clean --repo=winepak org.winepak.Sdk-staging.json

    flatpak-builder --arch=i386 --ccache --keep-build-dirs --force-clean --repo=winepak builds org.winepak.Sdk-staging.json

### Install the runtime
Now install the `org.winepak.*` runtime, if you don't build with a GPG key then you will be forced to install the runtime with `--user`.

    flatpak --user install winepak org.winepak.Sdk/x86_64/stable
    flatpak --user install winepak org.winepak.Platform/x86_64/stable

    flatpak --user install winepak org.winepak.Sdk/i386/stable
    flatpak --user install winepak org.winepak.Platform/i386/stable

If you build the `staging` branch add install those as well:

    flatpak --user install winepak org.winepak.Sdk/x86_64/staging
    flatpak --user install winepak org.winepak.Platform/x86_64/staging

    flatpak --user install winepak org.winepak.Sdk/i386/staging
    flatpak --user install winepak org.winepak.Platform/i386/staging

### Building an application
See [winepak/applications](https://github.com/winepak/applications).

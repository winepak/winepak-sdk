# Winepak Sdk Images
Platform and SDK runtimes for `winepak` based applications.

### Structure
Winepak is structure in three main parts; the runtime, the wine extensions, and the applications. The core of Winepak is the `org.winepak.Platform` and `org.winepak.Sdk`. The Platform & SDK contain the core modules for Winepak and a stable version of Wine, eg. Wine 3.0.

In order to use more feature rich versions of Wine users are encouraged to download/build/install Wine extensions. For example to take advantage of Wine staging you would install the `org.winepak.Platform.Wine//x.x-staging` package. So for Wine staging 3.8 you would need `org.winepak.Platform.Wine//3.8-staging`. Each [application](https://github.com/winepak/applications) is free to extend the version of Wine they need, however, they should attempt to use the stable version of wine first. Users can also specify a Wine extension themselves with the hopes that it works.

Finally [applications](https://github.com/winepak/applications) are built using the base Platform and SDK.

## Instructions
Remember run all `flatpak` commands as a user, root and `sudo` are not needed.

### Setup
First you need the base `org.freedesktop.Sdk` and `org.freedesktop.Platform` from [`flathub.org`](https://flathub.org).

    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    flatpak install flathub org.freedesktop.Sdk
    flatpak install flathub org.freedesktop.Platform

### New repo
Now we link the repo which stores the `winepak` builds, which will be called `winepak`. It will also create a directory called `winepak` in the directory the command was called.

    flatpak --user remote-add --no-gpg-verify --if-not-exists winepak winepak-repo

### Building the runtime
Now we need to build the `org.winepak.Platform` and `org.winepak.Sdk`. Depending on the application you may need 64bit or 32bit wine. For WoW64 support, see below. If the runtime will be distrusted it should be signed with a GPG key using `--gpg-sign=${GPG_KEY}`. If applications and/or runtimes are not signed with GPG they can't be installed at the system level and need to be installed at the user level with `--user`.

    flatpak-builder --arch=i386 --ccache --keep-build-dirs --force-clean --repo=winepak-repo builds/winepak-sdk-images-i386 org.winepak.Sdk.yml
    flatpak-builder --arch=x86_64 --ccache --keep-build-dirs --force-clean --repo=winepak-repo builds/winepak-sdk-images-x86_64 org.winepak.Sdk.yml

Building `wine`, `wine-gecko`, `wine-mono`, and `cabextract` can take a while.

It's also recommended you build Wine extensions with the [staging](https://github.com/wine-staging/wine-staging) branch. A good amount of applications need the patches from `staging` to work. Here I'm building `wine 3.8-staging`:

    flatpak-builder --arch=i386 --ccache --keep-build-dirs --force-clean --repo=winepak-repo builds/winepak-sdk-images-wine-3.8-staging-i386 winepak-sdk-images/wine/3.8-staging/org.winepak.Platform.Wine.yml
    flatpak-builder --arch=x86_64 --ccache --keep-build-dirs --force-clean --repo=winepak-repo builds/winepak-sdk-images-wine-3.8-staging-x86_64 winepak-sdk-images/wine/3.8-staging/org.winepak.Platform.Wine.yml

#### Building WoW64 Support
In order for Wine 64bit to be full functional you need to something called "WoW64" support, which is a Windows method of loading 32bit libraries and binaries on a 64bit environment. The current method to achieve this is building a "*.Compat32" extension, which is simply the i386/32bit `*.Platform` bundle as an extension to the x86_64/64bit Platform.

To do this run:

    flatpak build-commit-from --verbose --src-ref=runtime/org.winepak.Sdk/i386/3.0 winepak-repo runtime/org.winepak.Sdk.Compat32/x86_64/3.0
    flatpak build-commit-from --verbose --src-ref=runtime/org.winepak.Platform/i386/3.0 winepak-repo runtime/org.winepak.Platform.Compat32/x86_64/3.0

It's also recommended you build Wine extensions with the [staging](https://github.com/wine-staging/wine-staging) branch. A good amount of applications need the patches from `staging` to work. Here I'm building `wine 3.8-staging`:

    flatpak build-commit-from --verbose --src-ref=runtime/org.winepak.Platform.Wine/i386/3.8-staging winepak-repo runtime/org.winepak.Platform.Wine.Compat32/x86_64/3.8-staging

### Install the runtime
Now install the `org.winepak.*` runtime, if you don't build with a GPG key then you will be forced to install the runtime with `--user`.

    flatpak --user install winepak org.winepak.Sdk/x86_64/3.0
    flatpak --user install winepak org.winepak.Platform/x86_64/3.0

    flatpak --user install winepak org.winepak.Sdk/i386/3.0
    flatpak --user install winepak org.winepak.Platform/i386/3.0

If you built the `staging` branch, install those as well:

    flatpak --user install winepak org.winepak.Platform.Wine/i386/3.8-staging
    flatpak --user install winepak org.winepak.Platform.Wine/x86_64/3.8-staging

#### Install Compat32
If you built Compat32/WoW64 support install those as well:

    flatpak --user install winepak org.winepak.Sdk.Compat32/x86_64/3.0
    flatpak --user install winepak org.winepak.Platform.Compat32/x86_64/3.0
    flatpak --user install winepak org.winepak.Platform.Wine.Compat32/x86_64/3.8-staging

### Building an application
See [winepak/applications](https://github.com/winepak/applications).


## [Extra] Add the new version of Wine-staging automatically using ansible

Just run:

```bash
ansible-playbook ansible_add_latest_staging.yaml
```

It should add the newest version of Wine-staging to ./wine at this repo, ready for a pull request.

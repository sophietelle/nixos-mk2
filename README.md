## sophietelle nixos flake

my experimental playground and my configuration that i daily-drive :)

this config might not fit you and honestly, i don't even care! this is made public just for other people to maybe copy something out of it or fork this config and modify it for their needs.

it doesn't even have a bar and i will be experimenting with quickshell to create something better than just some disgusting strip of information :)

## current setup
- compositor: mangowc (it's very cool!!)
- terminal: alacritty
- configuration: home-manager + stylix
- explorer: thunar (a subject for change)
- editor: zed + vim mode

## how to install
1. fork it
2. `git clone` your fork
3. replace `hardware-configuration.nix` with whatever `nixos-generate-config --show-hardware-config` outputs (or whatever you already have in your config)
4. customize/change things you want at `laptop/` (you probably don't need ida-pro or waydroid)
5. `doas nixos-rebuild switch --flake <path to the folder or just . if you're in the config directory>` and yeah i use doas!

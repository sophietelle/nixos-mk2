{ nixpkgs, inputs, ... }: nixpkgs.lib.nixosSystem {
  specialArgs = { inherit inputs; };
  modules = [
    ./hardware-configuration.nix

    inputs.home-manager.nixosModules.home-manager
    inputs.mango.nixosModules.mango
    inputs.stylix.nixosModules.stylix

    (import ../presets/basics.nix {
      hostName = "laptop";
      stateVersion = "25.11";
      enableFlakes = true;
      allowUnfree = true;
    })

    ({ config, pkgs, lib, ... }: {
      environment.systemPackages = with pkgs; [
        neovim wget curl git gh zip unzip
        python3 bun
      ];

      programs.throne = {
        enable = true;
        tunMode = {
          enable = true;
          setuid = true;
        };
      };

      hardware.ledger.enable = true;
      boot.kernelPackages = pkgs.linuxPackages_zen;

      # ---

      virtualisation.waydroid = {
        enable = true;
        package = pkgs.waydroid-nftables;
      };

      networking.firewall.trustedInterfaces = [ "waydroid0" ];
      boot.kernel.sysctl = { "net.ipv4.ip_forward" = 1; "net.ipv4.conf.all.forwarding" = 1; "net.ipv6.conf.all.forwarding" = 1; };

      # ---

      services.sunshine = {
        enable = true;
        autoStart = true;
      };

      networking.networkmanager.wifi.powersave = false;
      networking.firewall.allowedUDPPorts = [ 67 68 47998 47999 48000 ];
      networking.firewall.allowedTCPPorts = [ 47984 47989 47990 48010 ];
      networking.nftables.enable = true;

      networking.nameservers = [ "1.1.1.1" "9.9.9.9" ];

      # ---

      services.gvfs.enable = true; # Trash folder
      programs.gphoto2.enable = true; # Camera access
      services.tumbler.enable = true; # Thumbnails
      programs.xfconf.enable = true; # Explorer preferences

      # ---

      programs.nix-ld.enable = true;
      stylix.targets.chromium.colors.enable = false;

      virtualisation.podman.enable = true;

      security.rtkit.enable = true;
      boot.kernel.sysctl."kernel.sched_rt_runtime_us" = -1;
    })

    (import ../presets/boot.nix {
      systemdBoot = true;
      usePlymouth = true;
      seamlessBoot = true;
    })
    (import ../presets/networking.nix {
      enable = true;
      disableWaitOnline = true;
    })
    (import ../presets/power-management.nix {
      enablePPD = true;
      enableUpower = true;
      enablePowertopDaemon = true;
      autoSuspendTimeout = 60;
    })
    (import ../presets/display.nix {
      enableBrightnessKeys = true;
    })
    (import ../presets/bluetooth.nix {
      enable = true;
      useOverskride = true;
    })
    (import ../presets/greetd.nix {
      enable = true;
      useRegreet = true;
      seamlessBoot = true;
    })
    (import ../presets/doas.nix {
      replaceSudo = true;
      allowWheel = true;
      keepEnv = true;
      noPass = true;
    })
    (import ../presets/graphics.nix {
      enable = true;
      nvidia = true;
      disablePrime = true;
      enableNvidiaModesetting = false;
    })
    (import ../presets/mangowc.nix {
      enable = true;
    })
    (import ../presets/obs.nix {
      enable = true;
      useCUDA = true;
      useVirtualCamera = true;
      plugins = [ "wlrobs" "obs-vaapi" "obs-vkcapture" ];
    })

    (import ./stylix.nix)

    ({ pkgs, lib, inputs, ... }: {
      nixpkgs.overlays = [
        inputs.ida-pro-overlay.overlays.default
        inputs.helium.overlays.default
      ];

      environment.systemPackages = [
        (pkgs.ida-pro.overrideAttrs (old: {
          installPhase = lib.replaceStrings
          [ "# Link the exported libraries to the output." ]
          [ ''
            pushd $IDADIR
            ${pkgs.python3}/bin/python3 ${./ida/these_bitches_change_up_like_the_season.py} --oneshot
            popd
          '' ]
          old.installPhase;
        }))
      ];
    })

    (import ../presets/home/home.nix {
      username = "sophie";
      displayName = "Sophie";
      stateVersion = "25.11";

      hmImports = [
        inputs.mango.hmModules.mango

        ./mangowc.nix
        ./fastfetch.nix
        ./fuzzel.nix
        ./zed.nix

        ({ inputs, ... }: {
          stylix.targets = {
            zed.enable = false;
            firefox.enable = false;
          };

          programs = {
            home-manager.enable = true;
            alacritty.enable = true;
            # firefox.enable = true;
          };
        })
      ];

      extraPackages = pkgs: with pkgs; [
        android-tools scrcpy
        steam telegram-desktop
        spotify mpv
        thunar thunar-archive-plugin
        helium
        osu-lazer-bin
        imv

        (prismlauncher.override {
          jdks = [ zulu8 zulu21 ];
        })
      ];
    })
  ];
}

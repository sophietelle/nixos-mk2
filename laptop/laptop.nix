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

    ({ pkgs, ... }: {
      environment.systemPackages = with pkgs; [
        neovim wget curl git gh zip unzip
      ];

      boot.kernelPackages = pkgs.linuxPackages_zen;

      virtualisation.waydroid = {
        enable = true;
        package = pkgs.waydroid-nftables;
      };

      hardware.opentabletdriver.enable = true;
      programs.nix-ld.enable = true;
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
      useUWSM = true;
    })

    (import ./stylix.nix)

    ({ pkgs, lib, inputs, ... }: {
      nixpkgs.overlays = [ inputs.ida-pro-overlay.overlays.default ];
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

        (import ../presets/home/alacritty.nix {
          enable = true;
          useDaemon = true;
        })
        (import ../presets/home/swaybg.nix { wallpaper = ../wallpapers/v3.png; })
        (import ../presets/home/obs.nix {
          enable = true;
          useCUDA = true;
          plugins = [ "wlrobs" "obs-vaapi" "obs-vkcapture" ];
        })

        ({ inputs, ... }: {
          stylix.targets = {
            zed.enable = false;
            firefox.enable = false;
          };

          programs = {
            home-manager.enable = true;
            firefox.enable = true;
          };

          programs.zed-editor.package = inputs.nixpkgs-master.legacyPackages.x86_64-linux.zed-editor;
        })
      ];

      extraPackages = pkgs: with pkgs; [
        android-tools scrcpy
        steam telegram-desktop
        bun python3
        spotify mpv
        thunar thunar-archive-plugin

        (prismlauncher.override {
          jdks = [ zulu8 zulu21 ];
        })
      ];
    })
  ];
}

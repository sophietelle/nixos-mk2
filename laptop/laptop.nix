{ nixpkgs, inputs, ... }:

nixpkgs.lib.nixosSystem {
  specialArgs = { inherit inputs; };
  modules = [
    ./hardware-configuration.nix

    inputs.home-manager.nixosModules.home-manager
    inputs.mango.nixosModules.mango
    inputs.stylix.nixosModules.stylix

    ./stylix.nix

    {
      nixpkgs.overlays = [
        inputs.nix-cachyos-kernel.overlays.pinned
        inputs.ida-pro-overlay.overlays.default
        inputs.helium.overlays.default
      ];
    }

    ({ config, pkgs, lib, ... }: {
      # - Hello, world!

      networking.hostName = "fa506icb";
      system.stateVersion = "26.05";

      # - Nix settings

      nix.settings.experimental-features = [ "nix-command" "flakes" ];
      nixpkgs.config.allowUnfree = true;
      programs.nix-ld.enable = true;

      environment.systemPackages = with pkgs; [
        neovim wget curl git gh zip unzip
        python3 bun
        mangohud

        # Bluetooth GUI manager
        bluejay
      ];

      # - Boot process

      boot = {
        loader = {
          systemd-boot.enable = true;
          efi.canTouchEfiVariables = true;

          timeout = 0;
        };

        plymouth = {
          enable = true;
          theme = "bgrt";
        };

        kernelParams = [ "8250.nr_uarts=0" "rd.systemd.show_status=auto" "quiet" "fbcon=vc:2-6" ];
        kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest-lto-x86_64-v3;
      };

      # - Fuck sudo on god

      security = {
        sudo.enable = false;
        doas = {
          enable = true;
          extraRules = [
            {
               groups = [ "wheel" ];
               keepEnv = true;
            }
          ];
        };
      };

      # - Greeter

      services = {
        greetd = {
          enable = true;
          greeterManagesPlymouth = true;
        };

        displayManager.regreet.enable = true;
      };

      # - Networking & VPNs

      networking.networkmanager.enable = true;

      boot.kernel.sysctl = {
        "net.core.default_qdisc" = "cake";

        # Also required for Waydroid!
        "net.ipv4.ip_forward" = 1;
        "net.ipv4.conf.all.forwarding" = 1;
        "net.ipv6.conf.all.forwarding" = 1;
      };

      programs.throne = {
        enable = true;
        tunMode = {
          enable = true;
          setuid = true;
        };
      };

      services.tailscale = {
        enable = true;
        useRoutingFeatures = "both";
      };
      
      networking.nftables.enable = true;

      # - Faster boot times

      systemd.network.wait-online.enable = false;
      systemd.services.NetworkManager-wait-online.enable = false;
      boot.initrd.systemd.network.wait-online.enable = false;
      systemd.units."dev-tpm0.device".wantedBy = lib.mkForce [];
      systemd.units."waydroid-container.service".wantedBy = lib.mkForce [];

      # - Virtualization

      virtualisation.podman.enable = true;

      # virtualisation.waydroid = {
      #   enable = true;
      #   package = pkgs.waydroid-nftables;
      # };

      # - Hardware

      services = {
        asusd.enable = true; # fans go whoosh
        usbmuxd.enable = true;
        illum.enable = true;

        upower.enable = true;
        power-profiles-daemon.enable = true;
      };

      hardware = {
        ledger.enable = true;
        opentabletdriver.enable = true;
        bluetooth = {
          enable = true;
          powerOnBoot = true;
        };
      };

      # - Graphics

      hardware = {
        graphics = {
          enable = true;
          enable32Bit = true;
        };

        nvidia = {
          modesetting.enable = true;
          powerManagement.enable = true;
          open = true;
        };
      };

      services.xserver.videoDrivers = [ "nvidia" ];

      environment.sessionVariables.WLR_DRM_DEVICES = "/dev/dri/card2";

      # - GUI

      programs.mango.enable = true;

      # - Remote access

      services.sunshine = {
        enable = true;
        autoStart = true;
        capSysAdmin = true;
        openFirewall = true;
      };

      services.openssh = {
        enable = true;
        openFirewall = true;
      };

      networking.firewall.allowedUDPPorts = [ config.services.tailscale.port 27015 ];
      networking.firewall.allowedTCPPorts = [ 53317 27015 ];

      # - OBS

      programs.obs-studio = {
        enable = true;
        plugins = with pkgs.obs-studio-plugins; [ wlrobs obs-vaapi obs-vkcapture ];
        package = ( pkgs.obs-studio.override { cudaSupport = true; } );
      };

      # - Explorer (Thunar)

      services.gvfs.enable = true; # Trash folder
      programs.gphoto2.enable = true; # Camera access
      services.tumbler.enable = true; # Thumbnails
      programs.xfconf.enable = true; # Explorer preferences

      # - Finally, my user & home

      programs.steam = {
        enable = true;
        extraCompatPackages = with pkgs; [
          proton-ge-bin
        ];
      };

      users.users.sophie = {
        isNormalUser = true;
        description = "Sophie";
        extraGroups = [ "networkmanager" "wheel" "audio" ];
      };

      home-manager = {
        useGlobalPkgs = true;
        extraSpecialArgs = { inherit inputs; };

        users.sophie = { pkgs, ... }: {
          home.stateVersion = "26.05";

          imports = [
            inputs.mango.hmModules.mango
            ./mangowc.nix
            ./zed.nix

            ({ inputs, ... }: {
              stylix.targets = {
                zed.enable = false;
                firefox.enable = false;
              };

              programs = {
                home-manager.enable = true;
                alacritty.enable = true;

                fastfetch = {
                  enable = true;
                  settings = import ./fastfetch.nix;
                };

                fuzzel = {
                  enable = true;
                  settings = (import ./fuzzel.nix) { inherit lib; };
                };
              };

              home.packages = with pkgs; [
                android-tools scrcpy
                telegram-desktop
                spotify mpv
                thunar thunar-archive-plugin
                helium
                osu-lazer-bin
                imv

                (pkgs.ida-pro.overrideAttrs (old: {
                  installPhase = lib.replaceStrings
                  [ "# Link the exported libraries to the output." ]
                  [ ''
                    # https://i.ibb.co/pjSkNK1p/image.png
                    pushd $IDADIR
                    ${pkgs.python3}/bin/python3 ${./ida/these_bitches_change_up_like_the_season.py} --oneshot
                    popd
                  '' ]
                  old.installPhase;
                }))

                (prismlauncher.override {
                  jdks = [ zulu8 zulu21 ];
                })
              ];
            })
          ];
        };
      };
    })
  ];
}

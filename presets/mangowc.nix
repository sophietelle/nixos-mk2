{
  enable ? false,
  useUWSM ? false,
}: { config, inputs, pkgs, lib, ... }: let
  pkg = inputs.mango.packages.${pkgs.stdenv.hostPlatform.system}.mango;
in {
  config = lib.mkIf enable {
    environment.systemPackages = [ pkg ];

    programs.uwsm = lib.mkIf useUWSM {
      enable = lib.mkDefault true;
      waylandCompositors = {
        mangowc = {
          prettyName = "MangoWC";
          comment = "MangoWC compositor managed by UWSM";
          binPath = lib.getExe pkg;
        };
      };
    };

    xdg.portal = {
      enable = lib.mkDefault true;

      config = {
        mango = {
          default = [
            "gtk"
          ];
          # except those
          "org.freedesktop.impl.portal.Secret" = ["gnome-keyring"];
          "org.freedesktop.impl.portal.ScreenCast" = ["wlr"];
          "org.freedesktop.impl.portal.ScreenShot" = ["wlr"];

          # wlr does not have this interface
          "org.freedesktop.impl.portal.Inhibit" = [];
        };
      };

      extraPortals = with pkgs; [
        xdg-desktop-portal-wlr
        xdg-desktop-portal-gtk
      ];

      wlr.enable = lib.mkDefault true;

      configPackages = [pkg];
    };

    security.polkit.enable = lib.mkDefault true;
    programs.xwayland.enable = lib.mkDefault true;
  };
}

{
  wallpaper,
  mode ? "fill",
}: { pkgs, lib, ... }: {
  home.packages = [ pkgs.swaybg ];

  systemd.user.services.swaybg = {
    Unit = {
      Description = "Wallpaper tool for Wayland compositors";
      After = [ "graphical-session.target" ];
    };

    Service = {
      ExecStart = lib.getExe pkgs.swaybg + " --image ${toString wallpaper} --mode ${mode}";
      Restart = "on-failure";
    };

    Install.WantedBy = [ "graphical-session.target" ];
  };
}

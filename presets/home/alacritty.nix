{
  enable ? false,
  useDaemon ? false,
}: { pkgs, lib, ... }: {
  programs.alacritty.enable = enable;

  systemd.user.services.alacritty-daemon = lib.mkIf useDaemon {
    Unit = {
      Description = "Alacritty daemon";
      Documentation = "https://alacritty.org/config-alacritty.html";
      After = [ "graphical-session.target" ];
    };

    Service = {
      ExecStart = lib.getExe pkgs.alacritty + " --daemon";
      Restart = "on-failure";
    };

    Install.WantedBy = [ "graphical-session.target" ];
  };
}

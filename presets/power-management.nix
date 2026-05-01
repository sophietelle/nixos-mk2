{
  enablePPD ? false,
  enableUpower ? false,
  enablePowertopDaemon ? false,
  autoSuspendTimeout ? 5,
}: { lib, ... }: {
  services.power-profiles-daemon.enable = lib.mkIf enablePPD true;

  services.upower = lib.mkIf enableUpower {
    enable = true;
  };

  powerManagement = lib.mkIf enablePowertopDaemon {
    enable = true;
    powertop.enable = true;
  };

  boot.kernelParams = [ "usbcore.autosuspend=${toString autoSuspendTimeout}" ]; # Default value is 5-ish i think?
}

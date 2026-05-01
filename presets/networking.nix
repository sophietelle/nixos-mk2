{
  enable ? false,
  useDHCP ? false,
  disableWaitOnline ? false,
}: { lib, ... }: {
  networking.networkmanager.enable = lib.mkIf enable true;
  networking.useDHCP = lib.mkIf useDHCP true;

  systemd.services.NetworkManager-wait-online.enable = lib.mkIf disableWaitOnline true;
}

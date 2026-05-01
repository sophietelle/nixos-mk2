{
  stateVersion,
  hostName,
  enableFlakes ? false,
  allowUnfree ? false,
}: { lib, ... }: {
  system.stateVersion = stateVersion;
  networking.hostName = hostName;

  nix.settings.experimental-features = lib.mkIf enableFlakes [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = lib.mkIf allowUnfree true;
}

{
  replaceSudo ? false,
  allowWheel ? false,
  keepEnv ? false,
  noPass ? false
}: { lib, ... }: {
  security.doas.enable = lib.mkIf replaceSudo true;
  security.sudo.enable = lib.mkIf replaceSudo false;
  security.doas.extraRules = [{
    groups = lib.mkIf allowWheel ["wheel"];
    # Optional, retains environment variables while running commands
    # e.g. retains your NIX_PATH when applying your config
    keepEnv = lib.mkIf keepEnv true;
    noPass = lib.mkIf noPass true;  # Optional, only require password verification a single time
  }];
}

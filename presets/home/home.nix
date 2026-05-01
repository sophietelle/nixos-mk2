{
  username,
  displayName,
  stateVersion,
  extraGroups ? [ "networkmanager" "wheel" "audio" ],
  useGlobalPkgs ? true,
  backupFileExtension ? "nix.original",
  hmImports ? [ ],
  extraPackages ? (pkgs: [ ]),
}: { inputs, ... }:

{
  home-manager = {
    inherit useGlobalPkgs backupFileExtension;
    extraSpecialArgs = { inherit inputs; };
  };

  users.users.${username} = {
    isNormalUser = true;
    description = displayName;
    inherit extraGroups;
  };

  home-manager.users.${username} = { pkgs, ... }: {
    home.stateVersion = stateVersion;
    imports = hmImports;
    home.packages = extraPackages pkgs;
  };
}

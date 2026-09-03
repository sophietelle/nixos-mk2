{ lib, ... }: {
  main = {
    prompt = "\"\"";

    horizontal-pad = 5;
    vertical-pad = 5;
    inner-pad = 10;
    lines = 8;
    line-height = 14;

    font = lib.mkForce "serif:size=8";
  };

  colors = {
    border = lib.mkForce "ffffffff";
  };

  border = {
    radius = 0;
  };
}

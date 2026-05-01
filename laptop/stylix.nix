({ pkgs, config, ... }: {
  config.stylix = {
    enable = true;

    targets.plymouth.enable = false;

    base16Scheme = {
      base00 = "18191B";
      base01 = "252629";
      base02 = "3E4147";
      base03 = "6E747B";
      base04 = "898E94";
      base05 = "E0E1E4";
      base06 = "FFFFFF";
      base07 = "FFFFFF";
      base08 = "EB4056";
      base09 = "EBC88D";
      base0A = "FAD075";
      base0B = "82D2CE";
      base0C = "2CCCE6";
      base0D = "4B8DEC";
      base0E = "AF9CFF";
      base0F = "E394DC";
    };

    opacity.terminal = 0.6;
    opacity.popups = 0.6;

    cursor = {
      name = "Posy_Cursor";
      package = pkgs.posy-cursors;
      size = 20;
    };

    fonts = {
      monospace = {
        package = pkgs.iosevka;
        name = "Iosevka";
      };
      sansSerif = {
        package = pkgs.liberation_ttf;
        name = "Liberation Serif";
      };
      serif = config.stylix.fonts.sansSerif;
      emoji = {
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };
      sizes = {
        applications = 12;
        desktop = 12;
        popups = 12;
        terminal = 12;
      };
    };

    polarity = "dark";
  };
})

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.program.pacdef;

  pacdefPackage = pkgs.callPackage ./pacdef-derivation.nix { };

  enabledProfilesFiltered = filterAttrs (profileName: packageList:
    packageList != [ ]
    && !(lib.elem profileName cfg.settings.disabled_backends)) cfg.profiles;

  linuxDistros = [ "arch" "debian" "fedora" "void" ];
  enabledLinux = filterAttrs (profileName: _: lib.elem profileName linuxDistros)
    enabledProfilesFiltered;

  renderedProfiles = lib.concatStringsSep "\n\n" (lib.mapAttrsToList
    (profileName: packageList:
      ''
        [${profileName}]
      '' + lib.concatStringsSep "\n" packageList) enabledProfilesFiltered);

  renderedGlobalConfig = ''
    aur_helper = "${cfg.settings.aur_helper}"
    aur_rm_args = [ ${
      concatStringsSep " " (map (arg: ''"${arg}"'') cfg.settings.aur_rm_args)
    } ]
    warn_not_symlinks = ${
      if cfg.settings.warn_not_symlinks then "true" else "false"
    }
    flatpak_systemwide = ${
      if cfg.settings.flatpak_systemwide then "true" else "false"
    }
    pip_binary = "${cfg.settings.pip_binary}"
  '';

in {
  options.program.pacdef = {
    enable = mkEnableOption "Enable pacdef configuration";

    profiles = mkOption {
      type = types.attrsOf (types.listOf types.str);
      default = { };
      description = "Profile definitions for pacdef (like package groups)";
    };

    settings = mkOption {
      type = types.attrs;
      default = {
        aur_helper = "paru";
        aur_rm_args = [ ];
        disabled_backends = [ ];
        warn_not_symlinks = true;
        flatpak_systemwide = true;
        pip_binary = "pip";
      };
      description =
        "Global pacdef settings. Use 'disabled_backends' to exclude backends even if their profile is defined.";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ pacdefPackage ];

    home.file.".config/pacdef/groups/nix".text = renderedProfiles;
    home.file.".config/pacdef/pacdef.toml".text = renderedGlobalConfig;

    home.activation.syncPacdef = lib.hm.dag.entryAfter ["writeBoundary"] ''
        export PATH="/usr/bin:$PATH"
        run ${lib.getExe' pacdefPackage "pacdef"} package clean --noconfirm
        run ${lib.getExe' pacdefPackage "pacdef"} package sync --noconfirm
      '';
  };
}

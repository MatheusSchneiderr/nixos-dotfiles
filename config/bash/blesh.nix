{ config, ... }:
let
  # Stylix has no ble.sh target, so config.lib.stylix.colors is read directly
  # here -- this is what follows stylix.base16Scheme on every rebuild instead
  # of hardcoding hex.
  c = config.lib.stylix.colors.withHashtag;
in
{
  xdg.configFile."blesh/themes/theme.sh".text = ''
    # fg=${c.base09} (varname/array) and fg=${c.base0E} (glob) are brand
    # accent colors outside the main palette, deliberately fixed regardless of
    # theme (same orange starship.toml uses for language-version icons).
    ble-face syntax_command=fg=${c.base0D}
    ble-face syntax_quoted=fg=${c.base0B}
    ble-face syntax_quotation=fg=${c.base0B},bold
    ble-face syntax_escape=fg=${c.base0F}
    ble-face syntax_expr=fg=${c.base0D}
    ble-face syntax_error=bg=${c.base08},fg=${c.base05}
    ble-face syntax_varname=fg=${c.base09}
    ble-face syntax_param_expansion=fg=${c.base0F}
    ble-face syntax_history_expansion=bg=${c.base01},fg=${c.base05}
    ble-face syntax_function_name=fg=${c.base0C},bold
    ble-face syntax_comment=fg=${c.base03}
    ble-face syntax_glob=fg=${c.base0E},bold
    ble-face syntax_brace=fg=${c.base0C},bold
    ble-face syntax_tilde=fg=${c.base0D},bold
    ble-face syntax_document=fg=${c.base0C}
    ble-face syntax_document_begin=fg=${c.base0C},bold
    ble-face command_builtin_dot=fg=${c.base08},bold
    ble-face command_builtin=fg=${c.base08}
    ble-face command_alias=fg=${c.base0C}
    ble-face command_function=fg=${c.base0C}
    ble-face command_file=fg=${c.base0B}
    ble-face command_keyword=fg=${c.base0D}
    ble-face command_jobs=fg=${c.base08},bold
    ble-face command_directory=fg=${c.base0D},underline
    ble-face filename_directory=underline,fg=${c.base0D}
    ble-face filename_link=underline,fg=${c.base0C}
    ble-face varname_array=fg=${c.base09},bold
    ble-face argument_option=fg=${c.base0C}
  '';
}

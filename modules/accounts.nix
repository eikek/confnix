{pkgs, config, ...}:
let
  accounts =
    let
      result = builtins.tryEval (import <accounts>);
    in
      if result.success then result.value
      else builtins.throw ''Please specify a accounts.nix file that
       contains the accounts that are setup here. You can generate the
       file using the pass2accounts.sh script. '' ;
in
with pkgs.lib;
{

  options = {
    accounts = mkOption {
      type = types.attrsOf (types.attrsOf types.str);
      default = {};
      example = { account1 = { username = "johndoe"; password = "x123"; }; };
    };
  };

  config.accounts = accounts;

}

{
  lib,
}:
let
  capitalizeFirstLetter =
    s:
    if s == "" || s == null then
      ""
    else
      (lib.toUpper (builtins.substring 0 1 s)) + (builtins.substring 1 (-1) s);

  toPascalCase =
    s:
    let
      parts = builtins.split "-" s;
      capitalizedParts = map capitalizeFirstLetter parts;
    in
    builtins.concatStringsSep "" capitalizedParts;

  boolToString = b: if b then "true" else "false";

  nullOrEmpty = v: if v == null then "" else toString v;

  recursiveTransform =
    attrs:
    if builtins.isAttrs attrs then
      lib.mapAttrs' (
        name: value:
        let
          newName =
            if name == "allowSubtitleExtraction" then "AllowSubtitleExtraction" else toPascalCase name;
        in
        if builtins.isAttrs value && !(value ? "tag") then
          {
            name = newName;
            value = recursiveTransform value;
          }
        else if builtins.isList value then
          {
            name = newName;
            value = map (item: recursiveTransform item) value;
          }
        else
          {
            name = newName;
            inherit value;
          }
      ) attrs
    else if builtins.isList attrs then
      map (item: recursiveTransform item) attrs
    else
      attrs;
in
{
  inherit
    capitalizeFirstLetter
    toPascalCase
    boolToString
    nullOrEmpty
    recursiveTransform
    ;
}

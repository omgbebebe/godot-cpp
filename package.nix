{ lib
, stdenv
, scons
, withPlatform ? "linux"
, withTarget ? "template_release"
, withPrecision ? "single"
}:

let
  mkSconsFlagsFromAttrSet = lib.mapAttrsToList (k: v:
    if builtins.isString v
    then "${k}=${v}"
    else "${k}=${builtins.toJSON v}");
in
stdenv.mkDerivation {
  name = "godot-cpp";
  src = lib.sourceByRegex ./. [
    "^src.*"
    "gdextension.*"
    "gen.*"
    "include.*"
    "misc.*"
    "test.*"
    "tools.*"
    "binding_generator.py"
    "CMakeLists.txt"
    "SConstruct"
    "SConstruct.gdextension"
    "SConstruct.gdextension.example"
  ];

  nativeBuildInputs = [ scons ];
  enableParallelBuilding = true;
  BUILD_NAME = "nix-flake";

  sconsFlags = mkSconsFlagsFromAttrSet {
    platform = withPlatform;
    target = withTarget;
    precision = withPrecision;
  };

  outputs = [ "out" ];

  installPhase = ''
    mkdir -p "$out"
    cp -av gen $out/
    cp -av include $out/
    cp -av gdextension $out/
    cp -av bin $out/
    cp SConstruct.gdextension $out/SConstruct
    cp SConstruct.gdextension.example $out/
  '';

  meta = with lib; {
    homepage = "https://github.com/godotengine/godot-cpp";
    description = "C++ bindings for the Godot script API";
    license = licenses.mit;
    platforms = [ "i686-linux" "x86_64-linux" "aarch64-linux" ];
    maintainers = with maintainers; [ omgbebebe ];
  };
}

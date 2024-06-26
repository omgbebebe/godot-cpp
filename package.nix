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
    "pc.in"
  ];

  nativeBuildInputs = [ scons ];
  enableParallelBuilding = true;
  BUILD_NAME = "nix-flake";

  sconsFlags = mkSconsFlagsFromAttrSet {
    platform = withPlatform;
    target = withTarget;
    precision = withPrecision;
  };

  validatePkgConfig = true;

  outputs = [ "out" "dev" ];

  postBuild = ''
    export target="${withTarget}"
    substituteAllInPlace pc.in
  '';

  installPhase = ''
    mkdir -p $out $dev $lib
    cp -av gen $dev/
    cp -av include $dev/
    cp -av gdextension $dev/
    cp -av bin/* $dev/
    cp SConstruct.gdextension $out/SConstruct
    cp SConstruct.gdextension.example $out/

    mkdir -p $dev/lib/pkgconfig
    cp pc.in $dev/lib/pkgconfig/libgodot-cpp.pc
  '';

  meta = with lib; {
    homepage = "https://github.com/godotengine/godot-cpp";
    description = "C++ bindings for the Godot script API";
    license = licenses.mit;
    platforms = [ "i686-linux" "x86_64-linux" "aarch64-linux" ];
    pkgConfigModules = [ "libgodot-cpp" ];
    maintainers = with maintainers; [ omgbebebe ];
  };
}

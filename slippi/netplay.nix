{
  stdenvNoCC,
  appimageTools,
  fetchurl,
  makeDesktopItem,
  copyDesktopItems
}:
stdenvNoCC.mkDerivation rec {
  pname = "slippi-netplay";
  version = "3.4.1";

  src = fetchurl {
    url = "https://github.com/project-slippi/Ishiiruka/releases/download/v${version}/Slippi_Online-x86_64.AppImage";
    hash = "sha256-Ns0yhnb2H0wDj+vUtjSgujpVV8GjKrKSf+OoaCuXIKA=";
  };
  dontUnpack = true;

  contents = appimageTools.extract { inherit pname version src; };

  src-wrapped = appimageTools.wrapType2 rec {
    inherit pname version src;
    extraPkgs = pkgs: with pkgs; [curl zlib mpg123];
  };

  desktopItems = [
    (makeDesktopItem {
      name = "slippi-netplay";
      exec = "slippi-netplay";
      icon = "slippi-netplay";
      desktopName = "Slippi netplay";
      comment = "The way to play Slippi Online and watch replays";
      type = "Application";
      categories = ["Game"];
      keywords = ["slippi" "melee" "rollback"];
    })
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/share"
    cp -r "${contents}/usr/share/icons" "$out/share"

    mkdir -p "$out/bin"
    cp -r "${src-wrapped}/bin" "$out"
    
    runHook postInstall
  '';

  nativeBuildInputs = [copyDesktopItems];
}

{
  stdenvNoCC,
  appimageTools,
  fetchurl,
  makeDesktopItem,
  copyDesktopItems
}:
stdenvNoCC.mkDerivation rec {
  pname = "slippi-netplay";
  version = "3.4.6";

  src = fetchurl {
    url = "https://github.com/project-slippi/Ishiiruka/releases/download/v${version}/Slippi_Online-x86_64.AppImage";
    hash = "sha256-+BNH02czcrOgaRbNdBLHf6rGoVD3HWCpcjUfpW7VJSE=";
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
      desktopName = "Slippi Netplay";
      comment = "The way to play Slippi Online and watch replays";
      type = "Application";
      categories = ["Game"];
      keywords = ["slippi" "melee" "rollback"];
    })
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/share/icons/hicolor/48x48/apps"
    cp "${contents}/usr/share/icons/hicolor/48x48/apps/dolphin-emu.png" "$out/share/icons/hicolor/48x48/apps/slippi-netplay.png"

    mkdir -p "$out/bin"
    cp -r "${src-wrapped}/bin" "$out"
    
    runHook postInstall
  '';

  nativeBuildInputs = [copyDesktopItems];
}

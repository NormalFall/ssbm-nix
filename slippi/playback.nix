{
  stdenvNoCC,
  appimageTools,
  fetchzip,
  makeDesktopItem,
  copyDesktopItems
}:
stdenvNoCC.mkDerivation rec {
  pname = "slippi-playback";
  version = "3.4.6";

  src = fetchzip {
    url = "https://github.com/project-slippi/Ishiiruka-Playback/releases/download/v${version}/playback-${version}-Linux.zip";
    hash = "sha256-bHbsdUs1pm7f/NSUn6f4s3LEL1Wbobq0h0TcQ0dCvbw=";

    stripRoot=false;
  };

  appimage = "${src}/Slippi_Playback-x86_64.AppImage";

  contents = appimageTools.extract { inherit pname version; src = appimage; };

  appimage-wrapped = appimageTools.wrapType2 rec {
    inherit pname version;
    src = appimage;
    extraPkgs = pkgs: with pkgs; [curl zlib mpg123];
  };

  desktopItems = [
    (makeDesktopItem {
      name = "slippi-playback";
      exec = "slippi-playback";
      icon = "slippi-playback";
      desktopName = "Slippi Playback";
      comment = "The way to play Slippi Online and watch replays";
      type = "Application";
      categories = ["Game"];
      keywords = ["slippi" "melee" "rollback"];
    })
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/share/icons/hicolor/48x48/apps"
    cp "${contents}/usr/share/icons/hicolor/48x48/apps/dolphin-emu.png" "$out/share/icons/hicolor/48x48/apps/slippi-playback.png"

    mkdir -p "$out/bin"
    cp -r "${appimage-wrapped}/bin" "$out"
    
    runHook postInstall
  '';

  nativeBuildInputs = [copyDesktopItems];
}

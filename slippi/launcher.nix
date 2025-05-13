{
  stdenvNoCC,
  appimageTools,
  fetchurl,
  makeDesktopItem,
  copyDesktopItems,
  slippi-netplay,
  slippi-playback
}:
stdenvNoCC.mkDerivation rec {
  pname = "slippi-launcher";
  version = "2.11.10";

  src = fetchurl {
    url = "https://github.com/project-slippi/slippi-launcher/releases/download/v${version}/Slippi-Launcher-${version}-x86_64.AppImage";
    hash = "sha256-OrWd0jVqe6CzNbVRNlm2alt2NZ8uBYeHiASaB74ouW4=";
  };
  dontUnpack = true;

  contents = appimageTools.extract { inherit pname version src; };

  src-wrapped = appimageTools.wrapType2 rec { inherit pname version src; };

  desktopItems = [
    (makeDesktopItem {
      name = "slippi-launcher";
      exec = "slippi-launcher";
      icon = "slippi-launcher";
      desktopName = "Slippi Launcher";
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
    cp -r "${src-wrapped}/bin/slippi-launcher" "$out/.slippi-launcher"

    cat > $out/bin/slippi-launcher <<EOF
    #!/bin/sh
    mkdir -p ~/.config/Slippi\ Launcher/netplay/
    mkdir -p ~/.config/Slippi\ Launcher/playback/
    echo ~

    # Awful wrapper to make the launcher run the right binaries
    ln -sf ${slippi-netplay}/bin/slippi-netplay ~/.config/Slippi\ Launcher/netplay/Slippi_Online-x86_64.AppImage
    ln -sf ${slippi-playback}/bin/slippi-playback ~/.config/Slippi\ Launcher/playback/Slippi_Playback-x86_64.AppImage

    exec $out/.slippi-launcher "\$@"
    EOF
    chmod +x $out/bin/slippi-launcher
    
    runHook postInstall
  '';

  nativeBuildInputs = [copyDesktopItems];
}

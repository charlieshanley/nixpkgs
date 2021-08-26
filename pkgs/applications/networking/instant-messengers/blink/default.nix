{ lib, python37Packages, libvncserver, xorg, makeDesktopItem
, mkDerivationWith, fetchFromGitHub, callPackage }:
let
  # using Python 3.7 because python3-application requires older than 3.8
  python37Packages' = python37Packages.override {
    overrides = self: super: {
      # because a test for pyroma segfaults under Python 3.7: https://github.com/NixOS/nixpkgs/issues/136901
      pyroma = super.pyroma.overridePythonAttrs (old: rec { doCheck = false; });
    };
  };
  callPackage' = p: callPackage p (python37Packages' // ag-deps);
  ag-deps = {
    application = callPackage' ./python3-application.nix;
    ag-gnutls = callPackage' ./python3-gnutls.nix;
    eventlib = callPackage' ./python3-eventlib.nix;
    msrplib = callPackage' ./python3-msrplib.nix;
    otr = callPackage' ./python3-otr.nix;
    sipsimple = callPackage' ./python3-sipsimple.nix;
    xcaplib = callPackage' ./python3-xcaplib.nix;
  };
in with python37Packages'; mkDerivationWith buildPythonApplication rec {

  pname = "blink";
  version = "5.1.1";

  src = fetchFromGitHub {
    owner = "AGProjects";
    repo = "blink-qt";
    rev = "${version}";
    sha256 = "sha256-fZtMBBaDjnCK/P4LzFcClt8qhOihIwAHi2tY1Da/7VA=";
  };

  propagatedBuildInputs = with ag-deps; [
    pyqt5_with_qtwebkit
    application
    eventlib
    sipsimple
    google-api-python-client
  ];

  nativeBuildInputs = [
    cython
  ];

  buildInputs = [
    libvncserver
    xorg.libxcb
  ];

  doCheck = false;
  pythonImportsCheck = [ "blink" ];

  dontWrapQtApps = true;

  preFixup = ''
    wrapQtApp "$out/bin/blink"
  '';

  postInstall = ''
    ln -s "${desktopItem}/share/applications" "$out/share/applications"

    mkdir -p "$out/share/pixmaps"
    cp "$out"/share/blink/icons/blink.* "$out/share/pixmaps"
  '';

  desktopItem = makeDesktopItem {
    name = "Blink";
    desktopName = "Blink";
    genericName = "SIP client";
    comment = meta.description;
    extraDesktopEntries = { X-GNOME-FullName = "Blink SIP client"; };
    exec = "blink";
    icon = "blink";
    startupNotify = false;
    terminal = false;
    categories = "Qt;Network;Telephony";
  };

  meta = with lib; {
    homepage = "http://icanblink.com/";
    description = "Fully featured, easy to use SIP client with a Qt based UI";
    longDescription = ''
      Blink is a fully featured SIP client written in Python and built on top of
      SIP SIMPLE client SDK with a Qt based user interface. Blink provides real
      time applications based on SIP and related protocols for Audio, Video,
      Instant Messaging, File Transfers, Desktop Sharing and Presence.
    '';
    platforms = platforms.linux;
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ pSub chanley ];
    mainProgram = "blink";
  };
}

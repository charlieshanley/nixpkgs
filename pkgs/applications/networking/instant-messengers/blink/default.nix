{ lib, python3, libvncserver, xorg, makeDesktopItem
, mkDerivationWith, fetchdarcs, callPackage }:
let
  callPackage' = p: callPackage p (python3.pkgs // ag-deps);
  ag-deps = {
    application = callPackage' ./python3-application.nix;
    ag-gnutls = callPackage' ./python3-gnutls.nix;
    eventlib = callPackage' ./python3-eventlib.nix;
    msrplib = callPackage' ./python3-msrplib.nix;
    otr = callPackage' ./python3-otr.nix;
    sipsimple = callPackage' ./python3-sipsimple.nix;
    xcaplib = callPackage' ./python3-xcaplib.nix;
  };
in with python3.pkgs; mkDerivationWith buildPythonApplication rec {

  pname = "blink";
  version = "5.1.6";

  src = fetchdarcs {
    url = "http://devel.ag-projects.com/repositories/blink-qt";
    rev = "${version}";
    sha256 = "sha256-3fCirFRrHSUM1/m6fCLcQXjqncTIzh8JMOiTohAmvZU=";
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

  doCheck = false; # there are none, but test discovery dies trying to import a Windows library
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

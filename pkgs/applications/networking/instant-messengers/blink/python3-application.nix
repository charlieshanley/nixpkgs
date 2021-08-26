{ lib, isPy3k, pythonOlder, buildPythonPackage, fetchFromGitHub, zope_interface, twisted, ... }:

buildPythonPackage rec {
  pname = "python3-application";
  version = "3.0.3";

  src = fetchFromGitHub {
    owner = "AGProjects";
    repo = "python3-application";
    rev = "${version}";
    sha256 = "sha256-oscUI/Ag/UXmAi/LN1pPTdyqQe9aAfeQzhKFxaTmW3A=";
  };

  propagatedBuildInputs = [ zope_interface twisted ];

  # time.clock is imported, and is deprecated in 3.8
  disabled = !(isPy3k && pythonOlder "3.8");

  pythonImportsCheck = [ "application" ];

  meta = with lib; {
    description = "A collection of modules that are useful when building python applications";
    homepage = "https://github.com/AGProjects/python3-application";
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [ chanley ];
    longDescription = ''
      This package is a collection of modules that are useful when building python applications. Their purpose is to eliminate the need to divert resources into implementing the small tasks that every application needs to do in order to run successfully and focus instead on the application logic itself.
      The modules that the application package provides are:
        1. process - UNIX process and signal management.
        2. python - python utility classes and functions.
        3. configuration - a simple interface to handle configuration files.
        4. log - an extensible system logger for console and syslog.
        5. debug - memory troubleshooting and execution timing.
        6. system - interaction with the underlying operating system.
        7. notification - an application wide notification system.
        8. version - manage version numbers for applications and packages.
    '';
  };
}

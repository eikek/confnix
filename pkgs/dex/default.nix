{ stdenv, fetchurl, pythonPackages }:

let
  dargparse = pythonPackages.buildPythonApplication rec {
    name = "dargparse-0.2.5";
    src = fetchurl {
      url = https://github.com/objectlabs/dargparse/archive/0.2.5.tar.gz;
      sha256 = "096fjicqlydcjycxs17x61nkvf10d5lk7jjmfcv7nhizg35jvd2h";
    };
  };
in
pythonPackages.buildPythonApplication rec {
  name = "dex-${version}";
  version = "0.6.1";

  src = fetchurl {
    url = "https://github.com/mongolab/dex/archive/${version}.tar.gz";
    sha256 = "11lbxjqsa3bgvdhhfpcrwxvvfk593ny83b062p7qpynzk7r3ywq6";
  };

  propagatedBuildInputs = with pythonPackages;[ pymongo pyyaml dargparse ordereddict ];

  meta = with stdenv.lib; {
    homepage = https://github.com/mongolab/dex/releases;
    description = ''
      Index and query analyzer for MongoDB: compares MongoDB log
      files and index entries to make index recommendations
    '';
    license = licenses.mit;
  };
}

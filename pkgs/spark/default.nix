{ fetchurl, lib, spark }:

let
  version = "1.5.0";
  name = "spark-${version}";
in
lib.overrideDerivation spark (attrs: {
  inherit name;

  src = fetchurl {
    url    = "mirror://apache/spark/${name}/${name}-bin-cdh4.tgz";
    sha256 = "02k820sz00501ib19bi0c9hq6q1ckfan5yahbjhqbb1f7gmfjnfb";
  };
})

{ fetchurl }:
let
  sbtVersion = "0.12.4";
in
fetchurl {
  url = "http://repo.typesafe.com/typesafe/ivy-releases/org.scala-sbt/sbt-launch/${sbtVersion}/sbt-launch.jar";
  sha256 = "1067xfdk7g8r3axmbxcbags7fvn60yk4kfrcpqdkm1x2cfk9dvvw";
}

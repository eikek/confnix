{ sbt, jdk17, jdk11, jdk8 }:
{
  sbt8 = sbt.override { jre = jdk8; };
  sbt11 = sbt.override { jre = jdk11; };
  sbt17 = sbt.override { jre = jdk17; };
}

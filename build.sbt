name := "some_examples"

version := "1.0"

scalaVersion := "2.13.0"
// scalaVersion := "2.12.15"
val spinalVersion = "1.6.0"

scalacOptions += "-deprecation"

libraryDependencies ++= Seq(
  // https://mvnrepository.com/artifact/org.scala-lang/scala-library
//   "org.scala-lang" % "scala-library" % "2.13.7",
  "com.github.spinalhdl" %% "spinalhdl-core" % spinalVersion,
  "com.github.spinalhdl" %% "spinalhdl-lib" % spinalVersion,
   compilerPlugin("com.github.spinalhdl" %% "spinalhdl-idsl-plugin" % spinalVersion)
)

fork := true
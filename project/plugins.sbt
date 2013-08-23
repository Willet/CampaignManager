// Comment to get more information during initialization
logLevel := Level.Warn

// The Typesafe repository
resolvers += "Typesafe repository" at "http://repo.typesafe.com/typesafe/releases/"

// Sonatype OSS repository
resolvers += "Sonatype OSS Releases" at "https://oss.sonatype.org/content/repositories/releases"

//resolvers += "Sonatype snapshots" at "http://oss.sonatype.org/content/repositories/snapshots/"

// Add your local publishes
resolvers += Resolver.file("Local repo", file("/Users/ariedler/.ivy2/local"))(Resolver.ivyStylePatterns)

// SBT
resolvers += Resolver.url("sbt-plugin-snapshots", url("http://repo.scala-sbt.org/scalasbt/sbt-plugin-releases/"))(Resolver.ivyStylePatterns)

// Resolvers
resolvers += "CodaHale" at "http://repo.codahale.com"

// Use the Play sbt plugin for Play projects
addSbtPlugin("play" % "sbt-plugin" % "2.1.3")

// For SASS/SCSS support + ZURB foundations
addSbtPlugin("net.litola" % "play-sass" % "0.2.0")

// For WAR compilation
addSbtPlugin("com.github.play2war" % "play2-war-plugin" % "1.0")

// Support for Ember Handlebars
addSbtPlugin("com.ketalo.play.plugins" % "emberjs" % "0.5.1-SNAPSHOT")


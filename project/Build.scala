import sbt._
import Keys._
import play.Project._
import net.litola.SassPlugin
import com.github.play2war.plugin._
import com.ketalo.play.plugins.emberjs.EmberJsKeys

object ApplicationBuild extends Build with EmberJsKeys {

  val appName         = "CampaignManager"
  val appVersion      = "1.0-SNAPSHOT"

  val appDependencies = Seq(
    // Add your project dependencies here,
    jdbc,
    anorm,
    "org.fusesource.scalate" %% "scalate-core" % "1.6.1",
    "mysql" % "mysql-connector-java" % "5.1.18",
    "com.typesafe.slick" %% "slick" % "1.0.1",
    "com.typesafe.play" %% "play-slick" % "0.4.0",
    "com.github.tototoshi" %% "slick-joda-mapper" % "0.3.0"
  )


  val main = play.Project(appName, appVersion, appDependencies)
    .settings(SassPlugin.sassSettings:_*)
    .settings(Play2WarPlugin.play2WarSettings: _*)
    .settings(Play2WarKeys.servletVersion := "3.0")
    .settings(emberJsVersion := "1.0.0-rc.7")

}

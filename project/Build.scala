import sbt._
import Keys._
import play.Project._
import net.litola.SassPlugin
import com.blendlabsinc.sbtelasticbeanstalk.{ ElasticBeanstalk, Deployment }
import com.blendlabsinc.sbtelasticbeanstalk.ElasticBeanstalkKeys._
import com.github.play2war.plugin._
import ca.riedler.play.plugins.handlebars.HandlebarsKeys

object ApplicationBuild extends Build with HandlebarsKeys {

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
    "com.github.tototoshi" %% "slick-joda-mapper" % "0.3.0",
    "securesocial" %% "securesocial" % "2.1.1",
    "io.github.nremond" %% "pbkdf2-scala" % "0.2"
  )


  val main = play.Project(appName, appVersion, appDependencies).settings(
      resolvers += Resolver.url("SQS Ivy", url("http://sqs.github.com/repo"))(Resolver.ivyStylePatterns),
      resolvers += Resolver.url("sbt-plugin-snapshots",
        url("http://repo.scala-sbt.org/scalasbt/sbt-plugin-releases/"))(Resolver.ivyStylePatterns),
      Play2WarKeys.servletVersion := "3.0",
      ebS3BucketName := "???",
      ebDeployments := Seq(
        Deployment(
          appName = "campaign-manager",
          envBaseName = "production",
          templateName = "???",
          cname = "campaign-manager.secondfunnel.com",
          environmentVariables = Map("RUN_ENV" -> "production")
        )
      ),
      ebRegion := "us-west-2"
    )
    .settings(SassPlugin.sassSettings:_*)
    .settings(Play2WarPlugin.play2WarSettings: _*)
    .settings(ElasticBeanstalk.elasticBeanstalkSettings: _*)
    .settings(handlebarsVersion := "1.0.0")

}

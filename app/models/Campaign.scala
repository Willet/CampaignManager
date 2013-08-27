package models

import com.github.tototoshi.slick.JodaSupport._
import org.joda.time.{DateTime, LocalDate}
import java.sql.Timestamp
import play.api.libs.json.Json

import play.api.db._
import play.api.libs.json._
import scala.slick.session.Session
import scala.slick.session.Database
import scala.slick.session.Database.threadLocalSession
import scala.slick.driver.MySQLDriver.simple._
import org.joda.time.{DateTime, LocalDate}
import Database.threadLocalSession

import play.api.libs.functional.syntax._
import play.api.Play.current

case class Campaign(
  id:               Long,
  created:          Option[Timestamp],
  last_modified:    Option[Timestamp],
  name:             Option[String],
  description:      Option[String],
  slug:             Option[String],
  store_id:         Long,
  live:             Boolean,
  theme_id:         Option[Long],
  mobile_id:        Option[Long],
  default_intentrank_id:      Option[Long],
  supports_categories:        Boolean
) {
}


object Campaigns extends Table[Campaign]("pinpoint_campaign") {
  def id               = column[Long]("id", O.PrimaryKey)
  def created          = column[Option[Timestamp]]("created")
  def last_modified    = column[Option[Timestamp]]("last_modified")
  def name             = column[Option[String]]("name")
  def description      = column[Option[String]]("description")
  def slug             = column[Option[String]]("slug")
  def store_id         = column[Long]("store_id")
  def live             = column[Boolean]("live")
  def theme_id         = column[Option[Long]]("theme_id")
  def mobile_id        = column[Option[Long]]("mobile_id")
  def default_intentrank_id      = column[Option[Long]]("default_intentrank_id")
  def supports_categories        = column[Boolean]("supports_categories")

  def * = (id ~ created ~ last_modified ~ name ~ description ~ slug ~ store_id ~ live ~ theme_id ~ mobile_id ~ default_intentrank_id ~
    supports_categories) <> (Campaign, Campaign.unapply _)

  lazy val database = Database.forDataSource(DB.getDataSource())

  implicit val rds: Reads[Timestamp] = (__ \ "time").read[Long].map{ long => new Timestamp(long) }
  implicit val wrs: Writes[Timestamp] = (__ \ "time").write[Long].contramap{ (a: Timestamp) => a.getTime }
  implicit val fmt: Format[Timestamp] = Format(rds, wrs)
  //
  implicit val storeFormat: Format[Campaign] = Json.format[Campaign]


  def all : List[Campaign] = {
    database.withSession {
      Query(Campaigns).list
    }
  }
  def find(id: Long) : Option[Campaign] = {
    database.withSession {
      val query = for {
        s <- Query(Campaigns) if s.id === id
      } yield s
      query.firstOption
    }
  }
}

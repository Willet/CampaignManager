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

case class Store(
  id: Long,
  name: Option[String],
  description: Option[String],
  slug: Option[String],
  public_base_url: Option[String],
  created: Option[Timestamp],
  theme_id: Option[Long],
  mobile_id: Option[Long]
)

object Stores extends Table[Store]("assets_store") {
  def id = column[Long]("id", O.PrimaryKey)
  def name = column[Option[String]]("name")
  def description = column[Option[String]]("description")
  def slug = column[Option[String]]("slug")
  def public_base_url = column[Option[String]]("public_base_url")
  def created = column[Option[Timestamp]]("created")
  def theme_id = column[Option[Long]]("theme_id")
  def mobile_id = column[Option[Long]]("mobile_id")

  def * = (id ~ name ~ description ~ slug ~ public_base_url ~ created ~ theme_id ~ mobile_id) <> (Store, Store.unapply _)

  lazy val database = Database.forDataSource(DB.getDataSource())

  implicit val rds: Reads[Timestamp] = (__ \ "time").read[Long].map{ long => new Timestamp(long) }
  implicit val wrs: Writes[Timestamp] = (__ \ "time").write[Long].contramap{ (a: Timestamp) => a.getTime }
  implicit val fmt: Format[Timestamp] = Format(rds, wrs)
  //
  implicit val storeFormat: Format[Store] = Json.format[Store]

  def all : List[Store] = {
    database.withSession {
      Query(Stores).list
    }
  }
  def find(id: Long) : Option[Store] = {
    database.withSession {
      val query = for {
        s <- Query(Stores) if s.id === id
      } yield s
      query.firstOption
    }
  }
}


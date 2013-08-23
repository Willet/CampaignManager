package models

import play.api.db._
import play.api.libs.json._
import scala.slick.session.Session
import scala.slick.session.Database
import scala.slick.session.Database.threadLocalSession
import scala.slick.driver.MySQLDriver.simple._
import Database.threadLocalSession

import play.api.libs.functional.syntax._
import play.api.Play.current

import securesocial.core._

import authentication._

case class User(
  id: Long,
  username:         String,
  first_name:       String,
  last_name:        String,
  email:            String,
  password:         String,
  is_staff:         Boolean,
  is_superuser:     Boolean
) {
  def socialUser : Option[SocialUser] = {
    // based on format by django auth
    val passwordSalt = password.split('$')(2)
    val passwordHash = password.split('$').last
    val passwordInfo = Option(PasswordInfo("UnsecureHasher", passwordHash, Option(passwordSalt)))
    Option(SocialUser(IdentityId(email, ""), first_name, last_name, first_name + " " + last_name, Option(email),
      None, AuthenticationMethod.UserPassword, None, None, passwordInfo))
  }
}


object Users extends Table[User]("auth_user") {
  def id            = column[Long]("id", O.PrimaryKey)
  def username      = column[String]("username")
  def first_name    = column[String]("first_name")
  def last_name     = column[String]("last_name")
  def email         = column[String]("email")
  def password      = column[String]("password")
  def is_staff      = column[Boolean]("is_staff")
  def is_superuser  = column[Boolean]("is_superuser")

  def * = (id ~ username ~ first_name ~ last_name ~ email ~ password ~ is_staff ~ is_superuser) <> (User, User.unapply _)

  lazy val database = Database.forDataSource(DB.getDataSource())

  implicit val userFormat: Format[User] = Json.format[User]

  def all : List[User] = {
    database.withSession {
      Query(Users).list
    }
  }
  def find(id: Long) : Option[User] = {
    database.withSession {
      val query = for {
        s <- Query(Users) if s.id === id
      } yield s
      query.firstOption
    }
  }
  def findByEmail(email: String) : Option[User] = {
    database.withSession {
      val query = for {
        s <- Query(Users) if s.email === email
      } yield s
      query.firstOption
    }
  }
}

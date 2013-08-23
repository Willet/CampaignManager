package authentication

import models.User
import models.Users
import securesocial.core._
import securesocial.core.providers.utils._
import io.github.nremond.PBKDF2
import play.api.Application

/**
 * A django auth equivalent password hasher,
 * integrates existing login setup
 */
class PBKDF2PasswordHasher(app: Application) extends PasswordHasher {

  def salt:String = "idk..."
  def iterations = 10000

  override def id = "PBKDF2PasswordHasher"

  def hash(plainPassword: String): PasswordInfo = {
    val hashedPassword = PBKDF2.apply(plainPassword, salt, iterations, 16)
    val encodedPassword = new sun.misc.BASE64Encoder().encode(hashedPassword.getBytes())
    PasswordInfo(id, encodedPassword)
  }

  def matches(passwordInfo: PasswordInfo, suppliedPassword: String) : Boolean = {
    val salt = passwordInfo.salt match {
      case Some(x) => x
      case _ => null
    }
    println(salt)
    val suppliedHashedPassword = PBKDF2.apply(suppliedPassword, salt, iterations, 16)
    println(suppliedHashedPassword)
    val encodedPassword = new sun.misc.BASE64Encoder().encode(suppliedHashedPassword.getBytes())
    println(encodedPassword)
    println(passwordInfo.password)
    passwordInfo.password == encodedPassword
  }
}


class UnsecureHasher(app: Application) extends PasswordHasher {

  override def id = "UnsecureHasher"

  def hash(plainPassword: String): PasswordInfo = {
    PasswordInfo(id, plainPassword)
  }

  def matches(passwordInfo: PasswordInfo, suppliedPassword: String) : Boolean = {
    suppliedPassword == "w1llet!"
  }

}


import securesocial.core._
import securesocial.core.providers.Token

class MyUserService(application: Application) extends UserServicePlugin(application) {

  // in-memory tokens
  private var tokens = Map[String, Token]()

  def find(uid: IdentityId) : Option[Identity] = {
    // we are going to ignore the provider, cause we don't currently support oauth etc
    Users.findByEmail(uid.userId) match {
      case None => None
      case Some(x) => x.socialUser
    }
  }

  def findByEmailAndProvider(email: String, providerId: String) : Option[Identity] = {
    // we are going to ignore the provider, cause we don't currently support oauth etc
    Users.findByEmail(email) match {
      case None => None
      case Some(x) => x.socialUser
    }
  }

  def save(user: Identity): Identity = {
    // TODO: might want to save new users
    user
  }

  def findToken(token: String): Option[Token] = {
    tokens.get(token)
  }

  def save(token: Token) = {
    tokens += (token.uuid -> token)
  }

  def deleteToken(uuid: String) = {
    tokens -= uuid
  }

  def deleteTokens() {
    tokens = Map()
  }

  def deleteExpiredTokens() = {
    tokens = tokens.filter(!_._2.isExpired)
  }

}

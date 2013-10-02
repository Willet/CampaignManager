package controllers

import play.api._
import play.api.libs.json._
import play.api.mvc._
import play.api.Play.current
import java.sql.Timestamp

import models.Store
import models.Stores._
import models.{Stores => StoresTable}

import securesocial.core.SecureSocial

object Stores extends Controller with SecureSocial {

  def index = SecuredAction(ajaxCall = true) { implicit request =>
    val stores = StoresTable.all
    Ok(Json.toJson(Map("stores" -> stores))).as(JSON)
  }

  def show(id: Long) = SecuredAction(ajaxCall = true) { implicit request =>
    val store = StoresTable.find(id)
    Ok(Json.toJson(store)).as(JSON)
  }

}

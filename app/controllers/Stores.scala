package controllers

import play.api._
import play.api.libs.json._
import play.api.mvc._
import play.api.Play.current
import java.sql.Timestamp

import models.Store
import models.Stores._
import models.{Stores => StoresTable}

object Stores extends Controller {

  def index = Action {
    val stores = StoresTable.all
    Ok(Json.toJson(Map("stores" -> stores))).as(JSON)
  }

  def show(id: Long) = Action {
    val store = StoresTable.find(id)
    Ok(Json.toJson(store)).as(JSON)
  }

  def add = Action {
    // TODO: implement
    Ok
  }

  def edit(id: Long) = Action {
    // TODO: implement
    Ok(Scalate("stores/new.scaml").render())
  }

  def update(id: Long) = Action {
    // TODO: implement
    Ok
  }

}

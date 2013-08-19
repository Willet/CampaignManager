package controllers

import play.api._
import play.api.mvc._

object Stores extends Controller {

  def index = Action {
    Ok(Scalate("stores/index.scaml").render())
  }

  def show(id: Long) = Action {
    Ok(Scalate("stores/show.scaml").render())
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

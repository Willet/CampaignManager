package controllers

import play.api._
import play.api.mvc._

object Products extends Controller {

  def index = Action {
    //Ok(Scalate("products_index.scaml").render())
    Ok(Scalate("products/index.scaml").render())
  }

  def show(id: Long) = Action {
    Ok(Scalate("products_show.scaml").render())
  }

  def add = Action {
    // TODO: implement
    Ok
  }

  def edit(id: Long) = Action {
    // TODO: implement
    Ok(Scalate("products_new.scaml").render())
  }

  def update(id: Long) = Action {
    // TODO: implement
    Ok
  }

}

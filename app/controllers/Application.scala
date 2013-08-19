package controllers

import play.api._
import play.api.mvc._

object Application extends Controller {

  def root = Action {
    Ok(Scalate("main.scaml").render())
  }

  def index(file: String) = Action {
    Ok(Scalate("main.scaml").render())
  }

}

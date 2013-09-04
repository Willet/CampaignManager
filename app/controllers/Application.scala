package controllers

import play.api._
import play.api.mvc._

object Application extends Controller {

  def root = Action {
    Ok(views.html.main())
  }

  def index(file: String) = Action {
    Ok(views.html.main())
  }

  def notFound(file: String) = Action {
    NotFound("")
  }

}

package controllers

import play.api._
import play.api.mvc._
import play.api.libs.concurrent.Execution.Implicits._
import play.api.libs.json.Json.toJson
import play.api.libs.ws.WS
import play.api.libs.ws.Response

object Products extends Controller {

  val apiHeaders = ("ApiKey","secretword")

  def relayResponse(response: Response) = {
    if (response.status == 200)
      Ok(response.json)
    else
      Status(response.status)(response.body)
  }

  def index(store_id:Long)  = Action {
    val request = WS.url("http://contentgraph-test.elasticbeanstalk.com/graph/store/" + store_id + "/product/live/")
    Async {
      request.withHeaders(apiHeaders)
        .get()
        .map(relayResponse)
    }
  }

  def show(store_id:Long, id: Long) = Action {
    val request = WS.url("http://contentgraph-test.elasticbeanstalk.com/graph/store/" + store_id + "/product/live/" + id)
    Async {
      request.withHeaders(apiHeaders)
        .get()
        .map(relayResponse)
    }
  }

  def update(store_id: Long, id: Long) = Action { implicit request =>
    val cg_request = WS.url("http://contentgraph-test.elasticbeanstalk.com/graph/store/" + store_id + "/product/live/" + id)
    Async {
      cg_request.withHeaders(apiHeaders)
        .put((request.body.asJson getOrElse "").toString)
        .map(relayResponse)
    }
  }

}

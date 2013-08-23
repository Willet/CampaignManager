package controllers

import play.api._
import play.api.mvc._
import play.api.libs.concurrent.Execution.Implicits._
import play.api.libs.json.Json.toJson
import play.api.libs.ws.WS
import play.api.libs.ws.Response

object Campaigns extends Controller {

  def index(store_id:Long)  = Action {
    val request = WS.url("http://contentgraph-test.elasticbeanstalk.com/graph/store/" + store_id + "/campaign/")
    Async {
      request.withHeaders(("ApiKey","secretword")).get()
        .map { response: Response =>
          println(response.body)
          println(response.status)
          if (response.status != 200)
            NotFound
          else
            Ok(response.json)
        }
    }
  }

  def show(store_id:Long, id: Long) = Action {
    val request = WS.url("http://contentgraph-test.elasticbeanstalk.com/graph/store/" + store_id + "/campaign/" + id)
    Async {
      request.withHeaders(("ApiKey","secretword")).get()
        .map { response: Response =>
          if (response.status != 200)
            NotFound("")
          else
            Ok(response.json)
        }
    }
  }

}

package controllers

import play.api._
import play.api.mvc._
import play.api.libs.concurrent.Execution.Implicits._
import play.api.libs.json.Json.toJson
import play.api.libs.ws.WS
import play.api.libs.ws.Response

object Products extends Controller {

  def index(store_id:Long)  = Action {
    val request = WS.url("http://contentgraph-test.elasticbeanstalk.com/graph/store/" + store_id + "/product/live/")
    Async {
      request.withHeaders(("ApiKey","secretword")).get()
        .map { response: Response =>
          if (response.status != 200)
            NotFound
          else
            Ok(response.json)
        }
    }
  }

  def show(store_id:Long, id: Long) = Action {
    val request = WS.url("http://contentgraph-test.elasticbeanstalk.com/graph/store/" + store_id + "/product/live/" + id)
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

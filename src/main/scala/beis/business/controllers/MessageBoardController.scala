/*
 * Copyright (C) 2016  Department for Business, Energy and Industrial Strategy
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

package beis.business.controllers

import javax.inject.Inject

import beis.business.data.MessageBoardOps
import beis.business.models.{ApplicationId, MessageId, UserId}
import org.joda.time.{DateTime, DateTimeZone}
import play.api.libs.json.{JsObject, _}
import play.api.mvc.{Action, Controller}

import scala.concurrent.{ExecutionContext, Future}

class MessageBoardController @Inject()(messages:MessageBoardOps)
                                      (implicit val ec: ExecutionContext) extends Controller with ControllerUtils {
  def byId(id: MessageId) = Action.async { implicit request =>
    messages.byId(id).map(os => Ok(Json.toJson(os)))
  }

  def userMessages = Action.async { implicit request =>
    val userId = request.headers.get("UserId").getOrElse("")
    messages.userMessages(UserId(userId)).map {
      os => ( Ok(Json.toJson(os)))
    }
  }

  def saveMessage() = Action.async(parse.json[JsObject]) { implicit request =>

    messages.createMessage(request.body).map {
      case MessageId(0) => NotFound
      case _ => NoContent
    }
  }

  def delete(id: MessageId) = Action.async { implicit request =>
    messages.delete(id).map(_ => NoContent)
  }
}

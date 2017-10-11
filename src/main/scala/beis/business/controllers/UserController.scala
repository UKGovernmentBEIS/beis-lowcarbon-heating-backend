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

import beis.business.Config
import beis.business.restmodels.User
import beis.business.actions.ApplicationAction
import beis.business.data.{ApplicationOps, UserOps}
import beis.business.models.{ApplicationId, MessageId, SubmittedApplicationRef, UserId}
import beis.business.notifications.NotificationService
import org.joda.time.{DateTime, DateTimeZone}
import play.api.Logger
import play.api.libs.json.{JsError, JsObject, JsSuccess, Json}
import play.api.mvc.{Action, Controller}

import scala.concurrent.{ExecutionContext, Future}
import beis.business.tables.JsonParseException
import cats.data.OptionT

/**
  * Created by venkatamutyala on 27/08/2017.
  */
class UserController @Inject()(users: UserOps,
                               applications: ApplicationOps,
                               notifications: NotificationService)
                              (implicit val ec: ExecutionContext) extends Controller with ControllerUtils {

  def login() = Action.async(parse.json[JsObject]) { implicit request =>
    users.login(request.body).map {
      os => ( Ok(Json.toJson(os)))
    }
  }

  def register() = Action.async(parse.json[JsObject]) { implicit request =>
    users.register(request.body).map {
      os =>( Ok(Json.toJson(os)))
    }
  }

  def forgotPassword() = Action.async(parse.json[JsObject]) { implicit request =>

    val username = (request.body \ "name").validate[String].getOrElse("NA")
    val email = (request.body \ "email").validate[String].getOrElse("NA")

    users.forgotpassword(request.body).map {
          os =>{
            if(os.equals("success.BF001"))
              sendforgotPasswordNotification(username, email)
            Ok(Json.toJson(os))
          }
        }
  }

  def resetPassword() = Action.async(parse.json[JsObject]) { implicit request =>

    users.resetpassword(request.body).map {
      os =>( Ok(Json.toJson(os)))
    }
  }


  private def sendforgotPasswordNotification(username:String, to: String) = {
    import Config.config.beis.{email => emailConfig}
    notifications.notifyApplicantForgotPassword(username, to).recover { case t =>
        Logger.error(s"Failed to send email to $username $to on forgot password link", t)
        None
      }
  }

}

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

package beis.business.tables

import java.util.Base64
import javax.inject.Inject

import beis.business.data.{ApplicationDetails, UserOps}
import beis.business.models._
import beis.business.restmodels.{Application, Login, User}
import beis.business.slicks.modules._
import beis.business.slicks.support.DBBinding
import play.api.data.validation.ValidationError
import play.api.db.slick.DatabaseConfigProvider
import play.api.libs.json._
import beis.business.tables.JsonParseException

import scala.concurrent.{ExecutionContext, Future}

class UserTables @Inject()(val dbConfigProvider: DatabaseConfigProvider)(implicit ec: ExecutionContext)
    extends UserOps
    with UserModule
    with OpportunityModule
    with ApplicationFormModule
    with ApplicationModule
    with DBBinding
    with PgSupport {

  implicit val userIdReads = Json.format[UserId]
  implicit val userFormat = Json.format[User]
  implicit val loginFormat = Json.format[Login]

  import api._

  override implicit def ApplicationFormUserIdMapper: BaseColumnType[UserId] = MappedColumnType.base[UserId, String](_.userId, UserId)

  override def login(jmsg: JsValue): Future[Option[UserRow]] = db.run{
    jmsg.validate[Login] match {
      case JsSuccess(a, _) => {
        userTable.filter(ut => (ut.name === a.name && ut.password === basicAuth(a.password))).result.map {
          os => os.map(u => UserRow(u.id, u.name, u.password, u.email)).headOption
        }
      }
      case JsError(errs) =>
        throw JsonParseException("login", errs)
    }
  }

  override def register(jmsg: JsValue): Future[String]  = db.run {
    jmsg.validate[User] match {
      case JsSuccess(a, _) =>
        (userTable returning userTable.map(_.password)) += UserRow(RegUserId(0), a.name, basicAuth(a.password), a.email)

      case JsError(errs) =>
        throw JsonParseException("register", errs)
    }
  }.recoverWith{
    case ex: Exception =>
    val msg = ex.getMessage
      /** TODO *****
        * We are sending exception as String which is not
        * an elegant solution
        * Need to send a Exception TYPE to frontend
        * instead of a string
        */
      //Future.successful(UniqueKeyException(ex.getMessage))
      Future.successful(msg)
    case ex => Future.failed(ex)
  }

  override def forgotpassword(jmsg: JsValue): Future[String] = db.run{

    val username = (jmsg \ "name").validate[String].getOrElse("NA")
    val email = (jmsg \ "email").validate[String].getOrElse("NA")
        userTable.filter(ut => (ut.name === UserId(username) && ut.email === email)).result.map {
          os => os.map(u => UserRow(u.id, u.name, u.password, u.email)).head.email
        }
  }.recoverWith{
    case ex: Exception =>
      val msg = ex.getMessage
      /** TODO *****
        * We are sending exception as String which is not
        * an elegant solution
        * Need to send a Exception TYPE to frontend
        * instead of a string
        */
      Future.successful(msg)
    case ex => Future.failed(ex)
  }

  def applicantEmailQ(id: Rep[ApplicationId]) =
      (applicationTable joinLeft userTable on (_.userId === _.name)).filter(_._1.id === id)

  val applicantEmailC = Compiled(applicantEmailQ _)

  override def user(applicationId: ApplicationId): Future[Option[User]] = db.run {
      applicantEmailC(applicationId).result
    }.map { ps =>
      val (as, ss) = ps.unzip
      ss.flatten.map(u=> User(u.id.id, u.name, u.password, u.email)).headOption
  }

  def basicAuth(pswd: String) = {
    new String(Base64.getEncoder.encode((pswd).getBytes))
  }

}

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

import javax.inject.Inject

import beis.business.data.{ApplicationDetails, MessageBoardOps}
import beis.business.models._
import beis.business.restmodels.{Application, Message}
import beis.business.slicks.modules._
import beis.business.slicks.support.DBBinding
import com.fasterxml.jackson.core.JsonParseException
import org.joda.time.{DateTime, DateTimeZone}
import play.api.data.validation.ValidationError
import play.api.db.slick.DatabaseConfigProvider
import play.api.libs.json._

import scala.concurrent.{ExecutionContext, Future}

class MessageBoardTables @Inject()(val dbConfigProvider: DatabaseConfigProvider)(implicit ec: ExecutionContext)
  extends MessageBoardModule
    with MessageBoardOps
    with DBBinding
    with PgSupport {


//    implicit val messageRowReads = Json.reads[MessageRow]
//  implicit val messageRowFormat = Json.format[MessageRow]
  implicit val messageIdReads = Json.format[MessageId]
  implicit val appIdReads = Json.format[ApplicationId]
  implicit val userIdReads = Json.format[UserId]
  //implicit val messageReads = Json.reads[Message]
  implicit val messageFormat = Json.format[Message]
  import api._

  override def byId(id: MessageId): Future[Option[MessageRow]] = db.run(messageBoardTable.filter(_.id === id).result).map { os =>
    os.map(m => MessageRow(m.id, m.userId, m.applicationId, m.sectionNumber, m.sentBy, m.sentAt, m.message)).headOption
  }

  override def userMessages(userId: UserId): Future[Set[MessageRow]] = db.run(messageBoardTable.filter(_.userId === userId).result).map { os =>
    os.map(m => {
      val ms: String = m.message.getOrElse("No Message")
      val msg = if(ms.length > 15) ms.substring(0, 15) else ms
      MessageRow(m.id, None, None, None, m.sentBy, m.sentAt, Option(msg + " . . ."))
    }).toSet
  }

  override def updateMessage(id: SubmittedApplicationRef, message: Option[String]): Future[Int] = {
    db.run( messageBoardTable.filter(_.applicationId === id).map(_.message).update(message) )
  }

  override def createMessage(jmsg: JsValue): Future[MessageId] = db.run {
    jmsg.validate[Message] match {
      case JsSuccess(a, _) =>
        (messageBoardTable returning messageBoardTable.map(_.id)) += MessageRow(MessageId(0), Option(a.userId), Option(a.applicationId),
          Option(a.sectionNumber), a.sentBy, DateTime.now(DateTimeZone.UTC), a.message )
        case JsError(errs) => throw JsonParseException("createMessage", errs)
    }
  }


    override def delete(id: MessageId): Future[Unit] = db.run {
    for {
      _ <- messageBoardTable.filter(_.id === id).delete
    } yield ()
  }

  override def deleteAll: Future[Unit] = db.run {
    for {
      _ <- messageBoardTable.delete
    } yield ()
  }

}
case class JsonParseException(method: String, errs: Seq[(JsPath, Seq[ValidationError])]) extends Exception

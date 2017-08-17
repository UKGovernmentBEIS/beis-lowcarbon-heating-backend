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

package beis.business.data

import beis.business.models._
import beis.business.tables.MessageBoardTables
import com.google.inject.ImplementedBy

import scala.concurrent.Future
import play.api.libs.json.{JsObject, JsValue}

@ImplementedBy(classOf[MessageBoardTables])
trait MessageBoardOps {

  def byId(id: MessageId): Future[Option[MessageRow]]
  def userMessages(userId:UserId): Future[Set[MessageRow]]
  def updateMessage(id: ApplicationId, message: Option[String]): Future[Int]
  def createMessage(jmsg: JsValue): Future[MessageId]
  def delete(id: MessageId) : Future[Unit]
  def deleteAll: Future[Unit]
}

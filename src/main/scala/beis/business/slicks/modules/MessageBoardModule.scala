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

package beis.business.slicks.modules

import beis.business.models._
import beis.business.slicks.support.DBBinding
import com.github.tminglei.slickpg.{ExPostgresDriver, PgDateSupportJoda, PgPlayJsonSupport}
import com.wellfactored.slickgen.IdType
import org.joda.time.DateTime
import play.api.libs.json.JsObject

import scala.language.implicitConversions

trait MessageBoardModule extends PlayJsonMappers {
  self: DBBinding with ExPostgresDriver with PgDateSupportJoda with PgPlayJsonSupport =>

  import api._

  implicit def ApplicationIdMapper: BaseColumnType[ApplicationId] = MappedColumnType.base[ApplicationId, Long](_.id, ApplicationId)
  implicit def MessageIdMapper: BaseColumnType[MessageId] = MappedColumnType.base[MessageId, Long](_.id, MessageId)
  implicit def ApplicationFormUserIdMapper: BaseColumnType[UserId] = MappedColumnType.base[UserId, String](_.userId, UserId)

  type MessageBoardQuery = Query[MessageBoardTable, MessageRow, Seq]

  class MessageBoardTable(tag: Tag) extends Table[MessageRow](tag, "messageboard") {
    def id = column[MessageId]("id", O.Length(IdType.length), O.PrimaryKey, O.AutoInc)

    def userId = column[Option[UserId]]("user_id", O.Length(50))

    def applicationId = column[Option[ApplicationId]]("application_id", O.Length(IdType.length))

    def sectionNumber = column[Option[Int]]("section_number")

    def sentBy = column[UserId]("sent_by", O.Length(50))

    def sentAt = column[DateTime]("sent_at_dtime")

    def message = column[Option[String]]("message")

    def * = (id, userId, applicationId, sectionNumber, sentBy, sentAt, message) <> ((MessageRow.apply _).tupled, MessageRow.unapply)
  }

  lazy val messageBoardTable = TableQuery[MessageBoardTable]

}
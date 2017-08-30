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

import scala.language.implicitConversions

trait UserModule extends PlayJsonMappers {
  self: DBBinding with ExPostgresDriver with PgDateSupportJoda with PgPlayJsonSupport =>

  import api._

  //implicit def ApplicationIdMapper: BaseColumnType[ApplicationId] = MappedColumnType.base[ApplicationId, Long](_.id, ApplicationId)
  implicit def RegUserIdMapper: BaseColumnType[RegUserId] = MappedColumnType.base[RegUserId, Long](_.id, RegUserId)
  //implicit def ApplicationFormUserIdMapper: BaseColumnType[UserId] = MappedColumnType.base[UserId, String](_.userId, UserId)

  type UserQuery = Query[UserTable, UserRow, Seq]

  class UserTable(tag: Tag) extends Table[UserRow](tag, "user") {

    def id = column[RegUserId]("id", O.Length(IdType.length), O.PrimaryKey, O.AutoInc)

    def name = column[String]("user_name", O.Length(20))

    def password = column[String]("password", O.Length(20))

    def email = column[String]("email", O.Length(100))

    def * = (id, name, password, email) <> ((UserRow.apply _).tupled, UserRow.unapply)
  }

  lazy val userTable = TableQuery[UserTable]

}
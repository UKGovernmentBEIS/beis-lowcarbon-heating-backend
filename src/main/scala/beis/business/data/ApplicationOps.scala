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

import com.google.inject.ImplementedBy
import org.joda.time.DateTime
import play.api.libs.json.JsObject
import beis.business.models._
import beis.business.restmodels.{Application,User}
import beis.business.tables.ApplicationTables

import scala.concurrent.Future

case class ApplicationDetails(app:ApplicationRow, form:ApplicationFormRow, opp:OpportunityRow)

@ImplementedBy(classOf[ApplicationTables])
trait ApplicationOps {
  def byId(id: ApplicationId): Future[Option[ApplicationRow]]

  def gatherDetails(id: ApplicationId): Future[Option[ApplicationDetails]]

  def delete(id: ApplicationId): Future[Unit]

  def deleteAll: Future[Unit]

  def forForm(applicationFormId: ApplicationFormId, userId: UserId): Future[Option[ApplicationRow]]

  def createForm(applicationFormId: ApplicationFormId, userId: UserId): Future[Option[ApplicationRow]]

  def application(applicationId: ApplicationId): Future[Option[Application]]

  def userApplications(userId: Option[UserId]): Future[Set[Application]]

  /**
    * @return `Some[ApplicationSectionRow]` if the application with the given `id` was found and it had a
    *         section with number `sectionNumber`. If there is no section, or if there is no application with
    *         the given `id` then this returns `None`. If you need to know whether it was the application
    *         or the section that was missing then use `fetchAppWithSection`.
    */
  def fetchSection(id: ApplicationId, sectionNumber: Int): Future[Option[ApplicationSectionRow]]

  /**
    * @return an option of a pair where the first element is the application row and the second element
    *         is an option of the section row. If the application with `id` does not exist then the
    *         whole result will be `None`, and if the application exists but there is no section with
    *         the given `sectionNumber` then the overall result will be `Some`, but the second element of
    *         the pair will be `None`. This way the caller can tell of the select failed because the
    *         application didn't exist, or because the application exists but the section doesn't.
    */
  def fetchAppWithSection(id: ApplicationId, sectionNumber: Int): Future[Option[(ApplicationRow, Option[ApplicationSectionRow])]]

  def fetchSections(id: ApplicationId): Future[Set[ApplicationSectionRow]]

  def saveSection(id: ApplicationId, sectionNumber: Int, answers: JsObject, completedAt: Option[DateTime] = None): Future[Int]

  def saveFileSection(id: ApplicationId, sectionNumber: Int, answers: JsObject, completedAt: Option[DateTime] = None): Future[Int]

  def deleteSection(id: ApplicationId, sectionNumber: Int): Future[Int]

  def clearSectionCompletedDate(id: ApplicationId, sectionNumber: Int): Future[Int]

  def submit(id: ApplicationId) : Future[Option[SubmittedApplicationRef]]

  def updatePersonalReference(id: ApplicationId, reference: Option[String]): Future[Int]

  def updateAppStatus(id: ApplicationId, appStatus: Option[String]): Future[Int]

  def createSimpleForm(applicationFormId: ApplicationFormId, userId: UserId): Future[Option[ApplicationRow]]

  //def user(id: ApplicationId): Future[Option[User]]

}

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

import cats.data.OptionT
import cats.instances.future._
import org.joda.time.DateTime
import play.api.db.slick.DatabaseConfigProvider
import play.api.libs.json.JsObject
import beis.business.controllers.JsonHelpers
import beis.business.data.{ApplicationDetails, ApplicationOps}
import beis.business.models._
import beis.business.restmodels.{Application, ApplicationSection, User}
import beis.business.slicks.modules._
import beis.business.slicks.support.DBBinding

import scala.concurrent.{ExecutionContext, Future}

class ApplicationTables @Inject()(val dbConfigProvider: DatabaseConfigProvider)(implicit ec: ExecutionContext)
  extends ApplicationOps
    with ApplicationModule
    with ApplicationFormModule
    with OpportunityModule
    //with UserModule
    with DBBinding
    with PgSupport {

  import driver.api._

  override def byId(id: ApplicationId): Future[Option[ApplicationRow]] = db.run(applicationTable.filter(_.id === id).result.headOption)

  override def gatherDetails(id: ApplicationId): Future[Option[ApplicationDetails]] = db.run {
    val q = for {
      a <- applicationTable.filter(_.id === id)
      f <- applicationFormTable.filter(_.id === a.applicationFormId)
      o <- opportunityTable.filter(_.id === f.opportunityId)
    } yield (a, f, o)

    q.result.headOption.map(_.map(ApplicationDetails.tupled))
  }

  override def forForm(applicationFormId: ApplicationFormId, userId: UserId): Future[Option[ApplicationRow]] = {
    db.run(applicationWithSectionsForFormC(applicationFormId, userId).result).flatMap {
      case Seq() =>  Future.successful(None)
      case ps =>
        val (as, ss) = ps.unzip
        Future.successful(as.map(a => buildApplicationRow(a, ss.flatten)).headOption)
    }
  }


  override def createForm(applicationFormId: ApplicationFormId, userId: UserId): Future[Option[ApplicationRow]] = {
    val appFormF = db.run(applicationFormTable.filter(_.id === applicationFormId).result.headOption)

    for {
      _ <- OptionT(appFormF)
      app <- OptionT.liftF(create(applicationFormId, userId))
    } yield ApplicationRow(app.id, app.applicationFormId, app.personalReference, app.userId, app.appStatus)
  }.value


  override def application(applicationId: ApplicationId): Future[Option[Application]] = db.run {
    applicationWithSectionsC(applicationId).result
  }.map { ps =>
    val (as, ss) = ps.unzip
    as.map(a => buildApplication(a, ss.flatten)).headOption
  }

  //override def userApplications(userId: UserId): Future[Set[Application]] = db.run(applicationTableC(userId).result).map { os =>
  override def userApplications(userId: Option[UserId]): Future[Set[Application]] = db.run(applicationTable.filter(_.userId ===userId).result).map { os =>
    os.map(a => Application(a.id, a.applicationFormId, a.personalReference, a.userId, a.appStatus, Seq())).toSet
  }

  override def delete(id: ApplicationId): Future[Unit] = db.run {
    for {
      _ <- applicationSectionTable.filter(_.applicationId === id).delete
      _ <- applicationTable.filter(_.id === id).delete
    } yield ()
  }

  override def deleteAll: Future[Unit] = db.run {
    for {
      _ <- applicationSectionTable.delete
      _ <- applicationTable.delete
    } yield ()
  }

//  def applicantEmailQ(id: Rep[ApplicationId]) =
//    (applicationTable joinLeft userTable on (_.userId === _.name)).filter(_._1.id === id)

 // val applicantEmailC = Compiled(applicantEmailQ _)

  def applicationWithSectionsQ(id: Rep[ApplicationId]) =
    (applicationTable joinLeft applicationSectionTable on (_.id === _.applicationId)).filter(_._1.id === id)

  val applicationWithSectionsC = Compiled(applicationWithSectionsQ _)

  def applicationWithSectionsForFormQ(id: Rep[ApplicationFormId], userId: Rep[UserId]) =
    (applicationTable joinLeft applicationSectionTable on (_.id === _.applicationId)).filter(a => (a._1.applicationFormId === id) && (a._1.userId === userId))

  val applicationWithSectionsForFormC = Compiled(applicationWithSectionsForFormQ _)

  private def fetch(applicationFormId: ApplicationFormId, userId: UserId): Future[Option[ApplicationRow]] = {
    db.run(applicationWithSectionsForFormC(applicationFormId, userId).result).flatMap {
      case Seq() =>  Future.successful(None)
      case ps =>
        val (as, ss) = ps.unzip
        Future.successful(as.map(a => buildApplicationRow(a, ss.flatten)).headOption)
    }
  }

  private def buildApplicationRow(app: ApplicationRow, secs: Seq[ApplicationSectionRow]): ApplicationRow = {
    val sectionOverviews: Seq[ApplicationSection] = secs.map { s =>
      ApplicationSection(s.sectionNumber, s.answers, s.completedAt)
    }
    ApplicationRow(app.id, app.applicationFormId, app.personalReference, app.userId, app.appStatus)
  }

  private def create(applicationFormId: ApplicationFormId, userId: UserId): Future[Application] = {
    db.run(applicationWithSectionsForFormC(applicationFormId, userId).result).flatMap {
      case Seq() => createApplicationForForm(applicationFormId, userId).map { id => Application(id, applicationFormId, None, userId, AppStatus("In progress"), Seq()) }
      case ps =>
        val (as, ss) = ps.unzip
        Future.successful(as.map(a => buildApplication(a, ss.flatten)).head)
    }
  }

  private def buildApplication(app: ApplicationRow, secs: Seq[ApplicationSectionRow]): Application = {
    val sectionOverviews: Seq[ApplicationSection] = secs.map { s =>
      ApplicationSection(s.sectionNumber, s.answers, s.completedAt)
    }

    Application(app.id, app.applicationFormId, app.personalReference, app.userId, app.appStatus, sectionOverviews)
  }


  //THIS ADDS A ROW IN APPLICATION TABLE
  private def createApplicationForForm(applicationFormId: ApplicationFormId, userId: UserId): Future[ApplicationId] = db.run {
    (applicationTable returning applicationTable.map(_.id)) += ApplicationRow(ApplicationId(0), applicationFormId, None, userId, AppStatus("In progress"))
  }

  override def fetchAppWithSection(id: ApplicationId, sectionNumber: Int): Future[Option[(ApplicationRow, Option[ApplicationSectionRow])]] = db.run {
    appWithSectionC(id, sectionNumber).result.headOption
  }

  override def fetchSection(id: ApplicationId, sectionNumber: Int): Future[Option[ApplicationSectionRow]] = db.run {
    appSectionC(id, sectionNumber).result.headOption
  }

  override def fetchSections(id: ApplicationId): Future[Set[ApplicationSectionRow]] = db.run(appSectionsC(id).result).map(_.toSet)

  override def saveSection(id: ApplicationId, sectionNumber: Int, answers: JsObject, completedAt: Option[DateTime] = None): Future[Int] = {
    fetchAppWithSection(id, sectionNumber).flatMap {
      case Some((app, Some(section))) => if (areDifferent(section.answers, answers) || completedAt.isDefined) {
        db.run(appSectionC(id, sectionNumber).update(section.copy(answers = answers, completedAt = completedAt)))
      } else {
        Future.successful(1)
      }
      case Some((app, None)) =>
        db.run(applicationSectionTable += ApplicationSectionRow(ApplicationSectionId(0), id, sectionNumber, answers, completedAt))
      case None => Future.successful(0)
    }
  }

  override def saveFileSection(id: ApplicationId, sectionNumber: Int, answers: JsObject, completedAt: Option[DateTime] = None): Future[Int] = {
    fetchAppWithSection(id, sectionNumber).flatMap {
      case Some((app, Some(section))) => if (areDifferent(section.answers, answers) || completedAt.isDefined) {
        db.run(appSectionC(id, sectionNumber).update(section.copy(answers = answers, completedAt = completedAt)))
      } else {
        Future.successful(1)
      }
      case Some((app, None)) => {
        db.run(applicationSectionTable += ApplicationSectionRow(ApplicationSectionId(0), id, sectionNumber, answers, completedAt))
      }
      case None => Future.successful(0)
    }
  }

  override def clearSectionCompletedDate(id: ApplicationId, sectionNumber: Int): Future[Int] = {
    fetchAppWithSection(id, sectionNumber).flatMap {
      case Some((app, Some(section))) => db.run(appSectionC(id, sectionNumber).update(section.copy(completedAt = None)))
      case _ => Future.successful(0)
    }
  }

  def areDifferent(obj1: JsObject, obj2: JsObject): Boolean = {
    val flat1 = JsonHelpers.flatten("", obj1).filter { case (_, v) => v.trim != "" }
    val flat2 = JsonHelpers.flatten("", obj2).filter { case (_, v) => v.trim != "" }
    flat1 != flat2
  }

  def joinedAppWithSection(id: Rep[ApplicationId], sectionNumber: Rep[Int]) = for {
    as <- applicationTable joinLeft applicationSectionTable on ((a, s) => a.id === s.applicationId && s.sectionNumber === sectionNumber) if as._1.id === id
  } yield as

  def appWithSectionQ(id: Rep[ApplicationId], sectionNumber: Rep[Int]) = joinedAppWithSection(id, sectionNumber)

  lazy val appWithSectionC = Compiled(appWithSectionQ _)

  override def deleteSection(id: ApplicationId, sectionNumber: Int): Future[Int] = db.run {
    appSectionC(id, sectionNumber).delete
  }

  override def submit(id: ApplicationId): Future[Option[SubmittedApplicationRef]] = {
    // dummy method
    play.api.Logger.info(s"Dummy application submission for $id")
    db.run( applicationTable.filter(_.id === id).map(_.appStatus).update(AppStatus("Submitted")))
    byId(id).flatMap(appRow => Future.successful(appRow.map(_.id)))
  }

  def appSectionQ(id: Rep[ApplicationId], sectionNumber: Rep[Int]) = applicationSectionTable.filter(a => a.applicationId === id && a.sectionNumber === sectionNumber)

  def appQ(id: Rep[ApplicationId]) = applicationTable.filter(_.id === id)

  lazy val appC = Compiled(appQ _)

  lazy val appSectionC = Compiled(appSectionQ _)

  def appSectionsQ(id: Rep[ApplicationId]) = applicationSectionTable.filter(_.applicationId === id)

  lazy val appSectionsC = Compiled(appSectionsQ _)

  //def applicationsQ(userId: Rep[UserId]) = applicationTable.filter(_.userId === userId)

  //val applicationTableC = Compiled(applicationsQ _)

  override def updatePersonalReference(id: SubmittedApplicationRef, reference: Option[String]): Future[Int] = {
    db.run( applicationTable.filter(_.id === id).map(_.personalReference).update(reference) )
  }

  override def updateAppStatus(id: SubmittedApplicationRef, appStatus: Option[String]): Future[Int] = {
    db.run( applicationTable.filter(_.id === id).map(_.appStatus).update(AppStatus(appStatus.get)) )
  }

  override def createSimpleForm(applicationFormId: ApplicationFormId, userId: UserId): Future[Option[ApplicationRow]] = {
    val appFormF = db.run(applicationFormTable.filter(_.id === applicationFormId).result.headOption)

    for {
      _ <- OptionT(appFormF)
      app <- OptionT.liftF(createSimple(applicationFormId, userId))
    } yield ApplicationRow(app.id, app.applicationFormId, app.personalReference, app.userId, app.appStatus)
  }.value

  private def createSimple(applicationFormId: ApplicationFormId, userId: UserId): Future[Application] = {
      createApplicationForForm(applicationFormId, userId).map { id => Application(id, applicationFormId, None, userId, AppStatus("In progress"), Seq()) }
  }

//  override def user(applicationId: ApplicationId): Future[Option[User]] = db.run {
//    applicantEmailC(applicationId).result
//  }.map { ps =>
//    val (as, ss) = ps.unzip
//    ss.flatten.map(u=> User(u.id.id, u.name, u.password, u.email)).headOption
//
//  }
}


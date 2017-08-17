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

package beis.business.notifications

import java.util
import javax.inject.{Inject, Named}

import beis.business.Config
import beis.business.controllers.JsonHelpers
import cats.data.OptionT
import cats.instances.future._
import org.joda.time.DateTime
import play.api.libs.mailer.MailerClient
import beis.business.data.{ApplicationOps, OpportunityOps}
import beis.business.models.{ApplicationFormRow, ApplicationId, OpportunityId, OpportunityRow}
import beis.business.tables.JsonParseException
import play.api.libs.json.{JsArray, JsDefined, JsError, JsNumber, JsObject, JsString, JsSuccess, JsValue}

import scala.util.{Failure, Success}
import play.api.libs.json.Json
import scala.concurrent.{ExecutionContext, Future}
import uk.gov.service.notify.{NotificationClientException, SendEmailResponse}
import uk.gov.service.notify.{NotificationClient, SendEmailResponse}

import scala.collection.JavaConversions._


class NotificationServiceGovNotifyImpl @Inject()(sender: MailerClient, applications: ApplicationOps, opportunities: OpportunityOps)
                                                (implicit ec: ExecutionContext) extends NotificationService {

  import Notifications._
  import play.api.libs.mailer._

  override def notifyApplicant(applicationId: ApplicationId, submittedAt: DateTime, from: String, to: String, mgrEmail: String): Future[Option[NotificationId]] = {

    def emailbodyParams(appForm: ApplicationFormRow, opportunity: OpportunityRow,
                        applicationTitle: String,
                        reviewDeadline: DateTime) = {
      val applicantLastName = "Eric"
      val applicantFirstName = "Eric"

      Map[String, String](
        "companyInfo" -> "Company",
        "companieshouseidentifier" -> "65675757",
        "applicantTitle" -> "Mr",
        "applicantFirstName" -> applicantFirstName,
        "applicantLastName" -> applicantLastName,
        "applicationTitle" -> applicationTitle,
        "opportunityRefNumber" -> opportunity.id.toString(),
        "opportunityTitle" -> opportunity.title.toString(),
        "submissionLink" -> "http://todo.link",
        "portFolioMgrFirstName" -> "Portfolio",
        "portFolioMgrLastName" -> "Peter",
        "portFolioMgrEmail" -> mgrEmail.toString(),
        "portFolioMgrPhone" -> "01896 000000",
        "reviewDeadline" -> reviewDeadline.toString()
      )
    }

    import Config.config.beis.{email => emailConfig}

    val applicantTemplateid = emailConfig.notifyservice.applicanttemplateid
    val workflowtesttemplateid = emailConfig.notifyservice.workflowtesttemplateid

    val apiKey = emailConfig.notifyservice.apikey
    val client = new NotificationClient(apiKey)

    (for {
      appSection <- OptionT(applications.fetchSection(applicationId, beis.business.models.APP_TITLE_SECTION_NO))
      details <-  OptionT( applications.gatherDetails(applicationId) )

    } yield {
      val title = appSection.answers.value.get("title").map(_.toString).getOrElse("")
      val reviewDeadline = submittedAt.plusDays(beis.business.models.APP_REVIEW_TIME_DAYS)
      val params =  emailbodyParams(details.form, details.opp, title, reviewDeadline)
      EmailId(client.sendEmail(applicantTemplateid, to /*"farhan.ghalib@beis.gov.uk"*/ , params, "").getNotificationId.toString)
    }).value
  }

  def sendEmail(to: String, templateid: String, params: Map[String, String])(implicit ec: ExecutionContext): Future[SendEmailResponse] = {
    import Config.config.beis.{email => emailConfig}
    val apiKey = emailConfig.notifyservice.apikey
    val client = new NotificationClient(apiKey)
    val paramsJava = new util.HashMap[String, String]()
    paramsJava.putAll(params)
    Future.successful(client.sendEmail(templateid, to, params, ""))
  }

  override def notifyManagerAppSubmitted(applicationId: ApplicationId, from: String, to: String): Future[Option[EmailId]] = {

    def emailbodyParams(appForm: ApplicationFormRow, opportunity: OpportunityRow) = {

      val emailSubject = "Application submitted"
      val portFolioMgrName = "Joe Blogg"
      val applicantLastName = "Eric"
      val applicantFirstName = "Eric"

      val m: util.Map[String, String] = Map[String, String](
        "portFolioMgrName" -> portFolioMgrName,
        "applicantTitle" -> "Mr",
        "applicantFirstName" -> applicantFirstName,
        "applicantLastName" -> applicantLastName,
        "applicantOrg" -> "Association of Medical Research Charities",
        "applicationRefNum" -> appForm.id.id.toString,
        "opportunityRefNumber" -> appForm.opportunityId.toString,
        "opportunityTitle" -> opportunity.title.toString(),
        "submissionLink" -> "http://todo.link"
      )
      val params = new util.HashMap[String, String]()
      params.putAll(m)
      params
    }
    import Config.config.beis.{email => emailConfig}

    val portfoliomanagertemplateid = emailConfig.notifyservice.manageroppsubmittedtemplateid
    val workflowtesttemplateid = emailConfig.notifyservice.workflowtesttemplateid

    val apiKey = emailConfig.notifyservice.apikey
    val client = new NotificationClient(apiKey)
    applications.gatherDetails(applicationId).map {
      _.map(d => EmailId(client.sendEmail(portfoliomanagertemplateid, to , emailbodyParams(d.form, d.opp), "").getNotificationId.toString))
    }
  }

  override def notifyManagerAppPublished(id: OpportunityId, from: String, to: String): Future[Option[NotificationId]] = {

    def emailbodyParams(opportunity: OpportunityRow) = {

      val emailSubject = "Opportunity published"
      val portFolioMgrName = "Joe blogg"

      val m: util.Map[String, String] = Map[String, String](
        "portFolioMgrName" -> portFolioMgrName,
        "opportunityRefNumber" -> opportunity.id.toString,
        "opportunityTitle" -> opportunity.title.toString()
      )
      val params = new util.HashMap[String, String]()
      params.putAll(m)
      params
    }

    import Config.config.beis.{email => emailConfig}

    val portfoliomanagertemplateid = emailConfig.notifyservice.manageropppublishedtemplateid
    val workflowtesttemplateid = emailConfig.notifyservice.workflowtesttemplateid

    val apiKey = emailConfig.notifyservice.apikey
    val client = new NotificationClient(apiKey)

    opportunities.byId(id).map {
      _.map(opp => EmailId(client.sendEmail(portfoliomanagertemplateid, to, emailbodyParams(opp), "").getNotificationId.toString))
    }
  }

  override def notifyManagerSimpleFormSubmitted(applicationId: ApplicationId, from: String, to: String) : Future[Option[EmailId]] = {

    def emailbodyParams(mp : Map[String, String]) = {

      val m: util.Map[String, String] = Map[String, String](

        "simpleFormTitle" -> "Sickness Absence Application",
        "managerName" -> mp.get("sicknessAbsence.managername").getOrElse("NA"),
        "managerEmail" -> mp.get("sicknessAbsence.manageremail").getOrElse("NA"),
        "applicantFullName" -> mp.get("sicknessAbsence.employeename").getOrElse("NA"),
        "applicantDept" -> mp.get("sicknessAbsence.department").getOrElse("NA"),
        "natureOfIllness" -> mp.get("sicknessAbsence.natureofillness").getOrElse("NA"),
        "attachmentLink" -> mp.get("sicknessAbsence.itemNumber").head
      )

      val params = new util.HashMap[String, String]()
      params.putAll(m)
      params
    }

    def managerEmail(mp : Map[String, String]) = {
      //mp.get("sicknessAbsence.manageremail").toString
      "venomeuk@hotmail.co.uk"
    }

    import Config.config.beis.{email => emailConfig}
    import Config.config.beis.{forms => BEISServerConfig}

    val managersicknessabsencetemplateid = emailConfig.notifyservice.managersicknessabsencetemplateid

    val frontendUrl = BEISServerConfig.frontendUrl

    val apiKey = emailConfig.notifyservice.apikey
    val client = new NotificationClient(apiKey)

    var mp: Map[String,String] = Map("na" -> "na")

    val answersAsMap1 = applications.fetchSections(applicationId).flatMap {
      s=>s.map{ a=> {
        val secId = JsonHelpers.flatten("", a.answers).contains("items") match {
          case true => Map("sectionId" -> a.sectionNumber.toString)
          case false => Map()
        }
        mp = mp ++ JsonHelpers.flatten("",  a.answers) ++ secId} }
        Future.successful(mp)
    }

    answersAsMap1.onComplete {
        case Success(mp) => {

            val n = mp.get("items").getOrElse("")

            val itemnum = Json.parse(n.substring(n.indexOf("{"), n.length-1)) \ "itemNumber"  match{
              case JsDefined(JsNumber(itnum)) => itnum.toString()
              case _ => "0"
            }

            val filetype = Json.parse(n.substring(n.indexOf("{"), n.length-1)) \ "supportingDocuments"  match{
              case JsDefined(JsString(fl)) => fl.substring(fl.indexOf("."), fl.length)
              case _ => "na"
            }
            val sec = applicationId.id.toString + "/section"
            val varMap = mp ++ Map("sicknessAbsence.itemNumber" ->
              s"$frontendUrl/application/$sec/${mp.get("sectionId").getOrElse("0")}/downloadfile/$itemnum$filetype")

            EmailId(client.sendEmail(managersicknessabsencetemplateid, managerEmail(varMap), emailbodyParams(varMap), "").getNotificationId.toString)
        }
        case Failure(t) => Map()
    }

    Future.successful(Option(EmailId("0")))
  }

}

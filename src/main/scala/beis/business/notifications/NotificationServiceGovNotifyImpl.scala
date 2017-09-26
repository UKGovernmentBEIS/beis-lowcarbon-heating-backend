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
import beis.business.data.{ApplicationOps, OpportunityOps, UserOps}
import beis.business.models.{ApplicationFormRow, ApplicationId, OpportunityId, OpportunityRow}
import beis.business.tables.JsonParseException
import play.api.libs.json.{JsArray, JsDefined, JsError, JsNumber, JsObject, JsString, JsSuccess, JsValue}

import scala.util.{Failure, Random, Success}
import play.api.libs.json.Json

import scala.concurrent.{ExecutionContext, Future}
import uk.gov.service.notify.{NotificationClientException, SendEmailResponse}
import uk.gov.service.notify.{NotificationClient, SendEmailResponse}

import scala.collection.JavaConversions._


class NotificationServiceGovNotifyImpl @Inject()(sender: MailerClient, applications: ApplicationOps, opportunities: OpportunityOps, users: UserOps)
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
      EmailId(client.sendEmail(applicantTemplateid, /*to*/ "farhan.ghalib@beis.gov.uk" , params, "").getNotificationId.toString)
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
      _.map(d => EmailId(client.sendEmail(portfoliomanagertemplateid, /*to*/ "venomeuk@hotmail.co.uk" , emailbodyParams(d.form, d.opp), "").getNotificationId.toString))
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

  override def notifyApplicantFormSubmitted(applicationId: ApplicationId, userName: String, from: String, to: String) : Future[Option[EmailId]] = {

    val appReference = applicationId.id + 1000
    def emailbodyParams() = {
      val m: util.Map[String, String] = Map[String, String](
        "applicationId" -> appReference.toString(),
        "applicantName" -> userName
      )
      val params = new util.HashMap[String, String]()
      params.putAll(m)
      params
    }
    import Config.config.beis.{email => emailConfig}
    import Config.config.beis.{forms => BEISServerConfig}

    val applicantlowcarbonheatingtemplateid = emailConfig.notifyservice.applicantlowcarbonheatingtemplateid
    val frontendUrl = BEISServerConfig.frontendUrl
    val apiKey = emailConfig.notifyservice.apikey
    val client = new NotificationClient(apiKey)
    var mp: Map[String,String] = Map("na" -> "na")

    val id = EmailId(client.sendEmail(applicantlowcarbonheatingtemplateid, to, emailbodyParams(), "").getNotificationId.toString)
    Future.successful(Option(id))
  }

  override  def notifyApplicantForgotPassword(username: String, to: String): Future[Option[NotificationId]]= {

    import Config.config.beis.{email => emailConfig}
    import Config.config.beis.{forms => BEISServerConfig}

    val applicantforgotpasswordtemplateid = emailConfig.notifyservice.applicantforgotpasswordtemplateid

    def emailbodyParams = {
      val emailSubject = "Forgot password"
      val frontendUrl = BEISServerConfig.frontendUrl
      val resetIdentifier = Random.nextInt().abs
      val resetLink = s"$frontendUrl/resetpassword/$resetIdentifier"
      val m: util.Map[String, String] = Map[String, String](
        "username" -> username,
        "resetlink" -> resetLink
      )

      users.saveResetPasswordRefNo(resetIdentifier)

      val params = new util.HashMap[String, String]()
      params.putAll(m)
      params
    }

    val apiKey = emailConfig.notifyservice.apikey
    val client = new NotificationClient(apiKey)

    val id = EmailId(client.sendEmail(applicantforgotpasswordtemplateid, to, emailbodyParams, "").getNotificationId.toString)
    //val id = EmailId("test")

    Future.successful(Option(id))
  }

}

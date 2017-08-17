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

import javax.inject.Inject

import cats.data.OptionT
import cats.instances.future._
import com.google.inject.ImplementedBy
import org.joda.time.DateTime
import play.api.libs.mailer.MailerClient
import beis.business.data.{ApplicationOps, OpportunityOps}
import beis.business.models.{ApplicationFormRow, ApplicationId, OpportunityId, OpportunityRow}

import scala.concurrent.{ExecutionContext, Future}

object Notifications {
  trait NotificationId {
    def id: String
  }

  case class EmailId(id: String) extends NotificationId
}

trait NotificationService {

  import Notifications._

  def notifyApplicant(applicationFormId: ApplicationId, submittedAt: DateTime, from: String, to: String, mgrEmail: String): Future[Option[NotificationId]]
  def notifyManagerAppSubmitted(applicationFormId: ApplicationId, from: String, to: String): Future[Option[NotificationId]]
  def notifyManagerAppPublished(id: OpportunityId, from: String, mgrEmail: String): Future[Option[NotificationId]]
  def notifyManagerSimpleFormSubmitted(applicationFormId: ApplicationId, from: String, to: String): Future[Option[NotificationId]]

}
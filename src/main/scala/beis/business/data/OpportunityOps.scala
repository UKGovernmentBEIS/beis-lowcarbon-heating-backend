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
import beis.business.models.{OpportunityId, OpportunityRow}
import beis.business.restmodels._
import beis.business.tables.OpportunityTables

import scala.concurrent.Future

@ImplementedBy(classOf[OpportunityTables])
trait OpportunityOps {
  def byId(id: OpportunityId): Future[Option[OpportunityRow]]

  def opportunity(opportunityId: OpportunityId): Future[Option[Opportunity]]

  def findOpen: Future[Set[Opportunity]]

  def summaries: Future[Set[Opportunity]]

  def openSummaries: Future[Set[Opportunity]]

  def updateSummary(summary: OpportunitySummary): Future[Int]

  def publish(id: OpportunityId): Future[Option[DateTime]]

  def duplicate(id: OpportunityId): Future[Option[OpportunityId]]

  def saveSectionDescription(id: OpportunityId, sectionNo: Int, description: Option[String]): Future[Int]

  def reset(): Future[Unit]
}


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

package beis.business

import org.joda.time.DateTime
import beis.business.data.OpportunityOps
import beis.business.models.{OpportunityId, OpportunityRow}
import beis.business.restmodels.{Opportunity, OpportunitySummary}

import scala.concurrent.Future

class StubOpportunityOps extends OpportunityOps {

  override def byId(id: OpportunityId): Future[Option[OpportunityRow]] = ???

  override def opportunity(opportunityId: OpportunityId): Future[Option[Opportunity]] = ???

  override def findOpen: Future[Set[Opportunity]] = ???

  override def summaries: Future[Set[Opportunity]] = ???

  override def openSummaries: Future[Set[Opportunity]] = ???

  override def updateSummary(summary: OpportunitySummary): Future[Int] = ???

  override def publish(id: OpportunityId): Future[Option[DateTime]] = ???

  override def duplicate(id: OpportunityId): Future[Option[OpportunityId]] = ???

  override def saveSectionDescription(id: OpportunityId, sectionNo: Int, description: Option[String]): Future[Int] = ???

  override def reset(): Future[Unit] = ???
}

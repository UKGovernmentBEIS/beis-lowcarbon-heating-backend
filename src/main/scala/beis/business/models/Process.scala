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

package beis.business.models

/**
  * Created by venkatamutyala on 05/06/2017.
  */
case class Process (id: ProcessId)
case class ProcessDefinition (processDefinitionId: ProcessDefinitionId, businessKey: BusinessKey, returnVariables: Boolean,
                              variables: Seq[ProcessVariable])
case class ProcessInstance (id: ProcessInstanceId)
case class ProcessId(id: LongId)
case class ProcessInstanceId(id: String)
case class ProcessDefinitionId(id: String)
case class ProcessTaskId(id: String)
case class BusinessKey(id: String)
case class ProcessVariable(name: String, value: String )

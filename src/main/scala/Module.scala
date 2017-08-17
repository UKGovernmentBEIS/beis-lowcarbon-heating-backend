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

import beis.business.Config
import beis.business.notifications.{NotificationService, NotificationServiceGovNotifyImpl, NotificationServicePlayImpl}
import com.google.inject.AbstractModule
import com.google.inject.name.Names
import play.api.{Configuration, Environment}

/**
  * Created by venkatamutyala on 28/03/2017.
  */
class Module(environment: Environment, configuration: Configuration) extends AbstractModule {
  override def configure(): Unit = {

    import Config.config.beis.{email => emailConfig}
    val mode = emailConfig.mode

    emailConfig.mode match {
      case "govnotify" =>
        bind (classOf[NotificationService] )
          .to (classOf[NotificationServiceGovNotifyImpl] )
      case "playnotify" =>
        bind (classOf[NotificationService] )
          .to (classOf[NotificationServicePlayImpl] )
    }
  }

}

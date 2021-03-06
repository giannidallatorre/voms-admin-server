/**
 * Copyright (c) Members of the EGEE Collaboration. 2006-2009. See
 * http://www.eu-egee.org/partners/ for details on the copyright holders.
 * 
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 * 
 * http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 * 
 * Authors: Andrea Ceccanti (INFN)
 */

package org.glite.security.voms.admin.integration.orgdb;

import java.util.Calendar;
import java.util.Date;

import org.glite.security.voms.admin.core.validation.ValidationManager;
import org.glite.security.voms.admin.integration.orgdb.model.Participation;
import org.glite.security.voms.admin.integration.orgdb.model.VOMSOrgDBPerson;
import org.glite.security.voms.admin.integration.orgdb.strategies.OrgDBMembershipSynchronizationStrategy;
import org.glite.security.voms.admin.persistence.model.VOMSUser;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class DefaultSyncStrategy implements
  OrgDBMembershipSynchronizationStrategy {

  public static final Logger log = LoggerFactory
    .getLogger(DefaultSyncStrategy.class);

  protected void synchronizeMembershipExpirationDate(VOMSUser u,
    VOMSOrgDBPerson orgDbPerson, String experimentName) {

    if (orgDbPerson.hasValidParticipationForExperiment(experimentName)) {

      Participation p = orgDbPerson
        .getValidParticipationForExperiment(experimentName);

      if (p.getEndDate() != null) {

        // Participation has an end date, use that for the VOMS
        // membership expiration.
        log.debug("Setting {} expiration date to {}. Previous value was: {}",
          new Object[] { u, p.getEndDate(), u.getEndTime() });

        u.setEndTime(p.getEndDate());

      } else {

        // There is a valid, open-ended participation in the OrgDb. We
        // need to check that user.endTime()
        // membership is updated accordingly, since we cannot have a
        // null value there due to database constraints.
        // (which we could drop, btw, but is a pita for database upgrade
        // management).
        Calendar cal = Calendar.getInstance();
        cal.add(Calendar.DAY_OF_WEEK, 5);
        Date fiveDaysFromNow = cal.getTime();

        // If the VOMS membership is going to expire within 5 days, we
        // just extend it to another year
        if (u.getEndTime().compareTo(fiveDaysFromNow) < 0) {

          log.debug("User VOMS memership end time: {}", u.getEndTime());
          log
            .debug(
              "User {} membership is going to expire within 5 days, but user has a valid OrgDB experiment participation.",
              u);

          cal.setTime(u.getEndTime());
          cal.add(Calendar.YEAR, 1);

          u.setEndTime(cal.getTime());
          log
            .debug(
              "New VOMS membership expiration date: {}. Note that this is purely indicative and will be anyway kept consistent with what comes from the OrgDb.",
              u.getEndTime());

        }
      }

      restoreMembershipIfNeeded(u);
    } else {

      // No valid participation found for experiment. We sync anyway against
      // the latest expired participation, if it exists, or set the membership
      // expiration time to NOW, otherwise

      Participation expiredParticipation = orgDbPerson
        .getLastExpiredParticipationForExperiment(experimentName);
      Date now = new Date();

      if (expiredParticipation == null) {

        // No participation found at all for a user that used to have one ...
        // strange.
        if (!u.hasExpired()) {

          log
            .debug(
              "Expiring VOMS membership for user {} since no valid or expired OrgDB participation was found for experiment {}",
              u, experimentName);
          u.setEndTime(now);
        }

      } else {

        if (u.getEndTime().after(expiredParticipation.getEndDate())) {

          // Set the end date to the date of the expired participation
          // The membership check task will do the rest.
          log
            .debug(
              "Setting {} expiration date to {}. Previous value was: {}",
              new Object[] { u, expiredParticipation.getEndDate(),
                u.getEndTime() });

          u.setEndTime(expiredParticipation.getEndDate());

        }
      }

    }
  }

  private void restoreMembershipIfNeeded(VOMSUser u) {

    if (u.isSuspended() && u.getSuspensionReason().startsWith("OrgDB: ")) {
      ValidationManager.instance().restoreUser(u);
    }

  }

  protected void synchronizeMembershipInstitutionInfo(VOMSUser u,
    VOMSOrgDBPerson orgDbPerson, String experimentName) {

    if (orgDbPerson.hasValidParticipationForExperiment(experimentName)) {

      Participation p = orgDbPerson
        .getValidParticipationForExperiment(experimentName);

      // The institute can be null sometimes
      if (p.getInstitute() != null) {

        if (u.getInstitution() == null
          || !u.getInstitution().equals(p.getInstitute().getOriginalName())) {

          u.setInstitution(p.getInstitute().getOriginalName());

          log.debug(
            "Institution for user {} and participation {} do not match. "
              + "Updating VOMS institution field.", u, p);
        }

      } else {

        log.debug("Null institution in OrgDB record for user {}. "
          + "Updating VOMS institution field.");

        u.setInstitution(null);
      }
    }
  }

  public void synchronizeMemberInformation(VOMSUser u,
    VOMSOrgDBPerson orgDbPerson, String experimentName) {

    log
      .debug(
        "Synchronizing pariticipation data for user {} against orgdb record {} for experiment {}",
        new Object[] { u, orgDbPerson, experimentName });

    synchronizeMembershipExpirationDate(u, orgDbPerson, experimentName);
    synchronizeMembershipInstitutionInfo(u, orgDbPerson, experimentName);

  }

}

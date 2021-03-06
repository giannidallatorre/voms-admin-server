/**
 * Copyright (c) Members of the EGEE Collaboration. 2006-2009.
 * See http://www.eu-egee.org/partners/ for details on the copyright holders.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * Authors:
 * 	Andrea Ceccanti (INFN)
 */
package org.glite.security.voms.admin.notification.messages;

import org.glite.security.voms.admin.configuration.VOMSConfiguration;
import org.glite.security.voms.admin.persistence.model.request.Request;

public class RequestRejected extends AbstractVelocityNotification {

  Request request;

  String rejectReasons;

  public RequestRejected(Request request, String rejectReasons) {

    addRecipient(request.getRequesterInfo().getEmailAddress());
    this.request = request;
    this.rejectReasons = rejectReasons;
  }

  protected void buildMessage() {

    String voName = VOMSConfiguration.instance().getVOName();

    String requestType = request.getTypeName().toLowerCase();

    setSubject("Your " + requestType + " for VO " + voName
      + " has been rejected.");

    context.put("voName", voName);
    context.put("request", request);
    context.put("recipient", getRecipientList().get(0));
    context.put("rejectReasons", rejectReasons);

    super.buildMessage();

  }

}

<%--

    Copyright (c) Members of the EGEE Collaboration. 2006-2009.
    See http://www.eu-egee.org/partners/ for details on the copyright holders.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

    Authors:
    	Andrea Ceccanti (INFN)

--%>
<%@include file="/WEB-INF/p/shared/taglibs.jsp"%>

  <voms:hasPermissions var="canRead"
    context="vo"
    permission="r"/>
    
  <voms:hasPermissions var="canSuspend"
    context="vo"
    permission="SUSPEND"/>

<s:if test="#attr.canRead">
<h1>Users:</h1>

<div id="searchPane">
  <s:form validate="true" theme="simple" action="search">
    <s:hidden name="searchData.type" value="%{'user'}"/>
    <s:textfield name="searchData.text" size="20" value="%{#session.searchData.text}"/>
    <s:submit value="%{'Search users'}" cssClass="submitButton"/>
    <span>Limit to:</span>
    <s:label for="limitToSuspendedUsers"><span class="blabel blabel-important baseline">Suspended</span></s:label>
    <s:checkbox id="limitToSuspendedCheck" 
      name="limitToSuspendedUsers" 
      onclick="$('#limitToAupCheck').attr('checked', false); this.form.submit()"/>
      
    <s:label for="limitToSuspendedUsers"><span class="blabel blabel-warning baseline">Pending sign AUP request</span></s:label>
    <s:checkbox 
      id="limitToAupCheck" 
      name="limitToUsersWithPendingSignAUPRequest" 
      onclick="$('#limitToSuspendedCheck').attr('checked', false); this.form.submit()"/>
      
    <s:label for="searchData.maxResults">Show:</s:label>
    <s:select name="searchData.maxResults" list="{'10','50','100'}"  
      value="%{#session.searchData.maxResults}" 
      onchange="this.form.submit()"/>
  </s:form>
  <s:fielderror fieldName="searchData.text"/>
</div>

<div id="createPane">
	<voms:hasPermissions var="canCreate"
		context="vo"
		permission="rw"/>
	<s:if test="#attr.canCreate">
		<a href="<s:url action="create" method="input"/>">Add a new user</a>
	</s:if>
</div>

<div class="searchResultsPane">
  <tiles2:insertTemplate template="../shared/errorsAndMessages.jsp"/>
  <s:if test='(#session.searchResults.searchString eq null) and (#session.searchResults.results.size == 0)'>
    No users found.
  </s:if>
  <s:elseif test="#session.searchResults.results.size == 0">
    No users found matching search string '<s:property value="#session.searchResults.searchString"/>'.
  </s:elseif>
  <s:elseif test="#session.searchResults != null">
  
  <s:form id="multiUserOpsForm">
  <table
    class="table"
  >
    <s:token/>
    <tr class="userBulkOperations">
      <td style="border: none">
        <s:checkbox 
          name="notSet" 
          id="userSelectorTrigger"
          disabled="%{(not #attr.canCreate and not #attr.CanSuspend)}"
          theme="simple"
          />
      </td>
      <td colspan="3" style="border: none;">
        
        <s:submit value="%{'Suspend'}" align="right" action="bulk-suspend" theme="simple" 
        cssClass="userActionButton"
        onclick=" return openSuspendDialog(this, 'suspendMultiUserDialog','');"
        disabled="%{#attr.canSuspend == false}"
        />
        
        <s:submit value="%{'Restore'}" align="right" action="bulk-restore" theme="simple" 
          cssClass="userActionButton"
          disabled="%{#attr.canSuspend == false}"
        />
        
        
        <s:if test="not #attr.disableMembershipEndTime">
        	<s:submit value="%{'Extend membership'}" align="right" action="bulk-extend-membership-expiration" theme="simple" 
          		cssClass="userActionButton"
          		disabled="%{#attr.canSuspend == false}"
        	/>
        </s:if>
        
        <s:submit value="%{'Delete'}" align="right" action="bulk-delete" theme="simple" 
          cssClass="userActionButton"
          disabled="%{#attr.canCreate == false}"
          onclick="openConfirmDialog(this, 'deleteMultiUserDialog', ''); return false"
        
          />
        
          <s:url value="/user/search.action" var="searchURL"/>
          <div class="resultsNav">
            <tiles2:insertTemplate template="../shared/searchNavBar.jsp"/>
          </div>
      </td>
    </tr>
    <tr style="border-bottom: 1px solid #c8c8c8;">
      <th/>
        
      <th>
        User information
      </th>
        
      <th>Certificates<tiles2:insertTemplate template="../shared/formattedDNControls.jsp"/>
      </th>
      <th/>
    </tr>
    <s:iterator
      value="#session.searchResults.results"
      var="user"
      status="rowStatus"
    >
      <tr class="tableRow">
        <td style="width: 1%; vertical-align: top; padding-top: .8em;">
          <s:checkbox 
            name="userIds" 
            fieldValue="%{id}" 
            cssClass="userCheckbox" 
            theme="simple" 
            value="%{'false'}"
            disabled="%{#attr.canCreate == false and #attr.canSuspend == false}"/>
        </td>
        <td style="width: 40%"> <!-- Personal info -->
          <div class="personal-info">
            
            <s:if test="name != null and name != ''">
              <div class="username">
                <s:property value="%{#user.name + ' ' + #user.surname}"/>
              </div>
            </s:if>
            <s:else>
              <div class="unspecified">
                No name specified for this user.
              </div>
            </s:else>
            <s:if test="institution != null and institution != ''">
              <div class="institution" style="padding-top: .5em">
                <s:property value="institution"/>
              </div>
            </s:if>
            <s:else>
              <div class="unspecified">
                No institution specified for this user.
              </div>
            </s:else>
       
            <div class="email">
              <a href="mailto:<s:property value="emailAddress"/>">
                <s:property value="emailAddress"/>
              </a>
            </div>
            
            <s:if test="suspended">
              <div>
                <span class="blabel blabel-important">Suspended</span>  
                <span class="blabel blabel-invert-important"><s:property value="suspensionReason"/></span>
              </div>
            </s:if>
            <div class="cont aupInfo">
              <tiles2:insertTemplate template="aupStatusDetail.jsp"/>
            </div>
            <div class="expirationInfo cont">
               <tiles2:insertTemplate template="membershipExpirationDetail.jsp"/>
            </div>
            </div>
        </td>

        <td> <!-- Certificate information -->
          <ol class="certificate-info">
          
          <s:iterator value="certificates" var="cert">
            <li> 
              <div class="certSubject <s:if test="suspended">suspended-cert</s:if>">
                <s:set value="subjectString" var="thisCertDN"/>
                <voms:formatDN dn="${thisCertDN}" fields="CN"/>
              </div>
              <div class="certIssuer <s:if test="suspended">suspended-cert</s:if>">
                <s:set value="ca.subjectString" var="thisCertCA"/>
                <voms:formatDN dn="${thisCertCA}" fields="CN"/>
              </div>
            </li>
          </s:iterator>
          </ol>
          </td>
          
          <td style="vertical-align: bottom;"> <!--  Actions -->
          <div class="actions" style="float: right;">
          
          	<s:url action="load" var="userLoadURL">
          		<s:param name="userId" value="id"/>	
          	</s:url> 
          	<s:a href="%{userLoadURL}" cssClass="actionLink">
              more info     
          	</s:a>	  	
          </div>
         </td>
      </tr>
    </s:iterator>
  </table>
  </s:form>
  
  <s:url value="/user/search.action" var="searchURL"/>
  
    <div class="resultsFooter">
      <tiles2:insertTemplate template="../shared/searchNavBar.jsp"/>
    </div>
  </s:elseif>
</div>
</s:if>
<s:else>
  You do not have enough permissions to browse this VO users.
</s:else>
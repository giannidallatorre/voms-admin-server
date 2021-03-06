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

<s:if
	test="not pendingRequests.{? #this.typeName == 'Group membership request'}.empty">
	<h1>Group membership requests:</h1>


	<table>
		<tr class="req-header-row">
			<th>Requester</th>
			<th>Requested group</th>
			<th />
		</tr>
		<s:iterator
			value="pendingRequests.{? #this.typeName == 'Group membership request'}"
			var="groupRequest">
			<tr class="tableRow">
				<td style="width: 40%"><tiles2:insertTemplate
					template="userInfo.jsp" flush="true" /></td>
				<td>
				<div class="groupName"><s:property value="groupName" /></div>

				</td>

				<td style="vertical-align: bottom; text-align: right">
                  <tiles2:insertTemplate template="decisionForm.jsp"/>
                </td>
			</tr>
		</s:iterator>
	</table>
</s:if>
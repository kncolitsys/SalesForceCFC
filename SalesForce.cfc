<cfcomponent displayname="SalesForceCFC" output="false">
	
	<cffunction name="init" access="public" output="false" returntype="SalesForce">
		<cfargument name="username" type="string" required="true" />
		<cfargument name="password" type="string" required="true" />
		<cfargument name="loginURL" type="string" required="false" default="https://www.salesforce.com/services/Soap/u/11.1" />
		<cfargument name="portalURL" type="string" required="false" default="https://na3.salesforce.com" />
		<cfargument name="soapTimeout" type="numeric" required="false" default="60" />
		<cfargument name="autoLogin" type="boolean" required="false" default="true" />
		
		<cfscript>
			variables.instance = structNew();
			variables.instance.sessionId = '';
			variables.instance.serverURL = '';
			variables.instance.lastLogin = '';
			
			setUserName(arguments.username);
			setPassword(arguments.password);
			setLoginURL(arguments.loginURL);
			setPortalURL(arguments.portalURL);
			setSOAPTimeout(arguments.soapTimeout);
			setAutoLogin(arguments.autoLogin);
		</cfscript>
		
		<cfreturn this />
	</cffunction>
	
	<!--- GETTERS / SETTERS --->
	<cffunction name="getMemento" access="public" returntype="struct" output="false">
		<cfreturn variables.instance />
	</cffunction>
	
	<cffunction name="getVersion" access="public" returntype="string" output="false">
		<cfreturn '0.8' />
	</cffunction>
	
	<cffunction name="getSessionId" access="public" returntype="string" output="false">
		<cfreturn variables.instance.sessionId />
	</cffunction>
	
	<cffunction name="getServerURL" access="public" returntype="string" output="false">
		<cfreturn variables.instance.serverURL />
	</cffunction>
	
	<cffunction name="getLastLogin" access="public" returntype="string" output="false">
		<cfreturn variables.instance.lastLogin />
	</cffunction>
	
	<cffunction name="getUserName" access="public" returntype="string" output="false">
		<cfreturn variables.instance.username />
	</cffunction>
	
	<cffunction name="setUserName" access="public" returntype="void" output="false">
		<cfargument name="username" type="string" required="true" />
		<cfset variables.instance.username = arguments.username />
	</cffunction>
	
	<cffunction name="getPassword" access="public" returntype="string" output="false">
		<cfreturn variables.instance.password />
	</cffunction>
	
	<cffunction name="setPassword" access="public" returntype="void" output="false">
		<cfargument name="password" type="string" required="true" />
		<cfset variables.instance.password = arguments.password />
	</cffunction>
	
	<cffunction name="getLoginURL" access="public" returntype="string" output="false">
		<cfreturn variables.instance.loginURL />
	</cffunction>
	
	<cffunction name="setLoginURL" access="public" returntype="void" output="false">
		<cfargument name="loginURL" type="string" required="true" />
		<cfset variables.instance.loginURL = arguments.loginURL />
	</cffunction>
	
	<cffunction name="getPortalURL" access="public" returntype="string" output="false">
		<cfreturn variables.instance.portalURL />
	</cffunction>
	
	<cffunction name="setPortalURL" access="public" returntype="void" output="false">
		<cfargument name="portalURL" type="string" required="true" />
		<cfset variables.instance.portalURL = arguments.portalURL />
	</cffunction>
	
	<cffunction name="getSoapTimeout" access="public" returntype="numeric" output="false">
		<cfreturn variables.instance.soapTimeout />
	</cffunction>
	
	<cffunction name="setSoapTimeout" access="public" returntype="void" output="false">
		<cfargument name="soapTimeout" type="numeric" required="true" />
		<cfset variables.instance.soapTimeout = arguments.soapTimeout />
	</cffunction>
	
	<cffunction name="getAutoLogin" access="public" returntype="boolean" output="false">
		<cfreturn variables.instance.autoLogin />
	</cffunction>
	
	<cffunction name="setAutoLogin" access="public" returntype="void" output="false">
		<cfargument name="autoLogin" type="boolean" required="true" />
		<cfset variables.instance.autoLogin = arguments.autoLogin />
	</cffunction>
	
	<!--- SF CORE CALLS --->
	<cffunction name="login" access="public" output="false" returntype="struct">
		<cfset var stLocal = structNew() />
		<cfset var stReturn = structNew() />
		<cfset stReturn.success = true />
		
		<cftry>
			<cfif not structKeyExists(variables,'instance')>
				<cfthrow message="Object not initialized" detail="Create an instance of object with init() method" type="salesForceCFC" />
			<cfelseif not len(getUserName())>
				<cfthrow message="Username is required." detail="Username is empty. Use setUserName() method." type="salesForceCFC" />
			<cfelseif not len(getPassword())>
				<cfthrow message="Password is required." detail="Password is empty. Use setPassword() method." type="salesForceCFC" />
			</cfif>
			
			<!--- build SOAP request--->
			<cfsavecontent variable="stLocal.requestSOAP">
				<cfoutput>
					<?xml version="1.0" encoding="utf-8"?>
					<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:enterprise.soap.sforce.com">
						<soapenv:Body>
							<urn:login>
								<urn:username>#getUserName()#</urn:username>
								<urn:password>#getPassword()#</urn:password>
							</urn:login>
						</soapenv:Body>
					</soapenv:Envelope>
				</cfoutput>
			</cfsavecontent>
			
			<!--- send SOAP request --->
			<cfset stLocal.soapXML = brokerSOAPRequest(requestURL = getLoginURL(), requestSOAP = stLocal.requestSOAP, generateHeader = false) />

			<!--- parse out session values --->
			<cfset stLocal.sessionId = xmlSearch(stLocal.soapXML, "//*[name()='sessionId']") />
			<cfset stLocal.serverUrl = xmlSearch(stLocal.soapXML, "//*[name()='serverUrl']") />
			<!--- if valid response set values --->
			<cfif arraylen(stLocal.sessionId) and arrayLen(stLocal.serverUrl)>
				<cfset variables.instance.serverURL = stLocal.serverUrl[1].xmlText />
				<cfset variables.instance.sessionId = stLocal.sessionId[1].xmlText />
				<cfset variables.instance.lastLogin = now() />
			<!--- on unknown return response --->
			<cfelse>
				<cfthrow message="Unknown response" detail="#trim(stLocal.soapRequest.results.fileContent)#" />
			</cfif>
						
			<!--- trap - return failure and error ---> 
			<cfcatch type="any">
				<cfset stReturn.success = false />
				<cfset stReturn.error = cfcatch />
			</cfcatch>
		</cftry>

		<cfreturn stReturn />
	</cffunction>
	
	<cffunction name="retrieveObject" access="public" output="false" returntype="struct">
		<cfargument name="objectType" type="string" required="true" />
		<cfargument name="fieldList" type="string" required="true" />
		<cfargument name="idList" type="string" required="true" />
		
		<cfset var stLocal = structNew() />
		<cfset var stReturn = structNew() />
		<cfset stReturn.success = true />
		<cfset stReturn.results = arrayNew(1) />
		
		<cftry>
			<cfset validate() />
			<!--- build SOAP request--->
			<cfsavecontent variable="stLocal.requestSOAP">
				<cfoutput>
					  <soapenv:Body>
					  	 <urn:retrieve>
					        <urn:fieldList>#arguments.fieldList#</urn:fieldList>
					        <urn:sObjectType>#arguments.objectType#</urn:sObjectType>
					        <cfloop list="#arguments.idList#" index="stLocal.iId">
					        	<urn:ids>#stLocal.iId#</urn:ids>
					        </cfloop>
					     </urn:retrieve>
					  </soapenv:Body>
				</cfoutput>
			</cfsavecontent>
			
			<!--- send SOAP request --->
			<cfset stLocal.soapXML = brokerSOAPRequest(requestURL = getServerURL(), requestSOAP = stLocal.requestSOAP) />
			
			<!--- parse out result --->
			<cfset stLocal.result = xmlSearch(stLocal.soapXML, "//*[name()='result']") />
			<!--- if valid response set values --->
			<cfif arraylen(stLocal.result)>
				<!--- create list of columns for query --->
				<cfset stLocal.fieldList = structNew() />
				<!--- loop thru records to build query --->
				<cfloop from="1" to="#arrayLen(stLocal.result[1].xmlChildren)#" index="stLocal.iColumn">
					<cfset stLocal.fieldList[listLast(stLocal.result[1].xmlChildren[stLocal.iColumn].xmlName,':')] = '' />
				</cfloop>
				<!--- loop thru field children to build info into struct --->
				<cfloop from="1" to="#arrayLen(stLocal.result)#" index="stLocal.iRecord">
					<!--- loop thru records to build query --->
					<cfloop from="1" to="#arrayLen(stLocal.result[stLocal.iRecord].xmlChildren)#" index="stLocal.iColValue">
						<cfset stLocal.fieldList[listLast(stLocal.result[stLocal.iRecord].xmlChildren[stLocal.iColValue].xmlName,':')] = stLocal.result[stLocal.iRecord].xmlChildren[stLocal.iColValue].xmlText />
					</cfloop>
					<cfset arrayAppend(stReturn.results,stLocal.fieldList) />
				</cfloop>
			<!--- on unknown return response --->
			<cfelse>
				<cfthrow message="Unknown response" detail="#trim(stLocal.soapRequest.results.fileContent)#" />
			</cfif>
				
			<!--- trap - return failure and error ---> 
			<cfcatch type="any">
				<cfset stReturn.success = false />
				<cfset stReturn.error = cfcatch />
			</cfcatch>
		</cftry>

		<cfreturn stReturn />
	</cffunction>
	
	<cffunction name="queryObject" access="public" output="false" returntype="struct">
		<cfargument name="queryString" type="string" required="true" />
		<cfargument name="includeRelatedObject" type="boolean" required="false" default="true" />
		<cfargument name="batchSize" type="numeric" required="false" default="0" hint="Minimum of 200. Maximum of 2,000." />
		<cfargument name="disablePagination" type="boolean" required="false" default="false" hint="Will use queryMore to fetch all records." />

		<cfset var stSOAPArgs = structNew() />
		<cfset var stLocal = structNew() />
		<cfset var stReturn = structNew() />
		<cfset stReturn.success = true />
		<cfset stReturn.results = '' />
		
		<cftry>
			<cfset validate() />
			
			<!--- build SOAP request--->
			<cfsavecontent variable="stLocal.requestSOAP">
				<cfoutput>
					  <soapenv:Body>
					     <urn:query>
					        <urn:queryString>#xmlFormat(arguments.queryString)#</urn:queryString>
					     </urn:query>
					  </soapenv:Body>
				</cfoutput>
			</cfsavecontent>
			
			<cfif not arguments.disablePagination and arguments.batchSize gt 0>
				<cfset stSOAPArgs.appendToHeader = buildQueryOptions(batchsize = arguments.batchSize) />
			</cfif>
			
			<cfset stSOAPArgs.requestURL = getServerURL() />
			<cfset stSOAPArgs.requestSOAP = stLocal.requestSOAP />
			
			<!--- send SOAP request --->
			<cfset stLocal.soapXML = brokerSOAPRequest(argumentCollection = stSOAPArgs) />
			
			<!--- check for valid response --->
			<cfset stLocal.result = xmlSearch(stLocal.soapXML, "//*[name()='result']") />
			<!--- return soap response when unknown --->
			<cfif not arrayLen(stLocal.result)>
				<cfthrow message="Unknown response" detail="#trim(arguments.soapRequest.results.fileContent)#" />
			</cfif>
			
			<!--- parse query results --->
			<cfset stLocal.queryResults = parseQueryXML(stLocal.soapXML, arguments.includeRelatedObject, arguments.batchSize) />
			<cfif not stLocal.queryResults.success>
				<cfthrow object="#stLocal.queryResults.error#" />
			</cfif>
			<cfset stReturn = stLocal.queryResults />
		
			<cfif arguments.disablePagination and structKeyExists(stReturn,'queryLocator') and isQuery(stReturn.results)>
				<cfloop condition="stReturn.results.recordCount lt stReturn.size">
					<cfset stLocal.queryMore = queryMore(queryLocator = stReturn.queryLocator, startRow = stReturn.batchSize + 1, batchsize = arguments.batchSize) />
					<cfif stLocal.queryMore.success>
						<cfquery name="stReturn.results" dbtype="query">
							SELECT *
							FROM stReturn.results
							UNION
							SELECT *
							FROM stLocal.queryMore.results
						</cfquery>
					<cfelse>
						<cfthrow object="#stLocal.queryMore.error#" />
					</cfif>
				</cfloop>
			</cfif>
			
			<!--- trap - return failure and error ---> 
			<cfcatch type="any">
				<cfset stReturn.success = false />
				<cfset stReturn.error = cfcatch />
			</cfcatch>
		</cftry>
		
		<cfreturn stReturn />
	</cffunction>
	
	<cffunction name="queryMore" access="public" output="false" returntype="struct">
		<cfargument name="queryLocator" type="string" required="false" />
		<cfargument name="includeRelatedObject" type="boolean" required="false" default="true" />
		<cfargument name="batchSize" type="numeric" required="false" default="200" hint="Minimum of 200. Maximum of 2,000." />
		<cfargument name="startRow" type="numeric" required="false" default="#(arguments.batchSize+1)#" />
		
		<cfset var stSOAPArgs = structNew() />
		<cfset var stLocal = structNew() />
		<cfset var stReturn = structNew() />
		<cfset stReturn.success = true />
		<cfset stReturn.results = '' />
		
		<cftry>
			<cfset validate() />
			
			<!--- build SOAP request--->
			<cfsavecontent variable="stLocal.requestSOAP">
				<cfoutput>
					  <soapenv:Body>
					  	 <urn:queryMore>
					        <urn:queryLocator>#arguments.queryLocator#-#(arguments.startRow-1)#</urn:queryLocator>
					     </urn:queryMore>
					  </soapenv:Body>
				</cfoutput>
			</cfsavecontent>
			
			<cfif arguments.batchSize gt 0>
				<cfset stSOAPArgs.appendToHeader = buildQueryOptions(batchsize = arguments.batchSize) />
			</cfif>
			
			<cfset stSOAPArgs.requestURL = getServerURL() />
			<cfset stSOAPArgs.requestSOAP = stLocal.requestSOAP />
			
			<!--- send SOAP request --->
			<cfset stLocal.soapXML = brokerSOAPRequest(argumentCollection = stSOAPArgs) />
			
			<!--- check for valid response --->
			<cfset stLocal.result = xmlSearch(stLocal.soapXML, "//*[name()='result']") />
			<!--- return soap response when unknown --->
			<cfif not arrayLen(stLocal.result)>
				<cfthrow message="Unknown response" detail="#trim(arguments.soapRequest.results.fileContent)#" />
			</cfif>
			
			<!--- parse query results --->
			<cfset stLocal.queryResults = parseQueryXML(stLocal.soapXML, arguments.includeRelatedObject, arguments.batchSize) />
			<cfif not stLocal.queryResults.success>
				<cfthrow object="#stLocal.queryResults.error#" />
			</cfif>
			<cfset stReturn = stLocal.queryResults />
			
			<!--- trap - return failure and error ---> 
			<cfcatch type="any">
				<cfset stReturn.success = false />
				<cfset stReturn.error = cfcatch />
			</cfcatch>
		</cftry>
		
		<cfreturn stReturn />
	</cffunction>

	<cffunction name="saveObject" access="public" output="false" returntype="struct">
		<cfargument name="objectType" type="string" required="false" />
		<cfargument name="objectDataStruct" type="struct" required="false" />
		<cfargument name="soapAction" type="string" required="true" />
		<cfargument name="sendNull" type="boolean" required="false" default="false" />
		<cfargument name="appendAssignmentHeader" type="boolean" required="false" default="false" />
		<cfargument name="assignmentHeaderId" type="string" required="false" />
		<cfargument name="useDefaultRule" type="boolean" required="false" />
		<cfargument name="objectArray" type="array" required="false" />
		
		<cfset var stSOAPArgs = structNew() />
		<cfset var stLocal = structNew() />
		<cfset var stReturn = structNew() />
		<cfset stReturn.success = true />							

		<cftry>
			<cfset validate() />
			
			<cfif structKeyExists(arguments,'objectDataStruct') and structKeyExists(arguments,'objectType')>
				<cfset arguments.objectArray = arrayNew(1) />
				<cfset arguments.objectArray[1] = arguments.objectDataStruct />
				<cfset arguments.objectArray[1]['_objectType'] =  arguments.objectType />
			</cfif>
			
			<!--- build SOAP request--->
			<cfsavecontent variable="stLocal.requestSOAP">
				<cfoutput>
					  <soapenv:Body>
					     <urn:#arguments.soapAction#>
				     		<cfloop from="1" to="#arrayLen(arguments.objectArray)#" index="stLocal.iObject">
					        	<urn:sObjects xsi:type="urn1:#arguments.objectArray[stLocal.iObject]._objectType#">
								<cfloop collection="#arguments.objectArray[stLocal.iObject]#" item="stLocal.iObjectField">
									<cfif not stLocal.iObjectField eq '_objectType' and len(arguments.objectArray[stLocal.iObject][stLocal.iObjectField]) or arguments.sendNull>
										<#stLocal.iObjectField#>#xmlFormat(arguments.objectArray[stLocal.iObject][stLocal.iObjectField])#</#stLocal.iObjectField#>
									</cfif>
								</cfloop>
								</urn:sObjects>
							</cfloop>
					     </urn:#arguments.soapAction#>
					  </soapenv:Body>
				</cfoutput>
			</cfsavecontent>

			<!--- check for assignment header --->
			<cfif arguments.appendAssignmentHeader>
				<cfset stSOAPArgs.appendToHeader = buildAssignmentHeader(argumentCollection = arguments) />
			</cfif>
			
			<cfset stSOAPArgs.requestURL = getServerURL() />
			<cfset stSOAPArgs.requestSOAP = stLocal.requestSOAP />
			<cfset stSOAPArgs.appendToEnvelope = 'xmlns:urn1="urn:sobject.enterprise.soap.sforce.com" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"' />
			
			<!--- send SOAP request --->
			<cfset stLocal.soapXML = brokerSOAPRequest(argumentCollection = stSOAPArgs) />
			
			<!--- check for error codes --->
			<cfset stLocal.success = xmlSearch(stLocal.soapXML, "//*[name()='success']") />
			<cfset stLocal.statusCode = xmlSearch(stLocal.soapXML, "//*[name()='statusCode']") />
			<cfset stLocal.message = xmlSearch(stLocal.soapXML, "//*[name()='message']") />
			
			<!--- on fail grab fault code and info --->
			<cfif arrayLen(stLocal.success) and not stLocal.success[1].xmlText and arraylen(stLocal.statusCode) and arraylen(stLocal.message)>
				<cfthrow message="#stLocal.message[1].xmlText#" detail="#stLocal.statusCode[1].xmlText#" />
			<!--- on success check for success and leadId --->
			<cfelse>
				<!--- look for multiple results --->
				<cfset stLocal.results = xmlSearch(stLocal.soapXML, "//*[name()='result']") />
				<cfif arrayLen(stLocal.results)>
					<cfset stReturn.results = arrayNew(1) />
					<cfloop from="1" to="#arrayLen(stLocal.results)#" index="stLocal.iResult">
						<cfset stLocal.result = structNew() />
						<cfset stLocal.result.success = stLocal.results[stLocal.iResult]['success'].xmlText />
						<!--- return id or error message --->
						<cfif stLocal.result.success>
							<cfset stLocal.result.idLong = stLocal.results[stLocal.iResult]['id'].xmlText />
							<cfset stLocal.result.id = left(stLocal.result.idLong,15) />
							<cfset stLocal.result.idURL = getPortalURL() & '/' & stLocal.result.id />
						<cfelse>
							<cfset stLocal.message = xmlSearch(stLocal.soapXML, "//*[name()='message']") />
							<cfset stLocal.result.message = stLocal.message[1].xmlText />
						</cfif>
						<cfset arrayAppend(stReturn.results,stLocal.result) />
					</cfloop>
					<cfif arrayLen(stLocal.results) eq 1>
						<cfset structAppend(stReturn,stLocal.result) />
					</cfif>
				<cfelse>
					<cfthrow message="Unknown response" detail="#trim(stLocal.soapRequest.results.fileContent)#" />
				</cfif>
			</cfif>
				
			<!--- trap - return failure and error ---> 
			<cfcatch type="any">
				<cfset stReturn.success = false />
				<cfset stReturn.error = cfcatch />
			</cfcatch>
		</cftry>

		<cfreturn stReturn />
	</cffunction>

	<cffunction name="deleteObject" access="public" output="false" returntype="struct">
		<cfargument name="idList" type="string" required="true" />
		
		<cfset var stLocal = structNew() />
		<cfset var stReturn = structNew() />
		<cfset stReturn.success = true />
		<cfset stReturn.results = structNew() />
		
		<cftry>
			<cfset validate() />
			
			<!--- build SOAP request--->
			<cfsavecontent variable="stLocal.requestSOAP">
				<cfoutput>
					  <soapenv:Body>
					     <urn:delete>
					        <cfloop list="#arguments.idList#" index="stLocal.iId">
					        	<urn:ids>#stLocal.iId#</urn:ids>
					        </cfloop>
					     </urn:delete>
					  </soapenv:Body>
				</cfoutput>
			</cfsavecontent>
			
			<!--- send SOAP request --->
			<cfset stLocal.soapXML = brokerSOAPRequest(requestURL = getServerURL(), requestSOAP = stLocal.requestSOAP) />
			
			<!--- parse out result --->
			<cfset stLocal.result = xmlSearch(stLocal.soapXML, "//*[name()='result']") />
			<!--- if valid response set values --->
			<cfif arraylen(stLocal.result)>
				<!--- create list of columns for query --->
				<cfset stLocal.fieldList = structNew() />
				<!--- loop thru records to build query --->
				<cfloop from="1" to="#arrayLen(stLocal.result[1].xmlChildren)#" index="stLocal.iColumn">
					<cfset stLocal.fieldList[listLast(stLocal.result[1].xmlChildren[stLocal.iColumn].xmlName,':')] = '' />
				</cfloop>
				<cfset stReturn.results = queryNew(structKeyList(stLocal.fieldList)) />

				<!--- loop thru field children to build info into struct --->
				<cfloop from="1" to="#arrayLen(stLocal.result)#" index="stLocal.iRecord">
					<cfset queryAddRow(stReturn.results) />
					<!--- loop thru records to build query --->
					<cfloop from="1" to="#arrayLen(stLocal.result[stLocal.iRecord].xmlChildren)#" index="stLocal.iColValue">
						<cfset querySetCell(stReturn.results,listLast(stLocal.result[stLocal.iRecord].xmlChildren[stLocal.iColValue].xmlName,':'),stLocal.result[stLocal.iRecord].xmlChildren[stLocal.iColValue].xmlText) />
					</cfloop>
				</cfloop>							
			<!--- on unknown return response --->
			<cfelse>
				<cfthrow message="Unknown response" detail="#trim(stLocal.soapRequest.results.fileContent)#" />
			</cfif>
	
			<!--- trap - return failure and error ---> 
			<cfcatch type="any">
				<cfset stReturn.success = false />
				<cfset stReturn.error = cfcatch />
			</cfcatch>
		</cftry>
		
		<cfreturn stReturn />
	</cffunction>
	
	<!--- SF DESCRIBE CALLS --->
	<cffunction name="describeGlobal" access="public" output="false" returntype="struct">
		<cfset var stLocal = structNew() />
		<cfset var stReturn = structNew() />
		<cfset stReturn.success = true />
		<cfset stReturn.results = arrayNew(1) />
		
		<cftry>
			<cfset validate() />
			
			<!--- build SOAP request--->
			<cfsavecontent variable="stLocal.requestSOAP">
				<cfoutput>
					  <soapenv:Body>
					     <urn:describeGlobal />
					  </soapenv:Body>
				</cfoutput>
			</cfsavecontent>
			
			<!--- send SOAP request --->
			<cfset stLocal.soapXML = brokerSOAPRequest(requestURL = getServerURL(), requestSOAP = stLocal.requestSOAP) />
			
			<!--- parse out types --->
			<cfset stLocal.types = xmlSearch(stLocal.soapXML, "//*[name()='types']") />
			<!--- if valid response set values --->
			<cfif arraylen(stLocal.types)>
				<cfloop from="1" to="#arrayLen(stLocal.types)#" index="stLocal.iType">
					<cfset stReturn.results[stLocal.iType] = stLocal.types[stLocal.iType].xmlText />
				</cfloop>
			<!--- on unknown return response --->
			<cfelse>
				<cfthrow message="Unknown response" detail="#trim(stLocal.soapRequest.results.fileContent)#" />
			</cfif>
	
			<!--- trap - return failure and error ---> 
			<cfcatch type="any">
				<cfset stReturn.success = false />
				<cfset stReturn.error = cfcatch />
			</cfcatch>
		</cftry>
		
		<cfreturn stReturn />
	</cffunction>
	
	<cffunction name="describeObject" access="public" output="false" returntype="struct">
		<cfargument name="objectType" type="string" required="true" />
		
		<cfset var stLocal = structNew() />
		<cfset var stReturn = structNew() />
		<cfset stReturn.success = true />
		<cfset stReturn.results = structNew() />
		
		<cftry>
			<cfset validate() />
			
			<!--- build SOAP request--->
			<cfsavecontent variable="stLocal.requestSOAP">
				<cfoutput>
					  <soapenv:Body>
					     <urn:describeSObject>
					        <urn:sObjectType>#arguments.objectType#</urn:sObjectType>
					     </urn:describeSObject>
					  </soapenv:Body>
				</cfoutput>
			</cfsavecontent>
			
			<!--- send SOAP request --->
			<cfset stLocal.soapXML = brokerSOAPRequest(requestURL = getServerURL(), requestSOAP = stLocal.requestSOAP) />
			
			<!--- parse out fields from xml --->
			<cfset stLocal.fields = xmlSearch(stLocal.soapXML, "//*[name()='fields']") />
			<!--- if valid response set values --->
			<cfif arraylen(stLocal.fields)>
				<!--- loop thru field children to build info into struct --->
				<cfloop from="1" to="#arrayLen(stLocal.fields)#" index="stLocal.iField">
					<cfset stLocal.stChildren = structNew() />
					<cfloop from="1" to="#arrayLen(stLocal.fields[stLocal.iField].xmlChildren)#" index="stLocal.iChild">
						<cfset stLocal.stChildren[stLocal.fields[stLocal.iField].xmlChildren[stLocal.iChild].xmlName] = stLocal.fields[stLocal.iField].xmlChildren[stLocal.iChild].xmlText />
					</cfloop>
					<cfset stReturn.results[stLocal.stChildren['name']] = stLocal.stChildren />
				</cfloop>
			<!--- on unknown return response --->
			<cfelse>
				<cfthrow message="Unknown response" detail="#trim(stLocal.soapRequest.results.fileContent)#" />
			</cfif>
				
			<!--- trap - return failure and error ---> 
			<cfcatch type="any">
				<cfset stReturn.success = false />
				<cfset stReturn.error = cfcatch />
			</cfcatch>
		</cftry>
		
		<cfreturn stReturn />
	</cffunction>
	
	<!--- SF UTILITY CALLS --->
	<cffunction name="getUserInfo" access="public" output="false" returntype="struct">
			
		<cfset var stLocal = structNew() />
		<cfset var stReturn = structNew() />
		<cfset stReturn.success = true />
		<cfset stReturn.results = structNew() />
		
		<cftry>
			<cfset validate() />
			<!--- build SOAP request--->
			<cfsavecontent variable="stLocal.requestSOAP">
				<cfoutput>
					  <soapenv:Body>
					     <urn:getUserInfo />
					  </soapenv:Body>
				</cfoutput>
			</cfsavecontent>
			
			<!--- send SOAP request --->
			<cfset stLocal.soapXML = brokerSOAPRequest(requestURL = getServerURL(), requestSOAP = stLocal.requestSOAP) />

			<!--- parse out fields from xml --->
			<cfset stLocal.result = xmlSearch(stLocal.soapXML, "//*[name()='result']") />
			<cfset stLocal.result = stLocal.result[1].xmlChildren />

			<!--- if valid response set values --->
			<cfif arraylen(stLocal.result)>
				<!--- loop thru field children to build info into struct --->
				<cfloop from="1" to="#arrayLen(stLocal.result)#" index="stLocal.iResult">
					<cfset structInsert(stReturn.results,stLocal.result[stLocal.iResult].xmlName,stLocal.result[stLocal.iResult].xmlText) />
				</cfloop>
			<!--- on unknown return response --->
			<cfelse>
				<cfthrow message="Unknown response" detail="#trim(stLocal.soapRequest.results.fileContent)#" />
			</cfif>
				
			<!--- trap - return failure and error ---> 
			<cfcatch type="any">
				<cfset stReturn.success = false />
				<cfset stReturn.error = cfcatch />
			</cfcatch>
		</cftry>
		
		<cfreturn stReturn />
	</cffunction>
	
	<cffunction name="getServerTimestamp" access="public" output="false" returntype="struct">
			
		<cfset var stLocal = structNew() />
		<cfset var stReturn = structNew() />
		<cfset stReturn.success = true />
		<cfset stReturn.results = structNew() />
		
		<cftry>
			<cfset validate() />
			<!--- build SOAP request--->
			<cfsavecontent variable="stLocal.requestSOAP">
				<cfoutput>
					  <soapenv:Body>
					    <urn:getServerTimestamp />
					  </soapenv:Body>
				</cfoutput>
			</cfsavecontent>
			
			<!--- send SOAP request --->
			<cfset stLocal.soapXML = brokerSOAPRequest(requestURL = getServerURL(), requestSOAP = stLocal.requestSOAP) />

			<!--- parse out fields from xml --->
			<cfset stLocal.result = xmlSearch(stLocal.soapXML, "//*[name()='result']") />
			
			<!--- if valid response set values --->
			<cfif arraylen(stLocal.result) and arrayLen(stLocal.result[1].xmlChildren) and len(stLocal.result[1].xmlChildren[1].xmlText)>
				<!--- loop thru field children to build info into struct --->
				<cfset stReturn.results = stLocal.result[1].xmlChildren[1].xmlText />
			<!--- on unknown return response --->
			<cfelse>
				<cfthrow message="Unknown response" detail="#trim(stLocal.soapRequest.results.fileContent)#" />
			</cfif>
				
			<!--- trap - return failure and error ---> 
			<cfcatch type="any">
				<cfset stReturn.success = false />
				<cfset stReturn.error = cfcatch />
			</cfcatch>
		</cftry>
		
		<cfreturn stReturn />
	</cffunction>
	
	<!--- SOAP --->
	<cffunction name="sendSoapRequest" access="private" output="false" returntype="struct">
		<cfargument name="requestURL" type="string" required="true" />
		<cfargument name="requestSOAP" type="string" required="true" />
		<cfargument name="appendToEnvelope" type="string" required="false" default="" />
		<cfargument name="generateHeader" type="boolean" required="false" default="true" />
		<cfargument name="appendToHeader" type="string" required="false" default="" />
		
		<cfset var stLocal = structNew() />
		<cfset var stReturn = structNew() />
		<cfset stReturn.success = true />
		<cfset stReturn.results = '' />

		<cftry>
			<cfif arguments.generateHeader>
				<!--- build SOAP request--->
				<cfsavecontent variable="arguments.requestSOAP">
					<cfoutput>
						<?xml version="1.0" encoding="utf-8"?>   
						<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"
						  xmlns:urn="urn:enterprise.soap.sforce.com" <cfif len(arguments.appendToEnvelope)>#arguments.appendToEnvelope#</cfif>>
						  <soapenv:Header>
						     <urn:SessionHeader>
						        <urn:sessionId>#getSessionId()#</urn:sessionId>
						     </urn:SessionHeader>
						     <cfif len(arguments.appendToHeader)>#arguments.appendToHeader#</cfif>
						  </soapenv:Header>
						  #arguments.requestSOAP#
						</soapenv:Envelope>
					</cfoutput>
				</cfsavecontent>
			</cfif>

			<!--- send SOAP request via http --->
			<cfhttp url="#arguments.requestURL#" method="post" charset="utf-8" result="stReturn.results" throwonerror="false" timeout="#getSoapTimeout()#">
				<cfhttpparam type="Header" 	name="Cache-Control" 	value="no-cache"> 
				<cfhttpparam type="Header" 	name="Pragma" 			value="no-cache">
				<cfhttpparam type="Header" 	name="SOAPAction" 		value="dummy">
				<cfhttpparam type="Header" 	name="Content-Length" 	value="#len(trim(arguments.requestSOAP))#">
				<cfhttpparam type="xml" 	name="body"				value="#trim(arguments.requestSOAP)#" />
			</cfhttp>
			
			<!--- trap - return failure and error ---> 
			<cfcatch type="any">
				<cfset stReturn.success = false />
				<cfset stReturn.error = cfcatch />
			</cfcatch>
		</cftry>
		
		<cfreturn stReturn />
	</cffunction>
	
	<cffunction name="formatSoapResponse" access="private" output="false" returntype="struct">
		<cfargument name="soapRequest" type="struct" required="true" />
		
		<cfset var stLocal = structNew() />
		<cfset var stReturn = structNew() />
		<cfset stReturn.success = true />
		<cfset stReturn.results = '' />
		
		<cftry>
			<!--- if request fails throw --->
			<cfif not arguments.soapRequest.success>
				<cfthrow message="#arguments.soapRequest.error.message#" detail="#arguments.soapRequest.error.detail#" />
			</cfif>

			<!--- parse SOAP request as XML --->
			<cfset stReturn.results = xmlParse(arguments.soapRequest.results.fileContent) />
			
			<!--- check for error codes --->
			<cfset stLocal.faultCode = xmlSearch(stReturn.results, "//*[name()='faultcode']") />
			<cfset stLocal.faultString = xmlSearch(stReturn.results, "//*[name()='faultstring']") />
			
			<!--- on fail grab fault code and info --->
			<cfif arraylen(stLocal.faultCode) and arraylen(stLocal.faultString)>
				<cfthrow message="#stLocal.faultCode[1].xmlText#" detail="#stLocal.faultString[1].xmlText#" />
			</cfif>
				 
			<!--- trap - return failure and error ---> 
			<cfcatch type="any">		
				<cfset stReturn.success = false />
				<cfset stReturn.error = cfcatch />
			</cfcatch>
		</cftry>
		
		<cfreturn stReturn />
	</cffunction>
		
	<cffunction name="brokerSoapRequest" access="private" output="false" returntype="any">
		<cfargument name="requestURL" type="string" required="true" />
		<cfargument name="requestSOAP" type="string" required="true" />
		<cfargument name="appendToEnvelope" type="string" required="false" default="" />
		<cfargument name="generateHeader" type="boolean" required="false" default="true" />
		<cfargument name="appendToHeader" type="string" required="false" default="" />
		
		<cfset var stLocal = structNew() />
	
		<!--- send  SOAP request --->
		<cfset stLocal.soapRequest = sendSoapRequest(requestURL = arguments.requestURL,
													requestSOAP = arguments.requestSOAP, 
													appendToEnvelope = arguments.appendToEnvelope,
													generateHeader = arguments.generateHeader,
													appendToHeader = arguments.appendToHeader) />
		<!--- format SOAP response --->
		<cfset stLocal.soapResponse = formatSoapResponse(stLocal.soapRequest) />
		
		<!--- if invalid session error and auto login is enabled --->
		<cfif not stLocal.soapResponse.success and findNoCase('INVALID_SESSION_ID',stLocal.soapResponse.error.detail) and getAutoLogin()>
			<!--- attempt login --->
			<cfset stLocal.stLogin = login() />
			<!--- throw when service is down to invalid credentials --->
			<cfif not stLocal.stLogin.success>
				<cfthrow object="#stLocal.stLogin.error#" />
			</cfif>
			<!--- re-send original request on successful login --->
			<cfset stLocal.soapRequest = sendSoapRequest(requestURL = arguments.requestURL,
														requestSOAP = arguments.requestSOAP, 
														appendToEnvelope = arguments.appendToEnvelope,
														generateHeader = arguments.generateHeader,
														appendToHeader = arguments.appendToHeader) />
			<cfset stLocal.soapResponse = formatSoapResponse(stLocal.soapRequest) />
		</cfif>
		
		<!--- throw on error from format response --->
		<cfif not stLocal.soapResponse.success>
			<cfthrow object="#stLocal.soapResponse.error#" />
		</cfif>
		
		<cfreturn stLocal.soapResponse.results />
	</cffunction>

	<!--- HELPERS --->
	<cffunction name="parseQueryXML" access="private" output="false" returntype="struct">
		<cfargument name="soapXML" type="xml" required="true" />
		<cfargument name="includeRelatedObject" type="boolean" required="true" />
		<cfargument name="batchSize" type="numeric" required="true" />
		
		<cfset var stLocal = structNew() />
		<cfset var stReturn = structNew() />
		<cfset stReturn.success = true />
		<cfset stReturn.results = '' />
		
		<cftry>
			<!--- get query size --->
			<cfset stLocal.totalRecords = xmlSearch(arguments.soapXML, "//*[name()='ns1:size']") />
			<!--- return size of query --->
			<cfset stReturn.size = val(stLocal.totalRecords[1].XmlText)>
			
			<!--- if valid size set values --->
			<cfif arrayLen(stLocal.totalRecords)>
				<cfset stLocal.records = xmlSearch(arguments.soapXML, "//*[name()='ns1:records']") />
				<!--- if records found build query --->
				<cfif arraylen(stLocal.records)>
					<!--- create list of columns for query --->
					<cfset stLocal.fieldList = structNew() />
					<!--- loop thru records to build query --->
					<cfloop from="1" to="#arrayLen(stLocal.records[1].xmlChildren)#" index="stLocal.iColumn">
						<cfset stLocal.fieldList[listLast(stLocal.records[1].xmlChildren[stLocal.iColumn].xmlName,':')] = '' />
					</cfloop>
					<cfset stReturn.results = queryNew(structKeyList(stLocal.fieldList)) />

					<!--- loop thru field children to build info into struct --->
					<cfloop from="1" to="#arrayLen(stLocal.records)#" index="stLocal.iRecord">
						<cfset queryAddRow(stReturn.results) />
						<!--- loop thru records to build query --->
						<cfloop from="1" to="#arrayLen(stLocal.records[stLocal.iRecord].xmlChildren)#" index="stLocal.iColValue">
							<!--- if query contains data from related object --->
							<cfif structKeyExists(stLocal.records[stLocal.iRecord].xmlChildren[stLocal.iColValue].xmlAttributes,'xsi:type')>
								<!--- create list of columns to add to query --->
								<cfset stLocal.subFieldList = structNew() />
								<!--- load fields and vals into struct --->
								<cfloop from="1" to="#arrayLen(stLocal.records[stLocal.iRecord].xmlChildren[stLocal.iColValue].xmlChildren)#" index="stLocal.iSubColumn">
									<cfset stLocal.subFieldList[listLast(stLocal.records[stLocal.iRecord].xmlChildren[stLocal.iColValue].xmlChildren[stLocal.iSubColumn].xmlName,':')] = stLocal.records[stLocal.iRecord].xmlChildren[stLocal.iColValue].xmlChildren[stLocal.iSubColumn].xmlText />
								</cfloop>
								<!--- build struct into query --->
								<cfif arguments.includeRelatedObject>
									<cfset querySetCell(stReturn.results,listLast(stLocal.records[stLocal.iRecord].xmlChildren[stLocal.iColValue].xmlName,':'),stLocal.subFieldList) />
								</cfif>
								<!--- build struct fields into query as columns --->
								<cfloop list="#structKeyList(stLocal.subFieldList)#" index="stLocal.iField">
									<!--- if prefix realted fields - append object name to field --->
									<cfset stLocal.subFieldName = listLast(stLocal.records[stLocal.iRecord].xmlChildren[stLocal.iColValue].xmlName,':') & '_' & stLocal.iField />
									<cfif not listFindNoCase(stReturn.results.columnList,stLocal.subFieldName)>
										<cfset queryAddColumn(stReturn.results,stLocal.subFieldName,arrayNew(1)) />
									</cfif>
									<cfset querySetCell(stReturn.results,stLocal.subFieldName,stLocal.subFieldList[stLocal.iField]) />
								</cfloop>
							<cfelse>
								<cfset querySetCell(stReturn.results,listLast(stLocal.records[stLocal.iRecord].xmlChildren[stLocal.iColValue].xmlName,':'),stLocal.records[stLocal.iRecord].xmlChildren[stLocal.iColValue].xmlText) />				
							</cfif>
						</cfloop>
					</cfloop>
				</cfif>
				
				<!--- check for query locator --->
				<cfset stLocal.aQueryLocator = xmlSearch(arguments.soapXML, "//*[name()='ns1:queryLocator']") />

				<cfif arrayLen(stLocal.aQueryLocator) and listLen(stLocal.aQueryLocator[1].xmlText,'-')>
					<cfset stReturn.queryLocator = listFirst(stLocal.aQueryLocator[1].xmlText,'-') />
					<cfset stReturn.locatorChunk = listLast(stLocal.aQueryLocator[1].xmlText,'-') />
					<cfset stReturn.startRow = (stReturn.locatorChunk - arguments.batchSize) + 1 />
					<cfset stReturn.batchSize = arguments.batchSize />
				</cfif>
			</cfif>

			<!--- trap - return failure and error ---> 
			<cfcatch type="any">
				<cfset stReturn.success = false />
				<cfset stReturn.error = cfcatch />
			</cfcatch>
		</cftry>
		
		<cfreturn stReturn />
	</cffunction>
	
	<cffunction name="validate" access="private" output="false" returntype="boolean">
		<cfif not structKeyExists(variables,'instance')>
			<cfthrow message="Object not initialized" detail="Create an instance of object with init() method" type="salesForceCFC" />
		<cfelseif not len(getSessionId())>
			<cfthrow message="Invalid Session Id" detail="Session Id is empty. Use login() method." type="salesForceCFC" />
		<cfelseif not len(getServerURL())>
			<cfthrow message="Invalid Server URL" detail="Server URL is empty. Use login() method." type="salesForceCFC" />
		</cfif>
		<cfreturn true />
	</cffunction>
	
	<cffunction name="buildAssignmentHeader" access="private" output="false" returntype="string">
		<cfargument name="assignmentHeaderId" type="string" required="false" />
		<cfargument name="useDefaultRule" type="boolean" required="false" />
		
		<cfset var assignmentHeader = '' />
		
		<cfsavecontent variable="assignmentHeader">
			<cfoutput>
				<urn:AssignmentRuleHeader>
					<cfif structKeyExists(arguments,'assignmentRuleId')>
						<urn:assignmentRuleId>#arguments.assignmentHeaderId#</urn:assignmentRuleId>
					<cfelseif structKeyExists(arguments,'useDefaultRule')>
						<urn:useDefaultRule>#arguments.useDefaultRule#</urn:useDefaultRule>
					</cfif>
				</urn:AssignmentRuleHeader>
			</cfoutput>
		</cfsavecontent>
			
		<cfreturn trim(assignmentHeader) />
	</cffunction>
	
	<cffunction name="buildEmailHeader" access="private" output="false" returntype="string">
		<cfargument name="triggerAutoResponseEmail" type="boolean" required="false" />
		<cfargument name="triggerOtherEmail" type="boolean" required="false" />
		<cfargument name="triggerUserEmail" type="boolean" required="false" />
		
		<cfset var emailHeader = '' />
		
		<cfsavecontent variable="emailHeader">
			<cfoutput>
				<urn:EmailHeader>
					<cfif structKeyExists(arguments,'triggerAutoResponseEmail')>
						<urn:triggerAutoResponseEmail>#arguments.triggerAutoResponseEmail#</urn:triggerAutoResponseEmail>
					<cfelseif structKeyExists(arguments,'triggerOtherEmail')>
						<urn:triggerOtherEmail>#arguments.triggerOtherEmail#</urn:triggerOtherEmail>
					<cfelseif structKeyExists(arguments,'triggerUserEmail')>
						<urn:triggerUserEmail>#arguments.triggerUserEmail#</urn:triggerUserEmail>
					</cfif>
				</urn:EmailHeader>
			</cfoutput>
		</cfsavecontent>
			
		<cfreturn trim(emailHeader) />
	</cffunction>
	
	<cffunction name="buildQueryOptions" access="private" output="false" returntype="string">
		<cfargument name="batchSize" type="numeric" required="true" />
		
		<cfset var queryHeader = '' />
		
		<cfsavecontent variable="queryHeader">
			<cfoutput>
				<urn:QueryOptions>
					<urn:batchSize>#arguments.batchSize#</urn:batchSize>
				 </urn:QueryOptions>
			</cfoutput>
		</cfsavecontent>
			
		<cfreturn trim(queryHeader) />
	</cffunction>
	
</cfcomponent>
<cfsetting showdebugoutput="false" requesttimeout="600" />

<cfparam name="form.username" default="" />
<cfparam name="form.password" default="" />
<cfparam name="form.persist" default="false" />

<html>
	<head>
		<title>SalesForceCFC Demo</title>
		<style>
			body{
				font-family:arial;
				font-size:12px;
			}
		</style>
	</head>
<body>
<h1>SalesForceCFC - Test Form</h1>
<cfform name="testForm" method="post">
	Username:<br />
	<cfinput type="text" name="username" required="true" message="Username is required" value="#form.username#" /><br />
	<br />Password:<br />
	<cfinput type="password" name="password" required="true" message="Password is required" value="#form.password#" /><br />
	<br />Persist in Session:<br />
	<input type="checkbox" name="persist" value="true" <cfif form.persist>checked</cfif> /><br />
	<br />
	<input type="submit" value="Run Test" />
</cfform>

<br />
<cfif len(form.username) and len(form.password)>
<h1>Results</h1>
	<!--- persist --->
	<cfif form.persist and not structKeyExists(session,'oSF')>
		<cfset session.oSF = createObject('component','salesforce').init(form.username,form.password) />
		<cfset oSF = session.oSF />
	<cfelse>
		<cfset oSF = createObject('component','salesforce').init(form.username,form.password) />
	</cfif>
	
	Version:<br />
	<cfdump var="#oSF.getVersion()#">
	<br /><br />
	login url:<br />
	<cfdump var="#oSF.getLoginURL()#">
	<br /><br />
	
	login results:<br />
	<cfset stLogin = oSF.login() />
	<cfdump var="#stLogin#">
	<br /><br />
	
	<cfif not stLogin.success>
		<cfabort>
	</cfif>

<!--- 	<cfset TestQuery = osf.queryObject("SELECT Account.Name, (SELECT Contact.LastName FROM Account.Contacts) FROM Account Where Account.Name = 'testsub'")>
	<cfdump var="#TestQuery#">
	<cfabort> --->
	SOAP Server URL:<br />
	<cfdump var="#oSF.getServerURL()#">
	<br /><br />
	
	Session Id:<br />
	<cfdump var="#oSF.getSessionId()#">
	<br /><br />
	
	User Info:<br />
	<cfdump var="#oSf.getUserInfo()#">
	
	Server TimeStamp:<br />
	<cfdump var="#oSf.getServerTimestamp()#">

	Describe Global - List of Objects:<br />
	<cfdump var="#oSF.describeGlobal()#">
	<br /><br />

	Save / Create - Lead - Apply Default Assignment Rule:<br />
	<cfset stLead = structNew() />
	<cfset stLead.email = 'test@here.com' />
	<cfset stLead.lastName = 'Test' />
	<cfset stLead.company = 'TestCo' />
	<cfset oSaveLead = oSF.saveObject(objectType='Lead',objectDataStruct=stLead,soapAction='create',appendAssignmentHeader=true,useDefaultRule=true) />
	<cfdump var="#oSaveLead#">
	<br /><br />
	
	Save / Create - Multiple Leads<br />
	<cfset aLeads = arrayNew(1)>
	
	<cfset stLead = structNew() />
	<cfset stLead._objectType = 'Lead'>
	<cfset stLead.email = 'test3@here.com' />
	<cfset stLead.lastName = 'Test3' />
	<cfset stLead.company = 'TestCo' />
	<cfset arrayAppend(aLeads,duplicate(stLead)) />
	
	<cfset stLead.email = 'test2@here.com' />
	<cfset stLead.lastName = 'Test2' />
	<cfset arrayAppend(aLeads,duplicate(stLead)) />
	
	<cfset structDelete(stLead,'email')>
	<cfset structDelete(stLead,'lastName')>
	<cfset structDelete(stLead,'company')>
	<cfset arrayAppend(aLeads,duplicate(stLead)) />
	
	<cfset oSaveLeads = oSF.saveObject(objectArray=aLeads,soapAction='create') />
	<cfdump var="#oSaveLeads#">
	<br /><br />

	Describe Account Object:<br />
	<cfset oAccount = oSF.describeObject('Account') />
	<cfdump var="#oAccount#">
	<br /><br />
	
	Save / Create - Account - name = 'salesForceCFC test' :<br />
	<cfset stAccount = structNew() />
	<cfset stAccount.name = 'SalesForceCFC test' />
	<cfset oSaveAccount = oSF.saveObject('Account',stAccount,'create') />
	<cfdump var="#oSaveAccount#">
	<br /><br />
	
	<!--- use to inflate accounts for pagination test --->
	<cfloop from="1" to="20" index="i"> 
		Loop Save / Create - Account - name = 'SalesForceCFC test(index)' :<br />
		<cfset stAccount = structNew() />
		<cfset stAccount.name = 'SalesForceCFC test#i#' />
		<cfset oSaveAccount = oSF.saveObject('Account',stAccount,'create') />
		<cfdump var="#oSaveAccount#">
		<br /><br />
	</cfloop>
	
	Query Accounts (SELECT Id, Name, createdDate FROM Account WHERE Name like 'SalesForceCFC%' order by createdDate desc):<br />
	<cfset qAccount = oSF.queryObject("SELECT Id, Name, createdDate FROM Account WHERE Name like 'SalesForceCFC%' order by createdDate desc") />
	<cfdump var="#qAccount#">
	<br /><br />
	
	Save / Create - Opportunity - name = 'Test Opportunity' to Account:<br />
	<cfset stOpportunity = structNew() />
	<cfset stOpportunity.AccountId = oSaveAccount.results[1].id />
	<cfset stOpportunity.Name = 'SalesForceCFC Test Opportunity' />
	<cfset stOpportunity.StageName = 'Prospecting' />
	<cfset stOpportunity.CloseDate = dateFormat(now(),'yyyy-mm-dd') />
	<cfset oSaveOpportunity = oSF.saveObject('Opportunity',stOpportunity,'create') />
	<cfdump var="#oSaveOpportunity#">
	<br /><br />
	
	Query Opportunites (SELECT Id, Name, createdDate FROM Opportunity WHERE Name like 'SalesForceCFC%' order by createdDate desc):<br />
	<cfset qOpportunity = oSF.queryObject("SELECT Id, Name, createdDate FROM Opportunity WHERE Name like 'SalesForceCFC%' order by createdDate desc") />
	<cfdump var="#qOpportunity#">
	<br /><br />
	
	Update - Account - name = 'SalesForceCFC test':<br />
	<cfset stAccount = structNew() />
	<cfset stAccount.id = oSaveAccount.results[1].id />
	<cfset stAccount.name = 'SalesForceCFC test_udpate' />
	<cfset oUpdateAccount = oSF.saveObject('Account',stAccount,'update') />
	<cfdump var="#oUpdateAccount#">
	<br /><br />
	
	Query Accounts (SELECT Id, Name, createdDate FROM Account WHERE Name like 'SalesForceCFC%' order by createdDate desc):<br />
	<cfset qAccount = oSF.queryObject("SELECT Id, Name, createdDate FROM Account WHERE Name like 'SalesForceCFC%' order by createdDate desc") />
	<cfdump var="#qAccount#">
	<br /><br />

	Relational Query (parent-to-child relationship) (SELECT Opportunity.Id, Opportunity.Name, Opportunity.StageName,Opportunity.Account.Name FROM Opportunity WHERE Account.Name like 'SalesForceCFC%' order by createdDate desc):<br />
	<cfset qAccount = oSF.queryObject("SELECT Opportunity.Id, Opportunity.Name, Opportunity.StageName, Opportunity.Account.Name FROM Opportunity WHERE Account.Name like 'SalesForceCFC%' order by createdDate desc",true) />
	<cfdump var="#qAccount#">
	<br /><br />
			
	Retrieve Created Account:<br />
	<cfset oRetrieveAccount = oSF.retrieveObject('Account','Id,Name,createdDate',oSaveAccount.id) />
	<cfdump var="#oRetrieveAccount#">
	<br /><br />
	
	Delete Opportunity:<br />
	<cfset oDeleteOpportunity = oSF.deleteObject(oSaveOpportunity.id) />
	<cfdump var="#oDeleteOpportunity#">
	<br /><br />
	
	Query Opportunites (SELECT Id, Name, createdDate FROM Opportunity WHERE Name like 'SalesForceCFC%' order by createdDate desc):<br />
	<cfset qOpportunity = oSF.queryObject("SELECT Id, Name, createdDate FROM Opportunity WHERE Name like 'SalesForceCFC%' order by createdDate desc") />
	<cfdump var="#qOpportunity#">
	<br /><br />
	
	Delete Account:<br />
	<cfset oDeleteAccount = oSF.deleteObject(oRetrieveAccount.results[1].id) />
	<cfdump var="#oDeleteAccount#">
	<br /><br />
	
	Query Accounts (SELECT Id, Name, createdDate FROM Account WHERE Name like 'SalesForceCFC%' order by createdDate desc):<br />
	<cfset qAccount = oSF.queryObject("SELECT Id, Name, createdDate FROM Account WHERE Name like 'SalesForceCFC%' order by createdDate desc") />
	<cfdump var="#qAccount#">
	<br /><br />
	
	Query Accounts with pagination / requires more then 200 accounts (SELECT Id, Name, createdDate FROM Account ORDER BY NAME):<br />
	<cfset qAccountPaged = oSF.queryObject(queryString = "SELECT Id, Name, createdDate FROM Account ORDER BY NAME", batchsize = 200) />
	<cfdump var="#qAccountPaged#">
	<br /><br />
	
	<cfif structKeyExists(qAccountPaged,'queryLocator')>
		Paged query result:
		<cfset qAccountMore = oSF.queryMore(queryLocator = qAccountPaged.queryLocator, startRow = qAccountPaged.batchSize + 1, batchsize = 200) />
		<cfdump var="#qAccountMore#">
		<br /><br />
		Query Accounts with pagination disabled (SELECT Id, Name, createdDate FROM Account ORDER BY NAME):<br />
		<cfset qAccountUnPaged = oSF.queryObject(queryString = "SELECT Id, Name, createdDate FROM Account ORDER BY NAME", disablePagination = true) />
		<cfdump var="#qAccountUnPaged#">
		<br /><br />
	<cfelse>
		Not enough accounts to run pagination demo. There are only <cfoutput>#qAccountPaged.results.recordCount#</cfoutput> accounts, you need more then 200.<br />
		Uncomment loop in testForm.cfm and set to a number greater then what you need here.
		<br /><br />
	</cfif>
	
	<!--- cleanup if you had errors along the way and created mulitple test accounts --->
	<cfif isQuery(qAccount.results) and qAccount.results.recordCount>
		Retrieve Queried Accounts (multiple - if present):<br />
		<cfset oRetrieveAccounts = oSF.retrieveObject('Account','Id,Name,createdDate',valueList(qAccount.results.id)) />
		<cfdump var="#oRetrieveAccounts#">
		<br /><br />
		
		Delete All 'SalesForceCFC' accounts:<br />
		<cfset oDeleteAccount = oSF.deleteObject(valueList(qAccount.results.id)) />
		<cfdump var="#oDeleteAccount#">
		<br /><br />
		
		Query Accounts (SELECT Id, Name, createdDate FROM Account WHERE Name like 'SalesForceCFC%' order by createdDate desc):<br />
		<cfset qAccount = oSF.queryObject("SELECT Id, Name, createdDate FROM Account WHERE Name like 'SalesForceCFC%' order by createdDate desc") />
		<cfdump var="#qAccount#">
		<br /><br />
	</cfif>
	
	<!--- cleanup if you had errors along the way and created mulitple test opportunites --->
	<cfif isQuery(qOpportunity.results) and qOpportunity.results.recordCount>
		Delete All 'SalesForceCFC' Opportunities:<br />
		<cfset oDeleteOpportunity = oSF.deleteObject(valueList(qOpportunity.results.id)) />
		<cfdump var="#oDeleteAccount#">
		<br /><br />
					
		Query Opportunites (SELECT Id, Name, createdDate FROM Opportunity WHERE Name like 'SalesForceCFC%' order by createdDate desc):<br />
		<cfset qOpportunity = oSF.queryObject("SELECT Id, Name, createdDate FROM Opportunity WHERE Name like 'SalesForceCFC%' order by createdDate desc") />
		<cfdump var="#qOpportunity#">
		<br /><br />
	</cfif>
</cfif>
</body>
</html>
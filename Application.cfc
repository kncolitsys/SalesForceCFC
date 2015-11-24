<cfcomponent displayname="Application" output="false">

	<cfscript>
		this.name 				= "SalesForce";
		this.clientmanagement 	= "false";
		this.sessionmanagement 	= "true";
		this.applicationtimeout	= CreateTimeSpan(1,0,0,0);
		this.sessiontimeout 	= CreateTimeSpan(0,0,30,0);
		this.setclientcookies 	= "false";
	</cfscript>
	
	<!--- on Application Start --->
	<cffunction name="onApplicationStart">
	</cffunction>
	
	<!--- on Session Start --->
	<cffunction name="onSessionStart">
	</cffunction>
	
	<!--- on Session End --->
	<cffunction name="onSessionEnd">
	</cffunction>
	
	<!--- on Request Start --->
	<cffunction name="onRequestStart">	
		<cfif structKeyExists(url,'reinit')>
			<cfobjectcache action="clear" />
			<cfset structClear(application) />
			<cfset structClear(session) />
			<cfset this.onApplicationStart() />
		</cfif>
	</cffunction>
	
	<!--- on Request End --->
	<cffunction name="onRequestEnd">
	</cffunction>
	
</cfcomponent>
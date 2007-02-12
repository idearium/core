<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/webskin/multiPageNav.cfm,v 1.4 2004/04/12 12:11:39 brendan Exp $
$Author: brendan $
$Date: 2004/04/12 12:11:39 $
$Name: milestone_3-0-1 $
$Revision: 1.4 $

|| DESCRIPTION || 
$DESCRIPTION: Displays simple navigation for multi page branches$

|| DEVELOPER ||
$DEVELOPER:Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: objectid (objectid of current template)$ 
$in: display (optional - boolean for displaying standard output or just return query)$ 
$in: displayPageNumbers (optional - boolean for displaying page numbers in navigation)$ 
$in: displayNextPrevious (optional - boolean for displaying next and previous pages)$ 
$in: displayNextPreviousTitle (optional - boolean for displaying next and previous title as link, otherwise word next/previous used)$ 
$in: class (optional - css class used for divs for display)$ 
$in: r_qLinks (optional - variable for return query)$ 
$in: seperator (optional - value to use to seperate page links)$ 
$in: previousArrow (optional - value to use for previous page arrow)$ 
$in: nextArrow (optional - value to use for next page arrow)$ 
--->

<cfsetting enablecfoutputonly="yes">

<cfimport taglib="/farcry/farcry_core/fourq/tags/" prefix="q4">

<!--- required attributes --->
<cfparam name="attributes.objectId">

<!--- optional attributes --->
<cfparam name="attributes.display" default="true">
<cfparam name="attributes.displayPageNumbers" default="true">
<cfparam name="attributes.displayNextPrevious" default="true">
<cfparam name="attributes.displayNextPreviousTitle" default="true">
<cfparam name="attributes.class" default="multiPage">
<cfparam name="attributes.r_qlinks" default="r_qlinks">
<cfparam name="attributes.seperator" default="&nbsp;">
<cfparam name="attributes.previousArrow" default="&laquo;">
<cfparam name="attributes.nextArrow" default="&raquo;">

<cffunction name="addPage" output="false">
	<cfargument name="objectid" required="Yes" type="UUID">

	<cfset var error= false>
	<cfset var bSuccess= false>
	<cfset var stPage= "">
	
	<!--- get page details --->
	<cftry>
		<q4:contentobjectget objectID="#arguments.objectid#" r_stobject="stPage">

		<!--- check object exists --->
		<cfcatch type="any">
			<!--- write out error in html commments --->
			<cfoutput><cfdump var="#cfcatch#"></cfoutput>
			<cfset error = true>
		</cfcatch>
	</cftry>
	<cfif stPage.typename eq "dmHTML" and not error AND request.mode.lValidStatus CONTAINS stPage.Status>
		<!--- add row to query --->
		<cfset queryAddRow(qPages, 1)>
		<cfset querySetCell(qPages, "objectid", arguments.objectid)>
		<cfset querySetCell(qPages, "title", stPage.title)>
		<cfset bSuccess = true>
	</cfif>
	
	<cfreturn bSuccess>
</cffunction>

<!--- get nav parent details --->
<q4:contentobjectget objectID="#request.navid#" r_stobject="stParent">

<!--- create query --->
<cfset qPages = queryNew("objectid, title")>

<!--- check if only next/previous required or all pages --->
<cfif attributes.displayPageNumbers>
	<!--- get all pages under nav parent --->
	<cfloop from="1" to="#arrayLen(stParent.aObjectIds)#" index="item">
		<!--- add item to page listing query --->
		<cfset addPage(stParent.aObjectIds[item])>
	</cfloop>	
<cfelse>
	<!--- just get next previous information. First work out current position --->
	<cfloop from="1" to="#arrayLen(stParent.aObjectIds)#" index="item">
		<cfif stParent.aObjectids[item] eq attributes.objectid>
			<cfset current = item>
			<cfbreak>
		</cfif>
	</cfloop>
	<!--- try to add previous page --->
	<cfloop from="#current-1#" to="1" index="prevItem" step="-1">
		<cfset bSuccess = addPage(stParent.aObjectIds[prevItem])>
		<cfif bSuccess>
			<cfbreak>
		</cfif>
	</cfloop>
	<!--- try to add current page --->
	<cftry>
		<cfset addPage(stParent.aObjectIds[current])>
		<cfcatch></cfcatch>
	</cftry>
	<!--- try to add next page --->
	<cfloop from="#current+1#" to="#arrayLen(stParent.aObjectIds)#" index="nextItem">
		<cfset bSuccess = addPage(stParent.aObjectIds[nextItem])>
		<cfif bSuccess>
			<cfbreak>
		</cfif>
	</cfloop>
</cfif>

<!--- check if user wants links to be displayed or just returned in a query --->
<cfif attributes.display>
	<cfoutput><div class="#attributes.class#"></cfoutput>
	
	<!--- show previous page --->
	<cfif attributes.displayNextPrevious>
		<!--- loop over pages --->
		<cfloop query="qPages">
			<!--- if current page, display previous --->
			<cfif objectid eq attributes.objectid and currentRow gt 1>
				<!--- display link --->
				<cfoutput><a href="index.cfm?objectid=#qPages.objectid[currentRow-1]#">#attributes.previousArrow# <cfif attributes.displayNextPreviousTitle>#qPages.title[currentRow-1]#<cfelse>Previous</cfif></a> #attributes.seperator# </cfoutput>
			</cfif>
		</cfloop>	
	</cfif>
	
	<!--- show page numbers as links --->
	<cfif attributes.displayPageNumbers>
		<!--- loop over pages --->
		<cfloop query="qPages">
			<!--- check there is an object in query --->
			<cfif len(objectid)>
				<!--- check not current page, if so don't link --->
				<cfif objectid neq attributes.objectId>
					<!--- display link --->
					<cfoutput><a href="index.cfm?objectid=#objectid#"></cfoutput>
				</cfif>
				<!--- check if there is a title --->
				<cfoutput>#currentRow#</cfoutput>
				<!--- check not current page, if so don't link --->
				<cfif objectid neq attributes.objectId>
					<cfoutput></a></cfoutput>
				</cfif>
				<cfoutput> #attributes.seperator# </cfoutput>
			</cfif>
		</cfloop>
	</cfif>
	
	<!--- show next page --->
	<cfif attributes.displayNextPrevious>
		<!--- loop over pages --->
		<cfloop query="qPages">
			<!--- if current page, display next --->
			<cfif objectid eq attributes.objectid and currentRow neq qPages.recordcount>
				<!--- display link --->
				<cfoutput><a href="index.cfm?objectid=#qPages.objectid[currentRow+1]#"><cfif attributes.displayNextPreviousTitle>#qPages.title[currentRow+1]#<cfelse>Next</cfif> #attributes.nextArrow# </a></cfoutput>
			</cfif>
		</cfloop>	
	</cfif>
	
	<cfoutput></div></cfoutput>
<cfelse>
	<!--- return query to calling page --->
	<cfset "caller.#attributes.r_qlinks#" = qPages>
</cfif>

<cfsetting enablecfoutputonly="no">

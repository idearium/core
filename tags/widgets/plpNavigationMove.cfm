<cfimport taglib="/farcry/core/tags/farcry" prefix="farcry" />
<farcry:deprecated message="widgets tag library is deprecated; please use formtools." />


<!--- @@Copyright: Daemon Pty Limited 2002-2008, http://www.daemon.com.au --->
<!--- @@License:
    This file is part of FarCry.

    FarCry is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    FarCry is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with FarCry.  If not, see <http://www.gnu.org/licenses/>.
--->
<!---
|| VERSION CONTROL ||
$Header: /cvs/farcry/core/tags/widgets/plpNavigationMove.cfm,v 1.1 2005/06/03 10:06:04 geoff Exp $
$Author: geoff $
$Date: 2005/06/03 10:06:04 $
$Name: milestone_3-0-1 $
$Revision: 1.1 $

|| DESCRIPTION || 
Works out where to go next during plp

|| DEVELOPER ||
Brendan Sisson (brendan@daemon.com.au)

|| ATTRIBUTES ||
in: 
out:
--->
<cfsetting enablecfoutputonly="yes">

<!--- user is going to 'next' page --->
<cfif IsDefined("CALLER.FORM.Submit")>
	<cfscript>
		CALLER.thisstep.isComplete = 1;
		CALLER.thisstep.advance = 1;
	</cfscript>

<!--- user 'cancels' plp --->
<cfelseif isdefined("caller.form.cancel")>
	<!--- try to unlock object --->
	<cftry>
		<cfinvoke component="#application.packagepath#.farcry.locking" method="unlock" returnvariable="unlockRet">
			<cfinvokeargument name="objectId" value="#caller.output.objectid#"/>
			<cfinvokeargument name="typename" value="#caller.output.typename#"/>
		</cfinvoke>
		<cfcatch>
			<cfset request.cfdumpinited = false>
			<cfdump var="#cfcatch#">
		</cfcatch>
	</cftry>  
	<!--- if dmHTML update tabs --->
	<cfif caller.output.typename eq "dmHTML">
		<script>
			document.getallbyId.siteEditOverview.className = activeTabClass;
		</script>
	</cfif>
	<!--- delete the current plp file this will ensure that when user goes back into plp, it will be regarded as 'new'--->
	<!--- currently only storage type is 'file' --->
	<cfswitch expression="#CALLER.attributes.storage#">
		<cfcase value="file">
			<cftry>
				<cflock name="plpfile" timeout="10" throwontimeout="Yes" type="EXCLUSIVE">
					<cffile 
						action="DELETE" 
						file="#CALLER.attributes.storagedir#/#CALLER.attributes.owner#.plp">
				</cflock>
				<cfcatch type="Any">
				</cfcatch>
			</cftry>
		</cfcase>
		<cfcase value="db">
			<!--- ///	todo:	/// --->
		</cfcase>
	</cfswitch>
	<!--- relocate to cancel location --->
	<cfif structkeyExists(CALLER.attributes, "cancelLocation")>
		<cflocation url="#CALLER.attributes.cancelLocation#" addtoken="no">
	<cfelse>
		<cfoutput><h3>PLP Wizard Cancelled</h3></cfoutput><cfabort>
	</cfif>
	
<cfelseif isdefined("caller.form.save")>
	<!--- save plp and return to current step --->
	<cfscript>
		CALLER.thisstep.isComplete = 1;
		CALLER.thisstep.nextStep = CALLER.thisstep.name;
		CALLER.thisstep.advance = 1;
	</cfscript>
	
<!--- user is going 'back' to a page --->
<cfelseif IsDefined("CALLER.FORM.Back")>
	<cfscript>
		PrevStep = "";
	</cfscript>
	<cfloop index="i" from="1" to="#ArrayLen(CALLER.stPLP.Steps)#">
		<cfscript>
		if (CALLER.thisstep.name EQ CALLER.stPLP.Steps[i].name AND Len(PrevStep)) {
			CALLER.thisstep.nextStep = PrevStep;
		}
		PrevStep = CALLER.stPLP.Steps[i].name;
		</cfscript>
	</cfloop>
	<cfscript>
		CALLER.thisstep.isComplete = 1;
		CALLER.thisstep.advance = 1;
	</cfscript>
<cfelseif IsDefined("CALLER.FORM.QuickNav") AND CALLER.FORM.QuickNav EQ "Yes">
	<cfscript>
		CALLER.thisstep.nextStep = CALLER.FORM.Navigation;
		CALLER.thisstep.advance = 1;
		CALLER.thisstep.isComplete = 1;
	</cfscript>
<cfelseif isdefined("url.step")>
	<cfscript>
		CALLER.thisstep.isComplete = 1;
		CALLER.thisstep.nextStep = url.step;
		CALLER.thisstep.advance = 1;
	</cfscript>
</cfif>

<cfsetting enablecfoutputonly="no">
<cfsetting enablecfoutputonly="Yes">
<cfprocessingDirective pageencoding="utf-8">
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
$Header: /cvs/farcry/core/webtop/admin/coapiTypes.cfm,v 1.26 2005/10/13 09:14:53 geoff Exp $
$Author: geoff $
$Date: 2005/10/13 09:14:53 $

$Name: milestone_3-0-1 $
$Revision: 1.26 $

|| DESCRIPTION || 
$Description: Management interface for COAPI types. 
	Legacy display is nasty as.  Need to rebuild this reporting tool 
	at some point. No time just now GB $

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au)$
--->

<!--- import tag libraries --->
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin" />
<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" />
<cfimport taglib="/farcry/core/tags/extjs/" prefix="extjs" />
<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" />
<cfimport taglib="/farcry/core/tags/security/" prefix="sec" />


<!--- Add the extjs iframe dialog to the head --->
<skin:loadJS id="jquery" />
<skin:loadJS id="jquery-ui" />
<skin:loadCSS id="jquery-ui" />


<sec:CheckPermission error="true" permission="AdminCOAPITab">
	<!--- environment variables --->
	<cfparam name="FORM.action" default="" type="string">
	
	<!--- component documentation url... --->
	<cfif structKeyExists(application.config.general,"componentDocURL") AND len(application.config.general.componentDocURL)>
		<cfset documentURL=application.config.general.componentDocURL>
	<cfelse>
		<cfset documentURL="/CFIDE/componentutils/componentdetail.cfm">
	</cfif>
	
	
	
	<cfscript>
	/* COAPI Evolution Actions */
		alterType = createObject("component","#application.packagepath#.farcry.alterType");
		alterType.refreshAllCFCAppData();
		if (isDefined("URL.deploy"))
			alterType.deployCFC(typename=url.deploy);
		switch(form.action){
			case "deleteproperty":
			 {
				alterType.deleteProperty(typename=form.typename,srcColumn=form.property);
				alterType.refreshCFCAppData(typename=form.typename);
				break;
			 }
			 case "droparraytable":
			 {
			 	alterType.dropArrayTable(typename=form.typename,property=form.property);
				alterType.refreshCFCAppData(typename=form.typename);
				break;
			 }
			 case "deployproperty":
			 {
			 	propMetadata = application.types[form.typename].stProps[form.property].metadata;
				//is the property nullable
				isNullable = false;
				if( isDefined('propMetadata.required') AND NOT propMetadata.required)
					isNullable = true;
				//do we have a default value
				defaultVal = "";
				if ( isDefined('propMetadata.default'))
					defaultVal = propMetadata.default;				
				alterType.addProperty(typename=form.typename,srcColumn=form.property,srcColumnType=alterType.getDataType(application.types[form.typename].stProps[form.property].metadata.type),bNull=isNullable,stDefault=defaultVal);
			 	alterType.refreshCFCAppData(typename=form.typename);
				break;
			 }	
			 case "deployarrayproperty":
			 {
			 	alterType.deployArrayProperty(typename=form.typename,property=form.property);
				alterType.refreshCFCAppData(typename=form.typename);
				break;
			 }	
			 case "renameproperty":
			 {
			 	alterType.alterPropertyName(typename=form.typename,srcColumn=form.property,destColumn=form.renameto,colType=form.colType,colLength=form.colLength);
				alterType.refreshCFCAppData(typename=form.typename);
				break;
			 }
			  case "repairproperty":
			 {
			 	alterType.repairProperty(typename=form.typename,srcColumn=form.property,srcColumnType=alterType.getDataType(application.types[form.typename].stProps[form.property].metadata.type,true));
				alterType.refreshCFCAppData(typename=form.typename);
				break;
			 }
			 default:
			 {	//do nothing
			 
			 }
		 }
		//if (NOT application.dbType is "ora") //temp mess until oracle compatability introduced
			stTypes = alterType.buildDBStructure();
	</cfscript>
	
	<!--- build page output --->
	<admin:header title="COAPI Types" writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">	
	
	<skin:htmlHead library="extJS" />
	
		<!--- TODO: i18n --->
		<h3>Custom Content Types</h3>
		<table class="table-5" cellspacing="0">
		<tr>
			<th>#application.rb.getResource("coapiadmin.labels.integrity@text","Integrity")#</th>
			<th>#application.rb.getResource("coapiadmin.labels.component@text","Component")#</th>
			<th>#application.rb.getResource("coapiadmin.labels.component@text","Component")#</th>
			<!--- TODO: i18n remove property label --->
			<!--- <th>#application.rb.getResource("deployed")#</th> --->
			<th>#application.rb.getResource("coapiadmin.labels.deploy@text","Deploy")#</th>
			<!--- TODO: i18n --->
			<!--- <th style="border-right:none">Permission Set</th> --->
			<!--- TODO: i18n --->
			<th style="border-right:none">#application.rb.getResource("coapiadmin.labels.cfdocs@text","Doc")#</th>
		</tr>
	</cfoutput>
	
	<cfset componentList = ListSort(StructKeyList(application.types),"textnocase") />	
	<cfloop list="#componentList#" index="componentname">
	<cfif application.types[componentname].bcustomtype>
		<cfset displayname = componentName />
		<cfif structkeyexists(application.types[componentname],"displayName")>
			<cfset displayname = application.types[componentname].displayname />
		</cfif>
		<cfscript>
			if (structKeyExists(stTypes,componentname))
				stConflicts = alterType.compareDBToCFCMetadata(typename=componentname,stDB=stTypes['#componentname#']);
			else
				stConflicts['#componentname#'] = structNew();
		</cfscript>
		<cfoutput>
			<tr <cfif alterType.isCFCConflict(stConflicts=stConflicts,typename=componentName)>style='color:##000;'</cfif>>
				<td>
					<cfif alterType.isCFCConflict(stConflicts=stConflicts,typename=componentName)>
						<img src="#application.url.farcry#/images/no.gif" /> #application.rb.getResource("coapiadmin.labels.seeBelow@text","See Below")#
					<cfelse>
						<img src="#application.url.farcry#/images/yes.gif" />
					</cfif>
				</td>
				<cfif structkeyexists(application.types[componentname], "hint")>
					<td><span title="#application.types[componentname].hint#">#displayname#</span></td>
				<cfelse>
					<td>#displayname#</td>
				</cfif>
				<td>#componentName#</td>
				<td>
					<cfif NOT alterType.isCFCDeployed(typename=componentName)>
						<a href="#CGI.SCRIPT_NAME#?deploy=#componentName#">#application.rb.getResource("coapiadmin.buttons.deploy@label","Deploy")#</a>
					<cfelse>
						<ft:button type="button" value="Scaffold" onclick="$j('##dialog').find('iframe').attr('src','#application.url.farcry#/admin/scaffold.cfm?typename=#componentName#&iframe=1').end().dialog({ autoOpen:true,width:500,height:400,title:'Scaffold #displayname#',modal:true });" />
					</cfif>
				</td>
				<!--- <td><em>Create Permissions</em>
				check application.types[componentname].permissionset exists
				if not assume typename* --->
				</td>
				<td style="border-right:none">
				<ft:button value="Doc" url="#variables.documentURL#?component=#application.types[componentname].name#" />
				</td>
			</tr>
		</cfoutput>
		<cfscript>
		// output dreadful interface for COAPI evolution
			if (structKeyExists(stConflicts,'cfc') AND structKeyExists(stConflicts['cfc'],componentName))
				{
				writeoutput("<tr><td colspan='5' style='background-color:##F9E6D4;border-right:none'><div id='#componentname#_report'>");
				alterType.renderCFCReport(typename=componentname,stCFC=stConflicts['cfc'][componentname]);
				writeoutput("</div></td></tr>");		
				}
			if (structKeyExists(stConflicts,'database') AND structKeyExists(stConflicts['database'],componentName))
				{
				writeoutput("<tr><td colspan='5' style='background-color:##F9E6D4;border-right:none'><div id='#componentname#_report'>");
				alterType.renderDBReport(typename=componentname,stDB=stConflicts['database'][componentname]);
				writeoutput("</div></td></tr>");		
				}
		</cfscript>
	</cfif>
	</cfloop>
	<cfoutput></table></cfoutput>
	
	<cfoutput>
		<h3>#application.rb.getResource("coapiadmin.headings.typeClasses@text","Type Classes")#</h3>
		<table class="table-5" cellspacing="0">
		<tr>
			<th>#application.rb.getResource("coapiadmin.labels.integrity@label","Integrity")#</th>
			<th>#application.rb.getResource("coapiadmin.labels.component@label","Component")#</th>
			<th>#application.rb.getResource("coapiadmin.labels.component@label","Component")#</th>
			<!--- TODO: i18n remove property label --->
			<!--- <th>#application.rb.getResource("deployed")#</th> --->
			<th>#application.rb.getResource("coapiadmin.labels.deploy@label","Deploy")#</th>
			<!--- TODO: i18n --->
			<th style="border-right:none">#application.rb.getResource("coapiadmin.labels.cfdocs@text","Doc")#</th>
		</tr>
	</cfoutput>
		
	<!--- output core types --->
	<cfloop list="#componentList#" index="componentname">
	<cfif NOT application.types[componentname].bcustomtype>
		<cfset displayname = componentName />
		<cfif structkeyexists(application.types[componentname],"displayName")>
			<cfset displayname = application.types[componentname].displayname />
		</cfif>
		<cfscript>
			if (structKeyExists(stTypes,componentname))
				stConflicts = alterType.compareDBToCFCMetadata(typename=componentname,stDB=stTypes['#componentname#']);
			else
				stConflicts['#componentname#'] = structNew();
		</cfscript>
		<cfoutput>
			<tr <cfif alterType.isCFCConflict(stConflicts=stConflicts,typename=componentName)>style='color:##000;'</cfif>>
				<td>
					<cfif alterType.isCFCConflict(stConflicts=stConflicts,typename=componentName)>
						<img src="#application.url.farcry#/images/no.gif" /> #application.rb.getResource("coapiadmin.labels.seeBelow@label","See Below")#
					<cfelse>
						<img src="#application.url.farcry#/images/yes.gif" />
					</cfif>
				</td>
				<td><span title="<cfif structKeyExists(application.types[componentname], 'hint')>#application.types[componentname].hint#<cfelse>#displayname#</cfif>">#displayname#</span></td>
				<td>#componentName#</td>
				<td>
					<cfif NOT alterType.isCFCDeployed(typename=componentName)>
						<a href="#CGI.SCRIPT_NAME#?deploy=#componentName#">#application.rb.getResource("coapiadmin.buttons.deploy@label","Deploy")#</a>
					<cfelse>
						<ft:button type="button" value="Scaffold" onclick="$j('##dialog').find('iframe').attr('src','#application.url.farcry#/admin/scaffold.cfm?typename=#componentName#&iframe=1').end().dialog({ autoOpen:true,width:500,height:400,title:'Scaffold #displayname#',modal:true });" />
					</cfif>
				</td>
				<td style="border-right:none">
				<ft:button value="Doc" url="#variables.documentURL#?component=#application.types[componentname].name#" />
				</td>
			</tr>
		</cfoutput>
		<cfscript>
		// output dreadful interface for COAPI evolution
			if (structKeyExists(stConflicts,'cfc') AND structKeyExists(stConflicts['cfc'],componentName))
				{
				writeoutput("<tr><td colspan='4' style='background-color:##F9E6D4;border-right:none'><div id='#componentname#_report'>");
				alterType.renderCFCReport(typename=componentname,stCFC=stConflicts['cfc'][componentname]);
				writeoutput("</div></td></tr>");		
				}
			if (structKeyExists(stConflicts,'database') AND structKeyExists(stConflicts['database'],componentName))
				{
				writeoutput("<tr><td colspan='4' style='background-color:##F9E6D4;border-right:none'><div id='#componentname#_report'>");
				alterType.renderDBReport(typename=componentname,stDB=stConflicts['database'][componentname]);
				writeoutput("</div></td></tr>");		
				}
		</cfscript>
	</cfif>
	</cfloop>
	<cfoutput></table><div id="dialog" style="display:none;"><iframe style="width:100%;height:100%;border:0 none;"></iframe></div></cfoutput>
</sec:CheckPermission>

<admin:footer>

<!--- <cfdump var="#application.types.dmarchive#"> --->
<cfsetting enablecfoutputonly="No">
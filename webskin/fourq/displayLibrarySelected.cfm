<cfsetting enablecfoutputonly="true">
<!--- @@Copyright: Daemon Pty Limited 1995-2007, http://www.daemon.com.au --->
<!--- @@License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php --->
<!--- @@displayname: Shows only library selected --->
<!--- @@description:   --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au) --->


<!------------------ 
FARCRY IMPORT FILES
 ------------------>
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
<cfimport taglib="/farcry/core/tags/grid" prefix="grid" />

<!------------------ 
START WEBSKIN
 ------------------>

	
	<cfparam name="url.property" type="string" />

	
	<cfset formAction = application.fapi.getLink(type='#stobj.typename#', objectid='#stobj.objectid#', view='displayLibrarySelected', urlParameters="property=#url.property#&ajaxmode=1") />
	
	<ft:form name="#stobj.typename#_#url.property#" bAjaxSubmission="true" action="#formAction#">
	
	<grid:col id="utility" span="20" />
		
	<grid:col span="1" />
	
	<grid:col span="60">
		
		
		<!--- DISPLAY THE SELECTION OPTIONS --->
		<cfoutput>
		<!-- summary pod with green arrow -->
		<div class="summary-pod">
				
					
			
					<cfset formAction = application.fapi.getLink(type='#stobj.typename#', objectid='#stobj.objectid#', view='displayLibrary', urlParameters="property=#url.property#&ajaxmode=1") />
					<ft:button value="Select More" renderType="link" type="button" onclick="farcryForm_ajaxSubmission('#request.farcryform.name#','#formAction#')" class="red" />
		
			
					<span id="librarySummary-#stobj.typename#-#url.property#"><p>&nbsp;</p></span>	
			
				
				
				
			
		</div>
		<!-- summary pod end -->
		</cfoutput>
		
		
		<cfset stMetadata = application.fapi.getPropertyMetadata(typename="#stobj.typename#", property="#url.property#") />
		
		<!--- DETERMINE THE SELECTED ITEMS --->
		<cfif stMetadata.type EQ "array">
			<cfset lSelected = arrayToList(stobj[url.property]) />
			
			<!--- setup the paginated array. --->
			<cfset aPaginatedData = stobj[url.property] />
		<cfelse>
			<cfset lSelected = stobj[url.property] />
			
			<!--- Turn item into an array so we can paginate --->
			<cfset aPaginatedData = arrayNew(1) />
			<cfset arrayAppend(aPaginatedData,stobj[url.property])>
		</cfif>
		
		<skin:pagination array="#aPaginatedData#" submissionType="form">
			<cfoutput>
				<div class="ctrlHolder #stObject.currentRowClass#" style="padding:3px;margin:3px;">
					<div style="float:left;width:20px;">
						<input type="checkbox" id="selected_#stobject.currentRow#" name="selected" class="checker" value="#stobject.objectID#" <cfif listFindNoCase(lSelected,stobject.objectid)>checked="checked"</cfif> />
					</div>
					<div style="margin-left: 30px;">
						<skin:view objectid="#stobject.objectid#" webskin="librarySelected" bIgnoreSecurity="true" />
					</div>					
				</div>
			</cfoutput>
		</skin:pagination>
		
		<cfoutput>
		<script type="text/javascript">
		$j(function(){
			fcForm.initLibrary('#stobj.typename#','#stobj.objectid#','#url.property#');	
		});
		</script>
		</cfoutput>
		
	</grid:col>	
	</ft:form>

<cfsetting enablecfoutputonly="false">
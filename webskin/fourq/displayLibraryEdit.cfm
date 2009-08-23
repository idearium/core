<cfsetting enablecfoutputonly="true">
<!--- @@Copyright: Daemon Pty Limited 1995-2007, http://www.daemon.com.au --->
<!--- @@License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php --->
<!--- @@displayname: library summary --->
<!--- @@description:   --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au) --->


<!------------------ 
FARCRY IMPORT FILES
 ------------------>
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />


<skin:htmlHead id="jqueryJS">
	<cfoutput>
		<script src="#application.url.webtop#/thirdparty/jquery/js/jquery-1.3.2.min.js" type="text/javascript"></script>
		<script type="text/javascript">
		     var $j = jQuery.noConflict();
		</script></cfoutput>
</skin:htmlHead>


<!------------------ 
START WEBSKIN
 ------------------>
<cfif application.fapi.isLoggedIn()>
	
	<cfparam name="url.property" type="string" />
	<cfparam name="url.editID" type="string" />
	
	<cfset stMetadata = application.fapi.getPropertyMetadata(typename="#stobj.typename#", property="#url.property#") />
	
			
	<ft:form name="#stobj.typename#_#url.property#">
		
		
		<cfset stOnExit = structNew() />
		<cfset stOnExit.type = "HTML" />
		<cfsavecontent variable="stOnExit.content">
		<cfoutput>
		<script type="text/javascript">
		$j(function() {
			parent.$j('###stobj.typename##stobj.objectid##url.property#').dialog('close');	
		});
		</script>
		</cfoutput>
		</cfsavecontent>
				
		<cfset type = application.fapi.findType("#url.editID#") />
		<cfset oType = application.fapi.getContentType(type) />		
  		<cfset html = oType.getView(objectID="#url.editID#", webskin="libraryEdit", OnExit="#stOnExit#", alternateHTML="", bIgnoreSecurity="true") />
		
		<cfif len(html)>
		    <cfoutput>#html#</cfoutput>
		<cfelse>
			<!--- THIS IS THE LEGACY WAY OF DOING THINGS AND STAYS FOR BACKWARDS COMPATIBILITY --->
		    <cfinvoke component="#oType#" method="edit">
		        <cfinvokeargument name="objectId" value="#url.editID#" />
		        <cfinvokeargument name="onExit" value="#stOnExit#" />
		    </cfinvoke>
		</cfif>
		
	</ft:form>

</cfif>

<cfsetting enablecfoutputonly="false">
<cfprocessingDirective pageencoding="utf-8">
<!--- createDraftObject.cfm 
Creates a draft object
--->

<cfsetting enablecfoutputonly="no">
<cfimport taglib="/farcry/farcry_core/fourq/tags/" prefix="q4">
<cfimport taglib="/farcry/farcry_core/tags/navajo/" prefix="nj">
<cfoutput>
	<link rel="stylesheet" type="text/css" href="#application.url.farcry#/navajo/navajo_popup.css">
</cfoutput>


<cfparam name="url.objectId" default="">
<cfparam name="url.method" default="edit">
<cfparam name="url.ref" default="">
<cfparam name="url.finishurl" default="">

<cfif len(url.objectId)>
	<!--- Get this object so we can duplicate it --->
	<q4:contentobjectget objectid="#url.objectId#" bactiveonly="False" r_stobject="stObject">
	
	<cfscript>
	// copy live object content
		stProps=structCopy(stObject);
	// override those properties unique to DRAFT at start
		stProps.objectid = createUUID();
		stProps.lastupdatedby = session.dmSec.authentication.userlogin;
		stProps.datetimelastupdated = Now();
	// todo: not sure createdby/datetimecreated should be changed for DRAFT GB 20050126
		stProps.createdby = session.dmSec.authentication.userlogin;
		stProps.datetimecreated = Now();
		stProps.status = "draft";
		stProps.versionID = URL.objectID;

		// create the new OBJECT 
		oType = createobject("component", application.types[stProps.TypeName].typePath);
		stNewObj = oType.createData(stProperties=stProps);
		NewObjId = stNewObj.objectid;
		oAuthentication = request.dmSec.oAuthentication;	
		stuser = oAuthentication.getUserAuthenticationData();
		application.factory.oaudit.logActivity(objectid="#URL.objectid#",auditType="Create", username=StUser.userlogin, location=cgi.remote_host, note="Draft object created");
		
		//this will copy containers and there rules from live object to draft
		oCon = createobject("component","#application.packagepath#.rules.container");
		oCon.copyContainers(stObject.objectid,stProps.objectid);
		
		//this will copy categories from live object to draft
		oCategory = createobject("component","#application.packagepath#.farcry.category");
		oCategory.copyCategories(stObject.objectid,stProps.objectid);
	</cfscript>

	<cfoutput>
	<script type="text/javascript">
		window.location="#application.url.farcry#/conjuror/invocation.cfm?objectid=#NewObjID#&method=#url.method#&ref=#url.ref#&finishurl=#url.finishurl#";
	</script>
	</cfoutput>
</cfif>


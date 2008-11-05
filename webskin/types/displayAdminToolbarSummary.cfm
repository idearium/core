<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Low profile admin toolbar --->

<cfimport taglib="/farcry/core/tags/extjs" prefix="extjs" />
<cfimport taglib="/farcry/core/tags/security" prefix="sec" />

<extjs:iframeDialog />

<!--- DATA --->
<cfset aItems = arraynew(1) />

<!--- Status --->
<cfif structkeyexists(stObj,"status")>
	<cfset arrayappend(aItems,"Status: <span class='status #stObj.status#'>#application.rb.getResource('workflow.constants.#stObj.status#@label',stObj.status)#</span>") />
</cfif>

<!--- Current template --->
<cfif structkeyexists(stObj,"displayMethod")>
	<cfquery dbtype="query" name="qWebskin">
		select		displayname
		from		application.stCOAPI.#stObj.typename#.qWebskins
		where		name='#stObj.displaymethod#.cfm'
	</cfquery>
	
	<cfset arrayappend(aItems,"Template: #qWebskin.displayname#") />
</cfif>


<!--- ACTIONS --->
<cfset aActions = arraynew(1) />

<!--- View drafts --->
<cfsavecontent variable="html">
	<cfoutput>
		{
			xtype:"tbbutton",
			iconCls:<cfif request.mode.showdraft>"previewmode_icon"<cfelse>"previewmodedisabled_icon"</cfif>,
			text:<cfif request.mode.showdraft>"Show Drafts"<cfelse>"Show Drafts"</cfif>,
			enableToggle:true,
			allowDepress:true,
			pressed:#request.mode.showdraft#,
			listeners:{
				"click":{
					fn:function(){
						<cfif request.mode.showdraft and structkeyexists(stObj,"versionid")>
							parent.updateContent("#url.url#&flushcache=1&showdraft=0");
						<cfelseif request.mode.showdraft>
							parent.updateContent("#url.url#&flushcache=1&showdraft=0");
						<cfelse>
							parent.updateContent("#url.url#&flushcache=0&showdraft=1");
						</cfif>
						Ext.getBody().mask("Loading...");
					}
				}
			}
		}
	</cfoutput>
</cfsavecontent>
<cfset arrayappend(aActions,html) />

<!--- Container management --->
<sec:CheckPermission permission="ContainerManagement" objectid="#request.navid#">
	<cfsavecontent variable="html">
		<cfoutput>
			{
				xtype:"tbbutton",
				iconCls:<cfif request.mode.design and request.mode.showcontainers gt 0>"designmode_icon"<cfelse>"designmodedisabled_icon"</cfif>,
				text:<cfif request.mode.design and request.mode.showcontainers gt 0>"Show Rules"<cfelse>"Show Rules"</cfif>,
				enableToggle:true,
				allowDepress:true,
				pressed:#request.mode.design and request.mode.showcontainers#,
				listeners:{
					"click":{
						fn:function(){
							<cfif request.mode.design and request.mode.showcontainers gt 0>
								parent.updateContent("#url.url#&designmode=0");
							<cfelse>
								parent.updateContent("#url.url#&designmode=1");
							</cfif>
							Ext.getBody().mask("Loading...");
						}
					}
				}
			}
		</cfoutput>
	</cfsavecontent>
	<cfset arrayappend(aActions,html) />
</sec:CheckPermission>

<!--- Editing the object --->

<sec:CheckPermission objectid="#stObj.objectid#" typename="#stObj.typename#" permission="Edit">
	<cfif structkeyexists(stObj,"status") and stObj.status eq "draft">
		<cfset editableid = stObj.objectid />
	<cfelseif structkeyexists(stObj,"versionid")>
		<cfset qDraft = createObject("component", "#application.packagepath#.farcry.versioning").checkIsDraft(objectid=stobj.objectid,type=stobj.typename)>
		<cfif qDraft.recordcount>
			<cfset editableid = qDraft.objectid />
		<cfelse>
			<cfset editableid = "" />
		</cfif>
	<cfelseif not structkeyexists(stObj,"status")>
		<cfset editableid = stObj.objectid />
	<cfelse>
		<cfset editableid = "" />
	</cfif>
	
	<cfif len(editableid)>
		<cfsavecontent variable="html">
			<cfoutput>
				{
					xtype:"tbbutton",
					iconCls:"edit_icon",
					text:"Edit",
					listeners:{
						"click":{
							fn:function(){
								parent.editContent("#application.url.webtop#/conjuror/invocation.cfm?objectid=#editableid#&method=edit&ref=&finishurl=&iframe=true","Edit #stObj.label#",800,600,true);
							}
						}
					}
				}
			</cfoutput>
		</cfsavecontent>
		<cfset arrayappend(aActions,html) />
	</cfif>
</sec:CheckPermission>

<cfoutput>{
	xtype:"panel",
	layout:"border",
	items:[{
		xtype:"panel",
		region:"center",
		html:"<div class='traytext'><a href='#application.url.webtop#/' class='webtoplink' title='Webtop' target='_top'><img class='traytypeicon' src='#application.url.webtop#/facade/icon.cfm?icon=#stObj.typename#&size=16' alt='#stObj.typename#' /></a>#jsstringformat(arraytolist(aItems,'<span class=''separator''>|</span>'))#</div>",
		cls:"htmlpanel detailview"
	}<cfif arraylen(aActions)>,{
		xtype:"toolbar",
		region:"east",
		width:271,
		items:[
			#arraytolist(aActions)#
		]
	}</cfif>]
}</cfoutput>

<cfsetting enablecfoutputonly="false" />
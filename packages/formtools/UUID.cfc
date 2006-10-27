<cfcomponent extends="field" name="UUID" displayname="UUID" hint="Used to liase with UUID type fields"> 

	<cfimport taglib="/farcry/farcry_core/tags/formtools/" prefix="ft" >
	
	<cffunction name="init" access="public" returntype="farcry.farcry_core.packages.formtools.UUID" output="false" hint="Returns a copy of this initialised object">
		<cfreturn this>
	</cffunction>
	
	<cffunction name="edit" access="public" output="false" returntype="string" hint="This is going to called from ft:object and will always be passed 'typename,stobj,stMetadata,fieldname'.">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">

		<cfset var stobj = structnew() / >
		
		<cfparam name="arguments.stMetadata.ftLibrarySelectedWebskin" default="LibrarySelected" type="string" />
		<cfparam name="arguments.stMetadata.ftLibrarySelectedListClass" default="arrayDetail" type="string" />
		<cfparam name="arguments.stMetadata.ftLibrarySelectedListStyle" default="" type="string" />
		<cfparam name="arguments.stMetadata.ftLibraryListItemWidth" default="" type="string" />
		<cfparam name="arguments.stMetadata.ftLibraryListItemHeight" default="" type="string" />
		<cfparam name="arguments.stMetadata.ftRenderType" default="Library">
		<cfparam name="arguments.stMetadata.ftFirstListLabel" default="-- SELECT --">

		<!--- A UUID type MUST have a 'ftJoin' property --->
		<cfif not structKeyExists(stMetadata,"ftJoin")>
			<cfreturn "" />
		</cfif>
		
		<!--- Create the Linked Table Type as an object  --->
		<cfset oData = createObject("component",application.types[stMetadata.ftJoin].typepath)>

		<!--------------------------------------------- 
		RENDER TYPE SWITCH
			- select specific form element output
 		----------------------------------------------->
		<cfswitch expression="#arguments.stMetadata.ftRenderType#">
		<cfcase value="list">
			<!-------------------------------------------------------------------------- 
			generate library data query to populate library interface 
			--------------------------------------------------------------------------->
			<cfif structkeyexists(stMetadata, "ftLibraryData") AND len(stMetadata.ftLibraryData)>	
				<cfset oPrimary = createObject("component", application.types[typename].typepath) />
				<cfset stPrimary =  oPrimary.getData(objectid=stobject.objectid) />
				
				<!--- use ftlibrarydata method from primary content type --->
				<cfif structkeyexists(oprimary, stMetadata.ftLibraryData)>
					<cfinvoke component="#oPrimary#" method="#stMetadata.ftLibraryData#" returnvariable="qLibraryList" />
				</cfif>
			</cfif>
			<!--- if nothing exists to generate library data then cobble something together --->
			<cfif NOT isDefined("qLibraryList")>
				<cfinvoke component="#oData#" method="getLibraryData" returnvariable="qLibraryList" />
			</cfif>

			<cfsavecontent variable="returnHTML">
			<cfif qLibraryList.recordcount>
				<cfoutput>
				<select  id="#arguments.fieldname#" name="#arguments.fieldname#">
				<cfif len(arguments.stMetadata.ftFirstListLabel)>
					<option value="">#arguments.stMetadata.ftFirstListLabel#</option>
				</cfif>
				<cfloop query="qLibraryList"><option value="#qLibraryList.objectid#" <cfif arguments.stObject[arguments.stMetaData.Name] EQ qLibraryList.objectid>selected</cfif>><cfif isDefined("qLibraryList.label")>#qLibraryList.label#<cfelse>#qLibraryList.objectid#</cfif></option></cfloop>
				</select>
				</cfoutput>
				
			<cfelse>
				<!--- todo: i18n --->
				<cfoutput>
				<em>No options available.</em>
				<input type="hidden" id="#arguments.fieldname#" name="#arguments.fieldname#" value="" />
				</cfoutput>
			</cfif>
			
			</cfsavecontent>
		
		</cfcase>
		
		<cfdefaultcase>
			<!--- ID of the unordered list. Important to use this so that the object can be referenced even if their are multiple objects referencing the same field. --->
			<cfset ULID = "#arguments.fieldname#_list">
			
			<cfsavecontent variable="returnHTML">
				<!--- Contains a list of objectID's currently associated with this field' --->
				<cfoutput><input type="hidden" id="#arguments.fieldname#" name="#arguments.fieldname#" value="#arguments.stObject[arguments.stMetaData.Name]#" /></cfoutput>

					<!-----------------------
					NEW ARRAY LAYOUT
					 ----------------------->
					<cfoutput>
						<br class="clearer"/>
						<div id="#arguments.fieldname#-libraryCallback">						
							<ul id="#ULID#" class="#arguments.stMetadata.ftLibrarySelectedListClass#View" style="#arguments.stMetadata.ftLibrarySelectedListStyle#">
					</cfoutput>
					
						<cfif Len(arguments.stObject[arguments.stMetaData.Name])>
											
			
							<cfset HTML = oData.getView(objectID=#arguments.stObject[arguments.stMetaData.Name]#, template="#arguments.stMetadata.ftLibrarySelectedWebskin#", alternateHTML="") />
							<cfif NOT len(trim(HTML))>
								<cfset stTemp = oData.getData(objectid=#arguments.stObject[arguments.stMetaData.Name]#)>
								<cfif structKeyExists(stTemp, "label") AND len(stTemp.label)>
									<cfset HTML = stTemp.label />
								<cfelse>
									<cfset HTML = stTemp.objectid />
								</cfif>
							</cfif>

							
							<cfoutput>
							<li id="#arguments.fieldname#_#arguments.stObject[arguments.stMetaData.Name]#" class="#ULID#handle" style="<cfif len(arguments.stMetadata.ftLibraryListItemWidth)>width:#arguments.stMetadata.ftLibraryListItemWidth#;</cfif><cfif len(arguments.stMetadata.ftLibraryListItemheight)>height:#arguments.stMetadata.ftLibraryListItemHeight#;</cfif>">
								<div class="buttonGripper"><p>&nbsp;</p></div>
								<input type="checkbox" name="#arguments.fieldname#Selected" id="#arguments.fieldname#Selected" class="formCheckbox" value="#arguments.stObject[arguments.stMetaData.Name]#" />

								<div class="#arguments.stMetadata.ftLibrarySelectedListClass#">
									<p>#HTML#</p>
								</div>
									
							</li>
							</cfoutput>
						</cfif>
								
					<cfoutput>
							</ul>
						</div>
						<div class="buttonGroup">
							<ft:farcryButton type="button" value="Remove Selected" onclick="deleteSelected#arguments.fieldname#();return false;" confirmText="Are you sure you want to remove the selected item" / >						
						</div>

						<br class="clearer" />
					</cfoutput>
				
	
					<cfoutput>
					<script type="text/javascript" language="javascript" charset="utf-8">
						
							
					function deleteSelected#arguments.fieldname#(){
						
						aInputs = $$("###ULID# input");
						aInputs.each(function(child) {
							if(child.checked == true){
								Element.remove('#arguments.fieldname#_' + child.value);
							}
						});
						Sortable.create('#ULID#');
						$('#arguments.fieldname#').value = Sortable.sequence('#ULID#');
						libraryCallback_#arguments.fieldname#('remove',$('#arguments.fieldname#').value);
					}
					
					function libraryCallback_#arguments.fieldname#(action,ids){
						$('#arguments.fieldname#').value = ids;
						
						
						new Ajax.Updater('#arguments.fieldname#-libraryCallback', '/farcry/facade/library.cfc?method=ajaxUpdateArray', {
								//onLoading:function(request){Element.show('indicator')},
								parameters:'Action=' + action + '&LibraryType=UUID&primaryObjectID=#arguments.stObject.ObjectID#&primaryTypename=#arguments.typename#&primaryFieldname=#arguments.stMetaData.Name#&primaryFormFieldname=#arguments.fieldname#&WizzardID=&DataObjectID=' + encodeURIComponent($('#arguments.fieldname#').value) + '&DataTypename=#ListFirst(arguments.stMetadata.ftJoin)#', evalScripts:true, asynchronous:true
							})
												
					}
					

					</script>
					</cfoutput>	
						<!---				
								
			<cfsavecontent variable="returnHTML">
			<cfoutput>
				<input type="hidden" id="#arguments.fieldname#" name="#arguments.fieldname#" value="#arguments.stObject[arguments.stMetaData.Name]#" />
				<div id="#arguments.fieldname#_1">
				<cfif Len(arguments.stObject[arguments.stMetaData.Name])>
				
					<cfset stobj = oData.getData(objectid=#arguments.stObject[arguments.stMetaData.Name]#)>
						
					<cfif FileExists("#application.path.project#/webskin/#arguments.stMetadata.ftJoin#/#arguments.stMetadata.ftLibrarySelectedWebskin#.cfm")>
						<cfset oData.getDisplay(stObject=stobj, template="#arguments.stMetadata.ftLibrarySelectedWebskin#") />
						<!---<cfinclude template="/farcry/#application.applicationname#/webskin/#arguments.stMetadata.ftJoin#/#arguments.stMetadata.ftLibrarySelectedWebskin#.cfm"> --->
					<cfelse>
						<cfif isDefined("stobj.label") AND len(stobj.label)>#stobj.Label#<cfelse>#stobj.ObjectID#</cfif>
					</cfif>
					<a href="##" onclick="new Effect.Fade($('#arguments.fieldname#_1'));Element.remove('#arguments.fieldname#_1');$('#arguments.fieldname#').value = ''; return false;"><img src="#application.url.farcry#/images/crystal/22x22/actions/button_cancel.png" style="width:16px;height:16px;" /></a>
				</cfif>
				</div>
			
				<script type="text/javascript" language="javascript" charset="utf-8">
				function update_#arguments.fieldname#_wrapper(HTML){
					$('#arguments.fieldname#-wrapper').innerHTML = HTML;
							 
				}
				</script>
			</cfoutput>	 --->
			</cfsavecontent>
		</cfdefaultcase>
		</cfswitch>
		
		
 		<cfreturn ReturnHTML>
		
	</cffunction>
	
	<cffunction name="display" access="public" output="false" returntype="string" hint="This will return a string of formatted HTML text to display.">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">

		<cfparam name="arguments.stMetadata.ftLibrarySelectedWebskin" default="librarySelected">
		<cfparam name="arguments.stMetadata.ftLibrarySelectedListClass" default="thumbNailsWrap">
		<cfparam name="arguments.stMetadata.ftLibrarySelectedListStyle" default="">
		
		
		<!--- A UUID type MUST have a 'ftJoin' property --->
		<cfif not structKeyExists(stMetadata,"ftJoin")>
			<cfreturn "">
		</cfif>
				
		<!--- Create the Linked Table Type as an object  --->
		<cfset oData = createObject("component",application.types[stMetadata.ftJoin].typepath)>
		

		<cfsavecontent variable="returnHTML">
		
			
			<cfif Len(arguments.stObject[arguments.stMetaData.Name])>
				<cfset stobj = oData.getData(objectid=#arguments.stObject[arguments.stMetaData.Name]#)>
				<cfif FileExists("#application.path.project#/webskin/#arguments.stMetadata.ftJoin#/#arguments.stMetadata.ftLibrarySelectedWebskin#.cfm")>
					
					<cfinclude template="/farcry/#application.applicationname#/webskin/#arguments.stMetadata.ftJoin#/#arguments.stMetadata.ftLibrarySelectedWebskin#.cfm">
				<cfelse>
					<cfoutput>#stobj.label#</cfoutput>
				</cfif>
			</cfif>
				
		
		</cfsavecontent>
		
		<cfreturn returnHTML>
	</cffunction>

	<cffunction name="validate" access="public" output="true" returntype="struct" hint="This will return a struct with bSuccess and stError">
		<cfargument name="stFieldPost" required="true" type="struct" hint="The fields that are relevent to this field type.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		
		<cfset var stResult = structNew()>		
		<cfset stResult.bSuccess = true>
		<cfset stResult.value = "">
		<cfset stResult.stError = StructNew()>
		
		<!--- --------------------------- --->
		<!--- Perform any validation here --->
		<!--- --------------------------- --->
		<cfset stResult.value = stFieldPost.Value>
		
		
		<!--- ----------------- --->
		<!--- Return the Result --->
		<!--- ----------------- --->
		<cfreturn stResult>
		
	</cffunction>
	
	<cffunction name="libraryCallback" access="public" output="true" returntype="string" hint="This is going to called from ft:object and will always be passed 'typename,stobj,stMetadata,fieldname'.">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">
		<cfargument name="stPackage" required="true" type="struct" hint="Contains the metadata for the all fields for the current typename.">
		
		<cfset var returnHTML = "" />
		<cfset var stobj = structnew() / >
		<cfset var stJoinObjects = structNew() /> <!--- This will contain a structure of object components that match the ftJoin list from the metadata --->

		<cfset var oData = "" />
		<cfset var q4 = "" />
		<cfset var joinTypename = "" />
		
		<!---
		<cfset var oFourQ = createObject("component","farcry.fourq.fourq")><!--- TODO: this needs to be removed when we add typename to array tables. ---> 
		 --->
		<cfparam name="arguments.stMetadata.ftLibrarySelectedWebskin" default="LibrarySelected" type="string" />
		<cfparam name="arguments.stMetadata.ftLibrarySelectedListClass" default="arrayDetail" type="string" />
		<cfparam name="arguments.stMetadata.ftLibrarySelectedListStyle" default="" type="string" />
		<cfparam name="arguments.stMetadata.ftLibraryListItemWidth" default="" type="string" />
		<cfparam name="arguments.stMetadata.ftLibraryListItemHeight" default="" type="string" />
		<cfparam name="arguments.stMetadata.ftRenderType" default="Library" type="string" />
		<cfparam name="arguments.stMetadata.ftSelectSize" default="10" type="numeric" />
		<cfparam name="arguments.stMetadata.ftSelectMultiple" default="true" type="string" />


		
		<!--- An array type MUST have a 'ftJoin' property --->
		<cfif not structKeyExists(arguments.stMetadata,"ftJoin") or not len(arguments.stMetadata.ftJoin)>
			<cfreturn "">
		</cfif>
		
		
		<!--- Create each of the the Linked Table Types as an object  --->
		<cfloop list="#arguments.stMetadata.ftJoin#" index="i">			
			<cfset stJoinObjects[i] = createObject("component",application.types[i].typepath)>
		</cfloop>

		<!--- Make sure scriptaculous libraries are included. --->
		<cfset Request.InHead.ScriptaculousDragAndDrop = 1>
		<cfset Request.InHead.ScriptaculousEffects = 1>	

		
		<!--------------------------------------------- 
		RENDER TYPE SWITCH
			- select specific form element output
 		----------------------------------------------->
		<cfswitch expression="#arguments.stMetadata.ftRenderType#">
		<cfcase value="list">
			
			<!-------------------------------------------------------------------------- 
			generate library data query to populate library interface 
			--------------------------------------------------------------------------->
			<cfif structkeyexists(stMetadata, "ftLibraryData") AND len(stMetadata.ftLibraryData)>	
				<cfset oPrimary = createObject("component", arguments.stPackage.packagePath) />
				
				<!--- use ftlibrarydata method from primary content type --->
				<cfif structkeyexists(oprimary, stMetadata.ftLibraryData)>
					<cfinvoke component="#oPrimary#" method="#stMetadata.ftLibraryData#" returnvariable="qLibraryList" />
				</cfif>
			</cfif>
			<!--- if nothing exists to generate library data then cobble something together --->
			<cfif NOT isDefined("qLibraryList")>
				<cfset qLibraryList = createObject("component", application.types[listFirst(arguments.stMetadata.ftJoin)].typepath).getLibraryData() />
			</cfif>
	
			<cfsavecontent variable="returnHTML">
			<cfif qLibraryList.recordcount>
				<cfoutput>
				<select  id="#arguments.fieldname#" name="#arguments.fieldname#" size="#arguments.stMetadata.ftSelectSize#" multiple="#arguments.stMetadata.ftSelectMultiple#" style="width:auto;">
				<cfloop query="qLibraryList"><option value="#qLibraryList.objectid#" <cfif valuelist(qArrayField.data) contains qLibraryList.objectid>selected</cfif>><cfif isDefined("qLibraryList.label")>#qLibraryList.label#<cfelse>#qLibraryList.objectid#</cfif></option></cfloop>
				</select>
				</cfoutput>
				
			<cfelse>
				<!--- todo: i18n --->
				<cfoutput>
				<em>No options available.</em>
				<input type="hidden" id="#arguments.fieldname#" name="#arguments.fieldname#" value="" />
				</cfoutput>
			</cfif>
			
			</cfsavecontent>
		
		</cfcase>
		
		<cfdefaultcase>
		
			<!--- ID of the unordered list. Important to use this so that the object can be referenced even if their are multiple objects referencing the same field. --->
			<cfset ULID = "#arguments.fieldname#_list">
			
			<cfsavecontent variable="returnHTML">

				
				<cfoutput>
					<ul id="#ULID#" class="#arguments.stMetadata.ftLibrarySelectedListClass#View" style="#arguments.stMetadata.ftLibrarySelectedListStyle#">
				</cfoutput>
				
					<cfif Len(arguments.stObject[arguments.stMetaData.Name])>
										
						<cfif listLen(arguments.stMetadata.ftJoin)>						
							<cfset q4 = createObject("component", "farcry.fourq.fourq")>
							<cfset joinTypename = q4.findType(objectid=arguments.stObject[arguments.stMetaData.Name])>
							<cfset oData = createObject("component", application.types[joinTypename].packagePath) />
						<cfelse>
							<cfset oData = createObject("component", application.types[arguments.stMetadata.ftJoin].packagePath) />
						</cfif>
						
						<cfset HTML = oData.getView(objectID=arguments.stObject[arguments.stMetaData.Name], template="#arguments.stMetadata.ftLibrarySelectedWebskin#", alternateHTML="") />
						<cfif NOT len(trim(HTML))>
							<cfset stTemp = oData.getData(objectid=#arguments.stObject[arguments.stMetaData.Name]#)>
							<cfif structKeyExists(stTemp, "label") AND len(stTemp.label)>
								<cfset HTML = stTemp.label />
							<cfelse>
								<cfset HTML = stTemp.objectid />
							</cfif>
						</cfif>

						
						<cfoutput>
						<li id="#arguments.fieldname#_#arguments.stObject[arguments.stMetaData.Name]#" class="#ULID#handle" style="<cfif len(arguments.stMetadata.ftLibraryListItemWidth)>width:#arguments.stMetadata.ftLibraryListItemWidth#;</cfif><cfif len(arguments.stMetadata.ftLibraryListItemheight)>height:#arguments.stMetadata.ftLibraryListItemHeight#;</cfif>">
							<div class="buttonGripper"><p>&nbsp;</p></div>
							<input type="checkbox" name="#arguments.fieldname#Selected" id="#arguments.fieldname#Selected" class="formCheckbox" value="#arguments.stObject[arguments.stMetaData.Name]#" />

							<div class="#arguments.stMetadata.ftLibrarySelectedListClass#">
								<p>#HTML#</p>
							</div>
								
						</li>
						</cfoutput>
					</cfif>
							
				<cfoutput>
					</ul>
				</cfoutput>
				
			
			</cfsavecontent>
		</cfdefaultcase>
		</cfswitch>
		
 		<cfreturn ReturnHTML />

	</cffunction>
			
</cfcomponent> 
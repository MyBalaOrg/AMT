({
	getPermissionSet : function(component) {		       
        	var action = component.get("c.getAssignedPermissionSet");
            var allowAccess = 'false';
        	var compName;
        	action.setCallback(this, function(response){
            	var state = response.getState();
            	console.log("c.initPage " + state);
            	if (state === "SUCCESS") {
               	 	var returnValue = response.getReturnValue();
                    console.log('returnvalue'+JSON.stringify(response.getReturnValue()));
                    if ($A.util.isEmpty(returnValue.errorMsg)) {
                        if (!$A.util.isEmpty(returnValue)) {                      	
                            debugger;
                            var PSList = JSON.parse(returnValue.permissionSetList);  
                            var allowedPS = JSON.parse(returnValue.allowedPS); 
                            var profileName =  JSON.parse(returnValue.ProfileName);                      
                            
                            var BreakException = {};
                            try {
                                for(var ps in PSList){  
                                    for(var i in allowedPS){  
                                        console.log('PSList[ps]'+PSList[ps]+'allowedPS[i]');
                                        if (PSList[ps].PermissionSet.Name === allowedPS[i]){                                               
                                            allowAccess = 'true'; 
                                            throw BreakException;
                                        }                                   
                                    }
                                    
                                }
                            }catch (e) {
                                if (e !== BreakException) throw e;
                            }
                            
                            
                        }   
                        
                    }    
                }    
                console.log("*** allowAccess : " + allowAccess);
                if (allowAccess === 'true'){
                     compName = "c:RevSys_ObservationMainCmp";
                }
                else{
                     compName = "c:ST_ObservationSubmissionCmp";
                }
                    
                  var evt = $A.get("e.force:navigateToComponent");
                    console.log("EVT"+evt);
                    evt.setParams({
                        componentDef : compName,
                        componentAttributes: {
                            //selectedRecordTypeId : result
                 		}                  	                          
            
                    });
                    evt.fire();               
                
            });
          $A.enqueueAction(action);
      }
                               
     
        
});
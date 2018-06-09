({
    init : function(component, event, helper) {
        helper.doinit(component);
    },
    
    gotoNewObservation : function(component, event, helper){
               var evt = $A.get("e.force:navigateToComponent");
                    console.log("EVT"+evt);
                    evt.setParams({
                        componentDef : 'c:RevSys_ObservationMainCmp',
                        componentAttributes: {
                            //selectedRecordTypeId : result
                 		}                  	                          
            
                    });
                    evt.fire();                    	 
    },
    
    gotoHomePage : function(component, event, helper){        
      var homeEvent = $A.get("e.force:navigateToObjectHome");
      homeEvent.setParams({
          "scope": "Observation__c"
      });
      homeEvent.fire();
               
    }
})
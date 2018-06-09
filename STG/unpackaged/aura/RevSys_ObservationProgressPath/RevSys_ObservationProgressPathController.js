({
    selectStep1 : function (component, event, helper) {     
		component.set("v.selectionState", "1");    
	},

    selectStep2 : function (component, event, helper) {  
    	var hasEmployee = component.get("v.hasEmployee");  
    	var selectionState = component.get("v.selectionState");  
    	if (hasEmployee) { 
			component.set("v.selectionState", "2");  
		}
		else {
			component.set("v.selectionState", selectionState); 
		} 
	},

    selectStep3 : function (component, event, helper) {     
    	var hasEmployee = component.get("v.hasEmployee");   
    	var selectionState = component.get("v.selectionState");  
   		var hasTest = component.get("v.hasTest");  
   		var selectedRecordType = component.get("v.selectedRecordType");
   		var recordTypeToDisplayTestNumbers = component.get("v.recordTypeToDisplayTestNumbers");
   		if (hasEmployee) {
   			if (selectedRecordType.Id != recordTypeToDisplayTestNumbers) {
   				component.set("v.selectionState", "3");
   			}
   			else if (hasTest) {
   				component.set("v.selectionState", "3");
   			}
   			else {
   				component.set("v.selectionState", selectionState);
   			}
   		}
   		else {
   			component.set("v.selectionState", selectionState);
   		}	    
	},

    selectStep4 : function (component, event, helper) {     
		component.set("v.selectionState", "4");    
	},
})
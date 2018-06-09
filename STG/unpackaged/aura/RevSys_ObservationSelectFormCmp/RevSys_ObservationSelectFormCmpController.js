({
    onclickTab : function(component, event, helper) {       
        event.stopPropagation();       
        var index = event.target.value;
        if (!$A.util.isEmpty(index)) {       		
            var selectedRecordType = component.get("v.recordTypes["+index+"]");        
            component.set("v.theObject.RecordTypeId", selectedRecordType.Id);
            component.set("v.selectedRecordType", selectedRecordType);
            var params = {'selectedRecordType' : selectedRecordType}; 
          	amtrak.fireMapParamEvent(component, "selectRecordType", params);
        }
    },

})
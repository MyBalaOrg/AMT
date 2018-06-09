({
	onchangeTestFormSelect : function(component, event, helper) {
		event.stopPropagation();
        var index = event.getSource().get("v.value");
        if (!$A.util.isEmpty(index)) {
            var selectedRecordType = component.get("v.obsRecordTypes["+index+"]");
            component.set("v.obsTemplate.RecordTypeId", selectedRecordType.Id);
            component.set("v.selectedRecordType", selectedRecordType);
        }
	}
})
({
    doInit : function(component, event, helper) {
        helper.initializeDisplayFindings(component);
	},
    
    addFindings : function(component, event, helper) {
		var findingList_c = component.get("v.question_c.findingList");
        findingList_c.push(helper.getNewFindingWrapper());
        component.set("v.question_c.findingList", findingList_c);
	},
    
    toggleQuestionSelection : function(component, event, helper) {
        component.set("v.displayFindings", !component.get("v.displayFindings"));
    }, 
    
    handleDeleteFindingEvent : function(component, event, helper) {
        event.stopPropagation();
        var index = event.getParam("index");
        var findingList_c = component.get("v.question_c.findingList");
        if (!$A.util.isEmpty(findingList_c)) {
            if (findingList_c.length <= 1) {
                findingList_c[0] = helper.getNewFindingWrapper();
            } else {
                findingList_c.splice(index, 1);
            }
        	component.set("v.question_c.findingList", findingList_c);
        }
    }
})
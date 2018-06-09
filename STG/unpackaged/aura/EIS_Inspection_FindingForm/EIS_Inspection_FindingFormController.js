({
	descriptionOnBlur : function(component, event, helper) {
		var description = event.target.value;
        var finding = component.get("v.finding_c.finding");
        if (!$A.util.isEmpty(finding) && description != finding.EIS_Description__c) {
            finding.EIS_Description__c = description;
            component.set("v.finding_c.finding", finding);
            helper.saveFinding(component, "c.updateFindingDescription");
        }
        if (!$A.util.isEmpty(description)) {
            helper.setErrorMessage(component, "finding-description", false);
        }
	},
    
    onclickResolvedOnSpot : function(component, event, helper) {
        helper.setErrorMessage(component, "finding-description", false);
        helper.saveFinding(component, "c.resolvedOnSpot");
    },
    
    onclickDeleteFinding : function(component, event, helper) {
        helper.saveFinding(component, "c.deleteFinding");
    },
    
	addCorrectiveAction : function(component, event, helper) {
		var caList = component.get("v.finding_c.caList");
        caList.push({
            'sObjectType' : 'Corrective_Action__c', 
            'EIS_Description__c' : '',
            'EIS_Finding__c' : component.get("v.finding_c.finding.Id")
        });
        component.set("v.finding_c.caList", caList);
	},
    
    handleMissingFindingEvent : function(component, event, helper) {
        event.stopPropagation();
        var origin = event.getParam("origin");
        if (parseInt(origin) == component.get("v.findingNum")) {
            helper.setErrorMessage(component, "finding-description", true);
        }
    },
    
    handleUpdateCorrectiveActionEvent : function(component, event, helper) {
        event.stopPropagation();
        var origin = event.getParam("origin");
        if (parseInt(origin) == component.get("v.findingNum")) {
            var index = event.getParam("index");
            var ca = event.getParam("correctiveaction");
            var caList = component.get("v.finding_c.caList");
            if ($A.util.isEmpty(ca.Id) && caList.length > 1) {
                caList.splice(index, 1);
            } else {
                caList[index] = ca;
            }
            component.set("v.finding_c.caList", caList);
        }
    }
})
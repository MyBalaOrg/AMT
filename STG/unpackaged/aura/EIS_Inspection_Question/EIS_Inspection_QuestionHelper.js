({
    initializeDisplayFindings : function(component) {
        var question = component.get("v.question_c.question");
        if (!$A.util.isEmpty(question)) {
            component.set("v.displayFindings", question.EIS_Issued__c);
        }
    },
    
    getNewFindingWrapper : function() {
        var finding_c = {};
        finding_c.finding = {'sObjectType':'Finding__c', 'EIS_Description__c':''};
        finding_c.caList = [{'sObjectType':'Corrective_Action__c', 'EIS_Description__c':''}];
        return finding_c;
    }
})
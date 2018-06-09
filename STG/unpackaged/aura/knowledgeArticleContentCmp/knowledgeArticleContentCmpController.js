({
    /**
    *------------------------------------------
    * @Name: doInit
    * @Description
    * this function populates knowledge article record and its record type
    *------------------------------------------
    * @param    component, event, helper		reference to component, event and helper
    * @return   
    *------------------------------------------
    **/
	doInit : function(component, event, helper) {
		var action = component.get("c.getKnowledgeArticle");
        action.setParams({
            "knowledgeArticleId" : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            if(component.isValid() && response.getState() == "SUCCESS" && response.getReturnValue() != null) {
                component.set("v.knowledgeArticle", response.getReturnValue());
                if(response.getReturnValue().RecordTypeId != null) {
                    var action = component.get("c.getKnowledgeArticleRecordTypeName");
                    action.setParams({
                        "knowledgeArticleRecordTypeId" : response.getReturnValue().RecordTypeId
                    });
                    action.setCallback(this, function(response) {
                        if(component.isValid() && response.getState() == "SUCCESS" && response.getReturnValue() != null) {
                            component.set("v.knowledgeArticleRecordType", response.getReturnValue());
                        }
                    });
                }
                $A.enqueueAction(action);
            }
        });
        $A.enqueueAction(action);
	}
})
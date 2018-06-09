({
	getCorrectiveActionCounts : function(component, questionIds) {
		var action = component.get("c.countCorrectiveActions");
        action.setParams({
            "questionIdsJSON" : JSON.stringify(questionIds)
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log("c.countCorrectiveActions " + state);
            if (state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                if (!$A.util.isEmpty(returnValue)) {
                    component.set("v.caCountList", returnValue);
                }
            } else {
                console.log(response.getError());
            }
        });
        $A.enqueueAction(action);
    },
})
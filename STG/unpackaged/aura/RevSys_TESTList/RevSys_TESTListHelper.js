({
	getRevSysTestListforObservation : function(component, event) {
		var action = component.get("c.getRevSysTestListforObservation");
        action.setCallback(this, function(a) {
            console.log('return value : ',a.getReturnValue());
        });
        $A.enqueueAction(action);
	}
})
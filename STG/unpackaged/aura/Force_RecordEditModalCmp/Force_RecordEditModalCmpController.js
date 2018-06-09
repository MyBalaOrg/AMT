({
	cancel : function(component, event, helper) {
		component.set("v.openModal", false);
	},
    
    save : function(component, event, helper) {
        var forceEditCmp = component.find("edit");
        if (!$A.util.isEmpty(forceEditCmp)) {
            forceEditCmp.get("e.recordSave").fire();
            console.log("force:recordSave event fired");
            //component.set("v.openModal", false);
        }
    },
    
    handleSaveSuccess : function(component, event, helper) {
        var compEvent = component.getEvent("saveRecord");
        var params = {"saveEdit": "reload"};
        compEvent.setParams({"paramMap" : params });
        compEvent.fire();
        console.log("Fired Save Success event");
        component.set("v.openModal", false);
    }
})
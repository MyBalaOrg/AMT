({
    scriptsLoaded : function(component, event, helper) {
        amtrak.scriptLoadedCheck();
        helper.doInit(component);
    },

    handleToggleLightningSpinner : function(component, event, helper) {
        event.stopPropagation();
        var paramMap = event.getParam("paramMap");
        amtrak.toggleLightningSpinner(component.find("fidget-spinner"), paramMap.hideSpinner);
    },
    
    updateTest : function(component, event, helper) {
    	console.log("=====> updateTest");
        event.stopPropagation();
        helper.handleUpdate(component);
    },

    handleupdateEmployeeStatus: function(component, event, helper){
        event.stopPropagation();
        var paramMap = event.getParam("paramMap");
        var updateEmployeeStatus = paramMap.updateEmployeeStatus;
        var testEntry = component.get("v.testEntry");
        testEntry.completed = updateEmployeeStatus;
        component.set("v.testEntry", component.get("v.testEntry"));
    }
})
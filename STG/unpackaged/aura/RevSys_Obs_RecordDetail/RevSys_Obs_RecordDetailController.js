({
    doInit : function(component, event, helper) {
    	var numOfColList = [
            {"value" : 8, "selected" : false},
            {"value" : 7, "selected" : false},
            {"value" : 6, "selected" : false},
            {"value" : 5, "selected" : false},
            {"value" : 4, "selected" : true },
            {"value" : 3, "selected" : false},
            {"value" : 2, "selected" : false},
            {"value" : 1, "selected" : false}
        ];    
        component.set("v.numOfColList", numOfColList);
    },
    
    changeNumberOfColumn : function(component, event, helper) {
        event.stopPropagation();
        var colNumber = event.currentTarget.value;
        if (!$A.util.isEmpty(colNumber)) {
            var numOfColList = component.get("v.numOfColList");
            numOfColList.forEach(function(col) {
                col.selected = (col.value == colNumber);
            });
            component.set("v.numOfCol", colNumber);
            component.set("v.numOfColList", numOfColList);
        }
    },
    
    handleToggleLightningSpinner : function(component, event, helper) {
        event.stopPropagation();
        var paramMap = event.getParam("paramMap");
        amtrak.toggleLightningSpinner(component.find("fidget-spinner"), paramMap.hideSpinner);
    },
    
    SaveForm : function(component, event, helper) {
        event.stopPropagation();
        amtrak.toggleLightningSpinner(component.find("fidget-spinner"), false);
        var action = component.get('c.saveFindings');
        var params = {
            "findingListJSON": JSON.stringify(component.get("v.findingList")),
            "obsId": component.get("v.recordId")
        };
        var obsStatus = event.currentTarget.value;
        if (!$A.util.isEmpty(obsStatus)) {
            params.obsStatus = obsStatus;
        }
        action.setParams({ "params" : params });
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log("c.saveFindings " + state);
            if (state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                if ($A.util.isEmpty(returnValue.errorMsg)) {
                    if (!$A.util.isEmpty(returnValue.obs)) {
                        component.set("v.obs", JSON.parse(returnValue.obs));
                    }
                    //amtrak.fireSuccessToastEvent(component, "", $A.get("$Label.c.RevSys_Error_Message_Obs_Form_Save_Success"));
                    $A.get('e.force:refreshView').fire();
                  helper.showObservationCloneDialog(component); //invoke observaion clone confirmation dialog
              
                } else {
                    amtrak.fireErrorToastEvent(component, "", returnValue.errorMsg);
                    console.log(returnValue.consolelog); 
                }
            } else {
                amtrak.fireErrorToastEvent(component, "", response.getError());
                console.log(response.getError());
            }
            amtrak.toggleLightningSpinner(component.find("fidget-spinner"), true);
        });
        $A.enqueueAction(action);
    },
    
    scriptsLoaded : function(component, event, helper) {
        amtrak.scriptLoadedCheck();
        helper.doInit(component);
    },
    
	closeModal : function(component, event, helper) {
        helper.closeModalHelper(component);
    },
    
    cloneObservation : function(component,event,helper){
        helper.cloneObservationHelper(component,event);
    }
})
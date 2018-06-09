/*
********************************************************************************************************************************************************************************************************************************************
*	@Name			PTC_AssetRowItemController.js
*	@Author			Deloitte Digital
*	@Created Date	10th May 2018
*	@Used By		PTC App	
*	@Controller		PTC_AssetInstallationController
********************************************************************************************************************************************************************************************************************************************
*	@Description	This is the javascript controller for PTC_AssetInstallationParent.cmp which handles events and 
 					interaction and forwards the request to helper methods for further processing.

********************************************************************************************************************************************************************************************************************************************
*	@Changes
********************************************************************************************************************************************************************************************************************************************	
*/
({ 
    /**
     * **********************************************************************************************************************
     * @Description
     * This method fires a event to create a new row
     * **********************************************************************************************************************
     * @param	cmp		component passed from the controller	
     * **********************************************************************************************************************
     **/
    addNewRow : function(component, event, helper) {
        
        component.getEvent("AddRowEvt").fire();
    },
    /**
     * **********************************************************************************************************************
     * @Description
     * This method fires a event to create a remove a row
     * **********************************************************************************************************************
     * @param	cmp		component passed from the controller	
     * **********************************************************************************************************************
     **/
    removeRow : function(component,event,helper) {
        component.getEvent("DeleteRowEvt").setParams({"indexVar" : component.get("v.rowIndex") }).fire();
    }, 
    /**
     * **********************************************************************************************************************
     * @Description
     * This method component name change
     * **********************************************************************************************************************
     * @param	cmp		component passed from the controller	
     * **********************************************************************************************************************
     **/
    onCompNameChange : function(component,event,helper) {
        component.set("v.isPartDisabled",false);        
        helper.handlerCompNameChange(component,event);
    },
    /**
     * **********************************************************************************************************************
     * @Description
     * This method handle part number change
     * **********************************************************************************************************************
     * @param	cmp		component passed from the controller	
     * **********************************************************************************************************************
     **/
    onPartNumberChange : function(component,event,helper) {
        component.set("v.isSerialDisabled",false);
        helper.handlerPartNumChange(component,event);
    },
     /**
     * **********************************************************************************************************************
     * @Description
     * This method handle serial number change
     * **********************************************************************************************************************
     * @param	cmp		component passed from the controller	
     * **********************************************************************************************************************
     **/
    onSerialNumberChange : function(component,event,helper) {
         component.set("v.isHwDisabled",false);
         component.set("v.isSwDisabled",false);
        helper.handleSerialNumChange(component,event);
    },
    /**
     * **********************************************************************************************************************
     * @Description
     * This method handle serial number change
     * **********************************************************************************************************************
     * @param	cmp		component passed from the controller	
     * **********************************************************************************************************************
     **/
    handleSelection : function(component,event,helper) {
        console.log("ControlSysSelected");
        var selectedControlSys = event.getParam("message");

        if(!$A.util.isEmpty(selectedControlSys)) {
            component.set("v.selectedControlSys",selectedControlSys);
            component.set("v.isComNameDisabled",false);
            //helper.getComponentNames(component,selectedControlSys);
        }
    },
})
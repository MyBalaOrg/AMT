({
    scriptsLoaded : function(component, event, helper) {
        console.log('in scripts loaded');
        amtrak.toggleLightningSpinner(component.find("fidget-spinner"), false);
        amtrak.scriptLoadedCheck();
        amtrak.toggleLightningSpinner(component.find("fidget-spinner"), true);
    },
    doInit: function(component,event,helper) {
        helper.checkPermission(component,event);
    },
    softDelete: function(component,event,helper) {
        helper.softDeleteObservation(component,event);
    },
    openSearchTestNumber: function(component,event,helper) {
        component.set("v.showTestSearch", true);
    },
    handleToggleLightningSpinner : function(component, event, helper) {
        event.stopPropagation();
        var paramMap = event.getParam("paramMap");
        amtrak.toggleLightningSpinner(component.find("fidget-spinner"), paramMap.hideSpinner);
    },
    handleAllTestSearch : function(component, event, helper) {
        event.stopPropagation();
        var paramMap = event.getParam("paramMap");
        var recordId = component.get("v.recordId");
        var params = {
            "searchKey" : paramMap.searchKey,
            "observationId" : recordId
        }
        helper.performSearch(component, event, params);
    },
    closeSearchResultModal : function(component, event, helper) {
        event.stopPropagation();
        component.set("v.showTestSearch", false);
        component.set("v.showUpdate", false);
    },
    handleUpdateObservationTest: function(component,event,helper) {
        event.stopPropagation();
        component.set("v.showTestSearch", false);
        var observationId = component.get("v.recordId");
        var selectedList = component.get("v.selectedList");
        var osrId;
        if (!$A.util.isEmpty(selectedList)) {
            osrId = selectedList[0].recordId;
        }
        var params = {
            "observationId" : observationId,
            "osrId" : osrId
        }
        helper.updateObservationTest(component,event, params);
    },
})
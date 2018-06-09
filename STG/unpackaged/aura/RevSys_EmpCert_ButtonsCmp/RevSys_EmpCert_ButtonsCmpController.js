({
    scriptsLoaded : function(component, event, helper) {
        console.log('in scripts loaded');
        amtrak.toggleLightningSpinner(component.find("fidget-spinner"), false);
        amtrak.scriptLoadedCheck();
        amtrak.toggleLightningSpinner(component.find("fidget-spinner"), true);
    },
    doInit: function(component,event,helper) {
        helper.loadECRecord(component,event);
    },
    printDetails: function(component,event,helper) {
        helper.printDetailsOnEC(component,event);
    },
    handleToggleLightningSpinner : function(component, event, helper) {
        event.stopPropagation();
        var paramMap = event.getParam("paramMap");
        amtrak.toggleLightningSpinner(component.find("fidget-spinner"), paramMap.hideSpinner);
    },
    certifyRecord: function(component,event,helper) {
        console.log('In controller');
        helper.checkForCertification(component,event);
    },
    openModel: function(component, event, helper) {
        component.set("v.isOpenWarning", true);
    },
    closeModel: function(component, event, helper) {
        component.set("v.isOpenWarning", false);
    },
})
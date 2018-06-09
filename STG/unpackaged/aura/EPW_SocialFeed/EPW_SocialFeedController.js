({
	doInit : function(component,event,helper) {
        var compBody=component.find('compBody');        
		var device = $A.get("$Browser.formFactor");
        if(device == 'DESKTOP'  || !component.get("v.showTileHeader")){
            $A.util.addClass(compBody,'slds-show');
        }else{
            $A.util.addClass(compBody,'slds-hide');
        
        }
	},
    toggleHeader:function(component, event, helper) {
        helper.toggleHeader(component, event,'articleOne');
    },
    
    doneRendering : function(component,event,helper) {
        //to block locker services version degraded to 39 and folowing changes are made
        if(component.get("v.scriptsLoaded")) {
            $('.iframe').contents().find('#twitter-widget-0').css('max-width', '100%');
        }
    },
    
    afterScriptsLoaded : function(component,event,helper) {
        component.set("v.scriptsLoaded", true);
    }
})
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
    }
})
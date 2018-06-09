({     
    save : function(component, event, helper) {
        helper.save(component);        
    },
    
    showSpinner : function (component, event, helper) {
        var spinner = component.find("spinner");
        $A.util.removeClass(spinner, "slds-hide");
        $A.util.addClass(spinner, "slds-show");
    },
    
    hideSpinner : function (component, event, helper) {       
       var spinner = component.find("spinner");
       $A.util.removeClass(spinner, "slds-show");
       $A.util.addClass(spinner, "slds-hide");
    },   
})
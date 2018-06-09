({
    openModel: function(component, event, helper) {
        // for Display Model,set the "isOpen" attribute to "true"
        component.set("v.isOpen", true);
    },
    
    closeModel: function(component, event, helper) {
        // for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
        component.set("v.isOpen", false);
    },
    
    confirmPressed : function(component,event,helper) {
        //Inform parent on button click
        component.getEvent("PopupEvent").setParams({"message" : "Confirm" }).fire();
        component.set("v.isOpen", false);
    }
})
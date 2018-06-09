/**
 * Edited by Joe Callin on 8/12/2017.
 */
({
    getSitePrefix: function(component) {
        var action = component.get("c.getSitePrefix");
        action.setCallback(this, function(actionResult) {
            var sitePrefix = actionResult.getReturnValue();
            component.set("v.sitePrefix", sitePrefix);
        });
        $A.enqueueAction(action);
    },
    getIsGuest: function(component) {
        // Create the action
        var action = component.get("c.isGuestUser");

        // Add callback behavior for when response is received
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                component.set("v.isGuest", response.getReturnValue());
            }
            else {
                console.log("Failed with state: " + state);
            }
            // component.set("v.isInit", true);
        });
        component.set("v.isGuestInit", true);

        // Send action off to be executed
        $A.enqueueAction(action);
    },
    setLabel: function(component, extendedText, attribute) {
        var labelRegex = /^\$Label\.([a-zA-Z0-9_]*\.){1}([a-zA-Z0-9_]+)$/;
        var text = component.get('v.labelText');
        if(extendedText != undefined){
            text = extendedText;
        }
        if (text !== undefined && text !== '') {
            if (text.indexOf('$Label') !== -1) {
                var label = '';
                if (labelRegex.test(text)) {
                    label = $A.getReference(text);
                } else {
                    label = 'This is an invalid label. Please check it.'
                }
                if(extendedText != undefined){
                    component.set('v.' + attribute, label);
                }else{
                    component.set('v.label', label);
                }
            } else {
                component.set('v.label', text);
            }
        } else {
            component.set('v.label', text);
        }
    },
    setLabelEvent: function(component, text, attribute) {
        this.setLabel(component, text, attribute);
    }
})
({
    createInfo: function(component) {
        
        var fields = component.get("v.readOnlyFields");
        console.log("RevSys_ObservationEmployeeInfoCmp fields: " + JSON.stringify(fields));
        var observation = component.get("v.observation");
        console.log("RevSys_ObservationEmployeeInfoCmp observation ID: " + observation.Id);
        var outputDesc = [];
        var labels = {};
        for (var i = 0; i < fields.length; i++) {
            var field = fields[i];
        	var config = {};
            if (observation != null) {
                config = {"componentDef" : "lightning:outputField", "attributes" : {}};
                config.attributes.fieldName = field.fieldPath;
                console.log("config.attributes.fieldName : " + config.attributes.fieldName);
            }
            outputDesc.push([
                config.componentDef,
                config.attributes
            ]);
        }
        $A.createComponents(outputDesc, function(components, status, errorMsg) {
            console.log("RevSys_ObservationEmployeeInfoCmp - entering info createcomponents");
	        if (status === "SUCCESS") {
                console.log("RevSys_ObservationEmployeeInfoCmp - createcomponents: " + status);
	            component.set("v.employeeInfo", components);
	        }
	        else if (status === "INCOMPLETE") {
	            console.log("No response from server or client is offline.")
	        }
	        else if (status === "ERROR") {
	            console.log("Error: " + errorMessage);
	        }
        });
    },
})
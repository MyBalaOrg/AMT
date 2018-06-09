({
	populatePropertiesArray : function(component) {

		//check if Ask CEO Tile to show Ask button
		if(component.get("v.recordTypeFilter") == 'Ask CEO Feedback'){
			component.set("v.askCeo", true);
		}

		var properties = [];
		properties.push(component.get("v.primaryObject"));
		properties.push(component.get("v.recordTypeFilter"));
		properties.push(component.get("v.headerField"));
		properties.push(component.get("v.descriptionField"));
		properties.push(component.get("v.secondaryObject"));
		properties.push(component.get("v.secondaryRelationshipField"));
		properties.push(component.get("v.secondaryField"));
		properties.push(component.get("v.numberRecords"));
		properties.push(component.get("v.headerUrl"));
		properties.push(component.get("v.orderByField"));
		if (component.get("v.orderBy") == "Ascending"){
			properties.push("ASC");
		}else if (component.get("v.orderBy") == "Descending"){
			properties.push("DESC");
		}
		properties.push(component.get("v.filterField"));
		properties.push(component.get("v.filterCriteria"));

		
		console.log(properties);
		this.getObjectRows(component,properties);
	},

	getObjectRows : function(component, properties){
		var action = component.get("c.retrieveLists");
        action.setParams({ "properties" : properties ,
        					"viewPrivate" : component.get("v.viewPrivate")
        				 });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
            	var returnValue = response.getReturnValue();
            	var output = [];
            	for (var key in returnValue){
            		output.push({value:returnValue[key], key:key});
            	}
            	console.log(output);
            	component.set("v.output", output);
            	
            } else {
                console.log(response.getError());
            }
            
        });
        $A.enqueueAction(action);
	},

	}
})
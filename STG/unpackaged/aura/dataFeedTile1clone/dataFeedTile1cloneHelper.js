({
    /**
    *------------------------------------------
    * @Name: populatePropertiesArray
    * @Description
    * populates array named properties
    *------------------------------------------
    * @param    component, event, helper		reference to component, event and helper
    * @return   
    *------------------------------------------
    **/
    populatePropertiesArray : function(component) {
        
        //check if Ask CEO Tile to show Ask button
        if(component.get("v.recordTypeFilter") == 'Ask CEO Feedback'){
            component.set("v.askCeo", true);
        }

        //check if custom icon exists
        if(component.get("v.iconStaticResource") != ''){
            component.set("v.customIcon", true);
        }

        //check if custom icon exists
        if(component.get("v.primaryObject") == 'Case'){
            component.set("v.caseModal", true);
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
        properties.push(component.get("v.imageUrl"));       
        //console.log(properties);
        this.getObjectRows(component,properties);
    },
    
    /**
    *------------------------------------------
    * @Name: getObjectRows
    * @Description
    * retreives the list of records for the selected object type
    *------------------------------------------
    * @param    component, event, helper		reference to component, event and helper
    * @return   
    *------------------------------------------
    **/
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
                var listkey = [];
                for (var key in returnValue){
                    output.push({value:output[key], key:key});
                    
                }
                listkey = Array.from( output.keys() );
                console.log(output);
                component.set("v.output", output);
                var pageSize = component.get("v.pageSize");
                console.log("pagesize "+pageSize);
                component.set("v.totalRecords", component.get("v.output").length);
                component.set("v.startPage",0);
                component.set("v.endPage",pageSize-1);
                var PaginationList = [];
                var counter = 0;
                for(var i=counter; i< pageSize+counter; i++){
                    var innerkey = listkey[i];
                    PaginationList.push({value:returnValue[key], key:innerkey});
                    
                }
                component.set('v.PaginationList', PaginationList);
                console.log('PaginationList helper'+PaginationList);
                /*console.log(pageSize);
                console.log(endPage);
                console.log(totalRecords);*/
            } else {
                console.log(response.getError());
            }
            
        });
        $A.enqueueAction(action);
    },
    helperFun : function(component,event,secId) {
	  var acc = component.find(secId);
        	for(var cmp in acc) {
        	$A.util.toggleClass(acc[cmp], 'slds-show');  
        	$A.util.toggleClass(acc[cmp], 'slds-hide');  
       }
	},
 })
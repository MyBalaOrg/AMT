({
    /**
    *------------------------------------------
    * @Name: doInit
    * @Description
    * populates array named properties
    *------------------------------------------
    * @param    component, event, helper		reference to component, event and helper
    * @return   
    *------------------------------------------
    **/
	doInit : function(component, event, helper) {
		helper.populatePropertiesArray(component);
        helper.setPaginationParams(component);

        if(component.get("v.recordsPerPage") == undefined){
            component.set("v.recordsPerPage", component.get("v.numberRecords"));
            component.set("v.showButtons", false);
        }else{
            component.set("v.showButtons", true);

        }
	},
	
    /**
    *------------------------------------------
    * @Name: viewSecondary
    * @Description
    * Shows the dialog with record details
    *------------------------------------------
    * @param    component, event, helper		reference to component, event and helper
    * @return   
    *------------------------------------------
    **/
	viewSecondary : function(component, event, helper) {
		var selectedItem = event.currentTarget;
		var index = selectedItem.dataset.index;
		document.getElementById(index + component.get("v.header")).style.display = "block";
		component.set("v.openModal", index + component.get("v.header"));
	},

    /**
    *------------------------------------------
    * @Name: hideSecondary
    * @Description
    * hides the dialog
    *------------------------------------------
    * @param    component, event, helper		reference to component, event and helper
    * @return   
    *------------------------------------------
    **/
	hideSecondary : function(component, event, helper) {
		document.getElementById(component.get("v.openModal")).style.display = "none";
	},
    
    sectionOne : function(component, event, helper) {
       helper.helperFun(component,event,'articleOne');
    },

    previous : function(component, event, helper) {
       component.set("v.currentPage", component.get("v.currentPage")-1);
    },

    next : function(component, event, helper) {
       component.set("v.currentPage", component.get("v.currentPage")+1);
    },

     currentPageChange : function(component, event, helper) {
        var upperRange = component.get("v.currentPage") * component.get("v.recordsPerPage");
        var lowerRange = upperRange - component.get("v.recordsPerPage") + 1;
        
        if(upperRange > component.get("v.numberRecords")){
            lowerRange = component.get("v.numberRecords");
        }

        for(var i = 1; i <= component.get("v.numberRecords"); i++){
            if(i <= upperRange && i >= lowerRange){
                document.getElementById("row" + i).style.display = "block";           
            }else{
                document.getElementById("row" + i).style.display = "none";           
            }
        }
    },
  
})
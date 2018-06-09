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
    next : function(component, event){
        var sObjectList = component.get("v.output");
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var pageSize = component.get("v.pageSize");
        var Paginationlist = [];
        var counter = 0;
        for(var i=end+1; i<end+pageSize+1; i++){
            if(sObjectList.length > i){
                Paginationlist.push(sObjectList[i]);
                /*for (var key in sObjectList){
                    PaginationList.push({value:returnValue[key], key:key});
                }*/ 
            }
            counter ++ ;
        }
        console.log('PaginationList'+PaginationList);
        start = start + counter;
        end = end + counter;
        component.set("v.startPage",start);
        component.set("v.endPage",end);
        component.set('v.PaginationList', Paginationlist);
        console.log('PaginationList'+PaginationList);
        console.log(pageSize);
        console.log(endPage);
        console.log(totalRecords);
    },
     previous : function(component, event){
        var sObjectList = component.get("v.output");
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var pageSize = component.get("v.pageSize");
        var Paginationlist = [];
        var counter = 0;
         for(var i= start-pageSize; i < start ; i++){
             if(i > -1){
                 Paginationlist.push(sObjectList[i]);
                 counter ++;
             }else{
                 start++;
             }
         }
        start = start - counter;
        end = end - counter;
        component.set("v.startPage",start);
        component.set("v.endPage",end);
        component.set('v.PaginationList', Paginationlist);
         console.log(PaginationList);
                console.log(pageSize);
                console.log(endPage);
                console.log(totalRecords);
    },
})
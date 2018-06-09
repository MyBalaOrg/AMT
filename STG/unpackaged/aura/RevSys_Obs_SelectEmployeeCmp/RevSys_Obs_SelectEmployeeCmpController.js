({
	handlePerformSearch : function(component, event, helper) {
		event.stopPropagation();
        var paramMap = event.getParam("paramMap");
        var params = { 
            "searchKey" : paramMap.searchKey,
            "deptCraftMapJSON" : JSON.stringify(component.get("v.deptCraftMap")),
            "allCraftDeptMapJSON" : JSON.stringify(component.get("v.allCraftDeptMap"))
        };
        helper.performSearch(component, params);
	},
    
    handleAllEmployeeSearch : function(component, event, helper) {
        var params = {
            "searchKey" : "",
            "deptCraftMapJSON" : JSON.stringify(component.get("v.deptCraftMap")),
            "allCraftDeptMapJSON" : JSON.stringify(component.get("v.allCraftDeptMap"))
        }
        helper.performSearch(component, params);
    }
})
({
    handlePerformSearch : function(component, event, helper) {
        event.stopPropagation();
         debugger;
        
        var paramMap = event.getParam("paramMap");
        var params = { 
            "searchKey" : paramMap.searchKey,
            "filterMap" : JSON.stringify(component.get("v.filterMap")),
            "recordType" : JSON.stringify(component.get("v.selectedRecordType")),
        };
        console.log("*** params : " + JSON.stringify(params));
        console.log("recordtype"+ JSON.stringify(component.get("v.selectedRecordType")));
        helper.performSearch(component, params);
    },
    
    handleEmpSearchNon1872RTChange : function(component, event, helper) {
        var params = { 
            "searchKey" : "", 
            "filterMap" : JSON.stringify(component.get("v.filterMap")),
            "recordType" : JSON.stringify(component.get("v.selectedRecordType")),
        };
        console.log("*** params : " + JSON.stringify(params));
        console.log("recordtype"+ JSON.stringify(component.get("v.selectedRecordType")));
        helper.performSearch(component, params);
    }
})
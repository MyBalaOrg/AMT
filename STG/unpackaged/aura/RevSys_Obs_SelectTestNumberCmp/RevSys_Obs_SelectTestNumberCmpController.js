({
    scriptsLoaded : function(component, event, helper) {
        amtrak.scriptLoadedCheck();
    },

	onclickToggleSelectAll : function(component, event, helper) {
        var selectAll = !$A.util.isEmpty(event.target.value);
		var osrWrapperList = component.get("v.osrWrapperList");
        osrWrapperList.forEach(function(obsWrapper) {
            obsWrapper.selected = selectAll;
        });
        component.set("v.osrWrapperList", osrWrapperList);
	},
    
    toggleSelectTestNumber : function(component, event, helper) {
        event.stopPropagation();
        var index = event.currentTarget.dataset.index;
        if (!$A.util.isEmpty(index)) {
            var osrWrapperList = component.get("v.osrWrapperList");
            osrWrapperList[index].selected = !osrWrapperList[index].selected;
            component.set("v.osrWrapperList", osrWrapperList);
        }
    },
    
    updateObsTemplateFields : function(component, event, helper) {
        
        var obsTemplate = component.get("v.obsTemplate");
        if(obsTemplate["Department__c"] != "" && ($A.util.isEmpty(obsTemplate["Craft__c"]) || obsTemplate["Craft__c"] == "")){
            obsTemplate["Craft__c"] = "All";
        }
        
        var selectedDept = obsTemplate["Department__c"];
        var selectedCraft = obsTemplate["Craft__c"];
        
        var resetOsrWrapList = false;
        
		var osrWrapperlist = component.get("v.osrWrapperListCopy");
        
        var osrFilteredList = [];
        
        if(selectedDept != ""){
            if(!$A.util.isEmpty(osrWrapperlist)){
                osrWrapperlist.forEach(function(obsWrapper) {
                    var deptCraftMapObj = obsWrapper.deptCraftMap;
                    
                    if(!$A.util.isEmpty(deptCraftMapObj)){
                        for(var depCraftKey in deptCraftMapObj){
                            if(deptCraftMapObj.hasOwnProperty(depCraftKey)){
                                var depCraft = deptCraftMapObj[depCraftKey];
                                console.log("depCraft : " + JSON.stringify(depCraft));
                                var doAdd = false;
                                if(!$A.util.isEmpty(depCraft) && depCraftKey == selectedDept){
                                    for(var depKey in depCraft){
                                        if(depCraft.hasOwnProperty(depKey)){
                                            if((selectedCraft == "All" || selectedCraft == "") && depCraft[depKey] == true){
                                                doAdd = (!doAdd) ? true : true;
                                                //osrFilteredList.push(obsWrapper);
                                            } else if (depCraft[depKey] == true && (selectedCraft != "All" && depKey == selectedCraft)){
                                                doAdd = (!doAdd) ? true : true;
                                                //osrFilteredList.push(obsWrapper);
                                            }
                                        }
                                    }
                                } 
                                if(doAdd){
                                    osrFilteredList.push(obsWrapper);
                                }
                            }
                        }
                    }
                    
                });
            }
        } else {
            obsTemplate["Craft__c"] = "";
            resetOsrWrapList = true;
        }
        
        component.set("v.obsTemplate", obsTemplate);
        if(!$A.util.isEmpty(osrFilteredList)){
        	component.set("v.osrWrapperList", osrFilteredList);    
        } else if (!resetOsrWrapList) {
            //please show toast message
            component.set("v.osrWrapperList", osrFilteredList);
            amtrak.fireErrorToastEvent(component, "Incomplete Form!", "There are no test associated with given department and craft. Please select valid department and craft.");
        } else if(resetOsrWrapList){
            component.set("v.osrWrapperList", component.get("v.osrWrapperListCopy"));
        }
        
    }
})
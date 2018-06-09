({
	onclickSearchButton : function(component, event, helper) {
        event.stopPropagation();
        var params = {'searchKey' : component.get("v.searchKey")}; 
		amtrak.fireMapParamEvent(component, "performSearch", params);
	},

    searchEnterKeyUp : function(component, event, helper) {
        event.stopPropagation();
        if(event.getParams().keyCode == 13){
            var params = {'searchKey' : component.get("v.searchKey")}; 
            var filterList = component.get("v.filterList");
            if (filterList.length > 0) {
                var filterMap = component.get("v.filterMap");
                var value = event.getSource().get("v.value"); 
                var label = event.getSource().get("v.label"); 
                filterMap[label] = value;
                component.set("v.filterMap",filterMap);
            }
          amtrak.fireMapParamEvent(component, "performSearch", params);
        }
    },
    
    handleSetResultList : function(component, event, helper) {
        console.log("----------");
        console.log("Handle Set Result List");
        var args = event.getParam("arguments");
        if (!$A.util.isEmpty(args)) {
            component.set("v.openResultModal", true);
            component.set("v.resultList", args.resultList);
            console.log("Opening Search Result Modal");
            var showInlineResult = component.get("v.showInlineResult");
            if (showInlineResult) {
                var searchResult = component.find("search-result");
                var filteredList = args.resultList;
                console.log("*** filteredList : " + JSON.stringify(filteredList));
                if (!$A.util.isEmpty(filteredList)) {
                    var selectedList = component.get("v.selectedList");
                    if (!$A.util.isEmpty(selectedList)) {
                        filteredList.forEach(function(filter){
                            selectedList.forEach(function(select){
                                if(select.theNumber == filter.theNumber){
                                    filter.selected = true;
                                }
                            });
                        });
                    }
                }
                searchResult.set("v.filteredList", args.resultList);
                console.log("-- filteredList : " + JSON.stringify(args.resultList));
            }
        }
        console.log("----------");
    },
    
    handleConfirmedItemSelections : function(component, event, helper) {
        console.log("----------");
        console.log("Handle Confirmed Item Selections");
        event.stopPropagation();
        var paramMap = event.getParam("paramMap");
        var selectedList = component.get("v.selectedList");
        var selectedItemIdSet = component.get("v.selectedItemIdSet");
        
        if (!$A.util.isEmpty(paramMap.selectedList)) {
            paramMap.selectedList.forEach(function(item) {
                if (selectedItemIdSet.indexOf(item.recordId) < 0) {
                    var isMultiSelect = component.get("v.isMultiSelect");
                    if (isMultiSelect) {
                        selectedList.push(item);
                        selectedItemIdSet += item.recordId + " ";
                    } else {
                        selectedList = [];
                        selectedList.push(item);
                        selectedItemIdSet = "";
                        selectedItemIdSet += item.recordId + " ";
                    }
                }
            }); 
            console.log(selectedList);
            component.set("v.selectedList", selectedList);
            component.set("v.selectedItemIdSet", selectedItemIdSet);
        }
        component.set("v.openResultModal", false);
        console.log("----------");
    },

    handleSelectedItems : function(component, event, helper) {
        console.log("Handle Selected Items");
        event.stopPropagation();
        var paramMap = event.getParam("paramMap");
        var selectedList = component.get("v.selectedList");
        var selectedItemIdSet = component.get("v.selectedItemIdSet");
        
        if (!$A.util.isEmpty(paramMap.selectedList)) {
            var isMultiSelect = component.get("v.isMultiSelect");
            paramMap.selectedList.forEach(function(item) {
                if (selectedItemIdSet.indexOf(item.recordId) < 0) {                    
                    if (isMultiSelect) {
                        selectedList.push(item);
                        selectedItemIdSet += item.recordId + " ";
                    } else {
                        selectedList = [];
                        selectedList.push(item);
                        selectedItemIdSet = "";
                        selectedItemIdSet += item.recordId + " ";
                    }
                } else if (selectedItemIdSet.indexOf(item.recordId) < 0 ) {
                    if (isMultiSelect) {
                        selectedList.push(item);
                        selectedItemIdSet += item.recordId + " ";
                    } else {
                        selectedList = [];
                        selectedList.push(item);
                        selectedItemIdSet = "";
                        selectedItemIdSet += item.recordId + " ";
                    }
                }
            }); 
        }
        if (!$A.util.isEmpty(paramMap.unselectedItem)) {
            var unselectedItem = paramMap.unselectedItem;

            var cleanSelectedItems = selectedList.filter(function(item) {
                return item.recordId != unselectedItem.recordId;
            });
            selectedItemIdSet = selectedItemIdSet.replace(unselectedItem.recordId, "");
            component.set("v.selectedList", cleanSelectedItems);
            component.set("v.selectedItemIdSet", selectedItemIdSet.trim());
        }
        else {
            component.set("v.selectedList", selectedList);
            component.set("v.selectedItemIdSet", selectedItemIdSet);            
        }
    },
    
    removeSelectedItem : function(component, event, helper) {
        event.stopPropagation();
        var selectedList = component.get("v.selectedList");
        var selectedItemIdSet = component.get("v.selectedItemIdSet");
        var removeIndex = event.currentTarget.dataset.rowIndex;
        try {
            selectedItemIdSet = selectedItemIdSet.replace(selectedList[removeIndex].recordId, "");
            selectedList.splice(removeIndex, 1);
            component.set("v.selectedItemIdSet", selectedItemIdSet.trim());
            component.set("v.selectedList", selectedList);
        } catch (err) {
            console.log(err);
        }
    },

    handleFilterBlur : function(component, event, helper) {
        event.stopPropagation();
        var filterMap = component.get("v.filterMap");
        console.log("*** filterMap on filter blur : " + JSON.stringify(filterMap));
        var value = event.getSource().get("v.value"); 
        var label = event.getSource().get("v.label"); 
        filterMap[label] = value;
        /*if(component.get("v.selectedRecordType.Name") != "Form-1872"){
            filterMap["Craft"] = value;
        }*/
        console.log("*** filterMap on filter blur AFTER : " + JSON.stringify(filterMap));
        component.set("v.filterMap",filterMap);
    }
})
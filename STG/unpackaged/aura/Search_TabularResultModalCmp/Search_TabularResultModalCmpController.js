({
    confirmItemSelections : function(component, event, helper) {
        event.stopPropagation();
        var resultList = component.get("v.resultList");
        var isMultiSelect = component.get("v.isMultiSelect");
        var selectedItem = component.get("v.selectedItemWrapper");
        var selectedList = [];
        if (isMultiSelect) {
            resultList.forEach(function(item) {
                if (item.selected) {
                    selectedList.push(item);
                }
            });
        } else {
            selectedList.push(selectedItem);
        }
        var params = { "selectedList" : selectedList };
        amtrak.fireMapParamEvent(component, "confirmedItemSelections", params);        
    },

    handleOnSelect : function(component, event, helper) {
        event.stopPropagation();
        var resultList = component.get("v.resultList");
        var isMultiSelect = component.get("v.isMultiSelect");
        var selectedList = [];
        var unselectedItem;
        if (isMultiSelect) {
            resultList.forEach(function(item) {
                if (item.selected) {
                    selectedList.push(item);
                }
            });
            var item = event.getSource().get("v.text");
            if (!item.selected) {
                unselectedItem = item;
            }
        } else {
            var selected = event.getSource().get("v.text");
            component.set("v.selectedItemWrapper", selected);
            var selectedItem = component.get("v.selectedItemWrapper");
            selectedList = [];
            selectedList.push(selectedItem);
            console.log("selected Item: " + selectedItem.recordId + " " + selectedItem.selected);
        }
        var params = { "selectedList" : selectedList}

        if (!$A.util.isEmpty(unselectedItem)) {
            params.unselectedItem = unselectedItem;
        }

        amtrak.fireMapParamEvent(component, "sendSelectedItems", params);        
    },
    
	closeSearchResultModal : function(component, event, helper) {
        event.stopPropagation();
		component.set("v.openResultModal", false);
	},
    
    onkeyupFilterResults : function(component, event, helper) {
        console.log("On keyup Filter Results");
        event.stopPropagation();
        var performFilter = false;
        var deleted = event.keyCode === 8;
        var colIndex = event.currentTarget.dataset.colIndex;
        var filterKey = event.currentTarget.value;
        var filterKeyList = component.get("v.filterKeyList");
        var newFilteredList = [];
        if (deleted) {
            filterKeyList[colIndex] = filterKey;
            console.log("*** filterKeyList in deleted : " + JSON.stringify(filterKeyList));
            var filteredList = component.get("v.resultList");
            console.log("*** filteredList in deleted : " + JSON.stringify(filteredList));
            filteredList.forEach(function(item) {
                var matched = true;
                try {
                    filterKeyList.forEach(function(keyValue) {
                        if (!$A.util.isEmpty(keyValue) && !$A.util.isEmpty(item.fieldValues[colIndex]) && !(item.fieldValues[colIndex].toLowerCase().indexOf(keyValue.toLowerCase()) >= 0)) {
                            throw BreakException;
                        }
                    });
                } catch (err) {
                    console.log("Exception Caught");
                    matched = false;
                }
                if (matched) {
                    newFilteredList.push(item);
                }
            });
            component.set("v.filteredList", newFilteredList);
        } else if (filterKey.length > 1) {
            var filteredList = component.get("v.filteredList");
            console.log("## filteredList : " + JSON.stringify(filteredList));
            filteredList.forEach(function(item) {
                if (!$A.util.isEmpty(filterKey) && !$A.util.isEmpty(item.fieldValues[colIndex]) && (item.fieldValues[colIndex].toLowerCase().indexOf(filterKey.toLowerCase()) >= 0)) {
                    newFilteredList.push(item);
                }  
            });
            component.set("v.filteredList", newFilteredList);
        }
    },
    
    onblurFilterResults : function(component, event, helper) {
        console.log("On blur Filter Results");
        event.stopPropagation();
        var colIndex = event.currentTarget.dataset.colIndex;
        var filterKey = event.currentTarget.value;
        var filterKeyList = component.get("v.filterKeyList");
        filterKeyList[colIndex] = filterKey;
        component.set("v.filterKeyList", filterKeyList);
        console.log(filterKeyList);
    },

    onRadio: function(component, evt) {
        var selected = evt.getSource().get("v.text");
        component.set("v.selectedItemWrapper", selected);
    }

})
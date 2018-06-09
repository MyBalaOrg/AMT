({
    createTestList : function(component, event, helper) {
     //   helper.buildTestList(component);
    },

    handleCreateTreeGrid : function(component, event, helper) {

    },

    handleOnSelect : function(component, event, helper) {
        event.stopPropagation();
        var resultList = component.get("v.testWithObservationsList");
        var selectedList = [];
        resultList.forEach(function(item) {
            if (item.selected) {
                selectedList.push(item);
            }
        });
        var params = { "selectedList" : selectedList };
        amtrak.fireMapParamEvent(component, "sendSelectedEmployee", params);        
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
            var filteredList = component.get("v.testWithObservationsList");
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

})
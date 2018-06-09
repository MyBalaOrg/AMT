({
    /**
    * @author        Duy Tran, Deloitte Consulting
    * @date          10/15/2016    Initial creation
    * @description   Function to generate a list of possible result from user input
    */
    generateResultItems : function(component, searchKey, isDelete) {
        var resultItems = [];
        var listItems = [];
        if (searchKey.length <= 3 || isDelete) {
            listItems = component.get("v.listItems");
        } else {
            listItems = component.get("v.resultItems");
        }
        for (var i = 0; i < listItems.length; i++) {
            if ($A.util.isEmpty(listItems[i].searchValue)) {
                if (this.itemContainsSearchKey(listItems[i].label.toLowerCase(), searchKey.toLowerCase())) {
                    resultItems.push(listItems[i]);
                }
            } else {
                if (this.itemContainsSearchKey(listItems[i].searchValue.toLowerCase(), searchKey.toLowerCase())) {
                    resultItems.push(listItems[i]);
                }
            }
        }
        component.set("v.resultItems", resultItems);
        this.displayResultItems(component);
    },
    
    /**
    * @author        Duy Tran, Deloitte Consulting
    * @date          10/15/2016    Initial creation
    * @description   Function to check if an item contains the search keys
    */
    itemContainsSearchKey : function(itemTitle, searchKey) {
        var keyList = searchKey.split(" ");
        var keyFound = (keyList.length > 0);
        keyList.forEach(function(keyValue) {
        	keyFound = keyFound && (itemTitle.indexOf(keyValue) >= 0);
        });
        return keyFound;
    }, 
    
    /**
    * @author        Duy Tran, Deloitte Consulting
    * @date          10/15/2016    Initial creation
    * @description   Function to display the list of possible result
    */
	displayResultItems : function(component) {
        var resultItems = component.get("v.resultItems");
        component.set("v.isExpanded", !$A.util.isEmpty(resultItems));
    },
    
    /**
    * @author        Duy Tran, Deloitte Consulting
    * @date          12/17/2016    Initial creation
    * @description   Function to determine if selected item exist in list.
    */
    itemExistsInList : function(component, itemTitle, listItems) {
        var itemFound = false;
        listItems.forEach(function(item) {
            if (item.title === itemTitle) {
                itemFound = true;
                component.set("v.selectedItemValue", item.value);
                return; 
            }
        });
        return itemFound;
    }
    
})
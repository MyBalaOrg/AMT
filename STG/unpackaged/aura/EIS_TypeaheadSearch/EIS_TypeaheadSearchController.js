({
    onblurSearchBox : function(component, event, helper) {
        var value = event.target.value;
        if ($A.util.isEmpty(value)) {
            var itemSelected = component.getEvent("searchItemSelected");
            itemSelected.setParams({
                "selectedItem" : null,
                "auraId" : component.getLocalId(),
                "index" : component.get("v.internalId")
            });
            itemSelected.fire();
            component.set("v.selectedItemLabel", "");
        }
    	setTimeout(function(){ component.set("v.isExpanded", false); }, 1000);    
    },
    
    onkeypressSearchBox : function(component, event, helper) {
    	var keyPressed = "which" in event ? event.which : event.keyCode; //; - 59   Enter - 13
        //if ((keyPressed >= 32 && keyPressed <= 57) || (keyPressed >= 65 && keyPressed <= 90) || (keyPressed >= 97 && keyPressed <= 122)) {
        if ((keyPressed >= 32 && keyPressed <= 126)) {
            var searchKey = event.target.value;
        } else {
            event.preventDefault();
        }
    },
    
    onkeyupSearchBox : function(component, event, helper) {
        console.log(" search key up ");
        var keyPressed = "which" in event ? event.which : event.keyCode;
        var searchKey = event.target.value;
        var previousFetchKey = component.get("v.previousFetchKey");
        if (searchKey.length == 3 && previousFetchKey != searchKey) {
            console.log(" search key up 1 ");
            var fetchEvent = component.getEvent("fetchSearchItems");
            console.log(" fetchEvent cmp : " + JSON.stringify(fetchEvent.setParams));
        	fetchEvent.setParams({
                "origin" : searchKey,
                "auraId" : component.getLocalId(),
                "index" : component.get("v.internalId")
            });
            console.log(" fetchEvent param : " + JSON.stringify(fetchEvent.setParams));
        	fetchEvent.fire();
            component.set("v.previousFetchKey", searchKey);
        } else {
            if (searchKey != component.get("v.oldSearchKey")) {
                component.set("v.oldSearchKey", searchKey);
                helper.generateResultItems(component, searchKey, keyPressed == 8);
            }
        }
    },
    
    /**
    * @author        Duy Tran, Deloitte Consulting
    * @date          10/15/2016    Initial creation
    * @description   Function to handle user selecting value returned from resultList
    */
    handleItemSelection : function(component, event, helper) {
        var index = event.currentTarget.dataset.index;
        var resultItems = component.get("v.resultItems");
        var itemSelected = component.getEvent("searchItemSelected");
        itemSelected.setParams({
            "selectedItem" : resultItems[index],
            "auraId" : component.getLocalId(),
            "index" : component.get("v.internalId")
        });
        itemSelected.fire();
        component.set("v.selectedItemLabel", resultItems[index].label);
        component.set("v.isExpanded", false);
    }
})
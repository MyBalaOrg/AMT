({
    afterRender: function (component, helper) {
        console.log("==== afterRender is running");
        this.superAfterRender();
        component.set("v.filteredList", component.get("v.resultList"));
        var fieldLabels = component.get("v.fieldLabels");
        var filterKeyList = [];
        fieldLabels.forEach(function(label) {
            filterKeyList.push("");
        });
        component.set("v.filterKeyList", filterKeyList);
    }
})
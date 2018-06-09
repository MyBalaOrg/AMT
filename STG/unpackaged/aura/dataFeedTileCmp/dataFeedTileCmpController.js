({
	doInit : function(component, event, helper) {
		helper.populatePropertiesArray(component);
	},

	viewSecondary : function(component, event, helper) {
		var selectedItem = event.currentTarget;
		var index = selectedItem.dataset.index;
		document.getElementById(index + component.get("v.header")).style.display = "block";
		component.set("v.openModal", index + component.get("v.header"));
	},

	hideSecondary : function(component, event, helper) {
		document.getElementById(component.get("v.openModal")).style.display = "none";
	},

	
})
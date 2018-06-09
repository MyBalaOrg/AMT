/**
 * dreamforce17-theme - Generates the assets used for Peak Lightning
 * @version 1.0.0
 * @author 7Summits
 *
 * COMPILED FILE DO NOT DIRECTLY EDIT
 */
({
	getPageUrl : function(component, event) {
       var sPageURL = window.location.href;
     //  alert(sPageURL);
       
	},
    toggleSearch: function toggleSearch(component, event, helper) {
        helper.toggleSearch(component);
    },

    hideSearch: function hideSearch(component, event, helper) {
        helper.hideSearch(component);
    }

});
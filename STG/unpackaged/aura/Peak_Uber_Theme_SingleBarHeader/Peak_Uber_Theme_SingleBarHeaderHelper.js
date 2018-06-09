/**
 * dreamforce17-theme - Generates the assets used for Peak Lightning
 * @version 1.0.0
 * @author 7Summits
 *
 * COMPILED FILE DO NOT DIRECTLY EDIT
 */
({

    toggleSearch: function toggleSearch(component) {
        var search = component.find("navSearch");
        var searchValue = component.get('v.searchValue');
        $A.util.toggleClass(component, "navSearch-active");
        $A.util.toggleClass(search, "navSearch-active__content");
        searchValue.value = '';
    },

    hideSearch: function hideSearch(component) {
        var search = component.find("navSearch");
        $A.util.removeClass(component, "navSearch-active");
        $A.util.removeClass(search, "navSearch-active__content");
    },

    getParentAnchor: function getParentAnchor(component, element) {
        while (element !== null) {
            if (element.tagName.toLowerCase() === 'a') {
                this.hideSearch(component);
            }
            element = element.parentNode;
        }
    }

});
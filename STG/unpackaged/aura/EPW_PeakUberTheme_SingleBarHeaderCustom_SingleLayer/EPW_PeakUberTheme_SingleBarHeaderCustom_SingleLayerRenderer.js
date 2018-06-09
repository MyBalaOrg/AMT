/**
 * dreamforce17-theme - Generates the assets used for Peak Lightning
 * @version 1.0.0
 * @author 7Summits
 *
 * COMPILED FILE DO NOT DIRECTLY EDIT
 */
({
    render: function render(component, helper) {
        var ret = this.superRender();
        return ret;
    },

    rerender: function rerender(component, helper) {
        this.superRerender();
    },

    afterRender: function afterRender(component, helper) {
        this.superAfterRender();

        var initSearch = function initSearch(component, helper) {
            // now that we have the parent search component we can reach down to the subcomponent
            // and access the needed elements.
            var resultContainer = searchContainer.getElementsByClassName('result-container')[0];
            var searchButton = searchContainer.getElementsByClassName('search-button')[0];
            var searchField = searchContainer.getElementsByClassName('search-field')[0];

            component.set('v.searchValue', searchField);

            // user clicks result in search results, close search box
            resultContainer.addEventListener('click', function (e) {
                if (e.target) {
                    helper.getParentAnchor(component, e.target);
                }
            });

            // user clicks the search button, close search box
            if (searchButton !== undefined) {
                searchButton.onclick = function () {
                    helper.hideSearch(component);
                };
            }

            // user presses enter key in search box, close search box
            if (searchField !== undefined) {

                // remove search input autocomplete
                searchField.setAttribute('autocomplete', 'off');

                searchField.onkeypress = function (event) {
                    if (event.which === 13 || event.keyCode === 13) {
                        helper.hideSearch(component);
                    }
                };
            }
        };

        // get search container that is in this component
        var searchContainer = document.getElementById('navSearch');

        // if the nav search container isn't null attach events
        if (searchContainer !== null && searchContainer !== undefined) {
            initSearch(component, helper);
        }
        
        //background image of html document
        if(component.get("v.backgroundImageUrl") != null && component.get("v.backgroundImageUrl") != '') {
            document.documentElement.style.background = "url('" + component.get("v.backgroundImageUrl") + "') no-repeat center center fixed";
            document.documentElement.style.backgroundSize = "cover";
        }
        
    },

    unrender: function unrender(component, helper) {
        this.superUnrender(component, helper);
    }

});
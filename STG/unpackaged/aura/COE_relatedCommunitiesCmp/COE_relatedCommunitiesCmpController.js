({
    /**
    *------------------------------------------
    * @Name: doInit
    * @Description
    * this function retrieves discussions stored in FeedItem object
    *------------------------------------------
    * @param    component, event, helper		reference to component, event and helper
    * @return   
    *------------------------------------------
    **/
	doInit : function(component, event, helper) {
		var action = component.get("c.getDiscussionForumFeeds");
        action.setCallback(this, function(response) {
            if(component.isValid() && response.getState() == "SUCCESS" && response.getReturnValue() != null) {
                component.set("v.feedItems", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
	},
    
    /**
    *------------------------------------------
    * @Name: navigateToDiscussionForumLandingPage
    * @Description
    * navigates to discussion forum landing page where user can see discussions grouped by topics
    *------------------------------------------
    * @param    component, event, helper		reference to component, event and helper
    * @return   
    *------------------------------------------
    **/
    navigateToDiscussionForumLandingPage : function(component, event, helper) {
        window.open(window.location.origin + 
                    window.location.pathname.substring(0, window.location.pathname.indexOf('/s/') + 3) + 
                    'topiccatalog', 
                    "_self");
	},
    
    /**
    *------------------------------------------
    * @Name: feedItemClicked
    * @Description
    * navigates to selected discussion page
    *------------------------------------------
    * @param    component, event, helper		reference to component, event and helper
    * @return   
    *------------------------------------------
    **/
    feedItemClicked : function(component, event, helper) {
        window.open(window.location.origin + 
                    window.location.pathname.substring(0, window.location.pathname.indexOf('/s/') + 3) + 
                    'question/' + event.target.id, 
                    "_self");
	}
})
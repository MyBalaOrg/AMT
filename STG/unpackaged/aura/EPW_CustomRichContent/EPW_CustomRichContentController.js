({
    /**
    *------------------------------------------
    * @Name: doInit
    * @Description
    * loads record of the specified object
    *------------------------------------------
    * @param    component, event, helper		reference to component, event and helper
    * @return   
    *------------------------------------------
    **/
	doInit : function(component, event, helper) {
        var application = component.get("v.application");
        var objectName = component.get("v.objectName");
        var fieldName = component.get("v.fieldName");
        var recordType = component.get("v.recordType");
        var title = component.get("v.title");
        var compBody=component.find('compBody');
        var device = $A.get("$Browser.formFactor");
        if(device == 'DESKTOP' || !component.get("v.showTileHeader")){
            $A.util.addClass(compBody,'slds-show');
        }else{
            $A.util.addClass(compBody,'slds-hide');
        
        }

        if(!$A.util.isEmpty(application) && !$A.util.isEmpty(objectName) && !$A.util.isEmpty(fieldName) && !$A.util.isEmpty(recordType) && !$A.util.isEmpty(title)) {
            var action = component.get("c.getRichTextContent");
            action.setParams({
                "application" : application,
                "objectName" : objectName,
                "fieldName" : fieldName,
                "recordTypeName" : recordType,
                "title" : title
            });

            action.setCallback(this, function(response) {
                if(component.isValid() && response.getState() == "SUCCESS" && response.getReturnValue() != null) {

                    if (component.get("v.imageCircle") == true){
                        var returnHtml = response.getReturnValue()['Image__c'];
                        var index = returnHtml.indexOf("img") + 3;
                        var splitHtml = returnHtml.substr(0,index);
                        splitHtml += ' style="border-radius:50%" ';
                        splitHtml += returnHtml.substr(index+1);
                        component.set("v.richContentThumbnail", splitHtml);
                    }else{
                        component.set("v.richContentThumbnail", response.getReturnValue()['Image__c']);
                    }

                    component.set("v.richContent", response.getReturnValue()[fieldName]);
                }
            });
            $A.enqueueAction(action);
        }
	},
    
    /**
    *------------------------------------------
    * @Name: navigateToURL
    * @Description
    * navigates to specified URL in footer
    *------------------------------------------
    * @param    component, event, helper		reference to component, event and helper
    * @return   
    *------------------------------------------
    **/
    navigateToURL : function(component, event, helper) {
        /*var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": component.get("v.tileFooterURL")
        });
        urlEvent.fire();*/
        window.open(component.get("v.tileFooterURL"),"_self");
    },
    toggleHeader:function(component, event, helper) {
        helper.toggleHeader(component, event,'articleOne');
    }
})
({
    /**
    *————————————————————————————————————————————————————
    * @Name: Gaurav Dharra
    * @Description
    * Call helper method to get user information and show it on the model
    *————————————————————————————————————————————————————
    * @param    component, event, helper
    * @return   
    *————————————————————————————————————————————————————
    **/
    showModal : function(component, event, helper) {
        helper.getUserInfo(component);
        component.set("v.staticMessage", $A.get('$Label.c.CEO_Portal_Case_Creation_Static_Message'));
        component.set("v.successMessaege", $A.get("$Label.c.CEO_Portal_Case_Creation_Success_Message"));
        component.set("v.showFormContent", true);
        component.set("v.showOtherFormContent", false);
        component.set("v.showErrorMsg", false);
        component.set("v.showSuccessMsg", false);
        //document.getElementById("modal").style.display = "block";
        component.set("v.showForm", true);
        component.set("v.disableSubmitButton", true);
    },
    /**
    *————————————————————————————————————————————————————
    * @Name: Gaurav Dharra
    * @Description
    * Show and hide fields when modal is closed
    *————————————————————————————————————————————————————
    * @param    component, event, helper
    * @return   
    *————————————————————————————————————————————————————
    **/
    closeModal : function(component, event, helper) {
        component.set("v.showForm", false);
        var question = component.find("question");
        question.set("v.errors", null);
        question.set("v.value", null);
        var subject = component.find("subject");
        subject.set("v.errors", null);
        subject.set("v.value", null);
          },

  
    
    /*closepopup : function(component, event, helper) {
        if(event.currentTarget == modal ){
         modal.style.display = "none";   
          
        }
        
    },*/
    
    
            
            
            
            /**
*————————————————————————————————————————————————————
* @Name: Gaurav Dharra
* @Description
* Call helper method for case creation once validation of all fields is complete
*————————————————————————————————————————————————————
* @param    component, event, helper
* @return   
*————————————————————————————————————————————————————
**/
        submitCase : function(component, event, helper) {
            var errors = helper.validateFields(component);
            if(!errors){
                var newCase = component.get("v.newCase");
                component.set("v.showFormContent", false);
                component.set("v.showOtherFormContent", true);
                helper.createCase(component, newCase);
            }	
        }
    })
({
    /**
*————————————————————————————————————————————————————
* @Name: Gaurav Dharra
* @Description
* Fetch User/Contact information
*————————————————————————————————————————————————————
* @param    component
* @return   
*————————————————————————————————————————————————————
**/
    getUserInfo : function(component) {
        var action = component.get("c.getUserInfo");
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                //console.log(response.getReturnValue());
                if(returnValue.EmployeeNumber){
                    var action2 = component.get("c.fetchContactFromUser");
                    action2.setParams({employeeNumber : returnValue.EmployeeNumber});
                    //console.log(returnValue.EmployeeNumber);
                    action2.setCallback(this, function(response2){
                        var contactInfo = response2.getReturnValue();
                        if(contactInfo){
                         	component.set("v.contactInfo", contactInfo[0]);   
                        	if(contactInfo[0].OtherCity == undefined && contactInfo[0].OtherState != undefined){
                                component.set("v.location" , contactInfo[0].OtherState);
                            }else if(contactInfo[0].OtherCity != undefined && contactInfo[0].OtherState == undefined){
                                component.set("v.location" , contactInfo[0].OtherCity);
                            }else if(contactInfo[0].OtherCity != undefined && contactInfo[0].OtherState != undefined){
                                component.set("v.location", contactInfo[0].OtherCity + ", " + contactInfo[0].OtherState);   
                            }  
                        }
                    });
                    $A.enqueueAction(action2);
                }
                component.set("v.currentUser", returnValue);
                component.set("v.disableSubmitButton", false);
            } else {
                console.log(response.getError());
            }
            
        });
        $A.enqueueAction(action);
    },
  /**
*————————————————————————————————————————————————————
* @Name: Gaurav Dharra
* @Description
* Create case object and pass to apex controller to create new case
*————————————————————————————————————————————————————
* @param    component
* @return   
*————————————————————————————————————————————————————
**/    
    createCase : function(component, newCase, helper) {
        var action = component.get("c.insertNewCase");
        var currentUser = component.get('v.currentUser');
        var contactInfo = component.get('v.contactInfo');
        newCase.Location__c = component.get('v.location');
        //newCase.Subject = $A.get("$Label.c.CEO_Portal_New_Question_Subject");
        newCase.Origin = $A.get("$Label.c.CEO_Portal_New_Case_Origin");
        newCase.Type = $A.get("$Label.c.CEO_Portal_New_Case_Type");
        if(contactInfo.Id != null){
            newCase.ContactId = contactInfo.Id;
        }
        action.setParams({ c : newCase });
        action.setCallback(this, function(response){
                var state = response.getState();
                console.log(state);
                if (state === "SUCCESS") {
                    console.log('Case Created.');
                    component.set("v.showSuccessMsg", true);
                } else {
                    console.log(response.getError());
                    component.set("v.errorMsgContent", $A.get("$Label.c.CEO_Portal_Case_Creation_Error_Message") + response.getError()[0].message);
                    component.set("v.showErrorMsg", true);
                }
            });
        $A.enqueueAction(action);
    },
  /**
*————————————————————————————————————————————————————
* @Name: Gaurav Dharra
* @Description
* Validate mandatory fields are set on form submission
*————————————————————————————————————————————————————
* @param    component
* @return   
*————————————————————————————————————————————————————
**/
    validateFields : function(component) {
        var errors = false;
        var question = component.find("question");
        var questionValue = question.get("v.value");
        var subject = component.find("subject");
        var subjectValue = subject.get("v.value");
        
        if(questionValue==undefined || questionValue==''){
            question.set("v.errors", [{message:"Please enter a description."}]);
            errors=true;
        }else{
            question.set("v.errors", null);
        }
        
        if(subjectValue==undefined || subjectValue==''){
            subject.set("v.errors", [{message:"Please enter a question."}]);
            errors=true;
        }else{
            subject.set("v.errors", null);
        }
        
        return errors;
    }
})
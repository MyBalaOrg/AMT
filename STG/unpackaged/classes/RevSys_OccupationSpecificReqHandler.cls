/**
*___________________________________________________
*@Name: RevSys_OccupationSpecificReqHandler
*@Author: Chuck Walley
*@Created: Date: 01/01/2018
*@Used_By: SPARTN
*___________________________________________________
*@Description: Occupation Specific Requirement Handler for Review Systems Records 
* This class extends the Trigger Handler and invokes helper and utility classes 
* for further logic.
* Put the logic in a helper/utility class. 
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/
public class RevSys_OccupationSpecificReqHandler extends TriggerHandler{
    
    public override void beforeInsert() {
        String errorMsg; 
        errorMsg  = RevSys_OccupationSpecificReqValidations.checkCertDupe(newList, null);  
        errorMsg += RevSys_OccupationSpecificReqValidations.checkObsTargetDupe(newList, null);  
        errorMsg += RevSys_OccupationSpecificReqValidations.checkReqTargetDupe(newList, null);  
        errorMsg += RevSys_OccupationSpecificReqValidations.checkDeptCraftObsDupe(newList, null);  
        errorMsg += Revsys_OccupationSpecReqHelper.addEmployeeViolationCheck(newList);
        /*if(errorMsg == null) {
            Revsys_OccupationSpecReqHelper.addEmployeeViolationCheck(newList); 
        }*/

        OccupationSpecificReqStaticUtility.TriggerErrorMessage 
                = StringUtility.cleanupMessage(errorMsg); 
    }  

    public override void beforeUpdate() {
        String errorMsg; 
        errorMsg  = RevSys_OccupationSpecificReqValidations.checkCertDupe(newList, oldMap);  
        errorMsg += RevSys_OccupationSpecificReqValidations.checkObsTargetDupe(newList, oldMap);  
        errorMsg += RevSys_OccupationSpecificReqValidations.checkReqTargetDupe(newList, oldMap);  
        errorMsg += RevSys_OccupationSpecificReqValidations.checkDeptCraftObsDupe(newList, oldMap);  
        errorMsg += Revsys_OccupationSpecReqHelper.addEmployeeViolationCheck(newList);

        /*if(errorMsg == null) {
            Revsys_OccupationSpecReqHelper.addEmployeeViolationCheck(newList); 
        }*/

        OccupationSpecificReqStaticUtility.TriggerErrorMessage 
                = StringUtility.cleanupMessage(errorMsg); 
     
    }  
    
    public override void afterInsert(){
       OccupationSpecificReqStaticUtility.TriggerErrorMessage = Revsys_OccupationSpecReqHelper.addReqToESR(newList);
    }

 /*   public override void afterUpdate(){
        Revsys_OccupationSpecReqHelper.addReqToESR(newList);
    }*/
}
/**
*___________________________________________________
*@Name: Revsys_EmployeeSpecificReqHandler
*@Author: Chuck Walley
*@Created: Date: March 28, 2018
*@Used_By: SPARTN
*___________________________________________________
*@Description: EmployeeSpecificRequirement Trigger Handler for SPARTN Systems Records 
* This class extends the Trigger Handler and invokes helper and utility classes 
* for further logic.
* Put the logic in a helper/utility class. 
*___________________________________________________
*@Changes: 
* 
**/
public class Revsys_EmployeeSpecificReqHandler extends TriggerHandler {
     public static Boolean DoFailTest = FALSE;

    /**
    *————————————————————————————————————————————————————
    * After Update
    *————————————————————————————————————————————————————
    **/
     public override void afterUpdate() {
        system.debug('HANDLER Revsys_EmployeeSpecificReqHandler afterUpdate-Start');   
        String errorMsg; 
        errorMsg  = Revsys_EmpSpecReqHelper.checkReadyToCertify(newList); 
        errorMsg  += Revsys_EmpSpecReqHelper.updateReportingFields(newList); 

        EmployeeSpecificRequirementStaticUtility.TriggerErrorMessage 
            = StringUtility.cleanupMessage(errorMsg);   
        system.debug('HANDLER Revsys_EmployeeSpecificReqHandler afterUpdate-End');        
         
     }
    public override void beforeInsert() {
        
    }  

    public override void beforeUpdate() {
        
    } 
    public override void afterInsert() {  
         if(Test.isRunningTest() && DoFailTest) {
             EmployeeSpecificRequirementStaticUtility.TriggerErrorMessage = 'Error' ;
        }
    }
    
}
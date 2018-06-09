/**
*___________________________________________________
*@Name: RevSys_OccCertificationTriggerHandler
*@Author: Colin Caldwell
*@Created: Date: 01/26/2018
*@Used_By: SPARTN
*___________________________________________________
*@Description: Occupation Certification Trigger Handler for Review Systems Records 
* This class extends the Trigger Handler and invokes the Handler for further logic.
* Put the logic in a helper/utility class. 
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/
public class RevSys_OccCertificationTriggerHandler extends TriggerHandler{
  public static Boolean DoFailTest = FALSE; 

    /*---------------------------------------------------------------------------------------------------
    OnBeforeInsert
    ---------------------------------------------------------------------------------------------------*/
    public override void beforeInsert() {
    	OccupationCertificationStaticUtility.TriggerErrorMessage 
    		= Revsys_OccCertValidation.checkDupeName(newList, null);
        if(Test.isRunningTest() && DoFailTest) {
            OccupationCertificationStaticUtility.TriggerErrorMessage = 'Error' ;
        }
    }
    /*---------------------------------------------------------------------------------------------------
    OnAfterInsert
    ---------------------------------------------------------------------------------------------------*/
    public override void afterInsert() {
        String errMsg;
        errMsg = RevSys_OccupationCertificationHelper.updateTargetEmployees(newList);
        errMsg += RevSys_OccupationCertificationHelper.createSupervisorTargets(newList);
        errMsg += RevSys_OccupationCertificationHelper.createCertificationTargets(newList);
        OccupationCertificationStaticUtility.TriggerErrorMessage = StringUtility.cleanupMessage(errMsg);
    }
    /*---------------------------------------------------------------------------------------------------
    OnBeforeUpdate
    ---------------------------------------------------------------------------------------------------*/   
    public override void beforeUpdate() {
        String errorMsg; 
        errorMsg  = RevSys_OccupationCertificationHelper.deactivateChild(newList); 
        errorMsg += Revsys_OccCertValidation.checkDupeName(newList, oldMap);

        OccupationCertificationStaticUtility.TriggerErrorMessage  
                  = StringUtility.cleanupMessage(errorMsg); 
    }
    /*---------------------------------------------------------------------------------------------------
    OnAfterUpdate
    ---------------------------------------------------------------------------------------------------*/  
   // public override void afterUpdate() {
    	//string errMsg; 
        //Moved to afterInsert
        //errMsg = RevSys_OccupationCertificationHelper.createCertificationTargets(newList,oldMap);        
        
       // OccupationCertificationStaticUtility.TriggerErrorMessage = StringUtility.cleanupMessage(errMsg);
   // }

}
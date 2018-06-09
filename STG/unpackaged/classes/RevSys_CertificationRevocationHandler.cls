/**
*___________________________________________________
*@Name: RevSys_CertificationRevocationHandler
*@Author: Hemanth Kesapragada
*@Created: Date: 02/15/2018
*@Used_By: SPARTN
*___________________________________________________
*@Description: Certification Revocation Trigger Handler for Review Systems Records 
* This class extends the Trigger Handler and invokes helper and utility classes 
* for further logic.
* Put the logic in a helper/utility class. 
*___________________________________________________
*@Changes: 
* 12/26/2017. Added beforeInsert and beforeUpdate methods[Raj Pandy]
* 05/18/2018. Removed afterInsert() and beforeUpdate() [Boom Bertetti]
* 06/03/2018. Added afterDelete() [Boom Bertetti]
**/
public class RevSys_CertificationRevocationHandler extends TriggerHandler {

    public static Boolean DoFailTest = FALSE;

    public override void afterUpdate() {
        String errMsg ='';
        errMsg = RevSys_CertificationRevocationHelper.processRevocation((List<CertificationRevocation__c>) newList, (Map<Id, CertificationRevocation__c>)oldMap, false);
        errMsg += RevSys_CertificationRevocationHelper.updateEmployeeCertification((List<CertificationRevocation__c>) newList,(Map<Id, CertificationRevocation__c>)oldMap);  
        CertificationRevocationStaticUtility.TriggerErrorMessage = StringUtility.cleanupMessage(errMsg);   
    }
    public override void beforeInsert() {
        CertificationRevocationStaticUtility.TriggerErrorMessage = RevSys_CertificationRevocationHelper.processRevocation((List<CertificationRevocation__c>) newList, null, false);
        CertificationRevocationStaticUtility.TriggerErrorMessage = StringUtility.cleanupMessage(CertificationRevocationStaticUtility.TriggerErrorMessage );   
        if(Test.isRunningTest() && DoFailTest){
            CertificationRevocationStaticUtility.TriggerErrorMessage = 'Error';
        }
    }  
    public override void afterDelete() {
        CertificationRevocationStaticUtility.TriggerErrorMessage = RevSys_CertificationRevocationHelper.processRevocation((List<CertificationRevocation__c>) oldList, null, true);
        CertificationRevocationStaticUtility.TriggerErrorMessage += RevSys_CertificationRevocationHelper.updateEmployeeCertification((List<CertificationRevocation__c>) oldList, null);  
        CertificationRevocationStaticUtility.TriggerErrorMessage = StringUtility.cleanupMessage(CertificationRevocationStaticUtility.TriggerErrorMessage );   
    }
}
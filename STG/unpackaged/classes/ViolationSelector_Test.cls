/**
*___________________________________________________
*@Name:     ViolationSelector_Test
*@Author:   Vaibhav Athikam
*@Created:  Date: April 9, 2018
*@Used_By:  SPARTN
*___________________________________________________
*@Description: Test for ViolationSelector
* 
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/
@isTest
public class ViolationSelector_Test {

    //Creating Test Data
    @TestSetup
    public static void loadTestData() {
        
        Contact myEmployee      = new Contact();
		myEmployee.LastName			    ='Employee'; 
		myEmployee.FirstName			    ='Amy'; 
		myEmployee.Personnel_Number__c   = 1234567;
		myEmployee.Email 				= 'test.test@amtrak.com';
		insert myEmployee; 


         Violation__c violation1 = new Violation__c
        ( 
            RecordTypeId = Revsys_StaticUtility.VIOLATION_SPARTN_OVERALL_VIOLATION_RECTYPE_ID ,
            CentralReportingIncidentId__c    = '123',
            IncidentDateTime__c              = DateTime.now(), 
            SPARTN_Nrpc3160Rule__c           = null,
       //     ViolationType__c                 = myObs.Id,
           ViolationDescription__c          = 'Description' 
        ); 



        Violation__c violation2 = new Violation__c
        ( 
            RecordTypeId = Revsys_StaticUtility.VIOLATION_SPARTN_EMP_RECTYPE_ID ,
        //    ParentViolation__c = myOverallViolation.Id,
            SPARTN_Nrpc3160Rule__c                  = null,
  //          ViolationType__c                 = myObs.Id, 
            ViolationDescription__c          = 'Description',
            RemovedFromServiceDate__c        = Date.today(),
            Employee__c                      = myEmployee.Id 
        );  


        insert new List<Violation__c>{violation1, violation2};
    }
    
     private static testmethod void getViolationRecordsTest() {
         List<Violation__c> violationList = new List<Violation__c>();
         violationList = [SELECT Id FROM Violation__c];

		 ViolationSelector.DoFailTest = FALSE;
         SelectorWrapper selector1 = ViolationSelector.getViolationRecords(violationList);
         system.debug('selector1.ErrorMessage  ' + selector1.ErrorMessage); 
         system.assertEquals(null,selector1.ErrorMessage); 
		 System.assertEquals(2, selector1.SObjectList.size());
         
          ViolationSelector.DoFailTest = TRUE;
         SelectorWrapper selector2 = ViolationSelector.getViolationRecords(violationList);
         system.debug('selector2.ErrorMessage  ' + selector2.ErrorMessage); 
         system.assertNotEquals(null,selector2.ErrorMessage); 
		 System.assertEquals(0, selector2.SObjectList.size());
     }



    
}
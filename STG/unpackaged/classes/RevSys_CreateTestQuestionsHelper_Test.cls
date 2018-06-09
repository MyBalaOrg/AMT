/**
*___________________________________________________
*@Name: RevSys_CertificationRevocation_Test
*@Author: Shiva
*@Created: Date: 03/17/2018
*@Used_By: SPARTN
*___________________________________________________
*@Description: Test class for RevSys_CreateTestQuestionsHelper class
* 
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/
@isTest
public class RevSys_CreateTestQuestionsHelper_Test {
    static testmethod void testStartProcess(){
        Test.startTest();
        RevSys_TestDataHelper.buildTestData();
        
        List<Contact> myEmployeeList = new List<Contact> 
            ( 
                [SELECT Id, Name, Email, Personnel_Number__c
                 FROM   Contact ]
            );
        
        Map<String,Contact> myContactMap = new Map<String,Contact>(); 
        
        for(Contact myEmployee :myEmployeeList)
        {
            myContactMap.put(myEmployee.Email,myEmployee); 
        }
        
        Contact myEmployee = myContactMap.get('abigale.employee@amtrak.com'); 
        Observation__c obs2 = new Observation__c
            ( 
                RecordTypeId                    = RevSys_StaticUtility.OBSERVATION_TEST1878_RECTYPE_ID,
                Date__c                         = Date.today(), 
                Department__c                   = 'Engineering ET',
                Employee__c =myEmployee.ID,
                Number_of_Workers_Observed__c = 1);
        Insert obs2;
        String x = RevSys_CreateTestQuestionsHelper.StartProcess(new List<Observation__c>{obs2});
        Test.stopTest();
    }
}
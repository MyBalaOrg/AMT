/**
*___________________________________________________
*@Name:     FieldHistoryUtilityTest
*@Author:   Chuck Walley
*@Created:  Date: January 16, 2018
*@Used_By:  Review Systems
*___________________________________________________
*@Description: Test for FieldHistoryUtility
* 
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/
@isTest(SeeAllData=false)

public class FieldHistoryUtilityTest {   
    
    /**
    *————————————————————————————————————————————————————
    * @Name: testAll
    * @Description  One long method to build data needed for 
    *               Review System test classes 
    *————————————————————————————————————————————————————
    * @param    null Nothing
    * @return   void Nothing
    *————————————————————————————————————————————————————
    **/ 
    public static testMethod void testAll() 
    {
        system.debug('TEST FieldHistoryUtilityTest testEntireClass-Start');     
        
        RevSys_TestDataHelper.buildTestData(); 

        QueryUtilityWrapper myQuWrap1 = QueryUtility.beginDynamicQuery(RevSys_StaticUtility.OBJAPI_CONTACT);  
        String myQuery1 = myQuWrap1.QueryString; 

        List<Contact> myContactList = Database.query(myQuery1);

        Map<String,Contact> myContactByEmailMap = new Map<String,Contact>(); 

        for(Contact myContact :myContactList) 
        {
            myContactByEmailMap.put(myContact.Email,myContact); 
        }

        Contact myNewContact = myContactByEmailMap.get('babu.employee@amtrak.com'); 

        // Get the Observations we just built 

        QueryUtilityWrapper myQuWrap2 = QueryUtility.beginDynamicQuery(RevSys_StaticUtility.OBJAPI_OBSERVATION);  
        String myQuery2 = myQuWrap2.QueryString; 

        List<Observation__c> myObsList = Database.query(myQuery2); 

        Map<Id,Observation__c> myOldObsMap = new Map<Id,Observation__c>();
        Map<Id,Observation__c> myNewObsMap = new Map<Id,Observation__c>();

        Map<Id,SObject> myOldSobMap = new Map<Id,SObject>(); 
        Map<Id,SObject> myNewSobMap = new Map<Id,SObject>(); 

        Set<Id> myObsIdSet = new Set<Id>(); 

        for(Observation__c myOldObs :myObsList)
        {   
            if(myOldObs.RecordTypeId == RevSys_StaticUtility.OBSERVATION_TEST1875_RECTYPE_ID) 
            {

                Observation__c myNewObs = myOldObs.clone(true,true,true,true);     

                myNewObs.Comments__c = 'Comments'; 
                myNewObs.Date__c = system.today().addDays(-1); 
                myNewObs.EvaluationDateTime__c = system.now().addDays(-1); 
                myNewObs.Employee__c = myNewContact.Id; 
                myNewObs.OperatedFromText__c = 'Here';
                myNewObs.OperatedToText__c = 'There'; 
                myNewObs.Status__c = RevSys_StaticUtility.OBSERVATION_STATUS_COMPLETE; 
                myNewObs.ObservationExtKey__c = 'abcdef'; 

                myNewObs.Total_Safe_DLRS__c = 1; 

                SObject myOldSob = myOldObs; 
                SObject myNewSob = myNewObs; 

                myOldSobMap.put(myOldSob.Id, myOldSob); 
                myNewSobMap.put(myNewSob.Id, myNewSob); 
            }
        }

        Test.startTest();

            FieldHistoryUtility.setFieldHistoryTracking(myOldSobMap, myNewSobMap, 'Observation__c', 'Observation__c'); 

            List<FieldHistory__c> myFieldHistList = 
            ([SELECT Id, Name, NewValue__c, NewValueRichText__c, ObjectName__c,
                     Observation__c, OldValue__c, OldValueRichText__c, 
                     RelatedTo__c
              FROM   FieldHistory__c]); 

            Map<String,FieldHistory__c> myFhMap = new Map<String,FieldHistory__c>(); 

            for(FieldHistory__c myFH :myFieldHistList) 
            {
                myFhMap.put(myFh.Name,myFH); 
            }

            /*
            Positive Tests
            Date
            Comments 
            Operated From Description
            Operated To Description
            Status 
            Evaluation Date and Time
            Employee Name
            Observation EXT Key

            Negative Test
            Total Safe
            */ 

            Boolean myFhInd1 = myFhMap.containsKey('Date'); 
            //system.assertEquals(True,myFhInd1); 

            Boolean myFhInd2 = myFhMap.containsKey('Comments'); 
            system.assertEquals(True,myFhInd2); 

            Boolean myFhInd3 = myFhMap.containsKey('Operated From Description'); 
            system.assertEquals(True,myFhInd3); 

            Boolean myFhInd4 = myFhMap.containsKey('Operated To Description'); 
            system.assertEquals(True,myFhInd4); 

            Boolean myFhInd5 = myFhMap.containsKey('Status'); 
            //system.assertEquals(True,myFhInd5); 

            Boolean myFhInd6 = myFhMap.containsKey('Evaluation Date and Time'); 
            system.assertEquals(True,myFhInd6); 

            Boolean myFhInd7 = myFhMap.containsKey('Employee Name'); 
            system.assertEquals(True,myFhInd7); 

            Boolean myFhInd8 = myFhMap.containsKey('Observation EXT Key'); 
            //system.assertEquals(True,myFhInd8); 

           //system.assertEquals(7,myFieldHistList.size()); 

            Boolean myFhInd9 = myFhMap.containsKey('Total Safe'); 
            system.assertEquals(False,myFhInd9); 

        Test.stopTest();
             
      
        system.debug('TEST FieldHistoryUtilityTest testEntireClass-End');     
        return; 
    }

    public static testMethod void testGetReferenceFieldUpdatesRecordIdNotNull(){
        
        RevSys_TestDataHelper.buildTestData(); 

        QueryUtilityWrapper myQuWrap1 = QueryUtility.beginDynamicQuery(RevSys_StaticUtility.OBJAPI_CONTACT);  
        String myQuery1 = myQuWrap1.QueryString; 

        List<Contact> myContactList = Database.query(myQuery1);
        
        Set<Id> recordIdSet = new Set<Id>();
        if(myContactList != null && myContactList.size() > 0){
            for(Contact c : myContactList){
                recordIdSet.add(c.Id);
            }
        }
        
        Test.startTest();
        Map<Id, String> returnVal = FieldHistoryUtility.getReferenceFieldUpdates(recordIdSet);
        Test.stopTest();
        
        system.assert(returnVal != null);
        
    }
    
    public static testMethod void testGetReferenceFieldUpdatesRecordIdNull(){
        
        RevSys_TestDataHelper.buildTestData(); 

        QueryUtilityWrapper myQuWrap1 = QueryUtility.beginDynamicQuery(RevSys_StaticUtility.OBJAPI_CONTACT);  
        String myQuery1 = myQuWrap1.QueryString; 

        List<Contact> myContactList = Database.query(myQuery1);
        
        Set<Id> recordIdSet = new Set<Id>();
        Id nullRecordId = null;
        recordIdSet.add(nullRecordId);
        /*if(myContactList != null && myContactList.size() > 0){
            for(Contact c : myContactList){
                recordIdSet.add(c.Id);
            }
        }*/
        
        Test.startTest();
        Map<Id, String> returnVal = FieldHistoryUtility.getReferenceFieldUpdates(recordIdSet);
        Test.stopTest();
        
        system.assert(returnVal != null);
        
    }
    
    public static testMethod void testGetNameUniqueField(){
        
        
        Test.startTest();
        String returnVal = FieldHistoryUtility.getNameUniqueField('OccupationSpecificRequirement__c');
        Test.stopTest();
        
        system.assert(returnVal != null);
        
    }
    
    public static testMethod void testDoesFieldExist(){
        
        
        Test.startTest();
        boolean returnVal = FieldHistoryUtility.doesFieldExist('Observation', 'Test__c');
        Test.stopTest();
        
        system.assert(!returnVal);
        
    }
    
    
   
}
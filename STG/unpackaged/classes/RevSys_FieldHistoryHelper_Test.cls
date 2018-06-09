/**
*___________________________________________________
*@Name:     RevSys_FieldHistoryHelper_Test
*@Author:   Chuck Walley
*@Created:  Date: January 16, 2018
*@Used_By:  Review Systems
*___________________________________________________
*@Description: Test for RevSys_FieldHistoryHelper
* 
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/
@isTest(SeeAllData=false)

public class RevSys_FieldHistoryHelper_Test {   
    
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

        // Get the Observations we just built 

        QueryUtilityWrapper myQuWrap2 = QueryUtility.beginDynamicQuery(RevSys_StaticUtility.OBJAPI_OBSERVATION);  
        String myQuery2 = myQuWrap2.QueryString; 

        List<Observation__c> myObsList = Database.query(myQuery2); 

        system.debug('myObsList ' + myObsList); 

        List<Observation__c> my1875ObsList = new List<Observation__c>(); 

        for(Observation__c myOldObs :myObsList)
        {   
            if(myOldObs.RecordTypeId == RevSys_StaticUtility.OBSERVATION_TEST1875_RECTYPE_ID) 
            {
                my1875ObsList.add(myOldObs); 
            }
        }


        Observation__c my1875Obs = my1875ObsList[0]; 

        Set<Id> myObsIdSet = new Set<Id>(); 
        myObsIdSet.add(my1875Obs.Id); 

        SelectorWrapper selWrap = FindingSelector.getObsRelatedFindings(myObsIdSet); 

        String myErrMsg = selWrap.ErrorMessage; 
        List<Finding__c>  myFindingList = selWrap.SObjectList;   

        Map<Id,SObject> myOldSobMap = new Map<Id,SObject>(); 
        Map<Id,SObject> myNewSobMap = new Map<Id,SObject>();    
            
        for(Finding__c myOldFind :myFindingList)
        {   
            Finding__c myNewFind = myOldFind.clone(true,true,true,true);    

            if(myNewFind.Sub_category__c == 'Operating Rules')
            {
                myNewFind.Score__c = 4; 
            }
            else if(myNewFind.Sub_category__c == 'Physical Characteristics')
            {
                myNewFind.Score__c = 1; 
            }

            SObject myOldSob = myOldFind; 
            SObject myNewSob = myNewFind; 

            myOldSobMap.put(myOldFind.Id, myOldFind); 
            myNewSobMap.put(myNewFind.Id, myNewFind); 
        }

        Test.startTest();

            RevSys_FieldHistoryHelper.updateScoresOnObservation(myOldSobMap, myNewSobMap, 'Finding__c', 'Finding__c'); 


            List<FieldHistory__c> myFieldHistList = 
            ([SELECT Id, Name, NewValue__c, NewValueRichText__c, ObjectName__c,
                     Observation__c, OldValue__c, OldValueRichText__c, 
                     RelatedTo__c
              FROM   FieldHistory__c]); 

            Map<String,FieldHistory__c> myFhMap = new Map<String,FieldHistory__c>(); 

            for(FieldHistory__c myFH :myFieldHistList) 
            {
                system.debug('myFH ' + myFH); 
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

            /*
            Boolean myFhInd1 = myFhMap.containsKey('Date'); 
            system.assertEquals(True,myFhInd1); 

            Boolean myFhInd2 = myFhMap.containsKey('Comments'); 
            system.assertEquals(True,myFhInd2); 

            Boolean myFhInd3 = myFhMap.containsKey('Operated From Description'); 
            system.assertEquals(True,myFhInd3); 

            Boolean myFhInd4 = myFhMap.containsKey('Operated To Description'); 
            system.assertEquals(True,myFhInd4); 

            Boolean myFhInd5 = myFhMap.containsKey('Status'); 
            system.assertEquals(True,myFhInd5); 

            Boolean myFhInd6 = myFhMap.containsKey('Evaluation Date and Time'); 
            system.assertEquals(True,myFhInd6); 

            Boolean myFhInd7 = myFhMap.containsKey('Employee Name'); 
            system.assertEquals(True,myFhInd7); 

            Boolean myFhInd8 = myFhMap.containsKey('Observation EXT Key'); 
            system.assertEquals(True,myFhInd8); 

            system.assertEquals(8,myFieldHistList.size()); 

            Boolean myFhInd9 = myFhMap.containsKey('Total Safe'); 
            system.assertEquals(False,myFhInd9); 
            */ 

        Test.stopTest();
       
      
        system.debug('TEST FieldHistoryUtilityTest testEntireClass-End');     
        return; 
    }


   
}
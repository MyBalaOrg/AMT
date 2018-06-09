/**
*___________________________________________________
*@Name:     RevSys_OverallScoreHelper_Test
*@Author:     Chuck Walley
*@Created:     Date: 11/12/2017
*@Used_By:     Review Systems
*___________________________________________________
*@Description: Test for RevSys_ObservationHandler
* 
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/
@isTest(SeeAllData=false)

public class RevSys_OverallScoreHelper_Test {   
    
    
  	@TestSetup
	public static void loadTestData(){
		RevSys_TestDataHelper.buildTestData(); 
    }    
    /**
    *————————————————————————————————————————————————————
    * @Name: testAllPass
    * @Description  One long method to build data needed for 
    *               Review System test classes 
    *————————————————————————————————————————————————————
    * @param    null Nothing
    * @return   void Nothing
    *————————————————————————————————————————————————————
    **/ 
 /*   public static testMethod void testAllPass() 
    {
        system.debug('TEST RevSys_ObservationHandler_Test testEntireClass-Start');     
        
         system.debug('ZZZZZZZZZZZZZ  before data build'); 
        
       // RevSys_TestDataHelper.buildTestData(); 

        // Get the Observations we just built 

        QueryUtilityWrapper myQuWrap = QueryUtility.beginDynamicQuery(RevSys_StaticUtility.OBJAPI_OBSERVATION);  
        String myQuery = myQuWrap.QueryString; 

        List<Observation__c> myObsList = Database.query(myQuery);      
            
        Map<Id,Observation__c> myOldObsMap = new Map<Id,Observation__c>();
        Set<Id> myObsIdSet = new Set<Id>(); 
        String rtname;
        List<Finding__c> observationFindings = new List<Finding__c>();
		Map<Id, String> obsRecordType = new Map<Id, String>();    
        
        Map<Id,String> returnMap = new Map<Id,String>(); //the return map variable
        for (RecordType rt : [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Observation__c']) { //grab the recordtypes for the specified sObject
            returnMap.put(rt.Id, rt.Name); //put the details into our map (Name -> Id)
        }        
        
        for(Observation__c myObs :myObsList)
        {   
            myObs.Status__c = RevSys_StaticUtility.OBSERVATION_STATUS_COMPLETE; 
            myObsIdSet.add(myObs.Id); 
            Observation__c myOldObs = myObs.clone(true,true,true, true); 
            myOldObsMap.put(myOldObs.Id,myOldObs); 

            
        	rtName = returnMap.get(myObs.recordtypeid);
      
        	Map<String, List<Finding__c>> findingsByRecordTypes = RevSys_ObservationController.getTestQuestionMap();
            observationFindings = findingsByRecordTypes.get(rtName);
            if (observationFindings != null) {
                for (Finding__c finding : observationFindings) {
                    finding.Observation__c = myObs.Id;
                } 
            }           
        }
                 
        if (observationFindings != null && !observationFindings.isEmpty()) {
            insert observationFindings;
        
            SelectorWrapper myFindingWrap = FindingSelector.getObsRelatedFindings(myObsIdSet); 

            List<Finding__c> myFindingList = myFindingWrap.SObjectList; 

            system.debug('ZZZZZZZZZZZZZ  myFindingList =  ' + myFindingList); 
           

                Integer myFindingListSize = myFindingList.size(); 

                system.assertNotEquals(0,myFindingListSize); 

                for(Finding__c myFinding :myFindingList)
                {
                    system.debug('myFinding ' + myFinding); 
                    myFinding.Score__c = 2; 
                }

                update myFindingList; 

                Test.startTest(); 

                    String  errorMsg = RevSys_OverallScoreHelper2.determineScore(myObsList, myOldObsMap); 


                Test.stopTest(); 
        }     
      
        system.debug('TEST RevSys_ObservationHandler_Test testEntireClass-End');     
        return; 
    }*/

    /**
    *————————————————————————————————————————————————————
    * @Name: test1875Pass
    * @Description  One long method to build data needed for 
    *               Review System test classes 
    *————————————————————————————————————————————————————
    * @param    null Nothing
    * @return   void Nothing
    *————————————————————————————————————————————————————
    **/ 
    public static testMethod void test1875Pass() 
    {
        system.debug('TEST RevSys_ObservationHandler_Test testEntireClass-Start');     
        
        //RevSys_TestDataHelper.buildTestData(); 

        // Get the Observations we just built 

        Id my1875RecTypeId = RevSys_StaticUtility.OBSERVATION_TEST1875_RECTYPE_ID;
        QueryUtilityWrapper myQuWrap = QueryUtility.beginDynamicQuery(RevSys_StaticUtility.OBJAPI_OBSERVATION);  
        String myQuery = myQuWrap.QueryString; 
        myQuery += ' WHERE RecordTypeId = :my1875RecTypeId';

        List<Observation__c> myObsList = Database.query(myQuery); 
        Map<Id,Observation__c> myOldObsMap = new Map<Id,Observation__c>();
        Set<Id> myObsIdSet = new Set<Id>();       
        
        

/*        for(Observation__c myObs :myObsList)
        {   
            myObsIdSet.add(myObs.Id); 
            Observation__c myOldObs = myObs.clone(true,true,true, true); 
            myOldObsMap.put(myOldObs.Id,myOldObs); 

            myObs.Status__c = RevSys_StaticUtility.OBSERVATION_STATUS_COMPLETE; 
        }*/
        
        String rtname;
        List<Finding__c> observationFindings = new List<Finding__c>();
		Map<Id, String> obsRecordType = new Map<Id, String>();    
        Map<Id,String> returnMap = new Map<Id,String>(); //the return map variable
        for (RecordType rt : [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Observation__c']) { //grab the recordtypes for the specified sObject
            returnMap.put(rt.Id, rt.Name); //put the details into our map (Name -> Id)
        }
        
        for(Observation__c myObs :myObsList)
        {   
			myObs.Status__c = RevSys_StaticUtility.OBSERVATION_STATUS_COMPLETE;
            myObsIdSet.add(myObs.Id); 
            Observation__c myOldObs = myObs.clone(true,true,true, true); 
            myOldObsMap.put(myOldObs.Id,myOldObs); 
             
        	rtName = returnMap.get(myObs.recordtypeid);
      
        	Map<String, List<Finding__c>> findingsByRecordTypes = RevSys_ObservationController.getTestQuestionMap();
            observationFindings = findingsByRecordTypes.get(rtName);
            if (observationFindings != null) {
                for (Finding__c finding : observationFindings) {
                    finding.Observation__c = myObs.Id;
                    finding.Score__c=1;
                }
            }
			
        //    myObs.Status__c = RevSys_StaticUtility.OBSERVATION_STATUS_COMPLETE; 
        }
         
        if (observationFindings != null && !observationFindings.isEmpty()) {
		  insert observationFindings;
        
            SelectorWrapper myFindingWrap = FindingSelector.getObsRelatedFindings(myObsIdSet); 
            List<Finding__c> myFindingList = myFindingWrap.SObjectList; 

            system.debug('ZZZZZZZZZZZZZ  myFindingList =  ' + myFindingList); 
           

                Integer myFindingListSize = myFindingList.size(); 

                system.assertNotEquals(0,myFindingListSize); 

            
                for(Finding__c myFinding :myFindingList)
                {
                    myFinding.Score__c = 2; 

                    system.debug('myFinding ' + myFinding); 
                }
            	update myFindingList;
            
                for(Observation__c myObs :myObsList)
                {
                     
                    myObs.OperatedFromText__c = '123';
                    myObs.OperatedToText__c='246';
                    myObs.Status__c = RevSys_StaticUtility.OBSERVATION_STATUS_COMPLETE; 
                }
                update myObsList;

            
            
                Test.startTest(); 

                    RevSys_ScoreWrapper myScoreWrap = RevSys_OverallScoreHelper2.scoreLogic(myFindingList); 

                    system.assertEquals(2,myScoreWrap.OverallScore); 
                    system.assertEquals(TRUE,myScoreWrap.PassedCriticalItems); 

                Test.stopTest(); 
        }     
      
        system.debug('TEST RevSys_ObservationHandler_Test testEntireClass-End');     
        return; 
    }
    /**
    *————————————————————————————————————————————————————
    * @Name: test1875Fail
    * @Description  One long method to build data needed for 
    *               Review System test classes 
    *————————————————————————————————————————————————————
    * @param    null Nothing
    * @return   void Nothing
    *————————————————————————————————————————————————————
    **/ 
    public static testMethod void test1875Fail() 
    {
        system.debug('TEST RevSys_ObservationHandler_Test testEntireClass-Start');     
        
        //RevSys_TestDataHelper.buildTestData(); 

        // Get the Observations we just built 

        Id my1875RecTypeId = RevSys_StaticUtility.OBSERVATION_TEST1875_RECTYPE_ID;
        QueryUtilityWrapper myQuWrap = QueryUtility.beginDynamicQuery(RevSys_StaticUtility.OBJAPI_OBSERVATION);  
        String myQuery = myQuWrap.QueryString; 
        myQuery += ' WHERE RecordTypeId = :my1875RecTypeId';

        List<Observation__c> myObsList = Database.query(myQuery); 

        Map<Id,Observation__c> myOldObsMap = new Map<Id,Observation__c>();
        Set<Id> myObsIdSet = new Set<Id>(); 
        

        /*for(Observation__c myObs :myObsList)
        {   
            myObsIdSet.add(myObs.Id); 
            Observation__c myOldObs = myObs.clone(true,true,true, true); 
            myOldObsMap.put(myOldObs.Id,myOldObs); 

            myObs.Status__c = RevSys_StaticUtility.OBSERVATION_STATUS_COMPLETE; 
        }*/
        
        String rtname;
        List<Finding__c> observationFindings = new List<Finding__c>();
		Map<Id, String> obsRecordType = new Map<Id, String>();    
        Map<Id,String> returnMap = new Map<Id,String>(); //the return map variable
        for (RecordType rt : [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Observation__c']) { //grab the recordtypes for the specified sObject
            returnMap.put(rt.Id, rt.Name); //put the details into our map (Name -> Id)
        }
        
        for(Observation__c myObs :myObsList)
        {   
            myObsIdSet.add(myObs.Id); 
            Observation__c myOldObs = myObs.clone(true,true,true, true); 
            myOldObsMap.put(myOldObs.Id,myOldObs); 

            myObs.Status__c = RevSys_StaticUtility.OBSERVATION_STATUS_COMPLETE; 
        	rtName = returnMap.get(myObs.recordtypeid);
      
        	Map<String, List<Finding__c>> findingsByRecordTypes = RevSys_ObservationController.getTestQuestionMap();
            observationFindings = findingsByRecordTypes.get(rtName);
            if (observationFindings != null) {
                for (Finding__c finding : observationFindings) {
                    finding.Observation__c = myObs.Id;
                    //finding.Score__c=2;
                } 
            }           
        }
         
        if (observationFindings != null && !observationFindings.isEmpty()) {
		  insert observationFindings;



            SelectorWrapper myFindingWrap = FindingSelector.getObsRelatedFindings(myObsIdSet); 

            List<Finding__c> myFindingList = myFindingWrap.SObjectList; 

            system.debug('ZZZZZZZZZZZZZ  myFindingList =  ' + myFindingList); 
           

                Integer myFindingListSize = myFindingList.size(); 

                system.assertNotEquals(0,myFindingListSize); 

                for(Finding__c myFinding :myFindingList)
                {
                    myFinding.Score__c = 4; 

                    system.debug('myFinding ' + myFinding); 
                }
                Test.startTest(); 

                    RevSys_ScoreWrapper myScoreWrap = RevSys_OverallScoreHelper2.scoreLogic(myFindingList); 

                    system.assertEquals(4,myScoreWrap.OverallScore); 
                    system.assertEquals(FALSE,myScoreWrap.PassedCriticalItems); 

                Test.stopTest(); 
        }     
      
        system.debug('TEST RevSys_ObservationHandler_Test testEntireClass-End');     
        return; 
    }

    /**
    *————————————————————————————————————————————————————
    * @Name: test1875SingleFail
    * @Description  One long method to build data needed for 
    *               Review System test classes 
    *————————————————————————————————————————————————————
    * @param    null Nothing
    * @return   void Nothing
    *————————————————————————————————————————————————————
    **/ 
    public static testMethod void test1875SingleFail() 
    {
        system.debug('TEST RevSys_ObservationHandler_Test testEntireClass-Start');     
        
        //RevSys_TestDataHelper.buildTestData(); 

        // Get the Observations we just built 

        Id my1875RecTypeId = RevSys_StaticUtility.OBSERVATION_TEST1875_RECTYPE_ID;
        QueryUtilityWrapper myQuWrap = QueryUtility.beginDynamicQuery(RevSys_StaticUtility.OBJAPI_OBSERVATION);  
        String myQuery = myQuWrap.QueryString; 
        myQuery += ' WHERE RecordTypeId = :my1875RecTypeId';

        List<Observation__c> myObsList = Database.query(myQuery); 

        Map<Id,Observation__c> myOldObsMap = new Map<Id,Observation__c>();
        Set<Id> myObsIdSet = new Set<Id>(); 
        

/*        for(Observation__c myObs :myObsList)
        {   
            myObsIdSet.add(myObs.Id); 
            Observation__c myOldObs = myObs.clone(true,true,true, true); 
            myOldObsMap.put(myOldObs.Id,myOldObs); 

            myObs.Status__c = RevSys_StaticUtility.OBSERVATION_STATUS_COMPLETE; 
        }*/
        
        String rtname;
        List<Finding__c> observationFindings = new List<Finding__c>();
		Map<Id, String> obsRecordType = new Map<Id, String>();    
        Map<Id,String> returnMap = new Map<Id,String>(); //the return map variable
        for (RecordType rt : [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Observation__c']) { //grab the recordtypes for the specified sObject
            returnMap.put(rt.Id, rt.Name); //put the details into our map (Name -> Id)
        }
        
        for(Observation__c myObs :myObsList)
        {   
            myObsIdSet.add(myObs.Id); 
            Observation__c myOldObs = myObs.clone(true,true,true, true); 
            myOldObsMap.put(myOldObs.Id,myOldObs); 

            myObs.Status__c = RevSys_StaticUtility.OBSERVATION_STATUS_COMPLETE; 
        	rtName = returnMap.get(myObs.recordtypeid);
      
        	Map<String, List<Finding__c>> findingsByRecordTypes = RevSys_ObservationController.getTestQuestionMap();
            observationFindings = findingsByRecordTypes.get(rtName);
            if (observationFindings != null) {
                for (Finding__c finding : observationFindings) {
                    finding.Observation__c = myObs.Id;
                } 
            }           
        }
         
        if (observationFindings != null && !observationFindings.isEmpty()) {
		  insert observationFindings;



            SelectorWrapper myFindingWrap = FindingSelector.getObsRelatedFindings(myObsIdSet); 

            List<Finding__c> myFindingList = myFindingWrap.SObjectList; 

            system.debug('ZZZZZZZZZZZZZ  myFindingList =  ' + myFindingList); 
           

                Integer myFindingListSize = myFindingList.size(); 

                system.assertNotEquals(0,myFindingListSize); 

                for(Finding__c myFinding :myFindingList)
                {
                    myFinding.Score__c = 1;

                    if(myFinding.Sub_category__c == 'Train Speed') { 
                        myFinding.Score__c = 4;
                    }


                    system.debug('myFinding ' + myFinding); 
                }
                Test.startTest(); 

                    RevSys_ScoreWrapper myScoreWrap = RevSys_OverallScoreHelper2.scoreLogic(myFindingList); 


                    system.assertEquals(FALSE,myScoreWrap.PassedCriticalItems); 

                Test.stopTest(); 
        } 
      
        system.debug('TEST RevSys_ObservationHandler_Test testEntireClass-End');     
        return; 
    }

    /**
    *————————————————————————————————————————————————————
    * @Name: test1877Pass
    * @Description  One long method to build data needed for 
    *               Review System test classes 
    *————————————————————————————————————————————————————
    * @param    null Nothing
    * @return   void Nothing
    *————————————————————————————————————————————————————
    **/ 
    public static testMethod void test1877Pass() 
    {
        system.debug('TEST RevSys_ObservationHandler_Test testEntireClass-Start');     
        
        //RevSys_TestDataHelper.buildTestData(); 

        // Get the Observations we just built 

        Id my1877RecTypeId = RevSys_StaticUtility.OBSERVATION_TEST1877_RECTYPE_ID;
        QueryUtilityWrapper myQuWrap = QueryUtility.beginDynamicQuery(RevSys_StaticUtility.OBJAPI_OBSERVATION);  
        String myQuery = myQuWrap.QueryString; 
        myQuery += ' WHERE RecordTypeId = :my1877RecTypeId';
        Decimal criticalItemcount=0;

        List<Observation__c> myObsList = Database.query(myQuery); 

        Map<Id,Observation__c> myOldObsMap = new Map<Id,Observation__c>();
        Set<Id> myObsIdSet = new Set<Id>(); 
        

/*        for(Observation__c myObs :myObsList)
        {   
            myObsIdSet.add(myObs.Id); 
            Observation__c myOldObs = myObs.clone(true,true,true, true); 
            myOldObsMap.put(myOldObs.Id,myOldObs); 

            myObs.Status__c = RevSys_StaticUtility.OBSERVATION_STATUS_COMPLETE; 
        }*/

        String rtname;
        List<Finding__c> observationFindings = new List<Finding__c>();
		Map<Id, String> obsRecordType = new Map<Id, String>();    
        Map<Id,String> returnMap = new Map<Id,String>(); //the return map variable
        for (RecordType rt : [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Observation__c']) { //grab the recordtypes for the specified sObject
            returnMap.put(rt.Id, rt.Name); //put the details into our map (Name -> Id)
        }
        
        for(Observation__c myObs :myObsList)
        {   
            myObsIdSet.add(myObs.Id); 
            Observation__c myOldObs = myObs.clone(true,true,true, true); 
            myOldObsMap.put(myOldObs.Id,myOldObs); 

            myObs.Status__c = RevSys_StaticUtility.OBSERVATION_STATUS_COMPLETE; 
        	rtName = returnMap.get(myObs.recordtypeid);
      
        	Map<String, List<Finding__c>> findingsByRecordTypes = RevSys_ObservationController.getTestQuestionMap();
            observationFindings = findingsByRecordTypes.get(rtName);
            if (observationFindings != null && !observationFindings.isEmpty()) {
                for (Finding__c finding : observationFindings) {
                    finding.Observation__c = myObs.Id;
                   
                }  
            }          
        }
         
        if (observationFindings != null && !observationFindings.isEmpty()) {
		  insert observationFindings;

        

            SelectorWrapper myFindingWrap = FindingSelector.getObsRelatedFindings(myObsIdSet); 

            List<Finding__c> myFindingList = myFindingWrap.SObjectList; 

            system.debug('ZZZZZZZZZZZZZ  myFindingList =  ' + myFindingList); 
           

                Integer myFindingListSize = myFindingList.size(); 

                system.assertNotEquals(0,myFindingListSize); 

                for(Finding__c myFinding :myFindingList)
                {
                    myFinding.Score__c = 1; 
    				 if(myFinding.Sub_category__c == 'Safety') { 
                        myFinding.Score__c = 2;
                    }

                    system.debug('myFinding ' + myFinding); 
                }
                Test.startTest(); 

                    criticalItemcount = RevSys_OverallScoreHelper2.scoreLogic1877(myFindingList);

                    //system.assertEquals(1,criticalItemcount); 
                   

                Test.stopTest(); 
        }      
      
        system.debug('TEST RevSys_ObservationHandler_Test testEntireClass-End');     
        return; 
    }
    
    
    /**
    *————————————————————————————————————————————————————
    * @Name: test1877fail
    * @Description  One long method to build data needed for 
    *               Review System test classes 
    *————————————————————————————————————————————————————
    * @param    null Nothing
    * @return   void Nothing
    *————————————————————————————————————————————————————
    **/ 
    public static testMethod void test1877Fail() 
    {
        system.debug('TEST RevSys_ObservationHandler_Test testEntireClass-Start');     
        
       // RevSys_TestDataHelper.buildTestData(); 

        // Get the Observations we just built 

        Id my1875RecTypeId = RevSys_StaticUtility.OBSERVATION_TEST1877_RECTYPE_ID;
        QueryUtilityWrapper myQuWrap = QueryUtility.beginDynamicQuery(RevSys_StaticUtility.OBJAPI_OBSERVATION);  
        String myQuery = myQuWrap.QueryString; 
        myQuery += ' WHERE RecordTypeId = :my1875RecTypeId';
        Decimal criticalItemcount=0;

        List<Observation__c> myObsList = Database.query(myQuery); 

        Map<Id,Observation__c> myOldObsMap = new Map<Id,Observation__c>();
        Set<Id> myObsIdSet = new Set<Id>(); 
        

      /*  for(Observation__c myObs :myObsList)
        {   
            myObsIdSet.add(myObs.Id); 
            Observation__c myOldObs = myObs.clone(true,true,true, true); 
            myOldObsMap.put(myOldObs.Id,myOldObs); 

            myObs.Status__c = RevSys_StaticUtility.OBSERVATION_STATUS_COMPLETE; 
        }*/
        
        String rtname;
        List<Finding__c> observationFindings = new List<Finding__c>();
		Map<Id, String> obsRecordType = new Map<Id, String>();    
        Map<Id,String> returnMap = new Map<Id,String>(); //the return map variable
        for (RecordType rt : [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Observation__c']) { //grab the recordtypes for the specified sObject
            returnMap.put(rt.Id, rt.Name); //put the details into our map (Name -> Id)
        }
        
        for(Observation__c myObs :myObsList)
        {   
            myObsIdSet.add(myObs.Id); 
            Observation__c myOldObs = myObs.clone(true,true,true, true); 
            myOldObsMap.put(myOldObs.Id,myOldObs); 

            myObs.Status__c = RevSys_StaticUtility.OBSERVATION_STATUS_COMPLETE; 
        	rtName = returnMap.get(myObs.recordtypeid);
      
        	Map<String, List<Finding__c>> findingsByRecordTypes = RevSys_ObservationController.getTestQuestionMap();
            observationFindings = findingsByRecordTypes.get(rtName);
            if (observationFindings != null) {
                for (Finding__c finding : observationFindings) {
                    finding.Observation__c = myObs.Id;
                }
            }            
        }
         
        if (observationFindings != null && !observationFindings.isEmpty()) {
		  insert observationFindings;



            SelectorWrapper myFindingWrap = FindingSelector.getObsRelatedFindings(myObsIdSet); 

            List<Finding__c> myFindingList = myFindingWrap.SObjectList; 

            system.debug('ZZZZZZZZZZZZZ  myFindingList =  ' + myFindingList); 
           

                Integer myFindingListSize = myFindingList.size(); 

                system.assertNotEquals(0,myFindingListSize); 

                for(Finding__c myFinding :myFindingList)
                {
                    myFinding.Score__c = 1; 

     			 if(myFinding.Sub_category__c == 'Safety') { 
                        myFinding.Score__c = 4;
                    }
                    system.debug('myFinding ' + myFinding); 
                }
                Test.startTest(); 

                    criticalItemcount = RevSys_OverallScoreHelper2.scoreLogic1877(myFindingList);

                    system.assertEquals(4,criticalItemcount); 
                   

                Test.stopTest(); 
        }
             
      
        system.debug('TEST RevSys_ObservationHandler_Test testEntireClass-End');     
        return; 
    }
   
    
    /**
    *————————————————————————————————————————————————————
    * @Name: test1878Pass
    * @Description  One long method to build data needed for 
    *               Review System test classes 
    *————————————————————————————————————————————————————
    * @param    null Nothing
    * @return   void Nothing
    *————————————————————————————————————————————————————
    **/ 
    public static testMethod void test1878Pass() 
    {
        system.debug('TEST RevSys_ObservationHandler_Test testEntireClass-Start');     
        
       // RevSys_TestDataHelper.buildTestData(); 

        // Get the Observations we just built 

        Id my1878RecTypeId = RevSys_StaticUtility.OBSERVATION_TEST1878_RECTYPE_ID;
        QueryUtilityWrapper myQuWrap = QueryUtility.beginDynamicQuery(RevSys_StaticUtility.OBJAPI_OBSERVATION);  
        String myQuery = myQuWrap.QueryString; 
        myQuery += ' WHERE RecordTypeId = :my1878RecTypeId';
        Decimal criticalItemcount=0;

        List<Observation__c> myObsList = Database.query(myQuery); 
        Map<Id,Observation__c> myOldObsMap = new Map<Id,Observation__c>();
        Set<Id> myObsIdSet = new Set<Id>(); 
        

        for(Observation__c myObs :myObsList)
        {   
            myObsIdSet.add(myObs.Id); 
            Observation__c myOldObs = myObs.clone(false,true,true, true); 
            myOldObsMap.put(myOldObs.Id,myOldObs); 			
            myObs.Status__c = RevSys_StaticUtility.OBSERVATION_STATUS_COMPLETE; 
        }

        String rtname;
        List<Finding__c> observationFindings = new List<Finding__c>();
		Map<Id, String> obsRecordType = new Map<Id, String>();    
        Map<Id,String> returnMap = new Map<Id,String>(); //the return map variable
        for (RecordType rt : [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Observation__c']) { //grab the recordtypes for the specified sObject
            returnMap.put(rt.Id, rt.Name); //put the details into our map (Name -> Id)
        }
        
        System.debug('myObsList$$'+ myObsList);
        for(Observation__c myObs :myObsList)
        {   
            myObsIdSet.add(myObs.Id); 
            Observation__c myOldObs = myObs.clone(true,true,true, true); 
            myOldObsMap.put(myOldObs.Id,myOldObs); 

            myObs.Status__c = RevSys_StaticUtility.OBSERVATION_STATUS_COMPLETE; 
        	rtName = returnMap.get(myObs.recordtypeid);
      
        	Map<String, List<Finding__c>> findingsByRecordTypes = RevSys_ObservationController.getTestQuestionMap();
            observationFindings = findingsByRecordTypes.get(rtName);
            System.debug('observationFindings$$'+ observationFindings);
            if (observationFindings != null) {
                for (Finding__c finding : observationFindings) {
                    finding.Observation__c = myObs.Id;
                     System.debug('myObs.Id'+myObs.Id+'finding Id'+finding.Id);
                }
            }          
        }
         
        if (observationFindings != null && !observationFindings.isEmpty()) {
		  insert observationFindings;

        

            SelectorWrapper myFindingWrap = FindingSelector.getObsRelatedFindings(myObsIdSet); 

            List<Finding__c> myFindingList = myFindingWrap.SObjectList; 

            system.debug('ZZZZZZZZZZZZZ  myFindingList =  ' + myFindingList); 
           

                Integer myFindingListSize = myFindingList.size(); 
                system.assertNotEquals(0,myFindingListSize); 

                for(Finding__c myFinding :myFindingList)
                {
                    myFinding.Score__c = 1; 
                    system.debug('myFinding ' + myFinding); 
                }
           		update myFindingList;
            
            	System.debug('12myFindingList$$$$'+myFindingList);
            
              	for(Observation__c myObs :myObsList)
                {
                     
                    myObs.OperatedFromText__c = '123';
                    myObs.OperatedToText__c='246';
                    myObs.Status__c = RevSys_StaticUtility.OBSERVATION_STATUS_COMPLETE; 
                }
                update myObsList;
                Test.startTest();
            		String  errorMsg = RevSys_OverallScoreHelper2.determineScore(myObsList, myOldObsMap); 
            		criticalItemcount = RevSys_OverallScoreHelper2.scoreLogic1878(myFindingList);
                    system.assertEquals(1,criticalItemcount); 
               // Test.stopTest(); 
            
            	for(Finding__c myFinding :myFindingList)
                {
                    myFinding.Score__c = 2; 
                    system.debug('myFinding ' + myFinding);                  
     			
                }
           		update myFindingList;
            
            	System.debug('12myFindingList$$$$'+myFindingList);
            
              	for(Observation__c myObs :myObsList)
                {                     
                    myObs.OperatedFromText__c = '1234';
                    myObs.OperatedToText__c='2467';
                    myObs.Status__c = RevSys_StaticUtility.OBSERVATION_STATUS_COMPLETE; 
                }
                update myObsList;
            
            //    Test.startTest();
                errorMsg = RevSys_OverallScoreHelper2.determineScore(myObsList, myOldObsMap);
            		criticalItemcount = RevSys_OverallScoreHelper2.scoreLogic1878(myFindingList);
                    system.assertEquals(2,criticalItemcount); 
                
            	for(Finding__c myFinding :myFindingList)
                {
                    myFinding.Score__c = 3; 
                    system.debug('myFinding ' + myFinding); 
                   
                }
           		update myFindingList;
            
            	System.debug('12myFindingList$$$$'+myFindingList);
            
              	for(Observation__c myObs :myObsList)
                {
                     
                    myObs.OperatedFromText__c = '234';
                    myObs.OperatedToText__c='467';
                    myObs.Status__c = RevSys_StaticUtility.OBSERVATION_STATUS_COMPLETE; 
                }
                update myObsList;
            
            //    Test.startTest();
            errorMsg = RevSys_OverallScoreHelper2.determineScore(myObsList, myOldObsMap);
            criticalItemcount = RevSys_OverallScoreHelper2.scoreLogic1878(myFindingList);
            system.assertEquals(3,criticalItemcount);

               	for(Finding__c myFinding :myFindingList)
                {
                    myFinding.Score__c = 3; 
                    system.debug('myFinding ' + myFinding); 
                    
 				if(myFinding.Sub_category__c == 'Safety') { 
                        myFinding.Score__c = 3;
                    }
                   
                }
           		update myFindingList;
            
            	System.debug('12myFindingList$$$$'+myFindingList);
            
              	for(Observation__c myObs :myObsList)
                {
                     
                    myObs.OperatedFromText__c = '234';
                    myObs.OperatedToText__c='467';
                    myObs.Status__c = RevSys_StaticUtility.OBSERVATION_STATUS_COMPLETE; 
                }
                update myObsList;
            
            //    Test.startTest();
            		errorMsg = RevSys_OverallScoreHelper2.determineScore(myObsList, myOldObsMap);
            		criticalItemcount = RevSys_OverallScoreHelper2.scoreLogic1878(myFindingList);
                    system.assertEquals(3,criticalItemcount);

			
            Test.stopTest(); 
            
            
        }         
      
        system.debug('TEST RevSys_ObservationHandler_Test testEntireClass-End');     
        return; 
    }
    
    
    /**
    *————————————————————————————————————————————————————
    * @Name: test1877fail
    * @Description  One long method to build data needed for 
    *               Review System test classes 
    *————————————————————————————————————————————————————
    * @param    null Nothing
    * @return   void Nothing
    *————————————————————————————————————————————————————
    **/ 
    public static testMethod void test1878Fail() 
    {
        system.debug('TEST RevSys_ObservationHandler_Test testEntireClass-Start');     
        
       // RevSys_TestDataHelper.buildTestData(); 

        // Get the Observations we just built 

        Id my1878RecTypeId = RevSys_StaticUtility.OBSERVATION_TEST1878_RECTYPE_ID;
        QueryUtilityWrapper myQuWrap = QueryUtility.beginDynamicQuery(RevSys_StaticUtility.OBJAPI_OBSERVATION);  
        String myQuery = myQuWrap.QueryString; 
        myQuery += ' WHERE RecordTypeId = :my1878RecTypeId';
        Decimal criticalItemcount=0;

        List<Observation__c> myObsList = Database.query(myQuery); 

        Map<Id,Observation__c> myOldObsMap = new Map<Id,Observation__c>();
        Set<Id> myObsIdSet = new Set<Id>(); 
        

      /*  for(Observation__c myObs :myObsList)
        {   
            myObsIdSet.add(myObs.Id); 
            Observation__c myOldObs = myObs.clone(true,true,true, true); 
            myOldObsMap.put(myOldObs.Id,myOldObs); 

            myObs.Status__c = RevSys_StaticUtility.OBSERVATION_STATUS_COMPLETE; 
        }*/
        
        String rtname;
        List<Finding__c> observationFindings = new List<Finding__c>();
		Map<Id, String> obsRecordType = new Map<Id, String>();    
        Map<Id,String> returnMap = new Map<Id,String>(); //the return map variable
        for (RecordType rt : [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Observation__c']) { //grab the recordtypes for the specified sObject
            returnMap.put(rt.Id, rt.Name); //put the details into our map (Name -> Id)
        }
        
        for(Observation__c myObs :myObsList)
        {   
            myObsIdSet.add(myObs.Id); 
            Observation__c myOldObs = myObs.clone(true,true,true, true); 
            myOldObsMap.put(myOldObs.Id,myOldObs); 

            myObs.Status__c = RevSys_StaticUtility.OBSERVATION_STATUS_COMPLETE; 
        	rtName = returnMap.get(myObs.recordtypeid);
      
        	Map<String, List<Finding__c>> findingsByRecordTypes = RevSys_ObservationController.getTestQuestionMap();
            observationFindings = findingsByRecordTypes.get(rtName);
            if (observationFindings != null) {
                for (Finding__c finding : observationFindings) {
                    finding.Observation__c = myObs.Id;
                }   
            }         
        }
         
        if (observationFindings != null && !observationFindings.isEmpty()) {
    		insert observationFindings;



            SelectorWrapper myFindingWrap = FindingSelector.getObsRelatedFindings(myObsIdSet); 

            List<Finding__c> myFindingList = myFindingWrap.SObjectList; 

            system.debug('ZZZZZZZZZZZZZ  myFindingList =  ' + myFindingList); 
           

                Integer myFindingListSize = myFindingList.size(); 

                system.assertNotEquals(0,myFindingListSize); 

                for(Finding__c myFinding :myFindingList)
                {
                    myFinding.Score__c = 1; 

     			 if(myFinding.Sub_category__c == 'Safety') { 
                        myFinding.Score__c = 4;
                    }
                    system.debug('myFinding ' + myFinding); 
                }
                Test.startTest(); 

                    criticalItemcount = RevSys_OverallScoreHelper2.scoreLogic1878(myFindingList);

                    system.assertEquals(4,criticalItemcount); 
                   

                Test.stopTest(); 
        }
             
      
        system.debug('TEST RevSys_ObservationHandler_Test testEntireClass-End');     
        return; 
    }
   
}
/**
*___________________________________________________
*@Name: RevSys_CreateTestQuestionsHelper
*@Author: Chuck Walley
*@Created: Date: 11/4/2017
*@Used_By: Review Systems
*___________________________________________________
*@Description: Creates Questions for Review Systems Operational Test 
*
* IMPORTANT: 
* Observation = A single "test." The record type represents the type of Test. (ie, 1875 will have a record 
* type of "Test-1875." 
* Finding = A question on the test. For example, the 1875 test requires multiple questions, therefore an 
* Observation representing an 1875 test will have multiple associated Findings. 
*
* When an Review System Observation is created, the user will determine if multiple questions (Findings) are 
* needed to complete the Observation. This is accomplished through Record Types. 
*
* When multiple questions are required, the system will obtain those questions from Station_Audit_Setting__mdt. 
*	- Category = Observation Record Type name
*	- Sub-category = Question 
* Each Station Audit Sub-category will become a Sub-category on a Finding record. 
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/
global with sharing class RevSys_CreateTestQuestionsHelper {
    
	public static string TestQuestHelperErrorMsg;   

    /**
    *------------------------------------------
    * @Name: startProcess
    * @Description
    * Culls Observation records to retain only those needed a set of questions, 
    * then calls genQuestions to proceed with the process. 
    *------------------------------------------
    * @param    theNewObsList	List of Observation records, generally from the trigger
    * @return   String			The error messsage associated with the process; null if no error exist 
    *------------------------------------------
    **/ 
    public static string startProcess(List<Observation__c> theNewObsList)
    {
        system.debug('HELPER RevSys_CreateTestQuestionsUtility startProcess-Start');     
        
        string errMsg;  
        try { 
			List<Observation__c> myObservationMakeQuestionList = new List<Observation__c>(); 

	        // Get 18XX Observations which require more questions 

	        for(Observation__c theNewObs :theNewObsList) { 

	        	 system.debug('theNewObs.RecordTypeId ' + theNewObs.RecordTypeId );
				
	        	if(		theNewObs.RecordTypeId == RevSys_StaticUtility.OBSERVATION_TEST1875_RECTYPE_ID 
	        		||	theNewObs.RecordTypeId == RevSys_StaticUtility.OBSERVATION_TEST1876_RECTYPE_ID	
	        		||	theNewObs.RecordTypeId == RevSys_StaticUtility.OBSERVATION_TEST1877_RECTYPE_ID
	        		||	theNewObs.RecordTypeId == RevSys_StaticUtility.OBSERVATION_TEST1878_RECTYPE_ID) {

					myObservationMakeQuestionList.add(theNewObs); 
				}
			}
	        // If we have questions to make, go to it 
	        if(myObservationMakeQuestionList.size() > 0) {
				errMsg = genQuestions(myObservationMakeQuestionList); 
	        }

        }catch(Exception e) {
	    		errMsg = 'Problem creating questions for Observation: ' + e.getMessage();
	    }

		system.debug('HELPER RevSys_CreateTestQuestionsUtility startProcess-End');     
        return errMsg;  

    }
    /*---------------------------------------------------------------------------------------------------
    genQuestions
    ---------------------------------------------------------------------------------------------------*/   
    /**
    *------------------------------------------
    * @Name: genQuestions
    * @Description
    * Mainline of the process
    * 1: Looks at the Observation record type and gets the Record Type Name. This name is added to a list
    *    used to query later. 
    * 2: Get a Map of List of Subcategories (Questions) by Categories (represents the TEST, such as 1875). 
    *    (We are utilizing the Station_Audit_Setting__mdt Custom Metadata object to manage questions 
    *     associated with a TEST)  	 
    * 3: Loop through Observations and get the list of questions associated with the record type. (ie Test-1875) 
    * 4: Insert the Finding records 
    *------------------------------------------
    * @param    theNewObsList	List of Observation records needed to have questions added 
    * @return   String			The error messsage associated with the process; null if no error exist 
    *------------------------------------------
    **/ 
    public static string genQuestions(List<Observation__c> theNewObsList)
    {
        system.debug('HELPER RevSys_CreateTestQuestionsUtility genQuestions-Start');     
        
        string errMsg;   

        // 1: 
        // Make a list of Categories I need to select from the Station Audit Custom Metadata Type)
        // (Yes, we are using the Station Audit Custom Metadata Type at this juncture to store Questions for tests.) 

        List<String> myCatToSelectList = new List<String>(); 
        
        //added additional record type check for form 1876, 1877, 1878

        for(Observation__c theNewObs :theNewObsList) {
        	if(theNewObs.RecordTypeId == RevSys_StaticUtility.OBSERVATION_TEST1875_RECTYPE_ID ||
               theNewObs.RecordTypeId == RevSys_StaticUtility.OBSERVATION_TEST1876_RECTYPE_ID ||
               theNewObs.RecordTypeId == RevSys_StaticUtility.OBSERVATION_TEST1877_RECTYPE_ID ||
               theNewObs.RecordTypeId == RevSys_StaticUtility.OBSERVATION_TEST1878_RECTYPE_ID)	{

        		myCatToSelectList.add(RevSys_RecTypeUtility.convertIdToName(theNewObs.RecordTypeId)); 
        	}
        }

        List<Finding__c> myFindingList = new List<Finding__c>(); 

        // 2: 
        // Get a map of List of Questions (Subcategories) by their Test (Category)  

        Map<String,List<Station_Audit_Setting__mdt>> myQuestionListByTestNameMap = queryForQuestions(myCatToSelectList);

        // errorcheck
        // We're using a global variable to ensure no bad things happened in queryForQuestions.
        errMsg = TestQuestHelperErrorMsg; 

        if(errMsg == null) { 

	        // 3: 
	        // For each Observation record, get the associated list of questions from myQuestionListByTestNameMap.
	        // Create a Finding record for each question.    

	        for(Observation__c theNewObs :theNewObsList) {

	       		String myRecTypeName = RevSys_RecTypeUtility.convertIdToName(theNewObs.RecordTypeId); 

				List<Station_Audit_Setting__mdt> myQuestionList = myQuestionListByTestNameMap.Get(myRecTypeName); 

	            if (myQuestionList != null) {
	           		for(Station_Audit_Setting__mdt myQuestion :myQuestionList) {

	    				Finding__c myNewFinding = new Finding__c 
	    				(
	    					RecordTypeId 	= RevSys_StaticUtility.FINDING_REVIEW_SYSTEMS_RECTYPE_ID,
	    					Observation__c	= theNewObs.Id,
	    					Category__c		= myQuestion.Category__c,
	    					Sub_category__c	= myQuestion.Sub_category__c,
	    					Sequence__c		= myQuestion.Sub_category_sequence__c,
	    					Score__c		= null,
                            IsCriticalItem__c = myQuestion.IsCriticalItem__c
	    				); 

	    				myFindingList.add(myNewFinding); 
	           		}
	            }
	        }
	    
	        // 4: 
	        // Insert the Finding records 

	        //errMsg = DmlHelper.insertList(myFindingList); 

	        insert myfindingList; 
	    }
		system.debug('HELPER RevSys_CreateTestQuestionsUtility genQuestions-End');     
        return errMsg;  

    }
    /*---------------------------------------------------------------------------------------------------
    queryForQuestions
    Input: List of Tests 
    Output: A map of Questions by Tests 
    ---------------------------------------------------------------------------------------------------*/   
    /**
    *------------------------------------------
    * @Name: queryForQuestions
    * @Description
    * Culls Observation records to retain only those needed a set of questions, 
    * then calls genQuestions to proceed with the process. 
    *------------------------------------------
    * @param    theCategoryList	A String List representing the different Observation record types 
    * 			we are processing. (The record type name matches Category names in Station_Audit_Setting__mdt) 
    * @return   Map<String,List<Station_Audit_Setting__mdt>>	A map, where each row contains a list of Questions 
    *															for each Record Type we are procesing.  
    *------------------------------------------
    **/ 
    public static Map<String,List<Station_Audit_Setting__mdt>> queryForQuestions(List<String> theCategoryList)
    {
        system.debug('HELPER RevSys_CreateTestQuestionsUtility queryForQuestions-Start');    

        List<Station_Audit_Setting__mdt> mySasList = new List<Station_Audit_Setting__mdt>(); 

       	Map<String,List<Station_Audit_Setting__mdt>> myQuestionListByTestNameMap 
        														= new  Map<String,List<Station_Audit_Setting__mdt>>(); 

        // Get all the questions related to the tests 

       	SelectorWrapper myReturnedWrap 
       		= StationAuditSettingSelector.getRevSysFindings(RevSys_StaticUtility.REVSYS_APP_NAME,theCategoryList);  

       	TestQuestHelperErrorMsg = myReturnedWrap.ErrorMessage; 

       	if(TestQuestHelperErrorMsg == null)
       	{
			List<Station_Audit_Setting__mdt> myQuestionList = myReturnedWrap.SObjectList; 

	       	// Separate the questions into maps of tests. 

	       	for(Station_Audit_Setting__mdt myQuestion :myQuestionList) {

	       		mySasList = myQuestionListByTestNameMap.get(myQuestion.Category__c); 

	       		if(mySasList == null) {

	       			mySasList = new List<Station_Audit_Setting__mdt>(); 
	       		}

	       		mySasList.add(myQuestion);
	       		myQuestionListByTestNameMap.put(myQuestion.Category__c,mySasList); 
	       	}
	  	}

       	// Return the map for further processing. 

		system.debug('HELPER RevSys_CreateTestQuestionsUtility queryForQuestions-End');     
        return myQuestionListByTestNameMap; 
    }

}
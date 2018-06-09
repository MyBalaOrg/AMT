/**
*___________________________________________________
*@Name: RevSys_OverallScoreHelper2
*@Author: Chuck Walley
*@Created: Date: 11/4/2017
*@Used_By: Review Systems
*___________________________________________________
*@Description: 	Determines Overall Score when a Finding 
*				is submitted      	
*
*___________________________________________________
*@Changes: 
* 12-24-2017. Modified scoreLogic() to output a wrapper class containing the 
              score and indicator for critical items. 
              Modified calculateOverallScore() to consume the wrapper class 
              returned from scoreLogic().
  01-04-2018  ETR-519 - fix to score when submitted 1875 was updated (cwalley)
**/
global with sharing class RevSys_OverallScoreHelper2 { 
    
	public string errorMsg; 


	public class MapWrapper {
		Public String 						ErrorMessage; 
		Public Map<Id,List<Finding__c>> 	FindingByObsIdMap;

		public MapWrapper(String theErrorMessage, Map<Id,List<Finding__c>>  theFindingByObsIdMap) {
			ErrorMessage 		= theErrorMessage;
			FindingByObsIdMap 	= theFindingByObsIdMap; 
		}
	}

    /*
    public class ScoreWrapper {
        Public Integer         OverallScore; 
        Public Boolean         PassedCriticalItems;

        public ScoreWrapper(Integer theOverallScore, Boolean thePassedCriticalItems) {
            OverallScore        = theOverallScore;
            PassedCriticalItems = thePassedCriticalItems; 
        }
    }
    */


    /**
    *————————————————————————————————————————————————————
    * @Name: determineScore
    * @Description
    * Mainline method for the process of determing an overall score  
    *————————————————————————————————————————————————————
    * @param    theNewFindList	List of Finding records, generally from the trigger
    * @return   String			The error messsage associated with the process; null if no error exist 
    *————————————————————————————————————————————————————
    **/
    public static String determineScore(List<Observation__c> theNewObsList, Map<Id,SObject> theOldMap) 
    {
        system.debug('HELPER RevSys_OverallScoreHelper determineScore-Start'); 
        String errMsg;     


        try { 
     		errMsg = determineScore2(theNewObsList, theOldMap); 

        } catch(QueryException qe) {
	    		errMsg = Label.RevSys_ProblemDeterminingTestScore + ' ' + qe.getMessage();
		} catch(Exception e) {
	    		errMsg = Label.RevSys_ProblemDeterminingTestScore + ' ' + e.getMessage();
		}
    
		system.debug('HELPER RevSys_OverallScoreHelper determineScore-End');  
		  

        return errMsg;  

    }

    /**
    *————————————————————————————————————————————————————
    * @Name: determineScore
    * @Description
    * Mainline method for the process of determing an overall score  
    *————————————————————————————————————————————————————
    * @param    theNewFindList	List of Finding records, generally from the trigger
    * @return   String			The error messsage associated with the process; null if no error exist 
    *————————————————————————————————————————————————————
    **/
    public static String determineScore2(List<Observation__c> theNewObsList, Map<Id,SObject> theOldMap) 
    {
        system.debug('HELPER RevSys_OverallScoreHelper determineScore-Start'); 
        String errMsg;     
        
     
        // Cull Records & Make set of Observation Ids 

        Map<Id,Observation__c> myCulledObsMap = cullRecords(theNewObsList, theOldMap); 

		Set<Id> myRevSysObsIdSet = new Set<Id>(); 

		List<Observation__c> myObsUpdateList = new List<Observation__c>(); 

        if(myCulledObsMap.size() > 0 ) {
        	
        	for(Id myObsId :myCulledObsMap.keyset() ) {
        		myRevSysObsIdSet.add(myObsId); 
        	}

        	// Select all Findings associated the Observation Id list & Map Finding List to Observation Id 

        	MapWrapper myMapWrap = getAndMapFindings(myRevSysObsIdSet);

        	Map<Id,List<Finding__c>> myFindingListByObsMap = myMapWrap.FindingByObsIdMap; 
        	errMsg = myMapWrap.ErrorMessage; 

        	if(errMsg == null) {

	        	// For each Observation, Roll through all associated Findings to calculate Overall score 

	        	// +++ marry the old list of Obs with the updated scores. 

	        	myObsUpdateList = calculateOverallScore(myFindingListByObsMap, myCulledObsMap);
	        }
        }
    
		system.debug('HELPER RevSys_OverallScoreHelper determineScore-End');     

        return errMsg;  

    }

	/**
    *————————————————————————————————————————————————————
    * @Name: cullRecords
    * @Description
    * Rolls through Finding records and retains only those with a Review Systems record type 
    *————————————————————————————————————————————————————
    * @param    theNewFindList	List of Finding records
    * @return   Set<Id>			Set of Observation Ids which are associated with the Finding records 
    *————————————————————————————————————————————————————
    **/
    public static Map<Id,Observation__c> cullRecords(List<Observation__c> theNewObsList, Map<Id,SObject> theOldMap) 
    {
        system.debug('HELPER RevSys_OverallScoreHelper cullRecords-Start');     
        
        string errMsg;   

       Map<Id,Observation__c> myCulledObsMap = new Map<Id,Observation__c>(); 

        // Select only Review Systems Findings 

        for(Observation__c theNewObs :theNewObsList) {
        	SObject theOldSob = theOldMap.get(theNewObs.Id); 
        	String myOldStatus = (String)theOldSob.get(Schema.Observation__c.Status__c);

        	system.debug('myOldSatus ' + myOldStatus); 
        	system.debug('myNewStatus ' + theNewObs.Status__c); 

        	if((   theNewObs.RecordTypeId == RevSys_StaticUtility.OBSERVATION_TEST1875_RECTYPE_ID
        	    || theNewObs.RecordTypeId == RevSys_StaticUtility.OBSERVATION_TEST1876_RECTYPE_ID
        	    || theNewObs.RecordTypeId == RevSys_StaticUtility.OBSERVATION_TEST1877_RECTYPE_ID
        	    || theNewObs.RecordTypeId == RevSys_StaticUtility.OBSERVATION_TEST1878_RECTYPE_ID)

				&& theNewObs.Status__c == RevSys_StaticUtility.OBSERVATION_STATUS_COMPLETE )
        	    //&& theNewObs.Status__c != myOldStatus)										 			
        	{
        	
        		   	myCulledObsMap.put(theNewObs.Id,theNewObs);
        	}
        }

		system.debug('HELPER RevSys_OverallScoreHelper cullRecords-End');     
        return myCulledObsMap;  

    }
    /**
    *————————————————————————————————————————————————————
    * @Name: getAndMapFindings
    * @Description
    * We need to consider all Findings associated with an Observation to determine the Overall score, not just 
    * the updated records, (although updating one at a time is an edge case) therefore we need to query all 
    * Findings associated with an Observation. 
    *
    * Then, we group the Findings in a list, by Observation ID, and Map them. 
    *————————————————————————————————————————————————————
    * @param    theObsIdSet	Set of Observation Ids used to query all Finding records  
    * @return   Map<Id,List<Finding__c>> >	Map of a List of Finding records, keyed by Observation ID 
    *————————————————————————————————————————————————————
    **/
    public static MapWrapper getAndMapFindings(Set<Id> theObsIdSet)
    {
        system.debug('HELPER RevSys_OverallScoreHelper getAndMapFindings-Start');     
        
        // Select all associated finding records 

        List<Finding__c> myFindingList = new List<Finding__c> (); 

        SelectorWrapper myFindingWrap = FindingSelector.getObsRelatedFindings(theObsIdSet); 

        myFindingList 		= myFindingWrap.SObjectList; 
        String errorMessage = myFindingWrap.ErrorMessage; 

        // If we've selected records, put all findings associated with an Observation in a list 
        // and map by Observation Id 

        Map<Id,List<Finding__c>> myFindingListByObsMap = new Map<Id,List<Finding__c>>(); 

        if(myFindingList.size() > 0) {

        	List<Finding__c> myFindByObsList = new List<Finding__c>(); 

        	for(Finding__c myFinding :myFindingList) {

        		myFindByObsList = myFindingListByObsMap.get(myFinding.Observation__c); 

        		if(myFindByObsList == null) {
        			myFindByObsList = new List<Finding__c>(); 
        		}

        		myFindByObsList.add(myFinding); 
        		myFindingListByObsMap.put(myFinding.Observation__c, myFindByObsList); 
        	}
       	}

       	MapWrapper myMapWrap = new MapWrapper(errorMessage,myFindingListByObsMap); 


		system.debug('HELPER RevSys_OverallScoreHelper getAndMapFindings-End');     

		return myMapWrap; 
    }
    /**
    *————————————————————————————————————————————————————
    * @Name: calculateOverallScore
    * @Description
    * We're receiving a map containing a list of Findings, indexed by Observation ID. For each Observation Id, we 
    * are going to calculate the overall score and create a Observation record so we can update the Observation with 
    * the newly formulated score. 
    *————————————————————————————————————————————————————
    * @param    theFindingListByObsMap	The Map - List of Finding Records indexed by Observation ID 
    * @return   List<Observation__c>	A list of Observation records ready for an update.  
    *————————————————————————————————————————————————————
    **/ 
    public static List<Observation__c> calculateOverallScore(Map<Id,List<Finding__c>> theFindingListByObsMap, 
    														 Map<Id,Observation__c>   theCulledObsMap) 
    {
    	system.debug('HELPER RevSys_OverallScoreHelper cullRecords-Start');   

    	String errMsg;
        Decimal criticalScore = 0;

        List<Observation__c> myObsUpdateList = new List<Observation__c>(); 

        	
        // Roll through the Map and for each row, determine the Observation's overall score 

        for(Id myObsId :theFindingListByObsMap.keyset() ) { 

        	List<Finding__c> myFindingList = theFindingListByObsMap.get(myObsId);  			
          	if(myFindingList != null) {             
               
                Observation__c myUpdatedObs = theCulledObsMap.get(myObsId); 
               	RevSys_ScoreWrapper myScoreWrap = scoreLogic(myFindingList);                 

                    myUpdatedObs.OverallScore__c = myScoreWrap.OverallScore;
                
                system.debug('$$OverallScore'+myScoreWrap.OverallScore);	
                
                if (myUpdatedObs.RecordTypeId != RevSys_StaticUtility.OBSERVATION_TEST1877_RECTYPE_ID && 
                    myUpdatedObs.RecordTypeId != RevSys_StaticUtility.OBSERVATION_TEST1878_RECTYPE_ID){

                    if(myScoreWrap.OverallScore > 0){    
                    	myUpdatedObs.QualificationStatus__c = Label.RevSys_Unqualified;   
                        Integer myMaxPassingScore = Integer.valueOf(Label.RevSys_MaxQualifiedScore);     
                        if(myScoreWrap.OverallScore <= myMaxPassingScore ){    
                            if(myScoreWrap.PassedCriticalItems == TRUE) {
                                myUpdatedObs.QualificationStatus__c = Label.RevSys_Qualified;
                            }
                        }
                    }   
                }
                else
                {                   
                    criticalScore = scoreLogic1877(myFindingList);
                    System.debug('Critical score'+ criticalScore);
                    
                    if (criticalScore >= 2){
                        myUpdatedObs.QualificationStatus__c = Label.RevSys_Unqualified;
                    }
                    else if(criticalScore == 1 ){                        
                        myUpdatedObs.QualificationStatus__c = Label.RevSys_Qualified;
                    }
                    else
                    {
                        myUpdatedObs.QualificationStatus__c = null; 
                    }
                    
                }
                // Updated logic for form 1878, ETR - 586 starts here. 
                 if (myUpdatedObs.RecordTypeId == RevSys_StaticUtility.OBSERVATION_TEST1878_RECTYPE_ID){
                    
                    myUpdatedObs.QualificationStatus__c = null; 
                    
                    Integer myMaxPassingScore = Integer.valueOf(Label.RevSys_MaxQualifiedScore); 
                     if(myScoreWrap.OverallScore>myMaxPassingScore){
                         myUpdatedObs.QualificationStatus__c = Label.RevSys_Unqualified_1878;
                     }
    
                    if(myScoreWrap.OverallScore <= myMaxPassingScore && myScoreWrap.OverallScore!=0) {
    
                        if(myScoreWrap.OverallScore==1){ //Meets or Exceeds Performance Requirements
                            myUpdatedObs.QualificationStatus__c = Label.RevSys_Qualified_1878;
                        }
                        else if(myScoreWrap.OverallScore==2){//Fair Performance or Knowledge
                             myUpdatedObs.QualificationStatus__c = Label.RevSys_Semi_Qualified_1878;
                        }
                        else if(myScoreWrap.OverallScore==3){//Limited Performance or Knowledge
                             myUpdatedObs.QualificationStatus__c = Label.RevSys_Unqualified_1878;
                        }
                       
                        System.debug('myScoreWrap.PassedCriticalItems$$'+ myScoreWrap.PassedCriticalItems);   
                        if(myScoreWrap.PassedCriticalItems == TRUE) {
                            criticalScore = scoreLogic1878(myFindingList);
                    	    System.debug('Critical score$$'+ criticalScore);                            
                    
                            if (criticalScore == 2){//Fair Performance or Knowledge"
                                myUpdatedObs.QualificationStatus__c =Label.RevSys_Semi_Qualified_1878;
                            }
                            else if(criticalScore == 3 ){ //Limited Performance or Knowledge                       
                                myUpdatedObs.QualificationStatus__c = Label.RevSys_Unqualified_1878;
                            }
                        }
                        else{
                             myUpdatedObs.QualificationStatus__c = Label.RevSys_Unqualified_1878;
                        }
                            
                    }
                }
				//updated logic for form 1878, ETR - 586 ends here.
          		System.debug('myUpdatedObs$$'+myUpdatedObs);
                myObsUpdateList.add(myUpdatedObs); 
          	}
    	}

		system.debug('HELPER RevSys_OverallScoreHelper cullRecords-End');     
        return myObsUpdateList;  

    }
	/**
    *————————————————————————————————————————————————————
    * @Name: scoreLogic
    * @Description
    * Logic required to determine the overall score. We roll through findings, determine if 
    * the record should be considered, and if so, accumulate the points. Finally, calculate the average
    * and round up.  
    *————————————————————————————————————————————————————
    * @param    theFindingList	All Findings associates with one Observation
    * @return   ScoreWrapper    Wrapper class containing the final, calculated score and an indicator
    *                           denoting all critical items were passed 
    *————————————————————————————————————————————————————
    **/ 
    public static RevSys_ScoreWrapper scoreLogic(List<Finding__c> theFindingList)
    {
        system.debug('HELPER RevSys_OverallScoreHelper scoreLogic-Start');   

        Boolean myPassedCriticalItems = TRUE; 

        Decimal ZERO		        = 0;
        Decimal myScore 	        = 0; 
        Decimal myAggregate	        = 0;
        Decimal myCount 	        = 0;
        Decimal myCriticalCount     = 0;
       
        Integer myMaxPassingScore   = Integer.valueOf(Label.RevSys_MaxQualifiedScore); 

        for(Finding__c theFinding :theFindingList) {

            
            if(theFinding.Score__c > ZERO) {

                // Check to see if the item is critical 
                if(theFinding.IsCriticalItem__c==true) {                   

                    // It is critical 
                    myCriticalCount++;

                    if(theFinding.Score__c > myMaxPassingScore ) {

                        // This test will fail 

                        myPassedCriticalItems = FALSE; 
                    }
                    
                }
        		myAggregate += theFinding.Score__c; 
        		myCount ++; 
        	}
        }

		Integer myScoreInt; 
        
        if(myCount > ZERO) {
        
            myScore = myAggregate / myCount;  
            myScoreInt = Integer.valueOf(myScore.round(System.RoundingMode.HALF_UP)); 
           
		}
		system.debug('myScoreInt$$$$'+myScoreInt);  
        RevSys_ScoreWrapper myWrap = new RevSys_ScoreWrapper(myScoreInt, myPassedCriticalItems); 

		system.debug('HELPER RevSys_OverallScoreHelper scoreLogic-End');     
        return myWrap;  
    }
    
    
    /**
    *————————————————————————————————————————————————————
    * @Name: scoreLogic1877
    * @Description
    * Logic required to determine the critical score. We roll through findings, determine if 
    * the record should be considered, and if so, accumulate the points. Finally, calculate the maximum
    * score.  
    *————————————————————————————————————————————————————
    * @param    theFindingList	All Findings associates with one Observation
    * @return   decimal  Maximum of the critical items
    *  
    *————————————————————————————————————————————————————
    **/ 
    public static Decimal scoreLogic1877(List<Finding__c> theFindingList)
    {
       system.debug('HELPER RevSys_OverallScoreHelper scoreLogic1877-Start');   
       Decimal myCriticalCount    = 0;
       Decimal ZERO		          = 0;
       
       for(Finding__c theFinding :theFindingList) {
                
            if(theFinding.Score__c > ZERO && theFinding.IsCriticalItem__c==true) {                    
                if(theFinding.Score__c > myCriticalCount ) {
                          myCriticalCount = theFinding.Score__c; 
                    }                   
        	
        	}
        }	
		system.debug('HELPER RevSys_OverallScoreHelper scoreLogic1877-End');     
        return myCriticalCount;
    }
    
/**
    *————————————————————————————————————————————————————
    * @Name: scoreLogic1878
    * @Description
    * Logic required to determine the critical score for form 1878. We roll through findings, determine if 
    * the record crosses the critical score, break the loop at that finding and return the critical score.
    *————————————————————————————————————————————————————
    * @param    theFindingList	All Findings associates with one Observation
    * @return   decimal  Maximum of the critical items
    *  
    *————————————————————————————————————————————————————
    **/ 
    public static Decimal scoreLogic1878(List<Finding__c> theFindingList)
    {
       system.debug('HELPER RevSys_OverallScoreHelper scoreLogic1878-Start');   
       Decimal myCriticalCount    = 1;
       Decimal ZERO		          = 0;
       
       for(Finding__c theFinding :theFindingList) {
                
            if(theFinding.Score__c > ZERO && theFinding.IsCriticalItem__c==true) {                    
                if(theFinding.Score__c != myCriticalCount) {
                          myCriticalCount = theFinding.Score__c; 
                    break;
                    }                   
        	
        	}
        }	
		system.debug('HELPER RevSys_OverallScoreHelper scoreLogic1878-End');     
        return myCriticalCount;
    }
   
}
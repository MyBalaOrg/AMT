/**
*___________________________________________________
*@Name: RevSys_OverallScoreHelper
*@Author: Chuck Walley
*@Created: Date: 11/4/2017
*@Used_By: Review Systems
*___________________________________________________
*@Description: 	Determines Overall Score when a Finding 
*				is submitted      	
*
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/
global with sharing class RevSys_OverallScoreHelper { 
    
	public string errorMsg;   

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
    public static String determineScore(List<Finding__c> theNewFindList)
    {
        system.debug('HELPER RevSys_OverallScoreHelper determineScore-Start'); 
        String errMsg;     
        
        // Cull Records & Make set of Observation Ids 
        Set<Id> myRevSysObsIdSet = cullRecords(theNewFindList); 

        if(myRevSysObsIdSet.size() > 0 ) {

        	// Select all Findings associated the Observation Id list & Map Finding List to Observation Id 

        	Map<Id,List<Finding__c>> myFindingListByObsMap = getAndMapFindings(myRevSysObsIdSet);

        	// For each Observation, Roll through all associated Findings to calculate Overall score 

        	List<Observation__c> myObsUpdateList = calculateOverallScore(myFindingListByObsMap);

        	// Update the Observations with the Overall Score. 

        	errMsg = DmlHelper.updateList(myObsUpdateList); 
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
    public static Set<Id> cullRecords(List<Finding__c> theNewFindList)
    {
        system.debug('HELPER RevSys_OverallScoreHelper cullRecords-Start');     
        
        string errMsg;   

        Set<Id> myRevSysObsIdSet = new Set<Id>(); 

        // Select only Review Systems Findings 

        for(Finding__c theNewFind :theNewFindList) {

        	if(theNewFind.RecordTypeId == RevSys_StaticUtility.FINDING_REVIEW_SYSTEMS_RECTYPE_ID ) {
        		myRevSysObsIdSet.add(theNewFind.Observation__c); 
			}
		}

		system.debug('HELPER RevSys_OverallScoreHelper cullRecords-End');     
        return myRevSysObsIdSet;  

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
    public static Map<Id,List<Finding__c>> getAndMapFindings(Set<Id> theObsIdSet)
    {
        system.debug('HELPER RevSys_OverallScoreHelper getAndMapFindings-Start');     
        
        // Select all associated finding records 

       /* List<Finding__c> myFindingList = new List<Finding__c> 
        (
        	[SELECT Id, Observation__c, Category__c, Sub_category__c, Score__c, Sequence__c
        	 FROM   Finding__c 
        	 WHERE  Observation__c IN :theObsIdSet] 
             ); */
             List<Finding__c> myFindingList = new List<Finding__c>();
             SelectorWrapper wrapper = FindingSelector.getObsRelatedFindings(theObsIdSet);

             if(wrapper!=null) {
                myFindingList = (List<Finding__c>) wrapper.sObjectList;
            }

        

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

		system.debug('HELPER RevSys_OverallScoreHelper getAndMapFindings-End');     

		return myFindingListByObsMap; 
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
    public static List<Observation__c> calculateOverallScore(Map<Id,List<Finding__c>> theFindingListByObsMap)
    {
    	system.debug('HELPER RevSys_OverallScoreHelper cullRecords-Start');   

    	String errMsg;   

        List<Observation__c> myObsUpdateList = new List<Observation__c>(); 

        // Roll through the Map and for each row, determine the Observation's overall score 

        for(Id myObsId :theFindingListByObsMap.keyset() ) { 

        	List<Finding__c> myFindingList = theFindingListByObsMap.get(myObsId); 

          	if(myFindingList != null) {

          		Integer myOverallScore = scoreLogic(myFindingList); 

          		Observation__c myObservation = new Observation__c
          		(
          			Id 				= myObsId, 
          			OverallScore__c	= myOverallScore
          		);

          		myObsUpdateList.add(myObservation); 
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
    * @return   Integer			The final, calculated score
    *————————————————————————————————————————————————————
    **/ 
    public static Integer scoreLogic(List<Finding__c> theFindingList)
    {
        system.debug('HELPER RevSys_OverallScoreHelper scoreLogic-Start');   

        Decimal ZERO		= 0;
        Decimal myScore 	= 0; 
        Decimal myAggregate	= 0;
        Decimal myCount 	= 0; 

        for(Finding__c theFinding :theFindingList) {

        	if(theFinding.Score__c > ZERO) {
        		myAggregate += theFinding.Score__c; 
        		myCount ++; 
        	}
        }
          
		Integer myScoreInt; 

		if(myCount > 0) {

			myScore = myAggregate / myCount;  

			myScoreInt = Integer.valueOf(myScore.round(System.RoundingMode.HALF_UP));
		}

		system.debug('HELPER RevSys_OverallScoreHelper scoreLogic-End');     
        return myScoreInt;  
    }
}
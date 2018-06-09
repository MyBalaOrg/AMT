/**
*___________________________________________________
*@Name: RevSys_UpdateEmployeeResultSummaryHelper
*@Author: Chuck Walley
*@Created: Date: 11/7/2017
*@Used_By: Review Systems
*___________________________________________________
*@Description: Move information from the Observation to the Employee Result Summary 
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
* 12-25-2017 added QualificationStatus__c in mapTest1872 & mapTest1875
**/
global with sharing class RevSys_UpdateEmployeeResultSummaryHelper {

    /**
    *————————————————————————————————————————————————————
    * @Name: updateSummary
    * @Description
    * Culls Observation records to retain only those needed a set of questions, 
    * then calls genQuestions to proceed with the process. 
    *————————————————————————————————————————————————————
    * @param    theNewObsList   List of Observation records, generally from the trigger
    * @return   void            Nothing
    *————————————————————————————————————————————————————
    **/ 
    public static String updateSummary(List<Observation__c> theNewObsList, Map<id,SObject> theOldObsMap)
    {
        system.debug('HELPER RevSys_UpdateEmployeeResultSummaryHelper updateSummary-Start');     
        
        string errMsg; 

        // Cull records. 
        ObservationListWrapper wrapper = cullRecords(theNewObsList, theOldObsMap);
        List<Observation__c> myCompletedObsList  = new List<Observation__c>();
        List<Observation__c> myUpdatedObsList = new List<Observation__c>();
        List<EmployeeResultSummary__c> myErsInsertList = new List<EmployeeResultSummary__c>();

        system.debug('updateSummary-050'); 
        //List<Observation__c> myCompletedObsList = cullRecords(theNewObsList, theOldObsMap);
        if(wrapper!=null) {
            system.debug('updateSummary-100'); 
            myCompletedObsList = wrapper.myCompletedObsList;
            myUpdatedObsList = wrapper.myUpdatedObsList;
        }

        if(myCompletedObsList.size() > 0 ) {

            // Map Fields & Create Employee Result Summary List 
            //List<EmployeeResultSummary__c> myErsInsertList = fieldMapController(myCompletedObsList);
            myErsInsertList.addAll(fieldMapController(myCompletedObsList));

            system.debug('myErsInsertList 1 ' + myErsInsertList); 

            // Insert Employee Result Summary
             

        }
        if(myUpdatedObsList.size() > 0) {

             myErsInsertList.addAll(getRelatedEmpResultSumm(myUpdatedObsList));
        }

        system.debug('myErsInsertList 2 ' + myErsInsertList); 
        system.debug('UPSERTING LIST ' + myErsInsertList); 

        errMsg = DmlHelper.upsertList(myErsInsertList);

        system.debug('HELPER RevSys_UpdateEmployeeResultSummaryHelper updateSummary-End');     
        return errMsg; 
    }
    /**
    *————————————————————————————————————————————————————
    * @Name: cullRecords
    * @Description
    * Culls Observation records to retain only recores needed for the update
    *————————————————————————————————————————————————————
    * @param    theNewObsList   List of Observation records, generally from the trigger
    * @param    theOldObsMap    Map of the former recrods 
    * @return   List<Observation__c>    List of completed Observations 
    *————————————————————————————————————————————————————
    **/ 
    public static ObservationListWrapper cullRecords(List<Observation__c> theNewObsList, Map<id,SObject> theOldObsMap)
    {
        system.debug('HELPER RevSys_UpdateEmployeeResultSummaryHelper cullRecords-Start');     
        
        string errMsg; 

        List<Observation__c> myCompletedObsList = new List<Observation__c>(); 
         List<Observation__c> myUpdatedObsList = new List<Observation__c>(); 

        for(Observation__c theNewObs :theNewObsList) {
            SObject theOldSob = theOldObsMap.get(theNewObs.Id); 
            String myOldStatus = (String)theOldSob.get(Schema.Observation__c.Status__c);

            system.debug('myOldSatus ' + myOldStatus); 
            system.debug('myNewStatus ' + theNewObs.Status__c); 

            if((   theNewObs.RecordTypeId == RevSys_StaticUtility.OBSERVATION_TEST1872_RECTYPE_ID
                || theNewObs.RecordTypeId == RevSys_StaticUtility.OBSERVATION_TEST1875_RECTYPE_ID
                || theNewObs.RecordTypeId == RevSys_StaticUtility.OBSERVATION_TEST1876_RECTYPE_ID
                || theNewObs.RecordTypeId == RevSys_StaticUtility.OBSERVATION_TEST1877_RECTYPE_ID
                || theNewObs.RecordTypeId == RevSys_StaticUtility.OBSERVATION_TEST1878_RECTYPE_ID)

                && theNewObs.Status__c == RevSys_StaticUtility.OBSERVATION_STATUS_COMPLETE 
                && theNewObs.Status__c != myOldStatus)                                                  
            {
            
                    myCompletedObsList.add(theNewObs); 

            } else if((theNewObs.RecordTypeId == RevSys_StaticUtility.OBSERVATION_TEST1872_RECTYPE_ID
                || theNewObs.RecordTypeId == RevSys_StaticUtility.OBSERVATION_TEST1875_RECTYPE_ID
                || theNewObs.RecordTypeId == RevSys_StaticUtility.OBSERVATION_TEST1876_RECTYPE_ID
                || theNewObs.RecordTypeId == RevSys_StaticUtility.OBSERVATION_TEST1877_RECTYPE_ID
                || theNewObs.RecordTypeId == RevSys_StaticUtility.OBSERVATION_TEST1878_RECTYPE_ID)
            && theNewObs.Status__c == RevSys_StaticUtility.OBSERVATION_STATUS_COMPLETE
            && myOldStatus == RevSys_StaticUtility.OBSERVATION_STATUS_COMPLETE) {

                myUpdatedObsList.add (theNewObs);
            }
        }
        ObservationListWrapper listWrapper =  new ObservationListWrapper();
        listWrapper.myUpdatedObsList = myUpdatedObsList;
        listWrapper.myCompletedObsList = myCompletedObsList;


        system.debug('HELPER RevSys_UpdateEmployeeResultSummaryHelper cullRecords-End');     
        return listWrapper; 

    }
    
    /**
    *————————————————————————————————————————————————————
    * @Name: getRelatedEmpResultSumm
    * @Description
    * Controls which mapping method is used for each record type
    *————————————————————————————————————————————————————
    * @param    theNewObsList   List of Observation records, generally from the trigger
    * @return   List<EmployeeResultSummary__c>> List of completed Observations 
    *————————————————————————————————————————————————————
    **/ 
    public static List<EmployeeResultSummary__c> getRelatedEmpResultSumm(List<Observation__c> theObsList) {
        system.debug('HELPER RevSys_ObservationHelper getRelatedEmpResultSumm-Start');   
        System.debug('$$ getRelatedEmpResultSumm' +theObsList);
        Map<Id,Observation__c> observationIdMap = new Map<Id,Observation__c>();
        List<EmployeeResultSummary__c> myUpdatedERSList = new List<EmployeeResultSummary__c>();

        if(theObsList!=null) {
            for(Observation__c obs :theObsList ) {
             observationIdMap.put(obs.Id,obs);
            }
        }      
        SelectorWrapper wrap =  EmployeeResultSummarySelector.getEmployeeResultSummary(observationIdMap.keySet());
        if(wrap!=null) {
           List<EmployeeResultSummary__c> empResultSummaryList = (List<EmployeeResultSummary__c>) wrap.sObjectList;
           for(EmployeeResultSummary__c myErsRec : empResultSummaryList) {
                if(observationIdMap.containsKey(myErsRec.Observation__c)) {
                    Observation__c theObs = observationIdMap.get(myErsRec.Observation__c);
                    if(theObs.RecordTypeId == RevSys_StaticUtility.OBSERVATION_TEST1872_RECTYPE_ID) {

                        myErsRec = mapTest1872(myErsRec,theObs); 
                    }
                    else if(    theObs.RecordTypeId == RevSys_StaticUtility.OBSERVATION_TEST1875_RECTYPE_ID
                        ||  theObs.RecordTypeId == RevSys_StaticUtility.OBSERVATION_TEST1876_RECTYPE_ID
                        ||  theObs.RecordTypeId == RevSys_StaticUtility.OBSERVATION_TEST1877_RECTYPE_ID
                        ||  theObs.RecordTypeId == RevSys_StaticUtility.OBSERVATION_TEST1878_RECTYPE_ID ) {

                        myErsRec = mapTest1875(myErsRec,theObs); 
                    }
                    myUpdatedERSList.add(myErsRec);

                }
            }
        }
        system.debug('HELPER RevSys_ObservationHelper getRelatedEmpResultSumm-End'); 
        system.debug('$$ myUpdatedERSList '+myUpdatedERSList);  
    return myUpdatedERSList;
    }

    /**
    *————————————————————————————————————————————————————
    * @Name: fieldMapController
    * @Description
    * Controls which mapping method is used for each record type
    *————————————————————————————————————————————————————
    * @param    theNewObsList   List of Observation records, generally from the trigger
    * @return   List<EmployeeResultSummary__c>> List of completed Observations 
    *————————————————————————————————————————————————————
    **/ 
    public static List<EmployeeResultSummary__c> fieldMapController(List<Observation__c> theObsList)
    {
        system.debug('HELPER RevSys_ObservationHelper fieldMapController-Start');     
        
        string errMsg; 

        List<EmployeeResultSummary__c> myErsInsertList = new List<EmployeeResultSummary__c>(); 

        for(Observation__c theObs :theObsList) {

            EmployeeResultSummary__c myErsRec = new EmployeeResultSummary__c(); 

            if(theObs.RecordTypeId == RevSys_StaticUtility.OBSERVATION_TEST1872_RECTYPE_ID) {

                myErsRec = mapTest1872(myErsRec,theObs); 
            }
            else if(    theObs.RecordTypeId == RevSys_StaticUtility.OBSERVATION_TEST1875_RECTYPE_ID
                    ||  theObs.RecordTypeId == RevSys_StaticUtility.OBSERVATION_TEST1876_RECTYPE_ID
                    ||  theObs.RecordTypeId == RevSys_StaticUtility.OBSERVATION_TEST1877_RECTYPE_ID
                    ||  theObs.RecordTypeId == RevSys_StaticUtility.OBSERVATION_TEST1878_RECTYPE_ID ) {
            
                myErsRec = mapTest1875(myErsRec,theObs); 
            }
            else {


            }
            // continue checking for record types here... 

            myErsInsertList.add(myErsRec);
        }

        system.debug('HELPER RevSys_ObservationHelper fieldMapController-End');     
        return myErsInsertList; 

    }
    /**
    *————————————————————————————————————————————————————
    * @Name: mapTest1872
    * @Description
    * Culls Observation records to retain only recores needed for the update
    *————————————————————————————————————————————————————
    * @param    theNewObsList   List of Observation records, generally from the trigger
    * @return   List<EmployeeResultSummary__c>> List of completed Observations 
    *————————————————————————————————————————————————————
    **/ 
    public static EmployeeResultSummary__c mapTest1872(EmployeeResultSummary__c myErsRec,Observation__c theObs)
    {
        system.debug('HELPER RevSys_ObservationHelper mapTest1872-Start');     
        
        string errMsg; 

        //EmployeeResultSummary__c myErsRec = new EmployeeResultSummary__c
        //( 
            myErsRec.RecordTypeId           = RevSys_StaticUtility.EMP_RES_SUMM_TEST1872_RECTYPE_ID;
            myErsRec.Comments__c            = theObs.Comments__c;
           // myErsRec.EvaluationDate__c              = theObs.Date__c;
            DateTime dT                     = theObs.EvaluationDateTime__c;
            myErsRec.EvaluationDate__c                = dt!=null ? date.newinstance(dT.year(), dT.month(), dT.day()) : null;
            myErsRec.Employee__c            = theObs.Employee__c; 
            myErsRec.RegionProperty__c      = theObs.RegionProperty__c;
            myErsRec.Result__c              = theObs.Result__c;
            myErsRec.Observation__c         = theObs.Id;
            myErsRec.QualificationStatus__c = theObs.QualificationStatus__c;
            myErsRec.Type__c                = 'Observation';
        //);         
         //Process__c          = theObs.Process__c,

        system.debug('HELPER RevSys_ObservationHelper mapTest1872-End');     
        return myErsRec;
    }

    /**
    *————————————————————————————————————————————————————
    * @Name: mapTest1875
    * @Description
    * Culls Observation records to retain only recores needed for the update
    *————————————————————————————————————————————————————
    * @param    theNewObsList   List of Observation records, generally from the trigger
    * @return   List<EmployeeResultSummary__c>> List of completed Observations 
    *————————————————————————————————————————————————————
    **/ 
    public static EmployeeResultSummary__c mapTest1875(EmployeeResultSummary__c myErsRec,Observation__c theObs)
    {
        system.debug('HELPER RevSys_ObservationHelper mapTest1875-Start'); 
        system.debug('myErsRec ' + myErsRec); 
        system.debug('theObs '   + theObs); 
        
        string errMsg; 

        Id myErsRecTypeId = determineRecordType(theObs.RecordTypeId); 

        //EmployeeResultSummary__c myErsRec = new EmployeeResultSummary__c
        //( 
            myErsRec.RecordTypeId           = myErsRecTypeId;
            myErsRec.Comments__c            = theObs.Comments__c;
            //myErsRec.EvaluationDate__c              = theObs.Date__c;
            DateTime dT                     = theObs.EvaluationDateTime__c;
            myErsRec.EvaluationDate__c                = dt!=null ? date.newinstance(dT.year(), dT.month(), dT.day()) : null;
            myErsRec.Employee__c            = theObs.Employee__c;
            myErsRec.LocationFrom__c        = theObs.OperatedFromFormula__c;
            myErsRec.LocationTo__c          = theObs.OperatedToFormula__c;
            myErsRec.TrainNumber__c         = theObs.TrainNumber__c;
            myErsRec.Result__c              = String.valueOf(theObs.OverallScore__c);
            myErsRec.Observation__c         = theObs.Id;
            myErsRec.QualificationStatus__c = theObs.QualificationStatus__c;
            myErsRec.Type__c                = 'Observation';
        //);

        system.debug('HELPER RevSys_ObservationHelper mapTest1875-End');     
        return myErsRec;
    }
    /**
    *————————————————————————————————————————————————————
    * @Name: determineRecordType
    * @Description
    * Determines the Employee Result Summary based on the Observation record type
    *————————————————————————————————————————————————————
    * @param    theObsRecTypeId Observation Record Type Id 
    * @return   Id The Employee Result Summary ID
    *————————————————————————————————————————————————————
    **/ 
    public static Id determineRecordType(Id theObsRecTypeId)
    {
        system.debug('HELPER RevSys_ObservationHelper determineRecordType-Start');     
        
        string errMsg; 

        Id myEarsRecTypeId = null; 

        if(theObsRecTypeId == RevSys_StaticUtility.OBSERVATION_TEST1875_RECTYPE_ID)
        {
            myEarsRecTypeId = RevSys_StaticUtility.EMP_RES_SUMM_TEST1875_RECTYPE_ID; 
        }
        else if(theObsRecTypeId == RevSys_StaticUtility.OBSERVATION_TEST1876_RECTYPE_ID)
        {
            myEarsRecTypeId = RevSys_StaticUtility.EMP_RES_SUMM_TEST1876_RECTYPE_ID; 
        }
        else if(theObsRecTypeId == RevSys_StaticUtility.OBSERVATION_TEST1877_RECTYPE_ID)
        {
            myEarsRecTypeId = RevSys_StaticUtility.EMP_RES_SUMM_TEST1877_RECTYPE_ID; 
        }
        else if(theObsRecTypeId == RevSys_StaticUtility.OBSERVATION_TEST1878_RECTYPE_ID)
        {
            myEarsRecTypeId = RevSys_StaticUtility.EMP_RES_SUMM_TEST1878_RECTYPE_ID; 
        }


        system.debug('HELPER RevSys_ObservationHelper determineRecordType-End');     
        return myEarsRecTypeId;
    }



    global class ObservationListWrapper {
        public List<Observation__c> myUpdatedObsList;
        public List<Observation__c> myCompletedObsList;

    }

}
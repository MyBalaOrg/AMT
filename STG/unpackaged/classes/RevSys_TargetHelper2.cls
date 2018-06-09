/**
*___________________________________________________
*@Name:     RevSys_TargetHelper2
*@Author:   Abhishek Shanbhag
*@Created:  Date: 12/07/2017
*@Used_By:  SPARTN  
*___________________________________________________
*@Description: Helper class for Targets 
Process: 
We determine the contect of the Observation. We want to know if it is 
new, modified or intended to be a soft deletion. 

For every Observation, we want to know the test number associated. We are 
going to pull OccupationSpecificRequirememt (OSR) records associated with 
those test numbers. These OSR records will have an associated Target or Requirement. 

Next, we pull Employee Specific Requirements (ESR) records associted with the 
Employees and (Targets OR Requirements). 

With this information, we  


*___________________________________________________
*@Changes: 
* 02-19-2018 - cwalley - Modified validateCertification to allow OSR records to
*                        look up to Requirements (OccupationRequirement - 
*                        SPARTN Requirement record type. This allows one Requirement 
*                        to have multiple Observations. 
* 05-30-2018 - hemanth - Modifed deriveTargetsAndRequirements method to populate testNumberAndTypeKey 
*                        with Test Number when there is a target requirement for the OSR
**/
public with sharing class RevSys_TargetHelper2 {
    
    private class ContactMapWrapper {
        Public String               ErrorMessage; 
        Public Map<Id,Contact>      ContactMap;
        
        public ContactMapWrapper(String theErrorMessage, Map<Id,Contact>  theContactMap) {
            ErrorMessage    = theErrorMessage;
            ContactMap      = theContactMap; 
        }
    }
    
    private class OsrListByTestNumMapWrapper {
        Public String               ErrorMessage; 
        Public Map<String,List<OccupationSpecificRequirement__c>> 
            OsrListByTestNumMap;
        
        public OsrListByTestNumMapWrapper(String theErrorMessage, 
                                          Map<String,List<OccupationSpecificRequirement__c>> theOsrListByTestNumMap) {
                                              ErrorMessage        = theErrorMessage;
                                              OsrListByTestNumMap = theOsrListByTestNumMap; 
                                          }
    }
    
    private class AppliesToAllTargetWrapper {
        Public String               ErrorMessage; 
        Public List<OccupationSpecificRequirement__c> 
            AppliesToAllTargetList;
        
        public AppliesToAllTargetWrapper(String theErrorMessage, 
                                         List<OccupationSpecificRequirement__c> theAppliesToAllTargetList) {
                                             ErrorMessage           = theErrorMessage;
                                             AppliesToAllTargetList = theAppliesToAllTargetList; 
                                         }
    }
    
    private class EsrByEmpAndTgtRqmtMapWrapper {
        Public String               ErrorMessage; 
        Public Map<String,List<EmployeeSpecificRequirement__c>> 
            EsrByEmpAndTgtRqmtMap;
        
        public EsrByEmpAndTgtRqmtMapWrapper(String theErrorMessage, 
                                            Map<String,List<EmployeeSpecificRequirement__c>> theEsrByEmpAndTgtRqmtMap) {
                                                ErrorMessage          = theErrorMessage;
                                                EsrByEmpAndTgtRqmtMap = theEsrByEmpAndTgtRqmtMap; 
                                            }
    }
    
    @TestVisible
    private class ObservationWrapper {
        Public String               Context; 
        Public Observation__c       Observation;
        
        public ObservationWrapper(String theContext, Observation__c  theObservation) {
            Context         = theContext;
            Observation     = theObservation; 
        }
    }
    
    private static Set<Id> EmployeeIdSet    = new Set<Id>();
    private static Set<Id> TargetIdSet      = new Set<Id>(); 
    private static Set<Id> RequirementIdSet = new Set<Id>(); 
    
    /**
*————————————————————————————————————————————————————
* @Name: processObservation
* @Description
* Determines the context of the Observation (New, Update, Remove) 
* and puts the Observation in a wrapper class, along with the 
* context. 
*————————————————————————————————————————————————————
* @param    theEmpIdList    Set of ContactIds
* @return   Map<Id,Contact> Map of Contacts by ID 
*
* Get a set of:
*  - Test Numbers tied to the Observations 
*  - Record Type Names associated to the Observations 
*  - Employee Ids associated with the Observations 
*————————————————————————————————————————————————————
**/ 
    public static string processObservation(List<Observation__c> theNewObsList,Map<Id,Observation__c>theOldObsMap)
    {
        system.debug('HELPER: RevSys_TargetHelper.processObservation - START');
        
        SelectorWrapper myApplyToAllTargetWrapper = getSupervisorGenericTargets();
        
        String errMsg = myApplyToAllTargetWrapper.ErrorMessage; 
        List<OccupationCertification__c> myApplyToAllTargetList = myApplyToAllTargetWrapper.SObjectList; 
        
        List<ObservationWrapper> myObsWrapList = new List<ObservationWrapper>(); 
        List<ObservationWrapper> myObsWrapNon1872List = new List<ObservationWrapper>();
        
        // Put the Emloyees and Supervisors in a Contact Map
        ContactMapWrapper myContactMapWrap = mapContacts(theNewObsList); 
        
        errMsg = myContactMapWrap.ErrorMessage; 
        Map<Id,Contact> myContactMap = myContactMapWrap.ContactMap; 
        
        if(errMsg == null && myContactMap.size() > 0) { 
            
            for(Observation__c theNewObs :theNewObsList) { 
                
                if(theNewObs.RecordTypeId == RevSys_StaticUtility.OBSERVATION_TEST1872_RECTYPE_ID) {
                    
                    // Get the related Contact
                    
                    Contact myEmp = myContactMap.get(theNewObs.Employee__c); 
                    
                    // Is this happening with an INSERT
                    if(theOldObsMap == null) {
                        if(theNewObs.Status__c == Label.RevSys_Observation_Status_Complete){
                           
                            // Process the new record as an "add"  
                            
                            ObservationWrapper myObsWrapAdd 
                                = new ObservationWrapper(Label.Revsys_Constant_Add, theNewObs); 
                            myObsWrapList.add(myObsWrapAdd); 
                        }                    
                        
                    }
                    else {
                        
                        // This is an UPDATE 
                        SObject theOldSobj = theOldObsMap.get(theNewObs.Id); 
                        Observation__c theOldObs = (Observation__c)theOldSobj; 
                        
                        if(theNewObs.Employee__c != null) { 
                            
                            // is this a newly submitted observation or an update? 
                            if(theOldObs.Status__c == Label.RevSys_Observation_Status_Draft && 
                               theNewObs.Status__c == Label.RevSys_Observation_Status_Complete) {
                                   
                                   // Process the new record as an "add"  
                                   
                                   ObservationWrapper myObsWrapAdd = new ObservationWrapper(Label.Revsys_Constant_Add, theNewObs); 
                                   myObsWrapList.add(myObsWrapAdd); 
                               }
                            else if(theOldObs.Status__c == Label.RevSys_Observation_Status_Complete && 
                                    theNewObs.Status__c == Label.RevSys_Observation_Status_Complete) {  
                                        
                                        // Process the old record as a "remove"
                                        // Process the new record as an "add"  
                                        
                                        /*if(theOldObs.Employee__c!=NULL && theOldObs.Employee__c != theNewObs.Employee__c){
                                            EmployeeIdSet.add(theOldObs.Employee__c);
                                        }*/
                                        
                                        ObservationWrapper myObsWrapRemove = new ObservationWrapper(Label.RevSys_Generic_Removed, theOldObs); 
                                        myObsWrapList.add(myObsWrapRemove); 
                                        
                                        ObservationWrapper myObsWrapAdd = new ObservationWrapper(Label.Revsys_Constant_Add, theNewObs); 
                                        myObsWrapList.add(myObsWrapAdd); 
                                    }
                            else if(theOldObs.Status__c == Label.RevSys_Observation_Status_Complete && 
                                    theNewObs.Status__c == Label.RevSys_Generic_Removed) {  
                                        
                                        // Process the new record as a "remove"
                                        
                                        ObservationWrapper myObsWrapRemove = new ObservationWrapper(Label.RevSys_Generic_Removed, theNewObs); 
                                        myObsWrapList.add(myObsWrapRemove); 
                                    }
                        }
                    }
                }
                
                else if(theNewObs.RecordTypeId == RevSys_StaticUtility.OBSERVATION_TEST1875_RECTYPE_ID ||
                        theNewObs.RecordTypeId == RevSys_StaticUtility.OBSERVATION_TEST1876_RECTYPE_ID || 
                        theNewObs.RecordTypeId == RevSys_StaticUtility.OBSERVATION_TEST1877_RECTYPE_ID || 
                        theNewObs.RecordTypeId == RevSys_StaticUtility.OBSERVATION_TEST1878_RECTYPE_ID){
                            
                            if(theOldObsMap == null){
                                
                                //This is an insert scenario
                                if(theNewObs.Status__c == Label.RevSys_Observation_Status_Complete){
                                    
                                    ObservationWrapper obsNon1872WrapAdd = new ObservationWrapper(Label.Revsys_Constant_Add, theNewObs);
                                    myObsWrapNon1872List.add(obsNon1872WrapAdd);
                                    
                                }
                                
                            } 
                            else{
                                
                                //This is an update scenario
                                SObject theOldSobj = theOldObsMap.get(theNewObs.id);
                                Observation__c theOldObs = (Observation__c)theOldSobj;
                                
                                if(theNewObs.Status__c == Label.RevSys_Observation_Status_Complete &&
                                   theOldObs.Status__c != theNewObs.Status__c){
                                       
                                       ObservationWrapper obsNon1872WrapAdd = new ObservationWrapper(Label.Revsys_Constant_Add, theNewObs);
                                       myObsWrapNon1872List.add(obsNon1872WrapAdd);
                                   }
                                else if(theNewObs.Status__c == Label.RevSys_Generic_Removed &&
                                        theOldObs.Status__c != theNewObs.Status__c){
                                            
                                            ObservationWrapper obsNon1872WrapRemove = new ObservationWrapper(Label.RevSys_Generic_Removed, theNewObs);
                                            myObsWrapNon1872List.add(obsNon1872WrapRemove);
                                            
                                        }
                                
                            }
                        }	  
                
            }
            
            // Now, we have an expanded list of Observations. Go process them. 
            if(myObsWrapList.size() > 0) { 
                errMsg = processExpandedObs(myObsWrapList, 
                                            myApplyToAllTargetList, myContactMap); 
            }
            
            //Now, we process the list of Non 1872 Observations
            if(myObsWrapNon1872List.size() > 0){
                errMsg = processExpandedNon1872Obs(myObsWrapNon1872List, myContactMap);
			}
        }
        system.debug('HELPER: RevSys_TargetHelper.processObservation - End');
        
        return errMsg; 
    }
    /**
*————————————————————————————————————————————————————
* @Name: processExpandedObs
* @Description
* This method obtains related OSRs (Target-Observations) and 
* the related ESR records
* 
* It then, processes: 
*   Generic Targets (Supvervisor gets credit for any Observation) 
*   Specific Targets (Employee gets credit for a Specific Test)
*   Divisional Targets (The "Division" gets the credit)
*————————————————————————————————————————————————————
* @param    theEmpIdList    Set of ContactIds
* @return   Map<Id,Contact> Map of Contacts by ID 
*————————————————————————————————————————————————————
**/ 
    public static String processExpandedObs(List<ObservationWrapper> theObsWrapList, 
                                            List<OccupationCertification__c> theApplyToAllTargetList,
                                            Map<Id,Contact> theContactMap)
    {
        system.debug('HELPER RevSys_TargetHelper processExpandedObs-Start');       
        
        String errMsg; 
        Integer lengthOfPeriod;
        Integer actualPeriod;
        String frequency;
        Date myEarliestDate;
        
        List<EmployeeSpecificRequirement__c> esrCheckList = new List<EmployeeSpecificRequirement__c>();
        Map<Id, EmployeeCertification__c> ecByIdMap = new Map<Id, EmployeeCertification__c>();
        Map<Id, OccupationSpecificRequirement__c> osrByIdMap = new Map<Id, OccupationSpecificRequirement__c>();
        Map<Id, List<OccupationSpecificRequirement__c>> osrByTrMap = new Map<Id, List<OccupationSpecificRequirement__c>>();
        Map<Id, EmployeeSpecificRequirement__c> finalUpdateMap = new Map<Id, EmployeeSpecificRequirement__c>();
        List<EmployeeCertification__c> ecAffected = new List<EmployeeCertification__c>();
        
        // Get a Map of Target-Observation List by Test Number. 
        // Each Test Number will have a list of associated OSRs. 
        // We'll use these OSRs to find the Targets and Requirements related
        // to the Test Numbers.  
        
        OsrListByTestNumMapWrapper myOsrListByTestMapWrap 
            = deriveTargetsAndRequirements(theObsWrapList); 
        
        // Move the wrapper items into their respective components 
        errMsg  = myOsrListByTestMapWrap.ErrorMessage;
        Map<String,List<OccupationSpecificRequirement__c>> myOsrListByTestNumMap 
            = myOsrListByTestMapWrap.OsrListByTestNumMap; 
        
        if(errMsg == null) { 
            
            EsrByEmpAndTgtRqmtMapWrapper myEsrMapWrap = mapEsrRecords(); 
            
            errMsg = myEsrMapWrap.ErrorMessage; 
            Map<String,List<EmployeeSpecificRequirement__c>> myEsrByEmpAndTgtRqmtMap
                = myEsrMapWrap.EsrByEmpAndTgtRqmtMap; 
            
            if(errMsg == null) {
                
                // Generic Supervisor Targets 
                myEsrByEmpAndTgtRqmtMap
                    = applyGenericTargets(theObsWrapList,  theApplyToAllTargetList,
                                          myOsrListByTestNumMap, myEsrByEmpAndTgtRqmtMap); 
                // Specific Targets 
                myEsrByEmpAndTgtRqmtMap  
                    = applySpecificTargets(theObsWrapList,        
                                           myOsrListByTestNumMap, myEsrByEmpAndTgtRqmtMap);
                // Division Targets 
                List<EmployeeSpecificRequirement__c> myDivEsrList 
                    = applyDivisionTargets(theObsWrapList, theContactMap);
                
                // unload map into update list 
                
                List<EmployeeSpecificRequirement__c> myUpdateEsrList = new List<EmployeeSpecificRequirement__c>(); 
                
                for(List<EmployeeSpecificRequirement__c> myEsrList :myEsrByEmpAndTgtRqmtMap.values() ) {
                    
                    myUpdateEsrList.addAll(myEsrList); 
                }

                myUpdateEsrList.addAll(myDivEsrList); 
                system.debug('--------------Div'+myDivEsrList);
                system.debug('--------------List'+myUpdateEsrList);

                if(myUpdateEsrList.size() > 0) { 
                    errMsg = DmlHelper.updateList(myUpdateEsrList); 
                }
            }
        }
        
        system.debug('HELPER RevSys_TargetHelper processExpandedObs-End'); 
        return errMsg;
    }
    /**
*————————————————————————————————————————————————————
* @Name: applyGenericTargets 
* @Description
* Here, we credit the Supervisor for any Observation. 
* There are specific Targets for which we are looking and they are 
* marked accordingly. We queried them earlier and now it is time 
* for processing. 
*————————————————————————————————————————————————————
* @param    theEmpIdList    Set of ContactIds
* @return   Map<Id,Contact> Map of Contacts by ID 
*————————————————————————————————————————————————————
**/ 
    public static Map<String,List<EmployeeSpecificRequirement__c>>  applyGenericTargets
        (List<ObservationWrapper> theObsWrapList, 
         List<OccupationCertification__c> theApplyToAllTargetList,
         Map<String,List<OccupationSpecificRequirement__c>> theOsrListByTestNumMap, 
         Map<String,List<EmployeeSpecificRequirement__c>>   theEsrByEmpAndTgtRqmtMap)
    {
        system.debug('HELPER RevSys_TargetHelper applyGenericTargets-Start');     
        
        for(ObservationWrapper theObsWrap :theObsWrapList) { 
            
            // We find the Targets which require no Observations because 
            // the Testing Officer gets credit no matter the Observation.  
            for(OccupationCertification__c myAppToAllTarget :theApplyToAllTargetList) { 
                
                String SupervisorMapKey = theObsWrap.Observation.Supervisor__c+'-'+myAppToAllTarget.Id;
                
                List<EmployeeSpecificRequirement__c> myMatchingEsrList 
                    = theEsrByEmpAndTgtRqmtMap.get(SupervisorMapKey); 
                
                if(myMatchingEsrList != null) {
                    
                    List<EmployeeSpecificRequirement__c> myUpdateEsrList 
                        = updateEsr(theObsWrap, myMatchingEsrList); 
                    
                    theEsrByEmpAndTgtRqmtMap.put(SupervisorMapKey,myUpdateEsrList); 
                }
            } 
        }
        
        system.debug('HELPER RevSys_TargetHelper applyGenericTargets-End'); 
        return theEsrByEmpAndTgtRqmtMap;
    }
    /**
*————————————————————————————————————————————————————
* @Name: applySpecificTargets
* @Description
* We now loop through all Observation records coming from the Trigger. 
* For each, we get the OSR records associated with the Observation's Test
* Number. For Each OSR, we see if we have a matching ESR, using the
* Employee ID plus the Target or Requirment Id. Once we have the List of 
* ESR records, we tally in updateEsr().  
*————————————————————————————————————————————————————
* @param    theEmpIdList    Set of ContactIds
* @return   Map<Id,Contact> Map of Contacts by ID 
*————————————————————————————————————————————————————
**/ 
    public static Map<String,List<EmployeeSpecificRequirement__c>> applySpecificTargets
        (List<ObservationWrapper> theObsWrapList, 
         Map<String,List<OccupationSpecificRequirement__c>> theOsrListByTestNumMap, 
         Map<String,List<EmployeeSpecificRequirement__c>>   theEsrByEmpAndTgtRqmtMap) 
    {
        system.debug('HELPER RevSys_TargetHelper applySpecificTargets-Start');  
        system.debug('theOsrListByTestNumMap '   + theOsrListByTestNumMap);
        system.debug('theEsrByEmpAndTgtRqmtMap ' + theEsrByEmpAndTgtRqmtMap);
        
        
        Set<Id> myCertIdSet =  new Set<Id>();
        List<OccupationCertification__c> occTargetList  = new List<OccupationCertification__c>();
        Map<String,String> targetSpeedcheckMap = new Map<String, String>();
        String strArray;
        Boolean sameSpeedCheck= False;
        
         for(List<OccupationSpecificRequirement__c> myOscList :theOsrListByTestNumMap.values()) 
         {
             for(OccupationSpecificRequirement__c osc : myOscList){
                 myCertIdSet.add(osc.Target__c);                             
             }         
         }        
         
        SelectorWrapper wrapper = OccupationCertificationSelector.getTargetsById(myCertIdSet);      
        if(wrapper!=null){
            occTargetList = (List<OccupationCertification__c>)wrapper.SobjectList;
        }
        
           //Get the EC records from the wrapper
            for(OccupationCertification__c ocRecord : occTargetList)
            {   
                strArray = ocRecord.Speed_Check_Method__c;
                targetSpeedcheckMap.put(ocRecord.Id,strArray);           
                                    
            }
 
        system.debug('targetSpeedcheckMap$$'+targetSpeedcheckMap);  
        
        
        system.debug('HELPER RevSys_TargetHelper applySpecificTargets-Start');  
        system.debug('theOsrListByTestNumMap ' + theOsrListByTestNumMap);
        
        for(ObservationWrapper theObsWrap :theObsWrapList) {
            
            Observation__c myObs = theObsWrap.Observation; 
            String myContext = theObsWrap.Context;
            
            
            system.debug('XXXXXXXXXXXXXXXXXXXX'); 
            system.debug('XXXXXXXXXXXXXXXXXXXX'); 
            system.debug('XXXXXXXXXXXXXXXXXXXX'); 
            
            system.debug('myObs ' + myObs); 
            
            // Get the OSR List associated with the Observation Test number 
            
            String testNumberAndTypeKey ;
            String RecordTypeName = Schema.SObjectType.Observation__c.getRecordTypeInfosById().get(myObs.RecordTypeId).getName(); 
            
            if(RecordTypeName==System.Label.RevSys_Observation_RT_Label_Test_1872) {
                // cw 2/21 testNumberAndTypeKey = myObs.TestNumber__c+'-'+RecordTypeName.toUpperCase();
                testNumberAndTypeKey = myObs.TestNumber__c;
            }
            else {
                testNumberAndTypeKey = RecordTypeName.toUpperCase();
            }
            
            List<OccupationSpecificRequirement__c> myOSRList 
                = theOsrListByTestNumMap.get(testNumberAndTypeKey); 
            
            if(myOSRList != null) {
                
                //**********************************************************
                // Roll through all OSR records 
                //**********************************************************
                
                //for(OccupationSpecificRequirement__c eachOSR : myOsrListByTestNumMap.get(testNumberAndTypeKey))
                
                for(OccupationSpecificRequirement__c eachOSR : myOSRList)
                {
                    // cw String mapKey = updatedObs.Employee__c+'-'+eachOSR.Target__c;
                    //String mapKey = updatedObs.Employee__c+'-'+eachOSR.TargetRequirement__c;
                    
                    // Process Employee 
                    // For each record make a mashkey of either 
                    // - The Employee + Target 
                    // - The Employee + Target Requirement 
                    String mapKey; 
                    
                    if(eachOSR.Target__c != null) {  
                        mapKey = theObsWrap.Observation.Employee__c+'-'+eachOSR.Target__c;
                    }
                    else { 
                        mapKey = theObsWrap.Observation.Employee__c+'-'+eachOSR.TargetRequirement__c;
                    }
                    
                    
                    
                    system.debug('2018-06-03_DEBUG: SourceRecordType__c ' + eachOSR.SourceRecordType__c); 
                    system.debug('2018-06-03_DEBUG: Target__c '      + eachOSR.Target__c); 
                    system.debug('2018-06-03_DEBUG: Test_Number__c ' + eachOSR.Test_Number__c); 
                    system.debug('2018-06-03_DEBUG: TestName__c '    + eachOSR.TestName__c); 
                    
                    
                    //Does the Target__ has the same speed check Method
                    String targetSpeedCheck  = targetSpeedcheckMap.get(eachOSR.Target__c);
                    
                
                    if(String.isNotBlank(targetSpeedCheck))
                    {
                        if(String.isNotBlank(myObs.SpeedCheckMethod__c)) {
                            List<String> targets = targetSpeedCheck.toUpperCase().split(';');
                            if(targets.contains((myObs.SpeedCheckMethod__c).toUpperCase()))
                            {
                                sameSpeedCheck = true;
                            } else {
                                sameSpeedCheck = false;
                            }
                        } else  {
                            sameSpeedCheck = false;
                        }
                    } 
                    else{
                      	sameSpeedCheck = true;  
                    }
                    
                    
                    
                    system.debug('sameSpeedCheck ' + sameSpeedCheck); 
                    
                    
                    
                    
                    
                    // Does this OSR have a matching ESR List?                     
                    
                    List<EmployeeSpecificRequirement__c> myMatchingEsrList 
                        = theEsrByEmpAndTgtRqmtMap.get(mapKey);
                        
                    system.debug('myMatchingEsrList ' + myMatchingEsrList); 
                    
                    if(myMatchingEsrList != null && sameSpeedCheck) {
                        
                        List<EmployeeSpecificRequirement__c> myUpdateEsrList 
                            = updateEsr(theObsWrap, myMatchingEsrList); 
                        
                        theEsrByEmpAndTgtRqmtMap.put(mapKey,myUpdateEsrList); 
                    }
                    
                    // Process Supervisor 
                    
                    if(theObsWrap.Observation.Supervisor__c != null) {  
                        mapKey = theObsWrap.Observation.Supervisor__c+'-'+eachOSR.Target__c;
                        // Does this OSR have a matching ESR List? 
                        
                        List<EmployeeSpecificRequirement__c> myMatchingEsrList2 
                            = theEsrByEmpAndTgtRqmtMap.get(mapKey); 
                        
                        if(myMatchingEsrList2 != null) {
                            
                            List<EmployeeSpecificRequirement__c> myUpdateEsrList2 
                                = updateEsr(theObsWrap, myMatchingEsrList2); 
                            
                            theEsrByEmpAndTgtRqmtMap.put(mapKey,myUpdateEsrList2); 
                        }
                    }
                }
            }
        }
        
        system.debug('theEsrByEmpAndTgtRqmtMap ' + theEsrByEmpAndTgtRqmtMap); 
        
        system.debug('HELPER RevSys_TargetHelper applySpecificTargets-End'); 
        return theEsrByEmpAndTgtRqmtMap;
    }
    
    /**
*————————————————————————————————————————————————————
* @Name: applyDivisionTargets 
* @Description
* Divisional Targets are different, given they are not applied to an 
* Employee. They are applied to the Division. Therefore, we don't process
* them in the same manner as the Generic and Specific targets. 
*
* In this case, we have to obtain those ESRs associated with a Division. We
* map them and process. 
*————————————————————————————————————————————————————
* @param    theEmpIdList    Set of ContactIds
* @return   Map<Id,Contact> Map of Contacts by ID 
*————————————————————————————————————————————————————
**/ 
    public static List<EmployeeSpecificRequirement__c> applyDivisionTargets
        (List<ObservationWrapper> theObsWrapList, 
         Map<Id,Contact>          theContactMap)
    {
        system.debug('HELPER RevSys_TargetHelper applyDivisionTargets-Start');   
        system.debug('theObsWrapList  ' + theObsWrapList);    
        system.debug('theContactMap  ' + theContactMap);      
        
        List<ObservationWrapper> theForeignObsWrapList = new List<ObservationWrapper>(); 
        
        // Roll through the list of Observation Wrappers
        // Collect only those associated with External employees 
        for(ObservationWrapper theObsWrap :theObsWrapList) { 
            Contact myEmp = theContactMap.get(theObsWrap.Observation.Employee__c); 
            if(myEmp != null && myEmp.RecordTypeId != null) {
                if(myEmp.RecordTypeId  == Revsys_StaticUtility.CONTACT_FOREIGNRREMPLOYEE_RECTYPE_ID) { 
                    theForeignObsWrapList.add(theObsWrap); 
                }
            }
        }

        system.debug('theForeignObsWrapList  ' + theForeignObsWrapList);    
        
        Map<String,List<EmployeeSpecificRequirement__c>> myEsrListByDivMap 
            = new Map<String,List<EmployeeSpecificRequirement__c>>();
        
        List<EmployeeSpecificRequirement__c> myUpdateEsrList 
            = new List<EmployeeSpecificRequirement__c>();  
        
        if(theForeignObsWrapList.size() > 0) { 
            
            // Get ESRs associated with Divisions instead of Employees 
            SelectorWrapper mySelWrap 
                = EmployeeSpecificRequirementSelector.getDivisionEsr();
            
            String errMsg = mySelWrap.ErrorMessage; 
            List<EmployeeSpecificRequirement__c> mySelEsrList = mySelWrap.SObjectList; 
            
            system.debug('mySelEsrList  ' + mySelEsrList);   

            if(errMsg == null && mySelEsrList.size() > 0) {
                for(EmployeeSpecificRequirement__c mySelEsr :mySelEsrList) {
                    
                    // Map the ESRs by Division 
                    List<EmployeeSpecificRequirement__c> myDivEsrList 
                        = myEsrListByDivMap.get(mySelEsr.DivisionOfObservation__c); 
                    
                    if(myDivEsrList == null) {
                        myDivEsrList = new List<EmployeeSpecificRequirement__c>(); 
                    }
                    myDivEsrList.add(mySelEsr);
                    
                    myEsrListByDivMap.put(mySelEsr.DivisionOfObservation__c,myDivEsrList); 
                }

                system.debug('myEsrListByDivMap  ' + myEsrListByDivMap);
                
                // Now, we have ESRs mapped by Division roll through the Observations
                // associated with External Employees. 
                
                for(ObservationWrapper theObsWrap :theForeignObsWrapList) {
                    
                    system.debug('*** theObsWrap.Observation.RegionProperty__c)  ' + theObsWrap.Observation.RegionProperty__c);

                    List<EmployeeSpecificRequirement__c> myEsrList 
                        = myEsrListByDivMap.get(theObsWrap.Observation.RegionProperty__c); 
                    
                    system.debug('*** myEsrList  ' + myEsrList);

                    if(myEsrList != null ) {
                        
                        myEsrList = updateEsr(theObsWrap, myEsrList); 
                        
                        myEsrListByDivMap.put(theObsWrap.Observation.RegionProperty__c, myEsrList); 
                    }
                }
            }

            system.debug('*** myEsrListByDivMap  ' + myEsrListByDivMap);

            // unload map into list 
            
            for(List<EmployeeSpecificRequirement__c> myEsrList :myEsrListByDivMap.values() ) 
            {
                myUpdateEsrList.addAll(myEsrList);
            }
        }

        system.debug('*** myUpdateEsrList  ' + myUpdateEsrList);
        
        system.debug('HELPER RevSys_TargetHelper applyDivisionTargets-End'); 
        return myUpdateEsrList;
    }
    
    /**
*————————————————————————————————————————————————————
* @Name: updateEsr 
* @Description
* We're getting an Observation and list of ESRs We roll through the 
* list of ERSs and determine if they are a Target or a Requirement. 
*————————————————————————————————————————————————————
* @param    theEmpIdList    Set of ContactIds
* @return   Map<Id,Contact> Map of Contacts by ID 
*————————————————————————————————————————————————————
**/ 
    public static List<EmployeeSpecificRequirement__c> updateEsr(ObservationWrapper theObsWrap, 
                                                                 List<EmployeeSpecificRequirement__c> theEsrList)
    {
        //system.debug('HELPER RevSys_TargetHelper updateEsr-Start');     
        
        List<EmployeeSpecificRequirement__c> myUpdateList = new List<EmployeeSpecificRequirement__c>(); 
        
        for(EmployeeSpecificRequirement__c esr : theEsrList) {
            if(esr.TotalAchieved__c==null) {
                esr.TotalAchieved__c=0;
            }
            
            if(esr.RecordTypeId == Revsys_StaticUtility.EMPSPECREQUIREMENT_SPARTNTARGET_RECTYPE_ID) {
                
                esr = processEsrTarget(theObsWrap, esr); 
            }
            else { 
                esr = processEsrRequirement(theObsWrap, esr); 
            }
            
            myUpdateList.add(esr);
        }       
        
        //system.debug('HELPER RevSys_TargetHelper updateEsr-End'); 
        return myUpdateList;
    }
    /**
*————————————————————————————————————————————————————
* @Name: processEsrTarget
* @Description
* We know we are procesing against a Target We want to ensure we are 
* within the proper date range and also, we want to know the context of
* the "transaction." 
*————————————————————————————————————————————————————
* @param    theEmpIdList    Set of ContactIds
* @return   Map<Id,Contact> Map of Contacts by ID 
*————————————————————————————————————————————————————
**/ 
    public static EmployeeSpecificRequirement__c processEsrTarget(ObservationWrapper theObsWrap, 
                                                                  EmployeeSpecificRequirement__c theEsr)
    {
        //system.debug('HELPER RevSys_TargetHelper processEsrTarget-Start');   
        system.debug('processEsrTarget-Start TotalAchieved');
        if(theObsWrap.Observation.EvaluationDateTime__c.Date()>=theEsr.StartDate__c && 
           theObsWrap.Observation.EvaluationDateTime__c.Date()<=theEsr.EndDate__c) 
        {
            if(theObsWRap.Context == Label.Revsys_Constant_Add) { 
                theEsr.TotalAchieved__c++;
            }
            else if(theEsr.TotalAchieved__c != 0){
                theEsr.TotalAchieved__c--;
            }
        }
        
        //system.debug('HELPER RevSys_TargetHelper processEsrTarget-End'); 
        return theEsr;
    }
    
    /**
*————————————————————————————————————————————————————
* @Name: processEsrRequirement
* @Description
* We know this is a Requirement. For this, we update the ESR and tell it 
* the current transaction date. 
* 
*————————————————————————————————————————————————————
* @param    theEmpIdList    Set of ContactIds
* @return   Map<Id,Contact> Map of Contacts by ID 
*————————————————————————————————————————————————————
**/ 
    public static EmployeeSpecificRequirement__c processEsrRequirement(ObservationWrapper theObsWrap, 
                                                                       EmployeeSpecificRequirement__c theEsr)
    {
        //system.debug('HELPER RevSys_TargetHelper processEsrRequirement-Start');   

        if(theObsWrap.Context == Label.Revsys_Constant_Add) { 
            theEsr.LastFulfilledDate__c = Date.today(); 
            if(theObsWrap.Observation.RecordTypeId == RevSys_StaticUtility.OBSERVATION_TEST1872_RECTYPE_ID)
            {
                if(theObsWrap.Observation.Result__c == Label.Revsys_1872_Result_Compliant || theObsWrap.Observation.Result__c ==  Label.RevSys_Pass ) { 
                    theEsr.ReportStatus__c = Label.RevSys_Pass;
                } 
                else {
                    theEsr.ReportStatus__c = Label.RevSys_Generic_Fail;
                }
            }
        }
        else {
            
            //theEsr.LastFulfilledDate__c = null;
            theEsr.ReportStatus__c = Label.RevSys_Generic_Pending; 
            
        }
        
        //system.debug('HELPER RevSys_TargetHelper processEsrRequirement-End'); 
        return theEsr;
    }
    /**
*————————————————————————————————————————————————————
* @Name: deriveTargetsAndRequirements 
* @Description
* We obtain all OSR records associated with the Observation record types and 
* Observation test numbers. We create a map of OSRs by Test Numbers 
* 
*————————————————————————————————————————————————————
* @param    theEmpIdList    Set of ContactIds
* @return   Map<Id,Contact> Map of Contacts by ID 
*————————————————————————————————————————————————————
**/ 
    public static OsrListByTestNumMapWrapper deriveTargetsAndRequirements(List<ObservationWrapper> theObsWrapList)
    {
        system.debug('HELPER RevSys_TargetHelper deriveTargetsAndRequirements-Start');    
        
        
        String      errMsg; 
        string      testNumberAndTypeKey;
        Set<String> myTestNumberSet     = new Set<String>(); 
        Set<String> myRecordTypeNameSet = new Set<String>(); 
        
        Map<String,List<OccupationSpecificRequirement__c>> myOsrListByTestNumMap 
            = new Map<String,List<OccupationSpecificRequirement__c>>();
        
        OsrListByTestNumMapWrapper myOsrListMap 
            = new OsrListByTestNumMapWrapper(null, null); 
        
        //**********************************************************************
        // Get a set of:
        //    Test Numbers tied to the Observations 
        //    Record Type Names associated to the Observations 
        //**********************************************************************
        for(ObservationWrapper theObsWrap :theObsWrapList) { 
            
            
            
            String myContext = theObsWrap.Context; 
            Observation__c myObs = theObsWrap.Observation; 
            
            if(myObs.TestNumber__c!=null) {
                myTestNumberSet.add(myObs.TestNumber__c);
                
            }
            
            String myRecordTypeName = Schema.SObjectType.Observation__c.getRecordTypeInfosById().get(myObs.RecordTypeId).getName(); 
            myRecordTypeNameSet.add(myRecordTypeName.toUpperCase());
            
        }
        
        system.debug('myRecordTypeNameSet  ' + myRecordTypeNameSet);   
        
        SelectorWrapper OSRwrapper = new SelectorWrapper('No Occupation Specific Requirements were found', null);
        
        if(!myTestNumberSet.isEmpty() && !myRecordTypeNameSet.isEmpty() ) { 
            
            // Get a list of Target-Observations by Test Number
            OSRwrapper 
                = OccupationSpecificRequirementSelector.getOccSpecificRequirementsFrmTestNum(myTestNumberSet,myRecordTypeNameSet);
            
            errMsg = OSRwrapper.ErrorMessage;
            
            system.debug('OSRwrapper  ' + OSRwrapper);   
            
            
            List<OccupationSpecificRequirement__c> myOsrList = OSRwrapper.SObjectList; 
            
            if(errMsg == null && myOsrList.size() > 0) {
                
                // For each Target-Observation (OSR) 
                for(OccupationSpecificRequirement__c myOsr :myOsrList)
                {
                    system.debug('myOsr  ' + myOsr);   
                    
                    // Add the Target and Requirement to their respective sets  
                    TargetIdSet.add(myOsr.Target__c);
                    RequirementIdSet.add(myOsr.TargetRequirement__c);

                    
                    // If this is an 1872, add the test number and record type to the testNumberAndTypeKey
                    // Othewise, just add the record type to the testNumberAndTypeKey 
                    
                    system.debug('myOsr.Target__r.SourceRecordType__c  ' + myOsr.Target__r.SourceRecordType__c);   
                    system.debug('System.Label.RevSys_Observation_RT_Label_Test_1872.toUpperCase()  ' + System.Label.RevSys_Observation_RT_Label_Test_1872.toUpperCase());   
                    
                    if(myOsr.Target__r.SourceRecordType__c==System.Label.RevSys_Observation_RT_Label_Test_1872.toUpperCase()) {  
                        // cw 2/21 testNumberAndTypeKey = osrRec.Test_Number__c+'-'+osrRec.Observation__r.SourceRecordType__c;
                        testNumberAndTypeKey = myOsr.Test_Number__c;
                        system.debug('STEP 1'); 
                    }
                    else {
                        testNumberAndTypeKey = myOsr.Target__r.SourceRecordType__c;
                        system.debug('STEP 2'); 
                    }

                    //testNumberAndTypeKey is populated with Test Number when there is a target requirement for the OSR
                    if(myOsr.TargetRequirement__c!=null){
                        testNumberAndTypeKey = myOsr.Test_Number__c;
                        system.debug('STEP 3'); 
                    }
                    // Load myOsrListByTestNumMap
                    
                    if(!myOsrListByTestNumMap.containsKey(testNumberAndTypeKey)) {
                        myOsrListByTestNumMap.put(testNumberAndTypeKey, new List<OccupationSpecificRequirement__c>());
                        system.debug('STEP 4'); 
                    }
                    
                    myOsrListByTestNumMap.get(testNumberAndTypeKey).add(myOsr);
                }
            }
            
            myOsrListMap 
                = new OsrListByTestNumMapWrapper(errMsg, myOsrListByTestNumMap); 
        }
        
        system.debug('myOsrListMap  ' + myOsrListMap);   
        
        system.debug('HELPER RevSys_TargetHelper deriveTargetsAndRequirements-End'); 
        return myOsrListMap;
    }
    /**
*————————————————————————————————————————————————————
* @Name: mapEsrRecords
* @Description
* With our accumulated Employee, Target and TargetRequirement IDs, we 
* obtain all related ESR records and map them by Employee Id and either 
* Target or Requirement 
*————————————————————————————————————————————————————
* @param    theEmpIdList    Set of ContactIds
* @return   Map<Id,Contact> Map of Contacts by ID 
*————————————————————————————————————————————————————
**/ 
    public static EsrByEmpAndTgtRqmtMapWrapper mapEsrRecords()
    {
        system.debug('HELPER RevSys_TargetHelper mapEsrRecords-Start'); 
        
        Map<String,List<EmployeeSpecificRequirement__c>> myEsrByEmpAndTgtRqmtMap 
            = new Map<String,List<EmployeeSpecificRequirement__c>>();
        
        SelectorWrapper ESRwrapper 
            = EmployeeSpecificRequirementSelector.getEmpSpecReqFrmEmpAndTargetOrReq(TargetIdSet, 
                                                                                    RequirementIdSet,
                                                                                    EmployeeIdSet);
        
        String errMsg = ESRwrapper.ErrorMessage; 
        List<EmployeeSpecificRequirement__c> myEsrList = ESRwrapper.SObjectList; 
        
        if(errMsg == null) {
            
            for(EmployeeSpecificRequirement__c esrRec :myEsrList) {
                if(esrRec.Employee__c!=null && (esrRec.Target__c!=null || esrRec.Requirement__c!=null)) {
                    
                    String key; 
                    
                    // Determine if this is for a Target or a Requirement 
                    if(esrRec.Target__c != null) {  
                        key = esrRec.Employee__c+'-'+esrRec.Target__c;
                    }
                    else { 
                        key = esrRec.Employee__c+'-'+esrRec.Requirement__c;
                    }
                    
                    // Add to the Map
                    if(myEsrByEmpAndTgtRqmtMap.containsKey(key)) {
                        myEsrByEmpAndTgtRqmtMap.get(key).add(esrRec);
                        
                    } else {
                        myEsrByEmpAndTgtRqmtMap.put(key,new List<EmployeeSpecificRequirement__c> {esrRec});
                        
                    }
                }
            }
        }
        // put the wrapper class together 
        EsrByEmpAndTgtRqmtMapWrapper myMapWrap 
            = new EsrByEmpAndTgtRqmtMapWrapper(errMsg, myEsrByEmpAndTgtRqmtMap); 
        
        system.debug('HELPER RevSys_TargetHelper mapEsrRecords-End'); 
        return myMapWrap;
    }
    
    /**
*————————————————————————————————————————————————————
* @Name: mapContacts
* @Description
* With the Observations, accumulate the Employee and Supervisor Ids. 
* Using that set, query the Contact object and map each Contact for 
* later use.  
*————————————————————————————————————————————————————
* @param    theEmpIdList    Set of ContactIds
* @return   Map<Id,Contact> Map of Contacts by ID 
*————————————————————————————————————————————————————
**/ 
    public static ContactMapWrapper mapContacts(List<Observation__c> theNewObsList)
    {
        system.debug('HELPER RevSys_TargetHelper mapContacts-Start');     
        
        for(Observation__c theNewObs :theNewObsList) { 
            
            if(theNewObs.Employee__c != null)   {
                EmployeeIdSet.add(theNewObs.Employee__c); 
            }
            if(theNewObs.Supervisor__c != null) {
                EmployeeIdSet.add(theNewObs.Supervisor__c); 
            }
        }
        
        Map<Id,Contact> myEmpMap = new Map<Id,Contact>();
        
        SelectorWrapper myEmpWrapper = ContactSelector.getContactsById(EmployeeIdSet);
        
        String errMsg = myEmpWrapper.ErrorMessage; 
        List<Contact> myEmpList = myEmpWrapper.SObjectList;
        
        if(errMsg == null && myEmplist.size() > 0) {
            for(Contact myEmp :myEmpList) { 
                myEmpMap.put(myEmp.Id, myEmp); 
            } 
        }
        
        ContactMapWrapper myWrap = new ContactMapWrapper(errMsg,myEmpMap); 
        
        system.debug('HELPER RevSys_TargetHelper mapContacts-End'); 
        return myWrap;
    }
    
    /**
*————————————————————————————————————————————————————
* @Name: getSupervisorGenericTargets
* @Description
* Query those Targets which are applied to any Observation per Supervisor. 
* Additionally, add the Target Id to the TargetIdSet.  
*————————————————————————————————————————————————————
* @param    theEmpIdList    Set of ContactIds
* @return   Map<Id,Contact> Map of Contacts by ID 
*————————————————————————————————————————————————————
**/ 
    public static SelectorWrapper getSupervisorGenericTargets()
    {
        system.debug('HELPER RevSys_TargetHelper getSupervisorGenericTargets-Start');     
        
        SelectorWrapper myOccCertWrapper
            = OccupationCertificationSelector.getAppliesToAllObsTargets();
        
        String errMsg = myOccCertWrapper.ErrorMessage; 
        
        if(errMsg == null) {
            
            List<OccupationCertification__c> myAppliesToAllTargetList = myOccCertWrapper.SObjectList; 
            
            for(OccupationCertification__c myAppToAllTarget :myAppliesToAllTargetList) { 
                TargetIdSet.add(myAppToAllTarget.Id); 
            }
        }
        
        system.debug('HELPER RevSys_TargetHelper getSupervisorGenericTargets-End'); 
        return myOccCertWrapper;
    }
    
    /**
*————————————————————————————————————————————————————
* @Name: processExpandedNon1872Obs
* @Description
* Query the ESRs related to the Employee and Supervisor  
*————————————————————————————————————————————————————
* @param    myObsWrapList    List of Observation Wrapper
			myContactsMap	 Map of Contacts by Id
* @return   String			 error message 
*————————————————————————————————————————————————————
**/ 
    public static String processExpandedNon1872Obs(List<ObservationWrapper> myObsWrapList, Map<Id, Contact> myContactsMap )
    {
        system.debug('HELPER RevSys_TargetHelper processExpandedNon1872Obs-Start');    
        String errMsg;
        Map<Id, List<EmployeeSpecificRequirement__c>> esrByEmployeeId = new Map<Id, List<EmployeeSpecificRequirement__c>>();
        
        List<EmployeeSpecificRequirement__c> empEsrList;
        List<EmployeeSpecificRequirement__c> supvEsrList;
        List<EmployeeSpecificRequirement__c> updateList = new List<EmployeeSpecificRequirement__c>();
        
        //Fetch the related ESRs of employee and supervisor
        SelectorWrapper myWrapper = EmployeeSpecificRequirementSelector.getEmployeeSpecificRequirements(myContactsMap.KeySet());
        
        if(myWrapper != null){
            
            List<EmployeeSpecificRequirement__c> esrList = (List<EmployeeSpecificRequirement__c>)myWrapper.SObjectList;
            
            for(EmployeeSpecificRequirement__c esr : esrList){
                
                if(esrByEmployeeId.containsKey(esr.Employee__c)){
                    
                    esrByEmployeeId.get(esr.Employee__c).add(esr);
                }
                else{
                    
                    esrByEmployeeId.put(esr.Employee__c, new List<EmployeeSpecificRequirement__c>{esr});
                }
            }
        }
        
        for(ObservationWrapper myObsWrap : myObsWrapList){
            empEsrList = new List<EmployeeSpecificRequirement__c>();
            supvEsrList = new List<EmployeeSpecificRequirement__c>();
            
            
            if(esrByEmployeeId.containsKey(myObsWrap.Observation.Employee__c)){
                
                empEsrList = processNon1872Targets(myObsWrap, esrByEmployeeId.get(myObsWrap.Observation.Employee__c));
            }
            
            if(esrByEmployeeId.containsKey(myObsWrap.Observation.Supervisor__c)){
                
                supvEsrList = processNon1872Targets(myObsWrap, esrByEmployeeId.get(myObsWrap.Observation.Supervisor__c));
            }
            updateList.addAll(empEsrList);
            updateList.addAll(supvEsrList);
        }
     
        if(updateList.size() > 0){
            
            errMsg = DmlHelper.updateList(updateList);
        }
        system.debug('HELPER RevSys_TargetHelper processExpandedNon1872Obs-End'); 
        return errMsg;
    }
    
    /**
*————————————————————————————————————————————————————
* @Name: processNon1872Targets
* @Description
* Query the ESRs related to the Employee and Supervisor  
*————————————————————————————————————————————————————
* @param    myObsWrapList    List of Observation Wrapper
			myContactsMap	 Map of Contacts by Id
* @return   String			 error message 
*————————————————————————————————————————————————————
**/ 
    public static List<EmployeeSpecificRequirement__c> processNon1872Targets(ObservationWrapper myObsWrap, List<EmployeeSpecificRequirement__c> esrList)
    {
        system.debug('HELPER RevSys_TargetHelper processExpandedNon1872Obs-Start');    
        String errMsg;
       
        List<EmployeeSpecificRequirement__c> myUpdateList = new List<EmployeeSpecificRequirement__c>();
        
        String RecordTypeName = Schema.SObjectType.Observation__c.getRecordTypeInfosById().get(myObsWrap.Observation.RecordTypeId).getName(); 
           
        
        //Loop through the OSRs
        for(EmployeeSpecificRequirement__c esr : esrList){
            if(esr.TotalAchieved__c == null){
                esr.TotalAchieved__c = 0;
            }
            
            
            if(esr.RecordTypeId == Revsys_StaticUtility.EMPSPECREQUIREMENT_SPARTNTARGET_RECTYPE_ID &&
              esr.Target__r.SourceRecordType__c == RecordTypeName.toUpperCase()){
                
                esr = processEsrTarget(myObsWrap, esr);
            }
            
            myUpdateList.add(esr);
        }
     
        system.debug('HELPER RevSys_TargetHelper processExpandedNon1872Obs-End'); 
        return myUpdateList;
    }
}
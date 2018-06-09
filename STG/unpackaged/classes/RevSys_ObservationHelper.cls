/**
*___________________________________________________
*@Name: RevSys_ObservationHelper
*@Author: Chuck Walley
*@Created: Date: 11/4/2017
*@Used_By: Review Systems
*___________________________________________________
*@Description: Creates Questions for Review Systems Operational Test 
* Holds generic helper methods for the Observation object relevent to the Review Systems application
* 
*___________________________________________________
*@Changes: 
* 12-13-2017 [Boom Bertetti] Updated updateTime method to set EvaluationDateTime based on 
*                            Date__c, TimeHH__c and TimeMM__c
* 12-21-2017 [Sudhindra Katti] Updated generateSupervisorContactMap method to set default Supervisor or 
* current user from contact
* 1-18-2018 [Hemanth Kesapragada] Added  getEmployeeSupervisor to update Employee's supervisor on observation
* 1-1-2018 [Sudhindra Katti] added updateEmployeeHierarchywithtestdate to update employee Hierarchy with last test taken
* 5-29-2018 [Boom Bertetti] Added updateEmployeeCertification method
* 6-4-2018 [Boom Bertetti] Added null checker in processFRALogic to prevent error when contact has no Hierarchy Assignment
* 6-4-2018 [walley] ETR-1286 - Code Review Remediation
* 6-6-18 [Boom Bertetti] ETR-1293 updated getEmployeeSupervisorContactInfo to use reference fields from SPARTN_Manager__c instead EPW_Contact__c
**/
global with sharing class RevSys_ObservationHelper {
    
 // Variable to identify whether the observation trigger is invoked. 
 // Used in EmployeeHierarchy
 public static boolean varObservationInvoked=false;    
    /**
*————————————————————————————————————————————————————
* @Name: applyDefaultInfo
* @Description
* Culls Observation records to retain only those needed a set of questions, 
* then calls genQuestions to proceed with the process. 
*————————————————————————————————————————————————————
* @param    theNewObsList   List of Observation records, generally from the trigger
* @return   void            Nothing
*————————————————————————————————————————————————————
**/ 
    public static void applyDefaultInfo(List<Observation__c> theNewObsList)
    {
        system.debug('HELPER RevSys_ObservationHelper applyDefaultInfo-Start');     
        
        string   errMsg; 
        System.debug('*** theNewObsList : ' + JSON.serialize(theNewObsList));
        Map<Id, Contact> employeesMap = generateContactMap(theNewObsList); 
        
        if(employeesMap.size() > 0) {
            
            for(Observation__c myRevSysObs :theNewObsList) {
                
                myRevSysObs.SPARTN_ShowPopup__c = True; //@ Pratik:- Added as a parrt of ETR14 form 1872
                
                if (employeesMap.containsKey(myRevSysObs.Employee__c)) {
                    Contact employee = employeesMap.get(myRevSysObs.Employee__c);
                    myRevSysObs.Region__c     = employee.Region__c;    
                    myRevSysObs.Division__c   = employee.Division__c;                
                    myRevSysObs.Department__c = employee.Department; 
                    myRevSysObs.Craft__c      = employee.Craft__c;  
                    myRevSysObs.CrewBase__c   = employee.CrewBase2__c;
                    myRevSysObs.Occupation__c = employee.Occupation__c;
                    myRevSysObs.Employee_PersonnelAreaText__c = employee.Personnel_Area_Text__c;                                                            
                    myRevSysObs.Employee_CostCenter__c    = employee.Cost_Center__c;
                    myRevSysObs.Employee_OrgUnitNumber__c = employee.Org_Unit_Number__c;
                }
            }
        }  
        
        system.debug('HELPER RevSys_ObservationHelper applyDefaultInfo-End');     
        return; 
        
    }
    
    /**
*————————————————————————————————————————————————————
* @Name: updateTime
* @Description
* Set default EvaluationDateTime to now if there is no value in 
* Date__c, TimeHH__c and TimeMM__c
* Update EvaluationDateTime and  Time__c on Observation when 
* Date__c, TimeHH__c and/or TimeMM__c is changed
*————————————————————————————————————————————————————
* @param    theNewObsList   List of Observation records, generally from the trigger
* @param    theOldMap       Map of SObject records, generally from the trigger
* @return   void            Nothing
*————————————————————————————————————————————————————
**/ 
    
    public static void updateTime(List<Observation__c> theNewObsList, Map<Id, SObject> theOldMap)
    {
        system.debug('HELPER RevSys_ObservationHelper updateTime-Start');     
        
        for(Observation__c myRevSysObs :theNewObsList) {
            
            Date myDate = System.today();
            DateTime myNow    = System.DateTime.now();
            Integer  myHour   = myNow.hour(); 
            Integer  myMinute = myNow.minute(); 
            
            if (myRevSysObs.Date__c != null) {
                myDate = myRevSysObs.Date__c;
            }
            else {
                myRevSysObs.Date__c = myDate;
            }
            
            if (myRevSysObs.TimeHH__c != null && myRevSysObs.TimeHH__c !='--') {
                myHour = Integer.ValueOf(myRevSysObs.TimeHH__c); 
            }
            else {
               // myRevSysObs.TimeHH__c = String.valueOf(myHour).length() == 2 ? String.valueOf(myHour) : '0' + String.valueOf(myHour);
            }
            
            if (myRevSysObs.TimeMM__c != null && myRevSysObs.TimeMM__c !='--') {
                myMinute = Integer.ValueOf(myRevSysObs.TimeMM__c);
            }
            else {
               // myRevSysObs.TimeMM__c = String.valueOf(myMinute).length() == 2 ? String.valueOf(myMinute) : '0' + String.valueOf(myMinute);                
            }
            
            if (theOldMap == null) {
                myRevSysObs.Time__c = Time.newInstance(myHour, myMinute, 0, 0); 
                myRevSysObs.EvaluationDateTime__c = DateTime.newInstance(myDate, myRevSysObs.Time__c);
            }
            else {
                Observation__c oldObs = (Observation__c)theOldMap.get(myRevSysObs.Id);
                
                if (oldObs != null && 
                    (myRevSysObs.TimeHH__c != oldObs.TimeHH__c || 
                     myRevSysObs.TimeMM__c != oldObs.TimeMM__c ||
                     myRevSysObs.Date__c != oldObs.Date__c)) {
                         myRevSysObs.Time__c = Time.newInstance(myHour, myMinute, 0, 0); 
                         myRevSysObs.EvaluationDateTime__c = DateTime.newInstance(myDate, myRevSysObs.Time__c);
                     }
            }
        }  
        
        system.debug('HELPER RevSys_ObservationHelper updateTime-End');     
        return; 
        
    }
    
    /**
*————————————————————————————————————————————————————
* @Name: generateContactMap
* @Description
* Generates a map of contacts from the Employee Ids in the Review System Observation Records
*————————————————————————————————————————————————————
* @param    theNewObsList   List of Observation records, generally from the trigger
* @return   Map<Id, Contact> A map of contacts indexed by Id 
*————————————————————————————————————————————————————
**/
    public static Map<Id, Contact> generateContactMap(List<Observation__c> theRevSysObsList)
    {
        system.debug('HELPER RevSys_ObservationHelper generateContactMap-Start');     
        
        Set<Id> contactIdsSet        = new Set<Id>();
        System.debug('*** theRevSysObsList : ' + JSON.serialize(theRevSysObsList));
        for(Observation__c theNewObs :theRevSysObsList) {
            
            if(theNewObs.Employee__c != null) {
                contactIdsSet.add(theNewObs.Employee__c);
            } 
        }
        
        Map<Id, Contact> contactsMap = new Map<Id, Contact>();
        
        
        List<Contact> contactList = new List<Contact>();
        SelectorWrapper wrapper = ContactSelector.getContacts(contactIdsSet);
        if(wrapper!=null) {
            contactList = (List<Contact>)wrapper.sObjectList;
            for(Contact con : contactList) {
                contactsMap.put(con.Id, con);
            }
        }
        
        
        system.debug('HELPER RevSys_ObservationHelper generateContactMap-End');     
        return contactsMap;  
    }
    
    
    
    
    /**
*————————————————————————————————————————————————————
* @Name: changeStatusToSubmitted
* @Description
* determines which records are now submitted and send on for 
* further processing 
*————————————————————————————————————————————————————
* @param    theNewObsList   List of Observation records
* @return   Nothing         Called before insert/Update 
*————————————————————————————————————————————————————
**/
    public static String changeStatusToSubmitted(List<Observation__c> theNewObsList, Map<Id, SObject> theOldMap){
        
        system.debug('HELPER RevSys_ObservationHelper changeStatusToSubmitted-Start');
        
        String errMsg; 
        
        List<Observation__c> mySubmittedObsList = new List<Observation__c>(); 
        
        for(Observation__c theNewobs : theNewObsList){
            
            if(theOldMap == null) {
                if(theNewobs.Status__c == Label.RevSys_Observation_Status_Complete){

                    mySubmittedObsList.add(theNewObs); 

                }

            }
            else {
                Observation__c obsOld = (Observation__c)theOldMap.get(theNewobs.Id);
                
                if(theNewobs.Status__c == Label.RevSys_Observation_Status_Complete){
                    
                //    if(obsOld.SubmissionDateTime__c == null){ [BB 3/14/18]
                        
                        mySubmittedObsList.add(theNewObs); 
                //    }
                }
            }

        }
        
        if(mySubmittedObsList.size() > 0) {
            errMsg = processSubmitted(mySubmittedObsList); 
        }
        
        system.debug('HELPER RevSys_ObservationHelper changeStatusToSubmitted-End');
        
        return errMsg;
    }
    
    /**
*————————————————————————————————————————————————————
* @Name: processSubmitted
* @Description
* Applies the current date and time to SubmissionDateTime__c
* Applies the Test Number and Name to the Observation text fields for future
* processing in an effort to cut down on Observation formula fields
*————————————————————————————————————————————————————
* @param    theNewObsList   List of Observation records, generally from the trigger
* @return   Map<Id, Contact> A map of contacts indexed by Id 
*————————————————————————————————————————————————————
**/
    public static String processSubmitted(List<Observation__c> theObsList)
    {
        system.debug('HELPER RevSys_ObservationHelper generateSupervisorContactMap-End');    
        
        String errMsg; 
        Set<Id> myObSpecReqIdSet = new Set<Id>(); 
        
        // First loop through Obs list to set submission date/time 
        // & add the OccupationSpecificRequirement Id to a set 
        for(Observation__c theObs :theObsList) {
            
            theObs.SubmissionDateTime__c = theObs.SubmissionDateTime__c == null ? Datetime.now() : theObs.SubmissionDateTime__c; // [BB 3/14/18]
            
            if (theObs.RecordTypeId == RevSys_StaticUtility.OBSERVATION_TEST1872_RECTYPE_ID) 
            //    theObs.TestNumber__c == null ) { [BB 3/14/18] comment out for ETR-799
                    myObSpecReqIdSet.add(theObs.OccupationSpecificRequirement__c); 
            //    }
        }
        
        
        if(myObSpecReqIdSet.size() > 0) {
            
            // Get the related OccupationSpecificRequirement records and map them 
            
            OccupationSpecificReqSelector OsrSelector = new OccupationSpecificReqSelector(); 
            
            SelectorWrapper mySelWrap 
                = OsrSelector.getOsrObsRecsById(myObSpecReqIdSet);
            
            List<OccupationSpecificRequirement__c> myOsrList;
            if(mySelWrap !=null){
                errMsg = mySelWrap.ErrorMessage; 
                myOsrList = mySelWrap.SObjectList; 
            }
            system.debug('errMsg '    + errMsg); 
            system.debug('myOsrList ' + myOsrList); 
            
            if(errMsg == null  && myOsrList != null && myOsrList.size() > 0) { 
                
                Map<Id,OccupationSpecificRequirement__c> myOsrMap 
                    = new Map<Id,OccupationSpecificRequirement__c>();
                
                for(OccupationSpecificRequirement__c myOsr :myOsrList) {
                    myOsrMap.put(myOsr.Id, myOsr); 
                }
                
                // Apply the OSR test name and number to the Observation 
                for(Observation__c theObs :theObsList) {
                    
                    OccupationSpecificRequirement__c myOsr 
                        = myOsrMap.get(theObs.OccupationSpecificRequirement__c); 
                    
                    theObs.TestNumber__c = myOsr.Test_Number__c; 
                    theObs.TestName__c   = myOsr.TestName__c; 
                }
            }
            else if(errMsg == null && myOsrList == null) {
                errMsg = 'An OccupationSpecificRequirement record (Test Number) was not found for this Observation.'; 
            }
        }
        
        system.debug('HELPER RevSys_ObservationHelper generateSupervisorContactMap-End');     
        return errMsg;  
    }
    
    /**


*————————————————————————————————————————————————————
* @Name: getPerformingSupervisorContactInfo
* @Description
* Generates a map of contacts with observation mapping to the current login user
*————————————————————————————————————————————————————
* @param    theNewObsList   List of Observation records, generally from the trigger
* @return  String A map of contacts indexed by Id 
*————————————————————————————————————————————————————
**/
    public static String getPerformingSupervisorContactInfo(List<Observation__c> theRevSysObsList)
    {
        system.debug('HELPER RevSys_ObservationHelper generateSupervisorContactMap-Start');     
        String ErrMsg = null;                   
        List<Contact> ContactIdList        = new List<Contact>();
        Set<String> myUserEmployeeNumber = new Set<String>(); 
        List<User> UserList = new List<User>();   
        List<Observation__c> lstObservation = new List<Observation__c>();
        
        SelectorWrapper wrapper = UserSelector.getUsers(new Set<Id>{UserInfo.getUserId()});
        
        if(wrapper!=null) {
            UserList = wrapper.SObjectList;
            for(User Us : UserList) {
                if((Us.EmployeeNumber)!= null){
                    Integer tmp = Integer.valueOf(Us.EmployeeNumber);//raj pandy - 02/19/18
                    myUserEmployeeNumber.add(String.valueOf(tmp));
                }               
            }            
        }
        
        SelectorWrapper contactwrapper = ContactSelector.getContactsBySAPId(myUserEmployeeNumber);    
        
        ErrMsg = contactwrapper.ErrorMessage; 
        
        if(contactwrapper.SObjectList.size() > 0 && contactwrapper.ErrorMessage == null){
            ContactIdList = (List<Contact>)contactwrapper.SObjectList;
            System.debug('contactIdList'+contactIdList);
            if(contactIdList.size()>0){
                System.debug('ContactIdList[0].Id'+ContactIdList[0].Id);    
                for(Observation__c theNewObs :theRevSysObsList) {                
                    theNewObs.Supervisor__c = ContactIdList[0].Id;
                    theNewObs.Supervisor_CostCenter__c = ContactIdList[0].Cost_Center__c;
                    theNewObs.Supervisor_Craft__c = ContactIdList[0].Craft__c;
                    theNewObs.Supervisor_Department__c = ContactIdList[0].Department;
                    theNewObs.Supervisor_Division__c = ContactIdList[0].Division__c;
                    theNewObs.Supervisor_Occupation__c = ContactIdList[0].Occupation__c;
                    theNewObs.Supervisor_OrgUnitNumber__c = ContactIdList[0].Org_Unit_Number__c;  
                    theNewObs.Supervisor_Position__c = ContactIdList[0].Position_Abbrv__c;
                    theNewObs.Supervisor_Region__c = ContactIdList[0].Region__c;                     
                    lstObservation.add(theNewObs);    
                }    
            }
        }      
        
        system.debug('HELPER RevSys_ObservationHelper generateSupervisorContactMap-End');     
        return ErrMsg;  
    }
    
    /**
*————————————————————————————————————————————————————
* @Name: getEmployeeSupervisorContactInfo
* @Description
* Stamps the email Id of the employee's supervisor
*————————————————————————————————————————————————————
* @param    theNewObsList   List of Observation records, generally from the trigger
* @return   Map<Id, Contact> A map of contacts indexed by Id 
*————————————————————————————————————————————————————
**/
    public static String getEmployeeSupervisorContactInfo(List<Observation__c> theRevSysObsList) {
        
        String errMsg; 
        
        //Fetch the employees on the observation
        Set<Id> employeeIds = new Set<Id>();
        List<EPW_Hierarchy_Assignment__c> HIList        = new List<EPW_Hierarchy_Assignment__c>();
        
        for(Observation__c obs : theRevSysObsList) {
            if(obs.Employee__c!=null) {
                employeeIds.add(obs.Employee__c);
            }
        }
        //Get the supervisor and assign to the lookup field on the observation
        if(!employeeIds.isEmpty()) {
            SelectorWrapper wrapper = HierarchyAssignmentSelector.getSPARTNManagerByContact(employeeIds);    
            
            errMsg = wrapper.ErrorMessage; 
            
            if(wrapper.SObjectList.size() > 0 && wrapper.ErrorMessage == null) { 
        
                HIList = (List<EPW_Hierarchy_Assignment__c>)wrapper.SObjectList;    
                
                for(Observation__c obs : theRevSysObsList) {
                    if(HIList.size()>0) {
                        
                            obs.EmployeeSupervisor__c = HIList[0].SPARTN_Manager__c;
                            obs.MAR_CostCenter__c = HIList[0].SPARTN_Manager__r.Cost_Center__c;
                            obs.MAR_Craft__c= HIList[0].SPARTN_Manager__r.Craft__c;
                            obs.MAR_Department__c= HIList[0].SPARTN_Manager__r.Department;
                            obs.MAR_Division__c= HIList[0].SPARTN_Manager__r.Division__c;
                            obs.MAR_Occupation__c= HIList[0].SPARTN_Manager__r.Occupation__c;
                            obs.MAR_OrgUnitNumber__c= HIList[0].SPARTN_Manager__r.Org_Unit_Number__c;
                            obs.MAR_Position__c= HIList[0].SPARTN_Manager__r.Position_Abbrv__c;
                            obs.MAR_Region__c    = HIList[0].SPARTN_Manager__r.Region__c;
                    }
                }           
            }
        }
        
        return errMsg; 
    }
    
 
/*————————————————————————————————————————————————————
* @Name: updateHierarchyAssignmentwithtestdate
* @Description
* Updated Hierachy Assignment with test date when Observation is submitted
*————————————————————————————————————————————————————
* @param    theNewObsList   List of Observation records, generally from the trigger
* @return  String A map of contacts indexed by Id 
*————————————————————————————————————————————————————
**/

    public static String updateHierarchyAssignmentwithtestdate(List<Observation__c> theRevSysObsList)
    {
        system.debug('HELPER RevSys_ObservationHelper updateEmployeeHierarchywithtestdate-Start'); 
        varObservationInvoked = true;
        String ErrMsg = null;                   
        Map<Id,DateTime> ContactLastTestTakenDate = new Map<Id,DateTime>();
        
        system.debug('theRevSysObsList'+theRevSysObsList);    
        
        for(Observation__c o : theRevSysObsList){
            //   system.debug('RecordTypeId'+o.recordtypeId+'78'+Revsys_StaticUtility.EMP_RES_SUMM_TEST1878_RECTYPE_ID+'72'+Revsys_StaticUtility.EMP_RES_SUMM_TEST1872_RECTYPE_ID+'77'+Revsys_StaticUtility.EMP_RES_SUMM_TEST1877_RECTYPE_ID+'75'+Revsys_StaticUtility.EMP_RES_SUMM_TEST1875_RECTYPE_ID);  
            
            if(o.RecordTypeId==Revsys_StaticUtility.OBSERVATION_TEST1878_RECTYPE_ID  && o.Status__c==Revsys_StaticUtility.OBSERVATION_STATUS_COMPLETE){
                system.debug('o.Employee__c'+o.Employee__c+'o.EvaluationDateTime__c'+o.EvaluationDateTime__c);  
                
                ContactLastTestTakenDate.put(o.Employee__c,o.EvaluationDateTime__c);
            }    
        }
        system.debug('ContactLastTestTakenDate'+ContactLastTestTakenDate);    
        //List <Id> ContactList = new List<Id>(ContactLastTestTakenDate.keyset());
        
        List <EPW_Hierarchy_Assignment__c> empHierList = new List<EPW_Hierarchy_Assignment__c>();
        // system.debug('ContactList$$$'+ContactList); 
       
        if(!ContactLastTestTakenDate.isEmpty()) {
            SelectorWrapper wrapper = HierarchyAssignmentSelector.getHrAssgnmentByContact(ContactLastTestTakenDate.keyset());
            If(String.isBlank(wrapper.ErrorMessage)){        
                for(EPW_Hierarchy_Assignment__c empHier : (List<EPW_Hierarchy_Assignment__c>) wrapper.SObjectList) {
                    empHier.SPARTN_LastTestCompletionDate__c = ContactLastTestTakenDate.get(empHier.EPW_Contact__c);  
                    empHierList.add(empHier);
                    system.debug('ContactLastTestTakenDate.get(empHier.EPW_Contact__c)$$$'+ContactLastTestTakenDate.get(empHier.EPW_Contact__c)); 
                }        
            } else {
                ErrMsg = wrapper.ErrorMessage;
            }
        }
        
        if(!empHierList.isEmpty()) {
            Revsys_HierarchyAssignmentHelper.doNotExecute = true;
            ErrMsg = DMLHelper.updateList(empHierList);
        }
        
        system.debug('HELPER RevSys_ObservationHelper updateEmployeeHierarchywithtestdate-End');     
        return ErrMsg;  
    }

/*————————————————————————————————————————————————————
* @Name: updateEmployeeCertification
* @Description
* (ETR-1231, ETR-1236, ETR-1237, ETR-1239, ETR-1213, ETR-1214)
* Update employee certification if observation has test FRA123, FRA125 or FRA138
*————————————————————————————————————————————————————
* @param    theNewObsList   List of Observation records, generally from the trigger
*           theOldMap       Map of Observation values
* @return  String for any error message
*————————————————————————————————————————————————————
**/
    public static String updateEmployeeCertification(List<Observation__c> theRevSysObsList, Map<Id, SObject> theOldMap)
    {
        system.debug('HELPER RevSys_ObservationHelper updateEmployeeCertification-Start'); 
        String errMsg = null;                   
        Map<Id, List<Observation__c>> empFraObsMap = new Map<Id, List<Observation__c>>();
        Map<Id, EmployeeCertification__c> empCertToUpdateMap = new Map<Id, EmployeeCertification__c>();
        Map<String, List<String>> testNumbersMap = new Map<String, List<String>>(); // Map collection of the FRA test numbers by Engineer and Conductor
        List<String> fraTestsList = new List<String>(); // List of FRA test numbers from custom setting
        List<String> engineerTestsList = new List<String>();  // List of engineer FRA303 test numbers from custom setting
        List<String> conductorTestsList = new List<String>(); // List of conductor efficiency test numbers from custom setting
        Map<Id, EPW_Hierarchy_Assignment__c> hierarchyAssignmentMap = new Map<Id, EPW_Hierarchy_Assignment__c>();

        if (REVSYS_Custom_Settings__c.getValues('Obs Form-1872 Efficiency Test Numbers') != null) {
            String fraTests = String.valueOf(REVSYS_Custom_Settings__c.getValues('Obs Form-1872 Efficiency Test Numbers').CSVString__c);
            fraTestsList = fraTests.split(',');
        }

        if (REVSYS_Custom_Settings__c.getValues('Engineer FRA303 Test Numbers') != null) {
            String enTests = String.valueOf(REVSYS_Custom_Settings__c.getValues('Engineer FRA303 Test Numbers').CSVString__c);
            engineerTestsList = enTests.split(',');
            fraTestsList.addAll(engineerTestsList);
            testNumbersMap.put('engineerTests', engineerTestsList);
        }
        system.debug('engineerTestsList' + engineerTestsList);    

        if (REVSYS_Custom_Settings__c.getValues('Conductor Efficiency Test Numbers') != null) {
            String condTests = String.valueOf(REVSYS_Custom_Settings__c.getValues('Conductor Efficiency Test Numbers').CSVString__c);
            conductorTestsList = condTests.split(',');
            fraTestsList.addAll(conductorTestsList);
            testNumbersMap.put('conductorTests', conductorTestsList);
        }
        system.debug('conductorTestsList' + conductorTestsList);    
        system.debug('fraTestsList' + fraTestsList);    

        for(Observation__c obs : theRevSysObsList) {
            if(obs.RecordTypeId==Revsys_StaticUtility.OBSERVATION_TEST1872_RECTYPE_ID && obs.Status__c==Revsys_StaticUtility.OBSERVATION_STATUS_COMPLETE
               && !fraTestsList.isEmpty() && fraTestsList.contains(obs.TestNumber__c) && obs.Employee__c != null) {
                if (theOldMap != null) {
                    System.debug('=====> inside update ');
                    Observation__c oldObs = (Observation__c)theOldMap.get(obs.Id);
                    if (oldObs.TestNumber__c != obs.TestNumber__c || oldObs.Date__c != obs.Date__c
                        || (oldObs.Result__c != obs.Result__c && obs.Result__c == Label.RevSys_Generic_Pass)
                        || (oldObs.Result__c != obs.Result__c && obs.Result__c == Label.Revsys_1872_Result_Compliant)) {
                        if (!empFraObsMap.containsKey(obs.Employee__c)) {
                            empFraObsMap.put(obs.Employee__c, new List<Observation__c>());
                        }
                        empFraObsMap.get(obs.Employee__c).add(obs);
                    }

                }            
                else if (theOldMap == null) {
                    if (obs.Result__c == Label.RevSys_Generic_Pass || obs.Result__c == Label.Revsys_1872_Result_Compliant) {
                        System.debug('=====> inside insert ');
                        if (!empFraObsMap.containsKey(obs.Employee__c)) {
                            empFraObsMap.put(obs.Employee__c, new List<Observation__c>());
                        }
                        empFraObsMap.get(obs.Employee__c).add(obs);
                    }
                }
            }    
        }
        System.debug('=====> empFraObsMap size: ' + empFraObsMap.size());
        if (!empFraObsMap.isEmpty()) {
            SelectorWrapper wrapper = EmployeeCertificationSelector.getEmpCertByEmpIds(empFraObsMap.keySet(), null);
          
            SelectorWrapper wrapperHierarchyAssignment = HierarchyAssignmentSelector.getHrAssgnmentByContact(empFraObsMap.keyset());
            if(String.isBlank(wrapperHierarchyAssignment.ErrorMessage)){
                List<EPW_Hierarchy_Assignment__c> hierarchyAssignmentList = (List<EPW_Hierarchy_Assignment__c>)wrapperHierarchyAssignment.SObjectList;
                for(EPW_Hierarchy_Assignment__c hierarchyObject : hierarchyAssignmentList){
                    hierarchyAssignmentMap.put(hierarchyObject.EPW_Contact__c, hierarchyObject);
                }
                
            }
            if (String.isBlank(wrapper.ErrorMessage)) {   
                List<EmployeeCertification__c> empCertList = (List<EmployeeCertification__c>) wrapper.SObjectList;
                empCertToUpdateMap = processFRALogic(empFraObsMap, empCertList, testNumbersMap, hierarchyAssignmentMap);    
            } else {
                errMsg = wrapper.ErrorMessage;
            }
        }
        
        if(!empCertToUpdateMap.isEmpty()) {
            errMsg = DMLHelper.updateList(empCertToUpdateMap.values());
        }
        
        system.debug('HELPER RevSys_ObservationHelper updateEmployeeCertification-End');     
        return errMsg;  
    }
    
/*————————————————————————————————————————————————————
* @Name: processFRALogic
* @Description
* (ETR-1231, ETR-1236, ETR-1237, ETR-1239, ETR-1213, ETR-1214)
* Update employee certification if observation has test FRA123, FRA125 or FRA138
*————————————————————————————————————————————————————
* @param    empFraObsMap  A map observation for FRA logic
*           empCertList List of Employee Certification
*           testNumbersMap A map of list of FRA test numbers for Engineer and Conductor
* @return  String for any error message
*————————————————————————————————————————————————————
**/
    public static Map<Id, EmployeeCertification__c> processFRALogic(Map<Id, List<Observation__c>> empFraObsMap, 
                                         List<EmployeeCertification__c> empCertList,
                                         Map<String, List<String>> testNumbersMap,
                                         Map<Id,EPW_Hierarchy_Assignment__c> hierarchyAssignmentMap)
    {
        Map<Id, EmployeeCertification__c> empCertToUpdateMap = new Map<Id, EmployeeCertification__c>();
        List<String> conductorTestsList = new List<String>(testNumbersMap.get('conductorTests'));
        List<String> engineerTestsList = new List<String>(testNumbersMap.get('engineerTests'));
        String errMsg = null;
        
        
        for (EmployeeCertification__c empCert : empCertList) {
            for (Observation__c obs : empFraObsMap.get(empCert.Employee__c)) {
              
                if (obs.TestNumber__c == Label.RevSys_FRA123_TestNumber) {
                    // ETR-1231
                    if (empCert.EfficiencyTestFRA123__c == null) {
                        empCert.EfficiencyTestFRA123__c = obs.Date__c;
                    }
                    else if (obs.Date__c > empCert.EfficiencyTestFRA123__c) {
                        empCert.EfficiencyTestFRA123__c = obs.Date__c;
                    }
                    empCertToUpdateMap.put(empCert.Id, empCert);
                }
                if (obs.TestNumber__c == Label.RevSys_FRA125_TestNumber) {
                    // ETR-1231
                    if (empCert.EfficiencyTestFRA125__c == null) {
                        empCert.EfficiencyTestFRA125__c = obs.Date__c;
                    }
                    else if (obs.Date__c > empCert.EfficiencyTestFRA125__c) {
                        empCert.EfficiencyTestFRA125__c = obs.Date__c;
                    }  
                    // ETR-1236
                    if (empCert.LastOperatingRulesDate__c == null) {
                        empCert.LastOperatingRulesDate__c = obs.Date__c;
                    }
                    else if (obs.Date__c > empCert.LastOperatingRulesDate__c) {
                        empCert.LastOperatingRulesDate__c = obs.Date__c;
                    }  
                    
                    empCertToUpdateMap.put(empCert.Id, empCert);
                }
                if (obs.TestNumber__c == Label.RevSys_FRA138_TestNumber) {
                    // ETR-1231
                    if (empCert.EfficiencyTestFRA138__c == null) {
                        empCert.EfficiencyTestFRA138__c = obs.Date__c;
                    }
                    else if (obs.Date__c > empCert.EfficiencyTestFRA138__c) {
                        empCert.EfficiencyTestFRA138__c = obs.Date__c;
                    }                           
                    // ETR-1239
                    if (empCert.EmergencyPreparednessTest__c == null) {
                        empCert.EmergencyPreparednessTest__c = obs.Date__c;
                    }
                    else if (obs.Date__c > empCert.EmergencyPreparednessTest__c) {
                        empCert.EmergencyPreparednessTest__c = obs.Date__c;
                    } 
                    // ETR-1213
                    if (empCert.LastRecertificationDate__c == null) {
                        empCert.LastRecertificationDate__c = obs.Date__c;
                    }
                    else if (obs.Date__c > empCert.LastRecertificationDate__c) {
                        empCert.LastRecertificationDate__c = obs.Date__c;
                    } 
                    empCertToUpdateMap.put(empCert.Id, empCert);
                }
                if (obs.TestNumber__c == Label.RevSys_FRA138_TestNumber || conductorTestsList.contains(obs.TestNumber__c)) {
                    // ETR-1237                          
                    if (empCert.LastEfficiencyTestDate__c == null) {
                        empCert.LastEfficiencyTestDate__c = obs.Date__c;
                    }
                    else if (obs.Date__c > empCert.LastEfficiencyTestDate__c) {
                        empCert.LastEfficiencyTestDate__c = obs.Date__c;
                    } 
                    empCertToUpdateMap.put(empCert.Id, empCert);
                }
                if (engineerTestsList.contains(obs.TestNumber__c)) {
                    // ETR-1214                          
                    if (empCert.EfficiencyTestFRA303__c == null) {
                        empCert.EfficiencyTestFRA303__c = obs.Date__c;
                        if (hierarchyAssignmentMap != null && hierarchyAssignmentMap.containsKey(obs.Employee__c)) {
                            hierarchyAssignmentMap.get(obs.Employee__c).EfficiencyTestFRA303__c = obs.Date__c;
                        }
                    }
                    else if (obs.Date__c > empCert.EfficiencyTestFRA303__c) {
                        empCert.EfficiencyTestFRA303__c = obs.Date__c;
                        if (hierarchyAssignmentMap != null && hierarchyAssignmentMap.containsKey(obs.Employee__c)) {
                            hierarchyAssignmentMap.get(obs.Employee__c).EfficiencyTestFRA303__c = obs.Date__c;
                        }
                    } 
                    empCertToUpdateMap.put(empCert.Id, empCert);
                }
                
                if (hierarchyAssignmentMap != null  && hierarchyAssignmentMap.containsKey(obs.Employee__c)) {
                    if (conductorTestsList.contains(obs.TestNumber__c)) {
                            hierarchyAssignmentMap.get(obs.Employee__c).Lastcfr242123__c = obs.Date__c;
                    }
                    hierarchyAssignmentMap.get(obs.Employee__c).lastobservationdate__c = obs.Date__c;
                }
                
            }                
            
            if(!hierarchyAssignmentMap.isEmpty() && hierarchyAssignmentMap != null) {
                Revsys_HierarchyAssignmentHelper.doNotExecute = true;
                ErrMsg = DMLHelper.updateList(hierarchyAssignmentMap.values());
            }
        }
        system.debug('HELPER RevSys_ObservationHelper processFRALogic-End');     
        return empCertToUpdateMap;
      
    }
/*
*————————————————————————————————————————————————————
* @Name: generateObservationDuplicateError
* @Description
* Generates a map of contacts with observation mapping to the current login user
*————————————————————————————————————————————————————
* @param    theNewObsList   List of Observation records, generally from the trigger
* @return   errMsg  
*————————————————————————————————————————————————————
*
    public static String generateObservationDuplicateError(List<Observation__c> theRevSysObsList)
    {
        system.debug('HELPER RevSys_ObservationHelper generateObservationDuplicateError-Start');     
        String ErrMsg = null;                   
        Set<Datetime> EvaluationDateSet        = new Set<Datetime>();
        Set<ID> EmployeeIdSet        = new Set<ID>();
        Map<id,List<Observation__c>> EmployeeIdObsetvationMap = new Map<id,List<Observation__c>>();
        List<Observation__c> ObsObjList = new List<Observation__c>();
        
        for(Observation__c obsObj : theRevSysObsList){
            if(theRevSysObsList !=NULL){
                EvaluationDateSet.add(obsObj.EvaluationDateTime__c);
                EmployeeIdSet.add(obsObj.Employee__c);
            }
        }
        //Returning the EvaluationDateSet based on the employees ids
        SelectorWrapper wrapper = ObservationSelector.selectByEvaluationDateAndEmployee(EvaluationDateSet,EmployeeIdSet);
        if(wrapper!=null){
            ObsObjList = (List<Observation__c>)wrapper.SObjectList;
        }
        
        //Looping to create the EmployeeIdObsetvationMap
        for( Observation__c tempObsObj : ObsObjList)
        {
            if(EmployeeIdObsetvationMap.containsKey(tempObsObj.Employee__c)){
                EmployeeIdObsetvationMap.get(tempObsObj.Employee__c).add(tempObsObj);//When the Key already exists
            }
            else{
                EmployeeIdObsetvationMap.put(tempObsObj.Employee__c,  new List<Observation__c>{tempObsObj});
            }
        }
        
        //Loop to check
        for(Observation__c tempParObsObj : theRevSysObsList){
            for(Observation__c tempChiObsObj : EmployeeIdObsetvationMap.get(tempParObsObj.Employee__c)){
                if(tempParObsObj.EvaluationDateTime__c == tempChiObsObj.EvaluationDateTime__c &&
                   tempParObsObj.Employee__c == tempChiObsObj.Employee__c){
                       if(tempParObsObj.RecordType.DeveloperName != Label.RevSys_Observation_RT_API_Test_1872){
                           errMsg = Label.RevSys_Cannot_create_the_same_observation_more_than_once_on_a_given_day_for_the; //Custom error message to be displayed duplicate observation
                       }
                       else if(tempParObsObj.RecordType.DeveloperName == Label.RevSys_Observation_RT_API_Test_1872 &&
                               tempParObsObj.TestNumber__c == tempChiObsObj.TestNumber__c ){
                                   errMsg = Label.RevSys_Cannot_create_the_same_observation_more_than_once_on_a_given_day_for_the; //Custom error message to be displayed duplicate observation
                               }
                   }
            }
        } 
        return errMsg;
    }*/
}
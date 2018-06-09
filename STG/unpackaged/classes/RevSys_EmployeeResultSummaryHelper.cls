/**
*___________________________________________________
*@Name: RevSys_EmployeeResultSummaryHelper
*@Author: Raj Kumar Pandy
*@Created: Date: 12/7/2017
*@Used_By: Review Systems
*___________________________________________________
*@Description: Updates the corresponding Employee Specific records
* 
*___________________________________________________
*@Changes: 
*02-19-2018 [Raj Pandy] created updateHealthServices method to set default Nurse 
*05-21-2018 ETR-1211; ETR-1259: Utilize specific values for Failed Vision and Failed Hearing Tests, 
*                               instead of "Failed Test."
*05-24-2018 ETR-1211; ETR-1259: Update logic for Vision Tests 
**/
public class RevSys_EmployeeResultSummaryHelper {
   
    private class ErsWrapper {
        Public String               Context; 
        Public EmployeeResultSummary__c       ers;
        
        public ErsWrapper(String theContext, EmployeeResultSummary__c  theErs) {
            Context     = theContext;
            ers    = theErs; 
        }
    }
    
    /**
*————————————————————————————————————————————————————
* @Name: createEmpSpecRequirement()
* @Description
* Creates Employee Specific Requirement records based on the Occupation Certification
*————————————————————————————————————————————————————
* @param    theNewEmpCertList	List of Employee Certification records, generally from the trigger
* @return   String		    Error message
*————————————————————————————————————————————————————
**/ 
    public static String updateRecords(List<EmployeeResultSummary__c> theNewEmpResSumList, Map<Id, EmployeeResultSummary__c> theOldMap)
    {
        system.debug('HELPER RevSys_EmployeeResultSummaryHelper updateRecords-Start'); 
        //Initialising the variables
        String errMsg;
        
        Set<ID> myEmployeeIdSet = new Set<ID>();
        EmployeeResultSummary__c theOldErs = new EmployeeResultSummary__c();
        
        List<EmployeeSpecificRequirement__c> empSpecReqList = new List<EmployeeSpecificRequirement__c>();
        Map<ID, List<EmployeeSpecificRequirement__c>> empIdEmpSpecReqMap = new Map<ID, List<EmployeeSpecificRequirement__c>>();
        
        List<EmployeeSpecificRequirement__c> empSpecReqMasterList = new List<EmployeeSpecificRequirement__c>();
        
        List<ErsWrapper> ErsWrapperList = new List<ErsWrapper>();
        
        // Loop on Employee Result Summary to fetch the Employee Ids 
        for(EmployeeResultSummary__c tempEmpResSumObj : theNewEmpResSumList)
        {
            
            if(tempEmpResSumObj.Status__c != NULL || 
               tempEmpResSumObj.Result__c != NULL   || 
               tempEmpResSumObj.CanEmployeeBeCertified__c== Label.REVSYS_Generic_Yes)
            {
                
                myEmployeeIdSet.add(tempEmpResSumObj.Employee__c);
            }
        }
        
        // Query to fetch the Employee Specific Requirements based on the Employee Ids 
        SelectorWrapper wrapper = EmployeeSpecificRequirementSelector.getEmployeeSpecificRequirements(myEmployeeIdSet);
        empSpecReqList = (List<EmployeeSpecificRequirement__c>)wrapper.SobjectList;
        
        //Loop to create the empIdEmpSpecReqMap
        for(EmployeeSpecificRequirement__c tempEmpSpecReqObj : empSpecReqList)
        {
            if(empIdEmpSpecReqMap.containsKey(tempEmpSpecReqObj.Employee__c))//When the Key value already exists
            {
                List<EmployeeSpecificRequirement__c> tempEmpSpecReqList = new List<EmployeeSpecificRequirement__c>();
                tempEmpSpecReqList = empIdEmpSpecReqMap.get(tempEmpSpecReqObj.Employee__c);
                tempEmpSpecReqList.add(tempEmpSpecReqObj);
                empIdEmpSpecReqMap.put(tempEmpSpecReqObj.Employee__c, tempEmpSpecReqList);
            }
            else//When the Key value does nto exists
            {
                List<EmployeeSpecificRequirement__c> tempEmpSpecReqList1 = new List<EmployeeSpecificRequirement__c>();
                tempEmpSpecReqList1.add(tempEmpSpecReqObj);
                empIdEmpSpecReqMap.put(tempEmpSpecReqObj.Employee__c , tempEmpSpecReqList1);
            }
        }
        
        // Loop on Employee Result Summary to check the Record Type and Call methods accordingly
        List<EmployeeSpecificRequirement__c> tempEmpSpecReqList;
        for(EmployeeResultSummary__c tempEmpResSumObj : theNewEmpResSumList)
        {
            if(theOldMap != null){
                Sobject theOldObj = theOldMap.get(tempEmpResSumObj.id);
                theOldErs = (EmployeeResultSummary__c)theOldObj;
            }
            
            ErsWrapper ersNon1872;
            
            tempEmpSpecReqList = new List<EmployeeSpecificRequirement__c>();
            //Condition to check Status, Result and whether the employee can be certified 
            if(tempEmpResSumObj.Status__c != NULL || 
               tempEmpResSumObj.Result__c != NULL   || 
               tempEmpResSumObj.CanEmployeeBeCertified__c== Label.REVSYS_Generic_Yes)
            {
                //Fetching the record type
                String ErsRecordTypeName = Schema.SObjectType.EmployeeResultSummary__c.getRecordTypeInfosById().get(tempEmpResSumObj.RecordTypeId).getName();
                if(tempEmpResSumObj.RecordTypeId == RevSys_StaticUtility.EMP_RES_SUMM_TEST1872_RECTYPE_ID)//1872 Record Type
                {
                    system.debug('--------------This is coming');
                    tempEmpSpecReqList = processObservation1872(tempEmpResSumObj, ErsRecordTypeName, empIdEmpSpecReqMap.get(tempEmpResSumObj.Employee__c));
                }
                //1875, 1876, 1877 and 1878 Record Types
                else if(tempEmpResSumObj.RecordTypeId == RevSys_StaticUtility.EMP_RES_SUMM_TEST1875_RECTYPE_ID ||
                        tempEmpResSumObj.RecordTypeId == RevSys_StaticUtility.EMP_RES_SUMM_TEST1876_RECTYPE_ID ||
                        tempEmpResSumObj.RecordTypeId == RevSys_StaticUtility.EMP_RES_SUMM_TEST1877_RECTYPE_ID ||
                        tempEmpResSumObj.RecordTypeId == RevSys_StaticUtility.EMP_RES_SUMM_TEST1878_RECTYPE_ID)
                {
                    if(theOldMap == null){
                        
                        ersNon1872 = new ErsWrapper(Label.Revsys_Constant_Add, tempEmpResSumObj);
                    }
                    else{
                        
                        if(tempEmpResSumObj.Status__c == Label.RevSys_Generic_Removed &&
                           theOldErs.Status__c != tempEmpResSumObj.Status__c){
                               
                               ersNon1872 = new ErsWrapper(Label.RevSys_Generic_Removed, tempEmpResSumObj);
                           }
                        else{
                            
                            ersNon1872 = new ErsWrapper(Label.Revsys_Constant_Add, tempEmpResSumObj);
                        }
                    }
                    tempEmpSpecReqList = processObservationNon1872(ersNon1872, ErsRecordTypeName, empIdEmpSpecReqMap.get(tempEmpResSumObj.Employee__c));
                }
                else if(tempEmpResSumObj.RecordTypeId == RevSys_StaticUtility.EMP_RES_SUMM_MEDICAL_RECTYPE_ID)//Medical record Type
                {
                    tempEmpSpecReqList = processMedicalHearingAndVision(tempEmpResSumObj, ErsRecordTypeName, empIdEmpSpecReqMap.get(tempEmpResSumObj.Employee__c));
                }
                else if(tempEmpResSumObj.RecordTypeId == RevSys_StaticUtility.EMP_RES_SUMM_EMPHISTORY_RECTYPE_ID)//Employee History Record type
                {
                    tempEmpSpecReqList = processEmploymentHistory(tempEmpResSumObj, ErsRecordTypeName, empIdEmpSpecReqMap.get(tempEmpResSumObj.Employee__c));
                }
                else if(tempEmpResSumObj.RecordTypeId == RevSys_StaticUtility.EMP_RES_SUMM_MOTORVEHICLE_RECTYPE_ID)//Motor Vehicle record type
                {
                    tempEmpSpecReqList = processMotorVehicleReview(tempEmpResSumObj, ErsRecordTypeName, empIdEmpSpecReqMap.get(tempEmpResSumObj.Employee__c));
                }
            }
            
            if(tempEmpSpecReqList.size()>0)
            {
                empSpecReqMasterList.addAll(tempEmpSpecReqList);
            }
        }
        system.debug('This is list'+empSpecReqMasterList);
        
        //Insert the Employee Specific Requirements
        errMsg = DmlHelper.updateList(empSpecReqMasterList);
        
        system.debug('HELPER RevSys_EmployeeResultSummaryHelper updateRecords-End');
        
        return errMsg;
    }
    /**
*————————————————————————————————————————————————————
* @Name: processObservation1872()
* @Description
* Updates the Employee Specific Requirement records of type 1872
*————————————————————————————————————————————————————
* @param    EmployeeResultSummary__c Single Employee Result Summary record 
*           myErsRecordTypeName      Employee Result Summary record type name
*           empSpecReqList	        List of Targets associated with the employee
* @return   List<EmployeeSpecificRequirement__c> Updated Employee Targets 
*————————————————————————————————————————————————————
**/ 
    public static List<EmployeeSpecificRequirement__c> processObservation1872(EmployeeResultSummary__c empResSumObj, String myErsRecordTypeName, List<EmployeeSpecificRequirement__c> empSpecReqList)
    {
        List<EmployeeSpecificRequirement__c> updateEmpSpecReqList = new List<EmployeeSpecificRequirement__c>();
        system.debug('HELPER RevSys_EmployeeResultSummaryHelper processObservation1872-Start');
        system.debug('-------------------- actual List'+empSpecReqList);
        if(empSpecReqList != null) {
            //Loop on Employee Specific Requirements
            for(EmployeeSpecificRequirement__c tempEmpSpecReqObj : empSpecReqList) {
                if(String.isNotBlank(tempEmpSpecReqObj.SourceRecordType__c)) {
                    //Condition to check the Source Record Type, and Result
                    if(tempEmpSpecReqObj.SourceRecordType__c.equalsIgnoreCase(myErsRecordTypeName)){
                        if(empResSumObj.Result__c=='C = Compliance'){
                            tempEmpSpecReqObj.LastFulfilledDate__c = empResSumObj.EvaluationDate__c;
                            tempEmpSpecReqObj.ReportStatus__c = Label.RevSys_Generic_Pass;
                        }
                        else{
                            tempEmpSpecReqObj.LastFulfilledDate__c = empResSumObj.EvaluationDate__c;
                            tempEmpSpecReqObj.ReportStatus__c = Label.RevSys_Generic_Fail;
                        }
                        updateEmpSpecReqList.add(tempEmpSpecReqObj);
                    }
                }
            }
        }
        system.debug('-------------------- update list 1872'+updateEmpSpecReqList);
        system.debug('HELPER RevSys_EmployeeResultSummaryHelper processObservation1872-End');
        return updateEmpSpecReqList;
    }
    /**
*————————————————————————————————————————————————————
* @Name: processObservationNon1872()
* @Description
* Updates the Employee Specific Requirement records of type not 1872
*————————————————————————————————————————————————————
* @param    EmployeeResultSummary__c Single Employee Result Summary record 
*           myErsRecordTypeName      Employee Result Summary record type name
*           empSpecReqList          List of Targets associated with the employee
* @return   List<EmployeeSpecificRequirement__c> Updated Employee Targets 
*————————————————————————————————————————————————————
**/ 
    public static List<EmployeeSpecificRequirement__c> processObservationNon1872
        (ErsWrapper myErsWrapper, 
         String myErsRecordTypeName, 
         List<EmployeeSpecificRequirement__c> empSpecReqList)
    {
        List<EmployeeSpecificRequirement__c> updateEmpSpecReqList = new List<EmployeeSpecificRequirement__c>();
        system.debug('HELPER RevSys_EmployeeResultSummaryHelper processObservationNon1872-Start');
        
        if(empSpecReqList != null) {
            
            //Loop on Employee Specific Requirements
            for(EmployeeSpecificRequirement__c tempEmpSpecReqObj : empSpecReqList)
            {
                //Condition to compare the Source Record Type of Employee Specific Requirement and Employee Result Summary
                if(tempEmpSpecReqObj.SourceRecordType__c == myErsRecordTypeName){
                    
                    if(myErsWrapper.Context == Label.Revsys_Constant_Add &&
                       tempEmpSpecReqObj.RecordTypeId == Revsys_StaticUtility.EMPSPECREQUIREMENT_SPARTNCERT_RECTYPE_ID){
                           
                           tempEmpSpecReqObj.LastFulfilledDate__c = myErsWrapper.ers.EvaluationDate__c;
                           tempEmpSpecReqObj.ReportStatus__c = myErsWrapper.ers.QualificationStatus__c;
                           
                       }
                    else{
                        
                        tempEmpSpecReqObj.LastFulfilledDate__c = null;
                        tempEmpSpecReqObj.ReportStatus__c = Label.RevSys_Generic_Pending;
                    }
                    
                    updateEmpSpecReqList.add(tempEmpSpecReqObj);
                }
            }
        }
        system.debug('-------------------- update list Non 1872'+updateEmpSpecReqList);
        system.debug('HELPER RevSys_EmployeeResultSummaryHelper processObservationNon1872-End');
        return updateEmpSpecReqList;
    }
    /**
*————————————————————————————————————————————————————
* @Name: processMedicalHearingAndVision()
* @Description
* Updates the Employee Specific Requirement records of type Medical Hearing and Vision
*————————————————————————————————————————————————————
* @param    EmployeeResultSummary__c Single Employee Result Summary record 
*           myErsRecordTypeName      Employee Result Summary record type name
*           empSpecReqList          List of Targets associated with the employee
* @return   List<EmployeeSpecificRequirement__c> Updated Employee Targets 
*————————————————————————————————————————————————————
**/
    public static List<EmployeeSpecificRequirement__c> processMedicalHearingAndVision(EmployeeResultSummary__c empResSumObj, String myErsRecordTypeName, List<EmployeeSpecificRequirement__c> empSpecReqList)
    {
        List<EmployeeSpecificRequirement__c> updateEmpSpecReqList = new List<EmployeeSpecificRequirement__c>();
        Map<Id, EmployeeSpecificRequirement__c> tempESRMap = new Map<Id, EmployeeSpecificRequirement__c>();
        system.debug('HELPER RevSys_EmployeeResultSummaryHelper processMedicalHearingAndVision-Start');
        if(empSpecReqList!=null) {
            //Loop on Employee Specific Requirements
            for(EmployeeSpecificRequirement__c tempEmpSpecReqObj : empSpecReqList)
            {
                //Condition to compare the Source Record Type and Source Test type of Employee Specific Requirement and Employee Result Summary
                if(tempEmpSpecReqObj.SourceRecordType__c == myErsRecordTypeName && 
                   tempEmpSpecReqObj.SourceTestType__c   == empResSumObj.Type__c)
                {
                    
                    //Remove check to compare the list for populating LastFulFilledDate
                    if(empResSumObj.Type__c == Label.RevSys_Generic_Vision_Test && 
                       empResSumObj.FieldTestResult__c == Label.RevSys_Generic_Pass) {
                           tempEmpSpecReqObj.LastFulfilledDate__c = empResSumObj.FieldTestDate__c;
                       }
                    else {
                        tempEmpSpecReqObj.LastFulfilledDate__c = empResSumObj.EvaluationDate__c;
                    }
                    
                    tempEmpSpecReqObj.Restrictions__c = empResSumObj.RestrictionType__c;
                    tempESRMap.put(tempEmpSpecReqObj.id, tempEmpSpecReqObj);
                    // }
                }
                if(tempEmpSpecReqObj.RecordTypeId == RevSys_StaticUtility.EMPSPECREQUIREMENT_SPARTNCERT_RECTYPE_ID &&
                   tempEmpSpecReqObj.Source__c == Label.RevSys_ESR_Source_Emp_Result_Summary &&
                   tempEmpSpecReqObj.SourceRecordType__c == myErsRecordTypeName)
                {
                    //Medical Examination Type
                    if(tempEmpSpecReqObj.SourceTestType__c == Label.RevSys_Generic_Medical_Examination &&
                       empResSumObj.Type__c == Label.RevSys_Generic_Medical_Examination)
                    {
                        tempEmpSpecReqObj 
                            = Revsys_EmpSpecReqHelper.processMedical(tempEmpSpecReqObj, empResSumObj);
                        tempESRMap.put(tempEmpSpecReqObj.id, tempEmpSpecReqObj);
                    }
                    //Vision Test
                    else if(tempEmpSpecReqObj.SourceTestType__c == Label.RevSys_Generic_Vision_Test &&
                            empResSumObj.Type__c == Label.RevSys_Generic_Vision_Test)
                    {
                        tempEmpSpecReqObj 
                            = Revsys_EmpSpecReqHelper.processVision(tempEmpSpecReqObj, empResSumObj);
                        tempESRMap.put(tempEmpSpecReqObj.id, tempEmpSpecReqObj);
                    }
                    //Hearing Test
                    else if(tempEmpSpecReqObj.SourceTestType__c == Label.RevSys_Generic_Hearing_Test &&
                            empResSumObj.Type__c == Label.RevSys_Generic_Hearing_Test)
                    {
                        tempEmpSpecReqObj 
                            = Revsys_EmpSpecReqHelper.processHearing(tempEmpSpecReqObj, empResSumObj);
                        tempESRMap.put(tempEmpSpecReqObj.id, tempEmpSpecReqObj);
                    }
                }
            }
        }
        updateEmpSpecReqList = tempESRMap.values();
        
        system.debug('HELPER RevSys_EmployeeResultSummaryHelper processMedicalHearingAndVision-End');
        return updateEmpSpecReqList;
    }
    /**
*————————————————————————————————————————————————————
* @Name: processEmploymentHistory()
* @Description
* Updates the Employee Specific Requirement records of type Employement History
*————————————————————————————————————————————————————
* @param    EmployeeResultSummary__c Single Employee Result Summary record 
*           myErsRecordTypeName      Employee Result Summary record type name
*           empSpecReqList          List of Targets associated with the employee
* @return   List<EmployeeSpecificRequirement__c> Updated Employee Targets 

* CAUTION: The same logc exist in Revsys_EmpSpecReqHelper - processEmploymentHistory
* This code should be mergetd when updating this method. 
*————————————————————————————————————————————————————
**/ 
    public static List<EmployeeSpecificRequirement__c> processEmploymentHistory(EmployeeResultSummary__c empResSumObj, String myErsRecordTypeName, List<EmployeeSpecificRequirement__c> empSpecReqList)
    {
        List<EmployeeSpecificRequirement__c> updateEmpSpecReqList = new List<EmployeeSpecificRequirement__c>();
        Map<Id, EmployeeSpecificRequirement__c> tempESRMap = new Map<Id, EmployeeSpecificRequirement__c>();
        system.debug('HELPER RevSys_EmployeeResultSummaryHelper processObservationNon1872-Start');
        
        if(empSpecReqList != null) 
        {
            //Loop on Employee Specific Requirements
            for(EmployeeSpecificRequirement__c tempEmpSpecReqObj : empSpecReqList)
            {
                //Condition to compare the Source Record Type of Employee Specific Requirement and Employee Result Summary
                if(tempEmpSpecReqObj.SourceRecordType__c == myErsRecordTypeName && 
                   empResSumObj.CanEmployeeBeCertified__c == Label.REVSYS_Generic_Yes)
                {
                    tempEmpSpecReqObj.LastFulfilledDate__c = empResSumObj.EvaluationDate__c;                   
                    tempESRMap.put(tempEmpSpecReqObj.id, tempEmpSpecReqObj);
                }
                if(tempEmpSpecReqObj.RecordTypeId == RevSys_StaticUtility.EMPSPECREQUIREMENT_SPARTNCERT_RECTYPE_ID &&
                   tempEmpSpecReqObj.Source__c == Label.RevSys_ESR_Source_Emp_Result_Summary &&
                   tempEmpSpecReqObj.SourceRecordType__c == myErsRecordTypeName)
                {
                    if(empResSumObj.CanEmployeeBeCertified__c == Label.REVSYS_Generic_Yes)
                    {
                        tempEmpSpecReqObj.ReportStatus__c = Label.RevSys_Generic_Pass;
                        tempESRMap.put(tempEmpSpecReqObj.id, tempEmpSpecReqObj);
                    }
                    else if(empResSumObj.CanEmployeeBeCertified__c == Label.REVSYS_Generic_No)
                    {
                        tempEmpSpecReqObj.ReportStatus__c = Label.RevSys_Generic_Fail;
                        tempESRMap.put(tempEmpSpecReqObj.id, tempEmpSpecReqObj);
                    }
                }
            }
            updateEmpSpecReqList = tempESRMap.values();
        }
        
        system.debug('HELPER RevSys_EmployeeResultSummaryHelper processMedicalHearingAndVision-End');
        return updateEmpSpecReqList;
    }
    /**
*————————————————————————————————————————————————————
* @Name: processMotorVehicleReview()
* @Description
* Updates the Employee Specific Requirement records of type Motor Vehicle Review
*————————————————————————————————————————————————————
* @param    EmployeeResultSummary__c Single Employee Result Summary record 
*           myErsRecordTypeName      Employee Result Summary record type name
*           empSpecReqList          List of Targets associated with the employee
* @return   List<EmployeeSpecificRequirement__c> Updated Employee Targets 
*
* CAUTION: The same logc exist in Revsys_EmpSpecReqHelper - processMotorVehicleReview
* This code should be mergetd when updating this method. 
*————————————————————————————————————————————————————
**/ 
    public static List<EmployeeSpecificRequirement__c> processMotorVehicleReview(EmployeeResultSummary__c empResSumObj, String myErsRecordTypeName, List<EmployeeSpecificRequirement__c> empSpecReqList)
    {
        List<EmployeeSpecificRequirement__c> updateEmpSpecReqList = new List<EmployeeSpecificRequirement__c>();
        Map<Id, EmployeeSpecificRequirement__c> tempESRMap = new Map<Id, EmployeeSpecificRequirement__c>();
        system.debug('HELPER RevSys_EmployeeResultSummaryHelper processMotorVehicleReview-Start');
        if(empSpecReqList != null) {
            
            //Loop on Employee Specific Requirements
            
            for(EmployeeSpecificRequirement__c tempEmpSpecReqObj : empSpecReqList) {
                
                /*if(tempEmpSpecReqObj.SourceRecordType__c == myErsRecordTypeName && 
empResSumObj.Status__c == Label.RevSys_Generic_Pass) {*/
                
                //Removed condition to check for status while populating Last fulfilled date
                //Condition to compare the Status, Source Record Type of Employee Specific Requirement and Employee Result Summary
                
                // IF the Employee Specific Requirement Source =  ERS Record Type 
                if(tempEmpSpecReqObj.SourceRecordType__c == myErsRecordTypeName ) {
                    
                    if(tempEmpSpecReqObj.SourceTestType__c == Label.RevSys_Generic_State_Review) {
                        
                        tempEmpSpecReqObj.LastFulfilledDate__c = empResSumObj.StateReviewDate__c;
                    }
                    
                    if(tempEmpSpecReqObj.SourceTestType__c == Label.RevSys_Generic_National_Review) {
                        
                        tempEmpSpecReqObj.LastFulfilledDate__c = empResSumObj.NdrReviewDate__c;
                    }
                    tempESRMap.put(tempEmpSpecReqObj.id, tempEmpSpecReqObj);
                }
                
                if(tempEmpSpecReqObj.RecordTypeId == RevSys_StaticUtility.EMPSPECREQUIREMENT_SPARTNCERT_RECTYPE_ID &&
                   
                   tempEmpSpecReqObj.Source__c == Label.RevSys_ESR_Source_Emp_Result_Summary &&
                   tempEmpSpecReqObj.SourceRecordType__c == myErsRecordTypeName &&
                   ((empResSumObj.NdrReviewDate__c!= NULL && tempEmpSpecReqObj.SourceTestType__c== Label.RevSys_Generic_National_Review) ||(empResSumObj.StateReviewDate__c!= NULL && tempEmpSpecReqObj.SourceTestType__c== Label.RevSys_Generic_State_Review)))
                {
                    if(empResSumObj.Status__c == Label.RevSys_Generic_Pass)
                    {
                        tempEmpSpecReqObj.ReportStatus__c = Label.RevSys_Generic_Pass;
                        tempESRMap.put(tempEmpSpecReqObj.id, tempEmpSpecReqObj);
                        system.debug('This is the req'+tempEmpSpecReqObj);
                    }
                    else if(empResSumObj.Status__c == Label.RevSys_Generic_Fail)
                    {
                        tempEmpSpecReqObj.ReportStatus__c = Label.RevSys_Generic_Fail;
                        tempESRMap.put(tempEmpSpecReqObj.id, tempEmpSpecReqObj);
                        system.debug('This is the req'+tempEmpSpecReqObj);
                    } 
                    //Added Pending status if status on the ERS is updated to pending
                    else if(empResSumObj.Status__c==Label.RevSys_Generic_Pending) {
                        tempEmpSpecReqObj.ReportStatus__c = Label.RevSys_Generic_Pending;
                        tempESRMap.put(tempEmpSpecReqObj.id, tempEmpSpecReqObj);
                    }
                } 
            }
            updateEmpSpecReqList = tempESRMap.values();
        }
        system.debug('-----------------------update List MVR'+updateEmpSpecReqList);
        system.debug('HELPER RevSys_EmployeeResultSummaryHelper processMotorVehicleReview-End');
        return updateEmpSpecReqList;
    }
    /**
*————————————————————————————————————————————————————
* @Name: processSupervisor
* @Description
* Updates the Obtains and adds the Supervisor to the record assuming it is
* on the beforeInsert or beforeUpdate portion of the trigger. 
*————————————————————————————————————————————————————
* @param    theErsList   List of Inserted or Updated EmployeeResultSummary records 
* @return   String       Error message
*————————————————————————————————————————————————————
**/ 
    public static String processSupervisor(List<EmployeeResultSummary__c> theErsList) {
        system.debug('HELPER RevSys_EmployeeResultSummaryHelper processSupervisor-Start');
        
        String myErrorMessage; 
        
        Set  <Id> myContactIdSet  = new Set<Id>();  
        List <Id> myContactIdList = new List<Id>();
        
        // Gather the Employee (Contact) Ids in the trigger list 
        for(EmployeeResultSummary__c theErs :theErsList)
        {
            myContactIdSet.add(theErs.Employee__c); 
        }
        
        // Transfer the set to a list for further processing
        myContactIdList.addAll(myContactIdSet); 
        
        // Get a map of Supervisors by Employee 
        Map<Id,Id> supervisorByEmployeeMap = new Map<Id,Id>(); 
        supervisorByEmployeeMap = RevSys_SupervisorManagerHelper.retrieveSupervisorId(myContactIdList); 
        if(!supervisorByEmployeeMap.isEmpty()){
            // Roll through the input list from the trigger and assign supervisors 
            for(EmployeeResultSummary__c theErs :theErsList)
            {
                if(supervisorByEmployeeMap.containsKey(theErs.Employee__c)){
                    Id mySupervisorId = supervisorByEmployeeMap.get(theErs.Employee__c); 
                    
                    if(mySupervisorId != null) {
                        theErs.Supervisor__c = mySupervisorId; 
                    }  
                }
                
            }
        }
        
        system.debug('HELPER RevSys_EmployeeResultSummaryHelper processSupervisor-End');
        return null;
    }
    /**
*————————————————————————————————————————————————————
* @Name: processNurse
* @Description
* Generates a map of contacts with observation mapping to the current login user
*————————————————————————————————————————————————————
* @param    theErsList   List of Inserted or Updated EmployeeResultSummary records 
* @return   String       Error message
*————————————————————————————————————————————————————
*
    public static String processNurse(List<EmployeeResultSummary__c> theErsList) 
    {
        system.debug('HELPER RevSys_EmployeeResultSummaryHelper processNurse-Start');  
        system.debug('theErsList ' + theErsList); 
        String ErrMsg = null;                   
        List<Contact> ContactIdList        = new List<Contact>();
        Set<String> myUserEmployeeNumberList = new Set<String>();
        List<User> UserList = new List<User>();   
        List<Observation__c> lstObservation = new List<Observation__c>();
        
        // Get the current user 
        
        SelectorWrapper wrapper = UserSelector.getUsers(new Set<Id>{UserInfo.getUserId()});
        
        // Add the employee number to a list 
        
        if(wrapper!=null) {
            UserList = wrapper.SObjectList;
            for(User Us : UserList) {
                if((Us.EmployeeNumber)!= null){                    
                    Integer tmp = Integer.valueOf(Us.EmployeeNumber);
                    myUserEmployeeNumberList.add(String.valueOf(tmp));
                }               
            }            
        }
        
        // Get Contacts by using the Employee Number List
        // ~ Remember - We're only going after the current user, so we're going 
        //   to return a list of 1 record.
        
        SelectorWrapper contactwrapper = ContactSelector.getContactsBySAPId(myUserEmployeeNumberList);            
        
        if(contactwrapper!=null){
            ContactIdList = (List<Contact>)contactwrapper.SObjectList;
            if(contactIdList.size()>0){
                
                for(EmployeeResultSummary__c theErs :theErsList) {                
                    if(theErs.HealthServicesNurse__c == null   && 
                       theErs.RecordTypeId == RevSys_StaticUtility.EMP_RES_SUMM_MEDICAL_RECTYPE_ID) {  
                           
                           theErs.HealthServicesNurse__c = ContactIdList[0].Id;
                       }    
                }         
            }
        }      
        
        
        
        system.debug('HELPER RevSys_EmployeeResultSummaryHelper processNurse-End');     
        return ErrMsg;  
    }*/
    
    /**
*————————————————————————————————————————————————————
* @Name: autoPopulateFields
* @Author : Padmini
* @Description
*  Automatically assigns the right Status value to the field based on the input
*————————————————————————————————————————————————————
* @param    theNewEmpCertList   List of Inserted or Updated 
EmployeeResultSummary records 
* @return   String   
*————————————————————————————————————————————————————
**/
    
    public static String autoPopulateFields (List<EmployeeResultSummary__c> theErsList){
        
        for(EmployeeResultSummary__c ers :theErsList)
        {
            
            //logic for ETR-609
            if(ers.RecordTypeId == RevSys_StaticUtility.EMP_RES_SUMM_MOTORVEHICLE_RECTYPE_ID &&
               (ers.ClassOfService__c == Label.RevSys_ClassOfService_TrainServiceEngineer || ers.ClassOfService__c == Label.RevSys_ClassOfService_LocomotiveServicingEngineer 
                || ers.ClassOfService__c == Label.RevSys_ClassOfService_StudentEngineer || ers.ClassOfService__c == Label.RevSys_ClassOfService_TrainServiceEngineerMechanicalFacility 
                || ers.ClassOfService__c == Label.RevSys_ClassOfService_StudentEngineerMechanicalFacility) && 
               ers.StateReviewDate__c != NULL){
                   if(ers.NdrReviewDate__c != NULL){
                       if(ers.AlcoholOrDrugViolationRevealed__c == true){
                           if(ers.EapEvaluationDate__c != NULL && ers.Status__c == 'Fail'){
                               ers.Status__c = 'Pass';
                           }
                       }
                       else{
                           ers.Status__c = 'Pass';
                       }
                   }
                   else{
                       ers.Status__c = 'Pending';
                   }
               }
            
            //logic for ETR-610
            
            if( ers.RecordTypeId == RevSys_StaticUtility.EMP_RES_SUMM_MOTORVEHICLE_RECTYPE_ID &&
               (ers.ClassOfService__c == Label.RevSys_ClassOfService_Conductor || ers.ClassOfService__c == Label.RevSys_ClassOfService_PassengerConductor 
                || ers.ClassOfService__c == Label.RevSys_ClassOfService_AssistantConductor) && ers.StateReviewDate__c != NULL)
            {
                if(ers.AlcoholOrDrugViolationRevealed__c == true){ 
                    if(ers.EapEvaluationDate__c != NULL && ers.Status__c == 'Fail')
                    {
                        ers.Status__c = 'Pass';
                    }
                }
                else{
                    ers.Status__c = 'Pass';
                }
            }
            
            //Logic for ETR-737
            //When Substance Abuse is checked then Status__c should be 'Fail'
            if(ers.RecordTypeId == RevSys_StaticUtility.EMP_RES_SUMM_MOTORVEHICLE_RECTYPE_ID &&
               ers.SubstanceAbuseDisorderDetermined__c == True)
            {
                ers.Status__c = Label.RevSys_Generic_Fail;
            }
        }
        return null;
    }
    /**
*————————————————————————————————————————————————————
* @Name: updateHealthServices
* @Author : Raj Pandy
* @Description
*  Automatically assigns the Health Services information on the medical form 
*————————————————————————————————————————————————————
* @param    esrList   List of Inserted or Updated EmployeeResultSummary records
* @return   String   
*————————————————————————————————————————————————————
**/ 
    public static String updateHealthServices(List<EmployeeResultSummary__c> esrList){
        
        List<EmployeeResultSummary__c> esrMedList = new List<EmployeeResultSummary__c>();
        List<Contact> ContactList = new List<Contact>();
        Set<String> myUserEmployeeNumber = new Set<String>();
        List<User> UserList = new List<User>();   
        
        system.debug('HELPER RevSys_EmployeeResultSummaryHelper updateHealthServices-Start');
        
        for(EmployeeResultSummary__c esrObj : esrList)
        {
            if(esrObj.RecordTypeId == RevSys_StaticUtility.EMP_RES_SUMM_MEDICAL_RECTYPE_ID )
                esrMedList.add(esrObj);
        }
        
        if(esrMedList.size()>0)
        { 
            SelectorWrapper wrapper = UserSelector.getUsers(new Set<Id>{UserInfo.getUserId()});
            
            if(wrapper!=null) {
                UserList = (List<User>)wrapper.SObjectList;
                for(User Us : UserList) {
                    if((Us.EmployeeNumber)!= null){
                        Integer tmp = Integer.valueOf(Us.EmployeeNumber);
                        myUserEmployeeNumber.add(String.valueOf(tmp));
                    }               
                }            
            }
            system.debug('The set is'+myUserEmployeeNumber);
            SelectorWrapper contactwrapper = ContactSelector.getContactsBySAPId(myUserEmployeeNumber);
            if(contactwrapper!=null){
                ContactList = (List<Contact>)contactwrapper.SObjectList;
                system.debug('Successsssssssssssssssss');
                if(contactList.size()>0){
                    for(EmployeeResultSummary__c tempEsrObj : esrMedList)
                    {
                        tempEsrObj.HealthServicesNurse__c = contactList[0].id;
                    }
                }
            }
        }
        
        system.debug('HELPER RevSys_EmployeeResultSummaryHelper updateHealthServices-End');
        
        return null;
    }
}
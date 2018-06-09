/**
*___________________________________________________
*@Name: RevSys_OccupationCertificationHelper
*@Author: Raj Kumar Pandy
*@Created: Date: 11/21/2017
*@Used_By: Review Systems
*___________________________________________________
*@Description: Inactivates the associated child records for the parent
* Holds generic helper methods for the Observation object relevent to the Review Systems application
* 
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
* 05-30-2018 Change to the supervisor targets method. 
**/

global with sharing class RevSys_OccupationCertificationHelper {
    
    /**
    *————————————————————————————————————————————————————
    * @Name: deactivateChild()
    * @Description
    * Culls Occupation Certification records that have status as Inactive as per their record type
    *————————————————————————————————————————————————————
    * @param    theNewObsList   List of Occupation Certification records, generally from the trigger
    * @return   String          Error message
    *————————————————————————————————————————————————————
    **/ 
    public static String deactivateChild(List<OccupationCertification__c> theNewOccCertsList)
    {
        system.debug('HELPER RevSys_OccupationCertificationHelper deactivateChild-Start');     
        //Initialising the variables
        string errMsg;
        
        Set<ID> inactveOccCertSet = new Set<ID>();
        Set<ID> inactveEmpSpecRequirmentsSet = new Set<ID>();
        //Loop on Occupation Certifications
        for(OccupationCertification__c tempOccCert : theNewOccCertsList)
            {
                //Picking the inactive records
                if(tempOccCert.Status__c == RevSys_StaticUtility.INACTIVE)
                {
                    //For Targets adding to the Employee Specific requirements list
                    if(tempOccCert.RecordTypeId == RevSys_StaticUtility.OCCUPCERTIFICATION_SPARTNTARGET_RECTYPE_ID)
                    {
                       inactveEmpSpecRequirmentsSet.add(tempOccCert.id);
                    }
                    //For Certification records adding it to the Occupation Certification List
                    else if(tempOccCert.RecordTypeId == RevSys_StaticUtility.OCCUPCERTIFICATION_SPARTNCERT_RECTYPE_ID)
                    {
                        inactveOccCertSet.add(tempOccCert.id);
                    }
                    
                }
            } 
        if(inactveOccCertSet.size() > 0)
        {
            errMsg = deactivateEmpCertificationChild(inactveOccCertSet);//Calling the method to deactivate Employee Certifcations
        }
        if(inactveEmpSpecRequirmentsSet.size() > 0)
        {
            errMsg = deactivateEmployeeSpecRequirementsChild(inactveEmpSpecRequirmentsSet);//Calling the method to deactivate Employee Specific Requirements
        }
        
        system.debug('HELPER RevSys_OccupationCertificationHelper deactivateChild-End'); 
        return errMsg;
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Name: deactivateEmpCertificationChild()
    * @Description
    * Fetches the associated Employee Certification child records and updates them
    *————————————————————————————————————————————————————
    * @param    inactiveOccCertSet  Set of inactive Occupation Certification records. Called from deactivateChild() method
    * @return   Void                Nothing
    *————————————————————————————————————————————————————
    **/ 
    public static string deactivateEmpCertificationChild(Set<ID> inactiveOccCertSet)
    {
        system.debug('HELPER RevSys_OccupationCertificationHelper deactivateEmpCertificationChild-Start');     
        
        string errMsg;
        
        List<EmployeeCertification__c> empCertificationList = new List<EmployeeCertification__c>();
        List<EmployeeCertification__c> empCertificationUpdateList = new List<EmployeeCertification__c>();
        
        //Query to fecth the Employee Certifications based on the Occupation certification Ids
        SelectorWrapper wrapper = EmployeeCertificationSelector.getOccCertRelated(inactiveOccCertSet);
        
        empCertificationList = (List<EmployeeCertification__c>)wrapper.SobjectList;
        
        //Loop on Employee Certifications
        for(EmployeeCertification__c tempEmpCertification : empCertificationList)
        {
            tempEmpCertification.Status__c = RevSys_StaticUtility.EXPIRED;//Update the Status to Expired 
            tempEmpCertification.ProcessFlag__c = System.Label.RevSys_EmpCert_ProcessFlag;
            empCertificationUpdateList.add(tempEmpCertification);
        }
        
        errMsg = DmlHelper.updateList(empCertificationUpdateList);
        
        system.debug('HELPER RevSys_OccupationCertificationHelper deactivateEmpCertificationChild-End'); 
        return errMsg;
    
    }


/**
    *————————————————————————————————————————————————————
    * @Name: deactivateEmpCertificationChild()
    * @Description
    * Fetches the associated Employee Specific Requirement child records and updates them
    *————————————————————————————————————————————————————
    * @param    inactiveOccESRSet   Set of inactive Occupation Target records. Called from deactivateChild() method
    * @return   Void                Nothing
    *————————————————————————————————————————————————————
    **/ 
    public static string deactivateEmployeeSpecRequirementsChild(Set<ID> empSpecRequirementsList)
    {
        system.debug('HELPER RevSys_OccupationCertificationHelper deactivateEmployeeSpecRequirementsChild-Start');     
        
        string errMsg;
        
        List<EmployeeSpecificRequirement__c> InactiveempSpecRequirementsList = new List<EmployeeSpecificRequirement__c>();
        List<EmployeeSpecificRequirement__c> InactiveempSpecRequirementsUpdateList = new List<EmployeeSpecificRequirement__c>();
        
        //Query to fetch Employee Specific Requirements based on the Ids
        SelectorWrapper wrapper = EmployeeSpecificRequirementSelector.getOccEmpSpecRequirementsRelated(empSpecRequirementsList);
        
        InactiveempSpecRequirementsList = (List<EmployeeSpecificRequirement__c>)wrapper.SobjectList;
        
        for(EmployeeSpecificRequirement__c tempEmpCertification : InactiveempSpecRequirementsList)
        {
            tempEmpCertification.Status__c = RevSys_StaticUtility.INACTIVE;//Updating the Status to Inactive
            InactiveempSpecRequirementsUpdateList.add(tempEmpCertification);
        }
        
        errMsg = DmlHelper.updateList(InactiveempSpecRequirementsUpdateList);//Updating the records using the DmlHelper class
        
        system.debug('HELPER RevSys_OccupationCertificationHelper deactivateEmployeeSpecRequirementsChild-End'); 
        return errMsg;
    
    }


    
    /**
    *————————————————————————————————————————————————————
    * @Name: createCertificationTargets()
    * @Description
    *  Creates ESR based on the Certificate targets defined in Occupation Certification object
    *————————————————————————————————————————————————————
    * @param    newOccCerList   List of records related to Occupation Certification after update
    *           oldOccCertMap   Map of Id and Occupation Certification record before update
    * @return   String          Returns string if error
    *————————————————————————————————————————————————————
    **/ 
    public static String createCertificationTargets(List<OccupationCertification__c> newOccCerList) {
        system.debug('HANDLER RevSys_OccupationCertificationHelper createCertificationTargets OnAfterInsert-Start'); 
        //Initialising the variables 
        String errMsg;
        Set<Id> myTargetIdSet = new Set<Id>();
        Set<Id> myParentCertIdSet = new Set<Id>();
        Map<Id,List<Id>> myEmpIdListByCertIdMap = new Map<Id,List<Id>>();
        List<OccupationCertification__c> myCertTargetList  = new List<OccupationCertification__c>();
        List<EmployeeSpecificRequirement__c> myEsrToInsertList = new List<EmployeeSpecificRequirement__c>();
        Map<id,Contact> contactMap = new Map<Id,Contact>();
        Set<Id> contactList = new Set<Id>();


        if(newOccCerList!=null) {
            //loop on Occupation Certifications
            for(OccupationCertification__c occCertification : newOccCerList) {
                //Condition to check for records of Target record type and also Active ones with Target type as Certification
                if(occCertification.RecordTypeId==RevSys_StaticUtility.OCC_CERT_SPARTNTARGET_RECTYPE_ID &&
                    occCertification.Status__c==RevSys_StaticUtility.ACTIVE &&
                    occCertification.TargetType__c==RevSys_StaticUtility.CERTIFICATION) {
                    myTargetIdSet.add(occCertification.Id);
                    if(occCertification.ParentCertification__c!=null) {
                        myParentCertIdSet.add(occCertification.ParentCertification__c);
                        myCertTargetList.add(occCertification);
                    }
                }
            }
        }

        if(!myParentCertIdSet.isEmpty()) {
            //Query to fecth Active Employee Certification records based on the Parent Certification Ids
            SelectorWrapper wrapper = EmployeeCertificationSelector.getActiveEmpCert(myParentCertIdSet);
            if(wrapper!=null) {
                //Loop on Employee Certification to create myEmpIdListByCertIdMap
                for(EmployeeCertification__c ec : (List<EmployeeCertification__c>)wrapper.SobjectList) {
                    contactList.add(ec.Employee__c);
                    if(myEmpIdListByCertIdMap.containsKey(ec.Certification__c)) {
                        myEmpIdListByCertIdMap.get(ec.Certification__c).add(ec.Employee__c);//when the key value already exists
                    } else {
                        myEmpIdListByCertIdMap.put(ec.Certification__c,new List<Id>{ec.Employee__c});//when the key does not exists
                    }
                }
            }
        }



        if(!myEmpIdListByCertIdMap.isEmpty()) {
            SelectorWrapper wrapper = ContactSelector.getContacts(contactList);
            if(wrapper!=null && String.isBlank(wrapper.ErrorMessage)) {
                for(Contact con : (List<Contact>) wrapper.SobjectList) {
                    if(String.isNotBlank(con.Employment_Status__c) && (con.Employment_Status__c).equalsIgnorecase(RevSys_StaticUtility.ACTIVE)) {
                        contactMap.put(con.Id,con);
                    }
                }
            }
        }

        //Check whether the Target list, Employee id map, Occupation Specific Requirement are empty
        if(!myCertTargetList.isEmpty() && !myEmpIdListByCertIdMap.isEmpty() && !contactMap.isEmpty()) {
            System.debug('*** myCertTargetList ' + myCertTargetList);
            //Loop to fetch the List of Occupation Specific Requirements and Employees based on the Certification Id
            for(OccupationCertification__c ocRecord : myCertTargetList) {
                List<Id> empIdList ;
               //Fetch the Employee id list based on the Certification id
                if(myEmpIdListByCertIdMap.containsKey(ocRecord.ParentCertification__c)) {
                    empIdList = myEmpIdListByCertIdMap.get(ocRecord.ParentCertification__c);
                }
                System.debug('*** empIdList ' + empIdList); 
                //Loop on the Employee id list
                for(Id empId : empIdList) {
                    if(contactMap.containsKey(empId)) {
                        Contact con = contactMap.get(empId);
                        if(String.isNotBlank(con.Department) && (con.Department==ocRecord.Department__c)) {
                           //Create ESR for each target defined for the employee
                            EmployeeSpecificRequirement__c esrObj =  new EmployeeSpecificRequirement__c();
                            esrObj.RecordTypeId     = RevSys_StaticUtility.EMP_SPEC_REQ_SPARTNTARGET_RECTYPE_ID;
                            esrObj.EmployeeTarget__c = con.Id;
                            esrObj.Employee__c      = con.Id;
                            esrObj.Target__c        = ocRecord.Id;
                            Boolean canBeApplied = RevSys_StartTarget.checkTargetPeriod(System.Date.today(),ocRecord.Frequency__c);
                            if(canBeApplied)
                            {
                                esrObj.StartDate__c    = Amtrak_DateUtility.determineThisStartDate(ocRecord.Frequency__c,System.Date.today());
                                esrObj.EndDate__c      = Amtrak_DateUtility.determineThisEndDate(ocRecord.Frequency__c, System.Date.today());
                                esrObj.PeriodName__c   = Amtrak_DateUtility.determineThisPeriod(ocRecord.Frequency__c, System.Date.today());
                            }
                            else
                            {
                                esrObj.StartDate__c    = Amtrak_DateUtility.determineNextStartDate(ocRecord.Frequency__c,System.Date.today());
                                esrObj.EndDate__c      = Amtrak_DateUtility.determineNextEndDate(ocRecord.Frequency__c, System.Date.today());
                                esrObj.PeriodName__c   = Amtrak_DateUtility.determineNextPeriod(ocRecord.Frequency__c, System.Date.today());
                            }
                            esrObj.TotalRequired__c = ocRecord.NumberOfTestsPerPeriod__c;
                            esrObj.Status__c        = RevSys_StaticUtility.ACTIVE;
                            myEsrToInsertList.add(esrObj);
                        }
                    }
                }
            }
        }


        if(!myEsrToInsertList.isEmpty()) {
            errMsg = DmlHelper.insertList(myEsrToInsertList);//Insert Employee Specific Requirements using DmlHelper Class
        }


        system.debug('HANDLER RevSys_OccupationCertificationHelper createCertificationTargets OnAfterInsert-END'); 
        return errMsg;

    }
    
     /**
    *————————————————————————————————————————————————————
    * @Name: createSupervisorTargets()
    * @Description
    *  Creates ESR based on the Supervisor targets defined in Occupation Certification object
    *————————————————————————————————————————————————————
    * @param    newOccCerList   List of records related to Occupation Certification after update
    *           oldOccCertMap   Map of Id and Occupation Certification record before update
    * @return   String          Returns string if error
    *————————————————————————————————————————————————————
    **/ 
    public static String createSupervisorTargets(List<OccupationCertification__c> newOccCerList) {
        system.debug('HANDLER RevSys_OccupationCertificationHelper createSupervisorTargets OnAfterInsert-Start'); 
        //Intialising the variables
        String errMsg;
        
        Set<String> myDeptSet = new Set<String>();
        //Set<String> myCraftSet = new Set<String>();
        List<OccupationCertification__c> targetsToProcess = new List<OccupationCertification__c>();
        Set<Id> supervisedContacts = new Set<Id>();
        Map<Id,Contact> contactIdMap = new Map<Id,Contact>();
       List<Contact> supervisorContacts  = new List<Contact>();

       //05/30
       List<OccupationCertification__c> divisionTargets =  new List<OccupationCertification__c>();



        //Loop to create myDeptSet and myCraftSet
        for(OccupationCertification__c occCertObj : newOccCerList)
        {   

           if(occCertObj.RecordTypeId == RevSys_StaticUtility.OCCUPCERTIFICATION_SPARTNTARGET_RECTYPE_ID && 
            occCertObj.Status__c == RevSys_StaticUtility.ACTIVE &&
            occCertObj.TargetType__c == RevSys_StaticUtility.SUPERVISOR) {
                if(String.isBlank(occCertObj.DivisionOfObservation__c)) {
                    myDeptSet.add(occCertObj.Department__c);
                    //myCraftSet.add(tempOccCertObj.Craft__c);
                    targetsToProcess.add(occCertObj);
                } else {
                    divisionTargets.add(occCertObj);
                }

            }
        }
        
        //Condition to check whether the containers are empty..
        //Applicable only when there are no division targets
        if(!myDeptSet.isEmpty())
        {
            System.debug('-----------------DeptSet '+myDeptSet);
            //Query to fecth the employees based on Department and Craft
            SelectorWrapper wrapper = ContactSelector.getContactsByDept(myDeptSet);
            if(wrapper!=null)
            {
                List<Contact> contactList = (List<Contact>)wrapper.SobjectList;
                System.debug('50 '+contactList);
                //Loop to create contactIdMap
                for(Contact employee : contactList) {
                   contactIdMap.put(employee.Id,employee);
                }
                if(!contactIdMap.isEmpty()) {
                    //Query to fecth the Employee Certifications based on the Ids
                    SelectorWrapper ecWrapper = EmployeeCertificationSelector.getSupervisorEmpCert(contactIdMap.keySet());
                    if(ecWrapper!=null) {
                        //Loop to create supervisedContacts
                        for(EmployeeCertification__c ec : (List<EmployeeCertification__c>)ecWrapper.SobjectList) {
                            supervisedContacts.add(ec.Employee__c);
                        }
                    }
                }
            }
        }

        if(!supervisedContacts.isEmpty()) {
           for(Id supervisorId : supervisedContacts) {
                if(contactIdMap.containsKey(supervisorId)) {
                    supervisorContacts.add(contactIdMap.get(supervisorId));
                }
           }
        }
        if(!supervisorContacts.isEmpty() && !targetsToProcess.isEmpty()) {
            //Calling RevSys_EstablishTargetHelper to establish the targets
            errMsg = RevSys_EstablishTargetHelper.establistTargetsFromOccCert(supervisorContacts,targetsToProcess, RevSys_StaticUtility.SUPERVISOR);
        }

        //Process Division Targets
        if(!divisionTargets.isEmpty()) {
           errMsg += RevSys_EstablishTargetHelper.processAsDivisionTargets(divisionTargets);
        }

        
        system.debug('HANDLER RevSys_OccupationCertificationHelper createSupervisorTargets OnAfterInsert-END');
        return errMsg;
    }

    /**
    *————————————————————————————————————————————————————
    * @Name: updateTargetEmployees()
    * @Description
    *  Creates ESR based on the Supervisor targets defined in Occupation Certification object
    *————————————————————————————————————————————————————
    * @param    newOccCerList   List of records related to Occupation Certification after update
    * @return   String          Returns string if error
    *————————————————————————————————————————————————————
    **/
    public static String updateTargetEmployees(List<OccupationCertification__c> newOccCerList) {
        system.debug('HANDLER RevSys_OccupationCertificationHelper updateTargetEmployees OnAfterInsert-Start'); 
        //Intialising the variables
        String errMsg;
        
        Set<String> myDeptSet = new Set<String>();
        //Set<String> myCraftSet = new Set<String>();
        List<OccupationCertification__c> targetsToProcess = new List<OccupationCertification__c>();
        
        //Loop to create myDeptSet and myCraftSet
        for(OccupationCertification__c tempOccCertObj : newOccCerList)
        {
            if(tempOccCertObj.RecordTypeId == RevSys_StaticUtility.OCCUPCERTIFICATION_SPARTNTARGET_RECTYPE_ID &&
               tempOccCertObj.TargetType__c == RevSys_StaticUtility.OCCUPATION &&
               tempOccCertObj.Status__c == RevSys_StaticUtility.ACTIVE)
            {
                myDeptSet.add(tempOccCertObj.Department__c);
                //myCraftSet.add(tempOccCertObj.Craft__c);
                targetsToProcess.add(tempOccCertObj);
            }
        }
        
        //Condition to check whether the containers are empty
        if(!myDeptSet.isEmpty())
        {
            //Query to fecth the employees based on Department and Craft
            SelectorWrapper wrapper = ContactSelector.getContactsByDept(myDeptSet);
            if(wrapper!=null)
            {
                //Calling RevSys_EstablishTargetHelper to establish the targets
                errMsg = RevSys_EstablishTargetHelper.establistTargetsFromOccCert((List<Contact>)wrapper.SobjectList,targetsToProcess, RevSys_StaticUtility.OCCUPATION);
            }
        }
        
        system.debug('HANDLER RevSys_OccupationCertificationHelper updateTargetEmployees OnAfterInsert-END');
        return errMsg;
    }
}
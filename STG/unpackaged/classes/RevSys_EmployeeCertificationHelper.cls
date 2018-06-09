/**
*___________________________________________________
*@Name: RevSys_EmployeeCertificationHelper
*@Author: Raj Kumar Pandy
*@Created: Date: 12/4/2017
*@Used_By: Review Systems
*___________________________________________________
*@Description: Creates the Employee Specific Requirements based on the Occupation Specific Requirement
* 
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
* 1-22-2018 [Abhishek]  Added populateEmployeeSupervisor to update Employee's supervisor on Employee Certification
* 3-6-2018  [Hemanth]   Added createEmployeeCertificationHistory method to create History records with Archived=true
* 4-20-2018 [cwalley]   Added method - checkIfReadyForArchival
**/

global with sharing class RevSys_EmployeeCertificationHelper {
    
    /**
*————————————————————————————————————————————————————
* @Name: createEmpSpecRequirement()
* @Description
* Creates Employee Specific Requirement records based on the Occupation Certification
*————————————————————————————————————————————————————
* @param    theNewEmpCertList   List of Employee Certification records, generally from the trigger
* @return   String          Error message
*————————————————————————————————————————————————————
**/ 
    public static String createEmpSpecRequirement(List<EmployeeCertification__c> theNewEmpCertsList)
    {
        String errMsg; //The return string
        
        //Declaring and intialising the container variables
        Set<ID> occCertSet = new Set<ID>();
        List<OccupationSpecificRequirement__c> occSpecReqList = new List<OccupationSpecificRequirement__c>();
        Map<ID, List<OccupationSpecificRequirement__c>> occCertOccSpecReqMap = new Map<ID, List<OccupationSpecificRequirement__c>>();
        
        List<EmployeeSpecificRequirement__c> empSpecReqMasterList = new List<EmployeeSpecificRequirement__c>();
        
        system.debug('HELPER RevSys_EmployeeCertificationHelper createEmpSpecRequirement-Start');    
        
        //Looping to get the Certification ids
        for(EmployeeCertification__c tempEmpCertObj : theNewEmpCertsList)
        { 
            if(tempEmpCertObj.RecordTypeId == RevSys_StaticUtility.EMPCERT_SPARTNCERT_RECTYPE_ID) {
                if(tempEmpCertObj.Status__c== RevSys_StaticUtility.PENDING)
                    occCertSet.add(tempEmpCertObj.Certification__c);
            }
        }
        
        //Returning the OccupationSpecificRequirements based on the Occupation certification ids
        SelectorWrapper wrapper = OccupationSpecificRequirementSelector.getOccSpecReqCertification(occCertSet);
        if(wrapper!=null) {
            occSpecReqList = (List<OccupationSpecificRequirement__c>)wrapper.SobjectList;
        }
        
        //Looping to create the occCertOccSpecReqMap
        for(OccupationSpecificRequirement__c tempOccSpecReqObj : occSpecReqList)
        {
            if(occCertOccSpecReqMap.containsKey(tempOccSpecReqObj.Certification__c))
            {
                occCertOccSpecReqMap.get(tempOccSpecReqObj.Certification__c).add(tempOccSpecReqObj);//When the Key already exists
            }
            else
            {
                occCertOccSpecReqMap.put(tempOccSpecReqObj.Certification__c,  new List<OccupationSpecificRequirement__c>{tempOccSpecReqObj});
            }
        }
        
        List<EmployeeSpecificRequirement__c> empSpecReqSubList = new List<EmployeeSpecificRequirement__c>();
        
        //Loop to check if the employee Certification has any EmployeeSpecificRequirements
        for(EmployeeCertification__c tempEmpCerObj : theNewEmpCertsList)
        {
            if(tempEmpCerObj.RecordTypeId == RevSys_StaticUtility.EMPCERT_SPARTNCERT_RECTYPE_ID && tempEmpCerObj.Status__c==RevSys_StaticUtility.PENDING) {
                empSpecReqSubList = mapEmpSpecReq(tempEmpCerObj, occCertOccSpecReqMap.get(tempEmpCerObj.Certification__c));
                if(!empSpecReqSubList.isEmpty())
                    empSpecReqMasterList.addAll(empSpecReqSubList);
                else
                    errMsg = Label.Revsys_Certification_does_not_have_any_Occupation_Specific_Requirements_defined; //Custom error message to be displayed when there are requirements pending
            }
        } 
        //Inserting the Employee Specific Requirements using the DMLHelper Class
        if(empSpecReqMasterList.size()!=0) {

            // Update dates with existing ESR records [ETR-1054]
            SelectorWrapper myWrap = Revsys_EmpSpecReqHelper.updateNewEsrWithExistingInfo(empSpecReqMasterList); 

            errMsg = myWrap.ErrorMessage; 
            if(ErrMsg == null) {

                empSpecReqMasterList = myWrap.SObjectList; 

                errMsg = DmlHelper.insertList(empSpecReqMasterList);
            }
        }
        
        system.debug('HELPER RevSys_EmployeeCertificationHelper createEmpSpecRequirement-End');
        
        return errMsg;
    }
    /**
*————————————————————————————————————————————————————
* @Name: mapEmpSpecReq()
* @Description
* Initiates Employee Specific Requirement records based on the Occupation Certification
*————————————————————————————————————————————————————
* @param    empCertObj                              Employee Certification record, generally from the trigger
* @param    occSpecReqList                          List of Occupation Specific Requirement records
* @return   List<EmployeeSpecificRequirement__c>    List of Employee specific requirement records
*————————————————————————————————————————————————————
**/ 
    public static List<EmployeeSpecificRequirement__c> mapEmpSpecReq(EmployeeCertification__c empCertObj, List<OccupationSpecificRequirement__c> occSpecReqList)
    {
        system.debug('HELPER RevSys_EmployeeCertificationHelper createEmpSpecReq-Start');
        //Initialising the container variables 
        List<EmployeeSpecificRequirement__c> empSpecReqList = new List<EmployeeSpecificRequirement__c>();
        
        Set<ID> reqSet = new Set<ID>();
        
        //Creating EmployeeSpecificRequirements based on the OccupationSpecificRequirements
        if(occSpecReqList!=null) {
            for(OccupationSpecificRequirement__c tempOccSpecReqObj : occSpecReqList)
            {
                EmployeeSpecificRequirement__c empSpecReqObj = new EmployeeSpecificRequirement__c();
                empSpecReqObj.RecordTypeId = RevSys_StaticUtility.EMPSPECREQUIREMENT_SPARTNCERT_RECTYPE_ID;
                empSpecReqObj.Employee__c = empCertObj.Employee__c;
                empSpecReqObj.OccupationSpecificRequirement__c = tempOccSpecReqObj.id;
                empSpecReqObj.EmployeeCertification__c = empCertObj.Id;
                empSpecReqObj.Requirement__c = tempOccSpecReqObj.Requirement__c;
                empSpecReqObj.Certification__c = tempOccSpecReqObj.Certification__c;
                empSpecReqObj.Status__c = RevSys_StaticUtility.ACTIVE;
                empSpecReqObj.ReportStatus__c = Label.RevSys_Generic_Pending;
                empSpecReqList.add(empSpecReqObj);
            }
        }
        
        system.debug('HELPER RevSys_EmployeeCertificationHelper createEmpSpecReq-End');
        
        return empSpecReqList;
        
    }
    
    
    // Wrapper class to tie Occupation specific requirement and earliest date
    public class OccupationSpecificRequriementWrapper {
        public OccupationSpecificRequirement__c oscrequirements {get; set;}
        public Date earliestDate { get; set;}
        public OccupationSpecificRequriementWrapper( OccupationSpecificRequirement__c oscrequirements,Date earliestDate ){
            this.oscrequirements=oscrequirements;
            this.earliestDate = earliestDate;
        }
        
    }


    /**
*————————————————————————————————————————————————————
* @Name: createCertificationTargets
* @Description
*  Creates ESR based on the Certificate targets defined in Occupation Certification object 
*  and when EC gets created
*————————————————————————————————————————————————————
* @param    newEmpCertList  List of records related to Employee Certification
*           oldEmpCertMap   Map of Id and Employee Certification record before update
* @return   String          Returns string if error
*————————————————————————————————————————————————————
**/
    //Cannot have the old map becuase of Employee Certificaion History. EC records are now "Inserted" as current
    //public static String createCertificationTargets(List<EmployeeCertification__c> newEmpCertList,Map<Id,EmployeeCertification__c> oldCertMap) {
    public static String createCertificationTargets(List<EmployeeCertification__c> newEmpCertList) {
         system.debug('HELPER RevSys_EmployeeCertificationHelper createCertificationTargets-Start');
        //Initialising the Container variables
        String errmsg;
        Set<Id> myTargetIdSet = new Set<Id>();
        Set<Id> myCertIdSet = new Set<Id>();
        Map<Id,List<OccupationCertification__c>> mycertTargetMap = new Map<Id,List<OccupationCertification__c>>();
        Map<Id,List<OccupationSpecificRequirement__c>> myOsrListByTargetIdMap = new  Map<Id,List<OccupationSpecificRequirement__c>>();
        List<EmployeeSpecificRequirement__c> myEsrToInsertList = new List<EmployeeSpecificRequirement__c>();
        List<EmployeeCertification__c> myProcessingList = new List<EmployeeCertification__c>();
        Set<Id> contactIdSet = new Set<Id>();
        List<Contact> contactList = new List<Contact>();
        Map<Id,Contact> contactIdMap = new Map<Id,Contact>();
        
        
        if(newEmpCertList!=null) {
            //Looping on Employee Certification to fetch the Certification Ids
            for(EmployeeCertification__c ecObj : newEmpCertList) {
                //String oldStatus = oldCertMap.get(ecObj.Id).Status__c;
                /*if(ecObj.RecordTypeId == RevSys_StaticUtility.EMPCERT_SPARTNCERT_RECTYPE_ID && 
                   (String.isNotBlank(ecObj.Status__c) && ecObj.Status__c.equalsIgnoreCase(RevSys_StaticUtility.CURRENT) && 
                    String.isNotBlank(oldStatus) && oldStatus.equalsIgnoreCase(RevSys_StaticUtility.PENDING))) {
                        myCertIdSet.add(ecObj.Certification__c);//Certification Id
                        myProcessingList.add(ecObj);//Employee Certification Id
                        contactIdSet.add(ecObj.Employee__c);
                    }*/
                if(ecObj.RecordTypeId == RevSys_StaticUtility.EMPCERT_SPARTNCERT_RECTYPE_ID && 
                   (String.isNotBlank(ecObj.Status__c) && ecObj.Status__c.equalsIgnoreCase(RevSys_StaticUtility.CURRENT))) {
                        myCertIdSet.add(ecObj.Certification__c);//Certification Id
                        myProcessingList.add(ecObj);//Employee Certification Id
                        contactIdSet.add(ecObj.Employee__c);
                }
            }
        }
        
        if(!myCertIdSet.isEmpty()) {
            //Query to fecth the Occupation Certification based on Certification Ids
            SelectorWrapper wrapper = OccupationCertificationSelector.getCertificationTargets(myCertIdSet);
            if(wrapper!=null) {
                //Loop to process the fetched Occupation Certification records
                for(OccupationCertification__c ocRec : (List<OccupationCertification__c>) wrapper.SobjectList) {
                    myTargetIdSet.add(ocRec.Id);
                    if(mycertTargetMap.containsKey(ocRec.ParentCertification__c)) {
                        mycertTargetMap.get(ocRec.ParentCertification__c).add(ocRec);//When the Key value already exists
                    } else {
                        mycertTargetMap.put(ocRec.ParentCertification__c, new List<OccupationCertification__c>{ocRec});
                    }
                }
            }
            
        }

        if(!contactIdSet.isEmpty()) {
            SelectorWrapper wrapper = ContactSelector.getContacts(contactIdSet);
            if(wrapper!=null && String.isBlank(wrapper.ErrorMessage)) {
                for(Contact con : (List<Contact>) wrapper.SobjectList) {
                    if(String.isNotBlank(con.Employment_Status__c) && (con.Employment_Status__c).equalsIgnorecase(RevSys_StaticUtility.ACTIVE)) {
                        contactIdMap.put(con.Id,con);
                    }
                }
            }
        }
        
        System.debug('------------------ contactIdMap '+contactIdMap);
        System.debug('------------------ mycertTargetMap '+mycertTargetMap);
        
        //Conditions to check whether the containers are empty
        if(!myTargetIdSet.isEmpty() && !myCertIdSet.isEmpty() && !mycertTargetMap.isEmpty()) {
            //Loop on Employee Certification
            for(EmployeeCertification__c ecRec :myProcessingList ) {
                if(mycertTargetMap.containsKey(ecRec.Certification__c)) {
                    //Loop on Occupation Certification
                    for(OccupationCertification__c targetObj : mycertTargetMap.get(ecRec.Certification__c)) {
                        if(contactIdMap.containsKey(ecRec.Employee__c)) {
                            Contact con = contactIdMap.get(ecRec.Employee__c);
                            if(String.isNotBlank(con.Department) && con.Department==targetObj.Department__c) {
                                //Loop to create Employee Specific Requirements based on the Occupation SPecific Requirement
                                //Create ESR for each target defined for the employee
                                EmployeeSpecificRequirement__c esrObj =  new EmployeeSpecificRequirement__c();
                                esrObj.RecordTypeId     = RevSys_StaticUtility.EMP_SPEC_REQ_SPARTNTARGET_RECTYPE_ID;
                                esrObj.EmployeeTarget__c = con.Id;
                                esrObj.Employee__c      = con.Id;
                                esrObj.Target__c        = targetObj.Id;
                                Boolean canBeApplied = RevSys_StartTarget.checkTargetPeriod(System.Date.today(),targetObj.Frequency__c);
                                if(canBeApplied)
                                {
                                    esrObj.StartDate__c    = Amtrak_DateUtility.determineThisStartDate(targetObj.Frequency__c,System.Date.today());
                                    esrObj.EndDate__c      = Amtrak_DateUtility.determineThisEndDate(targetObj.Frequency__c, System.Date.today());
                                    esrObj.PeriodName__c   = Amtrak_DateUtility.determineThisPeriod(targetObj.Frequency__c, System.Date.today());
                                }
                                else
                                {
                                    esrObj.StartDate__c    = Amtrak_DateUtility.determineNextStartDate(targetObj.Frequency__c,System.Date.today());
                                    esrObj.EndDate__c      = Amtrak_DateUtility.determineNextEndDate(targetObj.Frequency__c, System.Date.today());
                                    esrObj.PeriodName__c   = Amtrak_DateUtility.determineNextPeriod(targetObj.Frequency__c, System.Date.today());
                                }
                                esrObj.TotalRequired__c = targetObj.NumberOfTestsPerPeriod__c;
                                esrObj.Status__c        = RevSys_StaticUtility.ACTIVE;
                                myEsrToInsertList.add(esrObj);
                            }
                        }
                    }
                }
                
            }
        }
        //Inserting the Employee Specific Requirement records
        if(!myEsrToInsertList.isEmpty()) {
            System.debug('------------------ myEsrToInsertList '+myEsrToInsertList);
            errmsg = DmlHelper.insertList(myEsrToInsertList);
        }
        system.debug('HELPER RevSys_EmployeeCertificationHelper createCertificationTargets-END');
        return errmsg;
    }



    
    /**
*————————————————————————————————————————————————————
* @Name: establishSupervisorTargets
* @Description
* Employee based on the Certificate targets defined in Occupation Certification object 
*————————————————————————————————————————————————————
* @param    newEmpCertList  List of records related to Employee Certification
*           oldEmpCertMap   Map of Id and Employee Certification record before update
* @return   String          Returns string if error
*————————————————————————————————————————————————————
**/
    public static String establishSupervisorTargets(List<EmployeeCertification__c> newEmpCertList,Map<Id,EmployeeCertification__c> oldCertMap) {
        system.debug('HELPER RevSys_EmployeeCertificationHelper establishSupervisorTargets-Start');
        //Initialising the container variables
        String errmsg;
        Set<ID> empIDs = new Set<ID>();
        List<Contact> contactList = new List<Contact>();
        
        if(newEmpCertList!=null) {
            //Loop to fetch the Employee Ids
            for(EmployeeCertification__c ecObj : newEmpCertList) {
                String oldStatus = oldCertMap.get(ecObj.Id).Status__c;//Fetching the Old Status value
                //Condition to compare the Old and New Status values
                if(ecObj.RecordTypeId == RevSys_StaticUtility.EMPCERT_SPARTSUPV_RECTYPE_ID && 
                   (String.isNotBlank(ecObj.Status__c) && ecObj.Status__c.equalsIgnoreCase(RevSys_StaticUtility.ACTIVE) && 
                    String.isNotBlank(oldStatus) && oldStatus.equalsIgnoreCase(RevSys_StaticUtility.INACTIVE))) {
                        empIDs.add(ecObj.Employee__c);
                    }
            }
        }
        
        if(!empIDs.isEmpty())
        {
            //Query to fetch the Contacts based on Ids
            SelectorWrapper wrapper = ContactSelector.getContacts(empIDs);
            contactList = (List<Contact>)wrapper.SobjectList;
            
            errmsg = RevSys_EstablishTargetHelper.establistTargetsFromContact(contactList,RevSys_StaticUtility.SUPERVISOR); //Calling RevSys_EstablishTargetHelper to establish targets
            
        }
        system.debug('HELPER RevSys_EmployeeCertificationHelper establishSupervisorTargets-END');
        return errmsg;
    }
    
    /**
*————————————————————————————————————————————————————
* @Name: replaceLastCertifiedDate
* @Author : Padmini
* @Description
* Replacing Last Certification Date by Certification/Re-Certification Date 
*————————————————————————————————————————————————————
* @param    newEmpCertList  List of records related to Employee Certification
*           oldEmpCertMap   Map of Id and Employee Certification record before update
* @return   String          Returns string if error
*————————————————————————————————————————————————————
**/
    
    public static String replaceLastCertifiedDate (List<EmployeeCertification__c> newEmpCertList,Map<Id,EmployeeCertification__c> oldEmpCertMap){
        if(newEmpCertList!=null) {
            for(EmployeeCertification__c empcerRecord : newEmpCertList) {
                Date oldCertifiedDate = oldEmpCertMap.get(empcerRecord.Id).CertificationReCertificationDate__c;
                //Condition to compare the Old and New Date values
                if(empcerRecord.RecordTypeId == RevSys_StaticUtility.EMPCERT_SPARTNCERT_RECTYPE_ID && 
                   empcerRecord.CertificationReCertificationDate__c != null && empcerRecord.Status__c==RevSys_StaticUtility.CURRENT ){
                       empcerRecord.LastCertificationDate__c = empcerRecord.CertificationReCertificationDate__c;
                       
                   }
                else if(empcerRecord.RecordTypeId == RevSys_StaticUtility.EMPCERT_SPARTNCERT_RECTYPE_ID &&
                        empcerRecord.CertificationReCertificationDate__c == null  && empcerRecord.Status__c==RevSys_StaticUtility.CURRENT){
                            empcerRecord.LastCertificationDate__c = System.today();    
                }
                empcerRecord.CertificationReCertificationDate__c = NULL;
            }
            
        }
        return null;
    }
    
    /**
*————————————————————————————————————————————————————
* @Name: populateEmployeeSupervisor
* @Description : Finds the Employees Supervisor from Employee Hierarcy and populates on Employee Certification
*————————————————————————————————————————————————————
* @param    newEmpCertList  List of records related to Employee Certification
*           oldEmpCertMap   Map of Id and Employee Certification record before update
* @return   String          Returns string if error
*————————————————————————————————————————————————————
**/
    public static string populateEmployeeSupervisor(List<EmployeeCertification__c> newEmpCertList,Map<Id,EmployeeCertification__c> oldEmpCertMap){
        //Fetch the employees on the Employee Certfication
        List<Id> employeeIds = new List<Id>();
        for(EmployeeCertification__c empCert : newEmpCertList) {
            if(empCert.Employee__c!=null) {
                // On update check if the employee is changed 
                if(!oldEmpCertMap.isEmpty() && empCert.Employee__c!=oldEmpCertMap.get(empCert.Id).Employee__c){
                    employeeIds.add(empCert.Employee__c);
                }
                // On insert directly add the employee id 
                else if(oldEmpCertMap.isEmpty()){
                    employeeIds.add(empCert.Employee__c);
                }
            }
        }
        
        //Get the supervisor and assign to the lookup field on the Employee Certfication
        if(!employeeIds.isEmpty()) {
            Map<Id,Id> supEmpMap = RevSys_SupervisorManagerHelper.retrieveSupervisorId(employeeIds);
            if(supEmpMap!=null) {
                for(EmployeeCertification__c empCert : newEmpCertList) {
                    if(supEmpMap.containsKey(empCert.Employee__c)) {
                        empCert.EmployeeSupervisor__c = supEmpMap.get(empCert.Employee__c);
                    }
                }
            }
        }
        return null;
    }
    
    /**
*————————————————————————————————————————————————————
* @Name: generateCertificateNumber
* @Author : Sudhindra Katti
* @Description
* Generate unique Certification Number
*————————————————————————————————————————————————————
* @param    None
*           
* @return   String          Returns max CertificationNUmber, Invoked when the certification becomes valid
*————————————————————————————————————————————————————
**/
    
    public static Integer generateCertificateNumber(){
        Integer certificationNumber=0;
        
        List <aggregateResult> aggrResult = new list<aggregateResult>();
        //Query Occupation Certification based on certification Id
        SelectorWrapper wrapper = EmployeeCertificationSelector.generateCertificationId();      
        if(wrapper!=null){
            aggrResult = (List<aggregateResult>)wrapper.SobjectList;
        }        
        
        if(aggrResult.size()>0 && aggrResult != null) {            
            for(AggregateResult tempaggrResult : aggrResult) {              
                certificationNumber =  Integer.valueOf(tempaggrResult.get('expr0'));
                system.debug('expr'+ tempaggrResult.get('expr0'));
                //Condition to compare the Old and New Date values
                if(certificationNumber!=null) {
                    certificationNumber= certificationNumber;
                }
                else
                {
                    certificationNumber = 0;
                }
            }            
        }
        else
        {
            certificationNumber = 0; 
        }
        return certificationnumber;
        
    }
    
    /**
*————————————————————————————————————————————————————
* @Name: validateCertification
* @Author : Hemanth Kesapragada
* @Description
* validate a Certification
*————————————————————————————————————————————————————
* @param    newEmpCertList  Employee Certification records
*           
* @return   ecWrapperlist   List of EmployeeCertification records determining if the certifications are valid
*————————————————————————————————————————————————————
**/
    
    public static List<EmployeeCertificationWrapper> validateCertification(List<EmployeeCertification__c> newEmpCertList) {
        
        Map<Id,EmployeeCertificationWrapper> ecWrapperMap = new Map<Id,EmployeeCertificationWrapper>();
        if(newEmpCertList!=null && !newEmpCertList.isEmpty()) {
            //Initialising the variables
            Date myExpirationDate;
            Date myEarliestDate;
            Integer lengthofPeriod;
            String frequency;
            
            //Initialising the Container variables
            Map<ID, Date > myFutureExpirationDateByEmpCertIdMap = new Map<ID, Date>();
            List<OccupationCertification__c> occCertList = new List<OccupationCertification__c>();
            List<OccupationSpecificRequirement__c> myOscrequirements = new List<OccupationSpecificRequirement__c>();
            List<EmployeeSpecificRequirement__c> myEsrequirements = new List<EmployeeSpecificRequirement__c>();
            List<OccupationRequirement__c> myOccRequirementIdMap = new List<OccupationRequirement__c>();
            Set<ID> myEmployeeIdSet = new Set<ID>();       
            Set<ID> myCertIdSet = new Set<ID>();
            Set<ID> myOccReqIdSet = new Set<ID>();
            Set<ID> myEmployeeCertIdSet = new Set<ID>();
            Map<ID, Date > myExpirationDateByCertIdMap = new Map<ID, Date>();        
            Map<ID, List<OccupationSpecificRequriementWrapper>> myOsrWrapperListByCertificationIdMap = new Map<ID, List<OccupationSpecificRequriementWrapper>>();
            Map<Id, List<EmployeeSpecificRequirement__c>> myEsrByEmpCertIdMap = new Map<Id, List<EmployeeSpecificRequirement__c>>();
            List<EmployeeCertification__c> empListToUpdate = new List<EmployeeCertification__c>();
            List<EmployeeCertification__c> processECList = new List<EmployeeCertification__c>();
            Map<Id,List<Id>> erroredEC = new Map<Id,List<Id>>();
            
            //Get the EC records from the wrapper
            for(EmployeeCertification__c ecRecord : newEmpCertList)
            {  
                if(ecRecord.RecordTypeId==RevSys_StaticUtility.EMPCERT_SPARTNCERT_RECTYPE_ID){
                    processECList.add(ecRecord);
                    myEmployeeIdSet.add(ecRecord.Employee__c);
                    myCertIdSet.add(ecRecord.Certification__c);
                    myEmployeeCertIdSet.add(ecRecord.Id);
                    ecWrapperMap.put(ecRecord.Id,new EmployeeCertificationWrapper(ecRecord));
                }                
            }
            
            
            
            if(!myCertIdSet.isEmpty()) {
                //Query Occupation Certification based on certification Id
                SelectorWrapper wrapper = OccupationCertificationSelector.getCertifications(myCertIdSet);      
                if(wrapper!=null){
                    occCertList = (List<OccupationCertification__c>)wrapper.SobjectList;
                }
                
                //Query OccupationSpecificRequirement based on the Certification ids
                SelectorWrapper wrapperOsc = OccupationSpecificRequirementSelector.getOccSpecReqCertification(myCertIdSet);
                if(wrapperOsc!=null){
                    myOscrequirements = (List<OccupationSpecificRequirement__c>)wrapperOsc.SobjectList;
                }
            }
            
            //Create the myExpirationDateByCertIdMap from the OccupationCertification along with Expiration date
            for(OccupationCertification__c tempOccCertObj : occCertList)
            {            
                if(tempOccCertObj.LengthOfPeriod__c!=null) {
                    lengthofPeriod = Integer.valueOf(tempOccCertObj.LengthOfPeriod__c);
                }
                frequency = tempOccCertObj.Frequency__c;
                myExpirationDate = AMTRAK_DateUtility.determineDate(frequency,lengthofPeriod); 
                if(!myExpirationDateByCertIdMap.containsKey(tempOccCertObj.Id)){
                    myExpirationDateByCertIdMap.put(tempOccCertObj.Id,myExpirationDate);
                }
                
            }
            
            //Query Occupation Specific Requirement        
            for(OccupationSpecificRequirement__c tempOccSpecReqObj : myOscrequirements) {
                if(tempOccSpecReqObj.LengthOfPeriod__c!=null) {
                    lengthofPeriod = -1* (Integer.valueOf(tempOccSpecReqObj.LengthOfPeriod__c));
                }
                frequency = tempOccSpecReqObj.Frequency__c;
                myEarliestDate = AMTRAK_DateUtility.determineDate(frequency,lengthofPeriod); 
                
                //Create myOsrWrapperListByCertificationIdMap with Certification ids
                if(myOsrWrapperListByCertificationIdMap.containsKey(tempOccSpecReqObj.Certification__c)){
                    myOsrWrapperListByCertificationIdMap.get(tempOccSpecReqObj.Certification__c).add(new OccupationSpecificRequriementWrapper(tempOccSpecReqObj,myEarliestDate));  //When the key value already exists              
                }else{
                    myOsrWrapperListByCertificationIdMap.put(tempOccSpecReqObj.Certification__c, new List<OccupationSpecificRequriementWrapper>{new OccupationSpecificRequriementWrapper(tempOccSpecReqObj,myEarliestDate)}); //when the Key value does not exists
                }            
                
            }
            
            if(!myEmployeeCertIdSet.isEmpty()) {
                //Query EmployeeSpecificRequirement based on the EmployeeCertification Ids
                SelectorWrapper wrapperEsc = EmployeeSpecificRequirementSelector.getEmployeeSpecificRequirementsFrmEmpCert(myEmployeeCertIdSet);      
                if(wrapperEsc!=null){
                    myEsrequirements = (List<EmployeeSpecificRequirement__c>)wrapperEsc.SobjectList; 
                }
            }
            
            //Create myEsrByEmpCertIdMap from Employee Specific Requirement
            for(EmployeeSpecificRequirement__c tempEmpSpecReqObj: myEsrequirements)
            {
                if(myEsrByEmpCertIdMap.containsKey(tempEmpSpecReqObj.EmployeeCertification__c)){
                    myEsrByEmpCertIdMap.get(tempEmpSpecReqObj.EmployeeCertification__c).add(tempEmpSpecReqObj);
                    
                }else{
                    myEsrByEmpCertIdMap.put(tempEmpSpecReqObj.EmployeeCertification__c,new List<EmployeeSpecificRequirement__c>{tempEmpSpecReqObj});
                }
                
            }
            
            
            //Validation Logic
            for(EmployeeCertification__c tempObj : processECList) {
                if(!(System.today() <= tempObj.RevocationEndDate__c &&  System.today() >= tempObj.RevocationBeginDate__c) ) {

                //Condition to check whether Certification and Employee Certification Ids are available in the map
                if(myOsrWrapperListByCertificationIdMap.containsKey(tempObj.Certification__c) &&
                   myEsrByEmpCertIdMap.containsKey(tempObj.Id)) {
                       //Looping on the Occupation Specific Requirements wrapper
                       for(OccupationSpecificRequriementWrapper osrWithDate : myOsrWrapperListByCertificationIdMap.get(tempObj.Certification__c)){
                           OccupationSpecificRequirement__c osr = osrWithDate.oscrequirements;
                           //Looping on Employee Specific Requirements
                           for(EmployeeSpecificRequirement__c esr : myEsrByEmpCertIdMap.get(tempObj.Id) ){
                               if(esr.Requirement__c == osr.Requirement__c){
                                   if((date.valueOf(esr.LastFulfilledDate__c) < date.valueOf(osrWithDate.earliestDate )  &&  esr.SourceRecordType__c!=RevSys_StaticUtility.EMPLOYMENT_HISTORY ) || esr.LastFulfilledDate__c==null )
                                      /*&& (esr.Source__c!=RevSys_StaticUtility.EMPLOYEE_RESULT_SUMM && esr.SourceRecordType__c!=RevSys_StaticUtility.EMPLOYMENT_HISTORY))*/  // Check for ETR-673- do not check for when the result was provided.
                                   {
                                       myOccReqIdSet.add(osr.Requirement__c);
                                       if(erroredEC.containsKey(tempObj.Id)) {
                                           erroredEC.get(tempObj.Id).add(osr.Requirement__c);
                                       } else {
                                           erroredEC.put(tempObj.Id, new List<id>{osr.Requirement__c});
                                       }
                                   } else  {
                                       
                                       ecWrapperMap.get(tempObj.Id).hasError=false;
                                       if(esr.Source__c==RevSys_StaticUtility.OBSERVATION) {
                                            if(String.isBlank(esr.ReportStatus__c) || esr.ReportStatus__c!=Label.RevSys_Pass) {
                                               ecWrapperMap.get(tempObj.Id).hasError=true;
                                               ecWrapperMap.get(tempObj.Id).errorMsg = Label.Revsys_Error_for_Observation_Form;
                                               break;
                                           }
                                       } 
                                       else if(esr.Source__c==RevSys_StaticUtility.EMPLOYEE_RESULT_SUMM && esr.SourceRecordType__c==Label.RevSys_EmpResSumm_RT_Label_EmpHistory) {
                                           if(String.isBlank(esr.ReportStatus__c) || esr.ReportStatus__c!=Label.RevSys_Pass) {
                                               ecWrapperMap.get(tempObj.Id).hasError=true;
                                               ecWrapperMap.get(tempObj.Id).errorMsg = Label.Revsys_Error_for_Employee_History_Form;
                                               break;
                                           }
                                       } 
                                      else if(esr.Source__c==RevSys_StaticUtility.EMPLOYEE_RESULT_SUMM && esr.SourceRecordType__c==Label.RevSys_EmpResSumm_RT_Label_Motor) {
                                           if(String.isBlank(esr.ReportStatus__c) || esr.ReportStatus__c!=Label.RevSys_Pass) {
                                               ecWrapperMap.get(tempObj.Id).hasError=true;
                                               ecWrapperMap.get(tempObj.Id).errorMsg = Label.Revsys_Error_for_Motor_Vehicle_form;
                                               break;
                                           }
                                       } else if(esr.Source__c==RevSys_StaticUtility.EMPLOYEE_RESULT_SUMM && esr.SourceRecordType__c==Label.RevSys_EmpResSumm_RT_Label_Medical) {
                                           if(String.isBlank(esr.ReportStatus__c) || esr.ReportStatus__c!=Label.RevSys_Pass) {
                                               ecWrapperMap.get(tempObj.Id).hasError=true;
                                               ecWrapperMap.get(tempObj.Id).errorMsg = Label.RevSys_Error_Medical_Invalid_EmpCert;
                                               break;
                                           }
                                       } 
                                   }
                               }
                           }
                           //Continue validating next certificate when any one of the ESR has error
                           if(ecWrapperMap.get(tempObj.Id).hasError) {
                               break;
                           }
                       }
                       
                   } else{
                       //Custom Error message to be displayed when the Certification and Employee Certification Ids are not available in the Map
                       ecWrapperMap.get(tempObj.Id).errorMsg = Label.Revsys_Error_for_Certification_with_no_Requirements_data_setup;
                       ecWrapperMap.get(tempObj.Id).hasError=true;
                   }
                } else {
                    ecWrapperMap.get(tempObj.Id).errorMsg = Label.Revsys_Error_Certified_under_Revocation;
                    ecWrapperMap.get(tempObj.Id).hasError=true;
                }
            }
            
            
            // Querying requirements to get the errors
            Map<Id,String> reqIdNameMap = new Map<Id,String>();
            if(!myOccReqIdSet.isEmpty()) {
                SelectorWrapper wrapperOccReq = OccupationRequirementSelector.getOccRequirements(myOccReqIdSet);
                if(wrapperOccReq!=null){
                    myOccRequirementIdMap = (List<OccupationRequirement__c>)wrapperOccReq.SobjectList;
                    for(OccupationRequirement__c ocRec : myOccRequirementIdMap) {
                        reqIdNameMap.put(ocRec.Id,ocRec.Name);
                    }
                }
            }
            
            //Iterate throught the requirement Ids that are errored out and construct a label
            for(Id ecKey : erroredEC.keySet()) {
                String error;
                for(Id reqId : erroredEC.get(ecKey)) {
                    if(error==null) {
                        error = System.Label.RevSys_Error_Message_Certificate_Validation +' '+reqIdNameMap.get(reqId);
                    } else {
                        error += ','+ reqIdNameMap.get(reqId);
                    }
                }
                ecWrapperMap.get(ecKey).hasError=true;
                ecWrapperMap.get(ecKey).errorMsg = error;
            }  
            
            
        }
        return ecWrapperMap.values();
    }
    
    /**
*————————————————————————————————————————————————————
* @Name: updateCertification
* @Author : Hemanth Kesapragada
* @Description
* Once a Certification is Valid, Update the employee Certifications to Current
*————————————————————————————————————————————————————
* @param    newEmpCertList  Employee Certification records
*           
* @return   ecWrapperlist   List of EmployeeCertification records determining if the certifications are valid
*————————————————————————————————————————————————————
**/
    public static String updateCertification(List<EmployeeCertification__c> theNewEmpCertsList) {
        Integer certificationNumber=0;
        String errorMsg;
        Integer lengthofPeriod;
        String frequency;
        Date myExpirationDate;
        Map<Id,Date> myExpirationDateByCertIdMap = new Map<Id,Date>();
        Set<id> myCertIdSet = new Set<id>();
        List<OccupationCertification__c> occCertList =  new List<OccupationCertification__c>();
        List<EmployeeCertification__c> ecToUpdate = new List<EmployeeCertification__c>();
        List<EmployeeCertification__c> ecToProcess = new List<EmployeeCertification__c>();
        
        if(theNewEmpCertsList!=null) {
            for(EmployeeCertification__c ecRecord : theNewEmpCertsList) {
                if(ecRecord.RecordTypeId==RevSys_StaticUtility.EMPCERT_SPARTNCERT_RECTYPE_ID) {
                    myCertIdSet.add(ecRecord.Certification__c);
                    ecToProcess.add(ecRecord);
                    
                }
            }
            
            //Query Occupation Certification based on certification Id
            SelectorWrapper wrapper = OccupationCertificationSelector.getCertifications(myCertIdSet);      
            if(wrapper!=null){
                occCertList = (List<OccupationCertification__c>)wrapper.SobjectList;
            }
            
            
            //Create the myExpirationDateByCertIdMap from the OccupationCertification along with Expiration date
            for(OccupationCertification__c tempOccCertObj : occCertList)
            {            
                if(tempOccCertObj.LengthOfPeriod__c!=null) {
                    lengthofPeriod = Integer.valueOf(tempOccCertObj.LengthOfPeriod__c);
                }
                frequency = tempOccCertObj.Frequency__c;
                myExpirationDate = AMTRAK_DateUtility.determineDate(frequency,lengthofPeriod); 
                if(!myExpirationDateByCertIdMap.containsKey(tempOccCertObj.Id)){
                    myExpirationDateByCertIdMap.put(tempOccCertObj.Id,myExpirationDate);
                }
                
            }
            
            // Get the last certification number
            certificationNumber = generateCertificateNumber();
            System.debug('certificationNumber'+certificationNumber); 
            if (certificationNumber ==0){
                certificationNumber = Integer.valueOf(System.Label.Revsys_Certification_Start_Number);
            } else{
                certificationNumber++;              
            }
            
            for(EmployeeCertification__c ecRecord : ecToProcess) {
                //Updating Employee Certification
                ecRecord.ExpirationDate__c = myExpirationDateByCertIdMap.get(ecRecord.Certification__c);
                ecRecord.Status__c= Revsys_StaticUtility.CURRENT;
                ecRecord.ProcessFlag__c=System.Label.RevSys_EmpCert_ProcessFlag;
                ecRecord.LastCertificationDate__c=System.today();
                ecRecord.IsReadyToCertify__c = false; 
                
                //Updating the certification number
                if(ecRecord.BackEndSerialNumber__c==null){
                    ecRecord.BackEndSerialNumber__c = certificationNumber;
                    ecRecord.CertificationNumber__c = System.Label.Revsys_Certification_Prefix+certificationNumber;
                    certificationNumber++;
                }                            
                ecToUpdate.add(ecRecord);
            }
            
            if(!ecToUpdate.isEmpty()) {
                errorMsg = DmlHelper.updateList(ecToUpdate);
            }
        }
        return errorMsg;
    }

/*
*————————————————————————————————————————————————————
* @Name:    checkIfReadyForArchival
* @Author : Chuck Walley
* @Description
* Check the Employee Certification to see if we want to create and archived copy
* We only want to create an archival copy when the LastCertificationDate has changed and: 
* Status moves From: Current or Expired 
*              TO:   Current 
*————————————————————————————————————————————————————
* @param    newEmpCertList  Employee Certification records
*           
* @return   String          Error Message
*————————————————————————————————————————————————————
**/
    public static String checkIfReadyForArchival(List<EmployeeCertification__c> newEcList, Map<Id,EmployeeCertification__c> oldMap) {

        system.debug('HELPER RevSys_EmployeeCertificationHelper checkIfReadyForArchival-Start');
        system.debug('newEcList  ' + newEcList);
        system.debug('oldMap  '    + oldMap);

        String errorMsg; 

        Map<Id,EmployeeCertification__c> myNewEctoProcessMap = new Map<Id,EmployeeCertification__c>(); 
        Map<Id,EmployeeCertification__c> myOldEctoProcessMap = new Map<Id,EmployeeCertification__c>(); 

        // roll through the new list to see if we want to keep the record. 

        for(EmployeeCertification__c newEc :newEcList) 
        { 
            EmployeeCertification__c oldEc = oldMap.get(newEc.Id); 

            if(newEc.LastCertificationDate__c != oldEc.LastCertificationDate__c) 
            {
                if(newEc.Status__c == label.RevSys_Employee_Certification_Status_Current  
                    && 
                   (oldEc.Status__c == label.RevSys_Employee_Certification_Status_Current ||   
                    oldEc.Status__c == label.RevSys_Employee_Certification_Status_Expired))    
                    {
                          myNewEctoProcessMap.put(newEc.Id,newEc);  
                          myOldEctoProcessMap.put(oldEc.Id,oldEc);   
                    }
            } 
        }

        if(myNewEcToProcessMap.size() > 0) 
        {
            errorMsg = createEmployeeCertHistory(myNewEctoProcessMap,myOldEctoProcessMap); 

        }

        system.debug('HELPER RevSys_EmployeeCertificationHelper checkIfReadyForArchival-End');
        return errorMsg;
    }
    
/**
*————————————————————————————————————————————————————
* @Name: createEmployeeCertHistory()
* @Description
* Helps to create archived Employee Certification, ESR and CR revocation records
*————————————————————————————————————————————————————
* @param    newMap                              Employee Certification records from the trigger
* @param    oldMap                              List of EC records before update.
* @return   errorMessage                        returns error message if any
*————————————————————————————————————————————————————
**/ 
public static String createEmployeeCertHistory(Map<Id,EmployeeCertification__c> newMap, Map<Id,EmployeeCertification__c> oldMap){

        system.debug('HELPER RevSys_EmployeeCertificationHelper createEmployeeCertHistory-Start');
        String errorMsg;     
        List<EmployeeCertification__c> newCertList = new List<EmployeeCertification__c>();
        List<EmployeeCertification__c> ecList = new List<EmployeeCertification__c>();
        List<EmployeeSpecificRequirement__c> esrList = new List<EmployeeSpecificRequirement__c>();
        List<EmployeeSpecificRequirement__c> clonedEsrList = new List<EmployeeSpecificRequirement__c>();
        List<EmployeeSpecificRequirement__c> masterEsrList = new List<EmployeeSpecificRequirement__c>();
        List<CertificationRevocation__c> certRevocationList = new List<CertificationRevocation__c>();
        List<CertificationRevocation__c> clonedCertRevocationList = new List<CertificationRevocation__c>();
        List<CertificationRevocation__c> masterCertRevocationList = new List<CertificationRevocation__c>();
        Map<Id, EmployeeCertification__c> newEmpCertMap = new Map<Id, EmployeeCertification__c>();
        Map<Id, EmployeeCertification__c> clonedByIdEmpCertMap = new Map<Id, EmployeeCertification__c>();
        Set<Id> empCertIds = new Set<Id>();
        Map<Id, List<EmployeeSpecificRequirement__c>> esrByCertMap = new Map<Id, List<EmployeeSpecificRequirement__c>>();
        Map<Id, List<CertificationRevocation__c>> crByCertMap = new Map<Id, List<CertificationRevocation__c>>();
        
        //This is on after update. Requery EC records to process them
        SelectorWrapper ecWrap = EmployeeCertificationSelector.getEmpCertification(newMap.keySet());
        
        if(ecWrap!=null && String.isBlank(ecWrap.errorMessage)) {
            ecList =  (List<EmployeeCertification__c>)ecWrap.SObjectList;
        }
        

        for(EmployeeCertification__c newEmpCert : ecList){
            //now get the old record for every new record from the trigger
            EmployeeCertification__c oldEmpCert = oldMap.get(newEmpCert.Id);
            //process only when the status is changed to current and last certification date is changed.
            if(newEmpCert.Status__c.equalsIgnorecase(RevSys_StaticUtility.CURRENT) && newEmpCert.Status__c!= oldEmpCert.Status__c &&
               newEmpCert.LastCertificationDate__c != oldEmpCert.LastCertificationDate__c){
                   //Clone the new EC record from the trigger.
                   EmployeeCertification__c clonedEmpCert = newMap.get(newEmpCert.Id).clone();
                   //set process flag in order to bypass validations
                   clonedEmpCert.ProcessFlag__c = Label.RevSys_EmpCert_ProcessFlag;
                   //Set the new status with the values from the old EC record.
                   newEmpCert.Archived__c = true;
                   newEmpCert.ProcessFlag__c = Label.RevSys_EmpCert_ProcessFlag;
                   newEmpCert.LastCertificationDate__c = oldEmpCert.LastCertificationDate__c;
                   newEmpCert.Status__c = oldEmpCert.Status__c;
                   newCertList.add(newEmpCert);
                   newEmpCertMap.put(newEmpCert.Id, newEmpCert);
                   clonedByIdEmpCertMap.put(newEmpCert.Id, clonedEmpCert);
               }
        }      
        
        //Upsert cloned and new EC records
        errorMsg = DmlHelper.upsertList(newEmpCertMap.values());
        errorMsg += DmlHelper.insertList(clonedByIdEmpCertMap.values());
        errorMsg = StringUtility.cleanUpMessage(errorMsg);
        System.debug('errorMsg'+errorMsg);

        //Process ESR and CR only when the EC are successfull.
        if(String.isBlank(errorMsg)) {
            for(EmployeeCertification__c empCertObject : newEmpCertMap.values()) {
                empCertIds.add(empCertObject.Id);
            }
            
            //Query for ESRs on the new Cert Ids
            SelectorWrapper esrWrapper = EmployeeSpecificRequirementSelector.getESRbyEmployeeCertification(empCertIds);
            
            if(esrWrapper != null){
                esrList = (List<EmployeeSpecificRequirement__c>) esrWrapper.SObjectList;
                for(EmployeeSpecificRequirement__c tmpEsr : esrList)
                {
                    if(esrByCertMap.containsKey(tmpEsr.EmployeeCertification__c))
                    {
                        esrByCertMap.get(tmpEsr.EmployeeCertification__c).add(tmpEsr);
                    }
                    else
                    {
                        esrByCertMap.put(tmpEsr.EmployeeCertification__c,new List<EmployeeSpecificRequirement__c>{tmpEsr});
                    }
                }
                System.debug('******* esrByCertMap '+esrByCertMap);
                for(EmployeeCertification__c empCertObject : newEmpCertMap.values()){
                    //Clone ESR and associate it to the clone EC record.
                    if(esrByCertMap.containsKey(empCertObject.Id))
                    {
                        for(EmployeeSpecificRequirement__c employeeSpecificReqObject : esrByCertMap.get(empCertObject.Id)){
                            EmployeeSpecificRequirement__c clonedEsr = employeeSpecificReqObject.clone(false,false,false,false);
                            employeeSpecificReqObject.Archived__c = true;
                            clonedEsr.EmployeeCertification__c = clonedByIdEmpCertMap.get(empCertObject.Id).Id;                            
                            masterEsrList.add(clonedEsr);
                            masterEsrList.add(employeeSpecificReqObject);
                        }
                    }  
                }
            }
        
            //Get CRs from the new EC record Id.
            SelectorWrapper certRevocationWrapper = CertificationRevocationSelector.getCertRevocationbyEmpCertId(empCertIds);
            
            if(certRevocationWrapper != null){
                certRevocationList = (List<CertificationRevocation__c>)certRevocationWrapper.SObjectList;
                for(CertificationRevocation__c tmpCr : certRevocationList)
                {
                    if(crByCertMap.containsKey(tmpCr.EmployeeCertification__c))
                    {
                        crByCertMap.get(tmpCr.EmployeeCertification__c).add(tmpCr);
                    }
                    else
                    {
                        crByCertMap.put(tmpCr.EmployeeCertification__c,new List<CertificationRevocation__c>{tmpCr});
                    }
                }
                System.debug('******* crByCertMap '+crByCertMap);
                //Clone the CRs and associate it to the cloned EC record.
                for(EmployeeCertification__c empCertObject :  newEmpCertMap.values()){
                    if(crByCertMap.containsKey(empCertObject.Id))
                    {
                        for(CertificationRevocation__c certificationRevocationObj : crByCertMap.get(empCertObject.Id)){
                            CertificationRevocation__c clonedCertRevocation = certificationRevocationObj.clone(false,false,false,false);
                            certificationRevocationObj.Archived__c = true;
                            clonedCertRevocation.EmployeeCertification__c = clonedByIdEmpCertMap.get(empCertObject.Id).Id;
                            masterCertRevocationList.add(certificationRevocationObj);
                            masterCertRevocationList.add(clonedCertRevocation);
                        }
                    }
                }

                System.debug('******* masterEsrList '+masterEsrList);
                System.debug('******* masterCertRevocationList '+masterCertRevocationList);
                //upsert ESR and CR list.
                errorMsg = DmlHelper.upsertList(masterEsrList);
                errorMsg += DmlHelper.upsertList(masterCertRevocationList);
                System.debug(errorMsg);
                errorMsg = StringUtility.cleanUpMessage(errorMsg);
                system.debug('HELPER RevSys_EmployeeCertificationHelper createEmployeeCertHistory-End');
            }
        }
        return errorMsg;
    }
    
    /**
*————————————————————————————————————————————————————
* @Name: EmployeeCertificationWrapper
* @Author : Hemanth Kesapragada
* @Description
* Wrapper class for Employee Certification, errorMessages and hasError flag
*————————————————————————————————————————————————————
**/
    public class EmployeeCertificationWrapper {
        public EmployeeCertification__c ecRecord;
        public String errorMsg;
        public Boolean hasError;
        public EmployeeCertificationWrapper(EmployeeCertification__c ecRecord) {
            this.ecRecord = ecRecord;
            this.hasError = false;
        }
    }
    
}
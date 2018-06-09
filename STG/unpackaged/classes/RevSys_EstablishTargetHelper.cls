/**
*___________________________________________________
*@Name: RevSys_EstablishTargetHelper
*@Author: Hemanth Kesapragada
*@Created: Date: 03/13/2018
*@Used_By: SPARTN
*___________________________________________________
*@Description: Helper class to create ESR records for Contact
*___________________________________________________
*@Changes: 
* 03-16-2018. Split into different methods from contact and cert
* 03-27-2018  Update Internal/External employee check logic in matchEmployeeAttribute() [c walley] 
* 03-28-2018  Move upsert of ESR to end of loop in establishTargetsFromContact [cwalley]
**/
public with sharing class RevSys_EstablishTargetHelper {


 /**
*————————————————————————————————————————————————————
* @Name: establistTargetsFromContact
* @Description
* Creates targets (Employee Specific Requirement records) and associates it to the employee (Contact).
* @param    List of employees (Contacts), List Of Targets, Context
* @returns  String      Error message if any
*————————————————————————————————————————————————————
**/
public static String establistTargetsFromContact(List<Contact> contactList,String context) {
    String errorMsg;
    Set<String> deptSet = new Set<String>();
    List<OccupationCertification__c> targetsToProcess = new List<OccupationCertification__c>();  
    Map<String,List<OccupationCertification__c>> myTargetMap = new Map<String,List<OccupationCertification__c>>();
    Map<String,List<EmployeeSpecificRequirement__c>> myNewTargetMap  = new Map<String,List<EmployeeSpecificRequirement__c>>();
    Map<String,List<EmployeeSpecificRequirement__c>> myOldTargetMap  = new Map<String,List<EmployeeSpecificRequirement__c>>();
    List<EmployeeSpecificRequirement__c> masUpsertList =  new List<EmployeeSpecificRequirement__c>();

    Set<String> contactIdSet = new Set<String>(); 

    for(Contact con : contactList) {
        deptSet.add(con.Department);
    }

    //Get all the existing targets
    if(!deptSet.isEmpty()) {
        SelectorWrapper wrapper = OccupationCertificationSelector.getTargets(deptSet,context);
        if(wrapper!=null && String.isBlank(wrapper.errorMessage)) {
            targetsToProcess = (List<OccupationCertification__c>) wrapper.SObjectList;
            System.debug('&&&& targetsToProcess '+targetsToProcess);
        }
    }

     //Create a map of Occupation Certification (targets) records indexed by Department|Craft
        if(!targetsToProcess.isEmpty()) {
            //call the method to match the employee attributes and targets
            Map<Id,List<OccupationCertification__c>> contTargetMap =  matchEmployeeAttribute(contactList,targetsToProcess,context);
            if(contTargetMap!=null && !contTargetMap.isEmpty()) {
                if(contactList!=null) {
                    for(Contact conRec : contactList) {
                        if(contTargetMap.containsKey(conRec.Id)){
                            List<EmployeeSpecificRequirement__c> empSpecReqList = new List<EmployeeSpecificRequirement__c>();
                            //now that we have the matching targets of the employee, create the ESR
                            for(OccupationCertification__c  ocObj : contTargetMap.get(conRec.Id)) {
                                //Create ESR for each target defined for the employee
                                EmployeeSpecificRequirement__c esrObj =  new EmployeeSpecificRequirement__c();
                                esrObj.RecordTypeId     = RevSys_StaticUtility.EMP_SPEC_REQ_SPARTNTARGET_RECTYPE_ID;
                                esrObj.EmployeeTarget__c = conRec.Id;
                                esrObj.Employee__c      = conRec.Id;
                                esrObj.Target__c        = ocObj.Id;
                                Boolean canBeApplied = RevSys_StartTarget.checkTargetPeriod(System.Date.today(),ocObj.Frequency__c);
                                if(canBeApplied)
                                {
                                    esrObj.StartDate__c    = Amtrak_DateUtility.determineThisStartDate(ocObj.Frequency__c,System.Date.today());
                                    esrObj.EndDate__c      = Amtrak_DateUtility.determineThisEndDate(ocObj.Frequency__c, System.Date.today());
                                    esrObj.PeriodName__c   = Amtrak_DateUtility.determineThisPeriod(ocObj.Frequency__c, System.Date.today());
                                }
                                else
                                {
                                    esrObj.StartDate__c    = Amtrak_DateUtility.determineNextStartDate(ocObj.Frequency__c,System.Date.today());
                                    esrObj.EndDate__c      = Amtrak_DateUtility.determineNextEndDate(ocObj.Frequency__c, System.Date.today());
                                    esrObj.PeriodName__c   = Amtrak_DateUtility.determineNextPeriod(ocObj.Frequency__c, System.Date.today());
                                }
                                esrObj.TotalRequired__c = ocObj.NumberOfTestsPerPeriod__c;
                                esrObj.Status__c        = RevSys_StaticUtility.ACTIVE;
                                empSpecReqList.add(esrObj);
                            }
                            myNewTargetMap.put(conRec.Id,empSpecReqList);
                        } 
                    }
                }
            }

            //Capture all the Ids of contact in a set
            for(Contact conRec : contactList) {
                contactIdSet.add(conRec.Id);
            }
            //Get the existing ESRs of the employees
            if(!contactIdSet.isEmpty()) {
                SelectorWrapper newWrapper = EmployeeSpecificRequirementSelector.getEmployeeSpecificTargets(contactIdSet);
                //preparing the existing ESR of the contacts.
                if(newWrapper!=null) {
                    for(EmployeeSpecificRequirement__c empSpecReq : (List<EmployeeSpecificRequirement__c>) newWrapper.SObjectList) {
                        if(myOldTargetMap.containsKey(empSpecReq.Employee__c)) {
                            myOldTargetMap.get(empSpecReq.Employee__c).add(empSpecReq);
                        } else {
                            myOldTargetMap.put(empSpecReq.Employee__c, new List<EmployeeSpecificRequirement__c>{empSpecReq});
                        }

                    }
                }
            }
            //Iterate through contacts and associate Employee Specific Requirements
           
            for(Contact contactRec : contactList) {
                Set<Id> targetIds = new Set<Id>();
                //capture the targetIds in a set
                if(!myOldTargetMap.isEmpty()) {
                    List<EmployeeSpecificRequirement__c> oldESRList = myOldTargetMap.get(contactRec.Id);
                    if(oldESRList != null) {
                        for(EmployeeSpecificRequirement__c oldESRObj : oldESRList) {
                            targetIds.add(oldESRObj.Target__c);
                        }
                    }
                }
                
                //In case if there are no old targets or new targets are not yet associated with the employee, add to the master list
                if(!myNewTargetMap.isEmpty() && myNewTargetMap.containsKey(contactRec.Id)) {
                    for(EmployeeSpecificRequirement__c newESRObj : myNewTargetMap.get(contactRec.Id)) {
                        if(targetIds.isEmpty() || !targetIds.contains(newESRObj.Target__c)) {
                            masUpsertList.add(newESRObj);
                        }
                    }
                }

                if(!myOldTargetMap.isEmpty() && myOldTargetMap.containsKey(contactRec.Id)) {
                    Set<Id> newtargetIds = new Set<Id>();

                    //capture the new targetIds in a set
                    if(!myNewTargetMap.isEmpty()) {
                        List<EmployeeSpecificRequirement__c> newESRList = myNewTargetMap.get(contactRec.Id);
                        if(newESRList != null) {
                            for(EmployeeSpecificRequirement__c newESRObj : newESRList) {
                                newtargetIds.add(newESRObj.Target__c);
                            }
                        }
                    }
                    for(EmployeeSpecificRequirement__c oldESRObj : myOldTargetMap.get(contactRec.Id)) {
                        //If there are no new targets for employee or the old targets are not present in the new targets 
                        //then inactive the record in the Employee Specific Requirement
                        if(newtargetIds.isEmpty() || !newtargetIds.contains(oldESRObj.Target__c)) {
                            oldESRObj.Status__c = RevSys_StaticUtility.INACTIVE;
                            masUpsertList.add(oldESRObj);
                        } else {
                            //Activate the targets on the ESR if the targets are active on the Occupation Certification record
                            if(String.isNotBlank(oldESRObj.Status__c) && oldESRObj.Status__c.equalsIgnoreCase(RevSys_StaticUtility.INACTIVE)) {
                                oldESRObj.Status__c = RevSys_StaticUtility.ACTIVE;
                                masUpsertList.add(oldESRObj);
                            }
                        }
                    }
                }
                //Upsert the list by callig the DML Helper
                //if(!masUpsertList.isEmpty()) {
                //    errorMsg = DmlHelper.upsertList(masUpsertList);
                //    masUpsertList =  new List<EmployeeSpecificRequirement__c>();
                //}
            }
            //Upsert the list by callig the DML Helper
            if(!masUpsertList.isEmpty()) {
                errorMsg = DmlHelper.upsertList(masUpsertList);
                masUpsertList =  new List<EmployeeSpecificRequirement__c>();
            }
        }               // 51
        return errorMsg;
    }


    /**
    *————————————————————————————————————————————————————
    * @Name: establistTargetsFromOccCert
    * @Description
    * Creates targets (Employee Specific Requirement records) and associates it to the employee (Contact).
    * @param    List of employees (Contacts), List Of Targets, Context
    * @returns  String      Error message if any
    *————————————————————————————————————————————————————
    **/
    public static String establistTargetsFromOccCert(List<Contact> contactList,List<OccupationCertification__c> targetList, String context) 
    {
        List<EmployeeSpecificRequirement__c> empSpecReqList = new List<EmployeeSpecificRequirement__c>();
        String errorMsg;

        if(!targetList.isEmpty()) {
            System.debug('&&&& targetsToProcess '+targetList);
            //call the method to match the employee attributes and targets
            Map<Id,List<OccupationCertification__c>> contTargetMap =  matchEmployeeAttribute(contactList,targetList,context);
            System.debug('&&&& contTargetMap '+contTargetMap);
            if(contTargetMap!=null && !contTargetMap.isEmpty()) {
                if(contactList!=null) {
                    for(Contact conRec : contactList) {
                        if(contTargetMap.containsKey(conRec.Id)){
                            
                            //now that we have the matching targets of the employee, create the ESR
                            for(OccupationCertification__c  ocObj : contTargetMap.get(conRec.Id)) {
                                //Create ESR for each target defined for the employee
                                EmployeeSpecificRequirement__c esrObj =  new EmployeeSpecificRequirement__c();
                                esrObj.RecordTypeId     = RevSys_StaticUtility.EMP_SPEC_REQ_SPARTNTARGET_RECTYPE_ID;
                                esrObj.EmployeeTarget__c = conRec.Id;
                                esrObj.Employee__c      = conRec.Id;
                                /*if(String.isNotBlank(context) && context.equalsIgnoreCase(RevSys_StaticUtility.SUPERVISOR)) {
                                    if(String.isNotBlank(ocObj.DivisionOfObservation__c))  {
                                        esrObj.EmployeeTarget__c = null;
                                        esrObj.Employee__c      = null;
                                    }
                                }*/
                                esrObj.Target__c        = ocObj.Id;
                                Boolean canBeApplied = RevSys_StartTarget.checkTargetPeriod(System.Date.today(),ocObj.Frequency__c);
                                if(canBeApplied)
                                {
                                    esrObj.StartDate__c    = Amtrak_DateUtility.determineThisStartDate(ocObj.Frequency__c,System.Date.today());
                                    esrObj.EndDate__c      = Amtrak_DateUtility.determineThisEndDate(ocObj.Frequency__c, System.Date.today());
                                    esrObj.PeriodName__c   = Amtrak_DateUtility.determineThisPeriod(ocObj.Frequency__c, System.Date.today());
                                }
                                else
                                {
                                    esrObj.StartDate__c    = Amtrak_DateUtility.determineNextStartDate(ocObj.Frequency__c,System.Date.today());
                                    esrObj.EndDate__c      = Amtrak_DateUtility.determineNextEndDate(ocObj.Frequency__c, System.Date.today());
                                    esrObj.PeriodName__c   = Amtrak_DateUtility.determineNextPeriod(ocObj.Frequency__c, System.Date.today());
                                }
                                esrObj.TotalRequired__c = ocObj.NumberOfTestsPerPeriod__c;
                                esrObj.Status__c        = RevSys_StaticUtility.ACTIVE;
                                empSpecReqList.add(esrObj);
                            }
                        } 
                    }
                }
            }
            //Upsert the list by callig the DML Helper
            if(!empSpecReqList.isEmpty()) {
                errorMsg = DmlHelper.upsertList(empSpecReqList);
            }
        }
        return errorMsg;
    }   
    

    //Match all the employee attributes to create the target.
     public static Map<Id,List<OccupationCertification__c>> matchEmployeeAttribute(List<Contact> contactList, List<OccupationCertification__c> targets, String context) {
        Map<Id,List<OccupationCertification__c>> conTargetsMap = new Map<Id,List<OccupationCertification__c>>();
        for(Contact emp : contactList) {
            if(String.isNotBlank(emp.Employment_Status__c) && (emp.Employment_Status__c).equalsIgnoreCase(RevSys_StaticUtility.ACTIVE)) {
                for(OccupationCertification__c target : targets) {
                    List<String> crafts = String.isNotBlank(target.MultiCraft__c)?target.MultiCraft__c.toUpperCase().split(';'):null;
                    List<String> empReqList =  String.isNotBlank(emp.SPARTN_Requirement__c)?emp.SPARTN_Requirement__c.toUpperCase().split(';'):null;
                    List<String> targReqList =  String.isNotBlank(target.MatchEmployeeAttribute__c)?target.MatchEmployeeAttribute__c.toUpperCase().split(';'):null;
                    
                    Boolean isMatching  = true;

                    if(isMatching && String.isNotBlank(target.Department__c) &&  !(target.Department__c).equalsIgnoreCase(emp.Department)) {
                        isMatching =false;
                    }
                    if(String.isNotBlank(context) && !context.equalsIgnoreCase(RevSys_StaticUtility.SUPERVISOR)) {
                        //Only match if Craft is populated on the Target and previous check is true
                        if( isMatching && crafts!=null) {
                            if(String.isBlank(emp.Craft__c)) {
                                //Will be set to false if is employee craft is blank
                                isMatching = false;
                            } else {
                                //If craft on target has 'ALL'
                                if(crafts.contains(Label.RevSys_Generic_All_Label)) {
                                    //If craft on employee is N/A do not apply the target
                                    if(emp.Craft__c ==Label.RevSys_Generic_NA_Label) {
                                        isMatching = false;
                                    }
                                    //If craft on employee is different from the craft on Target
                                } else if(!crafts.contains((emp.Craft__c).toUpperCase())) {
                                    isMatching = false;
                                }
                            }
                        }

                        if(isMatching && String.isNotBlank(target.EmployeeDivision__c) && !(target.EmployeeDivision__c).equalsIgnoreCase(emp.Division__c)) {
                            isMatching = false;
                        }

                        /*
                        if(isMatching && String.isNotBlank(target.EmployeeType__c) && target.EmployeeType__c!=emp.Employee_Type__c ) {
                            isMatching =false;
                        }
                        */ 
                       
                        // Internal/External employee matching logic 

                        if(isMatching && String.isNotBlank(target.EmployeeType__c) ) {
                            if(target.EmployeeType__c == Label.Revsys_Constant_External && 
                               emp.RecordTypeId == null) {
                                isMatching = false;
                            }
                            else if(target.EmployeeType__c == Label.Revsys_Constant_Internal && emp.RecordTypeId != null) { 
                                if(emp.RecordTypeId == Revsys_StaticUtility.CONTACT_FOREIGNRREMPLOYEE_RECTYPE_ID) {
                                    isMatching = false;
                                }
                            }
                        }
                       

                        if(isMatching && target.HoursOfServiceEmployee__c && target.HoursOfServiceEmployee__c!=emp.HoursOfServiceEmployee__c) {
                            isMatching = false;
                        }
                        if(targReqList!=null && isMatching ) {
                            if(empReqList==null) {
                                    isMatching = false;
                            }
                            else {
                                for(String targReq: targReqList) {
                                    if(empReqList.contains(targReq)) {
                                         isMatching = true;
                                         break;
                                    } else {
                                        isMatching = false;
                                    }
                                }
                            }
                        }
                    }

                    if(isMatching) {
                        if(conTargetsMap.containsKey(emp.Id)) {
                            conTargetsMap.get(emp.Id).add(target);
                        } 
                        else {
                            conTargetsMap.put(emp.Id, new List<OccupationCertification__c> {target});
                        }
                    }
                }
            }
        }
        System.debug('&&&& conTargetsMap '+conTargetsMap);
        return conTargetsMap;

     }


    /**
    *————————————————————————————————————————————————————
    * @Name: processAsDivisionTargets
    * @Description
    * Creates Division Targets (Employee Specific Requirements)
    * @param    List Of Target
    * @returns  String      Error message if any
    *————————————————————————————————————————————————————
    **/
    public static String processAsDivisionTargets(List<OccupationCertification__c> divisionTargets) {
        List<EmployeeSpecificRequirement__c> empSpecReqList = new List<EmployeeSpecificRequirement__c>();
        String errorMsg = '';
        if(!divisionTargets.isEmpty()) {
            for(OccupationCertification__c ocObj : divisionTargets) {
                //Create ESR for each target defined for the employee
                EmployeeSpecificRequirement__c esrObj =  new EmployeeSpecificRequirement__c();
                esrObj.RecordTypeId     = RevSys_StaticUtility.EMP_SPEC_REQ_SPARTNTARGET_RECTYPE_ID;
                esrObj.EmployeeTarget__c = null;
                esrObj.Employee__c      = null;
                esrObj.Target__c        = ocObj.Id;
                Boolean canBeApplied = RevSys_StartTarget.checkTargetPeriod(System.Date.today(),ocObj.Frequency__c);
                if(canBeApplied) {
                    esrObj.StartDate__c    = Amtrak_DateUtility.determineThisStartDate(ocObj.Frequency__c,System.Date.today());
                    esrObj.EndDate__c      = Amtrak_DateUtility.determineThisEndDate(ocObj.Frequency__c, System.Date.today());
                    esrObj.PeriodName__c   = Amtrak_DateUtility.determineThisPeriod(ocObj.Frequency__c, System.Date.today());
                }
                else {
                    esrObj.StartDate__c    = Amtrak_DateUtility.determineNextStartDate(ocObj.Frequency__c,System.Date.today());
                    esrObj.EndDate__c      = Amtrak_DateUtility.determineNextEndDate(ocObj.Frequency__c, System.Date.today());
                    esrObj.PeriodName__c   = Amtrak_DateUtility.determineNextPeriod(ocObj.Frequency__c, System.Date.today());
                }
                esrObj.TotalRequired__c = ocObj.NumberOfTestsPerPeriod__c;
                esrObj.Status__c        = RevSys_StaticUtility.ACTIVE;
                empSpecReqList.add(esrObj);
            }
        }

        if(!empSpecReqList.isEmpty()) {
            errorMsg = DmlHelper.upsertList(empSpecReqList);
        }
        return errorMsg;
    }
}
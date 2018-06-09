/**
*___________________________________________________
*@Name: ViolationHelper
*@Author: Mona Bhutada
*@Created: Date: 01/29/2018
*@Used_By: SPARTN
*___________________________________________________
*@Description: The Helper Class for the ViolationsTrigger
*The functionality of this class is to insert Occupation Certification record when violation record is created.
*________________________________________________
*@Changes: 
* 04-12-2018 ETR-1113 [walley] 
**/
public class RevSys_ViolationHelper {

   
    /**
    *————————————————————————————————————————————————————
    * @Name: checkForTargetCreation
    * @Description - 
    *
    * 
    * @param    List<EPW_Hierarchy_Assignment__c> newHassList - list of Hierarchy Assignment
    *                                             records from the trigger 
    * @returns  String - error message from the process. 
    *————————————————————————————————————————————————————
    **/
    public static String checkForTargetCreation(List<Violation__c>   newViolationList, 
                                                Map<Id,Violation__c> oldViolationMap) { 
      
        system.debug('HELPER ViolationHelper checkForTargetCreation-Start');   
        system.debug('newViolationList  ' + newViolationList); 

        String errorMsg; 

        List<Violation__c> InsertTargetList     = new List<Violation__c>(); 
        List<Violation__c> UpdateTargetList     = new List<Violation__c>(); 
        List<Violation__c> InactivateTargetList = new List<Violation__c>(); 

        for(Violation__c newVio :newViolationList) 
        { 
            if(oldViolationMap == null ) 
            {
                // This is an INSERT 

                InsertTargetList.add(newVio); 
            }
            else
            {
                // THIS is an UPDATE 

                Violation__c oldVio = oldViolationMap.get(newVio.Id); 

                if(newVio.ReturnedToServiceDate__c != oldVio.ReturnedToServiceDate__c) 
                {
                    if(oldVio.ReturnedToServiceDate__c == null)
                    {
                        UpdateTargetList.add(newVio); 
                    }
                    else
                    {
                        InactivateTargetList.add(oldVio); 
                        UpdateTargetList.add(newVio); 
                    }
                }
            }
        }

        if(InsertTargetList.size() > 0 )
        {
            SelectorWrapper myInsertWrap = insertOccupationCertificationRecord(InsertTargetList); 

            errorMsg = myInsertWrap.ErrorMessage; 

            List<OccupationCertification__c> myActiveOcList = new List<OccupationCertification__c>(); 

            if(myInsertWrap.ErrorMessage == null && myInsertWrap.SObjectList.size() > 0) 
            {
                List<OccupationCertification__c> myOcList = (List<OccupationCertification__c>)myInsertWrap.SObjectList; 

                for(OccupationCertification__c myOc :myOcList) 
                {
                    if(myOc.Status__c == RevSys_StaticUtility.ACTIVE) 
                    { 
                        myActiveOcList.add(myOc); 
                    }
                }

                errorMsg = createEmployeeSpecificRequirements(myActiveOcList); 
            }
        }

        if(InactivateTargetList.size() > 0 )
        {
            errorMsg = inactivateEsr(InactivateTargetList); 
        }


        if(UpdateTargetList.size() > 0 )
        {
            SelectorWrapper myUpdateWrap = updateOccupationCertificationRecord(UpdateTargetList); 

            errorMsg = myUpdateWrap.ErrorMessage; 

            List<OccupationCertification__c> myActiveOcList = new List<OccupationCertification__c>(); 

            if(myUpdateWrap.ErrorMessage == null && myUpdateWrap.SObjectList.size() > 0) {

                List<OccupationCertification__c> myOcList = (List<OccupationCertification__c>)myUpdateWrap.SObjectList; 

                for(OccupationCertification__c myOc :myOcList) { 

                    if(myOc.Status__c == RevSys_StaticUtility.ACTIVE) { 
                        myActiveOcList.add(myOc); 
                    }
                }

                errorMsg = createEmployeeSpecificRequirements(myActiveOcList); 
            }
        }  

        system.debug('HELPER ViolationHelper checkForTargetCreation-End');   

        return errorMsg; 

    }

    /**
    *————————————————————————————————————————————————————
    * @Name: updateOccupationCertificationRecord
    * @Description
    * Creates Occupation Certification record and that internally creates Employee Specific Requirement.
    *————————————————————————————————————————————————————
    * @params   List of Employee Hierarchy records
    * @returns  NULL
    *————————————————————————————————————————————————————
    **/
    public static SelectorWrapper updateOccupationCertificationRecord(List<Violation__c> violationList) {

        system.debug('HELPER ViolationHelper updateOccupationCertificationRecord-Start');  
        system.debug('violationList ' + violationList) ; 

        String errorMsg; 

        Set<Id> myVioIdSet = new Set<Id>(); 

        Map<Id,OccupationCertification__c> myTargetByVioMap = new  Map<Id,OccupationCertification__c>(); 

        List<OccupationCertification__c> myUpdateOcList = new List<OccupationCertification__c>(); 

        for(Violation__c myVio :violationList) {
            myVioIdSet.add(myVio.Id); 
        }

        // Get the Occupation Certifications 

        SelectorWrapper myOcWrap = OccupationCertificationSelector.getTargetsByViolation(myVioIdSet); 

        errorMsg = myOcWrap.ErrorMessage; 

        if(myOcWrap.ErrorMessage == null && myOcWrap.SObjectList.size() > 0) {

            List<OccupationCertification__c> myOcList = (List<OccupationCertification__c>)myOcWrap.SObjectList; 
            myOcWrap = null; 

            for(OccupationCertification__c myOc :myOcList) { 
                myTargetByVioMap.put(myOc.Violation__c, myOc); 
            }

            for(Violation__c myVio :violationList) {

                Date myEndDate; 
                String myStatus = RevSys_StaticUtility.INACTIVE;

                if(myVio.ReturnedToServiceDate__c != null ) { 
                    myEndDate  = myVio.ReturnedToServiceDate__c.addMonths(13);
                    myStatus   = RevSys_StaticUtility.ACTIVE; 
                }

                OccupationCertification__c myOc = myTargetByVioMap.get(myVio.Id); 

                if(myOc != null) {
                    myOc.StartDate__c = myVio.ReturnedToServiceDate__c; 
                    myOc.EndDate__c   = myEndDate;
                    myOc.Status__c    = myStatus; 

                    myUpdateOcList.add(myOc); 
                }
            }
        }

        if(myUpdateOcList.size() > 0) {
            errorMsg = DmlHelper.updateList(myUpdateOcList); 
        }

        SelectorWrapper myWrap = new SelectorWrapper(errorMsg,myUpdateOcList); 
       
        system.debug('HELPER ViolationHelper updateOccupationCertificationRecord-End');   
        return myWrap; 
    }
/**
    *——  ——————————————————————————————————————————————————
    * @Name: createOccupationCertificationRecord
    * @Description
    * Creates Occupation Certification record and that internally creates Employee Specific Requirement.
    *————————————————————————————————————————————————————
    * @params   List of Employee Hierarchy records
    * @returns  NULL
    *————————————————————————————————————————————————————
    **/
    public static SelectorWrapper insertOccupationCertificationRecord(List<Violation__c> ViolationList) {

        List<OccupationCertification__c> occCertList = new List<OccupationCertification__c>();
        List<EmployeeSpecificRequirement__c> empSpecReqList = new List<EmployeeSpecificRequirement__c>();
        Map<Id,String> empMap= new Map<Id,String>();
        String errMsgOC;
        String errMsgESR;
        
        SelectorWrapper wrapperViolationIds = ViolationSelector.getViolationRecords(ViolationList);
        if(wrapperViolationIds!=null) 
        {
            for(Violation__c vId : (List<Violation__c>) wrapperViolationIds.sObjectList) 
            {
                empMap.put(vId.Id,vId.Employee__r.Name);        
            }
        }
        System.debug('empMap------->'+empMap);
        
        for (Violation__c v: ViolationList)
        {
            Date   myEndDate; 
            String myStatus = RevSys_StaticUtility.INACTIVE;

            if(v.RecordTypeId == RevSys_StaticUtility.VIOLATION_SPARTN_EMP_RECTYPE_ID)
            {

                if(v.ReturnedToServiceDate__c != null ) {
                    myEndDate  = v.ReturnedToServiceDate__c.addMonths(13); 
                    myStatus   = RevSys_StaticUtility.ACTIVE;

                }

                OccupationCertification__c occCertObj = new OccupationCertification__c();
                occCertObj.RecordTypeId              = RevSys_StaticUtility.OCC_CERT_SPARTN_VIOLATION_RECTYPE_ID ;
                occCertObj.Name                      = v.Name +' '+ empMap.get(v.Id) + ' ' + Label.SPARTN_Violation_Target_Label; 
                occCertObj.Employee__c               = v.Employee__c;
                occCertObj.Violation__c              = v.Id;
                occCertObj.Status__c                 = myStatus; 
                occCertObj.StartDate__c              = v.ReturnedToServiceDate__c;
                occCertObj.EndDate__c                = myEndDate; 
                occCertObj.Frequency__c              = RevSys_StaticUtility.MONTHS;
                occCertObj.LengthOfPeriod__c         = RevSys_StaticUtility.LENGTH_OF_PERIOD ; 
                occCertObj.NumberOfTestsPerPeriod__c = RevSys_StaticUtility.NUMBER_OF_TESTS_PER_PERIOD ; 
                
                occCertList.add(occCertObj);
                system.debug('OCC------>'+occCertObj);
            }
        }
        errMsgOC = DmlHelper.insertList(occCertList);

        SelectorWrapper myWrap = new SelectorWrapper(errMsgOC, occCertList); 

        
        return myWrap; 
        
    }

    /**
    *——  ——————————————————————————————————————————————————
    * @Name: createEmployeeSpecificRequirements
    * @Description
    * Creates Occupation Certification record and that internally creates Employee Specific Requirement.
    *————————————————————————————————————————————————————
    * @params   List of Employee Hierarchy records
    * @returns  NULL
    *————————————————————————————————————————————————————
    **/
    public static String createEmployeeSpecificRequirements(List<OccupationCertification__c> theOcList) {

        //List<OccupationCertification__c> occCertList = new List<OccupationCertification__c>();
        List<EmployeeSpecificRequirement__c> empSpecReqList = new List<EmployeeSpecificRequirement__c>();
        //Map<Id,String> empMap= new Map<Id,String>();
        //String errMsgOC;

        String errMsg; 
        

        for(OccupationCertification__c occObj :theOcList)
        {
            EmployeeSpecificRequirement__c esrObj =  new EmployeeSpecificRequirement__c();
            esrObj.RecordTypeId      = RevSys_StaticUtility.EMP_SPEC_REQ_SPARTNTARGET_RECTYPE_ID;
            esrObj.EmployeeTarget__c = occObj.Employee__c;
            esrObj.Employee__c       = occObj.Employee__c;
            esrObj.Target__c         = occObj.Id;
            esrObj.StartDate__c      = Amtrak_DateUtility.determineThisStartDate(occObj.Frequency__c, occObj.StartDate__c); 
            esrObj.EndDate__c        = Amtrak_DateUtility.determineThisEndDate(occObj.Frequency__c, occObj.StartDate__c); 
            esrObj.PeriodName__c     = Amtrak_DateUtility.determineThisPeriod(occObj.Frequency__c, occObj.StartDate__c); 
            esrObj.TotalRequired__c  = occObj.NumberOfTestsPerPeriod__c;
            esrObj.Status__c         = RevSys_StaticUtility.ACTIVE;

            empSpecReqList.add(esrObj);
        }

        errMsg = DmlHelper.insertList(empSpecReqList); 


        return errMsg; 
   
    }

    /**
    *————————————————————————————————————————————————————
    * @Name: inactivateEsr
    * @Description - 
    *
    * 
    * @param    List<EPW_Hierarchy_Assignment__c> newHassList - list of Hierarchy Assignment
    *                                             records from the trigger 
    * @returns  String - error message from the process. 
    *————————————————————————————————————————————————————
    **/
    public static String inactivateEsr(List<Violation__c>  violationList) {
                                                                        
      
        system.debug('HELPER ViolationHelper inactivateEsr-Start');   
        system.debug('newViolationList  ' + violationList); 

        String errorMsg; 

        Set<id> myViolationIdSet = new Set<Id>(); 
        Set<id> myOcIdSet        = new Set<Id>(); 

        List<OccupationCertification__c>       myOcList  = new List<OccupationCertification__c>(); 
        List<OccupationSpecificRequirement__c> myOsrList = new List<OccupationSpecificRequirement__c>(); 
        List<EmployeeSpecificRequirement__c>   myEsrList = new List<EmployeeSpecificRequirement__c>(); 

        for(Violation__c myVio :violationList) { 
            myViolationIdSet.add(myVio.Id); 
        }

        // Get the Occupation Certifications 

        SelectorWrapper myOcWrap = OccupationCertificationSelector.getTargetsByViolation(myViolationIdSet); 

        errorMsg = myOcWrap.ErrorMessage; 

        if(myOcWrap.ErrorMessage == null && myOcWrap.SObjectList.size() > 0) {

            myOcList = (List<OccupationCertification__c>)myOcWrap.SObjectList; 
            myOcWrap = null; 

            for(OccupationCertification__c myOc :myOcList) { 
                myOc.Status__c = label.RevSys_Generic_Status_Inactive; 
                myOcIdSet.add(myOc.Id); 
            }
        }

        // Get the Employee Specific Requirements 
        SelectorWrapper myEsrWrap = EmployeeSpecificRequirementSelector.getOccEmpSpecRequirementsRelated(myOcIdSet);

        errorMsg += myEsrWrap.ErrorMessage; 

        if(myEsrWrap.ErrorMessage == null && myEsrWrap.SObjectList.size() > 0) {

            myEsrList = (List<EmployeeSpecificRequirement__c>)myEsrWrap.SObjectList; 
            myEsrWrap = null; 

            for(EmployeeSpecificRequirement__c myEsr :myEsrList) { 
                myEsr.Status__c = label.RevSys_Generic_Status_Inactive; 
            }

            errorMsg += DmlHelper.updateList(myEsrList);  
        }

        errorMsg = StringUtility.cleanupMessage(errorMsg); 

        system.debug('HELPER ViolationHelper inactivateTargets-End');   
        return errorMsg; 
    }
}
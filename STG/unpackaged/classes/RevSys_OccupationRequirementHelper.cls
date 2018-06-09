/**
*___________________________________________________
*@Name: RevSys_OccupationRequirementHelper
*@Author: Raj Kumar Pandy
*@Created: Date: 11/23/2017
*@Used_By: Review Systems
*___________________________________________________
*@Description: Inactivates the associated child records for the parent
* Holds generic helper methods for the Observation object relevent to the Review Systems application
* 
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/
global with sharing class RevSys_OccupationRequirementHelper {
    
    /**
    *————————————————————————————————————————————————————
    * @Name: deactivateChild()
    * @Description
    * Culls Occupation Certification records that have status as Inactive as per their record type
    *————————————————————————————————————————————————————
    * @param    theNewObsList	List of Occupation Certification records, generally from the trigger
    * @return   String		    Error message
    *————————————————————————————————————————————————————
    **/ 
    public static String deactivateChild(List<OccupationRequirement__c> theNewOccReqList)
    {
        system.debug('HELPER RevSys_OccupationRequirementHelper deactivateChild-Start');     
        
        string errMsg;
        String errMsg1;

        Set<ID> inactveOccReqRequirementSet = new Set<ID>();
        
        for(OccupationRequirement__c tempOccReq : theNewOccReqList)
            {
                if(tempOccReq.Status__c == RevSys_StaticUtility.INACTIVE && tempOccReq.RecordTypeId == RevSys_StaticUtility.OCCREQUIREMENT_SPARTNREQUIREMENT_RECTYPE_ID)
                {
                        inactveOccReqRequirementSet.add(tempOccReq.id);
                }
            } 
        if(inactveOccReqRequirementSet.size() > 0)
        {
            errMsg = deactivateOccSpecificReqChild(inactveOccReqRequirementSet);
            errMsg1 = deactivateEmpSpecificReqChild(inactveOccReqRequirementSet);
        }
        
        if(errMsg1!= NULL)
        {
            errMsg = errMsg + errMsg1;
        }
        
        system.debug('HELPER RevSys_OccupationCertificationHelper deactivateChild-End'); 
        return errMsg;
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Name: deactivateOccSpecificReqChild()
    * @Description
    * Fetches the associated OccupationSpecificRequirement child records and updates them
    *————————————————————————————————————————————————————
    * @param    inactveOccReqRequirementSet	Set of inactive Occupation Requirement records. Called from deactivateChild() method
    * @return   String 		        		The Error message
    *————————————————————————————————————————————————————
    **/ 
    public static string deactivateOccSpecificReqChild(Set<ID> inactveOccReqRequirementSet)
    {
        system.debug('HELPER RevSys_OccupationRequirementHelper deactivateOccSpecificReqChild-Start');     
        
        string errMsg;
        
        List<OccupationSpecificRequirement__c> occSpecificReqList = new List<OccupationSpecificRequirement__c>();
        
        List<OccupationSpecificRequirement__c> occSpecificReqUpdateList = new List<OccupationSpecificRequirement__c>();
        
        SelectorWrapper wrapper = OccupationSpecificRequirementSelector.getSpecificRequirements(inactveOccReqRequirementSet);
        
        occSpecificReqList = (List<OccupationSpecificRequirement__c>)wrapper.SobjectList;
        
        for(OccupationSpecificRequirement__c tempoccSpecificReq : occSpecificReqList)
        {
            tempoccSpecificReq.Status__c = RevSys_StaticUtility.INACTIVE;
            occSpecificReqUpdateList.add(tempoccSpecificReq);
        }
        
        errMsg = DmlHelper.updateList(occSpecificReqUpdateList);
        
        system.debug('HELPER RevSys_OccupationRequirementHelper deactivateOccSpecificReqChild-End'); 
        return errMsg;
    
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Name: deactivateEmpSpecificReqChild()
    * @Description
    * Fetches the associated OccupationSpecificRequirement child records and updates them
    *————————————————————————————————————————————————————
    * @param    inactveOccReqRequirementSet	Set of inactive Occupation Requirement records. Called from deactivateChild() method
    * @return   String 		        		The Error message
    *————————————————————————————————————————————————————
    **/ 
    public static string deactivateEmpSpecificReqChild(Set<ID> inactveOccReqRequirementSet)
    {
        system.debug('HELPER RevSys_OccupationRequirementHelper deactivateEmpSpecificReqChild-Start');     
        
        string errMsg;
        
        List<EmployeeSpecificRequirement__c> empSpecificReqList = new List<EmployeeSpecificRequirement__c>();
        
        List<EmployeeSpecificRequirement__c> empSpecificReqUpdateList = new List<EmployeeSpecificRequirement__c>();
        
        SelectorWrapper wrapper = EmployeeSpecificRequirementSelector.getOccReqEmpSpecificRequirements(inactveOccReqRequirementSet);
        
        empSpecificReqList = (List<EmployeeSpecificRequirement__c>)wrapper.SobjectList;
        
        for(EmployeeSpecificRequirement__c tempEmpSpecificReq : empSpecificReqList)
        {
            tempEmpSpecificReq.Status__c = RevSys_StaticUtility.INACTIVE;
            empSpecificReqUpdateList.add(tempEmpSpecificReq);
        }
        
        errMsg = DmlHelper.updateList(empSpecificReqUpdateList);
        
        system.debug('HELPER RevSys_OccupationRequirementHelper deactivateEmpSpecificReqChild-End'); 
        return errMsg;
    
    }

    /**
    *————————————————————————————————————————————————————
    * @Name: defaultObsName
    * @Description
    * Defaults the name of records with the SPARTN Observation record type
    *————————————————————————————————————————————————————
    * @param    inactveOccReqRequirementSet Set of inactive Occupation Requirement records. Called from deactivateChild() method
    * @return   String                      The Error message
    *————————————————————————————————————————————————————
    **/ 
    public static String defaultObsName(List<OccupationRequirement__c> theNewOccReqList)
    {
        system.debug('HELPER RevSys_OccupationRequirementHelper defaultObsName-Start');     
        
        string errMsg;
        
        for(OccupationRequirement__c theNew :theNewOccReqList) {
            if(theNew.RecordTypeId == Revsys_StaticUtility.OCCREQUIREMENT_SPARTNOBSERVATION_RECTYPE_ID) {
                theNew.Name = theNew.TestNumber__c + ' - ' + theNew.TestName__c; 
            }
        }
        system.debug('HELPER RevSys_OccupationRequirementHelper defaultObsName-End'); 
        return errMsg;
    
    }

}
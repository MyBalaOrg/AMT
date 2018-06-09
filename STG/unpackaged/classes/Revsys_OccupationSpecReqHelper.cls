/**
*___________________________________________________
*@Name: Revsys_OccupationSpecReqHelper
*@Author: Chuck Walley
*@Created: Date: 01/01/2018
*@Used_By: Review Systems
*___________________________________________________
*@Description: Various helper methods for Occupation Specific Requirement Records.
* 
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/

global with sharing class Revsys_OccupationSpecReqHelper {
    
    /**
    *————————————————————————————————————————————————————
    * @Name: addEmployeeViolationCheck
    * @Description
    * Checks to see if a Target/Observation is associated with a Violation Target. 
    * If so, it adds the Employee Violation Id to the Target/Observation
    *————————————————————————————————————————————————————
    * @param    theOsrList      List of Occupation Specific Requirement records, generally from the trigger
    * @return   String          Error message
    *————————————————————————————————————————————————————
    **/ 
    public static String addEmployeeViolationCheck(List<OccupationSpecificRequirement__c> theOsrList)
    {
        system.debug('HELPER Revsys_OccupationSpecReqHelper addEmployeeViolationCheck-Start');     
        
        string errMsg;

        List<OccupationSpecificRequirement__c> myTargetObsList 
                                        = new List<OccupationSpecificRequirement__c>(); 
        Set<Id> myTargetIdSet = new Set<Id>(); 

        // Collect recrods with SPARTN Target record types 
        // Collect 
        for(OccupationSpecificRequirement__c theOsr :theOsrList) {
            if(theOsr.RecordTypeId == RevSys_StaticUtility.OCC_SPEC_REQ_SPARTNTARGET_RECTYPE_ID) {
                myTargetObsList.add(theOsr); 
                myTargetIdSet.add(theOsr.Target__c); 
            }
        }

        // Get the Associated Violation Target records 

        SelectorWrapper myWrap = OccupationCertificationSelector.getViolationTargets(myTargetIdSet); 

        errmsg = myWrap.ErrorMessage;
        List<OccupationCertification__c> myTargetList = myWrap.SObjectList; 

        if(errMsg == null && myTargetList != null) {
            errMsg = addEmployeeViolation(myTargetObsList, myTargetList); 
        }
        
        system.debug('HELPER Revsys_OccupationSpecReqHelper addEmployeeViolationCheck-End'); 
        return errMsg;
    }
    /**
    *————————————————————————————————————————————————————
    * @Name: addEmployeeViolation
    * @Description
    * Called by addEmployeeViolationCheck. Adds the Employee Validation record Id 
    * to the OSR (Target/Object) record 
    *————————————————————————————————————————————————————
    * @param    theOsrList      OSR records which have SPARTN Target record types 
    *           theTargetList   Associated Occ Cert records with SPARTN Violation Target record types  
    * @return   String          Error message
    *————————————————————————————————————————————————————
    **/ 
    private static String addEmployeeViolation(List<OccupationSpecificRequirement__c>   theOsrList, 
                                              List<OccupationCertification__c> theTargetList)
    {
        system.debug('HELPER Revsys_OccupationSpecReqHelper addEmployeeViolation-Start');     
        
        string errMsg;

        // Create a map to carry the Targets  

        Map<Id,OccupationCertification__c> myTargetMap = new Map<Id,OccupationCertification__c>(); 

        // Loop through Targets and map them 
        for(OccupationCertification__c theTarget :theTargetList) {
            myTargetMap.put(theTarget.Id, theTarget); 
        }

        // Loop through OSR records which have SPARTN Target record types. Match them with 
        // a Violation target to get the Employee Violation. 
        for(OccupationSpecificRequirement__c theOsr :theOsrList) {
            OccupationCertification__c myTarget =  myTargetMap.get(theOsr.Target__c); 

            if(myTarget != null) {
               theOsr.Violation__c = myTarget.Violation__c; 
            }
        }
        
        system.debug('HELPER Revsys_OccupationSpecReqHelper addEmployeeViolation-End'); 
        return errMsg;
    }

     /**
    *————————————————————————————————————————————————————
    * @Name: addReqToESR
    * @Description
    * Used to create Employee Specific Requirements to the Employee Certification
    * when a new OSR is added 
    *————————————————————————————————————————————————————
    * @param    newOsrList      OSR records which have SPARTN Certification record types 
    * @return   
    *————————————————————————————————————————————————————
    **/ 

   public static String addReqToESR(List<OccupationSpecificRequirement__c> newOsrList){
       
       system.debug('HELPER Revsys_OccupationSpecReqHelper addReqToESR - Start');
       
       String errMsg;
       Set<Id> occCertIdSet = new Set<Id>();
       List<EmployeeCertification__c> empCert = new List<EmployeeCertification__c>();
       List<EmployeeSpecificRequirement__c> esrList = new List<EmployeeSpecificRequirement__c>();
       
       for(OccupationSpecificRequirement__c tmpOsrObj : newOsrList)
       {
           if(tmpOsrObj.RecordTypeId ==  RevSys_StaticUtility.OCCSPECREQUIREMENT_SPARTNCERT_RECTYPE_ID){
           		occCertIdSet.add(tmpOsrObj.Certification__c);
           }
       }
       
       SelectorWrapper wrapper = EmployeeCertificationSelector.getEmpCertFromOccCertId(occCertIdSet);
       
       if(wrapper != null){
           empCert = (List<EmployeeCertification__c>) wrapper.SObjectList;
           for(EmployeeCertification__c cert : empCert){
               esrList.addAll(RevSys_EmployeeCertificationHelper.mapEmpSpecReq(cert, newOsrList));

           }
       }
      
       if(!esrList.isEmpty()){
           errMsg = DmlHelper.insertList(esrList);
       }

       system.debug('HELPER Revsys_OccupationSpecReqHelper addReqToESR - End');
       return errMsg;
	}
}
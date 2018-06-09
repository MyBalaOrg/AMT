public class OccupationSpecificRequriementWrapper {

/**
*___________________________________________________
*@Name:     OccupationSpecificRequriementWrapper
*@Author:   Sudhindra Katti
*@Created:  Date: 12/12/2017
*@Used_By:  RevSys_EmployeeCertificationHelper 
*___________________________________________________
*@Description: Wrapper class for OccupationSpecificRequirement__c object 
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/
    
    
    public list<OccupationSpecificRequirement__c> oscrequirements {get; set;}
    public string EarliestDate { get; set;}
    
    public void OccupationSpecificRequriementWrapper(Set<ID> OccCertSet)
    {
        SelectorWrapper wrapper = OccupationSpecificRequirementSelector.getOccSpecReqCertification(OccCertSet);      
        oscrequirements = (List<OccupationSpecificRequirement__c>)wrapper.SobjectList;
    }

}
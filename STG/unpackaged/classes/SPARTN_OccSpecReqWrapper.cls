/**
*___________________________________________________
*@Name: SPARTN_ObservationController
*@Author: Boom Bertetti
*@Created: Date: 3/06/2018
*@Used_By: SPARTN_ObservationController 
*___________________________________________________
*@Description: 
* A wrapper class to maintian the grouping of Occupation Specific Requirement by Department/Craft
*___________________________________________________
*@Changes: 
* 
**/
public class SPARTN_OccSpecReqWrapper {
    public Boolean selected {get; set;}
    public String testNumber {get; set;}
    public String testName {get; set;}
    public Map<String, Map<String, Boolean>> deptCraftMap {get; set;}
    public Map<String, Boolean> allCraftDeptMap {get; set;}
    public List<OccupationSpecificRequirement__c> osrList {get; set;}
    public list<String> speedCheckMethodList {get;set;}
    
    public SPARTN_OccSpecReqWrapper() {
        this.selected = false;
    }
    
    public SPARTN_OccSpecReqWrapper(OccupationSpecificRequirement__c osr) {
        this.selected = false;
        this.deptCraftMap = new Map<String, Map<String, Boolean>>();
        this.allCraftDeptMap = new Map<String, Boolean>();
        this.testNumber = osr.Observation__r.TestNumber__c;
        this.testName = osr.Observation__r.TestName__c;
        
        if(osr.Observation__r.SpeedCheckMethod__c != null){
            this.speedCheckMethodList = osr.Observation__r.SpeedCheckMethod__c.split(';');
        }
    }
}
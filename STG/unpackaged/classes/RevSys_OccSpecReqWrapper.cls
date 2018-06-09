public class RevSys_OccSpecReqWrapper {
    public Boolean selected {get; set;}
    public String testNumber {get; set;}
    public String testName {get; set;}
    public Map<String, Map<String, Boolean>> deptCraftMap {get; set;}
    public Map<String, Boolean> allCraftDeptMap {get; set;}
    public List<OccupationSpecificRequirement__c> osrList {get; set;}
    public list<String> speedCheckMethodList {get;set;}
    
    public RevSys_OccSpecReqWrapper() {
        this.selected = false;
    }
    
    public RevSys_OccSpecReqWrapper(OccupationSpecificRequirement__c osr) {
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
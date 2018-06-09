/**
*————————————————————————————————————————————————————
* @Name             RevSys_TestEntryWrapper
* @Author           Duy Tran
* @Created Date     01-08-2018
* @Used By          Any apex class controllers that
*                   utilize the custom observation ui functionality
*————————————————————————————————————————————————————
* @Description
* Wrapper Class for custom Observation Test Form
* It contains properties to identify that the observation is 
* selected when user is selecting Test and all required fields
* are completed
*————————————————————————————————————————————————————
* @Changes
* 02-09-2018 [Boom Bertetti] Added Description
* 05-29-2018 [Boom Bertetti] Added isFRAtest to controller the displayed in FORM-1872
**/
public class RevSys_TestEntryWrapper {
    public Boolean selected {get; set;}
    public Boolean display {get; set;}
    public Boolean completed {get; set;}
    public String testNumber {get; set;}
    public String employeeName {get; set;}
    public Observation__c obs {get; set;}
    public OccupationSpecificRequirement__c osr {get; set;}
    public Map<String, Boolean> requiredFields {get; set;}
    public List<RevSys_EmployeeWrapper> empList {get; set;}
    public List<Finding__c> findingList {get; set;}
    public List<String> speedCheckMethodList {get; set;}
    public String employeeId {get; set;}
    public String department {get; set;}
    public String craft {get; set;}
    public String entryKey {get; set;}
    public SearchTabularItemWrapper searchItem {get; set;}
    public boolean checkMethodReq {get; set;}
    public boolean checkMethodPermitted {get; set;}
    public boolean isFRAtest {get; set;}

    public RevSys_TestEntryWrapper() {
        this.selected = false;
    }
    public RevSys_TestEntryWrapper(OccupationSpecificRequirement__c osr, Observation__c obs) {
        this(osr, obs, null, '');
    }
    public RevSys_TestEntryWrapper(OccupationSpecificRequirement__c osr, Observation__c obs, String employeeName, String employeeInfo) {
        this.selected = false;
        this.osr = osr;
        this.obs = obs;
        this.testNumber = osr.Observation__r.TestNumber__c;
        this.employeeName = employeeName;
        if (employeeInfo != null && !String.isBlank(employeeInfo)) {
            List<String> employeeInfoList = employeeInfo.split(',');
            if (employeeInfoList.size() == 3) {
                this.employeeId = employeeInfoList[0];
                this.department = employeeInfoList[1];
                this.craft = employeeInfoList[2];
            }
        }
        this.entryKey = osr.Id + '-' + obs.Employee__c;
        if(osr.Observation__r.SpeedCheckMethod__c != null){
            this.speedCheckMethodList = osr.Observation__r.SpeedCheckMethod__c.split(';');
            
            String checkMethodReqInOR = osr.Observation__r.Check_Method_Required__c;
            if(checkMethodReqInOR != null){
                if(checkMethodReqInOR.equalsIgnoreCase('Yes - Required')){
                    this.checkMethodPermitted = true;
                    this.checkMethodReq = true;
                }else if (checkMethodReqInOR.equalsIgnoreCase('Yes - Not Required')){
                    this.checkMethodPermitted = true;
                    this.checkMethodReq = false;
                }else{
                    this.checkMethodPermitted = false;
                    this.checkMethodReq = false;
                }
            	//this.checkMethodReq = (checkMethodReqInOR.equalsIgnoreCase('Yes')) ? true : false;    
            }else{
                this.checkMethodPermitted = false;
                this.checkMethodReq = false;
            }
            
        }
        this.requiredFields = new Map<String, Boolean>();
        this.empList = new List<RevSys_EmployeeWrapper>();
        this.findingList = new List<Finding__c>();
    }
    public RevSys_TestEntryWrapper(OccupationSpecificRequirement__c osr, Observation__c obs, SearchTabularItemWrapper employee) {
        this.selected = false;
        this.osr = osr;
        this.obs = obs;
        this.testNumber = osr.Observation__r.TestNumber__c;
        this.employeeName = employee.theName;
        this.employeeId = employee.theNumber;
        this.department = employee.department;
        this.craft = employee.craft;
        this.entryKey = osr.Id + '-' + obs.Employee__c;
        if(osr.Observation__r.SpeedCheckMethod__c != null){
            this.speedCheckMethodList = osr.Observation__r.SpeedCheckMethod__c.split(';');
            
            String checkMethodReqInOR = osr.Observation__r.Check_Method_Required__c;
            if(checkMethodReqInOR != null){
                if(checkMethodReqInOR.equalsIgnoreCase('Yes - Required')){
                    this.checkMethodPermitted = true;
                    this.checkMethodReq = true;
                }else if (checkMethodReqInOR.equalsIgnoreCase('Yes - Not Required')){
                    this.checkMethodPermitted = true;
                    this.checkMethodReq = false;
                }else{
                    this.checkMethodPermitted = false;
                    this.checkMethodReq = false;
                }
            	//this.checkMethodReq = (checkMethodReqInOR.equalsIgnoreCase('Yes')) ? true : false;    
            }else{
                this.checkMethodPermitted = false;
                this.checkMethodReq = false;
            }
            
        }    
    }
    public RevSys_TestEntryWrapper(OccupationSpecificRequirement__c osr, Observation__c obs, SearchTabularItemWrapper employee, List<String> fraTestNumbers) {
        this(osr, obs, employee);
        if (fraTestNumbers.contains(osr.Observation__r.TestNumber__c)) {
            this.isFRAtest = true;
        }
    }
}
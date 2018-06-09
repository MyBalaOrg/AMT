/**
*————————————————————————————————————————————————————
* @Name             SPARTN_EmployeeWrapper
* @Author           Duy Tran
* @Created Date     01-08-2018
* @Used By          RevSys_TestEntryWrapper
*————————————————————————————————————————————————————
* @Description
* Wrapper Class for custom SPARTN Observation form
*————————————————————————————————————————————————————
* @Changes
* 
**/
public class SPARTN_EmployeeWrapper {
    public Boolean selected {get; set;}
    public String name {get; set;}
    public String recordId {get; set;}
    public String department {get; set;}
    public List<String> craftList {get; set;}
}
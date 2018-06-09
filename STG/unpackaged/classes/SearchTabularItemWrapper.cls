/**
*————————————————————————————————————————————————————
* @Name             SearchTabularItemWrapper
* @Author           Duy Tran
* @Created Date     01-08-2018
* @Used By          Any apex class controllers that
*                   utilize the custom search functionality
*————————————————————————————————————————————————————
* @Description
* Wrapper Class for Search functionality with tabular results
* Originally created for Review System
*————————————————————————————————————————————————————
* @Changes
* by Boom Bertetti  02-12-2018
*                   Added theName, theNumber,department, craft and addtionalFieldandValueMap
**/
public class SearchTabularItemWrapper {
    public Boolean selected {get; set;}
    public Id recordId {get; set;}
    public String theName {get; set;}
    public String theNumber {get; set;}
    public String department {get; set;}
    public String craft {get; set;}
    public List<String> fieldNames {get; set;}
    public List<String> fieldValues {get; set;}
    public List<RevSys_TestEntryWrapper> testNames {get; set;}
    public Map<String, String> additionalFieldandValueMap {get; set;}
}
/**
*————————————————————————————————————————————————————
* @Name             RevSys_TestWithObservationsWrapper
* @Author           Boom Bertetti
* @Created Date     02-09-2018
* @Used By          Any apex class controllers that
*                   utilize the custom observation ui functionality
*————————————————————————————————————————————————————
* @Description
* Wrapper Class for custom Observation Test Form
* It contains properties to display RevSys_TestEntryWrapper by Test Number
* and display the completion of each test based on number of 
* completed observations.
*————————————————————————————————————————————————————
* @Changes
**/
public class RevSys_TestWithObservationsWrapper {
    public Boolean selected {get; set;}
    public Boolean expand {get; set;}
    public String testNumber {get; set;}
    public String testName {get; set;}
    public List<RevSys_TestEntryWrapper> entryList {get; set;}
    public List<Boolean> completedObsList {get; set;}

    public RevSys_TestWithObservationsWrapper(String testNumber, String testName, List<RevSys_TestEntryWrapper> entryList) {
        this.selected = false;
        this.expand = false;
        this.testNumber = testNumber;
        this.testName = testName;
        this.entryList = entryList;
        this.completedObsList = new list<Boolean>();
    }

}
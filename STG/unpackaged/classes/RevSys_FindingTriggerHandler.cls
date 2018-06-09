/**
*___________________________________________________
*@Name: RevSys_FindingTriggerHandler
*@Author: Colin Caldwell
*@Created: Date: 01/26/2018
*@Used_By: SPARTN
*___________________________________________________
*@Description: Finding Trigger Handler for Review Systems Records 
* This class extends the Trigger Handler and invokes the Handler for further logic.
* Put the logic in a helper/utility class. 
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/
public class RevSys_FindingTriggerHandler extends TriggerHandler{

    public override void afterUpdate() {
    	
        Revsys_FindingFieldHistoryHelper.checkForAfterSubmitted(newList, newMap, oldMap);


    }
}
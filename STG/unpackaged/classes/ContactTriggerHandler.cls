/*
    Generic Contact Trigger helper to implement Contact functionality as per Trigger Context. Application specific contact functionality should be added in this class appropriately by creating
	new classes as required. For example Organization Chart related functionality is marked by prefix by OC_<ClassName> . Each application then will handle application specific functionality in separate
	classes to make this extensible.
    **********************************************************
    Audit History
    **********************************************************
    2014-09-15      Sarang Padhye         Created 
    **********************************************************  
*/

public class ContactTriggerHandler extends TriggerHandler {
    
    public override void afterUpdate() {
        //Add Application specific methods for after Update Context
        system.debug('CTH : Method afterUpdate');
        OC_ContactTriggerHandler.deactivateUsers(newList);
        EIS_contactTriggerHelper.updatePositionContact(newList,oldList,newMap,oldMap);
    }
    
    public override void afterInsert(){
        EIS_contactTriggerHelper.updatePositionContact(newList,oldList,newMap,oldMap);
    }
    
    public override void afterDelete(){}
    

}
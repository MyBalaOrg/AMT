/*
    Generic User Trigger helper to implement User functionality as per Trigger Context. Application specific contact functionality should be added in this class appropriately by creating
	new classes as required. For example Organization Chart related functionality is marked by prefix by OC_<ClassName> . Each application then will handle application specific functionality in separate
	classes to make this extensible.
    **********************************************************
    Audit History
    **********************************************************
    2014-09-15      Sarang Padhye         Created 
    **********************************************************  
*/


public class UserTriggerhandler extends TriggerHandler{
    
    public override void beforeInsert() {
        //Add Application specific methods for before Insert Context
        
        //default user fields before insert
        OC_UserTriggerHandler.autopopulateFieldsForUsersBeforeInsert(newList);
        
    }
    
    
    public override void afterInsert() {
        //Add Application specific methods for after Insert Context
        
        //default user fields after insert
        OC_UserTriggerHandler.autopopulateFieldsForUsersAfterInsert(newList);
    }
    
    

}
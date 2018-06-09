/*
    Generic Process Team Trigger helper to implement Process Team functionality as per Trigger Context. Application specific contact functionality should be added in this class appropriately by creating
	new classes as required. For example Organization Chart related functionality is marked by prefix by OC_<ClassName> . Each application then will handle application specific functionality in separate
	classes to make this extensible.
    **********************************************************
    Audit History
    **********************************************************
    2017-07-25      Sarang Padhye         Created 
    **********************************************************  
*/
public class ProcessTeamHandler extends Triggerhandler{
	
    //Before Update
     public override void beforeInsert() {
        //Add Application specific methods for after Update Context
        
        system.debug('CTH : Method before insert');
        SafeTrend_ProcessTeamHandler.updateUserBeforeInsert(newList);
        
    }
    
    //After Insert
    public override void afterInsert() {
        system.debug('CTH : Method after insert');
        SafeTrend_ProcessTeamHandler.updateUserAfterInsert(newList);
    }
    
    //After Update
    public override void afterUpdate() {
        system.debug('CTH : Method after Update');
        SafeTrend_ProcessTeamHandler.updateUserAfterUpdate(newList);
    }
    
}
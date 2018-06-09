// ****************************************************************************************************************
// Trigger: User Trigger 
// Author:  Sarang Padhye, Deloitte Digital
// Date:    Feb 24, 2017
// Description: Master Trigger to handle all User related functionality.
//
// Modifications: 
// 1.00: Created     
//

trigger UserTrigger on User (before insert,before update,after insert, after update) {
  
    new UserTriggerhandler().process();
}
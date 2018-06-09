trigger EpwHierarchyAssignmentTrigger on EPW_Hierarchy_Assignment__c (before insert, after insert,
                                                                      before update, after update)  { 
    String ErrorMessage; 
   
    if (!RevSys_OrgSettingsUtil.isEpwHierarchyAssignmentTriggerBypassEnabled() && 
        StaticUtils.hasAccess('SPARTN_User')) {
            system.debug('ENTERING SPARTN LOGIC'); 
            new Revsys_HierarchyAssignmentHandler().process();  
            errorMessage = EpwHierarchyAssignmentStaticUtility.TriggerErrorMessage;  
    }
    
    if(errorMessage != null) { 
        trigger.new[0].addError(errorMessage); 
    }
}
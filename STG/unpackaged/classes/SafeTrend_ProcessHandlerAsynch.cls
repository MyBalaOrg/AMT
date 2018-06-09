/**
*___________________________________________________
*@Name: SafeTrend_ProcessHandlerAsynch
*@Author: Sarang Padhye
*@Created: Date: 7/20/2017
*@Used_By: SafeTrends App
*___________________________________________________
*@Description: This class contains asynchronous methods to insert permission sets and public groups
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/

global class SafeTrend_ProcessHandlerAsynch {
    /**
* This method performs DML operation to insert public groups in to the database
* @param List<String> AssigneeId List of eligible user ids
* @param List<String> teamRoles List of team roles
* @param List<String> processNames List of processes
* @param List<String> List<String> groupNames List of groupNames
* @return Nothing
*/    
    
    @future
    public static void publicGroupAssignment(List<String> AssigneeId,List<String> teamRoles,List<String> processNames,List<String> groupNames) {
        system.debug('FUTURE publicGroupAssignment Enter');
        
        List<groupmember> grpMemToBeAssigned = new List<groupMember>();
        List<Id> groupIDList = new List<ID>();
        Map<String,ID> groupNameToID = new Map<String,Id>();
        
        try {
            //fetch group IDs based on group names
            for(group g : [select id,Name from group where Name =:groupNames]) {
                if(g!=null) {
                    groupNameToID.put(g.Name,g.Id);
                }
            }
            
            for(Integer i = 0; i<AssigneeID.size();i++) {
                //Assign the user to the user Group
                GroupMember newGroupMember = new GroupMember();
                String groupName = processNames.get(i) + ' ' + teamRoles.get(i);
                newGroupMember.GroupId = groupNameToID.get(groupName);
                newGroupMember.UserOrGroupId = AssigneeID.get(i);
                grpMemToBeAssigned.add(newGroupMember);
                
            }
            
            // Insert GroupMember
            if(grpMemToBeAssigned.size()>0) insert grpMemToBeAssigned;
            
        } catch(Exception e) {
            system.debug('ERROR : '+e.getMessage());
        }
        
        system.debug('FUTURE publicGroupAssignment Exit');
        
    }
    
    /**
* This method performs DML operation to insert permission set in to the database
* @param List<String> AssigneeId List of eligible user ids
* @param List<String> teamRoles List of team roles
* @return Nothing
*/        
    @future
    public static void permSetAssignment(Map<id,String> userIdToTeamRole) {
        system.debug('FUTURE permSetAssignment Enter');
        List<permissionSetAssignment> permSetToBeAssigned = new List<permissionsetAssignment>();
        List<groupmember> grpMemToBeAssigned = new List<groupMember>();
        List<Id> groupIDList = new List<ID>();
        
        Id facilitatorPermissionSetId;
        Id observerPermissionSetID;
        Id dataEntryClerk;
        
        try {
            //fetch the ids of Facilitator , Observer and Data Entry Clerk based on the name
            for(permissionset pm : [select id, Name from permissionset where (Name =: system.Label.Safe_Trend_Facilitator_Permission_Set OR Name =: system.Label.Safe_Trend_Observer_Permission_Set OR Name =: system.Label.Safe_Trend_Data_Entry_Clerk_Permission_Set	)]) {
                if(pm.Name == system.Label.Safe_Trend_Facilitator_Permission_Set) facilitatorPermissionSetId = pm.id;
                if(pm.Name == system.Label.Safe_Trend_Observer_Permission_Set) observerPermissionSetID = pm.id;
                if(pm.Name == system.Label.Safe_Trend_Data_Entry_Clerk_Permission_Set) dataEntryClerk = pm.id;
            }
            
            //If user Map is not Empty
            if(!userIdToTeamRole.isEmpty()) {
                //Loop over the map
                for(Id assigneeId : userIdToTeamRole.keySet()) {
                    String permissionSetId = '';
                    permissionSetAssignment newPermAssign = new permissionsetAssignment();
                    newPermAssign.AssigneeId = assigneeId;
                    //Assign correct permission set based on the Team Role
                    if(userIdToTeamRole.get(assigneeId) == system.Label.Safe_Trend_Facilitator_Role) {
                        permissionSetId = facilitatorPermissionSetId;
                    }
                    else if(userIdToTeamRole.get(assigneeId) == system.Label.Safe_Trend_Observer_Role) {
                        permissionSetId = observerPermissionSetID;
                        
                    } else if(userIdToTeamRole.get(assigneeId) == system.Label.Safe_Trend_Data_Entry_Role) {
                        permissionSetId = dataEntryClerk;   
                    }
                    newPermAssign.PermissionSetId = permissionSetId;
                    permSetToBeAssigned.add(newPermAssign);
                }
            }
            // Insert Permissions
            if(permSetToBeAssigned.size()>0) insert permSetToBeAssigned;
            
            
            system.debug('FUTURE permSetAssignment Enter');
            
        } catch(Exception e) {
            system.debug('ERROR '+e.getMessage());
        }
        
    }
    
    /**
* This method performs DML operation to delete public groups in to the database
* @param List<String> AssigneeId List of eligible user ids
* @param List<String> teamRoles List of team roles
* @param List<String> processNames List of processes
* @param List<String> List<String> groupNames List of groupNames
* @return Nothing
*/    
    
    @future
    public static void removeUserfromPublicGroup(List<String> AssigneeId,List<String> teamRoles,List<String> processNames,List<String> groupNames) {
        system.debug(' *************************FUTURE removeUserfromPublicGroup Enter');
        List<Id> groupIDList = new List<ID>();
        Map<String,ID> groupNameToID = new Map<String,Id>();
        List<ID> setGroupId = new List<ID>();
        List<ID> setUserOrGroupId = new List<ID>();
        Map<Id,Id> userToGroupId = new Map<Id,Id>();
        List<GroupMember> grpMemToBeDeleted = new List<GroupMember>();
        try {
            //fetch group IDs based on group names
            for(group g : [select id,Name from group where Name =:groupNames]) {
                if(g!=null) {
                    groupNameToID.put(g.Name,g.Id);
                }
            }
            
            for(Integer i = 0; i<groupNames.size();i++) {
                //Assign the user to the user Grou
                String groupName = processNames.get(i) + ' ' + teamRoles.get(i);
                ID GroupId = groupNameToID.get(groupName);
                //Create Map of user to Group
                userToGroupId.put(AssigneeID.get(i),GroupId);
                
            }
           //Loop through group members to find the groupmembers to be deleted
            if( !userToGroupId.isEmpty() ) {
                List<GroupMember> ListGM  = [ Select Id,GroupId,UserOrGroupID from GroupMember where UserOrGroupID in :userToGroupId.keySet()];
                 if(ListGM.size() > 0) {
                    for(GroupMember pb : ListGM) {
                        if(pb.GroupId== userToGroupId.get(pb.UserOrGroupId)){
                            grpMemToBeDeleted.add(pb);
                        }
                    }
                }
				//Delete Group Members                
                if(grpMemToBeDeleted.size() > 0) delete grpMemToBeDeleted;
            }
        } catch(Exception e) {
            system.debug('ERROR :'+e.getMessage());
        }
        
        system.debug(' FUTURE removeUserfromPublicGroup Exit');        
    }
    /**
* This method performs DML operation to delete permission set in to the database
* @param List<String> AssigneeId List of eligible user ids
* @param List<String> teamRoles List of team roles
* @return Nothing
*/            
    @future
    public static void removePermSetAssignment(Map<Id,String> userIdToTeamRole) {
        system.debug(' FUTURE removePermSetAssignment Enter');
        
        List<permissionSetAssignment> permSetToBeDeleted = new List<permissionsetAssignment>();
        Map<id,id> userToPermId = new Map<id,id>();
        
        Id facilitatorPermissionSetId;
        Id observerPermissionSetID;
        Id dataEntryClerk;
        
        try {
            //fetch the ids of Facilitator , Observer and Data Entry Clerk based on the name
            for(permissionset pm : [select id, Name from permissionset where (Name =: system.Label.Safe_Trend_Facilitator_Permission_Set OR Name =: system.Label.Safe_Trend_Observer_Permission_Set OR Name =: system.Label.Safe_Trend_Data_Entry_Clerk_Permission_Set	)]) {
                if(pm.Name == system.Label.Safe_Trend_Facilitator_Permission_Set) facilitatorPermissionSetId = pm.id;
                if(pm.Name == system.Label.Safe_Trend_Observer_Permission_Set) observerPermissionSetID = pm.id;
                if(pm.Name == system.Label.Safe_Trend_Data_Entry_Clerk_Permission_Set) dataEntryClerk = pm.id;
            }
            //If user Map is not Empty
            if(!userIdToTeamRole.isEmpty()) {
                //Loop over the map
                for(Id assigneeId : userIdToTeamRole.keySet()) {
                    String permissionSetId = '';
                    
                    //Assign correct permission set based on the Team Role
                    if(userIdToTeamRole.get(assigneeId) == system.Label.Safe_Trend_Facilitator_Role) {
                        permissionSetId = facilitatorPermissionSetId;
                    }
                    else if(userIdToTeamRole.get(assigneeId) == system.Label.Safe_Trend_Observer_Role) {
                        permissionSetId = observerPermissionSetID;
                        
                    } else if(userIdToTeamRole.get(assigneeId) == system.Label.Safe_Trend_Data_Entry_Role) {
                        permissionSetId = dataEntryClerk;   
                    }
 					
                    //Create a map of user and permission set Id
                    userToPermId.put(assigneeId, permissionSetId);
                }
            }
             //Loop through permsetassignment to find the permsetassignments to be deleted
            if( !userToPermId.isEmpty() )
            {
                List<permissionsetassignment> ListPA  = [ Select Id,AssigneeId,PermissionSetId from permissionsetassignment where assigneeid in :userToPermId.keySet()];
                if(ListPA.size() > 0) {
                    for(permissionsetassignment pa : ListPA) {
                        if(pa.PermissionSetId == userToPermId.get(pa.AssigneeId)){
                            permSetToBeDeleted.add(pa);
                        }
                    }
                }
                
                if(permSetToBeDeleted.size() > 0) delete permSetToBeDeleted;
            }        
            
        } catch(Exception e) {
            system.debug('ERROR '+e.getMessage());
        }
        system.debug(' FUTURE removePermSetAssignment Exit');
    }
    
}
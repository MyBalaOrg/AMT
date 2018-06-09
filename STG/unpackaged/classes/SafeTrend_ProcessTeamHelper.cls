/**
*___________________________________________________
*@Name: SafeTrend_ProcessTeamHelper
*@Author: Sarang Padhye
*@Created: Date: 7/20/2017
*@Used_By: SafeTrends App
*___________________________________________________
*@Description: This class is a helper class which contains methods to support after insert / after update functionality. Methods are called from SafeTrend_ProcessTeamHandler
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/

public class SafeTrend_ProcessTeamHelper {
    
    /**
* This method assigns the correct permission sets and public groups when the user updates the process team record by changin the status or changing the team role
* @param Set<Id> Set of user ids.
* @param Map<Id,process_team__c> Map of user id to process_team__c record
* @return Set<Id> Set of user Ids eligible for the perm set assignment
*/    
    public static Map<Id,process_team__c> getElligibleUserToBeAssigned(Map<Id,process_team__c> userMap,Boolean checkOldTeamRole){
        system.debug('****PTH - getElligibleUsers Enter');
        List<process_Team__c> processTeamList = new List<process_team__c>();
        Map<Id,process_team__c> usersToBeAssigned = new Map<Id,process_team__c>();
        Set<process_team__c> assignedFlagSet = new Set<process_team__c>();
        try{
            //Query Existing Process Teams
            processTeamList = [select id,User__c,Team_Role__c,Team_Member_Status__c from process_team__c where user__c in: userMap.keySet()];
            
            //For every user
            for(Id uId : userMap.keySet()) {
                Boolean isUserPartOfOtherProcessTeam = false;
                process_Team__c procTeam = userMap.get(uId);
                process_Team__c procTeamTobechecked;
                String teamRole;
                //Check for old record
                if(checkOldTeamRole) 
                    procTeamTobechecked = (Process_Team__c)Trigger.oldMap.get(procTeam.Id);
                else 
                    procTeamTobechecked = procTeam;
                
                if(procTeam!=null) {
                    //Check if the user is part of existing process team with the same role
                    for(process_team__c pt : processTeamList) {
                        
                        if(pt.User__c == procTeamTobechecked.User__c && pt.Team_Role__c == procTeamTobechecked.Team_Role__c && pt.Id != procTeamTobechecked.Id && pt.Team_Member_Status__c == 'Active') {
                            isUserPartOfOtherProcessTeam = true;
                        }
                    }
                    //Add user only if its a different role
                    if(isUserPartOfOtherProcessTeam == false) {
                        usersToBeAssigned.put(procTeamTobechecked.User__c,procTeamTobechecked);
                        
                    }
                } else system.debug('User is Not Available');
            }
            
        } catch(Exception e) {
            system.debug('ERROR : '+e.getMessage());
        }
        
        system.debug('****PTH - getElligibleUsers Exit');
        
        return usersToBeAssigned;
    }
    
    /**
* This method calls future method to assign permission set
* @param Set<Id> Set of user ids.
* @param Map<Id,process_team__c> Map of user id to process_team__c record
* @return List<String> List Of user Ids which are assigned permission set
*/    
    //Assign the desired permission set asynchronously
    public static void assignPermissionSet(Map<ID,process_team__c> userMap) {
        system.debug('*******PTH - assignPermissionSet Enter');
        List<String> assignedPermSets = new List<String>();
        Map<Id,String> userIdToTeamRole = new Map<Id,String>();
        
        try {
            //For every user
            for(ID userid :userMap.keySet() ) {
                Id userKey = userId;
                process_team__c procTeam = userMap.get(userKey);
                if(procTeam!=null) {
                    //Collect the user id and the Team Role
                    if(procTeam.Team_Member_Status__c == 'Active') {
                        userIdToTeamRole.put(userid,procTeam.Team_Role__c);
                    }
                } else system.debug('User is Not Available');
            }
            //Assign Perm set
            SafeTrend_ProcessHandlerAsynch.permSetAssignment(userIdToTeamRole);
            
        } catch (Exception e) {
            system.debug('ERROR : '+e.getMessage());
        }
        system.debug('*******PTH - assignPermissionSet Exit');
    }
    
    /**
* This method calls future method to assign public groups
* @param Set<Id> Set of user ids.
* @param Map<Id,process_team__c> Map of user id to process_team__c record
* @return List<String> List Of user Ids which are assigned permission set
*/    
    
    //Assign public groups asynchronously
    public static void assignPublicGroups(Map<ID,process_team__c> userMap) {
        system.debug('*******PTH - assignPublicGroups Enter');
        List<String> assigneeId = new List<String>();
        List<String> teamRoles = new List<String>();
        List<String> processNames = new List<String>();
        List<String> groupNames = new List<String>();
        try {
            //For every user
            for(ID userid : userMap.keySet()) {
                Id userKey = userId;
                Process_Team__c procTeam = userMap.get(userKey);
                if(procTeam!=null) {
                    //Collect user, team role and process names for active proc team mems and team roles other that Observer
                    if(procTeam.Team_Member_Status__c == 'Active' && procTeam.Team_Role__c != system.label.Safe_Trend_Observer_Role) {
                        assigneeId.add(userid);
                        teamRoles.add(procTeam.Team_Role__c);
                        processNames.add(procTeam.Process_Name__c);
                        groupNames.add(procTeam.Process_Name__c+ ' '+ procTeam.Team_Role__c);
                    }
                } else system.debug('User is Not Available!');
            }
            
            //Assign public groups
            SafeTrend_ProcessHandlerAsynch.publicGroupAssignment(assigneeId,teamRoles,processNames,groupNames);
            
            system.debug('*******PTH - assignPublicGroups Exit');
        } catch(Exception e) {
            system.debug('ERROR : '+e.getMessage());
        }
    }
    /**
* This method handles records which are changed from Active to Inactive.
* @param Set<Id> Set of user ids.
* @param Map<Id,process_team__c> Map of user id to process_team__c record
* @return Nothinf
*/    
    
    //Handler method to handle cases where the status is changed to inactive
    public static void handleInactiveUsers(Map<ID,process_team__c> userMap) {
        system.debug('*******PTH - handleInactiveUsers Enter');
        Map<Id,process_team__c> userToBeRemoved = new Map<id,process_team__c>();
        Map<Id,String> userToTeamRole = new Map<id,String>();
        
        try {
           //Remove public groups
           SafeTrend_ProcessTeamHelper.publicGroupRemoval(userMap,false);
            
            //Remove permission sets
            userToBeRemoved = SafeTrend_ProcessTeamHelper.getElligibleUserToBeAssigned(userMap,true);
  
            //Collect userid and team roles for removing permission sets
            for(Id u :userToBeRemoved.keySet()) {
                userToTeamRole.put(u,userToBeRemoved.get(u).Team_Role__c);
            }
            //Remove the permission sets asynchronously
            SafeTrend_ProcessHandlerAsynch.removePermSetAssignment(userToTeamRole);
        } catch(Exception e) {
            system.debug('ERROR : '+e.getMessage());
        }
        system.debug('*******PTH - assignPublicGroups Exit');
    }
    
    /**
* This method handles arecords which are changed from Inactive to Active with roles being unchanged
* @param Set<Id> Set of user ids.
* @param Map<Id,process_team__c> Map of user id to process_team__c record
* @return Nothing
*/    
    //Method to handle cases where the status is changed to active with role remain unchanges
    public static void handleActiveUserRoleUnchanged(Map<ID,process_team__c> userMap) {
        
        system.debug('*******PTH - handleActiveUserRoleUnchanged Enter');
        
        try {
            
            Map<Id,process_team__c> usersToBeAssigned = SafeTrend_ProcessTeamHelper.getElligibleUserToBeAssigned(userMap,false);
            
            //Assign desired permission sets
            SafeTrend_ProcessTeamHelper.assignPermissionSet(usersToBeAssigned); 
            
            //Assign desired public groups
           	SafeTrend_ProcessTeamHelper.assignPublicGroups(userMap);
            
        } catch(Exception e) {
            system.debug('ERROR : '+e.getMessage());
        }
        system.debug('*******PTH - handleActiveUserRoleUnchanged Exit');
    }
    
    
    /**
* This method handles records where the team role is changed
* @param Set<Id> Set of user ids.
* @param Map<Id,process_team__c> Map of user id to process_team__c record
* @return Nothing
*/    
    //Method to handle cases where the status is changed to active with role change
    public static void handleActiveUserRoleChange(Map<ID,process_team__c> userMap) {
        
        system.debug('*******PTH - handleActiveUserRoleChange Enter');
        Map<Id,process_team__c> userToBeRemoved = new Map<id,process_team__c>();
        Map<Id,String> userToTeamRole = new Map<id,String>();
    
        try {
            //Remove public groups
            SafeTrend_ProcessTeamHelper.publicGroupRemoval(userMap,true);
                       
            //Remove PermSet Assignments
            userToBeRemoved = SafeTrend_ProcessTeamHelper.getElligibleUserToBeAssigned(userMap,true);
            
            //Collect userid and team roles for removing permission sets
            for(Id u :userToBeRemoved.keySet()) {
                userToTeamRole.put(u,userToBeRemoved.get(u).Team_Role__c);
            }
            
            //Remove the permission sets asynchronously
            SafeTrend_ProcessHandlerAsynch.removePermSetAssignment(userToTeamRole);
            
            //Get Eligible Users
            Map<id,process_team__c> usersToBeAssigned = SafeTrend_ProcessTeamHelper.getElligibleUserToBeAssigned(userMap,false);
            
            //Assign permission sets
            SafeTrend_ProcessTeamHelper.assignPermissionSet(usersToBeAssigned);
            
            //Assign desired public groups
            SafeTrend_ProcessTeamHelper.assignPublicGroups(userMap);
            
            
        } catch(Exception e) {
            system.debug('Error : '+e.getMessage());
        }
        system.debug('*******PTH - handleActiveUserRoleChange Enter');
        
    }
       /**
* This method returns a Map of user and process_team__c
* @param List<Process_team__c> List of new process team records
* @return Map<Id,process_team__c>
*/    
    public static Map<Id,process_team__c> getUserMap(List<process_team__c> processTeamList) {
        Map<id,process_team__c> userMap = new Map<id,process_team__c>();
        for(process_team__c pt : processTeamList) {
                if(pt.User_Exists__c == true) {
                    //Sarang 9 13 2017 - Code Review Change
                    userMap.put(pt.User__c, pt);    
                }
            }
        
        return userMap;
    }
    
          /**
* This method removes the public groups
* @param Map<Id,Process_team__c> List of new process team records
* @param Boolean To check for old values for process team to remove the groups associated with the previous role
* @return Map<Id,process_team__c>
*/    
    
       public static void publicGroupRemoval(Map<id,process_team__c> userMap,Boolean checkOldTeamRole){
        List<String> assigneeId = new List<String>();
        List<String> teamRoles = new List<String>();
        List<String> processNames = new List<String>();
        List<String> groupNames = new List<String>();
         // Process Groups
            for(ID userid : userMap.keySet()) {
                process_Team__c procTeam = userMap.get(userid);
                process_Team__c procTeamTobechecked;
                //Check for old record
                if(checkOldTeamRole) 
                    procTeamTobechecked = (Process_Team__c)Trigger.oldMap.get(procTeam.Id);
                else 
                    procTeamTobechecked = procTeam;
                
                if(procTeamTobechecked != null) {
                    //collect the old process team record
                    if(procTeamTobechecked.Team_Role__c != system.label.Safe_Trend_Observer_Role){
                        assigneeId.add(userid);
                        teamRoles.add(procTeamTobechecked.Team_Role__c);
                        processNames.add(procTeamTobechecked.Process_Name__c);
                        groupNames.add(procTeamTobechecked.Process_Name__c+ ' '+ procTeamTobechecked.Team_Role__c);
                    }  
                } else system.debug('User is Not Available');
            }
            
            // Check Existing Process Teams
            SafeTrend_ProcessHandlerAsynch.removeUserfromPublicGroup(assigneeId, teamRoles, processNames, groupNames);

    }
}
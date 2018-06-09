/**
*___________________________________________________
*@Name: SafeTrend_ProcessTeamHandler
*@Author: Sarang Padhye
*@Created: Date: 7/20/2017
*@Used_By: SafeTrends App
*___________________________________________________
*@Description: This class has the methods to assign/remove relevant public groups and permission sets to users when the user inserts / updates
* any process_team__c records. This class will be invoked from the ProcessTeamHandler class which is invoked from the Process Team trigger.
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/

public class SafeTrend_ProcessTeamHandler {
    
    /**
* This method finds the corresponding user record based on the contact entered by the user and checks the User_Exists__c flag to true in
* in case the a user exists.
* @param List<Process_team__c> List of new process team records
* @return Nothing
*/    
    public static void updateUserBeforeInsert(List<Process_Team__c> newProcessTeamList){
        
        system.debug('*******PTHandler updateUserBeforeInsert Enter');
        //Variable Declaration
        Set<Id> contactIdSet = new Set<Id>();
        Set<String> personnelNumText = new Set<String>();
        Map<String,User> empNumToUser = new Map<String,User>();
        Map<String,String> personnelNumToContact = new Map<String,String>();
        List<user> userList = new List<User>();
        List<Contact> contactList = new List<Contact>();
        
        try{
            
            //Retrieve the ContactIds associated with the process team
            for(process_team__c pt : newProcessTeamList) {
                contactIdSet.add(pt.Contact__c);
            }
            
            //Retrieve all the contact Details
            contactList = [Select id,personnel_id__c,Formatted_Personnel_Num__c from contact where ID in: contactIDSet];
            
            //Retrieve the personnel id from the contacts
            for(contact c : contactList) {
                if(c.Formatted_Personnel_Num__c != null) {
                    personnelNumText.add(c.Formatted_Personnel_Num__c);
                    personnelNumToContact.put(c.id, c.Formatted_Personnel_Num__c);
                }
            }
            
            //Retrieve all the users with the personnel id
            if(personnelNumText.size() > 0) userList = [select id,employeenumber,isActive from user where employeenumber in:personnelNumText];
            
            for(user u : userList) {
                empNumToUser.put(u.employeenumber, u);
            }
            
           //Update the user reference and mark user Exists checkbox
            for(process_team__c pt: newProcessTeamList) {
                String personnelNum = personnelNumToContact.get(pt.Contact__c);
                User u = empNumToUser.get(personnelNum);
                //Sarang 9 13 2017 - Code Review Change
                if(u!=null && u.IsActive == true) {
                    pt.User__c = u.id;
                    pt.User_Exists__c = true;
                }
            }
            
        } catch(Exception e) {
            system.debug('ERROR '+e.getMessage());
        }
        
        system.debug('*******PTHandler updateUserBeforeInsert Exit');
    }
    
    /**
* This method assigns the correct permission sets and public groups to the users based on the selected Team Role and Process.
* @param List<Process_team__c> List of new process team records
* @return Nothing
*/    
    public static void updateUserAfterInsert(List<process_team__c> newProcessTeamList){
        system.debug('*******PTHandler updateUserAfterInsert Enter');
      
        Map<ID,process_team__c> userMap = new Map<ID,process_team__c>();
       
        try{
            //get User Map
            userMap = SafeTrend_ProcessTeamHelper.getUserMap(newProcessTeamList);
    
            //Process only if the user Map is not Empty
            if(!userMap.isEmpty()) {
             
                //Get Eligible Users
                Map<Id,process_team__c> usersToBeAssigned = SafeTrend_ProcessTeamHelper.getElligibleUserToBeAssigned(userMap,false);
                
                //call helper method to assign the desired Permission Sets
                SafeTrend_ProcessTeamHelper.assignPermissionSet(usersToBeAssigned); 
                
                //call helper method to assign the desired public groups
               	SafeTrend_ProcessTeamHelper.assignPublicGroups(userMap);
                
            } else system.debug('Map is Empty!');
        } catch(Exception e) {
            system.debug('ERROR : '+e.getMessage());
        }
        system.debug('*******PTHandler updateUserAfterInsert Exit');
    }
    
    /**
* This method assigns the correct permission sets and public groups when the user updates the process team record by changin the status or changing the team role
* @param List<Process_team__c> List of new process team records
* @return Nothing
*/    
    public static void updateUserAfterUpdate(List<process_team__c> newProcessTeamList){
        system.debug('*******PTHandlerupdateUserAfterUpdate Enter');
        Map<ID,process_team__c> userMap = new Map<ID,process_team__c>();
        Map<Id,process_team__c> inActiveUsers = new Map<Id,process_team__c>();
        Map<Id,process_team__c> activeUsersRoleUnchanged = new Map<Id,process_team__c>();
        Map<Id,process_team__c> activeUserRoleChange = new Map<Id,process_team__c>();
        try{
            
           //get User Map
            userMap = SafeTrend_ProcessTeamHelper.getUserMap(newProcessTeamList);
            
            // //Process only if the user Map is not Empty
            if(!userMap.isEmpty()) {
                for(process_team__c pt:newProcessTeamList) {
                    
                    Process_team__c oldObj = (Process_Team__c)Trigger.oldMap.get(pt.Id);
                    //1. Active Before Inactive now
                    if(pt.Team_Member_Status__c == 'Inactive' && oldObj.Team_Member_Status__c == 'Active' && pt.User_Exists__c == true) {
                        inActiveUsers.put(pt.User__c,pt);
                    }
                    //2. Inactive Before Active Now and Team Role remains the same
                    else if(pt.Team_Member_Status__c == 'Active' && 
                            oldObj.Team_Member_Status__c == 'Inactive' && 
                            pt.Team_Role__c == oldObj.Team_Role__c && pt.User_Exists__c == true) {
                                activeUsersRoleUnchanged.put(pt.User__c,pt);
                            }//3. Active Role Changed
                    else if(pt.Team_Member_Status__c == 'Active' && pt.Team_Role__c != oldObj.Team_Role__c && pt.User_Exists__c == true) {
                        activeUserRoleChange.put(pt.User__c,pt);
                    }            
                }
                
                //Call helper method to handle users of the inactive process team records
                if(!inActiveUsers.isEmpty()) SafeTrend_ProcessTeamHelper.handleInactiveUsers(inActiveUsers);
                //Call helper method to handle users of the process team with status changes to active and role is unhanged
                if(!activeUsersRoleUnchanged.isEmpty()) SafeTrend_ProcessTeamHelper.handleActiveUserRoleUnchanged(activeUsersRoleUnchanged);
                //Call helper method to handle users of the process team with status changes to active and role is changed
                if(!activeUserRoleChange.isEmpty()) SafeTrend_ProcessTeamHelper.handleActiveUserRoleChange(activeUserRoleChange);
                
            } else system.debug('Map is Empty!');
        } catch(Exception e) {
            system.debug('ERROR : '+e.getMessage());
        }
        system.debug('*******PTHandlerupdateUserAfterUpdate Exit');
    }
    
}
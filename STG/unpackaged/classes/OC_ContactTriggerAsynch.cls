// **************************************************************************************************************** 
// Author:  Sarang Padhye, Deloitte Digital
// Date:    Mar 8, 2017
// Description: Class to update users asynchronously
//
// Modifications: 
// 1.00: Created     

public with sharing class OC_ContactTriggerAsynch {
    
    //Future method to update users.
    @future
    public static void updateUsersAsynch(Set<String> personnelNumbersToBeUpdateText) {
        system.debug('In Future');
        List<User> userList = new list<User>();        
        //Retrieve all the Amtrak Employees with the same personnel numbers
        if(!personnelNumbersToBeUpdateText.isEmpty()){
            userList = [select id,name,profile.name,EmployeeNumber from User where EmployeeNumber IN:personnelNumbersToBeUpdateText];
            
            List<User> userToUpdate = new List<User>();
            
            //Deactivate the User
            for(User u : userList) {
                u.IsActive = false;
                userToUpdate.add(u);
            }
           
            //Update
            if(userToUpdate.size() > 0) update userToUpdate;
        }
    }
    
    
}
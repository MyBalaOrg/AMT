/*___________________________________________________
*@Name: Revsys_GenericUtility
*@Author: Sudhindra Katti
*@Created: Date: 02/21/2018
*@Used_By: RedirectCmp
*___________________________________________________
*@Description: 
* Generic utility apex class
* Added method getAssignedPermissionSet, get assigned permission set 
*
*___________________________________________________
*@Changes: 
**/
  
public class Revsys_GenericUtility {
    
    
    @AuraEnabled
    public Static Map<String, String> getAssignedPermissionSet(){  

        Map<String, String> resp = getAllowedPermissionSet('PermissionsforObservations');
            
        return resp;
    }

    /**
    *————————————————————————————————————————————————————
    * @Name: getAllowedPermissionSet
    * @Description
    * A helper method that returns response map with allowed permission sets, profiles for custom lightning
    *————————————————————————————————————————————————————
    * @param    psName   Name of REVSYS_Custom_Settings that contains specific permission set for Lightning Component accessibility
    * @return   Map<String,String>  Map indexed serialized items for Lightning 
    *————————————————————————————————————————————————————
    **/
    public Static Map<String, String> getAllowedPermissionSet(String psName){  
        List<String> permissionSetAPIs =  new List<String>();
        List<PermissionSetAssignment> permissionSetList =  new List<PermissionSetAssignment>();
        
        //get profile name of logged in user
        Id profileId = userinfo.getProfileId();
        String profileName = [Select Id, Name from Profile where Id = :profileId].Name;
        
        //get permission set csv from custom setting
        String permissionSetCsv = String.valueOf(REVSYS_Custom_Settings__c.getValues(psName).CSV_String__c);
        System.debug('PSNames'+permissionSetCsv);    
        if(permissionSetCsv != null && permissionSetCsv.length() > 0){                
             permissionSetAPIs = permissionSetCsv.split(',');
        }        

        Map<String, String> resp = new Map<String, String>();
            
        //get list of all permission set assigned to user
        permissionSetList = [SELECT Id, PermissionSet.Name, AssigneeId 
                                                           FROM PermissionSetAssignment 
                                                           WHERE AssigneeId = :userinfo.getUserId() limit 1000];
       
        
        resp.put('permissionSetList',JSON.serialize(permissionSetList));
        resp.put('allowedPS', JSON.serialize(permissionSetAPIs));
        resp.put('ProfileName', JSON.serialize(profileName));    
        system.debug('JSON : ' + JSON.serialize(permissionSetList));
         return resp;
    }
       
}
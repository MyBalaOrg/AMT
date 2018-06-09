/**
* ********************************************************************************************************************************************************************************************************************************************
*   @Name           AppratJITHandler
*   @Author         Sarang Padhye, Deloitte Digital
*   @Created Date   24th April 2017
*   @Used By        JIT 
*   *******************************************************************************************************************************************************************************************************************************************
*   @Description    A Custom JIT handler which appends custom domain name to the UserName and creates/updates user.
*   *******************************************************************************************************************************************************************************************************************************************
*   @Changes
*   10/25/2017 Prevent updating username upon update.
*   ******************************************************************************************************************************************************************************************************************************************* 
**/
global class AppratJITHandler implements Auth.SamlJitHandler {
    private class JitException extends Exception{}
    
    // Method which creates or updates the user as per the request
    private void handleUser(boolean create, User u, Map<String, String> attributes,String federationIdentifier, boolean isStandard) {
        
        //Populate the following fields for the user irrespective of whether it is a create request or update
        //1) UserName
        //2) Email
        //3) FirstName
        //4) LastName
        //5) EmployeeNumber
        //6) Alias
        
        //Sarang - Moving below code to only create
        /*
        if(attributes.containsKey('User.UserName')) {
            u.UserName = attributes.get('User.UserName') + '.'+Label.OC_Custom_Domain_Name;
        } 

		*/
        
        if(attributes.containsKey('User.Email')) {
            u.Email = attributes.get('User.Email');
        }
        
        if(attributes.containsKey('User.Firstname')) {
            u.Firstname = attributes.get('User.Firstname');
        }
        
        if(attributes.containsKey('User.Lastname')) {
            u.Lastname = attributes.get('User.Lastname');
        }
        
        if(attributes.containsKey('User.EmployeeNumber')) {
            u.EmployeeNumber= attributes.get('User.EmployeeNumber');
        }
        
        if(attributes.containsKey('User.Alias')) {
            u.Alias = attributes.get('User.Alias');
        }        
        
        // Populate the following user fields only during creating or when the user first time logs in to system
        // 1) Federation Identifier
        // 2) ProfileID
        // 3) LocaleSidKey
        // 4) Language Local key
        // 5) TimeZoneSidKey
        // 6) EmailEncodingKey
        
        if(create) {
            if(attributes.containsKey('User.FederationIdentifier')) {
                u.FederationIdentifier = attributes.get('User.FederationIdentifier');
            } else {
                u.FederationIdentifier = federationIdentifier;
            }
            
            if(attributes.containsKey('User.ProfileID')) {
                String profileId = attributes.get('User.ProfileID');
                List<Profile> p = [SELECT Id FROM Profile WHERE Name=:ProfileId];
                if(p.size() > 0 )
                    u.ProfileId = p[0].Id;            
                
            }
            //Retrieve the details of the current user and use his information to populate some of the fields.
            String uid = UserInfo.getUserId();
            User currentUser = 
                [SELECT LocaleSidKey, LanguageLocaleKey, TimeZoneSidKey, EmailEncodingKey FROM User WHERE Id=:uid];
            u.LocaleSidKey = currentUser.LocaleSidKey;
            u.LanguageLocaleKey = currentUser.LanguageLocaleKey;
            // Create the alias based on first name and last name only during creation
            String alias = '';
            if(u.Firstname == null) {
                alias = u.Lastname;
            } else {
                alias = u.Firstname.charAt(0) + u.Lastname;
            }
            if(alias.length() > 5) {
                alias = alias.substring(0, 5);
            }
            u.Alias = alias;
            u.TimeZoneSidKey = currentUser.TimeZoneSidKey;
            u.EmailEncodingKey = currentUser.EmailEncodingKey;
            
            //Update username only on create
            if(attributes.containsKey('User.UserName')) {
            u.UserName = attributes.get('User.UserName') + '.'+Label.OC_Custom_Domain_Name;
        }
        }
        
        //update the user if its an existing user.
        if(!create) {
            update(u);
        }
    }
    
    // Method which decides if its a standard user or not and routes the request accordingly
    private void handleJit(boolean create, User u, Id samlSsoProviderId, Id communityId, Id portalId,
                           String federationIdentifier, Map<String, String> attributes, String assertion) {
                               if(communityId != null || portalId != null) {
                                   handleUser(create, u, attributes, federationIdentifier, false);
                               } else {
                                   handleUser(create, u, attributes, federationIdentifier, true);
                               }
                           }
    
    // Method implemented via the interface to handle creation of the user.
    global User createUser(Id samlSsoProviderId, Id communityId, Id portalId,
                           String federationIdentifier, Map<String, String> attributes, String assertion) {
                               system.debug('In createUser');
                               User u = new User();
                               handleJit(true, u, samlSsoProviderId, communityId, portalId,
                                         federationIdentifier, attributes, assertion);
                               return u;
                           }
    
    // Method implemented via the interface to update a existing user.
    global void updateUser(Id userId, Id samlSsoProviderId, Id communityId, Id portalId,
                           String federationIdentifier, Map<String, String> attributes, String assertion) {
                               system.debug('In updateUser');
                               User u = [SELECT Id FROM User WHERE Id=:userId];
                               handleJit(false, u, samlSsoProviderId, communityId, portalId,
                                         federationIdentifier, attributes, assertion);
                           }
}
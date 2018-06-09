@isTest
public class AppratJITHandlerTest {
    
    static testMethod void testUserCreation() {
        
        String samlSsoProviderId = 'testProvider';
        String federationIdentifier = 'testFedId';
        Map<String,String> attributes = new Map<String,String>();
        String profileName = 'Amtrak Employee';
        String profileID = [select id from Profile where Name =: profileName].id;
        attributes.put('User.Email', 'test@test.com');
        attributes.put('User.FederationIdentifier',federationIdentifier);
        attributes.put('User.Firstname','testFirstName');
        attributes.put('User.ProfileID',profileName);
        attributes.put('User.Lastname','testLastName');
        attributes.put('User.UserName','test@test.com');
        attributes.put('User.EmployeeNumber','001001001');
         
        AppratJITHandler samlHandler = new AppratJITHandler();
        
        
        User u = samlHandler.createUser(Label.OC_SSO_Settings_Id, null, null, federationIdentifier, attributes, 'testAssertion');
        system.debug('User '+u);
    }
        
        
 
}
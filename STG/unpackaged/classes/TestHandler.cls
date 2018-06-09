/**
* A Utility Class to create Data
*/

public class TestHandler
{
    //Utility Method to create users
    public static User createTestUser(Id roleId, Id profID, String fName, String lName)
    {
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        User tuser = new User(  firstname = fName,
                                lastName = lName,
                                email = uniqueName + '@test' + orgId + '.org',
                                Username = uniqueName + '@test' + orgId + '.org',
                                EmailEncodingKey = 'ISO-8859-1',
                                Alias = uniqueName.substring(18, 23),
                                TimeZoneSidKey = 'America/Los_Angeles',
                                LocaleSidKey = 'en_US',
                                LanguageLocaleKey = 'en_US',
                                ProfileId = profId,
                                UserRoleId = roleId);
        return tuser;
    }
    
    //Create an Account
    public static Account createAccount(String name)
    {
        return new Account(Name = name);
    }
    
    //Utility Method to create multiple contacts
    public static List<Contact> createTestContacts(Integer numberOfContacts) {
        List<Contact> createdContacts = new List<Contact>();
        for(Integer i = 0; i<numberOfContacts;i++) {
            createdContacts.add(new Contact(firstname='Test'+i,lastname='Test'+i,Employment_Status__c='Test',personnel_number__c = Integer.valueOf(math.rint(math.random()*1000000))));
        }
     	return createdContacts;
    }
    
    //Utility Method to create Test Positions
    public static Position__c createTestPosition(String name,String PositionID) {
        return new Position__c(Name = name,Position_Id__c = PositionID);
    }
    
    //Utility method to create one contact
    public static Contact createTestContact(String LastName,ID AccountId, ID PositionLookup, String EmploymentStatus) {
        return new Contact(LastName = LastName,AccountId = AccountId,
                           PositionLookup__c = PositionLookup, Employment_Status__c = EmploymentStatus);
    }
    
    public static OC_Component_FieldList__c createComponentFieldList(String DisplayLabel
                                                                 ,Integer DisplaySequence
                                                                 ,String SobjectField
                                                                 ,String SobjectName
                                                                 ,String applicationContext
                                                                 ,String Name
                                                                 )
    {
        
        return new OC_Component_FieldList__c(DisplayLabel__c 		= DisplayLabel
                                        , DisplaySequence__c 	= DisplaySequence
                                        , SobjectField__c   	= SobjectField
                                        , SobjectName__c 		= SobjectName
                                        , ApplicationContext__c = applicationContext
                                        , Name 					= Name);
    }
}
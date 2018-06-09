@IsTest
private class Peak_ProfileProgressControllerTest {
    // Test the dynamic query builder
    @isTest
    public static void testDynamicQueryBuilder(){
        // Set up and run as a standard user
        String[] fields = new List<String>();
        fields.add('FirstName');
        User testUser = Peak_TestUtils.createStandardUser();
        User thisUser = [SELECT Id FROM User Where Id =: UserInfo.getUserId()];
        
        System.runAs(thisUser){
            insert testUser;
        }

        // The following code runs as user 'testUser'
        String builtQuery = Peak_ProfileProgressController.dynamicQueryBuilder('User', testUser.Id, fields);
        system.assertEquals('SELECT Id, FirstName FROM User WHERE Id = \'' + testUser.Id + '\'',builtQuery);
    }
    // Test getting the user
    @isTest
    public static void testGetUser(){
        // Set up and run as a standard user
        User testUser = Peak_TestUtils.createStandardUser();
        User thisUser = [SELECT Id FROM User Where Id =: UserInfo.getUserId()];
        
        System.runAs(thisUser){
            insert testUser;
        }

        System.runAs(testUser) {
            // The following code runs as user 'testUser'
            User queryUser = Peak_ProfileProgressController.getUser();
            system.assertEquals(Peak_TestConstants.FIRSTNAME + ' ' + Peak_TestConstants.LASTNAME,queryUser.Name);
        }
    }
    @isTest
    public static void testGetUserById(){
        // Set up and run as a standard user
        User testUser = Peak_TestUtils.createStandardUser();
        String[] fields = new List<String>();
        fields.add('FirstName');
        fields.add('LastName');
        fields.add('Email');
        User thisUser = [SELECT Id FROM User Where Id =: UserInfo.getUserId()];
        
        System.runAs(thisUser){
            insert testUser;
        }



        User queryUser = Peak_ProfileProgressController.getUserById(testUser.Id, fields);
        system.assertEquals(Peak_TestConstants.FIRSTNAME, queryUser.FirstName);
        system.assertEquals(Peak_TestConstants.LASTNAME, queryUser.LastName);
        system.assertEquals(Peak_TestConstants.STANDARD_EMAIL, queryUser.Email);
    }
    // Test getting the site prefix
    @isTest
    public static void testSitePrefix(){
        String prefix = Peak_ProfileProgressController.getSitePrefix();
    }
}
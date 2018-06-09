/**
*___________________________________________________
*@Name: CaseController_Test
*@Author: Gaurav Dharra
*@Created: Date: 12/04/2017
*@Used_By: CEO Systems
*___________________________________________________
*@Description: Test class for CEO New Question Creation Functionality
*___________________________________________________
**/
@isTest
public class CaseController_Test {
    
     /**
    *————————————————————————————————————————————————————
    * @Name: Gaurav Dharra
    * @Description
    * Method to create user and contact
    *————————————————————————————————————————————————————
    * @param    
    * @return   
    *————————————————————————————————————————————————————
    **/
    @TestSetup
    public static void init(){
        createContact();
        createUser();
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Name: createContact
    * @Description
    * Contact Creation
    *————————————————————————————————————————————————————
    * @param    
    * @return   
    *————————————————————————————————————————————————————
    **/    
    public static void createContact(){
        Contact con = new Contact();
        con.FirstName='FirstTestName';
        con.LastName ='LastTestName';
        con.Email='test@email.com';
        con.Personnel_Number__c = 90876541;
        insert con;
    }
  	/**
    *————————————————————————————————————————————————————
    * @Name: Gaurav Dharra
    * @Description
    * User Creation
    *————————————————————————————————————————————————————
    * @param    
    * @return   
    *————————————————————————————————————————————————————
    **/  
    public static void createUser(){
	    User user = new User();
        user.Username ='ceotestemail@test.com';
        user.LastName = 'ceoLastTestName';
        user.Email = 'ceotestemail@test.com';
        user.alias = 'testAl';
        user.TimeZoneSidKey = 'America/New_York';
        user.LocaleSidKey = 'en_US';
        user.EmailEncodingKey = 'ISO-8859-1';
        user.ProfileId = [select id from Profile where Name='System Administrator'].Id;
        user.LanguageLocaleKey = 'en_US';
        user.EmployeeNumber = '90876541';
        insert user;
    }
    /**
    *————————————————————————————————————————————————————
    * @Name: Gaurav Dharra
    * @Description
    * Fetch user Id from the getUserInfo method
    *————————————————————————————————————————————————————
    * @param    
    * @return   
    *————————————————————————————————————————————————————
    **/
    public static testMethod void getUserInfoTest(){
        User user = [SELECT Id from user where UserName ='ceotestemail@test.com'];
        System.RunAs(user) {
            Test.startTest();
            User u = CaseController.getUserInfo();
            System.assert(u.Id == user.Id, 'User successfully fetched');
            Test.stopTest();
        }
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Name: Gaurav Dharra
    * @Description
    * Fetch contact Id from the user employee id
    *————————————————————————————————————————————————————
    * @param    
    * @return   
    *————————————————————————————————————————————————————
    **/    
    public static testMethod void testContactFetch(){
        
        User user = [SELECT Id, EmployeeNumber from user where UserName ='ceotestemail@test.com'];
        Contact con = [Select Id from Contact where FirstName='FirstTestName'];
        
        Test.startTest();
        List<Contact> c = CaseController.fetchContactFromUser(user.EmployeeNumber);
        Test.stopTest();
        
        System.assert(c.size() > 0 && c.get(0).Id == con.Id, 'A contact was successfully fetched');
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Name: Gaurav Dharra
    * @Description
    * Test no matching contact Id from the user employee id
    *————————————————————————————————————————————————————
    * @param    
    * @return   
    *————————————————————————————————————————————————————
    **/    
    public static testMethod void testContactFetchWithNoMatchingEmployee(){
        
        User user = [SELECT Id, EmployeeNumber from user where UserName ='ceotestemail@test.com'];
        user.EmployeeNumber = '12345678';
        update user;
        
        Test.startTest();
        List<Contact> c = CaseController.fetchContactFromUser(user.EmployeeNumber);
        Test.stopTest();
        
        System.assert(c.size() == 0, 'No contact matching the user ID was found');
    }
    /**
    *————————————————————————————————————————————————————
    * @Name: Gaurav Dharra
    * @Description
    * Test case creation by passing case object
    *————————————————————————————————————————————————————
    * @param    
    * @return   
    *————————————————————————————————————————————————————
    **/        
    public static testMethod void insertNewCaseTest(){
        Contact con = [Select Id from Contact where FirstName='FirstTestName'];
        Case c = new Case(Subject = 'Test', Origin = 'Web', Type = 'Question', Description = 'Testing Case Insertion', ContactId = con.Id);
        
        Test.startTest();
        String msg = CaseController.insertNewCase(c);
        Test.stopTest();
        System.assert(msg == 'Success', 'A case was successfully inserted');
    }
}
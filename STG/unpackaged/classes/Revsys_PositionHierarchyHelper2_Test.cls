/**
*___________________________________________________
*@Name: Revsys_PositionHierarchyHelper2_Test
*@Author: Hemanth Kesapragada
*@Created: Date: 04/04/2018
*@Used_By: SPARTN
*___________________________________________________
*@Description: Test class for Revsys_PositionHierarchyHelper2 Class.
* 
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/
@isTest
private class Revsys_PositionHierarchyHelper2_Test {
    
    @TestSetup
    public static void loadTestData() {
        List<Contact> contactList = new List<Contact>();
        Contact employee = new Contact
            (
                LastName			='Employee', 
                FirstName			='Amy', 
                Department 			= 'Mechanical',
                Craft__c 			= 'Test Craft2',
                Personnel_Number__c = 1234,
                Email 				= 'test.test@amtrak.com'
            );
        insert employee;
        
        Contact supervisor = new Contact
            (
                LastName			='Supervisor', 
                FirstName			='John', 
                Department 			= 'Mechanical',
                Craft__c 			= 'Test Craft2',
                Personnel_Number__c = 12345,
                Email 				= 'super.test@amtrak.com'
            );
        insert supervisor;
        
        Contact manager = new Contact
            (
                LastName			='Manager', 
                FirstName			='Ned', 
                Department 			= 'Mechanical',
                Craft__c 			= 'Test Craft2',
                Personnel_Number__c = 123456,
                Email 				= 'manager.test@amtrak.com'
            );
        insert manager;
        
        SPARTN_Custom_Settings__c setting = new SPARTN_Custom_Settings__c();
        setting.Name = 'Valid Employee Department';
        setting.CsvString__c = 'TRANSPORTATION,ENGINEERING,MECHANICAL';
        insert setting;
        
        
        EPW_Organization__c Org2 = new EPW_Organization__c
            ( 
                RecordTypeId = Revsys_StaticUtility.ORGANIZATION_SPARTN_RECTYPE_ID, 
                Name = 'Spartn', 
                EPW_Organization_Number__c = '2',
                EPW_Status__c = 'Active'
            );
        insert Org2;
        
        EPW_Organization__c Org1 = new EPW_Organization__c
            ( 
                RecordTypeId = Revsys_StaticUtility.ORGANIZATION_AMTRAKORG_RECTYPE_ID, 
                Name = 'Amtrak', 
                EPW_Organization_Number__c = '1',
                EPW_Status__c = 'Active'
            );
        insert Org1;
        
        
        //Spartn PH
        EPW_Position_Hierarchy__c myPoHi1 = new EPW_Position_Hierarchy__c
            (   RecordTypeId = Revsys_StaticUtility.POSITION_HIERARCHY_SPARTN_RECTYPE_ID, 
             EPW_Position_Organization__c = Org2.Id,
             Name = 'Leve1 Supervisor A',
             EPW_Position_ID__c =  '10000000',
             EPW_Status__c = 'Active',
             EPW_Dept_Code_Description__c = 'Transportation'
            );
        insert myPoHi1;
        
        EPW_Hierarchy_Assignment__c myHiAsgn1 = new EPW_Hierarchy_Assignment__c
            ( 
                EPW_Contact__c = supervisor.Id,
                EPW_Position_Hierarchy__c = myPoHi1.Id,
                EPW_Status__c = 'Active'
            );
        insert myHiAsgn1;
        
        EPW_Position_Hierarchy__c myPoHi2 = new EPW_Position_Hierarchy__c
            (   RecordTypeId = Revsys_StaticUtility.POSITION_HIERARCHY_SPARTN_RECTYPE_ID, 
             EPW_Position_Organization__c = Org2.Id,
             EPW_Parent_Position_Hierarchy__c = myPoHi1.Id,
             Name = 'Leve2 Employee A',
             EPW_Position_ID__c =  '1000',
             EPW_Status__c = 'Active',
             EPW_Dept_Code_Description__c = 'Transportation'
            );
        insert myPoHi2;
        
        EPW_Hierarchy_Assignment__c myHiAsgn2 = new EPW_Hierarchy_Assignment__c
            ( 
                EPW_Contact__c = employee.Id,
                EPW_Position_Hierarchy__c = myPoHi2.Id,
                EPW_Status__c = 'Active'
            );
        insert myHiAsgn2;
        
        EPW_Position_Hierarchy__c myPoHi3 = new EPW_Position_Hierarchy__c
            (   RecordTypeId = Revsys_StaticUtility.POSITION_HIERARCHY_SPARTN_RECTYPE_ID, 
             EPW_Position_Organization__c = Org2.Id,
             EPW_Parent_Position_Hierarchy__c = myPoHi2.Id,
             Name = 'Leve3 Employee A',
             EPW_Position_ID__c =  '1000',
             EPW_Status__c = 'Active',
             EPW_Dept_Code_Description__c = 'Transportation'
            );
        insert myPoHi3;
        
        EPW_Hierarchy_Assignment__c myHiAsgn3 = new EPW_Hierarchy_Assignment__c
            ( 
                EPW_Contact__c = manager.Id,
                EPW_Position_Hierarchy__c = myPoHi3.Id,
                EPW_Status__c = 'Active'
            );
        insert myHiAsgn3;
        
    }
    public static testMethod void testAssignSupervisorDetails() {
        Test.startTest();
        EPW_Position_Hierarchy__c posHToUpdate = [Select Id,EPW_Parent_Position_Hierarchy__c from EPW_Position_Hierarchy__c where Name='Leve3 Employee A'];
        
        EPW_Position_Hierarchy__c parentPos = [Select Id from EPW_Position_Hierarchy__c where Name='Leve1 Supervisor A'];
        posHToUpdate.EPW_Parent_Position_Hierarchy__c = parentPos.Id;
        update posHToUpdate;
        
        Test.stopTest();
    }
    public static testMethod void testOverall() {
        Test.startTest();
        EPW_Position_Hierarchy__c posHToUpdate = [Select Id,EPW_Parent_Position_Hierarchy__c from EPW_Position_Hierarchy__c where Name='Leve3 Employee A'];
        
        EPW_Position_Hierarchy__c parentPos = [Select Id from EPW_Position_Hierarchy__c where Name='Leve1 Supervisor A'];
        posHToUpdate.EPW_Parent_Position_Hierarchy__c = parentPos.Id;
        update posHToUpdate;
        List<EPW_Position_Hierarchy__c> epwPosHierarchy = new List<EPW_Position_Hierarchy__c>();
        epwPosHierarchy.add(posHToUpdate);    
        Revsys_PositionHierarchyHelper2.processSupervisorPositionHierarchy(epwPosHierarchy);
        
        Map<Id,EPW_Position_Hierarchy__c>  idEPWPosHierarchyMap = new Map<Id,EPW_Position_Hierarchy__c>();
        Revsys_PositionHierarchyHelper2.updateSupervisorDetails(epwPosHierarchy,idEPWPosHierarchyMap); 
        Revsys_PositionHierarchyHelper2.updateSupervisorDetails(null,idEPWPosHierarchyMap);    
        Revsys_PositionHierarchyHelper2.updateSupervisorDetails(epwPosHierarchy,Null);     
        Test.stopTest();
    }
    public static testMethod void testException() {
        Test.startTest();
        try {
            RevSys_PositionHierarchyTriggerHandler.DoFailTest=true;
            
            EPW_Position_Hierarchy__c posHToUpdate = [Select Id,EPW_Parent_Position_Hierarchy__c from EPW_Position_Hierarchy__c where Name='Leve3 Employee A'];
            
            EPW_Position_Hierarchy__c parentPos = [Select Id from EPW_Position_Hierarchy__c where Name='Leve1 Supervisor A'];
            posHToUpdate.EPW_Parent_Position_Hierarchy__c = parentPos.Id;
            update posHToUpdate;    
        } catch (Exception e) {
            Boolean b = e.getMessage().contains('Error')?true:false;
            System.assertEquals(true,b);
        }
        Test.stopTest();
        
    }
    
    
}
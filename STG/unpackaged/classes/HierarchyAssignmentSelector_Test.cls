/**
*___________________________________________________
*@Name:     CertificationRevocationTrigger_Test
*@Author:   Vaibhav Athikam
*@Created:  Date: April 10, 2018
*@Used_By:  SPARTN
*___________________________________________________
*@Description: Test for CertificationRevocationTrigger
* 
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/
@isTest
public class HierarchyAssignmentSelector_Test {

        @TestSetup
    public static void loadTestData()
    {
        // Account 

        List<Account> myAccountList = new List<Account>(); 

        Account amtrakAcct = new Account
        (
            Name='Amtrak'
        );
        myAccountList.add(amtrakAcct); 

        Account foreignRrAcct = new Account
        (
            Name='Foreign Railroad'
        );
        myAccountList.add(foreignRrAcct); 

        system.debug('AAAAAAAAAA Inserting Account'); 

        INSERT myAccountList; 

        // Contact 

        List<Contact> myContactList = new List<Contact>(); 

        // supervisors
            Contact supervisorA = new Contact
            (
                AccountId           = amtrakAcct.id, 
                LastName            ='Supervisor', 
                FirstName           ='Amy', 
                Personnel_Number__c = 10000000,
                Email               = 'amy.supervisor@amtrak.com'

            );
            myContactList.add(supervisorA); 

            Contact supervisorB = new Contact
            (
                AccountId           = amtrakAcct.id, 
                LastName            ='Supervisor', 
                FirstName           ='Bob', 
                Personnel_Number__c = 20000000,
                Email               = 'bob.supervisor@amtrak.com'

            );
            myContactList.add(supervisorB); 

        // employees for supervisor A

            Contact employeeA1 = new Contact
            (
                AccountId           = amtrakAcct.id, 
                LastName            ='Employee', 
                FirstName           ='Abigale', 
                Personnel_Number__c = 10000001,
                Email               = 'abigale.employee@amtrak.com'

            );
            myContactList.add(employeeA1); 

            Contact employeeA2 = new Contact
            (
                AccountId           = amtrakAcct.id, 
                LastName            ='Employee', 
                FirstName           ='Adam', 
                Personnel_Number__c = 10000002,
                Email               = 'adam.employee@amtrak.com'

            );
            myContactList.add(employeeA2); 

            Contact employeeA3 = new Contact
            (
                AccountId           = amtrakAcct.id, 
                LastName            ='Employee', 
                FirstName           ='Ali', 
                Personnel_Number__c = 10000003,
                Email               = 'ali.employee@amtrak.com'

            );
            myContactList.add(employeeA3); 

        // employees for supervisor B

            Contact employeeB1 = new Contact
            (
                AccountId           = amtrakAcct.id, 
                LastName            ='Employee', 
                FirstName           ='Babu', 
                Personnel_Number__c = 20000001,
                Email               = 'babu.employee@amtrak.com'

            );
            myContactList.add(employeeB1); 

            Contact employeeB2 = new Contact
            (
                AccountId           = amtrakAcct.id, 
                LastName            ='Employee', 
                FirstName           ='Barbara', 
                Personnel_Number__c = 20000002,
                Email               = 'barbara.employee@amtrak.com'

            );
            myContactList.add(employeeB2); 

            Contact employeeB3 = new Contact
            (
                AccountId           = amtrakAcct.id, 
                LastName            ='Employee', 
                FirstName           ='Bose', 
                Personnel_Number__c = 20000003,
                Email               = 'bose.employee@amtrak.com'

            );
            myContactList.add(employeeB3); 

        system.debug('BBBBBBBBBB Inserting Contact'); 

        INSERT myContactList; 

        // Organization

        List<EPW_Organization__c> myOrgList = new List<EPW_Organization__c>(); 

        EPW_Organization__c Org1 = new EPW_Organization__c
        ( 
            RecordTypeId = Revsys_StaticUtility.ORGANIZATION_AMTRAKORG_RECTYPE_ID, 
            Name = 'Amtrak Org', 
            EPW_Organization_Number__c = '1',
            EPW_Status__c = 'Active'
        );
        myOrgList.add(Org1);

        EPW_Organization__c Org2 = new EPW_Organization__c
        ( 
            RecordTypeId = Revsys_StaticUtility.ORGANIZATION_SPARTN_RECTYPE_ID, 
            Name = 'Spartn', 
            EPW_Organization_Number__c = '2',
            EPW_Status__c = 'Active'
        );
        myOrgList.add(Org2);

        insert myOrgList; 

        // Position Hierarchy

        List<EPW_Position_Hierarchy__c> myPoHiList = new List<EPW_Position_Hierarchy__c>(); 

        EPW_Position_Hierarchy__c myPoHi1 = new EPW_Position_Hierarchy__c
        (   RecordTypeId = Revsys_StaticUtility.POSITION_HIERARCHY_AMTRAK_RECTYPE_ID, 
            EPW_Position_Organization__c = Org1.Id,
            Name = 'Leve1 Supervisor A',
            EPW_Position_ID__c =  '10000000',
            EPW_Status__c = 'Active',
            EPW_Dept_Code_Description__c = 'Transportation'
        );
        //myPoHiList.add(myPoHi1); 

        insert myPoHi1;

        EPW_Position_Hierarchy__c myPoHi2 = new EPW_Position_Hierarchy__c
        (   RecordTypeId = Revsys_StaticUtility.POSITION_HIERARCHY_AMTRAK_RECTYPE_ID, 
            EPW_Position_Organization__c = Org1.Id,
            Name = 'Leve1 Supervisor B',
            EPW_Position_ID__c =  '20000000',
            EPW_Status__c = 'Active',
            EPW_Dept_Code_Description__c = 'Transportation'
        );
        //myPoHiList.add(myPoHi2); 

        insert myPoHi2;

        EPW_Position_Hierarchy__c myPoHi3 = new EPW_Position_Hierarchy__c
        (   RecordTypeId = Revsys_StaticUtility.POSITION_HIERARCHY_AMTRAK_RECTYPE_ID, 
            EPW_Parent_Position_Hierarchy__c = myPoHi1.Id, 
            EPW_Position_Organization__c = Org1.Id,
            Name = 'Leve2 Employee A - 1',
            EPW_Position_ID__c =  '10000001',
            EPW_Status__c = 'Active',
            EPW_Dept_Code_Description__c = 'Transportation'
        );
        myPoHiList.add(myPoHi3); 

        EPW_Position_Hierarchy__c myPoHi4 = new EPW_Position_Hierarchy__c
        (   RecordTypeId = Revsys_StaticUtility.POSITION_HIERARCHY_AMTRAK_RECTYPE_ID, 
            EPW_Parent_Position_Hierarchy__c = myPoHi1.Id, 
            EPW_Position_Organization__c = Org1.Id,
            Name = 'Leve2 Employee A - 2',
            EPW_Position_ID__c =  '10000002',
            EPW_Status__c = 'Active',
            EPW_Dept_Code_Description__c = 'Transportation'
        );
        myPoHiList.add(myPoHi4); 

        EPW_Position_Hierarchy__c myPoHi5 = new EPW_Position_Hierarchy__c
        (   RecordTypeId = Revsys_StaticUtility.POSITION_HIERARCHY_AMTRAK_RECTYPE_ID, 
            EPW_Parent_Position_Hierarchy__c = myPoHi1.Id, 
            EPW_Position_Organization__c = Org1.Id,
            Name = 'Leve2 Employee A - 3',
            EPW_Position_ID__c =  '10000003',
            EPW_Status__c = 'Active',
            EPW_Dept_Code_Description__c = 'Transportation'
        );
        myPoHiList.add(myPoHi5); 

        EPW_Position_Hierarchy__c myPoHi6 = new EPW_Position_Hierarchy__c
        (   RecordTypeId = Revsys_StaticUtility.POSITION_HIERARCHY_AMTRAK_RECTYPE_ID, 
            EPW_Parent_Position_Hierarchy__c = myPoHi2.Id, 
            EPW_Position_Organization__c = Org1.Id,
            Name = 'Leve2 Employee B - 1',
            EPW_Position_ID__c =  '20000001',
            EPW_Status__c = 'Active',
            EPW_Dept_Code_Description__c = 'Transportation'
        );
        myPoHiList.add(myPoHi6); 

        EPW_Position_Hierarchy__c myPoHi7 = new EPW_Position_Hierarchy__c
        (   RecordTypeId = Revsys_StaticUtility.POSITION_HIERARCHY_AMTRAK_RECTYPE_ID, 
            EPW_Parent_Position_Hierarchy__c = myPoHi2.Id, 
            EPW_Position_Organization__c = Org1.Id,
            Name = 'Leve2 Employee B - 1',
            EPW_Position_ID__c =  '20000002',
            EPW_Status__c = 'Active',
            EPW_Dept_Code_Description__c = 'Transportation'
        );
        myPoHiList.add(myPoHi7); 

        EPW_Position_Hierarchy__c myPoHi8 = new EPW_Position_Hierarchy__c
        (   RecordTypeId = Revsys_StaticUtility.POSITION_HIERARCHY_AMTRAK_RECTYPE_ID, 
            EPW_Parent_Position_Hierarchy__c = myPoHi2.Id, 
            EPW_Position_Organization__c = Org1.Id,
            Name = 'Leve2 Employee B - 1',
            EPW_Position_ID__c =  '20000003',
            EPW_Status__c = 'Active',
            EPW_Dept_Code_Description__c = 'Transportation' 
        );
        myPoHiList.add(myPoHi8); 

        insert myPoHiList; 
        
        EPW_Position_Hierarchy__c myPoHi11 = new EPW_Position_Hierarchy__c
            (   RecordTypeId = Revsys_StaticUtility.POSITION_HIERARCHY_SPARTN_RECTYPE_ID, 
             EPW_Parent_Position_Hierarchy__c = myPoHi2.Id, 
             EPW_Position_Organization__c = Org1.Id,
             Name = 'Leve2 Employee B - 1',
             EPW_Position_ID__c =  '20000003',
             EPW_Status__c = 'Active',
             EPW_Dept_Code_Description__c = 'Transportation' 
            );
        insert myPoHi11;
        
    }
   /* private static testmethod void getHrAssgnmentByContactTest(){
       	 Set<Id> cSet = new Set<Id>();
            for(EPW_Hierarchy_Assignment__c cId : [SELECT Id FROM EPW_Hierarchy_Assignment__c] ) {
                cSet.add(cId);
            }
         SelectorWrapper wrapper2 = HierarchyAssignmentSelector.getHrAssgnmentByContact(cSet);
    }*/
    private static testmethod void getHrAssgnmentByPositionHierarchyTest(){
        Set<Id> parentPositionHierarchyList = new Set<Id>();
        for(EPW_Position_Hierarchy__c posHierarchy : [SELECT Id,EPW_Parent_Position_Hierarchy__c FROM EPW_Position_Hierarchy__c] ) {
            if(posHierarchy.EPW_Parent_Position_Hierarchy__c != null)  { 
            parentPositionHierarchyList.add(posHierarchy.EPW_Parent_Position_Hierarchy__c);
            }
        }
        
        HierarchyAssignmentSelector.DoFailTest = FALSE;
        SelectorWrapper wrapper = HierarchyAssignmentSelector.getHrAssgnmentByPositionHierarchy(parentPositionHierarchyList);
        System.debug('wrapper message '+ wrapper.ErrorMessage);
        System.assertEquals(null, wrapper.ErrorMessage);

		Map<Id,Id> parentContactMap = new Map<Id,Id>();        
        if(wrapper!=null && String.isBlank(wrapper.ErrorMessage)) {
            for(EPW_Hierarchy_Assignment__c hr : (List<EPW_Hierarchy_Assignment__c>)wrapper.sObjectList) {
                parentContactMap.put(hr.EPW_Position_Hierarchy__c, hr.EPW_Contact__c);
            }
        }    
            Set<Id> cSet = new Set<Id>();
            for(Id cId :parentContactMap.values() ) {
                cSet.add(cId);
            }
        SelectorWrapper wrapper2 = HierarchyAssignmentSelector.getHrAssgnmentByContact(cSet);
         System.debug('wrapper message '+ wrapper2.ErrorMessage);
        System.assertEquals(null, wrapper2.ErrorMessage);

        
         HierarchyAssignmentSelector.DoFailTest = TRUE;
        SelectorWrapper wrapper1 = HierarchyAssignmentSelector.getHrAssgnmentByPositionHierarchy(parentPositionHierarchyList);
        System.debug('wrapper1 message '+ wrapper1.ErrorMessage);
        System.assertNotEquals(null, wrapper1.ErrorMessage);
        System.assertEquals(0, wrapper1.SObjectList.size());
        
         SelectorWrapper wrapper3 = HierarchyAssignmentSelector.getHrAssgnmentByContact(cSet);
         System.debug('wrapper message '+ wrapper3.ErrorMessage);
        System.assertNotEquals(null, wrapper3.ErrorMessage);
        System.assertEquals(0, wrapper3.SObjectList.size());
    }
}
/**
*___________________________________________________
*@Name:     Revsys_MapToContactHelper_Test
*@Author:   Chuck Walley
*@Created:  Date: March 15, 2018
*@Used_By:  SPARTN
*___________________________________________________
*@Description: Test for Revsys_MapToContactHelper
* 
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/
@isTest
public class Revsys_MapToContactHelper_Test { 
   
    //Creating Test Data
    @TestSetup
    public static void loadTestData()
    {
        SPARTN_Custom_Settings__c setting = new SPARTN_Custom_Settings__c();
        setting.Name = 'Valid Employee Department';
        setting.CsvString__c = 'TRANSPORTATION,ENGINEERING,MECHANICAL';
        insert setting;

        // Mapping Records 
        List<FieldConversionMap__c> myFcList = new List<FieldConversionMap__c>(); 

        // Crafts 
        FieldConversionMap__c myJFc10 = new FieldConversionMap__c
        ( 
            RecordTypeId = RevSys_StaticUtility.FIELDCONVERSIONMAP_SPARTNCRAFT_RECTYPE_ID,
            SAP_JobCode__c = '7000010',
            ResultingValueA__c = 'Supervisor'   
        );
        myFcList.add(myJFc10); 

        FieldConversionMap__c myJFc11 = new FieldConversionMap__c
        ( 
            RecordTypeId = RevSys_StaticUtility.FIELDCONVERSIONMAP_SPARTNCRAFT_RECTYPE_ID,
            SAP_JobCode__c = '7000011',
            ResultingValueA__c = 'Other'   
        );
        myFcList.add(myJFc11); 

        FieldConversionMap__c myJFc12 = new FieldConversionMap__c
        ( 
            RecordTypeId = RevSys_StaticUtility.FIELDCONVERSIONMAP_SPARTNCRAFT_RECTYPE_ID,
            SAP_JobCode__c = '7000012',
            ResultingValueA__c = 'Conductor'   
        );
        myFcList.add(myJFc12); 

        FieldConversionMap__c myJFc13 = new FieldConversionMap__c
        ( 
            RecordTypeId = RevSys_StaticUtility.FIELDCONVERSIONMAP_SPARTNCRAFT_RECTYPE_ID,
            SAP_JobCode__c = '7000013',
            ResultingValueA__c = 'Engineer'   
        );
        myFcList.add(myJFc13); 


        FieldConversionMap__c myJFc20 = new FieldConversionMap__c
        ( 
            RecordTypeId = RevSys_StaticUtility.FIELDCONVERSIONMAP_SPARTNCRAFT_RECTYPE_ID,
            SAP_JobCode__c = '7000020',
            ResultingValueA__c = 'Supervisor'   
        );
        myFcList.add(myJFc20); 

        FieldConversionMap__c myJFc21 = new FieldConversionMap__c
        ( 
            RecordTypeId = RevSys_StaticUtility.FIELDCONVERSIONMAP_SPARTNCRAFT_RECTYPE_ID,
            SAP_JobCode__c = '7000021',
            ResultingValueA__c = 'Other'   
        );
        myFcList.add(myJFc21); 

        FieldConversionMap__c myJFc22 = new FieldConversionMap__c
        ( 
            RecordTypeId = RevSys_StaticUtility.FIELDCONVERSIONMAP_SPARTNCRAFT_RECTYPE_ID,
            SAP_JobCode__c = '7000022',
            ResultingValueA__c = 'Conductor'   
        );
        myFcList.add(myJFc22); 

        FieldConversionMap__c myJFc23 = new FieldConversionMap__c
        ( 
            RecordTypeId = RevSys_StaticUtility.FIELDCONVERSIONMAP_SPARTNCRAFT_RECTYPE_ID,
            SAP_JobCode__c = '7000023',
            ResultingValueA__c = 'Engineer'   
        );
        myFcList.add(myJFc23); 

        // Divisions
        FieldConversionMap__c myOFc1 = new FieldConversionMap__c
        ( 
            RecordTypeId = RevSys_StaticUtility.FIELDCONVERSIONMAP_SPARTNLOCATION_RECTYPE_ID,  
            SAP_OrgUnit__c = '80000001',
            ResultingValueA__c = 'North'
        );
        myFcList.add(myOFc1); 

        FieldConversionMap__c myOFc2 = new FieldConversionMap__c
        ( 
            RecordTypeId = RevSys_StaticUtility.FIELDCONVERSIONMAP_SPARTNLOCATION_RECTYPE_ID,  
            SAP_OrgUnit__c = '80000002',
            ResultingValueA__c = 'South'
        );
        myFcList.add(myOFc2); 

        FieldConversionMap__c myOFc3 = new FieldConversionMap__c
        ( 
            RecordTypeId = RevSys_StaticUtility.FIELDCONVERSIONMAP_SPARTNLOCATION_RECTYPE_ID,  
            SAP_OrgUnit__c = '80000003',
            ResultingValueA__c = 'East'
        );
        myFcList.add(myOFc3);

        FieldConversionMap__c myOFc4 = new FieldConversionMap__c
        ( 
            RecordTypeId = RevSys_StaticUtility.FIELDCONVERSIONMAP_SPARTNLOCATION_RECTYPE_ID,  
            SAP_OrgUnit__c = '80000004',
            ResultingValueA__c = 'West'
        );
        myFcList.add(myOFc4);

        INSERT myFcList; 

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

        INSERT myContactList; 

        // Organization

        List<EPW_Organization__c> myOrgList = new List<EPW_Organization__c>(); 

        EPW_Organization__c Org1 = new EPW_Organization__c
        ( 
            RecordTypeId = Revsys_StaticUtility.ORGANIZATION_AMTRAKORG_RECTYPE_ID, 
            Name = '80000001', 
            EPW_Organization_Number__c = '80000001',
            EPW_Status__c = 'Active'
        );
        myOrgList.add(Org1);

        EPW_Organization__c Org2 = new EPW_Organization__c
        ( 
            RecordTypeId = Revsys_StaticUtility.ORGANIZATION_AMTRAKORG_RECTYPE_ID, 
            Name = '80000002', 
            EPW_Organization_Number__c = '80000002',
            EPW_Status__c = 'Active'
        );
        myOrgList.add(Org2);

        EPW_Organization__c Org3 = new EPW_Organization__c
        ( 
            RecordTypeId = Revsys_StaticUtility.ORGANIZATION_AMTRAKORG_RECTYPE_ID, 
            Name = '80000003', 
            EPW_Organization_Number__c = '80000003',
            EPW_Status__c = 'Active'
        );
        myOrgList.add(Org3);

        EPW_Organization__c Org4 = new EPW_Organization__c
        ( 
            RecordTypeId = Revsys_StaticUtility.ORGANIZATION_AMTRAKORG_RECTYPE_ID, 
            Name = '80000004', 
            EPW_Organization_Number__c = '80000004',
            EPW_Status__c = 'Active'
        );
        myOrgList.add(Org4);

        insert myOrgList; 

        // Position Hierarchy

        List<EPW_Position_Hierarchy__c> mySupPoHiList = new List<EPW_Position_Hierarchy__c>(); 

        EPW_Position_Hierarchy__c myPoHi1 = new EPW_Position_Hierarchy__c
        (   RecordTypeId = Revsys_StaticUtility.POSITION_HIERARCHY_AMTRAK_RECTYPE_ID, 
            EPW_Position_Organization__c = Org1.Id,
            Name = 'Leve1 Supervisor A',
            EPW_Position_ID__c =  '10000000',
            EPW_Status__c = 'Active',
            EPW_Job_Number__c = '7000010',
            EPW_Dept_Code_Description__c = 'Transportation'
        );
        mySupPoHiList.add(myPoHi1); 

        EPW_Position_Hierarchy__c myPoHi2 = new EPW_Position_Hierarchy__c
        (   RecordTypeId = Revsys_StaticUtility.POSITION_HIERARCHY_AMTRAK_RECTYPE_ID, 
            EPW_Position_Organization__c = Org2.Id,
            Name = 'Leve1 Supervisor B',
            EPW_Position_ID__c =  '20000000',
            EPW_Status__c = 'Active',
            EPW_Job_Number__c = '7000020',
            EPW_Dept_Code_Description__c = 'Engineering'
        );
        mySupPoHiList.add(myPoHi2); 

        INSERT mySupPoHiList; 


        List<EPW_Position_Hierarchy__c> myPoHiList = new List<EPW_Position_Hierarchy__c>(); 

        EPW_Position_Hierarchy__c myPoHi3 = new EPW_Position_Hierarchy__c
        (   RecordTypeId = Revsys_StaticUtility.POSITION_HIERARCHY_AMTRAK_RECTYPE_ID, 
            EPW_Position_Organization__c = Org1.Id,
            EPW_Parent_Position_Hierarchy__c = myPoHi1.Id,
            Name = 'Leve2 Employee A - 1',
            EPW_Position_ID__c =  '10000001',
            EPW_Status__c = 'Active',
            EPW_Job_Number__c = '7000011',
            EPW_Dept_Code_Description__c = 'Transportation'
        );
        myPoHiList.add(myPoHi3); 

        EPW_Position_Hierarchy__c myPoHi4 = new EPW_Position_Hierarchy__c
        (   RecordTypeId = Revsys_StaticUtility.POSITION_HIERARCHY_AMTRAK_RECTYPE_ID, 
            EPW_Position_Organization__c = Org1.Id,
            EPW_Parent_Position_Hierarchy__c = myPoHi1.Id,
            Name = 'Leve2 Employee A - 2',
            EPW_Position_ID__c =  '10000002',
            EPW_Status__c = 'Active',
            EPW_Job_Number__c = '7000012',
            EPW_Dept_Code_Description__c = 'Transportation'
        );
        myPoHiList.add(myPoHi4); 

        EPW_Position_Hierarchy__c myPoHi5 = new EPW_Position_Hierarchy__c
        (   RecordTypeId = Revsys_StaticUtility.POSITION_HIERARCHY_AMTRAK_RECTYPE_ID, 
            EPW_Position_Organization__c = Org1.Id,
            EPW_Parent_Position_Hierarchy__c = myPoHi1.Id,
            Name = 'Leve2 Employee A - 3',
            EPW_Position_ID__c =  '10000003',
            EPW_Status__c = 'Active',
            EPW_Job_Number__c = '7000013',
            EPW_Dept_Code_Description__c = 'Transportation'
        );
        myPoHiList.add(myPoHi5); 

        EPW_Position_Hierarchy__c myPoHi6 = new EPW_Position_Hierarchy__c
        (   RecordTypeId = Revsys_StaticUtility.POSITION_HIERARCHY_AMTRAK_RECTYPE_ID, 
            EPW_Position_Organization__c = Org2.Id,
            EPW_Parent_Position_Hierarchy__c = myPoHi2.Id,
            Name = 'Leve2 Employee B - 1',
            EPW_Position_ID__c =  '20000001',
            EPW_Job_Number__c = '7000021',
            EPW_Status__c = 'Active',
            EPW_Dept_Code_Description__c = 'Engineering'
        );
        myPoHiList.add(myPoHi6); 

        EPW_Position_Hierarchy__c myPoHi7 = new EPW_Position_Hierarchy__c
        (   RecordTypeId = Revsys_StaticUtility.POSITION_HIERARCHY_AMTRAK_RECTYPE_ID, 
            EPW_Position_Organization__c = Org2.Id,
            EPW_Parent_Position_Hierarchy__c = myPoHi2.Id,
            Name = 'Leve2 Employee B - 2',
            EPW_Position_ID__c =  '20000002',
            EPW_Status__c = 'Active',
            EPW_Job_Number__c = '7000022',
            EPW_Dept_Code_Description__c = 'Engineering'
        );
        myPoHiList.add(myPoHi7); 

        EPW_Position_Hierarchy__c myPoHi8 = new EPW_Position_Hierarchy__c
        (   RecordTypeId = Revsys_StaticUtility.POSITION_HIERARCHY_AMTRAK_RECTYPE_ID, 
            EPW_Position_Organization__c = Org2.Id,
            EPW_Parent_Position_Hierarchy__c = myPoHi2.Id,
            Name = 'Leve2 Employee B - 3',
            EPW_Position_ID__c =  '20000003',
            EPW_Status__c = 'Active',
            EPW_Job_Number__c = '7000023',
            EPW_Dept_Code_Description__c = 'Engineering' 
        );
        myPoHiList.add(myPoHi8); 

        insert myPoHiList; 

    }

    private static testmethod void test_startFromHierarchyAssignment()
    {
        Id amtrakPhRecTypeId = Revsys_StaticUtility.POSITION_HIERARCHY_AMTRAK_RECTYPE_ID; 
        
        String myQuery; 
        // Get all Position Hierarchy Records 
        QueryUtilityWrapper myQuWrap = QueryUtility.beginDynamicQuery(RevSys_StaticUtility.OBJAPI_POSITION_HIERARCHY);   
        myQuery = myQuWrap.QueryString; 
        myQuery += ' WHERE RecordTypeId = :amtrakPhRecTypeId '; 

        List<EPW_Position_Hierarchy__c> myPoHiList = Database.query(myQuery); 

        Map<String,EPW_Position_Hierarchy__c> myPoHiByNameMap = new Map<String,EPW_Position_Hierarchy__c>(); 

        for(EPW_Position_Hierarchy__c myPoHi :myPoHiList) {
            myPoHiByNameMap.put(myPoHi.Name, myPoHi); 
        }

        // Get all Contact records
        myQuWrap = QueryUtility.beginDynamicQuery(RevSys_StaticUtility.OBJAPI_CONTACT);   
        myQuery = myQuWrap.QueryString; 
        List<Contact> myEmpList = Database.query(myQuery); 

        Map<String,Contact> myEmpByFirstNameMap = new Map<String,Contact>(); 

        for(Contact myEmp :myEmpList) {
            myEmpByFirstNameMap.put(myEmp.FirstName, myEmp); 
        }

        // Contacts: Amy, Bob, Abigale, Adam, Ali, Babu, Barbara, Bose
        // PosHis:  Leve1 Supervisor A, Leve1 Supervisor B, 
        //          Leve2 Employee A - 1, Leve2 Employee A - 2, Leve2 Employee A - 3
        //          Leve2 Employee B - 1, Leve2 Employee B - 2, Leve2 Employee B - 3


        Contact myContactAmy     = myEmpByFirstNameMap.get('Amy'); 
        Contact myContactBob     = myEmpByFirstNameMap.get('Bob'); 
        Contact myContactAbigale = myEmpByFirstNameMap.get('Abigale'); 
        Contact myContactAdam    = myEmpByFirstNameMap.get('Adam'); 
        Contact myContactAli     = myEmpByFirstNameMap.get('Ali'); 
        Contact myContactBabu    = myEmpByFirstNameMap.get('Babu'); 
        Contact myContactBarbara = myEmpByFirstNameMap.get('Barbara'); 
        Contact myContactBose    = myEmpByFirstNameMap.get('Bose'); 

        EPW_Position_Hierarchy__c myPoHiA  = myPoHiByNameMap.get('Leve1 Supervisor A'); 
        EPW_Position_Hierarchy__c myPoHiB  = myPoHiByNameMap.get('Leve1 Supervisor B'); 
        EPW_Position_Hierarchy__c myPoHiA1 = myPoHiByNameMap.get('Leve2 Employee A - 1'); 
        EPW_Position_Hierarchy__c myPoHiA2 = myPoHiByNameMap.get('Leve2 Employee A - 2'); 
        EPW_Position_Hierarchy__c myPoHiA3 = myPoHiByNameMap.get('Leve2 Employee A - 3'); 
        EPW_Position_Hierarchy__c myPoHiB1 = myPoHiByNameMap.get('Leve2 Employee B - 1'); 
        EPW_Position_Hierarchy__c myPoHiB2 = myPoHiByNameMap.get('Leve2 Employee B - 2'); 
        EPW_Position_Hierarchy__c myPoHiB3 = myPoHiByNameMap.get('Leve2 Employee B - 3'); 

        List<EPW_Hierarchy_Assignment__c> myHiAsList = new List<EPW_Hierarchy_Assignment__c>(); 

        EPW_Hierarchy_Assignment__c myHiAsgn1 = new EPW_Hierarchy_Assignment__c
        ( 
            EPW_Contact__c = myContactAmy.Id,
            EPW_Position_Hierarchy__c = myPoHiA.Id,
            EPW_Status__c = 'Active'
        );
        myHiAsList.add(myHiAsgn1);
        //insert myHiAsgn1;

        EPW_Hierarchy_Assignment__c myHiAsgn2 = new EPW_Hierarchy_Assignment__c
        ( 
            EPW_Contact__c = myContactBob.Id,
            EPW_Position_Hierarchy__c = myPoHiB.Id,
            EPW_Status__c = 'Active'
        );
        myHiAsList.add(myHiAsgn2);
        //insert myHiAsgn2;

        EPW_Hierarchy_Assignment__c myHiAsgn3 = new EPW_Hierarchy_Assignment__c
        ( 
            EPW_Contact__c = myContactAbigale.Id,
            EPW_Position_Hierarchy__c = myPoHiA1.Id,
            EPW_Status__c = 'Active'
        );
        myHiAsList.add(myHiAsgn3);
        //insert myHiAsgn3;
         
        EPW_Hierarchy_Assignment__c myHiAsgn4 = new EPW_Hierarchy_Assignment__c
        ( 
            EPW_Contact__c = myContactAdam.Id,
            EPW_Position_Hierarchy__c = myPoHiA2.Id,
            EPW_Status__c = 'Active'
        );
        myHiAsList.add(myHiAsgn4);
        //insert myHiAsgn4;
         
        EPW_Hierarchy_Assignment__c myHiAsgn5 = new EPW_Hierarchy_Assignment__c
        ( 
            EPW_Contact__c = myContactAli.Id,
            EPW_Position_Hierarchy__c = myPoHiA3.Id,
            EPW_Status__c = 'Active'
        );
        myHiAsList.add(myHiAsgn5);
        //insert myHiAsgn5;

        EPW_Hierarchy_Assignment__c myHiAsgn6 = new EPW_Hierarchy_Assignment__c
        ( 
            EPW_Contact__c = myContactBabu.Id,
            EPW_Position_Hierarchy__c = myPoHiB1.Id,
            EPW_Status__c = 'Active'
        );
        myHiAsList.add(myHiAsgn6);
        //insert myHiAsgn6;

        EPW_Hierarchy_Assignment__c myHiAsgn7 = new EPW_Hierarchy_Assignment__c
        ( 
            EPW_Contact__c = myContactBarbara.Id,
            EPW_Position_Hierarchy__c = myPoHiB2.Id,
            EPW_Status__c = 'Active'
        );
        myHiAsList.add(myHiAsgn7);
        //insert myHiAsgn7;

        EPW_Hierarchy_Assignment__c myHiAsgn8 = new EPW_Hierarchy_Assignment__c
        ( 
            EPW_Contact__c = myContactBose.Id,
            EPW_Position_Hierarchy__c = myPoHiB3.Id,
            EPW_Status__c = 'Active'
        );
        myHiAsList.add(myHiAsgn8);
        //insert myHiAsgn8;

        INSERT myHiAsList; 

        // Check the results... 
        // Get all Contact records
        myQuWrap = QueryUtility.beginDynamicQuery(RevSys_StaticUtility.OBJAPI_CONTACT);   
        myQuery = myQuWrap.QueryString; 
        myEmpList = Database.query(myQuery); 

        myEmpByFirstNameMap = new Map<String,Contact>(); 

        for(Contact myEmp :myEmpList) {
            myEmpByFirstNameMap.put(myEmp.FirstName, myEmp); 
        }

        myContactAmy     = myEmpByFirstNameMap.get('Amy'); 
        myContactAbigale = myEmpByFirstNameMap.get('Abigale'); 
        myContactAdam    = myEmpByFirstNameMap.get('Adam'); 
        myContactAli     = myEmpByFirstNameMap.get('Ali'); 

        myContactBob     = myEmpByFirstNameMap.get('Bob'); 
        myContactBabu    = myEmpByFirstNameMap.get('Babu'); 
        myContactBarbara = myEmpByFirstNameMap.get('Barbara'); 
        myContactBose    = myEmpByFirstNameMap.get('Bose'); 

        system.assertEquals('Transportation',myContactAmy.Department); 
        system.assertEquals('Supervisor',myContactAmy.Craft__c); 
        system.assertEquals('North',myContactAmy.Division__c); 

        system.assertEquals('Transportation',myContactAbigale.Department); 
        system.assertEquals('Other',myContactAbigale.Craft__c); 
        system.assertEquals('North',myContactAbigale.Division__c);

        system.assertEquals('Transportation',myContactAdam.Department); 
        system.assertEquals('Conductor',myContactAdam.Craft__c); 
        system.assertEquals('North',myContactAdam.Division__c);

        system.assertEquals('Transportation',myContactAli.Department); 
        system.assertEquals('Engineer',myContactAli.Craft__c); 
        system.assertEquals('North',myContactAli.Division__c);

        system.assertEquals('Engineering',myContactBob.Department); 
        system.assertEquals('Supervisor',myContactBob.Craft__c); 
        system.assertEquals('South',myContactBob.Division__c); 

        system.assertEquals('Engineering',myContactBabu.Department); 
        system.assertEquals('Other',myContactBabu.Craft__c); 
        system.assertEquals('South',myContactBabu.Division__c);

        system.assertEquals('Engineering',myContactBarbara.Department); 
        system.assertEquals('Conductor',myContactBarbara.Craft__c); 
        system.assertEquals('South',myContactBarbara.Division__c);

        system.assertEquals('Engineering',myContactBose.Department); 
        system.assertEquals('Engineer',myContactBose.Craft__c); 
        system.assertEquals('South',myContactBose.Division__c);
    }

    private static testmethod void test_startFromPositionHierarchy()
    {
        Id amtrakPhRecTypeId = Revsys_StaticUtility.POSITION_HIERARCHY_AMTRAK_RECTYPE_ID; 
        String myQuery; 

        // Get all Position Hierarchy Records 
        QueryUtilityWrapper myQuWrap = QueryUtility.beginDynamicQuery(RevSys_StaticUtility.OBJAPI_POSITION_HIERARCHY);   
        myQuery = myQuWrap.QueryString; 
        myQuery += ' WHERE RecordTypeId = :amtrakPhRecTypeId '; 

        List<EPW_Position_Hierarchy__c> myPoHiList = Database.query(myQuery); 

        Map<String,EPW_Position_Hierarchy__c> myPoHiByNameMap = new Map<String,EPW_Position_Hierarchy__c>(); 

        for(EPW_Position_Hierarchy__c myPoHi :myPoHiList) {
            myPoHiByNameMap.put(myPoHi.Name, myPoHi); 
            system.debug('SSSSSSS myPoHi ' + myPoHi);
        }

        // Get all Contact records
        myQuWrap = QueryUtility.beginDynamicQuery(RevSys_StaticUtility.OBJAPI_CONTACT);   
        myQuery = myQuWrap.QueryString; 
        List<Contact> myEmpList = Database.query(myQuery); 

        Map<String,Contact> myEmpByFirstNameMap = new Map<String,Contact>(); 

        for(Contact myEmp :myEmpList) {
            myEmpByFirstNameMap.put(myEmp.FirstName, myEmp); 
        }

        // Contacts: Amy, Bob, Abigale, Adam, Ali, Babu, Barbara, Bose
        // PosHis:  Leve1 Supervisor A, Leve1 Supervisor B, 
        //          Leve2 Employee A - 1, Leve2 Employee A - 2, Leve2 Employee A - 3
        //          Leve2 Employee B - 1, Leve2 Employee B - 2, Leve2 Employee B - 3


        Contact myContactAmy     = myEmpByFirstNameMap.get('Amy'); 
        Contact myContactBob     = myEmpByFirstNameMap.get('Bob'); 
        Contact myContactAbigale = myEmpByFirstNameMap.get('Abigale'); 
        Contact myContactAdam    = myEmpByFirstNameMap.get('Adam'); 
        Contact myContactAli     = myEmpByFirstNameMap.get('Ali'); 
        Contact myContactBabu    = myEmpByFirstNameMap.get('Babu'); 
        Contact myContactBarbara = myEmpByFirstNameMap.get('Barbara'); 
        Contact myContactBose    = myEmpByFirstNameMap.get('Bose'); 

        EPW_Position_Hierarchy__c myPoHiA  = myPoHiByNameMap.get('Leve1 Supervisor A'); 
        EPW_Position_Hierarchy__c myPoHiB  = myPoHiByNameMap.get('Leve1 Supervisor B'); 
        EPW_Position_Hierarchy__c myPoHiA1 = myPoHiByNameMap.get('Leve2 Employee A - 1'); 
        EPW_Position_Hierarchy__c myPoHiA2 = myPoHiByNameMap.get('Leve2 Employee A - 2'); 
        EPW_Position_Hierarchy__c myPoHiA3 = myPoHiByNameMap.get('Leve2 Employee A - 3'); 
        EPW_Position_Hierarchy__c myPoHiB1 = myPoHiByNameMap.get('Leve2 Employee B - 1'); 
        EPW_Position_Hierarchy__c myPoHiB2 = myPoHiByNameMap.get('Leve2 Employee B - 2'); 
        EPW_Position_Hierarchy__c myPoHiB3 = myPoHiByNameMap.get('Leve2 Employee B - 3'); 

        List<EPW_Hierarchy_Assignment__c> myHiAsList = new List<EPW_Hierarchy_Assignment__c>(); 

        EPW_Hierarchy_Assignment__c myHiAsgn1 = new EPW_Hierarchy_Assignment__c
        ( 
            EPW_Contact__c = myContactAmy.Id,
            EPW_Position_Hierarchy__c = myPoHiA.Id,
            EPW_Status__c = 'Active'
        );
        myHiAsList.add(myHiAsgn1);
        //insert myHiAsgn1;

        EPW_Hierarchy_Assignment__c myHiAsgn2 = new EPW_Hierarchy_Assignment__c
        ( 
            EPW_Contact__c = myContactBob.Id,
            EPW_Position_Hierarchy__c = myPoHiB.Id,
            EPW_Status__c = 'Active'
        );
        myHiAsList.add(myHiAsgn2);
        //insert myHiAsgn2;

        EPW_Hierarchy_Assignment__c myHiAsgn3 = new EPW_Hierarchy_Assignment__c
        ( 
            EPW_Contact__c = myContactAbigale.Id,
            EPW_Position_Hierarchy__c = myPoHiA1.Id,
            EPW_Status__c = 'Active'
        );
        myHiAsList.add(myHiAsgn3);
        //insert myHiAsgn3;
         
        EPW_Hierarchy_Assignment__c myHiAsgn4 = new EPW_Hierarchy_Assignment__c
        ( 
            EPW_Contact__c = myContactAdam.Id,
            EPW_Position_Hierarchy__c = myPoHiA2.Id,
            EPW_Status__c = 'Active'
        );
        myHiAsList.add(myHiAsgn4);
        //insert myHiAsgn4;
         
        EPW_Hierarchy_Assignment__c myHiAsgn5 = new EPW_Hierarchy_Assignment__c
        ( 
            EPW_Contact__c = myContactAli.Id,
            EPW_Position_Hierarchy__c = myPoHiA3.Id,
            EPW_Status__c = 'Active'
        );
        myHiAsList.add(myHiAsgn5);
        //insert myHiAsgn5;

        EPW_Hierarchy_Assignment__c myHiAsgn6 = new EPW_Hierarchy_Assignment__c
        ( 
            EPW_Contact__c = myContactBabu.Id,
            EPW_Position_Hierarchy__c = myPoHiB1.Id,
            EPW_Status__c = 'Active'
        );
        myHiAsList.add(myHiAsgn6);
        //insert myHiAsgn6;

        EPW_Hierarchy_Assignment__c myHiAsgn7 = new EPW_Hierarchy_Assignment__c
        ( 
            EPW_Contact__c = myContactBarbara.Id,
            EPW_Position_Hierarchy__c = myPoHiB2.Id,
            EPW_Status__c = 'Active'
        );
        myHiAsList.add(myHiAsgn7);
        //insert myHiAsgn7;

        EPW_Hierarchy_Assignment__c myHiAsgn8 = new EPW_Hierarchy_Assignment__c
        ( 
            EPW_Contact__c = myContactBose.Id,
            EPW_Position_Hierarchy__c = myPoHiB3.Id,
            EPW_Status__c = 'Active'
        );
        myHiAsList.add(myHiAsgn8);
        //insert myHiAsgn8;

        INSERT myHiAsList; 

        // Get all Position Hierarchy Records 
        myQuWrap = QueryUtility.beginDynamicQuery(RevSys_StaticUtility.OBJAPI_POSITION_HIERARCHY);   
        myQuery = myQuWrap.QueryString; 
        myQuery += ' WHERE RecordTypeId = :amtrakPhRecTypeId '; 

        myPoHiList = Database.query(myQuery); 

        myPoHiByNameMap = new Map<String,EPW_Position_Hierarchy__c>(); 

        for(EPW_Position_Hierarchy__c myPoHi :myPoHiList) {
            myPoHiByNameMap.put(myPoHi.Name, myPoHi); 
            system.debug('myPoHi  ' + myPoHi);
        }

        // Get all Contact records
        myQuWrap = QueryUtility.beginDynamicQuery(RevSys_StaticUtility.OBJAPI_CONTACT);   
        myQuery = myQuWrap.QueryString; 
        myEmpList = Database.query(myQuery); 

        myEmpByFirstNameMap = new Map<String,Contact>(); 

        for(Contact myEmp :myEmpList) {
            myEmpByFirstNameMap.put(myEmp.FirstName, myEmp); 
        }

        // Contacts: Amy, Bob, Abigale, Adam, Ali, Babu, Barbara, Bose
        // PosHis:  Leve1 Supervisor A, Leve1 Supervisor B, 
        //          Leve2 Employee A - 1, Leve2 Employee A - 2, Leve2 Employee A - 3
        //          Leve2 Employee B - 1, Leve2 Employee B - 2, Leve2 Employee B - 3


        myContactAmy     = myEmpByFirstNameMap.get('Amy'); 
        myContactAbigale = myEmpByFirstNameMap.get('Abigale'); 
        myContactAdam    = myEmpByFirstNameMap.get('Adam'); 
        myContactAli     = myEmpByFirstNameMap.get('Ali'); 

        myContactBob     = myEmpByFirstNameMap.get('Bob'); 
        myContactBabu    = myEmpByFirstNameMap.get('Babu'); 
        myContactBarbara = myEmpByFirstNameMap.get('Barbara'); 
        myContactBose    = myEmpByFirstNameMap.get('Bose'); 


        myPoHiA  = myPoHiByNameMap.get('Leve1 Supervisor A'); 
        myPoHiB  = myPoHiByNameMap.get('Leve1 Supervisor B'); 
        myPoHiA1 = myPoHiByNameMap.get('Leve2 Employee A - 1'); 
        myPoHiA2 = myPoHiByNameMap.get('Leve2 Employee A - 2'); 
        myPoHiA3 = myPoHiByNameMap.get('Leve2 Employee A - 3'); 
        myPoHiB1 = myPoHiByNameMap.get('Leve2 Employee B - 1'); 
        myPoHiB2 = myPoHiByNameMap.get('Leve2 Employee B - 2'); 
        myPoHiB3 = myPoHiByNameMap.get('Leve2 Employee B - 3'); 

        myPoHiA.EPW_Job_Number__c  = '7000023';
        myPoHiA1.EPW_Job_Number__c = '7000022';
        myPoHiA2.EPW_Job_Number__c = '7000021';
        myPoHiA3.EPW_Job_Number__c = '7000020';

        myPoHiB.EPW_Job_Number__c  = '7000013';
        myPoHiB1.EPW_Job_Number__c = '7000012';
        myPoHiB2.EPW_Job_Number__c = '7000011';
        myPoHiB3.EPW_Job_Number__c = '7000010';

        UPDATE myPoHiByNameMap.values(); 

        String errMsg = Revsys_MapToContactHelper.startFromPositionHierarchy(myPoHiByNameMap.values() ); 

        // Check the results... 
        // Get all Contact records
        myQuWrap = QueryUtility.beginDynamicQuery(RevSys_StaticUtility.OBJAPI_CONTACT);   
        myQuery = myQuWrap.QueryString; 
        myEmpList = Database.query(myQuery); 

        myEmpByFirstNameMap = new Map<String,Contact>(); 

        for(Contact myEmp :myEmpList) {
            myEmpByFirstNameMap.put(myEmp.FirstName, myEmp); 
        }

        myContactAmy     = myEmpByFirstNameMap.get('Amy'); 
        myContactAbigale = myEmpByFirstNameMap.get('Abigale'); 
        myContactAdam    = myEmpByFirstNameMap.get('Adam'); 
        myContactAli     = myEmpByFirstNameMap.get('Ali'); 

        myContactBob     = myEmpByFirstNameMap.get('Bob'); 
        myContactBabu    = myEmpByFirstNameMap.get('Babu'); 
        myContactBarbara = myEmpByFirstNameMap.get('Barbara'); 
        myContactBose    = myEmpByFirstNameMap.get('Bose'); 

        system.assertEquals('Transportation',myContactAmy.Department); 
        system.assertEquals('Engineer',myContactAmy.Craft__c); 
        system.assertEquals('North',myContactAmy.Division__c); 

        system.assertEquals('Transportation',myContactAbigale.Department); 
        system.assertEquals('Conductor',myContactAbigale.Craft__c); 
        system.assertEquals('North',myContactAbigale.Division__c);

        system.assertEquals('Transportation',myContactAdam.Department); 
        system.assertEquals('Other',myContactAdam.Craft__c); 
        system.assertEquals('North',myContactAdam.Division__c);

        system.assertEquals('Transportation',myContactAli.Department); 
        system.assertEquals('Supervisor',myContactAli.Craft__c); 
        system.assertEquals('North',myContactAli.Division__c);

        system.assertEquals('Engineering',myContactBob.Department); 
        system.assertEquals('Engineer',myContactBob.Craft__c); 
        system.assertEquals('South',myContactBob.Division__c); 

        system.assertEquals('Engineering',myContactBabu.Department); 
        system.assertEquals('Conductor',myContactBabu.Craft__c); 
        system.assertEquals('South',myContactBabu.Division__c);

        system.assertEquals('Engineering',myContactBarbara.Department); 
        system.assertEquals('Other',myContactBarbara.Craft__c); 
        system.assertEquals('South',myContactBarbara.Division__c);

        system.assertEquals('Engineering',myContactBose.Department); 
        system.assertEquals('Supervisor',myContactBose.Craft__c); 
        system.assertEquals('South',myContactBose.Division__c);
    }
}
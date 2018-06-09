/**
*___________________________________________________
*@Name:     Revsys_HierarchyAssignmentHelper_Test2
*@Author:   Chuck Walley
*@Created:  Date: March 15, 2018
*@Used_By:  SPARTN
*___________________________________________________
*@Description: Test for Revsys_HierarchyAssignmentHelper
* 
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/
@isTest
public class Revsys_HierarchyAssignmentHelper_Test2 { 
   
    Static Integer maxRecords = 300; 
    Static Integer maxCerts = 20; 

    //Creating Test Data
    @TestSetup
    public static void loadTestData()
    {
        SPARTN_Custom_Settings__c setting = new SPARTN_Custom_Settings__c();  
        setting.Name = 'Valid Employee Department';
        setting.CsvString__c = 'TRANSPORTATION,ENGINEERING,MECHANICAL';    
        insert setting;

        // Load Targets

        List<OccupationCertification__c> ocList = new List<OccupationCertification__c>();

        for (Integer xCount = 1; xCount < maxCerts + 1; xCount++) {

            OccupationCertification__c OccCert1 = new OccupationCertification__c
            (
                RecordTypeId = RevSys_StaticUtility.OCCUPCERTIFICATION_SPARTNTARGET_RECTYPE_ID,
                Name                        = 'Occupational Target ' + String.valueOf(xCount), 
                TargetType__c               = 'Occupation',
                Department__c               = 'Transportation',
                MultiCraft__c               = 'Engineer',
                Frequency__c                = 'Quarters',
                LengthOfPeriod__c           = 1,
                NumberOfTestsPerPeriod__c   = 99,
                Status__c                   = 'Active',
                StartDate__c                = system.today()
            );
            ocList.add(OccCert1);

        }

        system.debug('ocList Size =  ' + ocList.Size() ); 

        system.debug('TTTTTTTTTTT Inserting Targets');  

        INSERT ocList; 

    
        // Load Account 

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

        // Load Contacts 

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

        for (Integer xCount = 1; xCount < maxRecords + 1; xCount++) {

            String myEmail = 'this.guy' + String.valueOf(xCount) + '@amtrak.off'; 

            Contact myContact = new Contact
            (
                AccountId           = amtrakAcct.id, 
                LastName            = 'LastName' + String.valueOf(xCount), 
                FirstName           = 'FirstName', 
                Department          = 'Mechanical',
                Personnel_Number__c = xCount,
                Email               = myEmail
            );
            myContactList.add(myContact); 
        }
        system.debug('BBBBBBBBBB Inserting Contact'); 

        system.debug('Contact Size =  ' + myContactList.Size() ); 

        INSERT myContactList; 

        // Organization

        List<EPW_Organization__c> myOrgList = new List<EPW_Organization__c>(); 

        EPW_Organization__c Org1 = new EPW_Organization__c
        ( 
            RecordTypeId = Revsys_StaticUtility.ORGANIZATION_AMTRAKORG_RECTYPE_ID, 
            Name = 'Org 80000001', 
            EPW_Organization_Number__c = '80000001',
            EPW_Status__c = 'Active'
        );
        myOrgList.add(Org1);

        EPW_Organization__c Org2 = new EPW_Organization__c
        ( 
            RecordTypeId = Revsys_StaticUtility.ORGANIZATION_SPARTN_RECTYPE_ID, 
            Name = 'Org 80000002', 
            EPW_Organization_Number__c = '80000002',
            EPW_Status__c = 'Active'
        );
        myOrgList.add(Org2);

        insert myOrgList; 



         EPW_Position_Hierarchy__c myPoHi1 = new EPW_Position_Hierarchy__c
        (   RecordTypeId = Revsys_StaticUtility.POSITION_HIERARCHY_AMTRAK_RECTYPE_ID, 
            EPW_Position_Organization__c = Org1.Id,
            Name = 'Leve1 Supervisor A',
            EPW_Position_ID__c =  '10000000',
            EPW_Status__c = 'Active',
            EPW_Dept_Code_Description__c = 'Transportation'
        );
        INSERT myPoHi1; 

        List<EPW_Position_Hierarchy__c> myPoHiList = new List<EPW_Position_Hierarchy__c>(); 

        for (Integer xCount = 1; xCount < maxRecords + 1; xCount++) {

            String myPosIdString = String.valueOf(xCount); 

            EPW_Position_Hierarchy__c myPoHi = new EPW_Position_Hierarchy__c
            (   RecordTypeId = Revsys_StaticUtility.POSITION_HIERARCHY_AMTRAK_RECTYPE_ID, 
                EPW_Position_Organization__c = Org1.Id,
                EPW_Parent_Position_Hierarchy__c = myPoHi1.Id, 
                Name = myPosIdString,
                EPW_Position_ID__c =  myPosIdString,
                EPW_Status__c = 'Active',
                EPW_Dept_Code_Description__c = 'Transportation',
                EPW_Job_Number__c = '7000013'
            );
            myPoHiList.add(myPoHi); 

        }

        INSERT myPoHiList; 
        
         EPW_Hierarchy_Assignment__c myHiAsgn1 = new EPW_Hierarchy_Assignment__c
            ( 
                EPW_Contact__c = supervisorA.Id,
                EPW_Position_Hierarchy__c = myPoHi1.Id,
                EPW_Status__c = 'Active'
            );
        insert myHiAsgn1;

        // Mapping Records 
        List<FieldConversionMap__c> myFcList = new List<FieldConversionMap__c>(); 

        // Crafts 


        FieldConversionMap__c myJFc13 = new FieldConversionMap__c
        ( 
            RecordTypeId = RevSys_StaticUtility.FIELDCONVERSIONMAP_SPARTNCRAFT_RECTYPE_ID,
            SAP_JobCode__c = '7000013',
            ResultingValueA__c = 'Engineer'   
        );
        myFcList.add(myJFc13); 

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

        INSERT myFcList; 

    }

    /* ************************************************************************
     *
     * TEST METHODS 
     *
     ************************************************************************** */ 


    private static testmethod void test_BulkProcessing()
    {
        
        // Get all Contact records
        QueryUtilityWrapper myQuWrap = QueryUtility.beginDynamicQuery(RevSys_StaticUtility.OBJAPI_CONTACT);   
        String myQuery = myQuWrap.QueryString; 
        List<Contact> myEmpList = Database.query(myQuery); 

        Map<String,Contact> myContactMap = new Map<String,Contact>(); 

        for(Contact myEmp :myEmpList) {
            myContactMap.put(String.ValueOf(myEmp.Personnel_Number__c), myEmp); 
        }

        // Get all Position Hierarchy Records 
        myQuWrap = QueryUtility.beginDynamicQuery(RevSys_StaticUtility.OBJAPI_POSITION_HIERARCHY);
        myQuery = myQuWrap.QueryString; 
        List<EPW_Position_Hierarchy__c> myPoHiList = Database.query(myQuery); 

        Map<String,EPW_Position_Hierarchy__c> myPoHiMap = new Map<String,EPW_Position_Hierarchy__c>(); 

        for(EPW_Position_Hierarchy__c myPoHi :myPoHiList) {
            myPoHiMap.put(String.ValueOf(myPoHi.EPW_Position_ID__c), myPoHi); 
        }

        // Create the Hierarchy Assignment Records 
        List<EPW_Hierarchy_Assignment__c> myHaList = new LIst<EPW_Hierarchy_Assignment__c>();  
        for (Integer xCount = 1; xCount < maxRecords + 1; xCount++) {

            String myKey = String.valueOf(xCount); 

            Contact myContact = myContactMap.get(myKey); 
            EPW_Position_Hierarchy__c myPosHi   = myPoHiMap.get(myKey);

            EPW_Hierarchy_Assignment__c myHa = new EPW_Hierarchy_Assignment__c 
            (  
                EPW_Contact__c            = myContact.Id,
                EPW_Position_Hierarchy__c = myPosHi.Id,
                EPW_Status__c             = 'Active'
            ); 
            myHaList.add(myHa); 
        }


        // Bypassing Processes becasue we don't have supervisors defined - that is checked in Revsys_HierarchyAssignment_Test
        SPARTN_BypassRuleSettings__c orgsettings = SPARTN_BypassRuleSettings__c.getOrgDefaults();  
        orgsettings.Processes__c = true; 
        insert orgsettings;    
        
        system.debug('STARTING TEST - STARTING TEST - STARTING TEST - STARTING TEST'); 

        Test.startTest(); 
            INSERT myHaList; 
            UPDATE myHaList;
        Test.stopTest(); 

        // Check the results 

        // Get all Contact records
        myQuWrap = QueryUtility.beginDynamicQuery(RevSys_StaticUtility.OBJAPI_CONTACT);   
        myQuery = myQuWrap.QueryString; 
        myEmpList = Database.query(myQuery); 

        myContactMap = new Map<String,Contact>(); 

        for(Contact myEmp :myEmpList) {
            myContactMap.put(String.ValueOf(myEmp.Personnel_Number__c), myEmp); 
        }

        // Check a random contact to ensure the Department, Craft and Division fields are set correctly
        Contact myContact = myContactMap.get('143'); 

        system.assertEquals('Transportation', myContact.Department); 
        system.assertEquals('Engineer', myContact.Craft__c); 
        system.assertEquals('North', myContact.Division__c); 

    }
    
}
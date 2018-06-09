/**
*___________________________________________________
*@Name:     Revsys_Contact_BulkInsert_Test
*@Author:   Chuck Walley
*@Created:  Date: June 6, 2018
*@Used_By:  SPARTN
*___________________________________________________
*@Description: Bulk Test for Position update 
* 
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/
@isTest
public class Revsys_Contact_BulkInsert_Test { 
   
    Static Integer maxRecords = 200;   

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
        
        // Load Position

        List<Position__c> myPosList = new List<Position__c>();

        for (Integer xCount = 1; xCount < maxRecords + 1; xCount++) {
            
            Position__c myPos = new Position__c
            (
                Cost_Center__c                      = '1', 
				Cost_Center_Name__c                 = 'One',
				Dept_Code_Description__c            = 'TRANSPORTATION', 
				Employee_Group__c                   = '1',
				Employee_Group_Text__c              = 'One',
				Employee_Subgroup__c                = '1',
				Employee_Subgroup_Text__c           = 'One',
				Generated_Reports_To_Position__c    = null,
				Job_Abbrev__c                       = 'Job',
				Job_Number__c                       = '7000013',
				Job_Title__c                        = 'Engineer',
				Organization_Unit_Name__c           = 'North',
				Org_Unit_Number__c                  = '80000001',
				Personnel_Area__c                   = '0000',
				Personnel_Area_Text__c              = '0000',
				Personnel_SubArea__c                = '0000',
				Personnel_SubArea_Text__c           = '0000',
				Position_Abbrv__c                   = 'AAA',
				Position_ID__c                      = String.ValueOf(xCount),
				Employment_Status__c                = 'Active',
				Region__c                           = null
            );
            
            system.debug('myPos: ' + myPos); 
            
            myPosList.add(myPos);
        }

        system.debug('myPosList Size =  ' + myPosList.Size() ); 

        INSERT myPosList; 

    }

    /* ************************************************************************
     *
     * TEST METHODS 
     *
     ************************************************************************** */ 


    private static testmethod void test_BulkUpdates()
    {
        // Get all Position records
        QueryUtilityWrapper myQuWrap = QueryUtility.beginDynamicQuery(label.OBJAPI_POSITION);   
        String myQuery = myQuWrap.QueryString; 
        List<Position__c> myPosList = Database.query(myQuery); 
    
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
           
        for(Position__c myPos :myPosList) { 
            
            String myEmail = 'this.guy' + myPos.Position_ID__c + '@amtrak.off'; 

            Contact myContact = new Contact
            (
                AccountId           = amtrakAcct.id, 
                LastName            = 'LastName' + myPos.Position_ID__c, 
                FirstName           = 'FirstName', 
                PositionLookup__c   = myPos.Id, 
                Personnel_Number__c = Integer.valueOf(myPos.Position_ID__c),
                Email               = myEmail
            );
            
            system.debug('myContact ' + myContact); 
            
            myContactList.add(myContact); 
        }
            
        Test.StartTest(); 
        
            INSERT myContactList;     
        
        Test.StopTest(); 
        
        // Get all Contact records with a Department of Mechanical 
        myQuWrap = QueryUtility.beginDynamicQuery(label.OBJAPI_CONTACT);   
        myQuery = myQuWrap.QueryString; 
        myQuery += ' WHERE Department = \'TRANSPORTATION\' '; 
        List<Contact> myConList = Database.query(myQuery); 
        
        system.assertEquals(maxRecords, myConList.size() ); 
        
        for(Contact myCon :myConList) { 
            system.assertEquals('Engineer',myCon.Craft__c);   
            system.assertEquals('North',myCon.Division__c);   
        }
    }
    
}
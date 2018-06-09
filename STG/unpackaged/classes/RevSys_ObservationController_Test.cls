@isTest(SeeAllData = false)
public class RevSys_ObservationController_Test {
    
    @TestSetup
    public static void loadTestData() {
        
        //all custom setting
        list<REVSYS_Custom_Settings__c>  revCSList = new list<REVSYS_Custom_Settings__c>();
        
        REVSYS_Custom_Settings__c revCS1 = new REVSYS_Custom_Settings__c();
        revCS1.Name = 'Obs Form-1872 Info Required Fields';
        revCS1.CSV_String__c = 'RailroadRule__c,RegionProperty__c,State__c,Date__c,PersonallyObserved__c,Result__c,SpeedCheckMethod__c,MpSg__c,TimeHH__c,TimeMM__c';
        revCS1.CsvString__c = 'RailroadRule__c,RegionProperty__c,State__c,Date__c,PersonallyObserved__c,Result__c,SpeedCheckMethod__c,MpSg__c,TimeHH__c,TimeMM__c';
        revCSList.add(revCS1);
        
        REVSYS_Custom_Settings__c revCS2 = new REVSYS_Custom_Settings__c();
        revCS2.Name = 'Obs Form-1875 At least one required';
        revCS2.CSV_String__c = 'OperatedFromText__c-OperatedFromCode__c,OperatedToText__c-OperatedToCode__c';
        revCS2.CsvString__c = 'OperatedFromText__c-OperatedFromCode__c,OperatedToText__c-OperatedToCode__c';
        revCSList.add(revCS2);
        
        REVSYS_Custom_Settings__c revCS3 = new REVSYS_Custom_Settings__c();
        revCS3.Name = 'Obs Form-1875 Info Required Fields';
        revCS3.CSV_String__c = 'OperatedFromCode__c,OperatedFromText__c,OperatedToCode__c,OperatedToText__c,EngineNumber__c,NumberOfEngines__c,NumberOfCars__c,InitialQualification__c,Date__c,TrainDescription__c';
        revCS3.CsvString__c = 'OperatedFromCode__c,OperatedFromText__c,OperatedToCode__c,OperatedToText__c,EngineNumber__c,NumberOfEngines__c,NumberOfCars__c,InitialQualification__c,Date__c,TrainDescription__c';
        revCSList.add(revCS3);
        
        REVSYS_Custom_Settings__c revCS4 = new REVSYS_Custom_Settings__c();
        revCS4.Name = 'Obs Form-1875 Need Improvement';
        revCS4.CSV_String__c = '3,4';
        revCS4.CsvString__c = '3,4';
        revCSList.add(revCS4);
        
        REVSYS_Custom_Settings__c revCS5 = new REVSYS_Custom_Settings__c();
        revCS5.Name = 'Obs Form-1876 At least one required';
        revCS5.CSV_String__c = 'OperatedFromText__c-OperatedFromCode__c,OperatedToText__c-OperatedToCode__c';
        revCS5.CsvString__c = 'OperatedFromText__c-OperatedFromCode__c,OperatedToText__c-OperatedToCode__c';
        revCSList.add(revCS5);
        
        REVSYS_Custom_Settings__c revCS6 = new REVSYS_Custom_Settings__c();
        revCS6.Name = 'Obs Form-1876 Info Required Fields';
        revCS6.CSV_String__c = 'Date__c,OperatedFromCode__c,OperatedFromText__c,OperatedToCode__c,OperatedToText__c,ObservationMethod__c';
        revCS6.CsvString__c = 'Date__c,OperatedFromCode__c,OperatedFromText__c,OperatedToCode__c,OperatedToText__c,ObservationMethod__c';
        revCSList.add(revCS6);
        
        REVSYS_Custom_Settings__c revCS7 = new REVSYS_Custom_Settings__c();
        revCS7.Name = 'Obs Form-1876 Need Improvement';
        revCS7.CSV_String__c = '3,4';
        revCS7.CsvString__c = '3,4';
        revCSList.add(revCS7);
        
        REVSYS_Custom_Settings__c revCS8 = new REVSYS_Custom_Settings__c();
        revCS8.Name = 'Obs Form-1877 At least one required';
        revCS8.CSV_String__c = 'OperatedFromText__c-OperatedFromCode__c,OperatedToText__c-OperatedToCode__c-OperatedFromText__c,OperatedToCode__c-OperatedToText__c';
        revCS8.CsvString__c = 'OperatedFromText__c-OperatedFromCode__c,OperatedToText__c-OperatedToCode__c-OperatedFromText__c,OperatedToCode__c-OperatedToText__c';
        revCSList.add(revCS8);
        
        REVSYS_Custom_Settings__c revCS9 = new REVSYS_Custom_Settings__c();
        revCS9.Name = 'Obs Form-1877 Info Required Fields';
        revCS9.CSV_String__c = 'Date__c,OperatedFromCode__c,OperatedFromText__c,OperatedToCode__c,OperatedToText__c,TrainDescription__c,EngineNumber__c,NumberOfEngines__c,NumberOfCars__c,InitialQualification__c';
        revCS9.CsvString__c = 'Date__c,OperatedFromCode__c,OperatedFromText__c,OperatedToCode__c,OperatedToText__c,TrainDescription__c,EngineNumber__c,NumberOfEngines__c,NumberOfCars__c,InitialQualification__c';
        revCSList.add(revCS9);
        
        REVSYS_Custom_Settings__c revCS10 = new REVSYS_Custom_Settings__c();
        revCS10.Name = 'Obs Form-1877 Need Improvement';
        revCS10.CSV_String__c = '2';
        revCS10.CsvString__c = '2';
        revCSList.add(revCS10);
        
        REVSYS_Custom_Settings__c revCS11 = new REVSYS_Custom_Settings__c();
        revCS11.Name = 'Obs Form-1878 Info Required Fields';
        revCS11.CSV_String__c = 'Date__c,SectionTower__c';
        revCS11.CsvString__c = '';
        revCSList.add(revCS11);
        
        REVSYS_Custom_Settings__c revCS12 = new REVSYS_Custom_Settings__c();
        revCS12.Name = 'Obs Form-1878 Need Improvement';
        revCS12.CSV_String__c = '3,4';
        revCS12.CsvString__c = '3,4';
        revCSList.add(revCS12);
        
        REVSYS_Custom_Settings__c revCS13 = new REVSYS_Custom_Settings__c();
        revCS13.Name = 'Obs Search Employee Display Columns';
        revCS13.CSV_String__c = 'Name,Personnel_ID__c,Department,Craft__c,AdditionalCrafts__c';
        revCS13.CsvString__c = 'Name,Personnel_ID__c,Department,Craft__c,AdditionalCrafts__c';
        revCSList.add(revCS13);
        
        REVSYS_Custom_Settings__c revCS14 = new REVSYS_Custom_Settings__c();
        revCS14.Name = 'Obs Search Employee Field Names';
        revCS14.CSV_String__c = 'Name,Employee_ID__c,Department,Craft__c,AdditionalCrafts__c';
        revCS14.CsvString__c = 'Name,Employee_ID__c,Department,Craft__c,AdditionalCrafts__c';
        revCSList.add(revCS14);
        
        REVSYS_Custom_Settings__c revCS15 = new REVSYS_Custom_Settings__c();
        revCS15.Name = 'Obs Search Employee SOQL Fields';
        revCS15.CSV_String__c = 'Name,Personnel_ID__c,Employee_ID__c,Department,Dept_Code_Desc__c,Craft__c,AdditionalCrafts__c,CrewBase__c,Division__c,Region__c,Occupation__c';
        revCS15.CsvString__c = 'Name,Personnel_ID__c,Employee_ID__c,Department,Dept_Code_Desc__c,Craft__c,AdditionalCrafts__c,CrewBase__c,Division__c,Region__c,Occupation__c';
        revCSList.add(revCS15);
        
        REVSYS_Custom_Settings__c revCS16 = new REVSYS_Custom_Settings__c();
        revCS16.Name = 'Observation Form-1875 Certification';
        revCS16.CSV_String__c = 'Engineer';
        revCS16.CsvString__c = 'Engineer';
        revCSList.add(revCS16);
        
        REVSYS_Custom_Settings__c revCS17 = new REVSYS_Custom_Settings__c();
        revCS17.Name = 'Observation Form-1875 Score List';
        revCS17.CSV_String__c = '0,1,2,3,4';
        revCS17.CsvString__c = '0,1,2,3,4';
        revCSList.add(revCS17);
        
        REVSYS_Custom_Settings__c revCS18 = new REVSYS_Custom_Settings__c();
        revCS18.Name = 'Observation Form-1876 Craft';
        revCS18.CSV_String__c = 'Student Engineer';
        revCS18.CsvString__c = 'Student Engineer';
        revCSList.add(revCS18);
        
        REVSYS_Custom_Settings__c revCS18a = new REVSYS_Custom_Settings__c();
        revCS18a.Name = 'Observation Form-1876 Class of Service';
        revCS18a.CSV_String__c = 'Student Engineer';
        revCS18a.CsvString__c = 'Student Engineer';
        revCSList.add(revCS18a);

        REVSYS_Custom_Settings__c revCS18b = new REVSYS_Custom_Settings__c();
        revCS18b.Name = 'Observation Form-1876 Filter Logic';
        revCS18b.CSV_String__c = 'OR';
        revCS18b.CsvString__c = 'OR';
        revCSList.add(revCS18b);

        REVSYS_Custom_Settings__c revCS19 = new REVSYS_Custom_Settings__c();
        revCS19.Name = 'Observation Form-1876 Score List';
        revCS19.CSV_String__c = '0,1,2,3,4';
        revCS19.CsvString__c = '0,1,2,3,4';
        revCSList.add(revCS19);
        
        /*
        REVSYS_Custom_Settings__c revCS20 = new REVSYS_Custom_Settings__c();
        revCS20.Name = 'Observation Form-1877 Certification';
        revCS20.CSV_String__c = 'Conductor';
        revCS20.CsvString__c = 'Conductor';
        revCSList.add(revCS20);*/
        
        REVSYS_Custom_Settings__c revCS21 = new REVSYS_Custom_Settings__c();
        revCS21.Name = 'Observation Form-1877 Score List';
        revCS21.CSV_String__c = '0,1,2';
        revCS21.CsvString__c = '0,1,2';
        revCSList.add(revCS21);
        
        REVSYS_Custom_Settings__c revCS22 = new REVSYS_Custom_Settings__c();
        revCS22.Name = 'Observation Form-1878 Craft';
        revCS22.CSV_String__c = 'Dispatcher,Train Directors,Block Operators/Asst';
        revCS22.CsvString__c = 'Dispatcher,Train Directors,Block Operators/Asst';
        revCSList.add(revCS22);
        
        REVSYS_Custom_Settings__c revCS23 = new REVSYS_Custom_Settings__c();
        revCS23.Name = 'Observation Form-1878 Score List';
        revCS23.CSV_String__c = '0,1,2,3';
        revCS23.CsvString__c = '0,1,2,3';
        revCSList.add(revCS23);
        
        REVSYS_Custom_Settings__c revCS24 = new REVSYS_Custom_Settings__c();
        revCS24.Name = 'Observation Path Steps';
        revCS24.CSV_String__c = 'Select Employees,Select Tests,Results,Review & Submit';
        revCS24.CsvString__c = 'Select Employees,Select Tests,Results,Review & Submit';
        revCSList.add(revCS24);
        
        REVSYS_Custom_Settings__c revCS25 = new REVSYS_Custom_Settings__c();
        revCS25.Name = 'Observation Record Type Test List';
        revCS25.CSV_String__c = 'Form-1872,Form-1875,Form-1876,Form-1877,Form-1878';
        revCS25.CsvString__c = 'Form-1872,Form-1875,Form-1876,Form-1877,Form-1878';
        revCSList.add(revCS25);
        
        REVSYS_Custom_Settings__c revCS26 = new REVSYS_Custom_Settings__c();
        revCS26.Name = 'PermissionsforObservations';
        revCS26.CSV_String__c = 'SPARTN_Certification_Administrator,SPARTN_Manager_of_Train_Operations,SPARTN_Road_Foreman,SPARTN_Target_Administrator,SPARTN_Train_Master,SPARTN_Testing_Officer';
        revCS26.CsvString__c = 'SPARTN_Certification_Administrator,SPARTN_Manager_of_Train_Operations,SPARTN_Road_Foreman,SPARTN_Target_Administrator,SPARTN_Train_Master,SPARTN_Testing_Officer';
        revCSList.add(revCS26);
        
        REVSYS_Custom_Settings__c revCS27 = new REVSYS_Custom_Settings__c();
        revCS27.Name = 'Valid Employee Department';
        revCS27.CSV_String__c = 'TRANSPORTATION,ENGINEERING,MECHANICAL';
        revCS27.CsvString__c = 'TRANSPORTATION,ENGINEERING,MECHANICAL';
        revCSList.add(revCS27);
        
        insert revCSList;
        
        // Create Occupation Requirements (Observations)  
        OccupationRequirement__c myOR1 = new OccupationRequirement__c 
        ( 
            RecordTypeId = RevSys_StaticUtility.OCCREQUIREMENT_SPARTNOBSERVATION_RECTYPE_ID, 
            TestNumber__c   = '100', 
            TestName__c     = 'Test 100',
            Name            = '100 - Test 100',
            Status__c       = 'Active',
            SpeedCheckMethod__c = 'Stopping within One-Half the Range of Vision',
            Check_Method_Required__c = 'Yes - Required'
        ); 

        insert myOR1; 
        
        OccupationSpecificRequirement__c myOSR1 = new OccupationSpecificRequirement__c(
        	RecordTypeId = RevSys_StaticUtility.OCCSPECREQUIREMENT_DEPTCERT_FOR_OBS_RECTYPE_ID,
            ObservationDepartment2__c = 'Mechanical',
            ObservationCraft2__c = 'Conductor',
            Observation__c = myOR1.Id,
            Status__c       = 'Active'
        );
        
        insert myOSR1;
        
        //position list 
        List<Position__c> myPositionList = new List<Position__c>(); 

        Position__c PosSupervisorA = new Position__c
            (
                //RecordTypeId                    = null,
                Name                            = 'Transportation Engineer',
                Job_Title__c                    = 'Transportation Engineer',
                Position_ID__c                  = '10000000',
                Cost_Center__c                  = '1234',
                Cost_Center_Name__c             = 'Cost Center',
                Region__c                       = 'Region 1',
                //Division__c                     = 'Division 11',
                //Subdivision__c                  = 'Subdivision 111', 
                Dept_Code_Description__c        = 'Transportation',
                //Craft_Code_Description__c       = 'Engineer',
                //Crew_Base__c                    = 'Base1',
                HoursOfSericeEmployee__c    = true,
                Personnel_Area__c               = '1234'
            );
            myPositionList.add(PosSupervisorA); 

        Position__c PosSupervisorB = new Position__c
            (
                //RecordTypeId                    = null,
                Name                            = 'Transportation Conductor',
                Job_Title__c                    = 'Transportation Conductor',
                Position_ID__c                  = '20000000',
                Cost_Center__c                  = '1234',
                Cost_Center_Name__c             = 'Cost Center',
                Region__c                       = 'Region 1',
                //Division__c                     = 'Division 11',
                //Subdivision__c                  = 'Subdivision 111', 
                Dept_Code_Description__c        = 'Transportation',
                //Craft_Code_Description__c       = 'Conductor',
                //Crew_Base__c                    = 'Base1',
                HoursOfSericeEmployee__c    = true,
                Personnel_Area__c               = '1234'
            );
            myPositionList.add(PosSupervisorB); 

        Position__c PosEmployeeA1 = new Position__c
            (
                //RecordTypeId                    = null,
                Name                            = 'Transportation Engineer',
                Job_Title__c                    = 'Transportation Engineer',
                Position_ID__c                  = '10000001',
                Cost_Center__c                  = '1234',
                Cost_Center_Name__c             = 'Cost Center',
                Region__c                       = 'Region 1',
                //Division__c                     = 'Division 11',
                //Subdivision__c                  = 'Subdivision 111', 
                Dept_Code_Description__c        = 'Transportation',
                //Craft_Code_Description__c       = 'Engineer',
                //Crew_Base__c                    = 'Base1',
                HoursOfSericeEmployee__c   = true,
                Personnel_Area__c               = '1234'
            );
            myPositionList.add(PosEmployeeA1); 

        INSERT myPositionList;
        
        Position__c PosEmployeeA2 = new Position__c
            (
                //RecordTypeId                    = null,
                Name                            = 'Transportation Engineer',
                Job_Title__c                    = 'Transportation Engineer',
                Position_ID__c                  = '10000006',
                Cost_Center__c                  = '1234',
                Cost_Center_Name__c             = 'Cost Center',
                Region__c                       = 'Region 1',
                Generated_Reports_To_Position__c = myPositionList.get(0).Id,
                //Division__c                     = 'Division 11',
                //Subdivision__c                  = 'Subdivision 111', 
                Dept_Code_Description__c        = 'Transportation',
                //Craft_Code_Description__c       = 'Engineer',
                //Crew_Base__c                    = 'Base1',
                HoursOfSericeEmployee__c   = true,
                Personnel_Area__c               = '1234'
            );
        
        insert PosEmployeeA2;
        
        //contact
        List<Contact> myContactList = new List<Contact>(); 
        
        // supervisors
        Contact supervisorA = new Contact
            (
                //AccountId           = amtrakAcct.id, 
                LastName            ='Supervisor', 
                FirstName           ='Amy', 
                Personnel_Number__c = 10000000,
                Employment_Status__c = 'Active',
                Email               = 'amy.supervisor@amtrak.com',
                OnTheJobTrainingStartDate__c = system.today(),
                Department = 'Mechanical',
                Craft__c = 'Conductor'
                //PositionLookup__c   = PosSupervisorA.Id
            );
        myContactList.add(supervisorA); 
        
        Contact supervisorB = new Contact
            (
                //AccountId           = amtrakAcct.id, 
                LastName            ='Supervisor', 
                FirstName           ='Bob', 
                Personnel_Number__c = 20000000,
                Employment_Status__c = 'Active',
                Email               = 'bob.supervisor@amtrak.com',
                Department = 'Mechanical',
                Craft__c = 'Student Engineer'
                //PositionLookup__c   = PosSupervisorB.Id
            );
        myContactList.add(supervisorB);
        
        // employees for supervisor A
        
        Contact employeeA1 = new Contact
            (
                //AccountId           = amtrakAcct.id, 
                LastName            ='Employee', 
                FirstName           ='Abigale', 
                Personnel_Number__c = 10000001,
                Employment_Status__c = 'Active',
                Email               = 'abigale.employee@amtrak.com',
                Department = 'Mechanical',
                Craft__c = 'Conductor'
            );
        myContactList.add(employeeA1);
        
        Contact employeeA2 = new Contact
            (
                LastName            ='TestLast1', 
                FirstName           ='TestFirst1', 
                Personnel_Number__c = 1110920,
                Employment_Status__c = 'Active',
                Email               = 'test1@amtrak.com',
                Department = 'Mechanical',
                Craft__c = 'Test Craft1'
            );
        myContactList.add(employeeA2);
        
        insert myContactList;
        
        OccupationCertification__c myOC = new OccupationCertification__c(
        	Name = 'Test SPARTN Certification',
            Frequency__c = 'Months',
            LengthOfPeriod__c = 2,
            Status__c = 'Active',
            CertificationType__c = 'Conductor',
            TargetType__c = 'Supervisor',
            RecordTypeId = RevSys_StaticUtility.OCCUPCERTIFICATION_SPARTNCERT_RECTYPE_ID
        );
        
        insert myOC;
        
        myOSR1.Certification__c = myOC.Id;
        update myOSR1;
        
        Id conductorContactId = null;
        for(Contact c : myContactList){
            string firstName = c.FirstName;
            if(firstName.equalsIgnoreCase('Abigale')){
                conductorContactId = c.Id;
                break;
            }
        }
        
        //Date currentDate = system.today();
        Date currentDate = Date.valueOf(System.now());
        Date futureDate = currentDate.addDays(10);
        //String futureDate = AMTRAK_DateUtility.processDate(System.today().addDays(10));
        list<EmployeeSpecificRequirement__c> myEsrList = new list<EmployeeSpecificRequirement__c>();
        EmployeeSpecificRequirement__c myEsr = new EmployeeSpecificRequirement__c(
            Employee__c = conductorContactId,
            EndDate__c = futureDate,
            Archived__c = false,
            RecordTypeId = RevSys_StaticUtility.EMPSPECREQUIREMENT_SPARTNTARGET_RECTYPE_ID
        );
        myEsrList.add(myEsr);
        insert myEsrList;
        
        /*EmployeeCertification__c ec1 = new EmployeeCertification__c(
        	Status__c = 'Pending',
            Certification__c = myOC.Id,
            Employee__c = conductorContactId
            //LastCertificationDate__c = system.today()
        );
        
        insert ec1;*/
	
        //observations
        List<Observation__c> myObservationList = new List<Observation__c>(); 
		Observation__c obs1 = new Observation__c
        ( 
            RecordTypeId                    = RevSys_StaticUtility.OBSERVATION_TEST1875_RECTYPE_ID,
            Status__c                       = 'Draft',
            Date__c                         = Date.today(), 
            Department__c                   = 'Engineering ET',
            Employee__c                     = supervisorA.Id,
            Number_of_Workers_Observed__c = 1,
            OccupationSpecificRequirement__c = myOSR1.Id
        );
        myObservationList.add(obs1);

        Observation__c obs2 = new Observation__c
        ( 
            RecordTypeId                    = RevSys_StaticUtility.OBSERVATION_TEST1876_RECTYPE_ID,
            Status__c                       = 'Draft',
            Date__c                         = Date.today(), 
            Department__c                   = 'Engineering ET',
            Employee__c                     = supervisorA.Id,
            Number_of_Workers_Observed__c = 1,
            OccupationSpecificRequirement__c = myOSR1.Id
        );
        myObservationList.add(obs2);

        Observation__c obs3 = new Observation__c
        ( 
            RecordTypeId                    = RevSys_StaticUtility.OBSERVATION_TEST1877_RECTYPE_ID,
            Status__c                       = 'Draft',
            Date__c                         = Date.today(), 
            Department__c                   = 'Engineering ET',
            Employee__c                     = supervisorA.Id,
            Number_of_Workers_Observed__c = 1,
            OccupationSpecificRequirement__c = myOSR1.Id
        );
        myObservationList.add(obs3);

        Observation__c obs4 = new Observation__c
        ( 
            RecordTypeId                    = RevSys_StaticUtility.OBSERVATION_TEST1878_RECTYPE_ID,
            Status__c                       = 'Draft',
            Date__c                         = Date.today(), 
            Department__c                   = 'Engineering ET',
            Employee__c                     = supervisorA.Id,
            Number_of_Workers_Observed__c = 1,
            OccupationSpecificRequirement__c = myOSR1.Id
        );
        myObservationList.add(obs4);
        
        insert myObservationList; 
        
        //findings
        list<Finding__c> findingList = new list<Finding__c>();
        
        Finding__c myFinding1 = new Finding__c(
            RecordTypeId = RevSys_StaticUtility.FINDING_REVIEW_SYSTEMS_RECTYPE_ID,
        	Score__c = 0,
            Category__c = 'Form-1876',
            IsCriticalItem__c = true,
            Sequence__c = 150,
            Sub_category__c = 'Wayside Signals'
        );
        findingList.add(myFinding1);
        
        Finding__c myFinding2 = new Finding__c(
            RecordTypeId = RevSys_StaticUtility.FINDING_REVIEW_SYSTEMS_RECTYPE_ID,
        	Score__c = 0,
            Category__c = 'Form-1875',
            IsCriticalItem__c = false,
            Sequence__c = 160,
            Sub_category__c = 'Cab Signals'
        );
        findingList.add(myFinding2);
        
        insert findingList;
        
        //employee result summary
        list<EmployeeResultSummary__c> myERSlist = new list<EmployeeResultSummary__c>();
        
        EmployeeResultSummary__c myERS1 = new EmployeeResultSummary__c(
            RecordTypeId = RevSys_StaticUtility.EMP_RES_SUMM_TEST1878_RECTYPE_ID,
            Employee__c = conductorContactId,
            Observation__c = myObservationList.get(0).Id
        );
        myERSlist.add(myERS1);
        
        insert myERSlist;
    }
    
    public static testMethod void testInitPageObsTab() {
        
        //occupation requirement
        OccupationRequirement__c myOR1 = [select Id, RecordTypeId, TestNumber__c, TestName__c, Name, Status__c from OccupationRequirement__c limit 10000];
        
        //OccupationSpecificRequirement__c
        OccupationSpecificRequirement__c myOSR1 = [select Id, RecordTypeId, ObservationDepartment2__c, ObservationCraft2__c, Observation__c, Status__c from OccupationSpecificRequirement__c limit 10000];
        
        //contact list 
        List<Contact> myContactList = [select Id, LastName, FirstName, Personnel_Number__c, Email from Contact limit 10000];
        
        //observations
        List<Observation__c> myObservationList = [select Id, RecordTypeId, Status__c, Date__c, Department__c, Employee__c, Number_of_Workers_Observed__c, OccupationSpecificRequirement__c from Observation__c limit 10000];
        
        //Finding__c
        list<Finding__c> findingList = [select Id, Score__c, Category__c, IsCriticalItem__c, Sequence__c, QuestionLastModifiedVersion__c, Sub_category__c from Finding__c limit 10000];
        
        //custom setting 
        List<REVSYS_Custom_Settings__c> revCSList = REVSYS_Custom_Settings__c.getall().values();
        
        
        Map<String, String> params = new Map<String, String>();
        params.put('targetPage', 'obsTab');
        
        Test.startTest();
        Map<String, String> initReturn = RevSys_ObservationController.initPage(params);
        Test.stopTest();
        
        system.assert(initReturn != null);
    }
    
    public static testMethod void testInitPageRecordDetail() {
        
        //occupation requirement
        OccupationRequirement__c myOR1 = [select Id, RecordTypeId, TestNumber__c, TestName__c, Name, Status__c from OccupationRequirement__c limit 10000];
        
        //OccupationSpecificRequirement__c
        OccupationSpecificRequirement__c myOSR1 = [select Id, RecordTypeId, ObservationDepartment2__c, ObservationCraft2__c, Observation__c, Status__c from OccupationSpecificRequirement__c limit 10000];
        
        //contact list 
        List<Contact> myContactList = [select Id, LastName, FirstName, Personnel_Number__c, Email from Contact limit 10000];
        
        //observations
        List<Observation__c> myObservationList = [select Id, RecordTypeId, Status__c, Date__c, Department__c, Employee__c, Number_of_Workers_Observed__c, OccupationSpecificRequirement__c from Observation__c limit 10000];
        
        //Finding__c
        list<Finding__c> findingList = [select Id, Score__c, Category__c, IsCriticalItem__c, Sequence__c, QuestionLastModifiedVersion__c, Sub_category__c from Finding__c limit 10000];
        
        //custom setting 
        List<REVSYS_Custom_Settings__c> revCSList = REVSYS_Custom_Settings__c.getall().values();
        
        
        Map<String, String> params = new Map<String, String>();
        params.put('targetPage', 'recordDetail');
        params.put('obsId', myObservationList.get(0).Id);
        
        Test.startTest();
        Map<String, String> initReturn = RevSys_ObservationController.initPage(params);
        Test.stopTest();
        
        system.assert(initReturn != null);
    }
    
    public static testMethod void testGetItemsForTypeaheadSearch(){
        
        //occupation requirement
        OccupationRequirement__c myOR1 = [select Id, RecordTypeId, TestNumber__c, TestName__c, Name, Status__c from OccupationRequirement__c limit 10000];
        
        //OccupationSpecificRequirement__c
        OccupationSpecificRequirement__c myOSR1 = [select Id, RecordTypeId, ObservationDepartment2__c, ObservationCraft2__c, Observation__c, Status__c from OccupationSpecificRequirement__c limit 10000];
        
        //contact list 
        List<Contact> myContactList = [select Id, LastName, FirstName, Personnel_Number__c, Email from Contact limit 10000];
        
        //observations
        List<Observation__c> myObservationList = [select Id, RecordTypeId, Status__c, Date__c, Department__c, Employee__c, Number_of_Workers_Observed__c, OccupationSpecificRequirement__c from Observation__c limit 10000];
        
        //Finding__c
        list<Finding__c> findingList = [select Id, Score__c, Category__c, IsCriticalItem__c, Sequence__c, QuestionLastModifiedVersion__c, Sub_category__c from Finding__c limit 10000];
        
        //custom setting 
        List<REVSYS_Custom_Settings__c> revCSList = REVSYS_Custom_Settings__c.getall().values();
        
        String searchKey = 'Abi';
        String objectName = 'Contact';
        list<String> fieldsToSearchList = new list<String>();
        fieldsToSearchList.add('FirstName');
        fieldsToSearchList.add('LastName');
        
        Test.startTest();
        Map<String, String> initReturn = RevSys_ObservationController.getItemsForTypeaheadSearch(searchKey, objectName, fieldsToSearchList);
        Test.stopTest();
        
        system.assert(initReturn != null);
    }
    
    public static testMethod void testInsertNon1872_1876(){
        
        //occupation requirement
        OccupationRequirement__c myOR1 = [select Id, RecordTypeId, TestNumber__c, TestName__c, Name, Status__c from OccupationRequirement__c limit 10000];
        
        //OccupationSpecificRequirement__c
        OccupationSpecificRequirement__c myOSR1 = [select Id, RecordTypeId, ObservationDepartment2__c, ObservationCraft2__c, Observation__c, Status__c from OccupationSpecificRequirement__c limit 10000];
        
        //contact list 
        List<Contact> myContactList = [select Id, LastName, FirstName, Personnel_Number__c, Email from Contact limit 10000];
        Contact contact1 = myContactList.get(0);
        
        //observations
        List<Observation__c> myObservationList = [select Id, RecordTypeId, Status__c, Date__c, Department__c, Employee__c, Number_of_Workers_Observed__c, OccupationSpecificRequirement__c from Observation__c limit 10000];
         
        //Finding__c
        list<Finding__c> findingList = [select Id, Score__c, Category__c, IsCriticalItem__c, Sequence__c, QuestionLastModifiedVersion__c, Sub_category__c from Finding__c limit 10000];
        
        //EmployeeCertification__c
        //EmployeeCertification__c ec1 = [select Id, Employee__c, LastCertificationDate__c from EmployeeCertification__c limit 10000];
        
        //custom setting 
        List<REVSYS_Custom_Settings__c> revCSList = REVSYS_Custom_Settings__c.getall().values();
        
        Map<String, String> params = new Map<String, String>();
        params.put('observationJSON', '{\"attributes\":{\"type\":\"Observation__c\"},\"RecordTypeId\":\"'+RevSys_StaticUtility.OBSERVATION_TEST1876_RECTYPE_ID+'\",\"Employee__c\":\"'+contact1.Id+'\"}');
        params.put('rtName', 'Form-1876');
        
        Test.startTest();
        Map<String, String> returnVal = RevSys_ObservationController.insertNon1872(params);
        Test.stopTest();
        
        system.assert(returnVal != null);
        
    }
    
    public static testMethod void testInsertNon1872_1878(){
        
        //occupation requirement
        OccupationRequirement__c myOR1 = [select Id, RecordTypeId, TestNumber__c, TestName__c, Name, Status__c from OccupationRequirement__c limit 10000];
        
        //OccupationSpecificRequirement__c
        OccupationSpecificRequirement__c myOSR1 = [select Id, RecordTypeId, ObservationDepartment2__c, ObservationCraft2__c, Observation__c, Status__c from OccupationSpecificRequirement__c limit 10000];
        
        //contact list 
        List<Contact> myContactList = [select Id, LastName, FirstName, Personnel_Number__c, Email from Contact limit 10000];
        Contact contact1 = myContactList.get(0);
        
        //observations
        List<Observation__c> myObservationList = [select Id, RecordTypeId, Status__c, Date__c, Department__c, Employee__c, Number_of_Workers_Observed__c, OccupationSpecificRequirement__c from Observation__c limit 10000];
         
        //Finding__c
        list<Finding__c> findingList = [select Id, Score__c, Category__c, IsCriticalItem__c, Sequence__c, QuestionLastModifiedVersion__c, Sub_category__c from Finding__c limit 10000];
        
        //EmployeeCertification__c
        //EmployeeCertification__c ec1 = [select Id, Employee__c, LastCertificationDate__c from EmployeeCertification__c limit 10000];
        
        //custom setting 
        List<REVSYS_Custom_Settings__c> revCSList = REVSYS_Custom_Settings__c.getall().values();
        
        Map<String, String> params = new Map<String, String>();
        params.put('observationJSON', '{\"attributes\":{\"type\":\"Observation__c\"},\"RecordTypeId\":\"'+RevSys_StaticUtility.OBSERVATION_TEST1878_RECTYPE_ID+'\",\"Employee__c\":\"'+contact1.Id+'\"}');
        params.put('rtName', 'Form-1878');
        
        Test.startTest();
        Map<String, String> returnVal = RevSys_ObservationController.insertNon1872(params);
        Test.stopTest();
        
        system.assert(returnVal != null);
        
    }
    
    public static testMethod void testUpdateObservation(){
        
        //occupation requirement
        OccupationRequirement__c myOR1 = [select Id, RecordTypeId, TestNumber__c, TestName__c, Name, Status__c from OccupationRequirement__c limit 10000];
        
        //OccupationSpecificRequirement__c
        OccupationSpecificRequirement__c myOSR1 = [select Id, RecordTypeId, ObservationDepartment2__c, ObservationCraft2__c, Observation__c, Status__c from OccupationSpecificRequirement__c limit 10000];
        
        //contact list 
        List<Contact> myContactList = [select Id, LastName, FirstName, Personnel_Number__c, Email from Contact limit 10000];
        Contact contact1 = myContactList.get(0);
        system.debug('contact1 : ' + contact1);
        
        //observations
        List<Observation__c> myObservationList = [select Id, RecordTypeId, Status__c, SectionTower__c, Supervisor__c, Date__c, Department__c, Employee__c, Number_of_Workers_Observed__c, OccupationSpecificRequirement__c from Observation__c where RecordTypeId = :Revsys_Staticutility.OBSERVATION_TEST1878_RECTYPE_ID limit 10000];
        Observation__c obs1 = myObservationList.get(0);
        obs1.MovementOffice__c = 'Boston';
        obs1.SectionTower__c = 'Assistant Chief Train Dispatcher';
        obs1.Supervisor__c = contact1.Id;
        update obs1;
        system.debug('obs1 : ' + obs1);
        //TargetType__c
        
         
        //Finding__c
        list<Finding__c> findingList = [select Id, Score__c, Category__c, IsCriticalItem__c, Sequence__c, QuestionLastModifiedVersion__c, Sub_category__c from Finding__c limit 10000];
        Id findingId = findingList.get(0).Id;
        
        list<EmployeeResultSummary__c> myERSlist = [select Id, RecordTypeId, Employee__c, Observation__c from EmployeeResultSummary__c limit 10000];
        myERSlist.get(0).Employee__c = contact1.Id;
        myERSlist.get(0).Observation__c = obs1.Id;
        update myERSlist;
        system.debug('myERSlist : ' + myERSlist);
        
        //
        list<OccupationCertification__c> myOcList = [select Id, Name, Frequency__c, LengthOfPeriod__c, Status__c, CertificationType__c, TargetType__c, RecordTypeId from OccupationCertification__c limit 10000];
        system.debug('myOcList : ' + myOcList);
        
        list<EmployeeSpecificRequirement__c> myEsrList = [select Id, RecordTypeId, Employee__c, EndDate__c, Target__c, Archived__c from EmployeeSpecificRequirement__c limit 10000];
        myEsrList.get(0).Employee__c = contact1.Id;
        update myEsrList;
        system.debug('myEsrList : ' + myEsrList);
        
        
        //custom setting 
        List<REVSYS_Custom_Settings__c> revCSList = REVSYS_Custom_Settings__c.getall().values();
        
        Map<String, String> params = new Map<String, String>();
        params.put('observationJSON', '{\"attributes\":{\"type\":\"Observation__c\",\"url\":\"/services/data/v42.0/sobjects/Observation__c/'+obs1.Id+'\"},\"Employee__c\":\"'+contact1.Id+'\",\"OjtStartDate__c\":\"2018-03-06\",\"RecordTypeId\":\"'+RevSys_StaticUtility.OBSERVATION_TEST1876_RECTYPE_ID+'\",\"Id\":\"'+obs1.Id+'\",\"TimeHH__c\":\"\",\"TimeMM__c\":\"\",\"ObservationMethod__c\":\"Actual Ride\",\"Date__c\":\"2018-03-16\",\"OperatedFromText__c\":\"test\",\"OperatedToText__c\":\"test\",\"NeedsImprovement__c\":\"test\"}');
        params.put('rtName', 'Form-1876');
        params.put('findingListJSON', '[{\"attributes\":{\"type\":\"Finding__c\",\"url\":\"/services/data/v42.0/sobjects/Finding__c/'+findingId+'\"},\"RecordTypeId\":\"'+RevSys_StaticUtility.FINDING_REVIEW_SYSTEMS_RECTYPE_ID+'\",\"Category__c\":\"Form-1876\",\"Sub_category__c\":\"Wayside Signals\",\"Sequence__c\":150,\"Score__c\":\"2\",\"IsCriticalItem__c\":true,\"Observation__c\":\"'+obs1.Id+'\",\"Id\":\"'+findingId+'\"}]');
        //params.put('findingListJSON', '[{\"attributes\":{\"type\":\"Finding__c\",\"url\":\"/services/data/v42.0/sobjects/Finding__c/a03W00000053160IAA\"},\"RecordTypeId\":\"012W00000004hDQIAY\",\"Category__c\":\"Form-1876\",\"Sub_category__c\":\"Wayside Signals\",\"Sequence__c\":150,\"Score__c\":\"2\",\"IsCriticalItem__c\":true,\"Observation__c\":\"a05W0000006B3A4IAK\",\"Id\":\"a03W00000053160IAA\"},{\"attributes\":{\"type\":\"Finding__c\",\"url\":\"/services/data/v42.0/sobjects/Finding__c/a03W00000053161IAA\"},\"RecordTypeId\":\"012W00000004hDQIAY\",\"Category__c\":\"Form-1876\",\"Sub_category__c\":\"Cab Signals\",\"Sequence__c\":160,\"Score__c\":\"1\",\"IsCriticalItem__c\":false,\"Observation__c\":\"a05W0000006B3A4IAK\",\"Id\":\"a03W00000053161IAA\"}]');
        
        Test.startTest();
        Map<String, String> returnVal = RevSys_ObservationController.updateObservation(params);
        Test.stopTest();
        
        system.assert(returnVal != null);
    }
    
    public static testMethod void testSaveObservation(){
        
        //occupation requirement
        OccupationRequirement__c myOR1 = [select Id, RecordTypeId, TestNumber__c, TestName__c, Name, Status__c from OccupationRequirement__c limit 10000];
        
        //OccupationSpecificRequirement__c
        OccupationSpecificRequirement__c myOSR1 = [select Id, RecordTypeId, ObservationDepartment2__c, ObservationCraft2__c, Observation__c, Status__c from OccupationSpecificRequirement__c limit 10000];
        
        //contact list 
        List<Contact> myContactList = [select Id, LastName, FirstName, Personnel_Number__c, Email from Contact limit 10000];
        Contact contact1 = myContactList.get(0);
        
        //observations
        List<Observation__c> myObservationList = [select Id, RecordTypeId, Status__c, Date__c, Department__c, Employee__c, Number_of_Workers_Observed__c, OccupationSpecificRequirement__c from Observation__c limit 10000];
        Observation__c obs1 = myObservationList.get(0);
         
        //Finding__c
        list<Finding__c> findingList = [select Id, Score__c, Category__c, IsCriticalItem__c, Sequence__c, QuestionLastModifiedVersion__c, Sub_category__c from Finding__c limit 10000];
        
        //EmployeeCertification__c
        //EmployeeCertification__c ec1 = [select Id, Employee__c, LastCertificationDate__c from EmployeeCertification__c limit 10000];
        
        //custom setting 
        List<REVSYS_Custom_Settings__c> revCSList = REVSYS_Custom_Settings__c.getall().values();
        
        Map<String, String> params = new Map<String, String>();
        params.put('observationJSON', '{\"attributes\":{\"type\":\"Observation__c\",\"url\":\"/services/data/v42.0/sobjects/Observation__c/'+obs1.Id+'\"},\"Employee__c\":\"'+contact1.Id+'\",\"OjtStartDate__c\":\"2018-03-06\",\"RecordTypeId\":\"'+RevSys_StaticUtility.OBSERVATION_TEST1876_RECTYPE_ID+'\",\"Id\":\"'+obs1.Id+'\",\"TimeHH__c\":\"\",\"TimeMM__c\":\"\",\"ObservationMethod__c\":\"Actual Ride\",\"Date__c\":\"2018-03-16\",\"OperatedFromText__c\":\"test\",\"OperatedToText__c\":\"test\",\"NeedsImprovement__c\":\"test\"}');
        params.put('rtName', 'Form-1876');
        
        Test.startTest();
        Map<String, String> returnVal = RevSys_ObservationController.saveObservation(params);
        Test.stopTest();
        
        system.assert(returnVal != null);
    }
    
    public static testMethod void testSearchForEmployee(){
        
        //occupation requirement
        OccupationRequirement__c myOR1 = [select Id, RecordTypeId, TestNumber__c, TestName__c, Name, Status__c from OccupationRequirement__c limit 10000];
        
        //OccupationSpecificRequirement__c
        OccupationSpecificRequirement__c myOSR1 = [select Id, RecordTypeId, ObservationDepartment2__c, ObservationCraft2__c, Observation__c, Status__c from OccupationSpecificRequirement__c limit 10000];
        
        //contact list 
        List<Contact> myContactList = [select Id, LastName, FirstName, Personnel_Number__c, Email from Contact limit 10000];
        Contact contact1 = myContactList.get(0);
        
        //observations
        List<Observation__c> myObservationList = [select Id, RecordTypeId, Status__c, Date__c, Department__c, Employee__c, Number_of_Workers_Observed__c, OccupationSpecificRequirement__c from Observation__c limit 10000];
        Observation__c obs1 = myObservationList.get(0);
         
        //Finding__c
        list<Finding__c> findingList = [select Id, Score__c, Category__c, IsCriticalItem__c, Sequence__c, QuestionLastModifiedVersion__c, Sub_category__c from Finding__c limit 10000];
        
        //OccupationCertification__c
        OccupationCertification__c myOC = [select Id, Name, Frequency__c, Status__c from OccupationCertification__c limit 1];
        
        //EmployeeCertification__c
        /*EmployeeCertification__c ec1 = [select Id, Status__c, Certification__c, Employee__c from EmployeeCertification__c limit 1];
        ec1.ProcessFlag__c = 'CertifyProcess';
        ec1.Status__c = 'Current';
        update ec1;
        System.debug('*** ec1 : ' + ec1);*/
        
        //custom setting 
        List<REVSYS_Custom_Settings__c> revCSList = REVSYS_Custom_Settings__c.getall().values();
        //Obs Search Employee Display Columns
        if(revCSList != null && revCSList.size() > 0){
            for(REVSYS_Custom_Settings__c customSet : revCSList){
                if(customSet.Name.equalsIgnoreCase('Obs Search Employee Display Columns')){ 
                    string csvString = customSet.CSV_String__c;
                    csvString += ',Division__c,Region__c,Occupation__c';
                    customSet.CSV_String__c = csvString;
                }
            }
            
            update revCSList;
        }
        
        Map<String, String> params = new Map<String, String>();
        params.put('searchKey', 'Ab');
        params.put('filterMap', '{\"Craft\":\"Conductor\", \"Department\":\"Mechanical\"}');
        params.put('recordType', '{\"attributes\":{\"type\":\"RecordType\",\"url\":\"/services/data/v42.0/sobjects/RecordType/'+RevSys_StaticUtility.OBSERVATION_TEST1877_RECTYPE_ID+'\"},\"Id\":\"'+RevSys_StaticUtility.OBSERVATION_TEST1877_RECTYPE_ID+'\",\"Name\":\"Form-1877\",\"DeveloperName\":\"SPARTN_Form1877\"}');
        
        Test.startTest();
        Map<String, String> returnVal = RevSys_ObservationController.searchForEmployee(params);
        Test.stopTest();
        
        system.assert(returnVal != null);
    }
    
    public static testMethod void testSearchForEmployeeQueryExep(){
        
        //occupation requirement
        OccupationRequirement__c myOR1 = [select Id, RecordTypeId, TestNumber__c, TestName__c, Name, Status__c from OccupationRequirement__c limit 10000];
        
        //OccupationSpecificRequirement__c
        OccupationSpecificRequirement__c myOSR1 = [select Id, RecordTypeId, ObservationDepartment2__c, ObservationCraft2__c, Observation__c, Status__c from OccupationSpecificRequirement__c limit 10000];
        
        //contact list 
        List<Contact> myContactList = [select Id, LastName, FirstName, Personnel_Number__c, Email from Contact limit 10000];
        Contact contact1 = myContactList.get(0);
        
        //observations
        List<Observation__c> myObservationList = [select Id, RecordTypeId, Status__c, Date__c, Department__c, Employee__c, Number_of_Workers_Observed__c, OccupationSpecificRequirement__c from Observation__c limit 10000];
        Observation__c obs1 = myObservationList.get(0);
         
        //Finding__c
        list<Finding__c> findingList = [select Id, Score__c, Category__c, IsCriticalItem__c, Sequence__c, QuestionLastModifiedVersion__c, Sub_category__c from Finding__c limit 10000];
        
        //OccupationCertification__c
        OccupationCertification__c myOC = [select Id, Name, Frequency__c, Status__c from OccupationCertification__c limit 1];
        
        //custom setting 
        List<REVSYS_Custom_Settings__c> revCSList = REVSYS_Custom_Settings__c.getall().values();
        if(revCSList != null && revCSList.size() > 0){
            for(REVSYS_Custom_Settings__c customSet : revCSList){
                if(customSet.Name.equalsIgnoreCase('Obs Search Employee SOQL Fields')){ 
                    string csvString = customSet.CSV_String__c;
                    csvString += ',Test__c';
                    customSet.CSV_String__c = csvString;
                }
            }
            
            update revCSList;
        }
        
        
        Map<String, String> params = new Map<String, String>();
        params.put('searchKey', 'Ab');
        params.put('filterMap', '{\"Craft\":\"Conductor\", \"Department\":\"Mechanical\"}');
        RecordType rt = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SObjectType = 'Observation__c' AND Name LIKE '%1876' LIMIT 1];
        params.put('recordType', JSON.serialize(rt));
   //     params.put('recordType', '{\"attributes\":{\"type\":\"RecordType\",\"url\":\"/services/data/v42.0/sobjects/RecordType/'+RevSys_StaticUtility.OBSERVATION_TEST1877_RECTYPE_ID+'\"},\"Id\":\"'+RevSys_StaticUtility.OBSERVATION_TEST1877_RECTYPE_ID+'\",\"Name\":\"Form-1877\",\"DeveloperName\":\"SPARTN_Form1877\"}');
        
        Test.startTest();
        Map<String, String> returnVal = RevSys_ObservationController.searchForEmployee(params);
        Test.stopTest();
        
        system.assert(returnVal != null);
    }
    
    public static testMethod void testSearchForEmployeeWithEmpCert(){
        
        //occupation requirement
        OccupationRequirement__c myOR1 = [select Id, RecordTypeId, TestNumber__c, TestName__c, Name, Status__c from OccupationRequirement__c limit 10000];
        
        //OccupationSpecificRequirement__c
        OccupationSpecificRequirement__c myOSR1 = [select Id, RecordTypeId, ObservationDepartment2__c, ObservationCraft2__c, Observation__c, Status__c from OccupationSpecificRequirement__c limit 10000];
        
        //contact list 
        List<Contact> myContactList = [select Id, LastName, FirstName, Personnel_Number__c, Email from Contact limit 10000];
        Contact contact1 = myContactList.get(0);
        
        //observations
        List<Observation__c> myObservationList = [select Id, RecordTypeId, Status__c, Date__c, Department__c, Employee__c, Number_of_Workers_Observed__c, OccupationSpecificRequirement__c from Observation__c limit 10000];
        Observation__c obs1 = myObservationList.get(0);
         
        //Finding__c
        list<Finding__c> findingList = [select Id, Score__c, Category__c, IsCriticalItem__c, Sequence__c, QuestionLastModifiedVersion__c, Sub_category__c from Finding__c limit 10000];
        
        //OccupationCertification__c
        OccupationCertification__c myOC = [select Id, Name, Frequency__c, Status__c from OccupationCertification__c limit 1];
        
        //EmployeeCertification__c
        /*EmployeeCertification__c ec1 = [select Id, Status__c, Certification__c, Employee__c from EmployeeCertification__c limit 1];
        ec1.ProcessFlag__c = 'CertifyProcess';
        ec1.Status__c = 'Current';
        update ec1;
        System.debug('*** ec1 : ' + ec1);*/
        
        //custom setting 
        List<REVSYS_Custom_Settings__c> revCSList = REVSYS_Custom_Settings__c.getall().values();
        
        REVSYS_Custom_Settings__c revCS20 = new REVSYS_Custom_Settings__c();
        revCS20.Name = 'Observation Form-1877 Certification';
        revCS20.CSV_String__c = 'Conductor';
        revCS20.CsvString__c = 'Conductor';
        insert revCS20;
        
        Map<String, String> params = new Map<String, String>();
        params.put('searchKey', 'Ab');
        params.put('filterMap', '{\"Craft\":\"Conductor\", \"Department\":\"Mechanical\"}');
        params.put('recordType', '{\"attributes\":{\"type\":\"RecordType\",\"url\":\"/services/data/v42.0/sobjects/RecordType/'+RevSys_StaticUtility.OBSERVATION_TEST1877_RECTYPE_ID+'\"},\"Id\":\"'+RevSys_StaticUtility.OBSERVATION_TEST1877_RECTYPE_ID+'\",\"Name\":\"Form-1877\",\"DeveloperName\":\"SPARTN_Form1877\"}');
        
        Test.startTest();
        Map<String, String> returnVal = RevSys_ObservationController.searchForEmployee(params);
        Test.stopTest();
        
        system.assert(returnVal != null);
    }
    
    public static testMethod void testLoadTestSelection(){
        
        //occupation requirement
        OccupationRequirement__c myOR1 = [select Id, RecordTypeId, TestNumber__c, TestName__c, Name, Status__c from OccupationRequirement__c limit 10000];
        
        //OccupationSpecificRequirement__c
        OccupationSpecificRequirement__c myOSR1 = [select Id, RecordTypeId, ObservationDepartment2__c, ObservationCraft2__c, Observation__c, Status__c from OccupationSpecificRequirement__c limit 10000];
        
        //contact list 
        List<Contact> myContactList = [select Id, LastName, FirstName, Personnel_Number__c, Email from Contact limit 10000];
        Contact contact1 = myContactList.get(0);
        
        //observations
        List<Observation__c> myObservationList = [select Id, RecordTypeId, Status__c, Date__c, Department__c, Employee__c, Number_of_Workers_Observed__c, OccupationSpecificRequirement__c from Observation__c limit 10000];
        Observation__c obs1 = myObservationList.get(0);
         
        //Finding__c
        list<Finding__c> findingList = [select Id, Score__c, Category__c, IsCriticalItem__c, Sequence__c, QuestionLastModifiedVersion__c, Sub_category__c from Finding__c limit 10000];
        
        //EmployeeCertification__c
        //EmployeeCertification__c ec1 = [select Id, Employee__c, LastCertificationDate__c from EmployeeCertification__c limit 10000];
        
        //custom setting 
        List<REVSYS_Custom_Settings__c> revCSList = REVSYS_Custom_Settings__c.getall().values();
        
        Map<String, String> params = new Map<String, String>();
        params.put('selectedEmployees', '[{\"theNumber\":\"5078\",\"theName\":\"Bob Supervisor\",\"testNames\":null,\"selected\":true,\"recordId\":\"003W000000ksCOwIAM\",\"fieldValues\":[\"Bob Supervisor\",\"5078\",\"mechanical\",\"test Craft1\",null,\"CA49\"],\"fieldNames\":[\"Name\",\"Personnel_ID__c\",\"Department\",\"Craft__c\",\"AdditionalCrafts__c\",\"CrewBase__c\"],\"department\":\"Mechanical\",\"craft\":\"Test Craft1\",\"additionalFieldandValueMap\":{}}]');
        
        Test.startTest();
        Map<String, String> returnVal = RevSys_ObservationController.loadTestSelection(params);
        Test.stopTest();
        
        system.assert(returnVal != null);
    }
    
    public static testMethod void testLoadTestSelectionCheckMethodNo(){
        
        //occupation requirement
        OccupationRequirement__c myOR1 = [select Id, RecordTypeId, TestNumber__c, TestName__c, Name, Status__c from OccupationRequirement__c limit 10000];
        myOR1.Check_Method_Required__c = 'No';
        update myOR1;
        
        //OccupationSpecificRequirement__c
        OccupationSpecificRequirement__c myOSR1 = [select Id, RecordTypeId, ObservationDepartment2__c, ObservationCraft2__c, Observation__c, Status__c from OccupationSpecificRequirement__c limit 10000];
        
        //contact list 
        List<Contact> myContactList = [select Id, LastName, FirstName, Personnel_Number__c, Email from Contact limit 10000];
        Contact contact1 = myContactList.get(0);
        
        //observations
        List<Observation__c> myObservationList = [select Id, RecordTypeId, Status__c, Date__c, Department__c, Employee__c, Number_of_Workers_Observed__c, OccupationSpecificRequirement__c from Observation__c limit 10000];
        Observation__c obs1 = myObservationList.get(0);
         
        //Finding__c
        list<Finding__c> findingList = [select Id, Score__c, Category__c, IsCriticalItem__c, Sequence__c, QuestionLastModifiedVersion__c, Sub_category__c from Finding__c limit 10000];
        
        //EmployeeCertification__c
        //EmployeeCertification__c ec1 = [select Id, Employee__c, LastCertificationDate__c from EmployeeCertification__c limit 10000];
        
        //custom setting 
        List<REVSYS_Custom_Settings__c> revCSList = REVSYS_Custom_Settings__c.getall().values();
        
        Map<String, String> params = new Map<String, String>();
        params.put('selectedEmployees', '[{\"theNumber\":\"5078\",\"theName\":\"Bob Supervisor\",\"testNames\":null,\"selected\":true,\"recordId\":\"003W000000ksCOwIAM\",\"fieldValues\":[\"Bob Supervisor\",\"5078\",\"mechanical\",\"test Craft1\",null,\"CA49\"],\"fieldNames\":[\"Name\",\"Personnel_ID__c\",\"Department\",\"Craft__c\",\"AdditionalCrafts__c\",\"CrewBase__c\"],\"department\":\"Mechanical\",\"craft\":\"Test Craft1\",\"additionalFieldandValueMap\":{}}]');
        
        Test.startTest();
        Map<String, String> returnVal = RevSys_ObservationController.loadTestSelection(params);
        Test.stopTest();
        
        system.assert(returnVal != null);
    }
    
    public static testMethod void testLoadTestSelectionCheckMethodYesNotReq(){
        
        //occupation requirement
        OccupationRequirement__c myOR1 = [select Id, RecordTypeId, TestNumber__c, TestName__c, Name, Status__c from OccupationRequirement__c limit 10000];
        myOR1.Check_Method_Required__c = 'Yes - Not Required';
        update myOR1;
        
        //OccupationSpecificRequirement__c
        OccupationSpecificRequirement__c myOSR1 = [select Id, RecordTypeId, ObservationDepartment2__c, ObservationCraft2__c, Observation__c, Status__c from OccupationSpecificRequirement__c limit 10000];
        
        //contact list 
        List<Contact> myContactList = [select Id, LastName, FirstName, Personnel_Number__c, Email from Contact limit 10000];
        Contact contact1 = myContactList.get(0);
        
        //observations
        List<Observation__c> myObservationList = [select Id, RecordTypeId, Status__c, Date__c, Department__c, Employee__c, Number_of_Workers_Observed__c, OccupationSpecificRequirement__c from Observation__c limit 10000];
        Observation__c obs1 = myObservationList.get(0);
         
        //Finding__c
        list<Finding__c> findingList = [select Id, Score__c, Category__c, IsCriticalItem__c, Sequence__c, QuestionLastModifiedVersion__c, Sub_category__c from Finding__c limit 10000];
        
        //EmployeeCertification__c
        //EmployeeCertification__c ec1 = [select Id, Employee__c, LastCertificationDate__c from EmployeeCertification__c limit 10000];
        
        //custom setting 
        List<REVSYS_Custom_Settings__c> revCSList = REVSYS_Custom_Settings__c.getall().values();
        
        Map<String, String> params = new Map<String, String>();
        params.put('selectedEmployees', '[{\"theNumber\":\"5078\",\"theName\":\"Bob Supervisor\",\"testNames\":null,\"selected\":true,\"recordId\":\"003W000000ksCOwIAM\",\"fieldValues\":[\"Bob Supervisor\",\"5078\",\"mechanical\",\"test Craft1\",null,\"CA49\"],\"fieldNames\":[\"Name\",\"Personnel_ID__c\",\"Department\",\"Craft__c\",\"AdditionalCrafts__c\",\"CrewBase__c\"],\"department\":\"Mechanical\",\"craft\":\"Test Craft1\",\"additionalFieldandValueMap\":{}}]');
        
        Test.startTest();
        Map<String, String> returnVal = RevSys_ObservationController.loadTestSelection(params);
        Test.stopTest();
        
        system.assert(returnVal != null);
    }
    
    public static testMethod void testLoadTestSelectionCheckMethodNull(){
        
        //occupation requirement
        OccupationRequirement__c myOR1 = [select Id, RecordTypeId, TestNumber__c, TestName__c, Name, Status__c from OccupationRequirement__c limit 10000];
        myOR1.Check_Method_Required__c = null;
        update myOR1;
        
        //OccupationSpecificRequirement__c
        OccupationSpecificRequirement__c myOSR1 = [select Id, RecordTypeId, ObservationDepartment2__c, ObservationCraft2__c, Observation__c, Status__c from OccupationSpecificRequirement__c limit 10000];
        
        //contact list 
        List<Contact> myContactList = [select Id, LastName, FirstName, Personnel_Number__c, Email from Contact limit 10000];
        Contact contact1 = myContactList.get(0);
        
        //observations
        List<Observation__c> myObservationList = [select Id, RecordTypeId, Status__c, Date__c, Department__c, Employee__c, Number_of_Workers_Observed__c, OccupationSpecificRequirement__c from Observation__c limit 10000];
        Observation__c obs1 = myObservationList.get(0);
         
        //Finding__c
        list<Finding__c> findingList = [select Id, Score__c, Category__c, IsCriticalItem__c, Sequence__c, QuestionLastModifiedVersion__c, Sub_category__c from Finding__c limit 10000];
        
        //EmployeeCertification__c
        //EmployeeCertification__c ec1 = [select Id, Employee__c, LastCertificationDate__c from EmployeeCertification__c limit 10000];
        
        //custom setting 
        List<REVSYS_Custom_Settings__c> revCSList = REVSYS_Custom_Settings__c.getall().values();
        
        Map<String, String> params = new Map<String, String>();
        params.put('selectedEmployees', '[{\"theNumber\":\"5078\",\"theName\":\"Bob Supervisor\",\"testNames\":null,\"selected\":true,\"recordId\":\"003W000000ksCOwIAM\",\"fieldValues\":[\"Bob Supervisor\",\"5078\",\"mechanical\",\"test Craft1\",null,\"CA49\"],\"fieldNames\":[\"Name\",\"Personnel_ID__c\",\"Department\",\"Craft__c\",\"AdditionalCrafts__c\",\"CrewBase__c\"],\"department\":\"Mechanical\",\"craft\":\"Test Craft1\",\"additionalFieldandValueMap\":{}}]');
        
        Test.startTest();
        Map<String, String> returnVal = RevSys_ObservationController.loadTestSelection(params);
        Test.stopTest();
        
        system.assert(returnVal != null);
    }
    
    public static testMethod void testInsertForm1872(){
        
        //occupation requirement
        OccupationRequirement__c myOR1 = [select Id, RecordTypeId, TestNumber__c, TestName__c, Name, Status__c, Check_Method_Required__c, SpeedCheckMethod__c from OccupationRequirement__c limit 10000];
        
        //OccupationSpecificRequirement__c
        OccupationSpecificRequirement__c myOSR1 = [select Id, RecordTypeId, ObservationDepartment2__c, ObservationCraft2__c, Observation__c, Observation__r.TestNumber__c, Observation__r.SpeedCheckMethod__c, Observation__r.Check_Method_Required__c, Status__c from OccupationSpecificRequirement__c limit 10000];
        
        //position
        list<Position__c> positionListWithoutGeneratedReport = [select Id, Name, Job_Title__c, Position_ID__c, Cost_Center__c, Cost_Center_Name__c, Region__c, Generated_Reports_To_Position__c from Position__c where Generated_Reports_To_Position__c = null limit 10000];
        
		list<Position__c> positionList = [select Id, Name, Job_Title__c, Position_ID__c, Cost_Center__c, Cost_Center_Name__c, Region__c, Generated_Reports_To_Position__c from Position__c where Generated_Reports_To_Position__c != null limit 1];
        
        System.debug('positionList : ' + positionList);
        
        //contact list 
        List<Contact> myContactList = [select Id, LastName, FirstName, Personnel_Number__c, Email from Contact limit 10000];
        if(myContactList != null && myContactList.size() > 0){
            for(Contact c : myContactList){
                c.PositionLookup__c = positionList.get(0).Id;
            }
            update myContactList;
        }
        Contact contact1 = myContactList.get(0);
        Id contact1Id = contact1.Id;
        
        System.debug('myContactList : ' + JSON.serialize(myContactList));
        
        
        //observations
        List<Observation__c> myObservationList = [select Id, RecordTypeId, Status__c, Date__c, Department__c, Employee__c, Number_of_Workers_Observed__c, OccupationSpecificRequirement__c from Observation__c limit 10000];
        Observation__c obs1 = myObservationList.get(0);
         
        //Finding__c
        list<Finding__c> findingList = [select Id, Score__c, Category__c, IsCriticalItem__c, Sequence__c, QuestionLastModifiedVersion__c, Sub_category__c from Finding__c limit 10000];
        
        //EmployeeCertification__c
        //EmployeeCertification__c ec1 = [select Id, Employee__c, LastCertificationDate__c from EmployeeCertification__c limit 10000];
        
        //custom setting 
        List<REVSYS_Custom_Settings__c> revCSList = REVSYS_Custom_Settings__c.getall().values();
        
        //String testEntryJSON = '[{\"testNumber\":\"102\",\"speedCheckMethodList\":[\"Set-up Test\"],\"selected\":true,\"searchItem\":null,\"requiredFields\":{\"TimeMM__c\":true,\"TimeHH__c\":true,\"MpSg__c\":true,\"SpeedCheckMethod__c\":true,\"Result__c\":true,\"PersonallyObserved__c\":true,\"Date__c\":true,\"State__c\":false,\"RegionProperty__c\":true,\"RailroadRule__c\":true,\"Speed__c\":true},\"osr\":{\"attributes\":{\"type\":\"OccupationSpecificRequirement__c\",\"url\":\"/services/data/v42.0/sobjects/OccupationSpecificRequirement__c/a18W00000074AcGIAU\"},\"Id\":\"a18W00000074AcGIAU\",\"ObservationDepartment2__c\":\"Mechanical\",\"ObservationCraft2__c\":\"Test Craft1\",\"Observation__c\":\"a16W00000011RyRIAU\",\"Observation__r\":{\"attributes\":{\"type\":\"OccupationRequirement__c\",\"url\":\"/services/data/v42.0/sobjects/OccupationRequirement__c/a16W00000011RyRIAU\"},\"TestNumber__c\":\"102\",\"TestName__c\":\"Stop Signal\",\"SpeedCheckMethod__c\":\"Set-up Test\",\"Check_Method_Required__c\":\"Yes\",\"Id\":\"a16W00000011RyRIAU\"}},\"obs\":{\"attributes\":{\"type\":\"Observation__c\"},\"OccupationSpecificRequirement__c\":\"a18W00000074AcGIAU\",\"Employee__c\":\"'+contact1Id+'\",\"TimeHH__c\":\"15\",\"TimeMM__c\":\"15\",\"RailroadRule__c\":\"FR\",\"RegionProperty__c\":\"MetroLink\",\"State__c\":\"\",\"MpSg__c\":\"MP\",\"PersonalAreaCode__c\":\"\",\"SpeedCheckMethod__c\":\"Set-up Test\",\"Result__c\":\"C = Compliance\",\"PersonallyObserved__c\":\"Yes\",\"DiscussedWithEmployee__c\":\"\",\"SupervisorsCommentSelection__c\":\"\",\"Date__c\":\"2018-03-12\",\"MpSgNumber__c\":\"12\",\"Speed__c\":1,\"RecordTypeId\":\"012W00000004hSkIAI\"},\"findingList\":null,\"entryKey\":\"a18W00000074AcGIAU-003W000000ksCOwIAM\",\"employeeName\":\"Supervisor Amy\",\"employeeId\":\"5078\",\"empList\":null,\"display\":null,\"department\":\"mechanical\",\"craft\":\"test Craft1\",\"completed\":true,\"checkMethodReq\":true}]';
        //String testEntryJSON = '[{\"testNumber\":\"102\",\"speedCheckMethodList\":[\"Set-up Test\"],\"selected\":true,\"searchItem\":null,\"requiredFields\":{\"TimeMM__c\":true,\"TimeHH__c\":true,\"MpSg__c\":true,\"SpeedCheckMethod__c\":true,\"Result__c\":true,\"PersonallyObserved__c\":true,\"Date__c\":true,\"State__c\":false,\"RegionProperty__c\":true,\"RailroadRule__c\":true,\"Speed__c\":true},\"osr\":{\"attributes\":{\"type\":\"OccupationSpecificRequirement__c\",\"url\":\"/services/data/v42.0/sobjects/OccupationSpecificRequirement__c/'+myOSR1.Id+'\"},\"Id\":\"'+myOSR1.Id+'\",\"ObservationDepartment2__c\":\"Mechanical\",\"ObservationCraft2__c\":\"Test Craft1\",\"Observation__c\":\"a16W00000011RyRIAU\",\"Observation__r\":{\"attributes\":{\"type\":\"OccupationRequirement__c\",\"url\":\"/services/data/v42.0/sobjects/OccupationRequirement__c/a16W00000011RyRIAU\"},\"TestNumber__c\":\"102\",\"TestName__c\":\"Stop Signal\",\"SpeedCheckMethod__c\":\"Set-up Test\",\"Check_Method_Required__c\":\"Yes\",\"Id\":\"a16W00000011RyRIAU\"}},\"obs\":{\"attributes\":{\"type\":\"Observation__c\"},\"OccupationSpecificRequirement__c\":\"a18W00000074AcGIAU\",\"Employee__c\":\"'+contact1Id+'\",\"TimeHH__c\":\"15\",\"TimeMM__c\":\"15\",\"RailroadRule__c\":\"FR\",\"RegionProperty__c\":\"MetroLink\",\"State__c\":\"\",\"MpSg__c\":\"MP\",\"PersonalAreaCode__c\":\"\",\"SpeedCheckMethod__c\":\"Set-up Test\",\"Result__c\":\"C = Compliance\",\"PersonallyObserved__c\":\"Yes\",\"DiscussedWithEmployee__c\":\"\",\"SupervisorsCommentSelection__c\":\"\",\"Date__c\":\"2018-03-12\",\"MpSgNumber__c\":\"12\",\"Speed__c\":1,\"RecordTypeId\":\"'+RevSys_StaticUtility.OBSERVATION_TEST1872_RECTYPE_ID+'\"},\"findingList\":null,\"entryKey\":\"a18W00000074AcGIAU-003W000000ksCOwIAM\",\"employeeName\":\"Supervisor Amy\",\"employeeId\":\"5078\",\"empList\":null,\"display\":null,\"department\":\"mechanical\",\"craft\":\"test Craft1\",\"completed\":true,\"checkMethodReq\":true}]';
        String testEntryJSON = '[{\"testNumber\":\"102\",\"speedCheckMethodList\":[\"Set-up Test\"],\"selected\":true,\"searchItem\":null,\"requiredFields\":{\"TimeMM__c\":true,\"TimeHH__c\":true,\"MpSg__c\":true,\"SpeedCheckMethod__c\":true,\"Result__c\":true,\"PersonallyObserved__c\":true,\"Date__c\":true,\"State__c\":false,\"RegionProperty__c\":true,\"RailroadRule__c\":true,\"Speed__c\":true},\"osr\":{\"attributes\":{\"type\":\"OccupationSpecificRequirement__c\",\"url\":\"/services/data/v42.0/sobjects/OccupationSpecificRequirement__c/'+myOSR1.Id+'\"},\"Id\":\"'+myOSR1.Id+'\",\"ObservationDepartment2__c\":\"Mechanical\",\"ObservationCraft2__c\":\"Test Craft1\",\"Observation__c\":\"a16W00000011RyRIAU\",\"Observation__r\":{\"attributes\":{\"type\":\"OccupationRequirement__c\",\"url\":\"/services/data/v42.0/sobjects/OccupationRequirement__c/a16W00000011RyRIAU\"},\"TestNumber__c\":\"102\",\"TestName__c\":\"Stop Signal\",\"SpeedCheckMethod__c\":\"Set-up Test\",\"Check_Method_Required__c\":\"Yes\",\"Id\":\"a16W00000011RyRIAU\"}},\"obs\":{\"attributes\":{\"type\":\"Observation__c\"},\"OccupationSpecificRequirement__c\":\"'+myOSR1.Id+'\",\"Employee__c\":\"'+contact1Id+'\",\"TimeHH__c\":\"15\",\"TimeMM__c\":\"15\",\"RailroadRule__c\":\"FR\",\"FormType__c\":\"Form-1872\",\"RegionProperty__c\":\"Central\",\"State__c\":\"\",\"MpSg__c\":\"MP\",\"PersonalAreaCode__c\":\"\",\"SpeedCheckMethod__c\":\"Set-up Test\",\"Result__c\":\"C = Compliance\",\"PersonallyObserved__c\":\"Yes\",\"DiscussedWithEmployee__c\":\"\",\"SupervisorsCommentSelection__c\":\"\",\"Date__c\":\"2018-03-12\",\"MpSgNumber__c\":\"12\",\"Speed__c\":1,\"RecordTypeId\":\"'+RevSys_StaticUtility.OBSERVATION_TEST1872_RECTYPE_ID+'\"},\"findingList\":null,\"entryKey\":\"'+myOSR1.Id+'-'+contact1Id+'\",\"employeeName\":\"Supervisor Amy\",\"employeeId\":\"5078\",\"empList\":null,\"display\":null,\"department\":\"mechanical\",\"craft\":\"test Craft1\",\"completed\":true,\"checkMethodReq\":true}]';
        System.debug('*** testEntryJSON : ' + testEntryJSON);
        
        Map<String, String> params = new Map<String, String>();
        params.put('testEntryJSON', testEntryJSON);
        
        Test.startTest();
        Map<String, String> returnVal = RevSys_ObservationController.insertForm1872(params);
        RevSys_TestEntryWrapper revTestWrap = new RevSys_TestEntryWrapper();
        
        RevSys_TestEntryWrapper revTestWrap1 = new RevSys_TestEntryWrapper(myOSR1, obs1);
        
        Test.stopTest();
        
        system.assert(returnVal != null);
    }
    
    public static testMethod void testRevSys_TestEntryWrapperWIthCheckMethodYes(){
        //occupation requirement
        OccupationRequirement__c myOR1 = [select Id, RecordTypeId, TestNumber__c, TestName__c, Name, Status__c, Check_Method_Required__c, SpeedCheckMethod__c from OccupationRequirement__c limit 10000];
        myOR1.Check_Method_Required__c = 'Yes - Not Required';
        update myOR1;
        
        //OccupationSpecificRequirement__c
        OccupationSpecificRequirement__c myOSR1 = [select Id, RecordTypeId, ObservationDepartment2__c, ObservationCraft2__c, Observation__c, Observation__r.TestNumber__c, Observation__r.SpeedCheckMethod__c, Observation__r.Check_Method_Required__c, Status__c from OccupationSpecificRequirement__c limit 10000];
        
        //observations
        List<Observation__c> myObservationList = [select Id, RecordTypeId, Status__c, Date__c, Department__c, Employee__c, Number_of_Workers_Observed__c, OccupationSpecificRequirement__c from Observation__c limit 10000];
        Observation__c obs1 = myObservationList.get(0);
        
        list<Position__c> positionList = [select Id, Name, Job_Title__c, Position_ID__c, Cost_Center__c, Cost_Center_Name__c, Region__c, Generated_Reports_To_Position__c from Position__c where Generated_Reports_To_Position__c != null limit 1];
        
        //contacts
        List<Contact> myContactList = [select Id, LastName, FirstName, Personnel_Number__c, Email from Contact limit 10000];
        if(myContactList != null && myContactList.size() > 0){
            for(Contact c : myContactList){
                c.PositionLookup__c = positionList.get(0).Id;
            }
            update myContactList;
        }
        Contact contact1 = myContactList.get(0);
        Id contact1Id = contact1.Id;
        
        String employeeInfo = contact1Id+','+myOSR1.ObservationDepartment2__c+','+myOSR1.ObservationCraft2__c;
        
        Test.startTest();
        RevSys_TestEntryWrapper revTestWrap1 = new RevSys_TestEntryWrapper(myOSR1, obs1, contact1.Name, employeeInfo);
        Test.stopTest();
    }
    
    public static testMethod void testRevSys_TestEntryWrapperWIthCheckMethodNo(){
        //occupation requirement
        OccupationRequirement__c myOR1 = [select Id, RecordTypeId, TestNumber__c, TestName__c, Name, Status__c, Check_Method_Required__c, SpeedCheckMethod__c from OccupationRequirement__c limit 10000];
        myOR1.Check_Method_Required__c = 'No';
        update myOR1;
        
        //OccupationSpecificRequirement__c
        OccupationSpecificRequirement__c myOSR1 = [select Id, RecordTypeId, ObservationDepartment2__c, ObservationCraft2__c, Observation__c, Observation__r.TestNumber__c, Observation__r.SpeedCheckMethod__c, Observation__r.Check_Method_Required__c, Status__c from OccupationSpecificRequirement__c limit 10000];
        
        //observations
        List<Observation__c> myObservationList = [select Id, RecordTypeId, Status__c, Date__c, Department__c, Employee__c, Number_of_Workers_Observed__c, OccupationSpecificRequirement__c from Observation__c limit 10000];
        Observation__c obs1 = myObservationList.get(0);
        
        
        Test.startTest();
        RevSys_TestEntryWrapper revTestWrap1 = new RevSys_TestEntryWrapper(myOSR1, obs1);
        Test.stopTest();
    }
    
    public static testMethod void testRevSys_TestEntryWrapperWIthCheckMethodNull(){
        //occupation requirement
        OccupationRequirement__c myOR1 = [select Id, RecordTypeId, TestNumber__c, TestName__c, Name, Status__c, Check_Method_Required__c, SpeedCheckMethod__c from OccupationRequirement__c limit 10000];
        myOR1.Check_Method_Required__c = null;
        update myOR1;
        
        //OccupationSpecificRequirement__c
        OccupationSpecificRequirement__c myOSR1 = [select Id, RecordTypeId, ObservationDepartment2__c, ObservationCraft2__c, Observation__c, Observation__r.TestNumber__c, Observation__r.SpeedCheckMethod__c, Observation__r.Check_Method_Required__c, Status__c from OccupationSpecificRequirement__c limit 10000];
        
        //observations
        List<Observation__c> myObservationList = [select Id, RecordTypeId, Status__c, Date__c, Department__c, Employee__c, Number_of_Workers_Observed__c, OccupationSpecificRequirement__c from Observation__c limit 10000];
        Observation__c obs1 = myObservationList.get(0);
        
        
        Test.startTest();
        RevSys_TestEntryWrapper revTestWrap1 = new RevSys_TestEntryWrapper(myOSR1, obs1);
        Test.stopTest();
    }
    
    public static testMethod void testGetObservationCheckMethodReqNo(){
        OccupationRequirement__c myOR1 = [select Id, RecordTypeId, TestNumber__c, TestName__c, Name, Status__c, Check_Method_Required__c, SpeedCheckMethod__c from OccupationRequirement__c limit 10000];
        myOR1.Check_Method_Required__c = 'No';
        update myOR1;
        
        //OccupationSpecificRequirement__c
        OccupationSpecificRequirement__c myOSR1 = [select Id, RecordTypeId, ObservationDepartment2__c, ObservationCraft2__c, Observation__c, Observation__r.TestNumber__c, Observation__r.SpeedCheckMethod__c, Observation__r.Check_Method_Required__c, Status__c from OccupationSpecificRequirement__c limit 10000];
        
        Test.startTest();
        Map<String, Boolean> returnVal = RevSys_ObservationController.getObservationCheckMethodReq(myOSR1.Id);
        Test.stopTest();
        
        system.assert(returnVal != null);
        
    }
    
    public static testMethod void testGetObservationCheckMethodReqYesReq(){
        OccupationRequirement__c myOR1 = [select Id, RecordTypeId, TestNumber__c, TestName__c, Name, Status__c, Check_Method_Required__c, SpeedCheckMethod__c from OccupationRequirement__c limit 10000];
        myOR1.Check_Method_Required__c = 'Yes - Required';
        update myOR1;
        
        //OccupationSpecificRequirement__c
        OccupationSpecificRequirement__c myOSR1 = [select Id, RecordTypeId, ObservationDepartment2__c, ObservationCraft2__c, Observation__c, Observation__r.TestNumber__c, Observation__r.SpeedCheckMethod__c, Observation__r.Check_Method_Required__c, Status__c from OccupationSpecificRequirement__c limit 10000];
        
        Test.startTest();
        Map<String, Boolean> returnVal = RevSys_ObservationController.getObservationCheckMethodReq(myOSR1.Id);
        Test.stopTest();
        
        system.assert(returnVal != null);
    }
    
    public static testMethod void testGetObservationCheckMethodReqYesNotReq(){
        OccupationRequirement__c myOR1 = [select Id, RecordTypeId, TestNumber__c, TestName__c, Name, Status__c, Check_Method_Required__c, SpeedCheckMethod__c from OccupationRequirement__c limit 10000];
        myOR1.Check_Method_Required__c = 'Yes - Not Required';
        update myOR1;
        
        //OccupationSpecificRequirement__c
        OccupationSpecificRequirement__c myOSR1 = [select Id, RecordTypeId, ObservationDepartment2__c, ObservationCraft2__c, Observation__c, Observation__r.TestNumber__c, Observation__r.SpeedCheckMethod__c, Observation__r.Check_Method_Required__c, Status__c from OccupationSpecificRequirement__c limit 10000];
        
        Test.startTest();
        Map<String, Boolean> returnVal = RevSys_ObservationController.getObservationCheckMethodReq(myOSR1.Id);
        Test.stopTest();
        
        system.assert(returnVal != null);
    }
    
    public static testMethod void testGetObservationCheckMethodReqNull(){
        OccupationRequirement__c myOR1 = [select Id, RecordTypeId, TestNumber__c, TestName__c, Name, Status__c, Check_Method_Required__c, SpeedCheckMethod__c from OccupationRequirement__c limit 10000];
        myOR1.Check_Method_Required__c = null;
        update myOR1;
        
        //OccupationSpecificRequirement__c
        OccupationSpecificRequirement__c myOSR1 = [select Id, RecordTypeId, ObservationDepartment2__c, ObservationCraft2__c, Observation__c, Observation__r.TestNumber__c, Observation__r.SpeedCheckMethod__c, Observation__r.Check_Method_Required__c, Status__c from OccupationSpecificRequirement__c limit 10000];
        
        Test.startTest();
        Map<String, Boolean> returnVal = RevSys_ObservationController.getObservationCheckMethodReq(myOSR1.Id);
        Test.stopTest();
        
        system.assert(returnVal != null);
    }
    
    public static testMethod void testInitPageRecordDetailExep() {
        
        //occupation requirement
        OccupationRequirement__c myOR1 = [select Id, RecordTypeId, TestNumber__c, TestName__c, Name, Status__c from OccupationRequirement__c limit 10000];
        
        Map<String, String> params = new Map<String, String>();
        params.put('targetPage', 'recordDetail');
        params.put('obsId', myOR1.Id);
        
        Test.startTest();
        Map<String, String> initReturn = RevSys_ObservationController.initPage(params);
        Test.stopTest();
        
        system.assert(initReturn != null);
    }
    
    public static testMethod void testInitPageRecordDetailExepOnTargetPage() {
        
        //occupation requirement
        OccupationRequirement__c myOR1 = [select Id, RecordTypeId, TestNumber__c, TestName__c, Name, Status__c from OccupationRequirement__c limit 10000];
        
        //Map<String, String> params = new Map<String, String>();
        Map<String, String> params = null; 
        //params.put('targetPage', 'recordDetail');
        //params.put('obsId', myOR1.Id);
        
        Test.startTest();
        Map<String, String> initReturn = RevSys_ObservationController.initPage(params);
        Test.stopTest();
        
        system.assert(initReturn != null);
    }
    
    public static testMethod void testInsertNon1872_1876Exep(){
        
        //occupation requirement
        OccupationRequirement__c myOR1 = [select Id, RecordTypeId, TestNumber__c, TestName__c, Name, Status__c from OccupationRequirement__c limit 10000];
        
        //OccupationSpecificRequirement__c
        OccupationSpecificRequirement__c myOSR1 = [select Id, RecordTypeId, ObservationDepartment2__c, ObservationCraft2__c, Observation__c, Status__c from OccupationSpecificRequirement__c limit 10000];
        
        //contact list 
        List<Contact> myContactList = [select Id, LastName, FirstName, Personnel_Number__c, Email from Contact limit 10000];
        Contact contact1 = myContactList.get(0);
        
        //observations
        List<Observation__c> myObservationList = [select Id, RecordTypeId, Status__c, Date__c, Department__c, Employee__c, Number_of_Workers_Observed__c, OccupationSpecificRequirement__c from Observation__c limit 10000];
         
        //Finding__c
        list<Finding__c> findingList = [select Id, Score__c, Category__c, IsCriticalItem__c, Sequence__c, QuestionLastModifiedVersion__c, Sub_category__c from Finding__c limit 10000];
        
        //EmployeeCertification__c
        //EmployeeCertification__c ec1 = [select Id, Employee__c, LastCertificationDate__c from EmployeeCertification__c limit 10000];
        
        //custom setting 
        List<REVSYS_Custom_Settings__c> revCSList = REVSYS_Custom_Settings__c.getall().values();
        
        Map<String, String> params = new Map<String, String>();
        params.put('observationJSON', '{\"attributes\":{\"type\":\"Observation__c\"},\"RecordTypeId\":\"'+RevSys_StaticUtility.OBSERVATION_TEST1876_RECTYPE_ID+'\",\"Employee__c\":\"'+contact1.Id+'\"}');
        params.put('rtName', 'Form-1899');
        
        Test.startTest();
        Map<String, String> returnVal = RevSys_ObservationController.insertNon1872(params);
        Test.stopTest();
        
        system.assert(returnVal != null);
        
    }
    
    public static testMethod void testInsertNon1872_1876DMLExep(){
        
        //occupation requirement
        OccupationRequirement__c myOR1 = [select Id, RecordTypeId, TestNumber__c, TestName__c, Name, Status__c from OccupationRequirement__c limit 10000];
        
        //OccupationSpecificRequirement__c
        OccupationSpecificRequirement__c myOSR1 = [select Id, RecordTypeId, ObservationDepartment2__c, ObservationCraft2__c, Observation__c, Status__c from OccupationSpecificRequirement__c limit 10000];
        
        //contact list 
        List<Contact> myContactList = [select Id, LastName, FirstName, Personnel_Number__c, Email from Contact limit 10000];
        Contact contact1 = myContactList.get(0);
        
        //observations
        List<Observation__c> myObservationList = [select Id, RecordTypeId, Status__c, Date__c, Department__c, Employee__c, Number_of_Workers_Observed__c, OccupationSpecificRequirement__c from Observation__c limit 10000];
         
        //Finding__c
        list<Finding__c> findingList = [select Id, Score__c, Category__c, IsCriticalItem__c, Sequence__c, QuestionLastModifiedVersion__c, Sub_category__c from Finding__c limit 10000];
        
        //EmployeeCertification__c
        //EmployeeCertification__c ec1 = [select Id, Employee__c, LastCertificationDate__c from EmployeeCertification__c limit 10000];
        
        //custom setting 
        List<REVSYS_Custom_Settings__c> revCSList = REVSYS_Custom_Settings__c.getall().values();
        
        Map<String, String> params = new Map<String, String>();
        params.put('observationJSON', '{\"attributes\":{\"type\":\"Observation__c\"},\"RecordTypeId\":\"'+RevSys_StaticUtility.OBSERVATION_TEST1876_RECTYPE_ID+'\",\"Employee__c\":\"'+myOSR1.Id+'\"}');
        params.put('rtName', 'Form-1899');
        
        Test.startTest();
        Map<String, String> returnVal = RevSys_ObservationController.insertNon1872(params);
        Test.stopTest();
        
        system.assert(returnVal != null);
    }
    
    public static testMethod void testUpdateObservationDMLExep(){
        
        //occupation requirement
        OccupationRequirement__c myOR1 = [select Id, RecordTypeId, TestNumber__c, TestName__c, Name, Status__c from OccupationRequirement__c limit 10000];
        
        //OccupationSpecificRequirement__c
        OccupationSpecificRequirement__c myOSR1 = [select Id, RecordTypeId, ObservationDepartment2__c, ObservationCraft2__c, Observation__c, Status__c from OccupationSpecificRequirement__c limit 10000];
        
        //contact list 
        List<Contact> myContactList = [select Id, LastName, FirstName, Personnel_Number__c, Email from Contact limit 10000];
        Contact contact1 = myContactList.get(0);
        
        //observations
        List<Observation__c> myObservationList = [select Id, RecordTypeId, Status__c, Date__c, Department__c, Employee__c, Number_of_Workers_Observed__c, OccupationSpecificRequirement__c from Observation__c limit 10000];
        Observation__c obs1 = myObservationList.get(0);
         
        //Finding__c
        list<Finding__c> findingList = [select Id, Score__c, Category__c, IsCriticalItem__c, Sequence__c, QuestionLastModifiedVersion__c, Sub_category__c from Finding__c limit 10000];
        Id findingId = findingList.get(0).Id;
        
        //EmployeeCertification__c
        //EmployeeCertification__c ec1 = [select Id, Employee__c, LastCertificationDate__c from EmployeeCertification__c limit 10000];
        
        //custom setting 
        List<REVSYS_Custom_Settings__c> revCSList = REVSYS_Custom_Settings__c.getall().values();
        
        Map<String, String> params = new Map<String, String>();
        params.put('observationJSON', '{\"attributes\":{\"type\":\"Observation__c\",\"url\":\"/services/data/v42.0/sobjects/Observation__c/'+myOR1.Id+'\"},\"Employee__c\":\"'+contact1.Id+'\",\"OjtStartDate__c\":\"2018-03-06\",\"RecordTypeId\":\"'+RevSys_StaticUtility.OBSERVATION_TEST1876_RECTYPE_ID+'\",\"Id\":\"'+myOR1.Id+'\",\"TimeHH__c\":\"\",\"TimeMM__c\":\"\",\"ObservationMethod__c\":\"Actual Ride\",\"Date__c\":\"2018-03-16\",\"OperatedFromText__c\":\"test\",\"OperatedToText__c\":\"test\",\"NeedsImprovement__c\":\"test\"}');
        params.put('rtName', 'Form-1878');
        params.put('findingListJSON', '[{\"attributes\":{\"type\":\"Finding__c\",\"url\":\"/services/data/v42.0/sobjects/Finding__c/'+myOR1.Id+'\"},\"RecordTypeId\":\"'+RevSys_StaticUtility.FINDING_REVIEW_SYSTEMS_RECTYPE_ID+'\",\"Category__c\":\"Form-1876\",\"Sub_category__c\":\"Wayside Signals\",\"Sequence__c\":150,\"Score__c\":\"2\",\"IsCriticalItem__c\":true,\"Observation__c\":\"'+obs1.Id+'\",\"Id\":\"'+findingId+'\"}]');
        //params.put('findingListJSON', '[{\"attributes\":{\"type\":\"Finding__c\",\"url\":\"/services/data/v42.0/sobjects/Finding__c/a03W00000053160IAA\"},\"RecordTypeId\":\"012W00000004hDQIAY\",\"Category__c\":\"Form-1876\",\"Sub_category__c\":\"Wayside Signals\",\"Sequence__c\":150,\"Score__c\":\"2\",\"IsCriticalItem__c\":true,\"Observation__c\":\"a05W0000006B3A4IAK\",\"Id\":\"a03W00000053160IAA\"},{\"attributes\":{\"type\":\"Finding__c\",\"url\":\"/services/data/v42.0/sobjects/Finding__c/a03W00000053161IAA\"},\"RecordTypeId\":\"012W00000004hDQIAY\",\"Category__c\":\"Form-1876\",\"Sub_category__c\":\"Cab Signals\",\"Sequence__c\":160,\"Score__c\":\"1\",\"IsCriticalItem__c\":false,\"Observation__c\":\"a05W0000006B3A4IAK\",\"Id\":\"a03W00000053161IAA\"}]');
        
        Test.startTest();
        Map<String, String> returnVal = RevSys_ObservationController.updateObservation(params);
        Test.stopTest();
        
        system.assert(returnVal != null);
    }
    
    public static testMethod void testUpdateObservationExep(){
        Map<String, String> params = null;
        
        Test.startTest();
        Map<String, String> returnVal = RevSys_ObservationController.updateObservation(params);
        Test.stopTest(); 
        
        system.assert(returnVal != null);
    }
    
    public static testMethod void testSaveObservationExep(){
        Map<String, String> params = null;
        //params.put('observationJSON', '{\"attributes\":{\"type\":\"Observation__c\",\"url\":\"/services/data/v42.0/sobjects/Observation__c/'+obs1.Id+'\"},\"Employee__c\":\"'+contact1.Id+'\",\"OjtStartDate__c\":\"2018-03-06\",\"RecordTypeId\":\"'+RevSys_StaticUtility.OBSERVATION_TEST1876_RECTYPE_ID+'\",\"Id\":\"'+obs1.Id+'\",\"TimeHH__c\":\"\",\"TimeMM__c\":\"\",\"ObservationMethod__c\":\"Actual Ride\",\"Date__c\":\"2018-03-16\",\"OperatedFromText__c\":\"test\",\"OperatedToText__c\":\"test\",\"NeedsImprovement__c\":\"test\"}');
        //params.put('rtName', 'Form-1876');
        
        Test.startTest();
        Map<String, String> returnVal = RevSys_ObservationController.saveObservation(params);
        Test.stopTest();
        
        system.assert(returnVal != null);
    }
    
    public static testMethod void testSaveObservationDMLExep(){
        
        //occupation requirement
        OccupationRequirement__c myOR1 = [select Id, RecordTypeId, TestNumber__c, TestName__c, Name, Status__c from OccupationRequirement__c limit 10000];
        
        //OccupationSpecificRequirement__c
        OccupationSpecificRequirement__c myOSR1 = [select Id, RecordTypeId, ObservationDepartment2__c, ObservationCraft2__c, Observation__c, Status__c from OccupationSpecificRequirement__c limit 10000];
        
        //contact list 
        List<Contact> myContactList = [select Id, LastName, FirstName, Personnel_Number__c, Email from Contact limit 10000];
        Contact contact1 = myContactList.get(0);
        
        //observations
        List<Observation__c> myObservationList = [select Id, RecordTypeId, Status__c, Date__c, Department__c, Employee__c, Number_of_Workers_Observed__c, OccupationSpecificRequirement__c from Observation__c limit 10000];
        Observation__c obs1 = myObservationList.get(0);
         
        //Finding__c
        list<Finding__c> findingList = [select Id, Score__c, Category__c, IsCriticalItem__c, Sequence__c, QuestionLastModifiedVersion__c, Sub_category__c from Finding__c limit 10000];
        
        //EmployeeCertification__c
        //EmployeeCertification__c ec1 = [select Id, Employee__c, LastCertificationDate__c from EmployeeCertification__c limit 10000];
        
        //custom setting 
        List<REVSYS_Custom_Settings__c> revCSList = REVSYS_Custom_Settings__c.getall().values();
        
        Map<String, String> params = new Map<String, String>();
        params.put('observationJSON', '{\"attributes\":{\"type\":\"Observation__c\",\"url\":\"/services/data/v42.0/sobjects/Observation__c/'+myOSR1.Id+'\"},\"Employee__c\":\"'+contact1.Id+'\",\"OjtStartDate__c\":\"2018-03-06\",\"RecordTypeId\":\"'+RevSys_StaticUtility.OBSERVATION_TEST1876_RECTYPE_ID+'\",\"Id\":\"'+myOSR1.Id+'\",\"TimeHH__c\":\"\",\"TimeMM__c\":\"\",\"ObservationMethod__c\":\"Actual Ride\",\"Date__c\":\"2018-03-16\",\"OperatedFromText__c\":\"test\",\"OperatedToText__c\":\"test\",\"NeedsImprovement__c\":\"test\"}');
        params.put('rtName', 'Form-1876');
        
        Test.startTest();
        Map<String, String> returnVal = RevSys_ObservationController.saveObservation(params);
        Test.stopTest();
        
        system.assert(returnVal != null);
    }
    
    public static testMethod void testSearchForEmployeeExep(){
        
        Map<String, String> params = null;
        
        Test.startTest();
        Map<String, String> returnVal = RevSys_ObservationController.searchForEmployee(params);
        Test.stopTest();
        
        system.assert(returnVal != null);
    }
    
    public static testMethod void testLoadTestSelectionExep(){
        Map<String, String> params = null;
        
        Test.startTest();
        Map<String, String> returnVal = RevSys_ObservationController.loadTestSelection(params);
        Test.stopTest();
        
        system.assert(returnVal != null);
    }
    
    public static testMethod void testInsertForm1872DMLExep(){
        
        //occupation requirement
        OccupationRequirement__c myOR1 = [select Id, RecordTypeId, TestNumber__c, TestName__c, Name, Status__c, Check_Method_Required__c, SpeedCheckMethod__c from OccupationRequirement__c limit 10000];
        
        //OccupationSpecificRequirement__c
        OccupationSpecificRequirement__c myOSR1 = [select Id, RecordTypeId, ObservationDepartment2__c, ObservationCraft2__c, Observation__c, Observation__r.TestNumber__c, Observation__r.SpeedCheckMethod__c, Observation__r.Check_Method_Required__c, Status__c from OccupationSpecificRequirement__c limit 10000];
        
        //position
        list<Position__c> positionListWithoutGeneratedReport = [select Id, Name, Job_Title__c, Position_ID__c, Cost_Center__c, Cost_Center_Name__c, Region__c, Generated_Reports_To_Position__c from Position__c where Generated_Reports_To_Position__c = null limit 10000];
        
		list<Position__c> positionList = [select Id, Name, Job_Title__c, Position_ID__c, Cost_Center__c, Cost_Center_Name__c, Region__c, Generated_Reports_To_Position__c from Position__c where Generated_Reports_To_Position__c != null limit 1];
        
        System.debug('positionList : ' + positionList);
        
        //contact list 
        List<Contact> myContactList = [select Id, LastName, FirstName, Personnel_Number__c, Email from Contact limit 10000];
        if(myContactList != null && myContactList.size() > 0){
            for(Contact c : myContactList){
                c.PositionLookup__c = positionList.get(0).Id;
            }
            update myContactList;
        }
        Contact contact1 = myContactList.get(0);
        Id contact1Id = contact1.Id;
        
        System.debug('myContactList : ' + JSON.serialize(myContactList));
        
        
        //observations
        List<Observation__c> myObservationList = [select Id, RecordTypeId, Status__c, Date__c, Department__c, Employee__c, Number_of_Workers_Observed__c, OccupationSpecificRequirement__c from Observation__c limit 10000];
        Observation__c obs1 = myObservationList.get(0);
         
        //Finding__c
        list<Finding__c> findingList = [select Id, Score__c, Category__c, IsCriticalItem__c, Sequence__c, QuestionLastModifiedVersion__c, Sub_category__c from Finding__c limit 10000];
        
        //EmployeeCertification__c
        //EmployeeCertification__c ec1 = [select Id, Employee__c, LastCertificationDate__c from EmployeeCertification__c limit 10000];
        
        //custom setting 
        List<REVSYS_Custom_Settings__c> revCSList = REVSYS_Custom_Settings__c.getall().values();
        
        String testEntryJSON = '[{"testNumber":"102","speedCheckMethodList":["Set-up Test"],"selected":true,"searchItem":null,"requiredFields":{"TimeMM__c":true,"TimeHH__c":true,"MpSg__c":true,"SpeedCheckMethod__c":true,"Result__c":true,"PersonallyObserved__c":true,"Date__c":true,"State__c":false,"RegionProperty__c":true,"RailroadRule__c":true,"Speed__c":true},"osr":{"attributes":{"type":"OccupationSpecificRequirement__c","url":"/services/data/v42.0/sobjects/OccupationSpecificRequirement__c/'+contact1Id+'"},"Id":"'+contact1Id+'","ObservationDepartment2__c":"Mechanical","ObservationCraft2__c":"Test Craft1","Observation__c":"a16W00000011RyRIAU","Observation__r":{"attributes":{"type":"OccupationRequirement__c","url":"/services/data/v42.0/sobjects/OccupationRequirement__c/a16W00000011RyRIAU"},"TestNumber__c":"102","TestName__c":"Stop Signal","SpeedCheckMethod__c":"Set-up Test","Check_Method_Required__c":"Yes","Id":"a16W00000011RyRIAU"}},"obs":{"attributes":{"type":"Observation__c"},"OccupationSpecificRequirement__c":"'+myOSR1.Id+'","Employee__c":"'+obs1.Id+'","TimeHH__c":"15","TimeMM__c":"15","RailroadRule__c":"FR","FormType__c":"Form-1872","RegionProperty__c":"Central","State__c":"","MpSg__c":"MP","PersonalAreaCode__c":"","SpeedCheckMethod__c":"Set-up Test","Result__c":"C = Compliance","PersonallyObserved__c":"Yes","DiscussedWithEmployee__c":"","SupervisorsCommentSelection__c":"","Date__c":"2018-03-12","MpSgNumber__c":"12","Speed__c":1,"RecordTypeId":"'+RevSys_StaticUtility.OBSERVATION_TEST1872_RECTYPE_ID+'"},"findingList":null,"entryKey":"'+myOSR1.Id+'-'+obs1.Id+'","employeeName":"Supervisor Amy","employeeId":"5078","empList":null,"display":null,"department":"mechanical","craft":"test Craft1","completed":true,"checkMethodReq":true}]';
        System.debug('*** testEntryJSON : ' + testEntryJSON);
        
        Map<String, String> params = new Map<String, String>();
        params.put('testEntryJSON', testEntryJSON);
        
        Test.startTest();
        Map<String, String> returnVal = RevSys_ObservationController.insertForm1872(params);
        Test.stopTest();
        
        system.assert(returnVal != null);
    }
    
    public static testMethod void testInsertForm1872Exep(){
        
        Map<String, String> params = null;
        
        Test.startTest();
        Map<String, String> returnVal = RevSys_ObservationController.insertForm1872(params);
        Test.stopTest();
        
        system.assert(returnVal != null);
    }
    
}
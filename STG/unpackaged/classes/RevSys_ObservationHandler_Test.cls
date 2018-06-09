/**
*___________________________________________________
*@Name:     RevSys_ObservationHandler_Test
*@Author:   Chuck Walley
*@Created:  Date: 11/12/2017
*@Used_By:  Review Systems
*___________________________________________________
*@Description: Test for RevSys_ObservationHandler
* 
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/
@isTest(SeeAllData=false)

public class RevSys_ObservationHandler_Test {   
    /**
    *————————————————————————————————————————————————————
    * @Name: testEntireClass
    * @Description  One long method to build data needed for 
    *               Review System test classes 
    *————————————————————————————————————————————————————
    * @param    null Nothing
    * @return   void Nothing
    *————————————————————————————————————————————————————
    **/ 
    public static testMethod void testEntireClass() 
    {
        system.debug('TEST RevSys_ObservationHandler_Test testEntireClass-Start');     
        
        RevSys_TestDataHelper.buildTestData();

        List<Contact> myEmployeeList = new List<Contact> 
        ( 
            [SELECT Id, Name, Email, Personnel_Number__c
             FROM   Contact ]
        );

        Map<String,Contact> myContactMap = new Map<String,Contact>(); 

        for(Contact myEmployee :myEmployeeList)
        {
            myContactMap.put(myEmployee.Email,myEmployee); 
        }

        Contact myEmployee = myContactMap.get('abigale.employee@amtrak.com'); 

        system.assertNotEquals(null,myEmployee); 

        Test.startTest(); 

            List<Observation__c> myObservationList = new List<Observation__c>(); 

            Observation__c obs1 = new Observation__c
            ( 
                RecordTypeId                    = RevSys_StaticUtility.OBSERVATION_TEST1875_RECTYPE_ID,
                Date__c                         = Date.today(), 
                Department__c                   = 'Engineering ET',
                Employee__c                     = myEmployee.Id,
                Number_of_Workers_Observed__c = 1
            );
            myObservationList.add(obs1);

            Observation__c obs2 = new Observation__c
            ( 
                RecordTypeId                    = RevSys_StaticUtility.OBSERVATION_TEST1876_RECTYPE_ID,
                Date__c                         = Date.today(), 
                Department__c                   = 'Engineering ET',
                Employee__c                     = myEmployee.Id,
                Number_of_Workers_Observed__c = 1
            );
            myObservationList.add(obs2);

            Observation__c obs3 = new Observation__c
            ( 
                RecordTypeId                    = RevSys_StaticUtility.OBSERVATION_TEST1877_RECTYPE_ID,
                Date__c                         = Date.today(), 
                Department__c                   = 'Engineering ET',
                Employee__c                     = myEmployee.Id,
                Number_of_Workers_Observed__c = 1
            );
            myObservationList.add(obs3);

            Observation__c obs4 = new Observation__c
            ( 
                RecordTypeId                    = RevSys_StaticUtility.OBSERVATION_TEST1878_RECTYPE_ID,
                Date__c                         = Date.today(), 
                Department__c                   = 'Engineering ET',
                Employee__c                     = myEmployee.Id,
                Number_of_Workers_Observed__c = 1
            );
            myObservationList.add(obs4);

            insert myObservationList; 

            obs1.OverallScore__c = 4; 
            obs2.OverallScore__c = 4; 
            obs3.OverallScore__c = 4; 
            obs4.OverallScore__c = 4; 

            Integer testHour     = Datetime.now().hour() + 1;
            testHour =  testHour==24 ? 0 : testHour;
            obs4.TimeHH__c       = testHour <10 ? '0'+String.valueOf(testHour):String.valueOf(testHour);

            System.debug('test obs4: '+ obs4);
           // new RevSys_ObservationExtension().TriggerHandler(false);
            new RevSys_ObservationTriggerHandler().TriggerHandler(false);
            update new List<Observation__c>{obs1,obs2, obs3, obs4};
        //  update myObservationList; 


        Test.stopTest();

        system.debug('TEST RevSys_ObservationHandler_Test testEntireClass-End');     
        return; 

    }
    
    testmethod static void testEmpFieldPopInObs() {
        //prepare test data
        Contact emp = new Contact(
            LastName = 'testLastName',
            Occupation__c = 'testOccupation',
            Division__c = 'testDivision'
           // Crew_Base__c = 'testCrewBase'
        );
        insert emp;
        
        Observation__c obs = new Observation__c(
            Employee__c = emp.Id,
            RecordTypeId = RevSys_StaticUtility.OBSERVATION_TEST1875_RECTYPE_ID,
            EvaluationDateTime__c = null
        );
        
        //execute logic
        insert obs;
        
        //assert logic
        Observation__c resultingObs = [SELECT Id, Occupation__c, Division__c, CrewBase__c FROM Observation__c WHERE Id = :obs.Id];
        System.assertEquals('testOccupation', resultingObs.Occupation__c);
        System.assertEquals('testDivision', resultingObs.Division__c);
    }
    testmethod static void testQuestionsForObs(){
        
        //prepare test data
        Contact emp =new Contact(
            LastName = 'testLastName',
            Occupation__c = 'testOccupation'
            //Division__c = 'testDivision',
            //Crew_Base__c = 'testCrewBase'
            );
        insert emp;
        
        Observation__c obs = new Observation__c(
            Employee__c = emp.Id,
            RecordTypeId = RevSys_StaticUtility.OBSERVATION_TEST1875_RECTYPE_ID,
            EvaluationDateTime__c = null
        );
        
        insert obs;      
        //execute logic
        
        Integer CusMetDataCount = [select count() from Station_Audit_Setting__mdt  WHERE Application__c = :RevSys_StaticUtility.REVSYS_APP_NAME AND Category__c = :RevSys_RecTypeUtility.convertIdToName(RevSys_StaticUtility.OBSERVATION_TEST1875_RECTYPE_ID)];
        Integer FindingCountforObs = [select count() from Finding__c where Observation__c = :obs.Id];
        
        System.debug('Custom Metadata Count' + CusMetDataCount);
        System.debug('Finding Count' + FindingCountforObs);
            
        //assert logic
    }
    testmethod static void testObs(){
        
        //prepare test data
        Contact emp =new Contact(
            LastName = 'testLastName',
            Occupation__c = 'testOccupation'
            //Division__c = 'testDivision',
            //Crew_Base__c = 'testCrewBase'
            );
        insert emp;
        
        OccupationSpecificRequirement__c osr = [Select Id from OccupationSpecificRequirement__c where RecordTypeId =: RevSys_StaticUtility.OCCSPECREQUIREMENT_DEPTCERT_FOR_OBS_RECTYPE_ID];
        
        Observation__c obs = new Observation__c(
            Employee__c = emp.Id,
            RecordTypeId = RevSys_StaticUtility.OBSERVATION_TEST1872_RECTYPE_ID,
            OccupationSpecificRequirement__c = osr.id,
            NonComplianceRuleNumber__c = '2',
            Comments__c = 'None',
            SupervisorsCommentSelection__c = 'None',
            Status__c = 'Submitted',
            EvaluationDateTime__c = null
        );
        
        insert obs;      
        //execute logic
        
        
            
        //assert logic
    }
    
    testmethod static void testTargetHelper2_1872(){
        
        //Prepare Date
        Station__c st = new Station__c();
        st.name = 'Station';
        insert st;
        
		Contact emp = [Select Id from Contact where Name = 'testLastName'];
        
        OccupationSpecificRequirement__c osr = [Select Id from OccupationSpecificRequirement__c where RecordTypeId =: RevSys_StaticUtility.OCCSPECREQUIREMENT_DEPTCERT_FOR_OBS_RECTYPE_ID];
        
        Observation__c obs = new Observation__c(
            Employee__c = emp.Id,
            RecordTypeId = RevSys_StaticUtility.OBSERVATION_TEST1872_RECTYPE_ID,
            OccupationSpecificRequirement__c = osr.id,
            NonComplianceRuleNumber__c = '2',
            Comments__c = 'None',
            SupervisorsCommentSelection__c = 'None',
            Status__c = 'Submitted',
            EvaluationDateTime__c = null
        );
        
        insert obs;  
        
        
        test.startTest();
        // Update the Observation
        obs.OperatedFromText__c='test station';
        obs.OperatedToCode__c = st.Id;
        obs.TimeMM__c = '01';
        obs.Status__c='Submitted';
        update obs;
        
        // Verify the Total Achieved for Employee and Supervisor
        List<EmployeeSpecificRequirement__c> totalAchievedAfterUpdate = [Select TotalAchieved__c from EmployeeSpecificRequirement__c where 
                                            (Employee__c=:obs.Employee__c OR Employee__c=:obs.Supervisor__c) AND RecordTypeId =: Revsys_StaticUtility.EMPSPECREQUIREMENT_SPARTNTARGET_RECTYPE_ID];

        /*if(totalAchievedAfterUpdate.size() > 0) {
            system.assertEquals(1,totalAchievedAfterUpdate[0].TotalAchieved__c);
        }*/

        //system.assertEquals(1,totalAchievedAfterUpdate[1].TotalAchieved__c);
        test.stopTest();
    }
    
    testmethod static void testTargetHelper2_Division(){
        
        //Prepare Date
        Station__c st = new Station__c();
        st.name = 'Station';
        insert st;
        
		Contact emp = [Select Id from Contact where Name = 'testDivision'];
        
        OccupationSpecificRequirement__c osr = [Select Id from OccupationSpecificRequirement__c where RecordTypeId =: RevSys_StaticUtility.OCCSPECREQUIREMENT_DEPTCERT_FOR_OBS_RECTYPE_ID];
        
        Observation__c obs = new Observation__c(
            Employee__c = emp.Id,
            RecordTypeId = RevSys_StaticUtility.OBSERVATION_TEST1872_RECTYPE_ID,
            OccupationSpecificRequirement__c = osr.id,
            NonComplianceRuleNumber__c = '2',
            Comments__c = 'None',
            SupervisorsCommentSelection__c = 'None',
            Status__c = 'Submitted',
            EvaluationDateTime__c = null
        );
        
        insert obs;  
        
        
        test.startTest();
        // Update the Observation
        obs.OperatedFromText__c='test station';
        obs.OperatedToCode__c = st.Id;
        obs.TimeMM__c = '01';
        obs.Status__c='Submitted';
        update obs;
        
        // Verify the Total Achieved for Employee and Supervisor
        List<EmployeeSpecificRequirement__c> totalAchievedAfterUpdate = [Select TotalAchieved__c from EmployeeSpecificRequirement__c where 
                                            (Employee__c=:obs.Employee__c OR Employee__c=:obs.Supervisor__c) AND RecordTypeId =: Revsys_StaticUtility.EMPSPECREQUIREMENT_SPARTNTARGET_RECTYPE_ID];
        /*if(totalAchievedAfterUpdate.size() > 0) {
            system.assertEquals(0,totalAchievedAfterUpdate[0].TotalAchieved__c);
        }*/
        //system.assertEquals(1,totalAchievedAfterUpdate[1].TotalAchieved__c);
        test.stopTest();
    }
    
    testmethod static void testTargetHelper2_Non1872(){
        
        //Prepare Date
        Station__c st = new Station__c();
        st.name = 'Station';
        insert st;
        
		Contact emp = [Select Id from Contact where Name = 'testNon1872'];
        
        OccupationSpecificRequirement__c osr = [Select Id from OccupationSpecificRequirement__c where RecordTypeId =: RevSys_StaticUtility.OCCSPECREQUIREMENT_DEPTCERT_FOR_OBS_RECTYPE_ID];
        
        Observation__c obs = new Observation__c(
            Employee__c = emp.Id,
            RecordTypeId = RevSys_StaticUtility.OBSERVATION_TEST1875_RECTYPE_ID,
            OccupationSpecificRequirement__c = osr.id,
            NonComplianceRuleNumber__c = '2',
            OperatedToCode__c = st.Id,
            Comments__c = 'None',
            SupervisorsCommentSelection__c = 'None',
            Status__c = 'Draft',
            EvaluationDateTime__c = null
        );
        
        insert obs;  
        
        
        test.startTest();
        // Update the Observation
        obs.OperatedFromText__c='test station';
        obs.TimeMM__c = '01';
        obs.Status__c='Submitted';
        update obs;
        
        // Verify the Total Achieved for Employee and Supervisor
        List<EmployeeSpecificRequirement__c> totalAchievedAfterUpdate = [Select TotalAchieved__c from EmployeeSpecificRequirement__c where 
                                            (Employee__c=:obs.Employee__c OR Employee__c=:obs.Supervisor__c) AND RecordTypeId =: Revsys_StaticUtility.EMPSPECREQUIREMENT_SPARTNTARGET_RECTYPE_ID];

        if(totalAchievedAfterUpdate.size() > 0) {
            system.assertEquals(1,totalAchievedAfterUpdate[0].TotalAchieved__c);
        }
        //system.assertEquals(1,totalAchievedAfterUpdate[1].TotalAchieved__c);
        test.stopTest();
    }
    
    @TestSetup
    public static void dataSetup(){
        //prepare test data
        List<Contact> lstContact = new List<Contact>();
        Contact emp = new Contact(
            LastName = 'testLastName',
            Occupation__c = 'testOccupation'
            //Division__c = 'testDivision',
            //Crew_Base__c = 'testCrewBase'
        );
        lstContact.add(emp);
        
        Contact SupervisoryCont = new Contact(
            LastName = 'testSupervisor',
            Occupation__c = 'Supervisor'
            //Division__c = 'testDivision',
            //Crew_Base__c = 'testCrewBase'
        );
        lstContact.add(SupervisoryCont);
        
        Contact emp1 = new Contact(
            LastName = 'testNon1872',
            Occupation__c = 'testOccupation'
            //Division__c = 'testDivision',
            //Crew_Base__c = 'testCrewBase'
        );
        lstContact.add(emp1);
        
        Contact Foreign = new Contact(
            LastName = 'testDivision',
            Employee_Type__c = Label.Revsys_Constant_External,
            Occupation__c = 'testOccupation',
            Division__c = 'Central'
            //Crew_Base__c = 'testCrewBase'
        );
        lstContact.add(Foreign);
        insert lstContact;
        
        Observation__c obs = new Observation__c(
            Employee__c = lstContact[0].Id,
            RecordTypeId = RevSys_StaticUtility.OBSERVATION_TEST1875_RECTYPE_ID,
            TestNumber__c='Test123',
            Status__c='Draft',
            Supervisor__c=lstContact[1].Id,
            EvaluationDateTime__c=System.Today().AddDays(-1)
        );
        insert obs;
        
        OccupationRequirement__c OccRecRec = new OccupationRequirement__c(
            RecordTypeId = RevSys_StaticUtility.OCCREQUIREMENT_SPARTNOBSERVATION_RECTYPE_ID,
            TestNumber__c='Test123',
            TestName__c = 'Test',
            Source__c = 'Observation',
            SourceRecordType__c = 'FORM-1872'
        );
        insert OccRecRec;
        
        List<OccupationCertification__c> ocList = new List<OccupationCertification__c>();
        OccupationCertification__c OccCert = new OccupationCertification__c(
            RecordTypeId = RevSys_StaticUtility.OCCUPCERTIFICATION_SPARTNTARGET_RECTYPE_ID
        );
        ocList.add(OccCert);
        
           OccupationCertification__c OccCert1 = new OccupationCertification__c(
            RecordTypeId = RevSys_StaticUtility.OCCUPCERTIFICATION_SPARTNTARGET_RECTYPE_ID,
            SourceRecordType__c = 'FORM-1875'
        );
        ocList.add(OccCert1);
        
        OccupationCertification__c OccCert2 = new OccupationCertification__c(
            RecordTypeId = RevSys_StaticUtility.OCCUPCERTIFICATION_SPARTNTARGET_RECTYPE_ID,
            DivisionOfObservation__c = 'Central'
        );
        ocList.add(OccCert2);
        insert ocList;
            
        OccupationSpecificRequirement__c osrRec = new OccupationSpecificRequirement__c(
            Observation__c=OccRecRec.Id,
            Target__c=OccCert.Id
        );
        insert osrRec;
          
        List<EmployeeSpecificRequirement__c> lstESR = new List<EmployeeSpecificRequirement__c>();
        EmployeeSpecificRequirement__c esrRec = new EmployeeSpecificRequirement__c(
            TotalAchieved__c=0,
            Employee__c=lstContact[0].Id,
            Target__c=ocList[0].Id,
            Status__c = 'Active',
            StartDate__c = system.today().AddDays(-2),
            EndDate__c= system.today().AddDays(2)
        );
        lstESR.add(esrRec);

		EmployeeSpecificRequirement__c esrReqRec = new EmployeeSpecificRequirement__c(
            RecordTypeId = RevSys_StaticUtility.EMPSPECREQUIREMENT_SPARTNCERT_RECTYPE_ID,
            TotalAchieved__c=0,
            Employee__c=lstContact[0].Id,
            Target__c=ocList[0].Id,
			OccupationSpecificRequirement__c = osrRec.Id,
            Status__c = 'Active',
            StartDate__c = system.today().AddDays(-2),
            EndDate__c= system.today().AddDays(2)
        );
        lstESR.add(esrReqRec);

        
        EmployeeSpecificRequirement__c SupervisoryESR = new EmployeeSpecificRequirement__c(
            TotalAchieved__c=0,
            Employee__c=lstContact[1].Id,
            Target__c=ocList[0].Id,
            StartDate__c = system.today().AddDays(-2),
            EndDate__c= system.today().AddDays(2)
        );
        lstESR.add(SupervisoryESR);
        
        EmployeeSpecificRequirement__c non1872ESR = new EmployeeSpecificRequirement__c(
            TotalAchieved__c=0,
            Employee__c=lstContact[2].Id,
            Status__c = 'Active',
            Target__c=ocList[1].Id,
            StartDate__c = system.today().AddDays(-2),
            EndDate__c= system.today().AddDays(2)
        );
        lstESR.add(non1872ESR);
        EmployeeSpecificRequirement__c esrDivision = new EmployeeSpecificRequirement__c(
            TotalAchieved__c=0,
            Employee__c=lstContact[3].Id,
            Target__c=ocList[2].Id,
            Status__c = 'Active',
            StartDate__c = system.today().AddDays(-2),
            EndDate__c= system.today().AddDays(2)
        );
        lstESR.add(esrDivision);
        insert lstESR;
        
        OccupationSpecificRequirement__c osrObj = new OccupationSpecificRequirement__c();
        osrObj.Observation__c = OccRecRec.id;
        osrObj.ObservationDepartment2__c = 'Mechanical';
        osrObj.ObservationCraft2__c = 'Conductor';
        osrObj.RecordTypeId = Revsys_StaticUtility.OCCSPECREQUIREMENT_DEPTCERT_FOR_OBS_RECTYPE_ID;
        insert osrObj;
    }

    testmethod static void testTargetHelper2_Exception(){
        try {
            RevSys_ObservationTriggerHandler.DoFailTest=true;
            //Prepare Date
            Station__c st = new Station__c();
            st.name = 'Station';
            insert st;
            
            Contact emp = [Select Id from Contact where Name = 'testDivision'];
            
            OccupationSpecificRequirement__c osr = [Select Id from OccupationSpecificRequirement__c where RecordTypeId =: RevSys_StaticUtility.OCCSPECREQUIREMENT_DEPTCERT_FOR_OBS_RECTYPE_ID];
            
            Observation__c obs = new Observation__c(
                Employee__c = emp.Id,
                RecordTypeId = RevSys_StaticUtility.OBSERVATION_TEST1872_RECTYPE_ID,
                OccupationSpecificRequirement__c = osr.id,
                NonComplianceRuleNumber__c = '2',
                Comments__c = 'None',
                SupervisorsCommentSelection__c = 'None',
                Status__c = 'Submitted',
                EvaluationDateTime__c = null
            );
            
            insert obs;  
        }catch (Exception e) {
            Boolean b = e.getMessage().contains('Error')?true:false;
            System.assertEquals(true,b);
        }
    }
    public static testMethod void testUpdateHierarchyAssignmentwithtestdate(){
        
        SPARTN_Custom_Settings__c setting = new SPARTN_Custom_Settings__c();
        setting.Name = 'Valid Employee Department';
        setting.CsvString__c = 'TRANSPORTATION,ENGINEERING,MECHANICAL';
        insert setting;
        Account amtrakAcct = new Account
            (
                Name='Amtrak'
            );
        insert amtrakAcct;
        Contact employeeA1 = new Contact
            (
                AccountId           = amtrakAcct.id, 
                LastName            ='Employee', 
                FirstName           ='Abigale', 
                Personnel_Number__c = 10000001,
                Email               = 'abigale.employee@amtrak.com'
                
            );
        insert employeeA1;
        EPW_Organization__c Org1 = new EPW_Organization__c
            ( 
                RecordTypeId = Revsys_StaticUtility.ORGANIZATION_AMTRAKORG_RECTYPE_ID, 
                Name = 'Amtrak Org', 
                EPW_Organization_Number__c = '1',
                EPW_Status__c = 'Active'
            );
        insert Org1;
        
        EPW_Position_Hierarchy__c myPoHi = new EPW_Position_Hierarchy__c
            (   
             RecordTypeId = Revsys_StaticUtility.POSITION_HIERARCHY_AMTRAK_RECTYPE_ID, 
             EPW_Position_Organization__c = Org1.Id,
             Name = 'Leve1 Supervisor A',
             EPW_Position_ID__c =  '10000000',
             EPW_Status__c = 'Active',
             EPW_Dept_Code_Description__c = 'Transportation'
            ); 
        
        insert myPoHi;

        EPW_Hierarchy_Assignment__c myHiAsgn0 = new EPW_Hierarchy_Assignment__c
            ( 
                EPW_Contact__c = employeeA1.Id,
            	EPW_Position_Hierarchy__c = myPoHi.Id,
                EPW_Status__c = 'Active',
                SupervisorEmail__c = 'bob.supervisor@amtrak.com'
            );
        insert myHiAsgn0;
        
        Observation__c obs        = new Observation__c();
        obs.RecordTypeId          = RevSys_StaticUtility.OBSERVATION_TEST1878_RECTYPE_ID;
        obs.Status__c             = 'Submitted';
        obs.EvaluationDateTime__c = Datetime.now();
        obs.Employee__c           = employeeA1.Id;
        obs.TestNumber__c		  = '101';
        insert obs;
        
        Test.startTest();
        obs.TestNumber__c		  = '103';
        update obs;
        Test.stopTest();
    }
}
/*
*___________________________________________________
*@Name: 	RevSys_EmployeeCertificationBatch_Test
*@Author: 	Chuck Walley
*@Created: 	Date: June 4, 2018
*@Used_By: 	SPARTN
*___________________________________________________
*@Description: Unit test class to test the functionality implemented in RevSys_EmployeeCertification_Batch class
* 
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/
@isTest
public class RevSys_EmployeeCertificationBatch_Test {
        
    Static Integer maxContactBatchRecords = 30;  // Test 1  
    Static Integer maxContactRecords = 12;       // Test 2
    
    Static Id my00RandomEmployeeId; 
    Static Id my30RandomEmployeeId; 
    Static Id my60RandomEmployeeId; 
    Static Id my90RandomEmployeeId; 
    
    Static String my00DayMsg; 
    Static String my30DayMsg; 
    Static String my60DayMsg; 
    Static String my90DayMsg; 
    
    
    
    
    public static testMethod void testBatch1() {
    
         //SETUP
		Set<Id> myEmployeeCertificationIdSet                            = new Set<Id>();
		Map<Date, BatchProcessParameter__mdt>   batchProcesParam        = new Map<Date, BatchProcessParameter__mdt>();
		List<Date> myParameterDateList                                  = new List<Date>();
		Map<Date, BatchProcessParameter__mdt> myParameterMap            = new Map<Date, BatchProcessParameter__mdt>();
		Map<String, String> myMessageMap                                = new Map<String,String>();
		List<EmployeeCertification__c> myEcToProcessList                = new List<EmployeeCertification__c>();
		List<EmployeeCertification__c> myEcCheckNowList                 = new List<EmployeeCertification__c>();
		List<EmployeeCertification__c> myEcCheckLaterList               = new List<EmployeeCertification__c>();
		List<EmployeeCertification__c> employeeCertificationUpdateList  = new List<EmployeeCertification__c>();
		List<EmployeeCertification__c> empCertExpiredUpdated            = new List<EmployeeCertification__c>();
		Set<Id> employeeIds                                             = new Set<Id>();
		Set<String> templateNames                                       = new Set<String>();
		Map<Id,Id> empSuperId = new Map<Id,Id>();
		Map<Id,Id> empManagerId = new Map<Id,Id>();
        
        
        
        SPARTN_Custom_Settings__c setting = new SPARTN_Custom_Settings__c();  
        setting.Name = 'Valid Employee Department';
        setting.CsvString__c = 'TRANSPORTATION,ENGINEERING,MECHANICAL';    
        insert setting;
        
        // Get the Batch Process Parameter configuration records for batch processing.
        SelectorWrapper wrapper = BatchProcessParameterSelector.getBatchProcessParamRecords();
		if(wrapper!=null){
			//for each BPP records, load into map on the basis of the parameter date
			for(BatchProcessParameter__mdt bppRec : (List<BatchProcessParameter__mdt>) wrapper.sObjectList) {
				Integer lengthOfPeriod = Integer.valueOf(bppRec.LengthOfPeriod__c);
				Date myParameterDate = AMTRAK_DateUtility.determineDate(bppRec.Frequency__c,lengthOfPeriod);
				templateNames.add(bppRec.TemplateAPIName__c);
				myParameterDateList.add(myParameterDate);
				myParameterMap.put(myParameterDate, bppRec); 
                Integer myInt = Integer.valueOf(bppRec.LengthOfPeriod__c);
				myMessageMap.put(String.valueOf(myInt), bppRec.SuccessStateValue__c); 
			}

			if(!myParameterDateList.isEmpty()) {
				myParameterDateList.sort();					
			}
		}
		
		system.debug('myParameterDateList ' + myParameterDateList); 
		
		Date my00DaysDate = myParameterDateList[0].addDays(-1); 
		Date my30DaysDate = myParameterDateList[1].addDays(-1); 
		Date my60DaysDate = myParameterDateList[2].addDays(-1); 
		Date my90DaysDate = myParameterDateList[3].addDays(-1); 
		
		system.debug('my00DaysDate ' + my00DaysDate); 
		system.debug('my30DaysDate ' + my30DaysDate); 
		system.debug('my60DaysDate ' + my60DaysDate); 
		system.debug('my90DaysDate ' + my90DaysDate); 
		
		
		// Get Messages: 
		
		my00DayMsg = myMessageMap.get('0'); 
		my30DayMsg = myMessageMap.get('30'); 
		my60DayMsg = myMessageMap.get('60'); 
		my90DayMsg = myMessageMap.get('90'); 
		
		system.debug('my00DayMsg ' + my00DayMsg); 
		system.debug('my30DayMsg ' + my30DayMsg); 
		system.debug('my60DayMsg ' + my60DayMsg); 
		system.debug('my90DayMsg ' + my90DayMsg); 
		
        
        OccupationCertification__c certificate = new OccupationCertification__c();
		certificate.Status__c='Active';
		certificate.Name='NoWayThisNameIsUsed';
		certificate.RecordTypeId = RevSys_StaticUtility.OCCUPCERTIFICATION_SPARTNCERT_RECTYPE_ID;
		certificate.Frequency__c='Years';
		certificate.LengthOfPeriod__c=3;
		insert certificate;

		OccupationRequirement__c req= new OccupationRequirement__c();
		req.RecordTypeId = RevSys_StaticUtility.OCCREQUIREMENT_SPARTNREQUIREMENT_RECTYPE_ID;
		req.Name = 'Requirement Name';
		req.Source__c= 'Employee Result Summary';
		req.SourceRecordType__c = 'Medical, Hearing and Vision';
		req.SourceTestType__c = 'Medical Examination';
		req.Status__c = 'Active';
		insert req;

		OccupationSpecificRequirement__c osr = new OccupationSpecificRequirement__c();
		osr.RecordTypeId = RevSys_StaticUtility.OCCSPECREQUIREMENT_SPARTNCERT_RECTYPE_ID;
		osr.Certification__c = certificate.Id;
		osr.Requirement__c = req.Id;
		osr.Frequency__c = 'Days';
		osr.LengthOfPeriod__c = 366;
		insert osr;
		
		// Load Positions: 
		
		//Amtrak PH
		EPW_Position_Hierarchy__c amtrakPH = new EPW_Position_Hierarchy__c
        (   RecordTypeId = Revsys_StaticUtility.POSITION_HIERARCHY_AMTRAK_RECTYPE_ID, 
            Name = 'Leve1 Supervisor A',
            EPW_Position_ID__c =  '10000000',
            EPW_Status__c = 'Active',
            EPW_Dept_Code_Description__c = 'Transportation'
        );
        insert amtrakPH;
		
		//Spartn PH
		EPW_Position_Hierarchy__c myPoHi1 = new EPW_Position_Hierarchy__c
        (   RecordTypeId = Revsys_StaticUtility.POSITION_HIERARCHY_SPARTN_RECTYPE_ID, 
            Name = 'Leve1 Supervisor A',
            EPW_Position_ID__c =  '10000000',
            EPW_Status__c = 'Active',
            EPW_Dept_Code_Description__c = 'Transportation'
        );
        insert myPoHi1;
		
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

        for (Integer xCount = 1; xCount < maxContactBatchRecords-1; xCount++) {

            String myEmail = 'this.guy' + String.valueOf(xCount) + '@amtrak.off'; 

            Contact myContact = new Contact
            (
                AccountId           = amtrakAcct.id, 
                LastName            = 'LastName' + String.valueOf(xCount), 
                FirstName           = 'FirstName', 
                Department          = 'Transportation',
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
        
        EPW_Hierarchy_Assignment__c myHiAsgn1 = new EPW_Hierarchy_Assignment__c
        ( 
            EPW_Contact__c = supervisorA.Id,
            EPW_Position_Hierarchy__c = myPoHi1.Id,
            EPW_Status__c = 'Active'
        );
        insert myHiAsgn1;

        List<EPW_Position_Hierarchy__c> myPoHiList = new List<EPW_Position_Hierarchy__c>();  

        for (Integer xCount = 1; xCount < maxContactBatchRecords+1; xCount++) {

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
        
        
        
        // For each contact, insert an Employee Certification 
        // 1   - 50  - Expire today
        // 51  - 100 - Expire in 30 days 
        // 101 - 150 - Expire in 60 days
        // 151 - 200 - Expire in 90 days
        
        List<EmployeeCertification__c>    myEmpCertList = new List<EmployeeCertification__c>(); 
        List<EPW_Hierarchy_Assignment__c> myHaList      = new List<EPW_Hierarchy_Assignment__c>(); 
        
        system.debug('CONTACT LIST SIZE ' + myContactList.size()); 
        system.debug('POSITION HIERARCHY LIST SIZE ' + myPoHiList.size()); 
        
        Integer yCount = 1; 
        for(Contact myContact :myContactList) { 
            
            Date myDate; 
            String myEmailStatus; 
            
            if(yCount >= 1 && yCount <= 8) {
                myDate = my00DaysDate; 
                myEmailStatus = my90DayMsg; 
                if(yCount == 1) {
                    my00RandomEmployeeId = myContact.Id; 
                }
            }
            else if(yCount >= 9 && yCount <= 16) { 
                myDate = my30DaysDate; 
                myEmailStatus = my60DayMsg;
                if(yCount == 10) {
                    my30RandomEmployeeId = myContact.Id; 
                }
            }
            else if(yCount >= 17 && yCount <= 24) { 
                myDate = my60DaysDate; 
                myEmailStatus = my30DayMsg; 
                if(yCount == 18) {
                    my60RandomEmployeeId = myContact.Id; 
                }
            }
            else {
                myDate = my90DaysDate; 
                myEmailStatus = null;
                if(yCount == 25) {
                    my90RandomEmployeeId = myContact.Id; 
                }
            }
            
            EmployeeCertification__c myEmpCert = new EmployeeCertification__c
            (
                Employee__c = myContact.Id,
		        Certification__c = certificate.Id,
		        ExpirationDate__c = myDate,
		        Status__c = 'Current',
		        EmailStatus__c  = myEmailStatus,
                RecordTypeId = RevSys_StaticUtility.EMPCERT_SPARTNCERT_RECTYPE_ID
		    ); 
		    
		   
		    
		    myEmpCertList.add(myEmpCert); 
		    
		    EPW_Hierarchy_Assignment__c myHiAsgn = new EPW_Hierarchy_Assignment__c
            ( 
                EPW_Contact__c = myContact.Id,
                EPW_Position_Hierarchy__c = myPoHiList[yCount-1].Id,
                EPW_Status__c = 'Active'
            );
            
            
            myHaList.add(myHiAsgn); 
		    
		    yCount++; 
            
        }
        
        INSERT myHaList; 
        
        SPARTN_BypassRuleSettings__c bypassRule = SPARTN_BypassRuleSettings__c.getOrgDefaults();  
    	bypassRule.Processes__c = true; 
    	bypassRule.ValidationRules__c = true; 
    	bypassRule.WorkflowRules__c = true; 
    	insert bypassRule; 
        
        INSERT myEmpCertList; 
        
        Test.startTest();
            system.debug('START TEST'); 
            
            RevSys_EmployeeCertification_Batch myJob = new RevSys_EmployeeCertification_Batch(); 

            String sch = '00 03 * * * ? *';
            String jobID = system.schedule('Test'+Math.random(),sch, myJob); 
            
            List<AsyncApexJob> jobInfo = [SELECT Status,NumberOfErrors, jobitemsprocessed, totalJobItems FROM AsyncApexJob];
            AsyncApexJob apexJob;
            if(jobInfo!=null && jobInfo.size()!=0) {
                apexJob = jobInfo.get(0);
                List<Messaging.SingleEmailMessage> errorEmails = myJob.generateErrorEmail(apexJob);
                System.assertEquals(1, errorEmails.size());  
            }
           
            
            system.debug('STOP TEST'); 
        Test.stopTest();
        
    }
    
    
    
    public static testMethod void testBatch2() {
        
         //SETUP
		Set<Id> myEmployeeCertificationIdSet                            = new Set<Id>();
		Map<Date, BatchProcessParameter__mdt>   batchProcesParam        = new Map<Date, BatchProcessParameter__mdt>();
		List<Date> myParameterDateList                                  = new List<Date>();
		Map<Date, BatchProcessParameter__mdt> myParameterMap            = new Map<Date, BatchProcessParameter__mdt>();
		Map<String, String> myMessageMap                                = new Map<String,String>();
		List<EmployeeCertification__c> myEcToProcessList                = new List<EmployeeCertification__c>();
		List<EmployeeCertification__c> myEcCheckNowList                 = new List<EmployeeCertification__c>();
		List<EmployeeCertification__c> myEcCheckLaterList               = new List<EmployeeCertification__c>();
		List<EmployeeCertification__c> employeeCertificationUpdateList  = new List<EmployeeCertification__c>();
		List<EmployeeCertification__c> empCertExpiredUpdated            = new List<EmployeeCertification__c>();
		Set<Id> employeeIds                                             = new Set<Id>();
		Set<String> templateNames                                       = new Set<String>();
		Map<Id,Id> empSuperId = new Map<Id,Id>();
		Map<Id,Id> empManagerId = new Map<Id,Id>();
        
        
        
        SPARTN_Custom_Settings__c setting = new SPARTN_Custom_Settings__c();  
        setting.Name = 'Valid Employee Department';
        setting.CsvString__c = 'TRANSPORTATION,ENGINEERING,MECHANICAL';    
        insert setting;
        
        // Get the Batch Process Parameter configuration records for batch processing.
        SelectorWrapper wrapper = BatchProcessParameterSelector.getBatchProcessParamRecords();
		if(wrapper!=null){
			//for each BPP records, load into map on the basis of the parameter date
			for(BatchProcessParameter__mdt bppRec : (List<BatchProcessParameter__mdt>) wrapper.sObjectList) {
				Integer lengthOfPeriod = Integer.valueOf(bppRec.LengthOfPeriod__c);
				Date myParameterDate = AMTRAK_DateUtility.determineDate(bppRec.Frequency__c,lengthOfPeriod);
				templateNames.add(bppRec.TemplateAPIName__c);
				myParameterDateList.add(myParameterDate);
				myParameterMap.put(myParameterDate, bppRec); 
                Integer myInt = Integer.valueOf(bppRec.LengthOfPeriod__c);
				myMessageMap.put(String.valueOf(myInt), bppRec.SuccessStateValue__c); 
			}

			if(!myParameterDateList.isEmpty()) {
				myParameterDateList.sort();					
			}
		}
		
		system.debug('myMessageMap ' + myMessageMap); 
        system.debug('myParameterDateList ' + myParameterDateList); 
		
		Date my00DaysDate = myParameterDateList[0].addDays(-1); 
		Date my30DaysDate = myParameterDateList[1].addDays(-1); 
		Date my60DaysDate = myParameterDateList[2].addDays(-1); 
		Date my90DaysDate = myParameterDateList[3].addDays(-1); 
		
		system.debug('my00DaysDate ' + my00DaysDate); 
		system.debug('my30DaysDate ' + my30DaysDate); 
		system.debug('my60DaysDate ' + my60DaysDate); 
		system.debug('my90DaysDate ' + my90DaysDate); 
		
		
		// Get Messages: 
		
		my00DayMsg = myMessageMap.get('0'); 
		my30DayMsg = myMessageMap.get('30'); 
		my60DayMsg = myMessageMap.get('60'); 
		my90DayMsg = myMessageMap.get('90'); 
		
		system.debug('my00DayMsg ' + my00DayMsg); 
		system.debug('my30DayMsg ' + my30DayMsg); 
		system.debug('my60DayMsg ' + my60DayMsg); 
		system.debug('my90DayMsg ' + my90DayMsg); 
		
        
        OccupationCertification__c certificate = new OccupationCertification__c();
		certificate.Status__c='Active';
		certificate.Name='NoWayThisNameIsUsed';
		certificate.RecordTypeId = RevSys_StaticUtility.OCCUPCERTIFICATION_SPARTNCERT_RECTYPE_ID;
		certificate.Frequency__c='Years';
		certificate.LengthOfPeriod__c=3;
		insert certificate;

		OccupationRequirement__c req= new OccupationRequirement__c();
		req.RecordTypeId = RevSys_StaticUtility.OCCREQUIREMENT_SPARTNREQUIREMENT_RECTYPE_ID;
		req.Name = 'Requirement Name';
		req.Source__c= 'Employee Result Summary';
		req.SourceRecordType__c = 'Medical, Hearing and Vision';
		req.SourceTestType__c = 'Medical Examination';
		req.Status__c = 'Active';
		insert req;

		OccupationSpecificRequirement__c osr = new OccupationSpecificRequirement__c();
		osr.RecordTypeId = RevSys_StaticUtility.OCCSPECREQUIREMENT_SPARTNCERT_RECTYPE_ID;
		osr.Certification__c = certificate.Id;
		osr.Requirement__c = req.Id;
		osr.Frequency__c = 'Days';
		osr.LengthOfPeriod__c = 366;
		insert osr;
		
		// Load Positions: 
		
		//Amtrak PH
		EPW_Position_Hierarchy__c amtrakPH = new EPW_Position_Hierarchy__c
        (   RecordTypeId = Revsys_StaticUtility.POSITION_HIERARCHY_AMTRAK_RECTYPE_ID, 
            Name = 'Leve1 Supervisor A',
            EPW_Position_ID__c =  '10000000',
            EPW_Status__c = 'Active',
            EPW_Dept_Code_Description__c = 'Transportation'
        );
        insert amtrakPH;
		
		//Spartn PH
		EPW_Position_Hierarchy__c myPoHi1 = new EPW_Position_Hierarchy__c
        (   RecordTypeId = Revsys_StaticUtility.POSITION_HIERARCHY_SPARTN_RECTYPE_ID, 
            Name = 'Leve1 Supervisor A',
            EPW_Position_ID__c =  '10000000',
            EPW_Status__c = 'Active',
            EPW_Dept_Code_Description__c = 'Transportation'
        );
        insert myPoHi1;
		
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

        for (Integer xCount = 1; xCount < maxContactRecords-1; xCount++) {

            String myEmail = 'this.guy' + String.valueOf(xCount) + '@amtrak.off'; 

            Contact myContact = new Contact
            (
                AccountId           = amtrakAcct.id, 
                LastName            = 'LastName' + String.valueOf(xCount), 
                FirstName           = 'FirstName', 
                Department          = 'Transportation',
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
        
        EPW_Hierarchy_Assignment__c myHiAsgn1 = new EPW_Hierarchy_Assignment__c
        ( 
            EPW_Contact__c = supervisorA.Id,
            EPW_Position_Hierarchy__c = myPoHi1.Id,
            EPW_Status__c = 'Active'
        );
        insert myHiAsgn1;

        List<EPW_Position_Hierarchy__c> myPoHiList = new List<EPW_Position_Hierarchy__c>();  

        for (Integer xCount = 1; xCount < maxContactRecords+1; xCount++) {

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
        
        
        
        // For each contact, insert an Employee Certification 
        // 1   - 50  - Expire today
        // 51  - 100 - Expire in 30 days 
        // 101 - 150 - Expire in 60 days
        // 151 - 200 - Expire in 90 days
        
        List<EmployeeCertification__c>    myEmpCertList = new List<EmployeeCertification__c>(); 
        List<EPW_Hierarchy_Assignment__c> myHaList      = new List<EPW_Hierarchy_Assignment__c>(); 
        
        
        
        
        system.debug('CONTACT LIST SIZE ' + myContactList.size()); 
        system.debug('POSITION HIERARCHY LIST SIZE ' + myPoHiList.size()); 
        
        
        Integer yCount = 1; 
        for(Contact myContact :myContactList) { 
            
            Date myDate; 
            String myEmailStatus; 
            
            if(yCount >= 1 && yCount <= 3) {
                myDate = my00DaysDate; 
                myEmailStatus = my90DayMsg; 
                if(yCount == 1) {
                    my00RandomEmployeeId = myContact.Id; 
                }
            }
            else if(yCount >= 4 && yCount <= 6) { 
                myDate = my30DaysDate; 
                myEmailStatus = my60DayMsg;
                if(yCount == 5) {
                    my30RandomEmployeeId = myContact.Id; 
                }
            }
            else if(yCount >= 7 && yCount <= 9) { 
                myDate = my60DaysDate; 
                myEmailStatus = my30DayMsg; 
                if(yCount == 8) {
                    my60RandomEmployeeId = myContact.Id; 
                }
            }
            else {
                myDate = my90DaysDate; 
                myEmailStatus = null;
                if(yCount == 10) {
                    my90RandomEmployeeId = myContact.Id; 
                }
            }
            
            EmployeeCertification__c myEmpCert = new EmployeeCertification__c
            (
                Employee__c = myContact.Id,
		        Certification__c = certificate.Id,
		        ExpirationDate__c = myDate,
		        Status__c = 'Current',
		        EmailStatus__c  = myEmailStatus,
                RecordTypeId = RevSys_StaticUtility.EMPCERT_SPARTNCERT_RECTYPE_ID
		    ); 
		    
		   
		    
		    myEmpCertList.add(myEmpCert); 
		    
		    EPW_Hierarchy_Assignment__c myHiAsgn = new EPW_Hierarchy_Assignment__c
            ( 
                EPW_Contact__c = myContact.Id,
                EPW_Position_Hierarchy__c = myPoHiList[yCount-1].Id,
                EPW_Status__c = 'Active'
            );
            
            
            myHaList.add(myHiAsgn); 
		    
		    yCount++; 
            
        }
        
        INSERT myHaList; 
        
        SPARTN_BypassRuleSettings__c bypassRule = SPARTN_BypassRuleSettings__c.getOrgDefaults();  
    	bypassRule.Processes__c = true; 
    	bypassRule.ValidationRules__c = true; 
    	bypassRule.WorkflowRules__c = true; 
    	insert bypassRule; 
        
        INSERT myEmpCertList; 
        
        
        // Get all Employee Certification Records 
        QueryUtilityWrapper myQuWrap = QueryUtility.beginDynamicQuery(label.OBJAPI_EMPLOYEE_CERTIFICATION);   
        String myQuery = myQuWrap.QueryString; 
        List<EmployeeCertification__c> myEcList = Database.query(myQuery); 
        
        Test.startTest();
            system.debug('START TEST'); 
            
            Revsys_EmailHelper.employeeCert(myEcList); 
            
            system.debug('STOP TEST'); 
        Test.stopTest();
        
        
        // Get all Employee Certification Records 
        myQuWrap = QueryUtility.beginDynamicQuery(label.OBJAPI_EMPLOYEE_CERTIFICATION);   
        myQuery = myQuWrap.QueryString; 
        List<EmployeeCertification__c> myOutEcList = Database.query(myQuery); 
        
        Map<Id,EmployeeCertification__c> myEmpCertMap = new Map<Id,EmployeeCertification__c>(); 
        
        // Map the EC by Employee ID. (We can do this because each employee has only one certification) 
        for(EmployeeCertification__c myEc :myOutEcList) { 
            myEmpCertMap.put(myEc.Employee__c, myEc); 
        }
        
        EmployeeCertification__c my00Ec = myEmpCertMap.get(my00RandomEmployeeId); 
        EmployeeCertification__c my30Ec = myEmpCertMap.get(my30RandomEmployeeId); 
        EmployeeCertification__c my60Ec = myEmpCertMap.get(my60RandomEmployeeId); 
        EmployeeCertification__c my90Ec = myEmpCertMap.get(my90RandomEmployeeId); 
        
        system.debug('ASSERTION CHECK'); 
        system.assertEquals(my00DayMsg,my00Ec.EmailStatus__c); 
        system.assertEquals(my30DayMsg,my30Ec.EmailStatus__c);
        system.assertEquals(my60DayMsg,my60Ec.EmailStatus__c);
        system.assertEquals(my90DayMsg,my90Ec.EmailStatus__c); 
   
    }
    
    public static testMethod void testBatch3() {

		Contact employee = new Contact
		(
			LastName			='Employee', 
			FirstName			='Amy', 
			Department 			= 'Mechanical',
			Employment_Status__c = 'Active',
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
			Employment_Status__c = 'Active',
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
			Employment_Status__c = 'Active',
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


        //Amtrak PH
		EPW_Position_Hierarchy__c amtrakPH = new EPW_Position_Hierarchy__c
        (   RecordTypeId = Revsys_StaticUtility.POSITION_HIERARCHY_AMTRAK_RECTYPE_ID, 
            EPW_Position_Organization__c = Org1.Id,
            Name = 'Leve1 Supervisor A',
            EPW_Position_ID__c =  '10000000',
            EPW_Status__c = 'Active',
            EPW_Dept_Code_Description__c = 'Transportation'
        );
        insert amtrakPH;

        EPW_Hierarchy_Assignment__c amtrakHA = new EPW_Hierarchy_Assignment__c
        ( 
            EPW_Contact__c = manager.Id,
            EPW_Position_Hierarchy__c = amtrakPH.Id,
            EPW_Status__c = 'Active'
        );
        insert amtrakHA;

        EPW_Position_Hierarchy__c amtrakPH2 = new EPW_Position_Hierarchy__c
        (   RecordTypeId = Revsys_StaticUtility.POSITION_HIERARCHY_AMTRAK_RECTYPE_ID, 
            EPW_Position_Organization__c = Org1.Id,
            EPW_Parent_Position_Hierarchy__c = amtrakPH.Id,
            Name = 'Leve2 Employee A',
            EPW_Position_ID__c =  '1000',
            EPW_Status__c = 'Active',
            EPW_Dept_Code_Description__c = 'Transportation'
        );
        insert amtrakPH2;

        EPW_Hierarchy_Assignment__c amtrakHA2 = new EPW_Hierarchy_Assignment__c
        ( 
            EPW_Contact__c = employee.Id,
            EPW_Position_Hierarchy__c = amtrakPH2.Id,
            EPW_Status__c = 'Active'
        );
        insert amtrakHA2; 

		OccupationCertification__c certificate = new OccupationCertification__c();
		certificate.Status__c='Active';
		certificate.Name='Certificate1';
		certificate.RecordTypeId = RevSys_StaticUtility.OCCUPCERTIFICATION_SPARTNCERT_RECTYPE_ID;
		certificate.Frequency__c='Days';
		certificate.LengthOfPeriod__c=1;
		insert certificate;

		OccupationRequirement__c req= new OccupationRequirement__c();
		req.RecordTypeId = RevSys_StaticUtility.OCCREQUIREMENT_SPARTNREQUIREMENT_RECTYPE_ID;
		req.Name = 'Requirement Name';
		req.Source__c= 'Employee Result Summary';
		req.SourceRecordType__c = 'Medical, Hearing and Vision';
		req.SourceTestType__c = 'Medical Examination';
		req.Status__c = 'Active';
		insert req;

		OccupationSpecificRequirement__c osr = new OccupationSpecificRequirement__c();
		osr.RecordTypeId = RevSys_StaticUtility.OCCSPECREQUIREMENT_SPARTNCERT_RECTYPE_ID;
		osr.Certification__c = certificate.Id;
		osr.Requirement__c = req.Id;
		osr.Frequency__c = 'Days';
		osr.LengthOfPeriod__c = 10;
		insert osr;

		List<EmployeeCertification__c> emCertificationList = new List<EmployeeCertification__c>();
		EmployeeCertification__c emCertification = new EmployeeCertification__c();
		emCertification.Employee__c = employee.Id;
		emCertification.Certification__c = certificate.Id;
		//emCertification.ExpirationDate__c = (System.today()).addDays(-30);
		emCertification.ExpirationDate__c = System.today();
		emCertification.Status__c = 'Current';
		emCertification.ProcessFlag__c  = Label.RevSys_EmpCert_ProcessFlag;
        emCertification.RecordTypeId = RevSys_StaticUtility.EMPCERT_SPARTNCERT_RECTYPE_ID;
		emCertificationList.add(emCertification);

		emCertification = new EmployeeCertification__c();
		emCertification.Employee__c = employee.Id;
		emCertification.Certification__c = certificate.Id;
		emCertification.ExpirationDate__c =System.today().addDays(60);
		emCertification.Status__c = 'Current';
		emCertification.ProcessFlag__c  = Label.RevSys_EmpCert_ProcessFlag;
        emCertification.RecordTypeId = RevSys_StaticUtility.EMPCERT_SPARTNCERT_RECTYPE_ID;
		emCertificationList.add(emCertification);

		emCertification = new EmployeeCertification__c();
		emCertification.Employee__c = employee.Id;
		emCertification.Certification__c = certificate.Id;
		emCertification.ExpirationDate__c = System.today().addDays(90);
		emCertification.Status__c = 'Current';
		emCertification.ProcessFlag__c  = Label.RevSys_EmpCert_ProcessFlag;
        emCertification.RecordTypeId = RevSys_StaticUtility.EMPCERT_SPARTNCERT_RECTYPE_ID;
		emCertificationList.add(emCertification);


		emCertification = new EmployeeCertification__c();
		emCertification.Employee__c = employee.Id;
		emCertification.Certification__c = certificate.Id;
		emCertification.ExpirationDate__c = System.today().addDays(30);
		emCertification.Status__c = 'Current';
		emCertification.EmailStatus__c = 'Test';
		emCertification.ProcessFlag__c  = Label.RevSys_EmpCert_ProcessFlag;
        emCertification.RecordTypeId = RevSys_StaticUtility.EMPCERT_SPARTNCERT_RECTYPE_ID;
		emCertificationList.add(emCertification);
        
		insert emCertificationList;

	
		Test.startTest();
    		RevSys_EmployeeCertification_Batch myJob = new RevSys_EmployeeCertification_Batch(); 

    		String sch = '00 03 * * * ? *';
    		String jobID = system.schedule('Test'+Math.random(),sch, myJob); 

    		List<AsyncApexJob> jobInfo = [SELECT Status,NumberOfErrors, jobitemsprocessed, totalJobItems FROM AsyncApexJob];
    		AsyncApexJob apexJob;
    		if(jobInfo!=null && jobInfo.size()!=0) {
    			apexJob = jobInfo.get(0);
    			List<Messaging.SingleEmailMessage> errorEmails = myJob.generateErrorEmail(apexJob);
    			System.assertEquals(1, errorEmails.size());
    		}
	
		Test.stopTest();
	}



    public static testMethod void testBatch4() {

        Contact employee = new Contact
        (
            LastName            ='Employee', 
            FirstName           ='Amy', 
            Department          = 'Mechanical',
            Employment_Status__c = 'Active',
            Craft__c            = 'Test Craft2',
            Personnel_Number__c = 1234,
            Email               = 'test.test@amtrak.com'
        );
        insert employee;

        Contact supervisor = new Contact
        (
            LastName            ='Supervisor', 
            FirstName           ='John', 
            Department          = 'Mechanical',
            Employment_Status__c = 'Active',
            Craft__c            = 'Test Craft2',
            Personnel_Number__c = 12345
            //Email               = 'super.test@amtrak.com'  
        );
        insert supervisor;

        Contact manager = new Contact
        (
            LastName            ='Manager', 
            FirstName           ='Ned', 
            Department          = 'Mechanical',
            Employment_Status__c = 'Active',
            Craft__c            = 'Test Craft2',
            Personnel_Number__c = 123456,
            Email               = 'manager.test@amtrak.com'
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


        //Amtrak PH
        EPW_Position_Hierarchy__c amtrakPH = new EPW_Position_Hierarchy__c
        (   RecordTypeId = Revsys_StaticUtility.POSITION_HIERARCHY_AMTRAK_RECTYPE_ID, 
            EPW_Position_Organization__c = Org1.Id,
            Name = 'Leve1 Supervisor A',
            EPW_Position_ID__c =  '10000000',
            EPW_Status__c = 'Active',
            EPW_Dept_Code_Description__c = 'Transportation'
        );
        insert amtrakPH;

        EPW_Hierarchy_Assignment__c amtrakHA = new EPW_Hierarchy_Assignment__c
        ( 
            EPW_Contact__c = manager.Id,
            EPW_Position_Hierarchy__c = amtrakPH.Id,
            EPW_Status__c = 'Active'
        );
        insert amtrakHA;

        EPW_Position_Hierarchy__c amtrakPH2 = new EPW_Position_Hierarchy__c
        (   RecordTypeId = Revsys_StaticUtility.POSITION_HIERARCHY_AMTRAK_RECTYPE_ID, 
            EPW_Position_Organization__c = Org1.Id,
            EPW_Parent_Position_Hierarchy__c = amtrakPH.Id,
            Name = 'Leve2 Employee A',
            EPW_Position_ID__c =  '1000',
            EPW_Status__c = 'Active',
            EPW_Dept_Code_Description__c = 'Transportation'
        );
        insert amtrakPH2;

        EPW_Hierarchy_Assignment__c amtrakHA2 = new EPW_Hierarchy_Assignment__c
        ( 
            EPW_Contact__c = employee.Id,
            EPW_Position_Hierarchy__c = amtrakPH2.Id,
            EPW_Status__c = 'Active'
        );
        insert amtrakHA2; 

        OccupationCertification__c certificate = new OccupationCertification__c();
        certificate.Status__c='Active';
        certificate.Name='Certificate1';
        certificate.RecordTypeId = RevSys_StaticUtility.OCCUPCERTIFICATION_SPARTNCERT_RECTYPE_ID;
        certificate.Frequency__c='Days';
        certificate.LengthOfPeriod__c=1;
        insert certificate;

        OccupationRequirement__c req= new OccupationRequirement__c();
        req.RecordTypeId = RevSys_StaticUtility.OCCREQUIREMENT_SPARTNREQUIREMENT_RECTYPE_ID;
        req.Name = 'Requirement Name';
        req.Source__c= 'Employee Result Summary';
        req.SourceRecordType__c = 'Medical, Hearing and Vision';
        req.SourceTestType__c = 'Medical Examination';
        req.Status__c = 'Active';
        insert req;

        OccupationSpecificRequirement__c osr = new OccupationSpecificRequirement__c();
        osr.RecordTypeId = RevSys_StaticUtility.OCCSPECREQUIREMENT_SPARTNCERT_RECTYPE_ID;
        osr.Certification__c = certificate.Id;
        osr.Requirement__c = req.Id;
        osr.Frequency__c = 'Days';
        osr.LengthOfPeriod__c = 10;
        insert osr;

        List<EmployeeCertification__c> emCertificationList = new List<EmployeeCertification__c>();
        EmployeeCertification__c emCertification = new EmployeeCertification__c();
        emCertification.Employee__c = employee.Id;
        emCertification.Certification__c = certificate.Id;
        //emCertification.ExpirationDate__c = (System.today()).addDays(-30);
        emCertification.ExpirationDate__c = System.today();
        emCertification.Status__c = 'Current';
        emCertification.ProcessFlag__c  = Label.RevSys_EmpCert_ProcessFlag;
        emCertification.RecordTypeId = RevSys_StaticUtility.EMPCERT_SPARTNCERT_RECTYPE_ID;
        emCertificationList.add(emCertification);

        emCertification = new EmployeeCertification__c();
        emCertification.Employee__c = employee.Id;
        emCertification.Certification__c = certificate.Id;
        emCertification.ExpirationDate__c =System.today().addDays(60);
        emCertification.Status__c = 'Current';
        emCertification.ProcessFlag__c  = Label.RevSys_EmpCert_ProcessFlag;
        emCertification.RecordTypeId = RevSys_StaticUtility.EMPCERT_SPARTNCERT_RECTYPE_ID;
        emCertificationList.add(emCertification);

        emCertification = new EmployeeCertification__c();
        emCertification.Employee__c = employee.Id;
        emCertification.Certification__c = certificate.Id;
        emCertification.ExpirationDate__c = System.today().addDays(90);
        emCertification.Status__c = 'Current';
        emCertification.ProcessFlag__c  = Label.RevSys_EmpCert_ProcessFlag;
        emCertification.RecordTypeId = RevSys_StaticUtility.EMPCERT_SPARTNCERT_RECTYPE_ID;
        emCertificationList.add(emCertification);


        emCertification = new EmployeeCertification__c();
        emCertification.Employee__c = employee.Id;
        emCertification.Certification__c = certificate.Id;
        emCertification.ExpirationDate__c = System.today().addDays(30);
        emCertification.Status__c = 'Current';
        emCertification.EmailStatus__c = 'Test';
        emCertification.ProcessFlag__c  = Label.RevSys_EmpCert_ProcessFlag;
        emCertification.RecordTypeId = RevSys_StaticUtility.EMPCERT_SPARTNCERT_RECTYPE_ID;
        emCertificationList.add(emCertification);
        
        insert emCertificationList;

    
        Test.startTest();
            RevSys_EmployeeCertification_Batch myJob = new RevSys_EmployeeCertification_Batch(); 

            String sch = '00 03 * * * ? *';
            String jobID = system.schedule('Test'+Math.random(),sch, myJob); 

            List<AsyncApexJob> jobInfo = [SELECT Status,NumberOfErrors, jobitemsprocessed, totalJobItems FROM AsyncApexJob];
            AsyncApexJob apexJob;
            if(jobInfo!=null && jobInfo.size()!=0) {
                apexJob = jobInfo.get(0);
                List<Messaging.SingleEmailMessage> errorEmails = myJob.generateErrorEmail(apexJob);
                System.assertEquals(1, errorEmails.size());
            }
    
        Test.stopTest();
    }

}
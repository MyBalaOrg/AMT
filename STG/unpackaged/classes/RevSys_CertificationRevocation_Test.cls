/**
*___________________________________________________
*@Name: RevSys_CertificationRevocation_Test
*@Author: Hemanth Kesapragada
*@Created: Date: 02/22/2018
*@Used_By: SPARTN
*___________________________________________________
*@Description: Test class for RevSys_CertificationRevocationHelper class
* 
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/
@isTest
public class RevSys_CertificationRevocation_Test {
	
	@TestSetup
	public static void loadTestData() {

        SPARTN_BypassRuleSettings__c orgsettings = SPARTN_BypassRuleSettings__c.getOrgDefaults();  
        orgsettings.ValidationRules__c = true; 
        upsert orgsettings SPARTN_BypassRuleSettings__c.Id;   

        SPARTN_Custom_Settings__c setting = new SPARTN_Custom_Settings__c();  
        setting.Name = 'Emp Cert: Num Days to Check for Reqs';
        setting.CsvString__c = '1200';    
        insert setting;

        setting = new SPARTN_Custom_Settings__c();  
        setting.Name = 'Earliest Amtrak Date';
        setting.CsvString__c = '1971-10-30';    
        insert setting;

        Contact c = new Contact();
        c.FirstName = 'Test1';
        c.LastName = 'Test LastName';
        c.Employment_Status__c='Active';
        c.Department= 'Engineering';

        Contact c2 = new Contact();
        c2.FirstName = 'Test2';
        c2.LastName = 'Test LastName';
        c2.Employment_Status__c='Active';
        c2.Department= 'Engineering';
        insert new List<Contact>{c, c2};

        OccupationCertification__c oc = new OccupationCertification__c();
        oc.Status__c = RevSys_StaticUtility.ACTIVE;
        oc.Name = 'Test OC';
        oc.RecordTypeId = RevSys_StaticUtility.OCCUPCERTIFICATION_SPARTNCERT_RECTYPE_ID;
        oc.Frequency__c = 'Months';
        oc.LengthOfPeriod__c = 10;

        OccupationCertification__c oc2 = new OccupationCertification__c();
        oc2.Status__c = RevSys_StaticUtility.ACTIVE;
        oc2.Name = 'Test OC2';
        oc2.RecordTypeId = RevSys_StaticUtility.OCCUPCERTIFICATION_SPARTNCERT_RECTYPE_ID;
        oc2.Frequency__c = 'Months';
        oc2.LengthOfPeriod__c = 10;
        insert new List<OccupationCertification__c>{oc, oc2};

        OccupationRequirement__c oreq = new OccupationRequirement__c();
        oreq.Status__c =  RevSys_StaticUtility.ACTIVE;
        oreq.RecordTypeId = RevSys_StaticUtility.OCCREQUIREMENT_SPARTNREQUIREMENT_RECTYPE_ID;
        oreq.Name =  'Test Requirement';
        oreq.Source__c = 'Observation';
        oreq.SourceRecordType__c = 'FORM-1872';
        oreq.TestNumber__c ='TestNumber';
        oreq.TestName__c ='101';
        insert oreq;

        OccupationSpecificRequirement__c osr  =  new OccupationSpecificRequirement__c();
        osr.RecordTypeId    = RevSys_StaticUtility.OCCSPECREQUIREMENT_SPARTNCERT_RECTYPE_ID;
        osr.Status__c       = RevSys_StaticUtility.ACTIVE;
        osr.Frequency__c = 'Days';
        osr.LengthOfPeriod__c = 1;
        osr.Certification__c = oc.Id;
        osr.Requirement__c = oreq.Id;
        insert osr;

        EmployeeCertification__c ecRecord = new EmployeeCertification__c();
        ecRecord.Status__c = RevSys_StaticUtility.PENDING;
        ecRecord.Employee__c = c.Id;
        ecRecord.Certification__c = oc.Id;
        ecRecord.Archived__c = FALSE;
        ecRecord.RecordTypeId = RevSys_StaticUtility.EMPCERT_SPARTNCERT_RECTYPE_ID;

        EmployeeCertification__c ecRecord2 = new EmployeeCertification__c();
        ecRecord2.Status__c = RevSys_StaticUtility.PENDING;
        ecRecord2.Employee__c = c2.Id;
        ecRecord2.Certification__c = oc.Id;
        ecRecord2.Archived__c = FALSE;
        ecRecord2.RecordTypeId = RevSys_StaticUtility.EMPCERT_SPARTNCERT_RECTYPE_ID;

        EmployeeCertification__c ecRecord3 = new EmployeeCertification__c();
        ecRecord3.Status__c = RevSys_StaticUtility.PENDING;
        ecRecord3.Employee__c = c2.Id;
        ecRecord3.Certification__c = oc2.Id;
        ecRecord3.Archived__c = FALSE;
        ecRecord3.RecordTypeId = RevSys_StaticUtility.EMPCERT_SPARTNCERT_RECTYPE_ID;
        insert new List<EmployeeCertification__c>{ecRecord, ecRecord2, ecRecord3};

        CertificationRevocation__c revRec = new CertificationRevocation__c();
        revRec.Status__c = 'Active';
        revRec.IncidentDate__c  = System.today().addMonths(-5);
        revRec.Description__c = 'This is test';
        revRec.EmployeeCertification__c = ecRecord.Id;
        revRec.PerformingAs__c = 'Conductor'; 
        revRec.TrackType__c = 'Main Track';
        revRec.RevocationBeginDate__c = System.today().addMonths(-5);

        CertificationRevocation__c revRec2 = new CertificationRevocation__c();
        revRec2.Status__c = 'Active';
        revRec2.IncidentDate__c  = System.today().addMonths(-5);
        revRec2.Description__c = 'This is test';
        revRec2.EmployeeCertification__c = ecRecord2.Id;
        revRec2.PerformingAs__c = 'Conductor'; 
        revRec2.TrackType__c = 'Main Track';
        revRec2.Violation__c = Label.RevSys_Off_Duty_Drug_Violation;
        
        CertificationRevocation__c revRec3 = new CertificationRevocation__c();
        revRec3.Status__c = 'Active';
        revRec3.IncidentDate__c  = System.today().addMonths(-3);
        revRec3.Description__c = 'This is non-main track revocation';
        revRec3.EmployeeCertification__c = ecRecord3.Id;
        revRec3.PerformingAs__c = 'Conductor'; 
        revRec3.TrackType__c = Label.RevSys_Track_Type_None_Main_Track;
        revRec3.RevocationBeginDate__c = System.today().addMonths(-3);
        revRec3.Violation__c = 'Shoving Movements';
        insert new List<CertificationRevocation__c>{revRec, revRec2, revRec3};
        
        
	}

	public static testMethod void testEmployeeCertificationStatus() {

        EmployeeCertification__c ec = [Select RevocationBeginDate__c,RevocationEndDate__c,Status__c,ProcessFlag__c from EmployeeCertification__c Where Employee__r.FirstName='Test1' Limit 1];
        ec.RevocationBeginDate__c = System.today().addDays(1);
        ec.RevocationEndDate__c = System.today().addDays(2);
        ec.ProcessFlag__c = Label.RevSys_EmpCert_ProcessFlag;
        update ec;
		

		CertificationRevocation__c cerRev = [Select Id,Status__c,IncidentDate__c from CertificationRevocation__c Limit 1];
		cerRev.Status__c = 'Inactive';
		update cerRev;

		EmployeeCertification__c empCert = [Select Id,Status__c from EmployeeCertification__c limit 1];
		System.assertEquals('Expired',empCert.Status__c);
	}

	public static testMethod void testProcessRevocations() {
        
        system.debug('----------------------------------This is process');
        Test.startTest(); 
		EmployeeCertification__c empCert = [Select Id,Status__c,InitialIncidentDate__c,ProbationEndDate__c,RevocationBeginDate__c from EmployeeCertification__c Where Employee__r.FirstName='Test1' limit 1];
	//	System.assertEquals(RevSys_StaticUtility.REVOKED,empCert.Status__c);
		//System.assertEquals(System.today().addMonths(24),empCert.ProbationEndDate__c);
		System.assertEquals(empCert.RevocationBeginDate__c.addMonths(36),empCert.ProbationEndDate__c);

        List<CertificationRevocation__c> revList = new List<CertificationRevocation__c>();
        
		CertificationRevocation__c revRec2 = new CertificationRevocation__c();
        revRec2.Status__c = 'Active';
        revRec2.IncidentDate__c  = System.today().addDays(1);
        revRec2.Description__c = 'This is my Second Revocation record';
        revRec2.EmployeeCertification__c = empCert.Id;
        revRec2.PerformingAs__c = 'Conductor'; 
        revRec2.TrackType__c = 'Main Track';
        revRec2.RevocationBeginDate__c = System.today();


        CertificationRevocation__c revRec3 = new CertificationRevocation__c();
        revRec3.Status__c = 'Active';
        revRec3.IncidentDate__c  = System.today().addDays(2);
        revRec3.Description__c = 'Rev3';
        revRec3.EmployeeCertification__c = empCert.Id;
        revRec3.PerformingAs__c = 'Conductor'; 
        revRec3.TrackType__c = 'Main Track';
        revRec3.RevocationBeginDate__c = System.today();

        CertificationRevocation__c revRec4 = new CertificationRevocation__c();
        revRec4.Status__c = 'Active';
        revRec4.IncidentDate__c  = System.today().addDays(3);
        revRec4.Description__c = 'Rev4';
        revRec4.EmployeeCertification__c = empCert.Id;
        revRec4.PerformingAs__c = 'Conductor'; 
        revRec4.TrackType__c = 'Main Track';
        revRec4.RevocationBeginDate__c = System.today();
       
        revList.add(revRec4);
        revList.add(revRec3);
        revList.add(revRec2);
        insert revList;
        

        Test.stopTest();

        //RevSys_CertificationRevocationHelper.processRevocation(revList);

        CertificationRevocation__c rev = [Select RevocationEndDate__c from CertificationRevocation__c where Description__c='Rev4'];
       	empCert = [Select Id,Status__c,InitialIncidentDate__c,RevocationBeginDate__c,RevocationEndDate__c,ProbationEndDate__c from EmployeeCertification__c where Id=:empCert.Id limit 1];
		System.assertEquals(RevSys_StaticUtility.REVOKED,empCert.Status__c);
        System.assertEquals(rev.RevocationEndDate__c,empCert.RevocationEndDate__c);
       
	}

    public static testMethod void testDelete() {

        EmployeeCertification__c ec = [Select RevocationBeginDate__c,RevocationEndDate__c,Status__c,ProcessFlag__c from EmployeeCertification__c where Certification__r.Name = 'Test OC2' Limit 1];
        ec.RevocationBeginDate__c = System.today().addMonths(-1);
        ec.ProbationEndDate__c = System.today().addDays(-2);
        ec.ProcessFlag__c = Label.RevSys_EmpCert_ProcessFlag;
        update ec;
        
        CertificationRevocation__c revRec = new CertificationRevocation__c();
        revRec.Status__c = 'Active';
        revRec.IncidentDate__c  = System.today();
        revRec.Description__c = 'second off duty revocation';
        revRec.EmployeeCertification__c = ec.Id;
        revRec.PerformingAs__c = 'Conductor'; 
        revRec.TrackType__c = Label.RevSys_Track_Type_Main_Track;
        revRec.RevocationBeginDate__c = System.today();
        revRec.Violation__c = 'Speeding';
        insert revRec;

        List<CertificationRevocation__c> cerRevList = [Select Id,Status__c,IncidentDate__c from CertificationRevocation__c where EmployeeCertification__c = :ec.Id];
        delete cerRevList;

        ec = [Select Id,Status__c, RevocationBeginDate__c,RevocationEndDate__c from EmployeeCertification__c where Id = :ec.Id limit 1];
    //    System.assertEquals(null,ec.RevocationBeginDate__c);
    }

    public static testMethod void testDrugViolations() {

        SPARTN_BypassRuleSettings__c orgsettings = SPARTN_BypassRuleSettings__c.getOrgDefaults();  
        orgsettings.ValidationRules__c = true; 
        upsert orgsettings SPARTN_BypassRuleSettings__c.Id;   

        EmployeeCertification__c ec = [Select RevocationBeginDate__c,RevocationEndDate__c,Status__c,ProcessFlag__c from EmployeeCertification__c Where Employee__r.FirstName='Test2' And Certification__r.Name = 'Test OC' Limit 1];

        Test.startTest(); 

        CertificationRevocation__c revRec = new CertificationRevocation__c();
        revRec.Status__c = 'Active';
        revRec.IncidentDate__c  = System.today().addMonths(-2);
        revRec.Description__c = 'on duty revocation';
        revRec.EmployeeCertification__c = ec.Id;
        revRec.PerformingAs__c = 'Conductor'; 
        revRec.TrackType__c = Label.RevSys_Track_Type_None_Main_Track;
        revRec.RevocationBeginDate__c = System.today().addMonths(-2);
        revRec.Violation__c = Label.RevSys_On_Duty_Drug_Alcohol_Violation;

        CertificationRevocation__c revRec2 = new CertificationRevocation__c();
        revRec2.Status__c = 'Active';
        revRec2.IncidentDate__c  = System.today().addMonths(-1);
        revRec2.Description__c = 'second off duty revocation';
        revRec2.EmployeeCertification__c = ec.Id;
        revRec2.PerformingAs__c = 'Conductor'; 
        revRec2.TrackType__c = Label.RevSys_Track_Type_None_Main_Track;
        revRec2.RevocationBeginDate__c = System.today().addMonths(-1);
        revRec2.Violation__c = Label.RevSys_Off_Duty_Drug_Violation;

        CertificationRevocation__c revRec3 = new CertificationRevocation__c();
        revRec3.Status__c = 'Active';
        revRec3.IncidentDate__c  = System.today();
        revRec3.Description__c = 'second off duty revocation';
        revRec3.EmployeeCertification__c = ec.Id;
        revRec3.PerformingAs__c = 'Conductor'; 
        revRec3.TrackType__c = Label.RevSys_Track_Type_Main_Track;
        revRec3.RevocationBeginDate__c = System.today();
        revRec3.Violation__c = 'Speeding';
        insert new List<CertificationRevocation__c>{revRec, revRec2, revRec3};

        Test.stopTest();
        delete revRec3;

        EmployeeCertification__c empCert = [Select Id,Status__c, RevocationBeginDate__c,RevocationEndDate__c from EmployeeCertification__c limit 1];
        revRec = [Select Id, RevocationEndDate__c From CertificationRevocation__c Where Id = :revRec.Id limit 1];
        System.debug('=====> test empCert: ' + empCert.RevocationEndDate__c);
        System.debug('=====> test revRec: ' + revRec.RevocationEndDate__c);
    }

    public static testmethod void testErrorMessage(){
        Test.startTest();
        RevSys_CertificationRevocationHandler.DoFailTest = TRUE;
        try{
            EmployeeCertification__c empCert = [Select Id,Status__c,InitialIncidentDate__c,ProbationEndDate__c from EmployeeCertification__c limit 1];
            CertificationRevocation__c revRec = new CertificationRevocation__c();
            revRec.Status__c = 'Active';
            revRec.IncidentDate__c  = System.today().addDays(3);
            revRec.Description__c = 'Rev';
        	revRec.EmployeeCertification__c = empCert.Id;
        	revRec.PerformingAs__c = 'Conductor'; 
            revRec.TrackType__c = 'Main Track';
            revRec.RevocationBeginDate__c = System.today().addDays(3);
            
            insert revRec;
         }catch(Exception e){
            Boolean b = e.getMessage().contains('Error')?true:false;
                System.assertEquals(true,b);
        }

    }
    
}
//Lakshmi 1/17/2018 -Changes to fix ARSS-142
@isTest
public class EIS_TestDataUtils {
    public static List<String> logisticActivities = StaticUtils.getPicklistValues(Logistic__c.EIS_Activity__c.getDescribe());
    public static List<String> logisticSources = StaticUtils.getPicklistValues(Logistic__c.EIS_Source__c.getDescribe());
    public static List<String> logisticSubRegions = StaticUtils.getPicklistValues(Logistic__c.EIS_eGRID_Subregion__c.getDescribe());
    public static List<String> logisticScopes = StaticUtils.getPicklistValues(Logistic__c.EIS_Scope__c.getDescribe());
    public static Map<String, List<String>> logisticSourceTypeMap = StaticUtils.getDependentOptionsImpl(Logistic__c.EIS_Source_Type__c.getDescribe().getSObjectField(), 
                                                                                                        Logistic__c.EIS_Source__c.getDescribe().getSObjectField());
    
    public static List<EIS_Questions__mdt> getMetadataQuestionList(String metaFormType) {
        List<EIS_Questions__mdt> metaQuestions = [
            SELECT Id, Question__c, Sr_No__c, Weightage__c, Criticality__c, Section_Name__c
            FROM EIS_Questions__mdt
            WHERE Form__c = :metaFormType
            ORDER BY Section_Name__c ASC, Sr_No__c ASC
        ];
        return metaQuestions;
    }
    
    public static User createAmtrakUser(String pSetName) {
        User testUser;
        User admin = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(admin) {
            Profile prfl = [SELECT Id FROM Profile WHERE Name = :Label.EIS_Profile_Label_Amtrak_Employee];
            testUser = new User(  
                FirstName = 'Dry',
                LastName = 'Tuna',
                Email = 'drytuna' + '@testdrytuna.org',
                Username = 'drytuna' + '@testdrytuna.org',
                EmailEncodingKey = 'ISO-8859-1',
                Alias = 'drytuna',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US',
                ProfileId = prfl.Id
            );
            insert testUser;
            
            if (String.isBlank(pSetName)) {
                pSetName = Label.EIS_Permission_Set_API_EMA;
            }
            PermissionSet pSet = [SELECT Id, Label, Name FROM PermissionSet WHERE Name = :pSetName];
            PermissionSetAssignment psa = new PermissionSetAssignment(
                PermissionSetId = pSet.Id, 
                AssigneeId = testUser.Id
            );
            insert psa;
        }
        return testUser;
    }
    
    public static Account createAccount(String name) {
        if (String.isEmpty(name)) {
            name = 'YnD Corp';
        }
        Account acc = new Account(Name = name); 
        insert acc;
        return acc;
    }
    
    public static Contact createInternalContact(Account acc) {
        if (acc == null) {
            acc = createAccount(null);
        }
        Contact emp = new Contact(
        	FirstName = 'Dry',
            LastName = 'Tuna',
            Employee_Type__c = 'Internal',
            Email = 'empdrytuna@test.org',
            Account = acc
        );
        insert emp;
        return emp;
    }
    
    public static Location__c createMainLocation() {
        Location__c loc = new Location__c(
        	RecordTypeId = EIS_StaticUtils.LOCATION_MAIN_RTID,
            Name = 'Hello Kitty Island'
        );
        insert loc;
        return loc;
    }
    
    public static Site__c createMainSite(Location__c location) {
        if (location == null) {
            location = createMainLocation();
        }
        Site__c site = new Site__c (
        	RecordTypeId = EIS_StaticUtils.SITE_MAIN_RTID,
            EIS_Site_Location__c = location.Id,
            EIS_Audit_Eligible__c = true,
            Name = 'Hello Kitty Island Adventure'
        );
        insert site;
        return site;
    }
    
    public static Site__c createMainFacility(Site__c site) {
        if (site == null) {
            site = createMainSite(null);
        }
        Site__c facility = new Site__c (
        	RecordTypeId = EIS_StaticUtils.FACILITY_MAIN_RTID,
            EIS_Facility_Site_Name__c = site.Id,
            EIS_Active__c = true,
            Name = 'Hello Kitty Island Facility'
        );
        insert facility;
        return facility;
    }
    
    public static Contact_List__c createContactList(Contact cont, Site__c site, String type) {
        if (cont == null) {
            cont = createInternalContact(null);
        }
        if (site == null) {
            site = createMainSite(null);
        }
        if (String.isEmpty(type)) {
            type = 'Agency';
        }
        Contact_List__c contactList = new Contact_List__c(
        	EIS_Contact__c = cont.Id, 
            EIS_Site__c = site.Id, 
            EIS_Type__c = type, 
            RecordTypeId = Schema.SObjectType.Contact_List__c.getRecordTypeInfosByName().get(Label.EIS_Contact_List_AEPHIS_Site_Record_Type_Label).getRecordTypeId()
        );
        insert contactList;
        return contactList;
    }
    
    public static Audit_Inspections__c createInspection(Site__c facility, Contact emp, Id recordTypeId) {
        if (facility == null) {
            facility = createMainFacility(null);
        }
        if (emp == null) {
            emp = createInternalContact(null);
        }
        if (recordTypeId == null) {
            recordTypeId = EIS_StaticUtils.INSPECTION_COMMISSARY_RTID;
        }
        Audit_Inspections__c ai = new Audit_Inspections__c(
            RecordTypeId = recordTypeId, 
            PH_Facility__c = facility.Id, 
            Inspected_By__c = emp.Id
        );
		insert ai;        
        return ai;
    }
    
    public static Audit_Inspections__c createAuditSFA(Site__c site, Contact emp, Id recordTypeId) {
        if (site == null) {
            site = createMainSite(null);
        }
        if (emp == null) {
            emp = createInternalContact(null);
        }
        if (recordTypeId == null) {
            recordTypeId = EIS_StaticUtils.INSPECTION_AUDIT_FORM_RTID;
        }
        if (recordTypeId == EIS_StaticUtils.INSPECTION_AUDIT_FORM_RTID) {
            site.EIS_Audit_Eligible__c = true;
            update site;
        } else {
            site.EIS_Audit_Eligible__c = false;
            update site;
        }
        Audit_Inspections__c ai = new Audit_Inspections__c(
            RecordTypeId = recordTypeId, 
            EIS_Site__c = site.Id, 
            EIS_Auditor_1__c = emp.Id
        );
		insert ai;        
        return ai;
    }
    
	public static List<Audit_Inspections__c> createInspectionList(Site__c facility, Contact emp) {
        if (facility == null) {
            facility = createMainFacility(null);
        }
        if (emp == null) {
            emp = createInternalContact(null);
        }
        List<Audit_Inspections__c> inspections = new List<Audit_Inspections__c>();
        inspections.add(new Audit_Inspections__c(RecordTypeId = EIS_StaticUtils.INSPECTION_COMMISSARY_RTID, PH_Facility__c = facility.Id, Inspected_By__c = emp.Id));
        inspections.add(new Audit_Inspections__c(RecordTypeId = EIS_StaticUtils.INSPECTION_WATERPOINT_RTID, PH_Facility__c = facility.Id, Inspected_By__c = emp.Id));
        inspections.add(new Audit_Inspections__c(RecordTypeId = EIS_StaticUtils.INSPECTION_VENDOR_RTID, PH_Facility__c = facility.Id, Inspected_By__c = emp.Id));
        inspections.add(new Audit_Inspections__c(RecordTypeId = EIS_StaticUtils.INSPECTION_FOOD_CAR_RTID, PH_Facility__c = facility.Id, Inspected_By__c = emp.Id));
        insert inspections;
        return inspections;
    }
    
    public static Questions__c createInspectionQuestion(Audit_Inspections__c inspection, String criticality) {
        if (inspection == null || String.isBlank(inspection.Id)) {
            inspection = createInspection(null, null, null);
        }
        if (String.isBlank(criticality)) {
            criticality = Label.EIS_Questions_Criticality_Critical;
        }
        Questions__c question = new Questions__c(
        	RecordTypeId = EIS_StaticUtils.QUESTIONS_INSPECTION_RTID,
            Audit_Inspections__c = inspection.Id, 
            EIS_Criticality__c = criticality, 
            Points__c = 5
        );
        insert question;
        return question;
    }
    
    public static List<Questions__c> createInspectionQuestionList(List<Audit_Inspections__c> inspections) {
        if (inspections == null || inspections.size() == 0) {
            inspections = createInspectionList(null, null);
        }
        List<Questions__c> questions = new List<Questions__c>();
        for (Audit_Inspections__c ai : inspections) {
            questions.add(new Questions__c(
                RecordTypeId = EIS_StaticUtils.QUESTIONS_INSPECTION_RTID, 
                Audit_Inspections__c = ai.Id, 
                EIS_Criticality__c = Label.EIS_Questions_Criticality_Critical, 
                Points__c = 5
            ));
            questions.add(new Questions__c(
                RecordTypeId = EIS_StaticUtils.QUESTIONS_INSPECTION_RTID, 
                Audit_Inspections__c = ai.Id, 
                EIS_Criticality__c = Label.EIS_Questions_Criticality_Non_Critical, 
                points__c = 2));
        }
        insert questions;
        return questions;
    }
    
    public static Finding__c createInspectionFinding(Questions__c question) {
        if (question == null || String.isBlank(question.Id)) {
            question = createInspectionQuestion(null, null);
        }
        Finding__c finding = new Finding__c(RecordTypeId = EIS_StaticUtils.FINDING_INSPECTION_RTID, Question__c = question.Id);
        insert finding;
        Corrective_Action__c ca = new Corrective_Action__c(
            RecordTypeId = EIS_StaticUtils.CORRECTIVEACTION_INSPECTION_RTID, 
            EIS_Finding__c = finding.Id, 
            EIS_Due_Date__c = Date.Today(),
            EIS_Status__c = Label.EIS_Corrective_Action_Status_Not_Started
        );
        insert ca;
        return finding;
    }
    
    public static List<Finding__c> createInspectionFindingList(List<Questions__c> questions) {
        if (questions == null || questions.size() == 0) {
            questions = createInspectionQuestionList(null);
        }
        List<Finding__c> findings = new List<Finding__c>();
        for (Questions__c q : questions) {
            findings.add(new Finding__c(RecordTypeId = EIS_StaticUtils.FINDING_INSPECTION_RTID, Question__c = q.Id));
            findings.add(new Finding__c(RecordTypeId = EIS_StaticUtils.FINDING_INSPECTION_RTID, Question__c = q.Id));
        }
        insert findings;
        return findings;
    }
    
    public static Corrective_Action__c createInspectionCorrectiveAction(Finding__c finding) {
        if (finding == null || String.isBlank(finding.Id)) {
            finding = createInspectionFinding(null);
        }
        Corrective_Action__c ca = new Corrective_Action__c(
            RecordTypeId = EIS_StaticUtils.CORRECTIVEACTION_INSPECTION_RTID, 
            EIS_Finding__c = finding.Id, 
            EIS_Status__c = Label.EIS_Corrective_Action_Status_Not_Started
        );
        insert ca;
        return ca;
    }
    
    public static List<Corrective_Action__c> createInspectionCorrectiveActionList(List<Finding__c> findings) {
        if (findings == null || findings.size() == 0) {
            findings = createInspectionFindingList(null);
        }
        List<Corrective_Action__c> caList = new List<Corrective_Action__c>();
        for (Finding__c f : findings) {
            caList.add(new Corrective_Action__c(RecordTypeId = EIS_StaticUtils.CORRECTIVEACTION_INSPECTION_RTID, EIS_Finding__c = f.Id, EIS_Status__c = Label.EIS_Corrective_Action_Status_Not_Started));
            caList.add(new Corrective_Action__c(RecordTypeId = EIS_StaticUtils.CORRECTIVEACTION_INSPECTION_RTID, EIS_Finding__c = f.Id, EIS_Status__c = Label.EIS_Corrective_Action_Status_In_Progress));
            caList.add(new Corrective_Action__c(RecordTypeId = EIS_StaticUtils.CORRECTIVEACTION_INSPECTION_RTID, EIS_Finding__c = f.Id, EIS_Status__c = Label.EIS_Corrective_Action_Status_Correct));
            caList.add(new Corrective_Action__c(RecordTypeId = EIS_StaticUtils.CORRECTIVEACTION_INSPECTION_RTID, EIS_Finding__c = f.Id, EIS_Status__c = Label.EIS_Corrective_Action_Status_Fail_Correction));
        }
        insert caList;
        return caList;
    }
    
    public static Bypass_Trigger_Settings__c getBypassTriggerSettings() {
        Bypass_Trigger_Settings__c bts = new Bypass_Trigger_Settings__c(
        	CorrectiveActionTrigger__c = false,
            IncidentsTrigger__c = false,
            PermitTrigger__c = false,
            QuestionsTrigger__c = false,
            TaskTrigger__c = false,
            WasteEmissionsTrigger__c = false
        );
        insert bts;
        return bts;
    }
    
    public static void insertCustomSettings() {
        List<AEPHIS_Settings__c> aephisList = new List<AEPHIS_Settings__c>();
        aephisList.add(new AEPHIS_Settings__c(Name = 'Initial GeoLocator Start Date', EIS_Text_Value__c = '01-01-1970'));
        aephisList.add(new AEPHIS_Settings__c(Name = 'Inspection Correction Deadline', EIS_Integer_Value__c = 9));
        aephisList.add(new AEPHIS_Settings__c(Name = 'Question Point: Potential Violation', EIS_Integer_Value__c = 4));
        aephisList.add(new AEPHIS_Settings__c(Name = 'Question Point: Management Practice', EIS_Integer_Value__c = 2));
        aephisList.add(new AEPHIS_Settings__c(Name = 'Question Point: Repeat Finding', EIS_Integer_Value__c = 1));
        insert aephisList;
    }
    
    public static Tracking__c createTrackingRecord(ID trackingId,String type) {
        Tracking__c t = new tracking__c();
        t.EIS_Inspection_Form__c = trackingId;
        t.EIS_Location__c = 'Freezer 1';
        t.EIS_Temperature_Type__c = type;
        t.EIS_Temperature__c = 22;
        
        insert t;
        
        return t;
    }
    
    public static List<Logistic__c> createLogisticGHGActivityType() {
        List<Logistic__c> setupLogistics = new List<Logistic__c>();
        for (String activity : logisticActivities) {
            for (String source : logisticSources) {
                for (String sourceType : logisticSourceTypeMap.get(source)) {
                    setupLogistics.add(getActivityTypeLogistic(activity, source, sourceType));
                }
            }
        }
        
        insert setupLogistics;
        return setupLogistics;
    }
    
    public static Logistic__c getActivityTypeLogistic(String activity, String source, String sourceType) {
        Logistic__c logistic = new Logistic__c(
        	RecordTypeId = EIS_StaticUtils.LOGISTIC_GHG_ACTIVITY_TYPE_RTID,
            EIS_Activity__c = activity,
            EIS_Source__c = source,
            EIS_Source_Type__c = sourceType,
            EIS_Scope__c = EIS_TestDataUtils.logisticScopes[0],
            EIS_UOM__c = EIS_TestDataUtils.logisticScopes[0]
        );
        return logistic;
    }
    
    public static Logistic__c getGWPFactorTable() {
        Logistic__c logistic = new Logistic__c(
        	RecordTypeId = EIS_StaticUtils.LOGISTIC_GHG_FACTOR_TABLE_RTID,
            EIS_Electric_Line_Loss__c = 0.5, EIS_Natural_Gas_Line_Loss__c = 0.5, R_407C__c = 0.5, R_408a__c = 0.5, R_409a__c = 0.5, R_410a__c = 0.5, R_502__c = 0.5, 
            SF6__c = 0.5, CH4__c = 0.5, CO2__c = 0.5, N2O__c = 0.5, R_11__c = 0.5, R_12__c = 0.5, R_123__c = 0.5, R_134a__c = 0.5, R_22__c = 0.5, R_27__c = 0.5, 
            R_401a__c = 0.5, R_404a__c = 0.5, R_407a__c = 0.5
        );
        return logistic;
    }
    
    public static Logistic__c getEGridFactorTable(String subregion, Id parentId) {
        Logistic__c logistic = new Logistic__c(
        	RecordTypeId = EIS_StaticUtils.LOGISTIC_GHG_EGRID_TABLE_RTID,
            EIS_eGRID_Subregion__c = subregion, CO2__c = 0.5, CH4__c = 0.5, N2O__c = 0.5, EIS_UOM__c = EIS_TestDataUtils.logisticScopes[0], EIS_Factor_Table__c = parentId
        );
        return logistic;
    }
    
    public static List<Logistic__c> getEmissionFactorTable(Id parentId) {
        List<Logistic__c> emissionFactors = new List<Logistic__c>();
        for (String scope : logisticScopes) {
            for (String source : logisticSources) {
                for (String sourceType : logisticSourceTypeMap.get(source)) {
                    Logistic__c logistic = new Logistic__c(
                        RecordTypeId = EIS_StaticUtils.LOGISTIC_GHG_EMISSION_TABLE_RTID,
                        EIS_Source__c = source, EIS_Source_Type__c = sourceType, EIS_Scope__c = scope,
                        CO2__c = 0.5, CH4__c = 0.5, N2O__c = 0.5, EIS_UOM__c = EIS_TestDataUtils.logisticScopes[0], EIS_Factor_Table__c = parentId
                    );
                    emissionFactors.add(logistic);
                }
            }
        }
        return emissionFactors;
    }
}
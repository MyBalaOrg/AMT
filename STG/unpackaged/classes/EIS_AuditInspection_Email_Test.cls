//Test class for EIS_Onsubmit_Audit_Inspection_Info, EIS_Onsubmit_Inspection_Notification, EIS_SendEmailNotification
@isTest
public class EIS_AuditInspection_Email_Test {
    @testSetup static void setup() {
        try {
            EIS_TestDataUtils.insertCustomSettings();
        } catch (DMLException e) {
            
        }
    }
    
    //Testing EIS_Onsubmit_Audit_Inspection_Info.apxc
    @isTest
    public static void sendInspectorEmail_AuditForm_Test() {
        Site__c site = EIS_TestDataUtils.createMainSite(null);
        Site__c facility = EIS_TestDataUtils.createMainFacility(site);
        Contact cont = EIS_TestDataUtils.createInternalContact(null);
        Contact_List__c contactList = EIS_TestDataUtils.createContactList(cont, site, null);
        
        Test.startTest();
        Audit_Inspections__c audit = EIS_TestDataUtils.createAuditSFA(site, cont, EIS_StaticUtils.INSPECTION_AUDIT_FORM_RTID);
        Schema.DescribeFieldResult fieldResult = EIS_Audit_Question__mdt.Protocol_Name__c.getDescribe();
        audit.EIS_Protocol_Name__c = EIS_Audit_BodyCtrl_Test.setListToString_Semicolon(EIS_StaticUtils.getPicklistValues(fieldResult));
        audit.EIS_Auditor_1__c = cont.Id;
        Questions__c question = EIS_TestDataUtils.createInspectionQuestion(audit, null);
        EIS_Audit_Question__mdt metaQ = [
            SELECT Question_Id__c, Question_Name__c, Qualifier_Name__c, Protocol_Name__c 
            FROM EIS_Audit_Question__mdt 
            WHERE Protocol_Name__c =: audit.EIS_Protocol_Name__c.split(';')[0] ORDER BY Question_Id__c LIMIT 1
        ];
        question.EIS_Metadata_Question_Id__c = metaQ.Question_Id__c;
        question.EIS_Issued__c = false;
        question.EIS_Corrected__c = true;
        question.EIS_Criticality__c = 'critical';
        question.EIS_Question_Text__c = metaQ.Question_Name__c;
        question.EIS_Qualifier_Name__c = metaQ.Qualifier_Name__c;
        question.EIS_Protocol_Name__c = metaQ.Protocol_Name__c;
        update audit;
        update question;
        Finding__c finding = EIS_TestDataUtils.createInspectionFinding(question);
        fieldResult = Finding__c.EIS_Responsible_Department__c.getDescribe();
        List<String> listString = EIS_StaticUtils.getPicklistValues(fieldResult);
        listString.remove(0);
        finding.EIS_Responsible_Department__c = EIS_Audit_BodyCtrl_Test.setListToString_Semicolon(listString);
        update finding;
        Corrective_Action__c ca = EIS_TestDataUtils.createInspectionCorrectiveAction(finding);
        ca.EIS_Status__c = Label.EIS_Corrective_Action_Status_Correct;
        update ca;
        
        List<Audit_Inspections__c> auditList = new List<Audit_Inspections__c>();
        auditList.add(audit);
        
        EIS_Onsubmit_Audit_Inspection_Info.sendAuditorEmail(auditList);
        
        auditList[0].RecordTypeId = EIS_StaticUtils.INSPECTION_SFA_FORM_RTID;
        site.EIS_Audit_Eligible__c = false;
        update site;
        update auditList;
        contactList.EIS_Audit_Specific__c = true;
        update contactList;
        
        EIS_Onsubmit_Audit_Inspection_Info.sendAuditorEmail(auditList);
        Test.stopTest();
    }
    
    //Testing EIS_Onsubmit_Inspection_Notification.apxc
    @isTest
    public static void sendInspectorEmail_InspectionForm_Test() {
        Route__c route = new Route__c(Name = 'YT'); 
        insert route;
        Train__c train = new Train__c(Name = 'YT', Route__c = route.Id);
        insert train;
        Food_Car__c car = new Food_Car__c(Name = 'YT', EIS_Train__c = train.Id, EIS_Food_Car_Type__c = 'Diner');
        insert car;
        
        Site__c site = EIS_TestDataUtils.createMainSite(null);
        Site__c facility = EIS_TestDataUtils.createMainFacility(site);
        Contact cont = EIS_TestDataUtils.createInternalContact(null);
        Contact_List__c contactList = EIS_TestDataUtils.createContactList(cont, facility, null);
        contactList.EIS_Train__c = train.Id;
        update contactList;
        List<Audit_Inspections__c> inspections = EIS_TestDataUtils.createInspectionList(facility, cont);
        for (Integer i = 1; i < inspections.size(); i++) {
            inspections[i].Inspected_By__c = cont.Id;
            inspections[i].PH_Employee_Responsible__c = cont.Id;
            if (inspections[i].RecordTypeId == EIS_StaticUtils.INSPECTION_FOOD_CAR_RTID) {
                inspections[i].EIS_Food_Car__c = car.Id;
                inspections[i].Mech_Critical_Violations__c = 100;
                inspections[i].OBS_Train_Manager__c = cont.Id;
            }
        }
        update inspections;
        List<Questions__c> questions = EIS_TestDataUtils.createInspectionQuestionList(inspections);
        List<Finding__c> findings = EIS_TestDataUtils.createInspectionFindingList(questions);
        List<Corrective_Action__c> caList = EIS_TestDataUtils.createInspectionCorrectiveActionList(findings);
        for (Integer i =0; i < caList.size(); i++) {
            caList[i].EIS_Assigned_To__c = cont.Id;
        }
        update caList;
        
        Test.startTest();
        List<Audit_Inspections__c> testInspections = new List<Audit_Inspections__c>();
        testInspections.add(null);
        for (Audit_Inspections__c inspection : inspections) {
            testInspections[0] = inspection;
            EIS_Onsubmit_Inspection_Notification.sendInspectorEmail(testInspections);
            EIS_SendEmailNotification.sendEmailToFacilityContactList(testInspections);
        }
        Test.stopTest();
    }
    
    
    //Testing EIS_SendEmailNotification.apxc
    @isTest
    public static void sendEmailToFacilityContactList_InspectionForm_Test() {
        Site__c site = EIS_TestDataUtils.createMainSite(null);
        Site__c facility = EIS_TestDataUtils.createMainFacility(site);
        Contact cont = EIS_TestDataUtils.createInternalContact(null);
        Contact_List__c contactList = EIS_TestDataUtils.createContactList(cont, facility, null);
        List<Audit_Inspections__c> inspections = EIS_TestDataUtils.createInspectionList(facility, cont);
        for (Integer i = 0; i < inspections.size(); i++) {
            inspections[i].Inspected_By__c = cont.Id;
        }
        update inspections;
        List<Questions__c> questions = EIS_TestDataUtils.createInspectionQuestionList(inspections);
        List<Finding__c> findings = EIS_TestDataUtils.createInspectionFindingList(questions);
        List<Corrective_Action__c> caList = EIS_TestDataUtils.createInspectionCorrectiveActionList(findings);
        
        Test.startTest();
        List<Audit_Inspections__c> testInspections = new List<Audit_Inspections__c>();
        testInspections.add(null);
        for (Audit_Inspections__c inspection : inspections) {
            testInspections[0] = inspection;
            EIS_SendEmailNotification.sendEmailToFacilityContactList(testInspections);
        }
        Test.stopTest();
    }
    @isTest
    public static void testSendInspectorEmail()
    {
        contact con = new Contact
            (
                LastName = 'Test',
                Email = 'Test@exampletest.com'
            );
        insert con;
        system.debug('test1');
        Route__c rout = new Route__c
            (
                Name = 'Test'
            );
        insert rout;
        system.debug('test2');
        Train__c trn = new Train__c
            (
                Name = '1324',
                Route__c = rout.Id
            );
        insert trn;
        system.debug('test3');
        Food_Car__c fc = new Food_Car__c
            (
                Name = '1000',
                EIS_Food_Car_Type__c = 'Diner',
                EIS_Train__c = trn.Id
            );
        insert fc;
        system.debug('test4');
        Audit_Inspections__c ai = new 	Audit_Inspections__c
            (
                RecordTypeId = EIS_StaticUtils.INSPECTION_FOOD_CAR_RTID,
                Inspected_By__c = con.Id,
                OBS_Train_Manager__c = con.Id,
                OBS_Train_Manager_Crew_Base__c = 'BOS',
                Date_and_Time__c = Datetime.now(),
                PH_Submission_Status__c = 'Submitted'
            );
        insert ai;
        
        //create ContentDocumentLink  record 
        
        
        ContentVersion cv=new Contentversion(
            title='ABC',
            PathOnClient ='test',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert cv;
        
        ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];
        
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = ai.id;
        cdl.contentdocumentid =contentVersion_2 .contentdocumentid;
        cdl.shareType = 'V';
        insert cdl;
        System.assertEquals(documents.size(), 1);
        System.assertEquals(documents[0].Id, contentVersion_2.ContentDocumentId);
        System.assertEquals(documents[0].LatestPublishedVersionId, contentVersion_2.Id);
        System.assertEquals(documents[0].Title, contentVersion_2.Title);
        
        
        System.assertEquals('Submitted', ai.PH_Submission_Status__c); 
        EIS_Onsubmit_Inspection_Notification.sendInspectorEmail(new list<Audit_Inspections__c>{ai});
    }
}
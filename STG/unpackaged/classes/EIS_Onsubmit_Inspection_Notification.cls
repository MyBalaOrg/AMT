/**
*—————————————————————————————————————————————————————————————————————————
* @Name             EIS_Onsubmit_Inspection_Notification
* @Author           Kumar Suyash
* @Created Date     07-10-2017
* @Used By          Audit Inspection Process Builder to call the method
*—————————————————————————————————————————————————————————————————————————
* @Description
* Send an email to Contact List related to Inspection  
* with pdf attachment 
*—————————————————————————————————————————————————————————————————————————
* @Changes
* 
**/

public without sharing class EIS_Onsubmit_Inspection_Notification {
    
    @InvocableMethod
    
    public static void sendInspectorEmail(List < Audit_Inspections__c > auditInspection) {
        System.debug('BEGIN EIS_Onsubmit_Inspection_Notification.sendInspectorEmail()');
        try {
            //Retreive email template and Map them by the record type of the audit/SFA form
            Map<Boolean, Id> templateIdMap = new Map<Boolean, Id>();
            templateIdMap.put(true, [SELECT Id FROM EmailTemplate WHERE DeveloperName = :Label.Submission_Email_Food_Car LIMIT 1].Id);  // TRUE for Food Car
            templateIdMap.put(false, [SELECT Id FROM EmailTemplate WHERE DeveloperName = :Label.Email_Template_Submission_Inspection_Email LIMIT 1].Id); // FALSE for non food car
            
            //Retrieve Public Group email addresses
            Map<Boolean, Set<String>> publicGroupEmailMap = getPublicGroupEmailAddressesMap();      // TRUE for Food Car, FALSE for Non Food Car
            
            //Set of inspection form ID
            Set<id> inspectionIDSet = new Set<id>();
            
            // Create the Attachment
            // Reference the attachment page, pass in the Inspection ID
            Set<Id> facilityIds = new Set<Id>();
            Set<Id> foodcarIds = new Set<Id>();
            Map<Id, List<Messaging.EmailFileAttachment>> fileAttachmentMap = new Map<Id, List<Messaging.EmailFileAttachment>>();
            Map<Id, Set<String>> caAssignedToEmailMap = new Map<Id, Set<String>>();
            for (Audit_Inspections__c ai : auditInspection) {
                inspectionIDSet.add(ai.id);
                PageReference pdf = Page.EIS_AuditInspectionReportV2;
                pdf.getParameters().put('id', ai.Id);
                pdf.setRedirect(true);
                
                Blob fileBody = Test.isRunningTest() ? Blob.valueOf('UNIT.TEST') : pdf.getContent();
                Messaging.EmailFileAttachment fileAttachment = new Messaging.EmailFileAttachment();
                fileAttachment.setFileName(ai.PH_Code__c+'.pdf');
                fileAttachment.setBody(fileBody);
                
                fileAttachmentMap.put(ai.Id, new List<Messaging.EmailFileAttachment> {fileAttachment});
                
                if (ai.RecordTypeId == EIS_StaticUtils.INSPECTION_FOOD_CAR_RTID) {
                    if (ai.EIS_Food_Car__c != null) {
                        foodcarIds.add(ai.EIS_Food_Car__c);
                    }
                } else {
                    if (ai.PH_Facility__c != null) {
                        facilityIds.add(ai.PH_Facility__c);
                    } 
                }
            }
            
            
            //Shiva
            //Retrieve Inspection Attachment 
            //getting sum of contentSize
           
            List<ContentDocumentLink> conDocumentLink = new  List<ContentDocumentLink>([SELECT id, LinkedEntityId, ContentDocumentId, ContentDocument.title, ContentDocument.FileType FROM ContentDocumentLink where LinkedEntityId IN: inspectionIDSet]);
            System.debug('conDocumentLink list$$$ -'+conDocumentLink);
            
            Set<Id> contentDocumentId  = new Set<Id>();
            Map<Id,ContentDocumentLink> contentDocTitle = new Map<Id,ContentDocumentLink>();
            Map<Id,List<Id>> entityAndDocMap = new Map<Id,List<Id>>();
            
            if(conDocumentLink != NULL && !conDocumentLink.isEmpty()){
                for(ContentDocumentLink cdl : conDocumentLink ){
                    contentDocumentId.add(cdl.ContentDocumentId);
                    contentDocTitle.put(cdl.ContentDocumentId,cdl );
                    if(entityAndDocMap.containsKey(cdl.LinkedEntityId)) {
                        entityAndDocMap.get(cdl.LinkedEntityId).add(cdl.ContentDocumentId);
                    } else {
                        entityAndDocMap.put(cdl.LinkedEntityId,new List<Id>{cdl.ContentDocumentId});
                    }
                }
            }
            System.debug('entityAndDocMap list$$$ -'+entityAndDocMap);
            System.debug('contentDocumentId list$$$ -'+contentDocumentId);
            System.debug('contentDocTitle list$$$ -'+contentDocTitle);
             AggregateResult[] groupedResults
                = [SELECT SUM(contentsize) Con
                   FROM ContentVersion where ContentDocumentId IN: contentDocumentId];
            Double sumSize = (Double)groupedResults[0].get('con');
           
            if( sumSize  < 49000000){
            //Retrive ContentVersion 
            List<ContentVersion> contentVersion = new  List<ContentVersion>([Select VersionData, contentsize, ContentDocumentId, FileExtension, FileType FROM ContentVersion where ContentDocumentId IN: contentDocumentId ]);
            Map<id,ContentVersion> contentVersionMap = new Map<id,ContentVersion>();
            System.debug('contentSize sum ' +sumSize );
            System.debug('contentSize = '+contentVersion[0].ContentSize);
            system.debug('test1 start'+'Content Size =' + contentVersion);
            if(contentVersion != NULL && !contentVersion.isEmpty()){
                for(ContentVersion cv : contentVersion){
                    contentVersionMap.put(cv.ContentDocumentId,cv);
                }
            }                 
            for (Audit_Inspections__c ai : auditInspection) {
                
                if(!entityAndDocMap.isEmpty() && entityAndDocMap.containsKey(ai.Id)) {
                    for(String docId : entityAndDocMap.get(ai.Id)) {
                        if(!contentDocTitle.isEmpty() && !contentVersionMap.isEmpty()) {
                            if(contentDocTitle.containsKey(docId) && contentVersionMap.containsKey(docId)) {
                                Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                                efa.setFileName(contentDocTitle.get(docId).ContentDocument.title+'.'+contentVersionMap.get(docId).FileExtension);
                                efa.setBody(contentVersionMap.get(docId).VersionData);
                                efa.setInline(false);
                                if(fileAttachmentMap.containsKey(ai.Id)) {
                                    fileAttachmentMap.get(ai.Id).add(efa);
                                } else {
                                    fileAttachmentMap.put(ai.Id, new List<Messaging.EmailFileAttachment> {efa});
                                }
                            }
                        }
                    }
                }
            }
            }
            System.debug('File End');
            
            
            // Fetching email address from contactList
            Map<Id, Set<String>> clEmailMap = new Map<Id, Set<String>>();
            if (!facilityIds.isEmpty() || !foodcarIds.isEmpty()) {
                clEmailMap = getContactListEmailMap(facilityIds, foodcarIds);
            }
            facilityIds = null; foodcarIds = null;
            
            // Fetching Org Wide Email Address id
            String orgId = [select id, Address from OrgWideEmailAddress where Address =: Label.EIS_OW_Email_Address Limit 1].Id;
            // Setup Single Email Message Function
            List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
            
            //Quering to get the emails from the related Employees
            List<Audit_Inspections__c> aiList = [
                SELECT Id, Inspected_By__c, RecordTypeId, PH_Employee_Responsible__c, PH_Employee_Responsible__r.Email, Mech_Critical_Violations__c, 
                OBS_Train_Manager__c, OBS_Train_Manager__r.Email, EIS_Food_Car__c, PH_Facility__c
                FROM Audit_Inspections__c
                WHERE Id IN :inspectionIDSet
            ];
            
            for (Audit_Inspections__c ai : aiList) {
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.setTargetObjectId(ai.Inspected_By__c);
                message.setWhatId(ai.Id);
                message.setTemplateId(templateIdMap.get(ai.RecordTypeId == EIS_StaticUtils.INSPECTION_FOOD_CAR_RTID));
                message.setFileAttachments(fileAttachmentMap.get(ai.Id));
                message.setOrgWideEmailAddressId(orgId);
                
                // Begin appending all additional receiver's email addresses 
                Set<String> toAddressesSet = new Set<String>();
                system.debug('******ai.PH_Employee_Responsible__r.Email*****'+ai.PH_Employee_Responsible__r.Email);
                if (String.isNotBlank(ai.PH_Employee_Responsible__r.Email) && String.isNotBlank(ai.PH_Employee_Responsible__r.Email.trim())) {
                    toAddressesSet.add(ai.PH_Employee_Responsible__r.Email.trim());
                }
                
                toAddressesSet.addAll(publicGroupEmailMap.get(ai.RecordTypeId == EIS_StaticUtils.INSPECTION_FOOD_CAR_RTID));
                
                if (ai.RecordTypeId == EIS_StaticUtils.INSPECTION_FOOD_CAR_RTID) {
                    if (ai.Mech_Critical_Violations__c > 0) {
                        toAddressesSet.addAll(getSplitStringValues(Label.CNOC_distribution));
                    }
                    system.debug('******ai.OBS_Train_Manager__r.Email*****'+ai.OBS_Train_Manager__r.Email);
                    if (String.isNotBlank(ai.OBS_Train_Manager__r.Email) && String.isNotBlank(ai.OBS_Train_Manager__r.Email.trim())) {
                        toAddressesSet.add(ai.OBS_Train_Manager__r.Email.trim());
                    }
                    if (clEmailMap.get(ai.EIS_Food_Car__c) != null) {
                        toAddressesSet.addAll(clEmailMap.get(ai.EIS_Food_Car__c));
                    }
                } else {
                    if (clEmailMap.get(ai.PH_Facility__c) != null) {
                        toAddressesSet.addAll(clEmailMap.get(ai.PH_Facility__c));
                    }
                }
                
                toAddressesSet.remove(null);
                List<String> toAddresses = new List<String>();
                for (String toAddress : toAddressesSet) {
                    if (String.isNotBlank(toAddress) && toAddress.contains('@')) {
                        toAddresses.add(toAddress.trim());
                    }
                }
                message.setToAddresses(toAddresses);
                
                emailMessages.add(message);
            } 
            List<Messaging.SendEmailResult> results = Messaging.sendEmail(emailMessages);
            for (Messaging.SendEmailResult result : results) {
                if (result.success) {
                    System.debug('Email was sent successfully');
                } else {
                    System.debug('Email failed to send: ' + result.errors[0].message);
                }
            }
            
        } catch (Exception e) {
            System.debug('Exception Caught: ' + e.getMessage());
            System.debug(e.getStackTraceString());
        }
        System.debug('END EIS_Onsubmit_Inspection_Notification.sendInspectorEmail()');
    }
    
    /**
*————————————————————————————————————————————————————
* @Description
* Split a String into a List of String, deliminated by space, comma, and semicolon
*————————————————————————————————————————————————————
* @param    str             String value to be split into List
* @return   List<String>    List representation of str value
*————————————————————————————————————————————————————
**/
    private static List<String> getSplitStringValues(String str) {
        List<String> splitString = new List<String>();
        if (String.isNotBlank(str)) {
            splitString = str.split('(\\s|,|;)+');
        }
        return splitString;
    }
    
    /**
*————————————————————————————————————————————————————
* @Description
* Query for all users in public group and separate them into Map with key values
* correspond to if the record type is Food Car or not Food Car 
*————————————————————————————————————————————————————
* @return   Map<Boolean, Set<String>>   Map of email addresses organized by boolean values
*————————————————————————————————————————————————————
**/
    private static Map<Boolean, Set<String>> getPublicGroupEmailAddressesMap() {
        Map<Boolean, Set<String>> publicGroupEmailMap = new Map<Boolean, Set<String>>();
        publicGroupEmailMap.put(true, new Set<String>());       // TRUE for Food Car
        publicGroupEmailMap.put(false, new Set<String>());      // FALSE for non food car
        List<User> publicGroupUser = [
            select Id, email from user where id in (select userorgroupid from groupmember where group.DeveloperName =: Label.Group_Public_Health_Approver)
            and email != null and email like '%@%'
        ];
        for (User usr: publicGroupUser) {
            if (String.isNotBlank(usr.email) && String.isNotBlank(usr.email.trim())) {
                publicGroupEmailMap.get(true).add(usr.email.trim());
                publicGroupEmailMap.get(false).add(usr.email.trim());
            }
        }
        
        publicGroupUser = [
            select Id, email from user where id in (select userorgroupid from groupmember where group.DeveloperName =: Label.Group_Public_Health_Inspector)
            and email != null and email like '%@%'
        ];
        for (User usr: publicGroupUser) {
            if (String.isNotBlank(usr.email) && String.isNotBlank(usr.email.trim())) {
                publicGroupEmailMap.get(true).add(usr.email.trim());
            }
        }
        publicGroupUser = null;     // no longer needed, freeing up memory
        
        return publicGroupEmailMap;
    }
    
    /**
*————————————————————————————————————————————————————
* @Description
* Query for all corrective actions to retrieve Assigned To contacts and map them by the inspection record Id
*————————————————————————————————————————————————————
* @param    auditInspection         List of inspection records to be iterate over
* @return   Map<Id, Set<String>>    Map of email addresses organized by record Id of the inspection record
*————————————————————————————————————————————————————
**/
    private static Map<Id, Set<String>> getContactListEmailMap(Set<Id> facilityIds, Set<Id> foodcarIds) {
        Map<Id, Set<String>> clEmailMap = new Map<Id, Set<String>>();
        Map<Id, Set<Id>> trainIdMap = new Map<Id, Set<Id>>();   // Key is Train Id, Value is Food Car Ids
        if (!foodcarIds.isEmpty()) {
            List<Food_Car__c> foodcarList = [SELECT Id, EIS_Train__c FROM Food_Car__c WHERE Id IN :foodcarIds];
            for (Food_Car__c fc : foodcarList) {
                if (trainIdMap.get(fc.EIS_Train__c) == null) {
                    trainIdMap.put(fc.EIS_Train__c, new Set<Id>());
                }
                trainIdMap.get(fc.EIS_Train__c).add(fc.Id);
            }
        }
        
        //ARSS-243 - Filtering separated contacts from contact list retrieval - 4/24/18
        List<Contact_List__c> contactList = [
            SELECT EIS_Contact__c, EIS_Site__c, EIS_Train__c, EIS_Contact__r.Email,EIS_Contact__r.Employment_Status__c 
            FROM Contact_List__c 
            WHERE (EIS_Site__c IN :facilityIds OR EIS_Train__c IN :trainIdMap.keySet())
            AND EIS_Contact__r.Employment_Status__c != :Label.Separated_Label AND EIS_Contact__r.Email != null AND EIS_Contact__r.Email LIKE '%@%'
        ]; 
        
        for (Contact_List__c cl: contactList) {
            if (String.isNotBlank(cl.EIS_Contact__r.Email) && String.isNotBlank(cl.EIS_Contact__r.Email.trim())) {
                if (clEmailMap.get(cl.EIS_Site__c) == null) {
                    clEmailMap.put(cl.EIS_Site__c, new Set<String>());
                }
                clEmailMap.get(cl.EIS_Site__c).add(cl.EIS_Contact__r.Email.trim());
                
                if (trainIdMap.get(cl.EIS_Train__c) != null) {
                    for (Id fcId : trainIdMap.get(cl.EIS_Train__c)) {
                        if (clEmailMap.get(fcId) == null) {
                            clEmailMap.put(fcId, new Set<String>());
                        }
                        clEmailMap.get(fcId).add(cl.EIS_Contact__r.Email.trim());
                    }
                }
            }
        }
        trainIdMap = null;      // no longer needed, freeing up memory
        contactList = null;     // no longer needed, freeing up memory
        
        return clEmailMap;
    }
}
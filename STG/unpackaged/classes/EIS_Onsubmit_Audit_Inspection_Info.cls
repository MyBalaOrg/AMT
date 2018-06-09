/**
*————————————————————————————————————————————————————
* @Name             EIS_Onsubmit_Audit_Inspection_Info
* @Author           Kumar Suyash
* @Created Date     07-22-2017
* @Used By          Audit Inspection Process Builder
*————————————————————————————————————————————————————
* @Description
* Class which is called by Processbuilder for Mailing 
* 
*————————————————————————————————————————————————————
* @Changes
* 09-13-2017    Refactored to work with list of records instead of just a single record. Code clean up
**/
public with sharing class EIS_Onsubmit_Audit_Inspection_Info {
    
    @InvocableMethod
    public static void sendAuditorEmail(List<Audit_Inspections__c> auditInspection) {
        try {
            system.debug('Inside apex class post PB call');
            // Create the Attachment
            // Reference the attachment page, pass in the Inspection ID
            Set<Id> siteIds = new Set<Id>();
            Map<Id, List<Messaging.EmailFileAttachment>> fileAttachmentMap = new Map<Id, List<Messaging.EmailFileAttachment>>();
            for (Audit_Inspections__c ai : auditInspection) {
                PageReference pdf = Page.EIS_AuditInspection_Pdf_Genration;
                pdf.getParameters().put('id', ai.Id);
                pdf.setRedirect(true);
                
                Blob fileBody = Test.isRunningTest() ? Blob.valueOf('UNIT.TEST') : pdf.getContent();
                Messaging.EmailFileAttachment fileAttachment = new Messaging.EmailFileAttachment();
                fileAttachment.setFileName(ai.Name+'.pdf');
                fileAttachment.setBody(fileBody);
                
                fileAttachmentMap.put(ai.Id, new List<Messaging.EmailFileAttachment> {fileAttachment});
                
                if (ai.EIS_Site__c != null) {
                    siteIds.add(ai.EIS_Site__c);
                }
            }
            //Retreive email template and Map them by the record type of the audit/SFA form
            Map<Id, Id> templateIdMap = new Map<Id, Id>();
            templateIdMap.put(EIS_StaticUtils.INSPECTION_AUDIT_FORM_RTID, 
                              [SELECT Id FROM EmailTemplate WHERE DeveloperName = :Label.Email_Template_Onsubmit_CAs_Audit_Inspection_Notification LIMIT 1].Id);
            templateIdMap.put(EIS_StaticUtils.INSPECTION_SFA_FORM_RTID, 
                              [SELECT Id FROM EmailTemplate WHERE DeveloperName = :Label.Email_Template_Onsubmit_Observations_Audit_Inspection_Notification LIMIT 1].Id);
            
            //Retrieve Public Group email addresses
            List<String> emailAddresses = new List<String>();
            List<User> publicGroupUser = [
                select Email from User where Id in
                (select userorgroupid from groupmember where group.DeveloperName =: Label.Group_Audit_Program_Manager )
                and Email != null and Email like '%@%'
            ];
            for (User usr: publicGroupUser) {
                if (String.isNotBlank(usr.Email) && usr.Email.contains('@')) {
                    emailAddresses.add(usr.Email.trim());
                }
            }
            publicGroupUser = null;     // no longer needed, freeing up memory
            
            //pk:-3/30/2018 ARSS 152 :- add constant mail ids from custom settings 
            //ap:-4/6/2018 commented code since this is not needed if public group will work
            /*
            AEPHIS_Settings__c mailCustomSetting =  AEPHIS_Settings__c.getValues('AuditMailIds');
             emailAddresses.addAll((mailCustomSetting.EIS_Text_Value__c).split(','));             
            system.debug('Email after Adding constant mail ids :-' + emailAddresses);
            */
            
            // Fetching email address from contactList
            //ARSS-243 - Filtering separated contacts from contact list retrieval - 4/24/18
            Map<Id, List<String>> clEmailMap = new Map<Id, List<String>>();
            if(!siteIds.isEmpty())  { 
                List<Contact_List__c> contactList = [
                    SELECT EIS_Contact__r.Email, EIS_Contact__c, EIS_Audit_Specific__c, EIS_Site__c,EIS_Contact__r.Employment_Status__c  
                    FROM Contact_List__c 
                    WHERE EIS_Site__c IN: siteIds AND EIS_Contact__r.Employment_Status__c != :Label.Separated_Label  AND EIS_Contact__r.Email != null AND EIS_Contact__r.Email LIKE '%@%'
                ];   
                for (Contact_List__c cl: contactList) {
                    if (String.isNotBlank(cl.EIS_Contact__r.Email) && cl.EIS_Audit_Specific__c && cl.EIS_Contact__r.Email.contains('@')) {
                        if (clEmailMap.get(cl.EIS_Site__c) == null) {
                            clEmailMap.put(cl.EIS_Site__c, new List<String>()); 
                            clEmailMap.get(cl.EIS_Site__c).addAll(emailAddresses);
                        }
                        clEmailMap.get(cl.EIS_Site__c).add(cl.EIS_Contact__r.Email.trim());
                    }
                }
                contactList = null;     // no longer needed, freeing up memory
            }
            
            if (!emailAddresses.isEmpty() || !siteIds.isEmpty()) {
                //fetching Org Wide Email Address id
                String orgId = [select id, Address from OrgWideEmailAddress where Address=:Label.EIS_OW_Email_Address Limit 1].Id;
                // Setup Single Email Message Function
                List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
                for (Audit_Inspections__c ai : auditInspection) {
                    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                    message.setTargetObjectId(ai.EIS_Auditor_1__c); 
                    message.setWhatId(ai.Id);
                    message.setTemplateId(templateIdMap.get(ai.RecordTypeId));
                    message.setFileAttachments(fileAttachmentMap.get(ai.Id));
                    message.setOrgWideEmailAddressId(orgId);
                    if (clEmailMap.get(ai.EIS_Site__c) == null) {
                        message.setToAddresses(emailAddresses); // Public Group email list
                    } else {
                        message.setToAddresses(clEmailMap.get(ai.EIS_Site__c)); // Facility's ContactList emails and Public Group email list
                    }
                    
                    emailMessages.add(message); 
                }
                
                system.debug('The Email Message to be sent :----' + emailMessages);
                List<Messaging.SendEmailResult> results = Messaging.sendEmail(emailMessages);
                for (Messaging.SendEmailResult result : results) {
                    if (result.success) {
                        System.debug('Email was sent successfully');
                    } else {
                        System.debug('Email failed to send: ' + result.errors[0].message);
                    }
                }
            }
            
        } catch (Exception e) {
            System.debug(e.getMessage());
            if (auditInspection != null && !auditInspection.isEmpty()) { auditInspection[0].addError(e.getMessage()); }
        }
        
    }
}
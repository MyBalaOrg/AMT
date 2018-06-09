/**
*————————————————————————————————————————————————————
* @Name             EIS_IncidentsTriggerHelper
* @Created Date     06-1-2017
*————————————————————————————————————————————————————
* @Description
* Send an email to Site Contact List related to Compliance Action
*————————————————————————————————————————————————————
* @Changes
* 09/06/2017	Refactored the trigger to send emailMessages to targetObjectId instead of custom email list
**/
public class EIS_IncidentsTriggerHelper {
    
/**
* Method Name: sendEmailToSiteContactList_AfterInsert
* Description: This is a method which sends email notification to site contact list upon Compliance Action or Spills record creation.
* 
**/
    public void sendEmailToSiteContactList_AfterInsert(List<Incidents__c> newList) { 
        try {
            //Retreive email template and Map them by the record type of the incidents
            Map<Id, Id> templateIdMap = new Map<Id, Id>();
            templateIdMap.put(EIS_StaticUtils.Compliance_Action_Main_RTID, 
                              [SELECT Id FROM EmailTemplate WHERE DeveloperName = :Label.Email_Template_EIS_New_Compliance_Action_Notification LIMIT 1].Id);
            templateIdMap.put(EIS_StaticUtils.EIS_Spill_Main_label_RTID, 
                              [SELECT Id FROM EmailTemplate WHERE DeveloperName = :Label.Email_EIS_Incident_New_Spill_Notification LIMIT 1].Id);
            //fetching Org Wide Email Address id
            Id orgId = [SELECT Id, Address FROM OrgWideEmailAddress WHERE Address=:Label.EIS_OW_Email_Address LIMIT 1].Id;
            
            //featching siteIds 
            Set<Id> siteIds = new Set<Id>();
            for (Incidents__c incident : newList) {
                if (incident.RecordTypeId == EIS_StaticUtils.Compliance_Action_Main_RTID || incident.RecordTypeId == EIS_StaticUtils.EIS_Spill_Main_label_RTID) {
                    if (incident.EIS_Site__c != null) {
                        siteIds.add(incident.EIS_Site__c);
                    }
                }
            }
            
            // Checking the siteIds and fetching the values for email fields from contact list agains siteIds
            if (!siteIds.isEmpty()) {
                Map<Id, Set<Id>> targetObjectIdMap = new Map<Id, Set<Id>>();
                List<Site__c> incidentSites = [SELECT Id, (SELECT EIS_Contact__r.Email, EIS_Contact__c FROM Site_Team_Contacts__r) FROM Site__c WHERE Id IN :siteIds];
                for (Site__c site : incidentSites) {
                    for (Contact_List__c cl : site.Site_Team_Contacts__r) {
                        if (targetObjectIdMap.get(site.Id) == null) {
                            targetObjectIdMap.put(site.Id, new Set<Id>());
                        }
                        if (String.isNotBlank(cl.EIS_Contact__c) && String.isNotBlank(cl.EIS_Contact__r.Email)) {
                            targetObjectIdMap.get(site.Id).add(cl.EIS_Contact__c);
                        }
                    }
                }
                incidentSites = null;
                
                // Setup Single Email Message Function
                List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
                for (Incidents__c incident : newList) {
                    if (targetObjectIdMap.get(incident.EIS_Site__c) != null) {
                        for (Id targetObjectId : targetObjectIdMap.get(incident.EIS_Site__c)) {
                            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                            mail.setSaveAsActivity(false);
                            mail.setTemplateId(templateIdMap.get(incident.RecordTypeId));
                            mail.setTargetObjectId(targetObjectId);
                            mail.setWhatId(incident.Id);
                            mail.setOrgWideEmailAddressId(orgId);
                            emailMessages.add(mail);
                        }
                    }
                }
                
                Messaging.sendEmail(emailMessages);
            }
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
    }
    
    
}
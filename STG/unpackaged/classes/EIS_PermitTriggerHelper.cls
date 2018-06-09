/**
*————————————————————————————————————————————————————
* @Name             EIS_PermitTriggerHelper
* @Author           Alex
* @Created Date     06-1-2017
* @Used By          PermitTriggerHandler.apxc
*————————————————————————————————————————————————————
* @Description
* Helper class to handle trigger logic for Permit object
*
*————————————————————————————————————————————————————
**/
public class EIS_PermitTriggerHelper {
    
    public void sendEmailToSiteContactList(List<Permit_Plan__c> newList) {
        try{
            EmailTemplate newCompliance = [
                SELECT Id FROM EmailTemplate WHERE DeveloperName =: Label.Email_Template_Site_Permit_Due_Date_Reminder LIMIT 1
            ];

            Set<Id> siteIds = new Set<Id>();
            for (Permit_Plan__c permit : newList) {
                if (EIS_StaticUtils.PERMIT_PLAN_MAIN_RTID == permit.RecordTypeId && permit.EIS_6_Month_Update_Placeholder__c != null) {
                    siteIds.add(permit.EIS_Site__c);   
                }
            }
            
            List<Site__c> siteList = new List<Site__c>();
            Map<Id, List<String>> emailAddressMap = new Map<Id, List<String>>();
            if(!siteIds.isEmpty()) { 
                siteList = [
                    SELECT Id, (SELECT EIS_Contact__r.Email, EIS_Contact__c FROM Site_Team_Contacts__r)
                    FROM Site__c WHERE Id IN: siteIds LIMIT :Limits.getDmlRows()
                ];
                
                for(Site__c site : siteList) {
                    for (Contact_List__c cl : site.Site_Team_Contacts__r) {
                        if (emailAddressMap.get(site.Id) == null) {
                            emailAddressMap.put(site.Id, new List<String>());
                        }
                        if (String.isNotBlank(cl.EIS_Contact__r.Email)) {
                            emailAddressMap.get(site.Id).add(cl.EIS_Contact__r.Email);
                        }
                    }
                }
            }
            
            //fetching Org Wide Email Address id
            String orgId = [select id, Address from OrgWideEmailAddress where Address=:Label.EIS_OW_Email_Address Limit 1].Id;
            
            // Setup Single Email Message Function
            List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
            for (Permit_Plan__c permit : newList) {
                if (EIS_StaticUtils.PERMIT_PLAN_MAIN_RTID == permit.RecordTypeId && permit.EIS_6_Month_Update_Placeholder__c != null){
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setSaveAsActivity(false);
                    mail.setTemplateId(newCompliance.Id);
                    mail.setTargetObjectId(permit.EIS_Internal_Contact__c);
                    mail.setWhatId(permit.Id);
                    mail.setOrgWideEmailAddressId(orgId);
                    if (emailAddressMap.get(permit.EIS_Site__c) != null) {
                        mail.setToAddresses(emailAddressMap.get(permit.EIS_Site__c));
                    }
                    emailMessages.add(mail);
                }
            }
            
            //Sending E-Mail
            if(emailMessages.size() > 0)
                Messaging.sendEmail(emailMessages);
        } catch(Exception e){
            System.debug(e.getMessage());
        }
    }
}
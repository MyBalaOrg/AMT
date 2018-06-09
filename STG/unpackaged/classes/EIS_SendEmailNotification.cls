/**
*————————————————————————————————————————————————————
* @Name             EIS_SendEmailNotification
* @Author           Kumar Suyash
* @Created Date     06-20-2017
* @Used By          EIS_Onsubmit_Audit_Inspection_Info
*————————————————————————————————————————————————————
* @Description
* Send an email to Contact List related to Inspection 
* 
*————————————————————————————————————————————————————
* @Changes
* 
**/

public class EIS_SendEmailNotification {
    
    @InvocableMethod
    public static void sendEmailToFacilityContactList(List<Audit_Inspections__c> auditInspection) {
        //Email templat for Inspection Due Date 
        EmailTemplate newInspection = [
            SELECT Id FROM EmailTemplate WHERE DeveloperName =: Label.Email_Template_Inspection_Due_Date_Reminder_Notification 
        ]; 
        //Permission Set Check
        List<String> permissionSetNames = new List<String>();
        permissionSetNames.add(Label.Permission_Set_EIS_Public_Health_Approver );
        permissionSetNames.add(Label.Permission_Set_EIS_Public_Health_Inspector ); 
        
        List<Id> siteIds = new List<Id>();
        //Retreive email address from contact list    
        for (Audit_Inspections__c inspection : auditInspection) {
            siteIds.add(inspection.PH_Facility__c);   
        }
        
        List<Site__c> siteList = [
            SELECT Id, (SELECT EIS_Email_Formula__c, EIS_Contact__c FROM Site_Team_Contacts__r)
            FROM Site__c WHERE Id IN: siteIds
        ];
        
        Id targetObjectId = null;
        Map<Id, List<String>> emailAddressMap = new Map<Id, List<String>>();
        for(Site__c site : siteList) {
            List<Contact_List__c> contactList = site.Site_Team_Contacts__r;
            for (Contact_List__c cl : contactList) {
                if (emailAddressMap.get(site.Id) == null) {
                    emailAddressMap.put(site.Id, new List<String>());
                }
                if (String.isNotBlank(cl.EIS_Email_Formula__c)) {
                    emailAddressMap.get(site.Id).add(cl.EIS_Email_Formula__c);
                    targetObjectId = cl.EIS_Contact__c;
                }
            }
        }
        if(targetObjectId != null){
        //Adding email to SingleEmailMessage method
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        for (Audit_Inspections__c inspection : auditInspection) {
            if (emailAddressMap.get(inspection.PH_Facility__c) != null) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setSaveAsActivity(false);
                mail.setTemplateId(newInspection.Id);
                mail.setTargetObjectId(targetObjectId);
                mail.setWhatId(inspection.Id);
                mail.setToAddresses(emailAddressMap.get(inspection.PH_Facility__c));
                emails.add(mail);
            }
        }
        
        System.debug(emails.size());
        
        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
            }
        }
    }
}
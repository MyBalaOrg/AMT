/**
*————————————————————————————————————————————————————
* @Name             StaticUtils
* @Author           Duy Tran
* @Created Date     08-30-2017
* @Used By          All other apex classes
*————————————————————————————————————————————————————
* @Description
* Common utilities method and constants used by other classes
*————————————————————————————————————————————————————
* @Changes
* 08-30-2017    Migration from EIS_StaticUtils.apxc* 
* 07-03-2018    Added sendEmailMethod Method  
* 04-28-2018    Don't query profiles and custom permissions if we've done so before [cwalley]
**/
public class StaticUtils {

    public static List<Profile> profiles = new List<Profile>(); 
    public static List<CustomPermission> custPerm = new List<CustomPermission>(); 
    
	// Wrapper Class for primarily used in search functionality
   public class SearchItem {
        public Id recordId {get; set;}			// Id of the record being looked up
        public String searchValue {get; set;}	// Append all desired searchable value to this field
        public String label {get; set;}			// Used for label in the selectable drop down list
        public String phone {get; set;}			// Additional field to carry more information
        //ARSS204
        public List<AdditionalField> additionalFields { get; set; }	// Additional fields
    }
    
    //ARSS204 wrapper for AdditionalField class
    public class AdditionalField {
        public String FieldAPIName { get; set; }
        public String FieldLabel { get; set; }
        public String Value { get; set; }
        public AdditionalField(String fieldApiName, String fieldLabel, String value) {
            this.FieldAPIName = fieldApiName;
            this.FieldLabel = fieldLabel;
            this.Value = value;
        }
    }
    
    //Wrapper Class for Search functionality with tabular results
    //Originally created for Review System
    public class SearchTabularItem {
        public Boolean selected {get; set;}
        public Id recordId {get; set;}
        public List<String> fieldNames {get; set;}
        public List<String> fieldValues {get; set;}
    }    
    
    // Check if current user is a System Admin
    public static Boolean userIsSystemAdmin() {
        if(profiles.size() == 0) { 
            profiles = [SELECT Id FROM Profile WHERE Id = :UserInfo.getProfileId() AND Name = 'System Administrator'];
        }
        return !profiles.isEmpty();
    }
    
    // Check if current user has any of the provided permission set
    public static Boolean verifyUserPermissionSet(List<String> permissionSetNames) {
        List<PermissionSetAssignment> psaList = [
            SELECT Id FROM PermissionSetAssignment 
            WHERE AssigneeId = :UserInfo.getUserId() 
            AND PermissionSetId IN (SELECT Id FROM PermissionSet WHERE Name IN: permissionSetNames)];
        return !psaList.isEmpty();
    }
    
    // Check if current user is a valid app user
    public static Boolean hasAccess(String customPermissionName) {
        
        if(custPerm.size() == 0) {
         
            if (userIsSystemAdmin()) { return true; }        
            Map<id, PermissionSetAssignment> mapPermissionID = new Map<id, PermissionSetAssignment>();
            for(PermissionSetAssignment p : [SELECT PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId=: UserInfo.getUserId()] ) {
                mapPermissionID.put(p.PermissionSetId, p);
            }
            system.debug(mapPermissionID);
            custPerm = [
                SELECT DeveloperName FROM CustomPermission 
                WHERE DeveloperName = :customPermissionName
                AND Id IN (SELECT SetupEntityId FROM SetupEntityAccess WHERE SetupEntityType = 'CustomPermission' AND ParentId IN: mapPermissionID.keyset())
            ];
        }    
        return custPerm != null && !custPerm.isEmpty() ;
    }
    
    //Get Picklist Values from a Field
    public static List<String> getPicklistValues(Schema.DescribeFieldResult fieldResult) {
        List<String> picklistValues = new List<String>();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry f : ple){
            picklistValues.add(f.getLabel());
        }
        return picklistValues;
    }
    
    /***************** BEGIN GET DEPENDENT PICKLIST ENTRIES *****************/
    private static final String base64Chars = '' + 'ABCDEFGHIJKLMNOPQRSTUVWXYZ' + 'abcdefghijklmnopqrstuvwxyz' + '0123456789+/';
    public class PicklistEntryWrapper {
        public String active {get; set;}
        public String defaultValue {get; set;}
        public String label {get; set;}
        public String value {get; set;}
        public String validFor {get; set;}
    }
    
    public static Map<String, List<String>> getDependentOptionsImpl(Schema.SObjectField theField, Schema.SObjectField ctrlField) {
        // validFor property cannot be accessed via a method or a property,
        // so we need to serialize the PicklistEntry object and then deserialize into a wrapper.
        List<Schema.PicklistEntry> contrEntries = ctrlField.getDescribe().getPicklistValues();
        List<PicklistEntryWrapper> depEntries = wrapPicklistEntries(theField.getDescribe().getPicklistValues());
        
        // Set up the return container - Map<ControllingValue, List<DependentValues>>
        Map<String, List<String>> objResults = new Map<String, List<String>>();
        List<String> controllingValues = new List<String>();
        
        for (Schema.PicklistEntry ple : contrEntries) {
            String label = ple.getLabel();
            objResults.put(label, new List<String>());
            controllingValues.add(label);
        }
        
        for (PicklistEntryWrapper plew : depEntries) {
            String label = plew.label;
            String validForBits = base64ToBits(plew.validFor);
            for (Integer i = 0; i < validForBits.length(); i++) {
                // For each bit, in order: if it's a 1, add this label to the dependent list for the corresponding controlling value
                String bit = validForBits.mid(i, 1);
                if (bit == '1') {
                    objResults.get(controllingValues.get(i)).add(label);
                }
            }
        }
        
        return objResults;
    }
    
    // Convert decimal to binary representation (alas, Apex has no native method :-(
    //    eg. 4 => '100', 19 => '10011', etc.
    // Method: Divide by 2 repeatedly until 0. At each step note the remainder (0 or 1).
    // These, in reverse order, are the binary.
    public static String decimalToBinary(Integer val) {
        String bits = '';
        while (val > 0) {
            Integer remainder = Math.mod(val, 2);
            val = Integer.valueOf(Math.floor(val / 2));
            bits = String.valueOf(remainder) + bits;
        }
        return bits;
    }
    
    // Convert a base64 token into a binary/bits representation
    // e.g. 'gAAA' => '100000000000000000000'
    public static String base64ToBits(String validFor) {
        if (String.isEmpty(validFor)) return '';
        
        String validForBits = '';
        
        for (Integer i = 0; i < validFor.length(); i++) {
            String thisChar = validFor.mid(i, 1);
            Integer val = base64Chars.indexOf(thisChar);
            String bits = decimalToBinary(val).leftPad(6, '0');
            validForBits += bits;
        }
        
        return validForBits;
    }
    
    private static List<PicklistEntryWrapper> wrapPicklistEntries(List<Schema.PicklistEntry> PLEs) {
        return (List<PicklistEntryWrapper>)JSON.deserialize(JSON.serialize(PLEs), List<PicklistEntryWrapper>.class);
    }
    /***************** END GET DEPENDENT PICKLIST ENTRIES *****************/

    /*******Generic Method to send Emails**********/    
    public static void sendEmailMethod(Boolean setActivityFlg, Id setTemplateId, Id setTargetObjectId, Id setWhatId, List<string>setAddressList, Boolean TreatTargetObjectAsRec){
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setSaveAsActivity(setActivityFlg);
        mail.setTemplateId(setTemplateId);
        mail.setTargetObjectId(setTargetObjectId);
        mail.setWhatId(setWhatId);
        mail.setToAddresses(setAddressList);
        mail.setTreatTargetObjectAsRecipient(TreatTargetObjectAsRec);
        emails.add(mail);
            
        System.debug(emails.size());
 
        if (!emails.isEmpty()) {
            system.debug('tO EMAIL SEND......!!!!');
            Messaging.sendEmail(emails);
            system.debug('EMAIL SEND......!!!!');
        }
    }
}
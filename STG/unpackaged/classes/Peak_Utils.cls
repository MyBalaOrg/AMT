// ===================
// Share general utility methods
// ===================
global with sharing class Peak_Utils {

    // Return true/false to determine guest user
    global Static Boolean isGuestUser() {
        Boolean isGuest = false;
        if (UserInfo.getUserType() == 'Guest' || UserInfo.getUserName() == Peak_TestConstants.GUEST_USERNAME){
            isGuest = true;
        }
        return isGuest;
    }

    // Get the site prefix
    global static String getSitePrefix(){
        return System.Site.getPathPrefix();
    }

    // Get picklist values for any object, any field
    public List<String> getPicklistValues(String ObjectApi_name,String Field_name){
        // Thanks http://salesforce.stackexchange.com/questions/4992/how-to-get-a-picklist-all-values-in-apex-controller
        List<String> lstPickvals=new List<String>();
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(ObjectApi_name);//From the Object Api name retrieving the SObject
        Sobject Object_name = targetType.newSObject();
        Schema.sObjectType sobject_type = Object_name.getSObjectType(); //grab the sobject that was passed
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
        List<Schema.PicklistEntry> pick_list_values = field_map.get(Field_name).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
        for (Schema.PicklistEntry a : pick_list_values) { //for all values in the picklist list
            lstPickvals.add(a.getValue());//add the value  to our final list
        }

        return lstPickvals;
    }

    // Build comma list string from a set
    public String buildStringFromSet(Set<String> sourceSet){
        String stringOutput = '';
        for(String thisString:sourceSet) {
            stringOutput +=  (stringOutput==''?'':', ')+thisString;
        }
        return stringOutput;
    }

    // Get User
    public Static User getUser(){
        // BannerPhotoUrl, IsProfilePhotoActive
        User user;

        List<User> userList = [select
                Id, Email,PostalCode
        from User
        where Id = :UserInfo.getUserId()];

        if (!Peak_Utils.isNullOrEmpty(userList)) {
            user = userList[0];
        }

        return user;
    }

    public Static Boolean isNullOrEmpty(List<Object> objectList) {
        if (objectList == null || objectList.size() == 0) {
            return true;
        }
        return false;
    }
}
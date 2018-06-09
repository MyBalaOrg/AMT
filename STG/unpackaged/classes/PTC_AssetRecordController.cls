public class PTC_AssetRecordController {
	@AuraEnabled
    public static List<Location__c> findAllLocations(String searchKey){
        String searchWildCard = '%'+searchKey+'%';
        List<Location__c> locationList = new List<Location__c>();
        try {
            locationList = [SELECT Id, Name FROM Location__c WHERE Name LIKE :searchWildCard and RecordType.Name =: System.Label.EIS_Location_Main_Record_Type_Label limit 5];
            system.debug('location list '+locationList);
        } catch(Exception e){
            system.debug('ERROR '+e.getMessage());
        }
        return locationList;
    }
    @AuraEnabled
    public static List<Contact> findAllContacts(String searchKey){
        String searchWildCard = '%'+searchKey+'%';
        List<Contact> contactList = new List<Contact>();
        
        try {
            contactList = [SELECT Id, email,Name FROM Contact WHERE Name LIKE :searchWildCard limit 5];
            
        } catch(Exception e) {
            system.debug(e.getMessage());
        }
        
        return contactList;
    }
    @AuraEnabled
    public static List<Product2> findAllProducts(String searchKey,String ctrlSysCompName){
        String searchWildCard = '%'+searchKey+'%';
        //String searchCtrlSysComp = ctrlSysCompName;
        List<Product2> productList = new List<Product2>();
        
        try {
            productList = [SELECT Id,Name,PTC_ParentProduct__c,PTC_Control_Systems_Component_Name__c FROM Product2 WHERE Name LIKE :searchWildCard AND PTC_ParentProduct__c = '' AND PTC_Control_Systems_Component_Name__r.Id =:ctrlSysCompName limit 5];
            system.debug('productList==='+productList);
        } catch(Exception e) {
            system.debug(e.getMessage());
        }
        
        return productList;
    }
    @AuraEnabled
    public static List<PTC_Control_System_Component_Name__c> findAllCtrlSystemCompNameField(String searchKey){
        String searchWildCard = '%'+searchKey+'%';
        List<PTC_Control_System_Component_Name__c> ctrlSystemCompNameList = new List<PTC_Control_System_Component_Name__c>();
        
        try {
            ctrlSystemCompNameList = [SELECT Id,Name FROM PTC_Control_System_Component_Name__c WHERE Name LIKE :searchWildCard limit 5];
            
        } catch(Exception e) {
            system.debug(e.getMessage());
        }
        
        return ctrlSystemCompNameList;
    }
    @AuraEnabled
    public static List<PTC_Locomotive__c> findAllLocomotives(String searchKey){
        String searchWildCard = '%'+searchKey+'%';
        List<PTC_Locomotive__c> locomotiveList = new List<PTC_Locomotive__c>();
        
        try {
            locomotiveList = [SELECT Id,Name FROM PTC_Locomotive__c WHERE Name LIKE :searchWildCard limit 5];
            
        } catch(Exception e) {
            system.debug(e.getMessage());
        }
        
        return locomotiveList;
    }
     @AuraEnabled    
    public static List<String> getStatus(){
        system.debug('in method');
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = Asset.PTC_New_Status__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
       // options.add('--None--');
        for (Schema.PicklistEntry f: ple) {
            options.add(f.getLabel());
        }
        system.debug('options'+options);
        return options;
    }
    @AuraEnabled
public static List<ListView> getListViews() {
    List<ListView> listviews = 
        [SELECT Id, Name FROM ListView WHERE SobjectType = 'Asset'];

    // Perform isAccessible() check here
    return listviews;
}
}
/**
* ********************************************************************************************************************************************************************************************************************************************
*   @Name           OC_OrgChartTopLevelApexController
*   @Author         Sarang, Deloitte Digital
*   @Created Date   14th Jun 2017
*   @Used By        OC_VerticalOrgChartComponent    
*   *******************************************************************************************************************************************************************************************************************************************
*   @Description    Helper class to the OC_OrgChartTopLevelController
*   *******************************************************************************************************************************************************************************************************************************************
*   @Changes

*   ******************************************************************************************************************************************************************************************************************************************* 
**/

public class OC_OrgChartTopLevelApexControllerHelper {
    
    /*
     * Method to return the origin tile name
     */
    public static String getOriginTile(){
        Organization_Chart__c orgChart = Organization_Chart__c.getValues('OrgChartData');
        String originTitle = orgChart.Origin_Tile_Title__c;
        return originTitle;
    }
    
    /*
     * Method to return the report URL
     */
    public static String exportAllURL() {
        Organization_Chart__c orgChart = Organization_Chart__c.getValues('OrgChartData');
        String exportURL = orgChart.Export_All_URL__c;
        return exportURL;
    }

	/*
	 * Get the url for the job aid doc
	 */    
    public static String getJobAidDoc(String docName) {
        system.debug('Doc Id '+docName);
        Document documents = [SELECT Id, FolderId, Folder.Name FROM Document WHERE  Name =: docName LIMIT 1];  
        
        String fullFileURL = URL.getSalesforceBaseUrl().toExternalForm();
        String URlDownload = fullFileURL+'/servlet/servlet.FileDownload?file='+documents.Id;
        
        return URlDownload;
    }
    
    /*
     * Get Field list
     */
    public static OC_OrgChartTopLevelApexController.FieldList retrieveFieldList(String ApplicationContext) {
         //create a new FieldList object
        OC_OrgChartTopLevelApexController.FieldList fl = new OC_OrgChartTopLevelApexController.FieldList();
        
        //query the Component_FieldList__c object filtering by S Object Name
        
        for(OC_Component_FieldList__c c : [Select SObjectName__c
                                           , SobjectField__c
                                           , DisplayLabel__c
                                           from OC_Component_FieldList__c 
                                           where ApplicationContext__c = :ApplicationContext
                                           order by DisplaySequence__c asc])
        {
            fl.sobjectFields.add(c.SobjectField__c);
            fl.displayLabels.add(c.DisplayLabel__c);
        }
        
        //return the field list
        return fl;
    }
    
    /*
     * method to find object Name from prefix
     */
    public static String findObjectNameFromRecordIdPrefix(String recordIdOrPrefix){
        String objectName = '';
        try{
            //Get prefix from record ID
            //This assumes that you have passed at least 3 characters
            String myIdPrefix = String.valueOf(recordIdOrPrefix).substring(0,3);
            
            //Get schema information
            Map<String, Schema.SObjectType> gd =  Schema.getGlobalDescribe(); 
            
            //Loop through all the sObject types returned by Schema
            for(Schema.SObjectType stype : gd.values()){
                Schema.DescribeSObjectResult r = stype.getDescribe();
                String prefix = r.getKeyPrefix();
                System.debug('Prefix is ' + prefix);
                
                //Check if the prefix matches with requested prefix
                if(prefix!=null && prefix.equals(myIdPrefix)){
                    objectName = r.getName();
                    System.debug('Object Name! ' + objectName);
                    break;
                }
            }
        }catch(Exception e){
            System.debug(e);
        }
        return objectName;
    }
    
    /*
     * Method to get Active Statuses from custom labels
     */
    public static List<String> getActiveStatuses () {
        String activeStatuses = '';
        List<String> activeStatusList = new List<String>();
        try {
            activeStatuses = Label.OC_Active_Status;
            system.debug('activeStatuses '+activeStatuses);
            activeStatusList = activeStatuses.split('\\,');
            system.debug('activeStatusList '+activeStatusList.size());
        } catch(Exception e) {
            system.debug(e.getMessage());
        }
        return activeStatusList;
    }
    
    /*
     * Method to get the terminated status from custom label
     */
    public static List<String> getTerminatedStatuses() {
        String terminatedStatuses = '';
        List<String> terminatedStatusesList = new List<String>();
        try {
            terminatedStatuses = Label.OC_Terminated_Status;
            system.debug('terminatedStatuses '+terminatedStatuses);
            terminatedStatusesList = terminatedStatuses.split('\\,');
            system.debug('terminatedStatusesList '+terminatedStatusesList.size());
        } catch(Exception e) {
            system.debug(e.getMessage());
        }
        return terminatedStatusesList;
    }
    
    /*
     * Get Contact based on id
     */
    public static Contact getContact(String id) {
        List<Contact> contact = new List<Contact>();
        try{
            contact = [SELECT id,positionlookup__c,FirstName, MiddleName, LastName, Suffix, Job_Abbrev__c, Org_Unit_Number__c, Organization_Unit_Name__c, Cost_Center__c, Personnel_Area__c, Personnel_SubArea_Text__c, Work_Schedule__c, Time_Admin__c, Payroll_Admin__c, Org_Key__c, Corp_Function__c, Hire_Date__c, Employment_Status__c from Contact where id=:id];
        } catch(Exception e) {
            system.debug(e.getMessage());
        }
        return contact.get(0);
    }
}
/*
Author: Raj Kumar Pandy
Description: The Batch class for updating the Case records in Documentum which failed in the Trigger call
*/
Global class Batch_ODILR_DocumentumIntegration implements database.batchable<sobject>, Database.AllowsCallouts{
    public string query; 
    //Start Method for the batch class
    Global database.querylocator start(database.batchablecontext bc){
    
        //Query integration log records for the mulesoft documentum integration related failed records that did not succeed in retries either. 
        string intgType = System.Label.ODILR_Mulesoft_Documentum_Integration;
        string failure = System.Label.ODILR_Mulesoft_API_Failure;
        string success = System.Label.ODILR_Mulesoft_API_Success;
        
        query='Select Error_Code__c, Error_Message__c, Internal_Record_ID__c from Integration_Log__c WHERE Message_Type__c = :intgType AND Status__c = :failure AND Retry_Status__c != :success';
        return database.getquerylocator(query);
    }  
    //Execute method for the batch class
    Global void execute(database.batchablecontext bc, List<Integration_Log__c> intLogRecords){
        
        Set<Id> CaseIdsSet = new Set<Id>();
        
        //Create a list of unique case ids from the integration log records that need to be passed into the API call.         
        for(Integration_Log__c intLog : intLogRecords)
            CaseIdsSet.Add(intLog.Internal_Record_ID__c);            
        
        if(CaseIdsSet.size() > 0)
            ODILR_MuleSoftAPICall.callMulesoftAPI(CaseIdsSet);  //Calling the REST Callout method 
    } 
    
    Global void finish(database.batchablecontext bc){
    
        
    } 
    
    
}
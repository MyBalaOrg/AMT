/*
Author: Raj Kumar Pandy
Description: The global class for making the REST API callout to the MuleSoft API for sending Case Object details to the Documentum.
*/
Global class ODILR_MuleSoftAPICall {
    
    //Method for creating the JSON with Case object details to be sent to the Documentum via MuleSoft
    public static void createJSON(List<Case> caseList)
    {
        Set<ID> uniqueCaseIDs = new Set<ID>();
        Map<ID,Schema.RecordTypeInfo> rt_Map = Case.sObjectType.getDescribe().getRecordTypeInfosById();
        
        //Looping for creating a map of CaseNumber and its IDs
        for(Case tempCaseObj : caseList)
        {
            if((rt_Map.get(tempCaseObj.RecordTypeId).getName() == System.Label.ODILR_Discipline_Record_Type) || 
               (rt_Map.get(tempCaseObj.RecordTypeId).getName() == System.Label.ODILR_Claims_Record_Type))
                uniqueCaseIDs.add(tempCaseObj.Id);
        }
        //Calling the future method for making the REST callout
        if(uniqueCaseIds.size() > 0)
            ODILR_MuleSoftAPICall.apiCalloutCase(uniqueCaseIDs);

    }
    
    //Future method for making the REST API callout to the MuleSoft application 
    @future(callout = true)
    global static void apiCalloutCase(Set<ID> caseIDs)
    {
        if(caseIDs != NULL)
        {
         ODILR_MuleSoftAPICall.callMulesoftAPI(caseIDs);   
        }        
    }
    
    public static void callMulesoftAPI(Set<ID> caseIDs)
    {
        //Initialising the parameters for the callout
        ODILR_Hierarchy_Setting__c hs = ODILR_Hierarchy_Setting__c.getOrgDefaults();
        
        String CID = hs.ODILR_MuleSoft_API_CID__c;
        String CSEC = hs.ODILR_MuleSoft_API_CSEC__c;
        String EndPointURL = hs.ODILR_MuleSoft_API_EndPoint__c;
        Integer timeout = Integer.ValueOf(hs.ODILR_MuleSoft_API_Timeout__c);
        Map<Id, HttpResponse> caseIdResponseMap = new Map<Id,HttpResponse>();
        
        //Response variable initialisation
        String caseJSON = '';
        String responseJSON = '';
        
        //Map for fetching Case Records
        Map<Id,Case> caseRecordMap = new Map<Id,Case>([Select Id, CaseNumber, Claimant_Name__c, RecordType.Name, SAP_Number__c, Union__r.Name, ODILR_File_Number_Second_Level__c, 
                                                       Appeal_Received_Date_Second_Level__c, Comments_Second_Level__c,  ODILR_File_Number_Third_Level__c, Appeal_Received_Date_Third_Level__c, 
                                                       Comments_Third_Level__c, Board_Level_Case_Number__c, Board_Number__c, Entered_Date__c, Comments_Board_Level__c, Award_Date__c,Decision_Date_Second_Level__c,Decision_Date_Third_Level__c,
                                                       First_Name__c, Last_Name__c from Case where ID IN : caseIDs AND (RecordType.Name =: System.Label.ODILR_Discipline_Record_Type OR RecordType.Name =: System.Label.ODILR_Claims_Record_Type)]);
        
        //Loop for making the REST Callout
        for(Case tempCaseObj : caseRecordMap.values())
        {
            ODILR_JSONWrapper wrapObj = new ODILR_JSONWrapper(tempCaseObj);
            caseJSON = JSON.serialize(wrapObj);
            System.debug('Json is ' + caseJSON);
            
            //Declaring the REST Callout request parameters
            HttpRequest httpreq = new HttpRequest();
            httpreq.setTimeout(timeout);
            httpreq.setEndpoint(EndPointURL);
            httpreq.setHeader('client_id', CID);
            httpreq.setHeader('client_secret', CSEC);
            httpreq.setHeader('Accept', 'application/json');
            httpreq.setHeader('Content-Type','application/json');
            httpreq.setBody(caseJSON);
            httpreq.setMethod('POST');
            HttpResponse httpres = new HttpResponse();
            //Exception Handler
            try
            {
                Http htp = new Http();
                httpres = htp.send(httpreq);//REST API callout to MuleSoft   
                caseIdResponseMap.Put(tempCaseObj.id,httpres);                    
            }
            catch(Exception e)
            {
                system.debug('The Error message is '+e.getMessage()+' at line number '+e.getLineNumber());
            }                
        }//for
        ODILR_MuleSoftAPICall.updateIntegrationLog(caseIdResponseMap);
    }
    
    //Method for updating the error log
    public static void updateIntegrationLog(Map<Id, HttpResponse> caseIdResponseMap)    
    { 
        //Fetching Log records 
        List<Integration_Log__c> caseIntLogList = [Select Id,Internal_Record_Id__c,Retry_Status__c FROM Integration_Log__c WHERE Internal_Record_ID__c IN :caseIdResponseMap.keySet()];
        Map<Id,Case> caseMap = new Map<Id,Case>([Select Id,CaseNumber FROM Case WHERE Id IN :caseIdResponseMap.keySet()]);
        
        //Loop for updating logs on the Integration_Log__c
        for(Integration_Log__c eachCaseIntLog : caseIntLogList){
            eachCaseIntLog.Retry_Date_Time__c = DateTime.Now();
            //Condition to update the Retry status 
            if(caseIdResponseMap.Get(eachCaseIntLog.Internal_Record_Id__c) != NULL && caseIdResponseMap.Get(eachCaseIntLog.Internal_Record_Id__c).getStatusCode() == 200)
                eachCaseIntLog.Retry_Status__c = System.Label.ODILR_Mulesoft_API_Success;
            else
                eachCaseIntLog.Retry_Status__c = System.Label.ODILR_Mulesoft_API_Failure;        
        }
        
        if(caseIntLogList.size() > 0)
            update caseIntLogList; //updating the log records
        
        List<Integration_Log__c> intLogListToInsert = new List<Integration_Log__c>();
        //Loop for creating logs on the Integration_Log__c 
        for(Id caseID : caseIdResponseMap.keySet()) {
            HttpResponse httpresp = caseIdResponseMap.Get(caseId);
        
            Integration_Log__c integLog = new Integration_Log__c(Object_Name__c = 'Case', 
                                                                 Direction__c = System.Label.ODILR_Integration_API_Call_out, 
                                                                 Message_Type__c = System.Label.ODILR_Mulesoft_Documentum_Integration,
                                                                 Processing_Mode__c = System.Label.ODILR_API_Processing_Type_Asynchronous);
            //Condition to check the Response code 
            if(httpresp.getStatusCode() == 200)
                integLog.Status__c = System.Label.ODILR_Mulesoft_API_Success;
            else
                integLog.Status__c = System.Label.ODILR_Mulesoft_API_Failure;
            
            if(caseMap.ContainsKey(caseId))
                integLog.Object_Value__c = caseMap.Get(caseId).CaseNumber;
            integLog.Error_Code__c = httpresp.getStatusCode();
            integLog.Error_Message__c = httpresp.getStatus();
            integLog.Internal_Record_ID__c = caseID;
            intLogListToInsert.Add(integLog);
        }
        
        if(intLogListToInsert.size() > 0)
            insert intLogListToInsert; //Creation of Log
    }

}
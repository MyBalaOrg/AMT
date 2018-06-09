/**
*___________________________________________________
*@Name: ST_ObservationController
*@Author: Jialin Ding
*@Created: Date: 4/19/2017
*@Used_By: SafeTrends App
*___________________________________________________
*@Description: This class has all the methods needed to provide data to the front end custom UI and get the data from there to submit it to the database.
*Methods in this class are responsible to perform auto population, correct data mapping among current User, Process, location, area, department and SBIs.
*
*___________________________________________________
*@Changes:
* MM-DD-YYY. Explanation of the change.
**/

public with sharing class ST_ObservationController{

    @AuraEnabled
    public static User currentUser {get;set;}

    @AuraEnabled
    public static String result {get;set;}
    
    private static List<process_team__c> userProcessTeam{get;set;}
    
    static{
        //Query current user record with realted child process teams
        // Jialin 7/27/2017 - Changes as per new enhancements
        currentUser= [Select id, EmployeeNumber, Name,(SELECT id,Process__c,Team_Role__c,Team_Member_Status__c,User__c FROM Process_Team__r where Team_Member_Status__c='Active') from User where id=: Userinfo.getUserId()];

        result='';

        //If current user has no process team records, then this user shall not be able to create new observation, app will return error confirmation
        if(currentUser.Process_Team__r.size()<=0){
            result = 'Error_Process_Team';
            getServerSideMessage();
        }
    }
    
    //Method which returns current user's processes as a list for selection
    @AuraEnabled
    public static List<Process__c> getCurrentUserProcesses(){
        Set<Id> processIdSet = new Set<Id>();
        for(Process_Team__c pt: currentUser.Process_Team__r){
            if(pt.Team_Member_Status__c=='Active'){
                processIdSet.add(pt.Process__c);
            }
        }

        List<Process__c> processList = new List<Process__c>();
        //based on process team this user belongs to, query processes
        if(processIdSet.size()>0){
            processList = [SELECT Name, Id from Process__c where Id IN:processIdSet];
        }
        return processList;
    }

     //Method which returns current user's process team record set as default value based on selected process
    @AuraEnabled
    public static Process_Team__c getCurrentUserObserver(Id selectedProcessId){
        Process_Team__c currentUserObserver = new Process_Team__c();
        Process_Team__c[] processTeams = [SELECT id,Name,Team_Role__c,Team_Member_Status__c,User__c FROM Process_Team__c WHERE Team_Member_Status__c='Active' AND Process__c =: selectedProcessId AND user__c =: currentUser.Id];
        if (processTeams.size()>0){
            currentUserObserver = processTeams[0];
        }
        else{
            result = 'Error_UserPermission';
        }
        return currentUserObserver;  
    }
    
    //Following code returns a list of areas based on selected location on front-end
    @AuraEnabled
    public static List<Location__c> getAreas(Id location){
        List<Location__c> areaList = new List<Location__c>();
        // Selection made for location will be used here to filter out areas under that location.
        areaList= [select id,name from Location__c where RecordType.Name=:System.Label.Safe_Trend_Area_Record_Type AND Location__c =: location];
        return areaList;
    }

    //Method which returns list of SBIs based on selected Department.
    @AuraEnabled
    public static List<SBI__c> getSBIs(string department){
        List<SBI__c> sbiList = new List<SBI__c>();
        //Selection made for department on front-end will be used here to get specific SBIs.
        sbiList= [Select name, SBI_Description__c from SBI__c where Department__c includes (:department) ORDER BY name ASC];
        system.debug('returning a total of SBI '+sbiList.size());
        return sbiList;
    }

    //Method which returns list of observation.department picklist value
    @AuraEnabled
    public static List<String> getDepartmentPickval(){
        List<String> departmentOptions = new List<String>();

        Schema.DescribeFieldResult fieldResult = Observation__c.Department__c.getDescribe();

        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

        for (Schema.PicklistEntry f: ple) {
            departmentOptions.add(f.getLabel());
        }       
        return departmentOptions;
    }

    //Method which returns list of observation.shift picklist value
    @AuraEnabled
    public static List<String> getShiftPickval(){
        List<String> shiftOptions = new List<String>();
        shiftOptions.add('-- None --');

        Schema.DescribeFieldResult fieldResult = Observation__c.Shift__c.getDescribe();

        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

        for (Schema.PicklistEntry f: ple) {
            shiftOptions.add(f.getLabel());
        }       
        return shiftOptions;
    }

    //Method which returns list of observation.craft picklist value
    @AuraEnabled
    public static List<String> getCraftPickval(){
        List<String> craftOptions = new List<String>();
        craftOptions.add('-- None --');

        Schema.DescribeFieldResult fieldResult = Observation__c.Craft__c.getDescribe();

        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

        for (Schema.PicklistEntry f: ple) {
            craftOptions.add(f.getLabel());
        }       
        return craftOptions;
    }
    
    //Method which returns list of observation.craft picklist value
    @AuraEnabled
    public static List<String> getFindingBehavePickval(){
        List<String> findingBehaveOpt = new List<String>();
        //craftOptions.add('-- None --');

        Schema.DescribeFieldResult fieldResult = Finding__c.Behavior__c.getDescribe();

        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

        for (Schema.PicklistEntry f: ple) {
            findingBehaveOpt.add(f.getLabel());
        }       
        return findingBehaveOpt;
    }

    //Method which returns list of finding.behavior picklist value
    @AuraEnabled
    public static List<String> getBehaviorPickVal(){
        List<String> behaviorOptions = new List<String>();
        //behaviorOptions.add('Choose Behavior');

        Schema.DescribeFieldResult fieldResult = Finding__c.Behavior__c.getDescribe();

        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

        for (Schema.PicklistEntry f: ple) {
            behaviorOptions.add(f.getLabel());
        }       
        return behaviorOptions;
    }

    
    //Method which search observer and coach process team based on input and return list of process team members
    @AuraEnabled
    public static List<Process_Team__c> findObserverOrCoach(String searchKey, Id selectedProcessId){
        String searchWildCard = '%'+searchKey+'%';
        List<Process_Team__c> observerList = [SELECT Id, Name,User__c FROM Process_Team__c WHERE Name LIKE :searchWildCard AND Process__c =:selectedProcessId AND Team_Member_Status__c='Active'];
        return observerList;
    }

    //Method which search location based on input and return list of locations
    @AuraEnabled
    public static List<Location__c> findAllLocations(String searchKey, String selectedProcessId){
        system.debug('selected Process Id '+selectedProcessId);
        String searchWildCard = '%'+searchKey+'%';
        List<Location__c> locationList = [SELECT Id, Name FROM Location__c WHERE Name LIKE :searchWildCard AND Process__c =:selectedProcessId AND RecordType.Name = :System.Label.Safe_Trend_Location_Record_Type];
        system.debug('location list '+locationList);
        return locationList;
    }
    
   
    //Method that takes the data from front end, validates it and inserts into the database.
    @AuraEnabled
    public static string insertObservation(Observation__c newObservation, List<Finding__c> newFindings){
        
        Boolean checkRollback = false;
        List<Finding__c> findingsToInset = new List<Finding__c>();
        system.debug(newObservation);
        system.debug(newFindings);
        
        // Get the record Type Id Safe Trends Finding record
        List<RecordType> findingsRecordType = [select id,name from RecordType where Name =:Label.ST_FindingRecordTypeName];

        //set savepoint for rollback
        Savepoint sp = Database.setSavepoint();
        //insert observation
        Database.SaveResult saveResult = Database.insert(newObservation, false);

        if(saveResult.isSuccess()){
            // Operation was successful, so get the ID of the record that was processed. Get all Findings fields
            for(Finding__c f : newFindings){
                f.Observation__c = newObservation.id;
                f.recordtypeid = findingsRecordType.get(0).Id;
                findingsToInset.add(f);
            }
        //}
        
        //insert Observation Findings to the database        
        List<Database.SaveResult> saveResult_finding = Database.insert(findingsToInset,false);
            for(Database.SaveResult findingsInsert : saveResult_finding){
                if(findingsInsert.isSuccess()){
                    System.debug('Successfully inserted Findings. Findings record ID: ' + findingsInsert.getId());
                }
                else{
                    for(Database.Error err : findingsInsert.getErrors()){                   
                        System.debug('The following error has occurred. '+err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Finding fields that affected this error: ' + err.getFields());
                    }
                    //if finding list insert returns error, check rollback observation insert to true
                    checkRollback = true;
                }
            }
            if(result!=''){
                result = result;
            }
            if (checkRollback == true && result==''){
                Database.rollback(sp);
                result = 'Error_findings';
            }
            else if(checkRollback == false && result==''){
                result = 'Success';
            }
        }else{
           // If the database insert fail, display all errors                
           for(Database.Error err : saveResult.getErrors()){                   
                System.debug('The following error has occurred. '+err.getStatusCode() + ': ' + err.getMessage());
                System.debug('Observation fields that affected this error: ' + err.getFields());
            }
            result = 'Error_observations';
        }
        return result;
    }

    //Method that returns server side dynamic error/success message
    @AuraEnabled
    public static String getServerSideMessage(){

        String serverMessage = '';
        if(result=='Error_UserPermission'){
            serverMessage = system.label.Safe_Trend_Server_Error_User_Permission;
        }
        else if (result=='Error_observations'){
            serverMessage = system.label.Safe_Trend_Server_Error_Observation;
        }
        else if (result=='Error_findings'){
            serverMessage = system.label.Safe_Trend_Server_Error_Finding;
        }
        else if(result =='Error_Process_Team') {
            serverMessage = system.label.Safe_Trend_Server_Error_Process_Team;
        }
        else if (result=='Success'){
            serverMessage = system.label.Safe_Trend_Server_Success;
        }  
        return serverMessage;
    }

    //Method to return dynamic dependent picklsit option value by entering SObject name, controlling picklist name, and dependent picklist name
    @AuraEnabled  
    public static Map<String,List<String>> getDependentOptionsImpl(string objApiName , string contrfieldApiName , string depfieldApiName){
        system.debug('Object Name: '+objApiName + ' -Controlling Field Name: ' + contrfieldApiName + ' -Dependent Field Name: ' + depfieldApiName);
           
        String objectName = objApiName.toLowerCase();
        String controllingField = contrfieldApiName.toLowerCase();
        String dependentField = depfieldApiName.toLowerCase();
        
        Map<String,List<String>> objResults = new Map<String,List<String>>();
        //get the string to sobject global map
        Map<String,Schema.SObjectType> objGlobalMap = Schema.getGlobalDescribe();
         
        if (!Schema.getGlobalDescribe().containsKey(objectName)){
            System.debug('OBJNAME NOT FOUND --.> ' + objectName);
            return null;
         }
        
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);
        if (objType==null){
            return objResults;
        }
        
        
        Map<String, Schema.SObjectField> objFieldMap = objType.getDescribe().fields.getMap();
        //Check if picklist values exist
        if (!objFieldMap.containsKey(controllingField) || !objFieldMap.containsKey(dependentField)){
            System.debug('FIELD NOT FOUND --.> ' + controllingField + ' OR ' + dependentField);
            return objResults;     
        }
        //Convert String to Schema.SobjectField
        Schema.SObjectField cntrField = objFieldMap.get(controllingField);
        Schema.SObjectField deptField = objFieldMap.get(dependentField);
        
        //Common Util Class
        objResults  = StaticUtils.getDependentOptionsImpl(deptField ,cntrField );
        return objResults;
       
    }
    
   }
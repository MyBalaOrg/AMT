/**
*___________________________________________________
*@Name:     OccupationRequirementSelector
*@Author:  Sudhindra katti
*@Created:  Date: 12/12/2017
*@Used_By:  Global 
*___________________________________________________
*@Description: Selector class for OccupationRequirement__c object 
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/
public with sharing class OccupationRequirementSelector {
    public static Boolean DoFailTest = FALSE; 
    /**
*————————————————————————————————————————————————————
* @Name: getOccRequirementQueryString
* @Description
* Specifically frames the query 
* 
*————————————————————————————————————————————————————
* @params   
* @returns  String      A method to frame the query
*————————————————————————————————————————————————————
**/
    
     public static String getOccRequirementQueryString() {  
        String myQuery; 
        
        
        QueryUtilityWrapper myQuWrap = QueryUtility.beginDynamicQuery(Label.OBJAPI_OCCUPATION_REQUIREMENT);   
        if(myQuWrap.ErrorMessage == null) { 
            
            myQuery = myQuWrap.QueryString;             
        }        
        
        return myQuery;
    }
    
       /**
*————————————————————————————————————————————————————
* @Name: getOccRequirementQueryString
* @Description
* Specifically frames the query 
* 
*————————————————————————————————————————————————————
* @params   
* @returns  String      A method to frame the query
*————————————————————————————————————————————————————
**/
    
    public static SelectorWrapper getOccRequirements(Set<ID> OccReqSet) {
        
        String myQuery = getOccRequirementQueryString();
        String myErrorMessage; 
        
        List<OccupationRequirement__c> occRequirementList = new List<OccupationRequirement__c>(); 
        List<Sobject> mySobjectList = new List<Sobject>();
        
        myQuery += System.Label.WHERE +' Id IN :  OccReqSet';
        if(Test.isRunningTest() && DoFailTest) {
                myQuery = myQuery.replace('SELECT', 'FAIL') ;
        }
        try {
            
            occRequirementList = Database.query(myQuery); 
        
        } catch(QueryException qe) {
            
            system.debug(System.Label.SOQL_Query_Error + qe.getMessage() );
            myErrorMessage = System.Label.QueryErrorSobjectException + qe.getMessage();
        }
        mySobjectList = occRequirementList;
        
        SelectorWrapper myWrap = new SelectorWrapper(myErrorMessage, mySobjectList); 
        return myWrap;
 }

/**
*————————————————————————————————————————————————————
* @Name: getOccRequirementQueryString
* @Description
* Specifically frames the query 
* 
*————————————————————————————————————————————————————
* @params   
* @returns  String      A method to frame the query
*————————————————————————————————————————————————————
**/
    
    public static SelectorWrapper getOccReqByName(Set<String> OccReqNameSet) {
        
        String myQuery = getOccRequirementQueryString();
        String myErrorMessage; 
        
        List<OccupationRequirement__c> occRequirementList = new List<OccupationRequirement__c>(); 
        List<Sobject> mySobjectList = new List<Sobject>();
        
        myQuery += ' WHERE Name IN :OccReqNameSet';
        if(Test.isRunningTest() && DoFailTest) {
                myQuery = myQuery.replace('SELECT', 'FAIL') ;
        }
        try {
            
            occRequirementList = Database.query(myQuery); 
        
        } catch(QueryException qe) {
            
            system.debug(System.Label.SOQL_Query_Error + qe.getMessage() );
            myErrorMessage = System.Label.QueryErrorSobjectException + qe.getMessage();
        }
        mySobjectList = occRequirementList;
        
        SelectorWrapper myWrap = new SelectorWrapper(myErrorMessage, mySobjectList); 
        return myWrap;
 }
/*
*————————————————————————————————————————————————————
* @Name: getObsByTestNum
* @Description
* Retrieves Occupation Requirement SPARTN Observation records 
* by Test Number 
*————————————————————————————————————————————————————
* @params   
* @returns  String      A method to frame the query
*————————————————————————————————————————————————————
**/
    
    public static SelectorWrapper getObsByTestNum(Set<String> theTestNumSet) {
        
        String myQuery = getOccRequirementQueryString();
        String myErrorMessage; 

        ID myObsRecType = OccupationRequirementStaticUtility.OCCREQUIREMENT_SPARTNOBSERVATION_RECTYPE_ID; 

        List<OccupationRequirement__c> occRequirementList = new List<OccupationRequirement__c>(); 
        List<Sobject> mySobjectList = new List<Sobject>();

        myQuery += ' WHERE RecordTypeId = :myObsRecType ';
        myQuery += ' AND TestNumber__c IN :theTestNumSet'; 
        if(Test.isRunningTest() && DoFailTest) {
                myQuery = myQuery.replace('SELECT', 'FAIL') ;
        }
        try {
            
            occRequirementList = Database.query(myQuery); 
        
        } catch(QueryException qe) {
            
            system.debug(System.Label.SOQL_Query_Error + qe.getMessage() );
            myErrorMessage = System.Label.QueryErrorSobjectException + qe.getMessage();
        }
        mySobjectList = occRequirementList;

        system.debug('myErrorMessage ' + myErrorMessage); 
        system.debug('mySobjectList ' + mySobjectList); 
        
        SelectorWrapper myWrap = new SelectorWrapper(myErrorMessage, mySobjectList); 
        return myWrap;
 }

 /*
*————————————————————————————————————————————————————
* @Name: getObsByTestName
* @Description
* Retrieves Occupation Requirement SPARTN Observation records 
* by Test Number 
*————————————————————————————————————————————————————
* @params   
* @returns  String      A method to frame the query
*————————————————————————————————————————————————————
**/
    
    public static SelectorWrapper getObsByTestName(Set<String> theTestNameSet) {
        
        String myQuery = getOccRequirementQueryString();
        String myErrorMessage; 

        ID myObsRecType = OccupationRequirementStaticUtility.OCCREQUIREMENT_SPARTNOBSERVATION_RECTYPE_ID; 

        List<OccupationRequirement__c> occRequirementList = new List<OccupationRequirement__c>(); 
        List<Sobject> mySobjectList = new List<Sobject>();

        myQuery += ' WHERE RecordTypeId = :myObsRecType ';
        myQuery += ' AND TestName__c IN :theTestNameSet'; 
        if(Test.isRunningTest() && DoFailTest) {
                myQuery = myQuery.replace('SELECT', 'FAIL') ;
        }
        try {
            
            occRequirementList = Database.query(myQuery); 
        
        } catch(QueryException qe) {
            
            system.debug(System.Label.SOQL_Query_Error + qe.getMessage() );
            myErrorMessage = System.Label.QueryErrorSobjectException + qe.getMessage();
        }
        mySobjectList = occRequirementList;

        system.debug('myErrorMessage ' + myErrorMessage); 
        system.debug('mySobjectList ' + mySobjectList); 
        
        SelectorWrapper myWrap = new SelectorWrapper(myErrorMessage, mySobjectList); 
        return myWrap;
 }
}
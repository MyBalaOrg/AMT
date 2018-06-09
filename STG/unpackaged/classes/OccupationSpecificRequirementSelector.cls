/**
*___________________________________________________
*@Name:     OccupationSpecificRequirementSelector
*@Author:   Hemanth Kesapragada
*@Created:  Date: 11/21/2017
*@Used_By:  Global 
*___________________________________________________
*@Description: Selector class for OccupationSpecificRequirement__c object 
*___________________________________________________
*@Changes: 
* 04-02-2018 getOccSpecificRequirementsFrmTestNum()- Add "Status__c = Active" to selection [cwalley] 
**/
public with sharing class OccupationSpecificRequirementSelector {
    public static Boolean DoFailTest = FALSE; 
    /**
*————————————————————————————————————————————————————
* @Name: getOccSpecificReqQueryString
* @Description
* Specifically frames the query 
* 
*————————————————————————————————————————————————————
* @params   
* @returns  String      A method to frame the query
*————————————————————————————————————————————————————
**/
    public static String getOccSpecificReqQueryString() {  
        String myQuery; 
        
        
        QueryUtilityWrapper myQuWrap = QueryUtility.beginDynamicQuery(Label.OBJAPI_OCCUPATION_SPECIFIC_REQUIREMENT);   
        if(myQuWrap.ErrorMessage == null) { 
            
            myQuery = myQuWrap.QueryString; 
            
        }
        
        
        return myQuery;
    }
    
/**
*————————————————————————————————————————————————————
* @Name: getSpecificRequirements
* @Description
* Fetches the OccupationSpecificRequirement records 
*————————————————————————————————————————————————————
* @params   
* @returns  SelectorWrapper         Fetches the required OccupationSpecificRequirement based on the where clause
*————————————————————————————————————————————————————
**/
    public static SelectorWrapper getSpecificRequirements(Set<ID> OccRequirementSet)
    {
        String myQuery = getOccSpecificReqQueryString();
        String myErrorMessage; 
        
        List<OccupationSpecificRequirement__c> ocSpecRequirementList = new List<OccupationSpecificRequirement__c>(); 
        List<Sobject> mySobjectList = new List<Sobject>();
        
        myQuery += System.Label.WHERE +' Requirement__c IN :  OccRequirementSet';
        if(Test.isRunningTest() && DoFailTest) {
            myQuery = myQuery.replace('SELECT', 'FAIL') ;
        }
        try {
            
            ocSpecRequirementList = Database.query(myQuery); 
            
        } catch(QueryException qe) {
            
            system.debug(System.Label.SOQL_Query_Error + qe.getMessage() );
            myErrorMessage = System.Label.QueryErrorSobjectException + qe.getMessage();
        }
        mySobjectList = ocSpecRequirementList;
        
        SelectorWrapper myWrap = new SelectorWrapper(myErrorMessage, mySobjectList); 
        
        return myWrap;
        
    }
/**
*————————————————————————————————————————————————————
* @Name: getById
* @Description
* Fetches the OccupationSpecificRequirement records 
*————————————————————————————————————————————————————
* @params   
* @returns  SelectorWrapper         Fetches the required OccupationSpecificRequirement based on the where clause
*————————————————————————————————————————————————————
**/
    public static SelectorWrapper getById(Set<ID> occIdSet)
    {
        String myQuery = getOccSpecificReqQueryString();
        String myErrorMessage; 
        
        List<OccupationSpecificRequirement__c> ocSpecRequirementList = new List<OccupationSpecificRequirement__c>(); 
        List<Sobject> mySobjectList = new List<Sobject>();
        
        myQuery += System.Label.WHERE +' Id IN :  occIdSet';
        if(Test.isRunningTest() && DoFailTest) {
            myQuery = myQuery.replace('SELECT', 'FAIL') ;
        }
        try {
            
            ocSpecRequirementList = Database.query(myQuery); 
            
        } catch(QueryException qe) {
            
            system.debug(System.Label.SOQL_Query_Error + qe.getMessage() );
            myErrorMessage = System.Label.QueryErrorSobjectException + qe.getMessage();
        }
        mySobjectList = ocSpecRequirementList;
        
        SelectorWrapper myWrap = new SelectorWrapper(myErrorMessage, mySobjectList); 
        
        return myWrap;
        
    }
    
    /**
*————————————————————————————————————————————————————
* @Name: getOccSpecificRequirementsFrmTestNum
* @Description
* Fetches the OccupationSpecificRequirement records based on TestNumber 
*————————————————————————————————————————————————————
* @params   
* @returns  SelectorWrapper         Fetches the required OccupationSpecificRequirement based on the TestNumber 
*————————————————————————————————————————————————————
**/
    public static SelectorWrapper getOccSpecificRequirementsFrmTestNum(Set<String> OccSpRequirementSet,Set<String> RecordTypeNameSet)
    {
        String myQuery = getOccSpecificReqQueryString();
        String myErrorMessage; 
        String newQuery;
        
        List<OccupationSpecificRequirement__c> occSpecRequirementList = new List<OccupationSpecificRequirement__c>(); 
        List<Sobject> mySobjectList = new List<Sobject>();

        Id TARGETID = OccupationSpecificReqStaticUtility.OCC_SPEC_REQ_SPARTNTARGET_RECTYPE_ID; 
        
        if(!String.isBlank(myQuery)){
            if(!OccSpRequirementSet.isEmpty()){
                myQuery += System.Label.WHERE +' RecordTypeId = :TARGETID ';
                myQuery += System.Label.AND +' Test_Number__c IN :OccSpRequirementSet ';
                myQuery += ' '+System.Label.AND +' Status__c = \''+RevSys_StaticUtility.ACTIVE+'\' ';
            	// cw 2/21 myQuery += ' '+System.Label.AND +' Observation__r.SourceRecordType__c IN : RecordTypeNameSet';
            }else
            {
                myQuery += System.Label.WHERE +' Observation__r.SourceRecordType__c IN : RecordTypeNameSet';
            }
            
            newQuery = myQuery.replace(System.Label.SELECT,System.Label.Revsys_Observation_r_SourceRecordType_c);
             if(Test.isRunningTest() && DoFailTest) {
                newQuery = newQuery.replace('SELECT', 'FAIL') ;
            }
        }
        try {
            if(!String.isBlank(newQuery))
                occSpecRequirementList = Database.query(newQuery); 
        
        } catch(QueryException qe) {
            
            system.debug(System.Label.SOQL_Query_Error + qe.getMessage() );
            myErrorMessage = System.Label.QueryErrorSobjectException + qe.getMessage();
        }
        mySobjectList = occSpecRequirementList;
        
        SelectorWrapper myWrap = new SelectorWrapper(myErrorMessage, mySobjectList); 
        return myWrap;
    }
    /**
*————————————————————————————————————————————————————
* @Name: getOccSpecReqCertification
* @Description
* Fetches the OccupationSpecificRequirement records 
*————————————————————————————————————————————————————
* @params   
* @returns  SelectorWrapper         Fetches the required OccupationSpecificRequirement based on the where clause
*————————————————————————————————————————————————————
**/
    public static SelectorWrapper getOccSpecReqCertification(Set<ID> OccCertSet)
    {
        
        String myQuery = getOccSpecificReqQueryString();
        String myErrorMessage; 
        
        List<OccupationSpecificRequirement__c> ocSpecRequirementList = new List<OccupationSpecificRequirement__c>(); 
        List<Sobject> mySobjectList = new List<Sobject>();
        
        myQuery += System.Label.WHERE +' Certification__c IN :  OccCertSet';
        system.debug('Set'+ OccCertSet);
        system.debug('Selector query'+ myQuery);
        if(Test.isRunningTest() && DoFailTest) {
            myQuery = myQuery.replace('SELECT', 'FAIL') ;
        }
        try {
            
            ocSpecRequirementList = Database.query(myQuery); 
            
        } catch(QueryException qe) {
            
            system.debug(System.Label.SOQL_Query_Error + qe.getMessage() );
            myErrorMessage = System.Label.QueryErrorSobjectException + qe.getMessage();
        }
        mySobjectList = ocSpecRequirementList;
        
        SelectorWrapper myWrap = new SelectorWrapper(myErrorMessage, mySobjectList); 
        
        return myWrap;
        
    }
    /** ——————————————————————————————————————————————————
    * @Name: getOccSpecReqTarget
    * @Description
    * Fetches the OccupationSpecificRequirement records 
    *————————————————————————————————————————————————————
    * @params   
    * @returns  SelectorWrapper         Fetches the required OccupationSpecificRequirement based on the target Id set
    *————————————————————————————————————————————————————
    **/
    public static SelectorWrapper getOccSpecReqTarget(Set<ID> targetIdSet)
    {
        String myQuery = getOccSpecificReqQueryString();
        String myErrorMessage; 
        
        List<OccupationSpecificRequirement__c> ocSpecRequirementList = new List<OccupationSpecificRequirement__c>(); 
        List<Sobject> mySobjectList = new List<Sobject>();
        
        myQuery += System.Label.WHERE +' Target__c IN :  targetIdSet';
        myQuery += ' '+System.Label.AND +' Status__c = \'Active\'';
        if(Test.isRunningTest() && DoFailTest) {
            myQuery = myQuery.replace('SELECT', 'FAIL') ;
        }
        system.debug('Selector query'+ myQuery);
        
        try {
            
            ocSpecRequirementList = Database.query(myQuery); 
            
        } catch(QueryException qe) {
            
            system.debug(System.Label.SOQL_Query_Error + qe.getMessage() );
            myErrorMessage = System.Label.QueryErrorSobjectException + qe.getMessage();
        }
        mySobjectList = ocSpecRequirementList;
        
        SelectorWrapper myWrap = new SelectorWrapper(myErrorMessage, mySobjectList); 
        
        return myWrap;
        
    }
    /** ——————————————————————————————————————————————————
    * @Name: getOsrTargetReq
    * @Description
    * Fetches the OccupationSpecificRequirement records 
    *————————————————————————————————————————————————————
    * @params   
    * @returns  SelectorWrapper         Fetches the required OccupationSpecificRequirement based on the target requirement Id set
    *————————————————————————————————————————————————————
    **/
    public static SelectorWrapper getOsrTargetReq(Set<ID> targetReqIdSet)
    {
        system.debug('HELPER OccupationSpecificRequirementSelector getOccSpecReqCertification-Start');
        system.debug('targetReqIdSet  ' + targetReqIdSet);

        String myQuery = getOccSpecificReqQueryString();
        String myErrorMessage; 
        
        List<OccupationSpecificRequirement__c> ocSpecRequirementList = new List<OccupationSpecificRequirement__c>(); 
        List<Sobject> mySobjectList = new List<Sobject>();
        
        myQuery += System.Label.WHERE +' TargetRequirement__c IN :  targetReqIdSet';
        myQuery += ' '+System.Label.AND +' Status__c = \'Active\'';
        myQuery += ' '+System.Label.AND +' RecordTypeId =\''+OccupationSpecificReqStaticUtility.OCC_SPEC_REQ_SPARTNTARGET_RECTYPE_ID+'\'';
        if(Test.isRunningTest() && DoFailTest) {
            myQuery = myQuery.replace('SELECT', 'FAIL') ;
        }
        system.debug('Selector query'+ myQuery);
        
        try {
            
            ocSpecRequirementList = Database.query(myQuery); 
            
        } catch(QueryException qe) {
            
            system.debug(System.Label.SOQL_Query_Error + qe.getMessage() );
            myErrorMessage = System.Label.QueryErrorSobjectException + qe.getMessage();
        }

        system.debug('ocSpecRequirementList size  ' + ocSpecRequirementList.size());
        system.debug('ocSpecRequirementList  ' + ocSpecRequirementList);


        mySobjectList = ocSpecRequirementList;
        
        SelectorWrapper myWrap = new SelectorWrapper(myErrorMessage, mySobjectList); 
        
        return myWrap;
        
    }
}
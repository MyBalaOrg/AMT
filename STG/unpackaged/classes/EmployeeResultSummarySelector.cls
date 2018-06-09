/**
*___________________________________________________
*@Name: 	EmployeeResultSummarySelector
*@Author: 	Hemanth Kesapragada
*@Created: 	Date: 11/28/2017
*@Used_By: 	Global 
*___________________________________________________
*@Description: Selector class for EmployeeResultSummary__c object 
*___________________________________________________
*@Changes: 
* 02-07-2017. Hemanth - Added method getMedicalHearingVisionERS
* 
**/
public with sharing class EmployeeResultSummarySelector {
    public static Boolean DoFailTest = FALSE;
	/**
    *————————————————————————————————————————————————————
    * @Name: getEmpResultSumQueryString
    * @Description
    * Specifically frames the query 
    * 
    *————————————————————————————————————————————————————
    * @params  	
    * @returns  String		A method to frame the query
    *————————————————————————————————————————————————————
    **/
    public static String getEmpResultSumQueryString() {  
    	String myQuery; 


    	QueryUtilityWrapper myQuWrap = QueryUtility.beginDynamicQuery(Label.OBJAPI_EMPLOYEE_RESULT_SUMMARY);   
    	if(myQuWrap.ErrorMessage == null) { 

    		myQuery = myQuWrap.QueryString; 

    	}


    	return myQuery;
    }
    /**
    *————————————————————————————————————————————————————
    * @Name: getEmployeeResultSummary related to Observatio records
    * @Description
    * Fetches the EmployeeResultSummary records 
    *————————————————————————————————————————————————————
    * @params  	
    * @returns  SelectorWrapper			Fetches the required EmployeeResultSummary records based on the where clause
    *————————————————————————————————————————————————————
    **/
    public static SelectorWrapper getEmployeeResultSummary(Set<ID> theObjIds)
    {
        String myQuery = getEmpResultSumQueryString();
        String myErrorMessage; 
        
        List<EmployeeResultSummary__c> eResultSummaryList = new List<EmployeeResultSummary__c>(); 
        List<Sobject> mySobjectList = new List<Sobject>();
        
		myQuery += ' WHERE Observation__c IN :  theObjIds';
         if(Test.isRunningTest() && DoFailTest) {
            myQuery = myQuery.replace('SELECT', 'FAIL') ;
            }

    		try {

    			eResultSummaryList = Database.query(myQuery); 

			} catch(QueryException qe) {

				system.debug(System.Label.SOQL_Query_Error + qe.getMessage() );
				myErrorMessage = System.Label.QueryErrorSobjectException + qe.getMessage();
			}
        mySobjectList = eResultSummaryList;
        
        SelectorWrapper myWrap = new SelectorWrapper(myErrorMessage, mySobjectList); 
        
        return myWrap;
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Name: getMotorVehicleReviewERS related to Contact records
    * @Description
    * Fetches the EmployeeResultSummary records 
    *————————————————————————————————————————————————————
    * @params  	
    * @returns  SelectorWrapper			Fetches the required EmployeeResultSummary records based on the where clause
    *————————————————————————————————————————————————————
    **/
    public static SelectorWrapper getMotorVehicleReviewERS(Set<ID> contactIds)
    {
        String myQuery = getEmpResultSumQueryString();
        String myErrorMessage; 
        List<EmployeeResultSummary__c> eResultSummaryList = new List<EmployeeResultSummary__c>(); 
        List<Sobject> mySobjectList = new List<Sobject>();
        
        myQuery += System.Label.WHERE +' Employee__c IN :  contactIds';
        myQuery += ' '+System.Label.AND +' RecordTypeId =\'' + EmployeeResultSummaryStaticUtility.EMP_RES_SUMM_MOTORVEHICLE_RECTYPE_ID+'\'';
        myQuery += ' order by createdDate ASC';
        
         if(Test.isRunningTest() && DoFailTest) {
            myQuery = myQuery.replace('SELECT', 'FAIL') ;
            }
        try {
            eResultSummaryList = Database.query(myQuery); 
        } 
        catch(QueryException qe) {
            system.debug(System.Label.SOQL_Query_Error + qe.getMessage() );
            myErrorMessage = System.Label.QueryErrorSobjectException + qe.getMessage();
        }
        mySobjectList = eResultSummaryList;
        SelectorWrapper myWrap = new SelectorWrapper(myErrorMessage, mySobjectList); 
        return myWrap;
    }

     /**
    *————————————————————————————————————————————————————
    * @Name: getMedicalHearingVisionERS 
    * @Description
    * Fetches the EmployeeResultSummary records of Medical Hearing and Vision RecordType related to Contact records
    *————————————————————————————————————————————————————
    * @params   
    * @returns  SelectorWrapper        Fetches the required EmployeeResultSummary records based on the where clause
    *————————————————————————————————————————————————————
    **/
    public static SelectorWrapper getMedicalHearingVisionERS(Set<ID> contactIds)
    {
        String myQuery = getEmpResultSumQueryString();
        String myErrorMessage; 
        List<EmployeeResultSummary__c> eResultSummaryList = new List<EmployeeResultSummary__c>(); 
        List<Sobject> mySobjectList = new List<Sobject>();
        
        myQuery += System.Label.WHERE +' Employee__c IN :  contactIds';
        myQuery += ' '+System.Label.AND +' RecordTypeId =\'' + EmployeeResultSummaryStaticUtility.EMP_RES_SUMM_MEDICAL_RECTYPE_ID+'\'';
        myQuery += ' order by createdDate ASC';
        
         if(Test.isRunningTest() && DoFailTest) {
            myQuery = myQuery.replace('SELECT', 'FAIL') ;
            }
        try{
            eResultSummaryList = Database.query(myQuery); 
        } 
        catch(QueryException qe) {
            system.debug(System.Label.SOQL_Query_Error + qe.getMessage() );
            myErrorMessage = System.Label.QueryErrorSobjectException + qe.getMessage();
        }
        mySobjectList = eResultSummaryList;
        SelectorWrapper myWrap = new SelectorWrapper(myErrorMessage, mySobjectList); 
        return myWrap;
    }
    
       /**
    *————————————————————————————————————————————————————
    * @Name: getEmployeeSummaryRecords 
    * @Description
    * Fetches the EmployeeResultSummary records of tests taken by the employee for selected record types
    *————————————————————————————————————————————————————
    * @params   
    * @returns  SelectorWrapper        Fetches the required EmployeeResultSummary records based on the where clause
    *————————————————————————————————————————————————————
    **/
    public static SelectorWrapper getEmployeeSummaryRecords(Set<ID> contactIds, Set<ID> recordTypeId)
    {
        String myQuery = getEmpResultSumQueryString();
        String myErrorMessage; 
        List<EmployeeResultSummary__c> eResultSummaryList = new List<EmployeeResultSummary__c>(); 
        List<Sobject> mySobjectList = new List<Sobject>();
        
        myQuery += System.Label.WHERE +' Employee__c IN :  contactIds';
        myQuery += ' '+System.Label.AND +' RecordTypeId IN : recordTypeId';
        myQuery += ' order by Observation__r.SectionTower__c DESC';
        myQuery = myQuery.replace('SELECT', 'SELECT Employee__r.name,Observation__r.name,Observation__r.SectionTower__c,Observation__r.OverallScore__c,Observation__r.SubmissionDateTime__c,') ;   
        
        System.debug('myqueryEmpSumm$$'+myQuery);
        
         if(Test.isRunningTest() && DoFailTest) {
            myQuery = myQuery.replace('SELECT', 'FAIL') ;
            }
        
        try {
            eResultSummaryList = Database.query(myQuery); 
        } 
        
        
        
      	catch(QueryException qe) {
            system.debug(System.Label.SOQL_Query_Error + qe.getMessage() );
            myErrorMessage = System.Label.QueryErrorSobjectException + qe.getMessage();
        }
        mySobjectList = eResultSummaryList;
        SelectorWrapper myWrap = new SelectorWrapper(myErrorMessage, mySobjectList); 
        return myWrap;
    }
    /**
    *————————————————————————————————————————————————————
    * @Name: getErsByEmpIdTestNumber 
    * @Description
    * Fetches the EmployeeResultSummary records of tests taken by the employee for selected record types
    *————————————————————————————————————————————————————
    * @params   
    * @returns  SelectorWrapper        Fetches the required EmployeeResultSummary records based on the where clause
    *————————————————————————————————————————————————————
    **/
    public static SelectorWrapper getErsByEmpIdTestNumber(Set<ID> contactIds, Set<String> testNumbers)
    {
        String myQuery = getEmpResultSumQueryString();
        String myErrorMessage; 
        List<EmployeeResultSummary__c> eResultSummaryList = new List<EmployeeResultSummary__c>(); 
        List<Sobject> mySobjectList = new List<Sobject>();
        
        myQuery += System.Label.WHERE +' Employee__c IN :  contactIds';
        myQuery += ' '+System.Label.AND +' TestNUmber__c IN : testNumbers';
        myQuery += ' order by createdDate ASC';  
        
         if(Test.isRunningTest() && DoFailTest) {
            myQuery = myQuery.replace('SELECT', 'FAIL') ;
            }
        
        System.debug('myqueryEmpSumm$$'+myQuery);
        
        try {
            eResultSummaryList = Database.query(myQuery); 
        } 
        
      	catch(QueryException qe) {
            system.debug(System.Label.SOQL_Query_Error + qe.getMessage() );
            myErrorMessage = System.Label.QueryErrorSobjectException + qe.getMessage();
        }
        mySobjectList = eResultSummaryList;
        SelectorWrapper myWrap = new SelectorWrapper(myErrorMessage, mySobjectList); 
        return myWrap;
    }

    /**
    *————————————————————————————————————————————————————
    * @Name: getErsByEmployeeAndSourceInfo
    * @Description
    * Fetches the EmployeeResultSummary records of tests taken by the employee for selected record types
    *————————————————————————————————————————————————————
    * @params   
    * @returns  SelectorWrapper        Fetches the required EmployeeResultSummary records based on the where clause
    *————————————————————————————————————————————————————
    **/
    public static SelectorWrapper getErsByEmployeeAndSourceInfo(Set<ID> contactIds, Set<Id> recTypeIdSet, Set<String> typeSet, Date earliestDate )
    {
        system.debug('SELECTOR EmployeeResultSummarySelector getErsByEmployeeAndSourceInfo-Start');   
        system.debug('contactIds  '   + contactIds); 
        system.debug('recTypeIdSet  ' + recTypeIdSet); 
        system.debug('typeSet  '      + typeSet); 
        system.debug('earliestDate  ' + earliestDate); 

        String myQuery = getEmpResultSumQueryString();
        String myErrorMessage; 
        List<EmployeeResultSummary__c> eResultSummaryList = new List<EmployeeResultSummary__c>(); 
        List<Sobject> mySobjectList = new List<Sobject>();
        
        myQuery += System.Label.WHERE +'   Employee__c   IN :contactIds ';
        myQuery += ' '+System.Label.AND +' RecordTypeId  IN :recTypeIdSet ';
        //myQuery += ' '+System.Label.AND +' Type__c       IN :typeSet ';
        myQuery += ' AND ( EvaluationDate__c  >= :earliestDate '; 
        myQuery += '  or   NdrReviewDate__c   >= :earliestDate ';
        myQuery += '  or   ReviewDate__c      >= :earliestDate ';
        myQuery += '  or   StateReviewDate__c >= :earliestDate) ';
        myQuery += ' order by createdDate ASC';  
        
         if(Test.isRunningTest() && DoFailTest) {
            myQuery = myQuery.replace('SELECT', 'FAIL') ;
            }
        
        System.debug('myqueryEmpSumm$$'+myQuery);
        
        try {
            eResultSummaryList = Database.query(myQuery); 
        } 
        
        catch(QueryException qe) {
            system.debug(System.Label.SOQL_Query_Error + qe.getMessage() );
            myErrorMessage = System.Label.QueryErrorSobjectException + qe.getMessage();
        }

        system.debug('eResultSummaryList  ' + eResultSummaryList); 

        mySobjectList = eResultSummaryList;
        SelectorWrapper myWrap = new SelectorWrapper(myErrorMessage, mySobjectList); 

        system.debug('SELECTOR EmployeeResultSummarySelector getErsByEmployeeAndSourceInfo-End');  
        return myWrap;
    }
}
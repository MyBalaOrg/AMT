/**
*___________________________________________________
*@Name: 	EmployeeSpecificRequirementSelector
*@Author: 	Hemanth Kesapragada
*@Created: 	Date: 11/22/2017
*@Used_By: 	Global 
*___________________________________________________
*@Description: Selector class for EmployeeSpecificRequirement__c object 
*___________________________________________________
*@Changes: 
* 04-02-2018 getEmpSpecReqFrmEmpAndTargetOrReq()- Add "Status__c = Active" to selection [cwalley] 
**/
global with sharing class EmployeeSpecificRequirementSelector {
	public static Boolean DoFailTest = FALSE;
	/**
	*————————————————————————————————————————————————————
	* @Name: getEmpSpecificReqQueryString
	* @Description
	* Specifically frames the query 
	* 
	*————————————————————————————————————————————————————
	* @params  	
	* @returns  String		A method to frame the query
	*————————————————————————————————————————————————————
	**/
	public static String getEmpSpecificReqQueryString() {  
		String myQuery; 


		QueryUtilityWrapper myQuWrap = QueryUtility.beginDynamicQuery(Label.OBJAPI_EMPLOYEE_SPECIFIC_REQUIREMENT);   
		if(myQuWrap.ErrorMessage == null) { 

			myQuery = myQuWrap.QueryString; 
	        
		}


		return myQuery;
	}
	/**
    *————————————————————————————————————————————————————
    * @Name: getEmployeeSpecificTargets
    * @Description
    * Return Targets associated employee
    * 
    * @returns  SelectorWrapper		A wrapper class containing the errorMessage and the List 
    *————————————————————————————————————————————————————
    **/
	 public static SelectorWrapper getEmployeeSpecificTargets(Set<String> contactIds) {
	 	String myQuery = getEmpSpecificReqQueryString();

        String myErrorMessage; 
        List<EmployeeSpecificRequirement__c> empSpecificRequirements = new List<EmployeeSpecificRequirement__c>(); 

            myQuery += ' WHERE recordTypeId =\'' + EmployeeSpecificRequirementStaticUtility.EMP_SPEC_REQ_SPARTNTARGET_RECTYPE_ID+'\''; 
            myQuery += ' AND Employee__c IN :contactIds';
         	myQuery += ' AND Archived__c = '+ FALSE;
         
            if(Test.isRunningTest() && DoFailTest) {
            myQuery = myQuery.replace('SELECT', 'FAIL') ;
            }

            
            try {
                
                empSpecificRequirements = Database.query(myQuery); 

            } catch(QueryException qe) {

                system.debug(System.Label.SOQL_Query_Error + qe.getMessage() );
                myErrorMessage = System.Label.QueryErrorSobjectException + qe.getMessage();
            }


        SelectorWrapper myWrap = new SelectorWrapper(myErrorMessage, empSpecificRequirements); 

        return myWrap;
    }

    /**
    *————————————————————————————————————————————————————
    * @Name: getOccEmpSpecRequirementsRelated
    * @Description
    * Specifically returns records 
    * 
    *————————————————————————————————————————————————————
    * @params  	
    * @returns  SelectorWrapper		A wrapper class containing the errorMessage and the List 
    *————————————————————————————————————————————————————
    **/
    public static SelectorWrapper getOccEmpSpecRequirementsRelated(Set<ID> OccCertSet) {  
       	String myQuery = getEmpSpecificReqQueryString();

        String myErrorMessage; 
        List<EmployeeSpecificRequirement__c> empSpecRequirementsList = new List<EmployeeSpecificRequirement__c>(); 
        List<SObject> mySObjectList = new List<SObject>(); 

            myQuery += ' WHERE Target__c IN :  OccCertSet';
        	myQuery += ' AND Archived__c = '+ FALSE;
            
            if(Test.isRunningTest() && DoFailTest) {
                myQuery = myQuery.replace('SELECT', 'FAIL') ;
            }
            
            try {
                
                empSpecRequirementsList = Database.query(myQuery); 

            } catch(QueryException qe) {

                system.debug(System.Label.SOQL_Query_Error + qe.getMessage());
                myErrorMessage = System.Label.QueryErrorSobjectException + qe.getMessage();
            }
        mySObjectList = empSpecRequirementsList; 

        SelectorWrapper myWrap = new SelectorWrapper(myErrorMessage, mySObjectList); 

        return myWrap;
    }
    /**
    *————————————————————————————————————————————————————
    * @Name: getOccReqEmpSpecificRequirements
    * @Description
    * Return the requirement associated records
    * 
    * @returns  SelectorWrapper		A wrapper class containing the errorMessage and the List 
    *————————————————————————————————————————————————————
    **/
	 public static SelectorWrapper getOccReqEmpSpecificRequirements(Set<ID> occRequirementSet) {
	 	String myQuery = getEmpSpecificReqQueryString();

        String myErrorMessage; 
        List<EmployeeSpecificRequirement__c> empSpecificRequirements = new List<EmployeeSpecificRequirement__c>();
        List<Sobject> mySobjectList = new List<Sobject>();

            myQuery += ' WHERE Requirement__c IN :OccRequirementSet';
         	myQuery += ' AND Archived__c = '+ FALSE;
         
            if(Test.isRunningTest() && DoFailTest) {
            myQuery = myQuery.replace('SELECT', 'FAIL') ;
            }
            
            try {
                
                empSpecificRequirements = Database.query(myQuery); 

            } catch(QueryException qe) {

                system.debug(System.Label.SOQL_Query_Error + qe.getMessage() );
                myErrorMessage = System.Label.QueryErrorSobjectException + qe.getMessage();
            }
         mySobjectList = empSpecificRequirements;


        SelectorWrapper myWrap = new SelectorWrapper(myErrorMessage, mySobjectList); 

        return myWrap;
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Name: getEmpSpecReqFrmEmpAndTarget
    * @Description
    * Specifically returns records EmployeeSpecificRequirement__c based on Employee and Target 
    * 
    *————————————————————————————————————————————————————
    * @params  	
    * @returns  SelectorWrapper		A wrapper class containing the errorMessage and the List 
    *————————————————————————————————————————————————————
    **/
    public static SelectorWrapper getEmpSpecReqFrmEmpAndTarget(Set<ID> occCertSet, Set<ID> employeeSet) {  
       	String myQuery = getEmpSpecificReqQueryString();

        String myErrorMessage; 
        List<EmployeeSpecificRequirement__c> empSpecRequirementsList = new List<EmployeeSpecificRequirement__c>(); 
        List<SObject> mySObjectList = new List<SObject>(); 
        String currentDate = AMTRAK_DateUtility.processDate(System.today());

            myQuery += ' WHERE Target__c IN :OccCertSet and Employee__c IN : EmployeeSet';
        	myQuery += ' AND Archived__c = '+ FALSE;
            
            system.debug('The Query is '+myQuery);
        
           if(Test.isRunningTest() && DoFailTest) {
            myQuery = myQuery.replace('SELECT', 'FAIL') ;
            }

            
            try {
                
                empSpecRequirementsList = Database.query(myQuery); 

            } catch(QueryException qe) {

                system.debug(System.Label.SOQL_Query_Error + qe.getMessage());
                myErrorMessage = System.Label.QueryErrorSobjectException + qe.getMessage();
            }
        mySObjectList = empSpecRequirementsList; 

        SelectorWrapper myWrap = new SelectorWrapper(myErrorMessage, mySObjectList); 

        return myWrap;
    }
    /**
    *————————————————————————————————————————————————————
    * @Name: getEmpSpecReqFrmEmpAndTargetOrReq
    * @Description
    * Specifically returns records EmployeeSpecificRequirement__c based on 
    * Employee and Requirement 
    * 
    *————————————————————————————————————————————————————
    * @params   
    * @returns  SelectorWrapper     A wrapper class containing the errorMessage and the List 
    *————————————————————————————————————————————————————
    **/
    
    public static SelectorWrapper getEmpSpecReqFrmEmpAndTargetOrReq(Set<Id> targetIdSet, Set<ID> reqIdSet, Set<ID> employeeSet) {  
        String myQuery = getEmpSpecificReqQueryString();

        String myErrorMessage; 
        List<EmployeeSpecificRequirement__c> empSpecRequirementsList = new List<EmployeeSpecificRequirement__c>(); 
        List<SObject> mySObjectList = new List<SObject>(); 
        String currentDate = AMTRAK_DateUtility.processDate(System.today());

            myQuery += ' WHERE Employee__c IN :EmployeeSet '; 
            myQuery += ' AND (Requirement__c IN :reqIdSet ';
            myQuery += ' OR Target__c IN :targetIdSet) ';
        	myQuery += ' AND Archived__c = '+ FALSE;
            myQuery += ' AND DivisionOfObservation__c = null ';
            myQuery += ' AND Status__c = \'Active\'';
            
            system.debug('The Query is '+myQuery);
        
           if(Test.isRunningTest() && DoFailTest) {
            myQuery = myQuery.replace('SELECT', 'FAIL') ;
            }

            
            try {
                
                empSpecRequirementsList = Database.query(myQuery); 

            } catch(QueryException qe) {

                system.debug(System.Label.SOQL_Query_Error + qe.getMessage());
                myErrorMessage = System.Label.QueryErrorSobjectException + qe.getMessage();
            }
        mySObjectList = empSpecRequirementsList; 

        SelectorWrapper myWrap = new SelectorWrapper(myErrorMessage, mySObjectList); 

        return myWrap;
    }
    /**
    *————————————————————————————————————————————————————
    * @Name: getEmployeeSpecificRequirements
    * @Description
    * Return Employee Specific Requirements based on the Employee
    * 
    * @returns  SelectorWrapper		A wrapper class containing the errorMessage and the List 
    *————————————————————————————————————————————————————
    **/
	 public static SelectorWrapper getEmployeeSpecificRequirements(Set<ID> contactIds) {
	 	String myQuery = getEmpSpecificReqQueryString();

        String myErrorMessage; 
        List<EmployeeSpecificRequirement__c> empSpecificRequirements = new List<EmployeeSpecificRequirement__c>(); 
        List<SObject> mySObjectList = new List<SObject>();

            myQuery += ' WHERE Employee__c IN :contactIds';
         	myQuery += ' AND Archived__c = '+ FALSE;
            myQuery += ' AND Status__c = \'Active\'';
         
            myQuery = myQuery.replace('SELECT', 'SELECT Target__r.SourceRecordType__c,') ;
         
            if(Test.isRunningTest() && DoFailTest) {
            myQuery = myQuery.replace('SELECT', 'FAIL') ;
            }

            
            try {
                
                empSpecificRequirements = Database.query(myQuery); 

            } catch(QueryException qe) {

                system.debug(System.Label.SOQL_Query_Error + qe.getMessage() );
                myErrorMessage = System.Label.QueryErrorSobjectException + qe.getMessage();
            }
         mySObjectList = empSpecificRequirements;


        SelectorWrapper myWrap = new SelectorWrapper(myErrorMessage, mySObjectList); 

        return myWrap;
    }
    
      /**
    *————————————————————————————————————————————————————
    * @Name: getEmployeeSpecificRequirements
    * @Description
    * Return Employee Specific Requirements based on the Certificate
    * 
    * @returns  SelectorWrapper		A wrapper class containing the errorMessage and the List 
    *————————————————————————————————————————————————————
    **/
	 public static SelectorWrapper getEmployeeSpecificRequirementsFrmEmpCert(Set<ID> oCertId) {
	 	String myQuery = getEmpSpecificReqQueryString();

        String myErrorMessage; 
        List<EmployeeSpecificRequirement__c> empSpecificRequirements = new List<EmployeeSpecificRequirement__c>(); 
        List<SObject> mySObjectList = new List<SObject>();

            myQuery += ' WHERE EmployeeCertification__c IN :oCertId';
         	myQuery += ' AND Archived__c = '+ FALSE;
            myQuery += ' AND Status__c = \'Active\'';
         
         system.debug('The check is '+myQuery);
         
            if(Test.isRunningTest() && DoFailTest) {
            myQuery = myQuery.replace('SELECT', 'FAIL') ;
            }

            
            try {
                
                empSpecificRequirements = Database.query(myQuery); 

            } catch(QueryException qe) {

                system.debug(System.Label.SOQL_Query_Error + qe.getMessage() );
                myErrorMessage = System.Label.QueryErrorSobjectException + qe.getMessage();
            }
         mySObjectList = empSpecificRequirements;


        SelectorWrapper myWrap = new SelectorWrapper(myErrorMessage, mySObjectList); 

        return myWrap;
    }
    
     /**
    *————————————————————————————————————————————————————
    * @Name: getActiveEmpSpecReqFrmEmpAndTarget
    * @Description
    * Specifically returns records EmployeeSpecificRequirement__c based on Employee and Target 
    * 
    *————————————————————————————————————————————————————
    * @params  	
    * @returns  SelectorWrapper		A wrapper class containing the errorMessage and the List 
    *————————————————————————————————————————————————————
    **/
    public static SelectorWrapper geActivetEmpSpecReqFrmEmpAndTarget(Set<ID> employeeSet, Set<String> TargetType) {  
       	String myQuery = getEmpSpecificReqQueryString();

        String myErrorMessage; 
        List<EmployeeSpecificRequirement__c> empSpecRequirementsList = new List<EmployeeSpecificRequirement__c>(); 
        List<SObject> mySObjectList = new List<SObject>(); 
        String currentDate = AMTRAK_DateUtility.processDate(System.today());

            myQuery += ' WHERE Employee__c IN : EmployeeSet';
        	myQuery += ' AND EndDate__c >='+currentDate;
        	myQuery += ' AND Target__r.TargetType__c IN: TargetType';
        	myQuery += ' AND Archived__c = '+ FALSE;
        	myQuery = myQuery.replace('SELECT', 'SELECT Target__r.Name,') ;   
        
            system.debug('The Query is $$'+myQuery);
        
           if(Test.isRunningTest() && DoFailTest) {
            myQuery = myQuery.replace('SELECT', 'FAIL') ;
            }

            
            try {
                
                empSpecRequirementsList = Database.query(myQuery); 

            } catch(QueryException qe) {

                system.debug(System.Label.SOQL_Query_Error + qe.getMessage());
                myErrorMessage = System.Label.QueryErrorSobjectException + qe.getMessage();
            }
        mySObjectList = empSpecRequirementsList; 

        SelectorWrapper myWrap = new SelectorWrapper(myErrorMessage, mySObjectList); 

        return myWrap;
    }


    
       public static SelectorWrapper getESRbyEmployeeCertification(Set<ID> employeeCertId) {  
       	String myQuery = getEmpSpecificReqQueryString();

        String myErrorMessage; 
        List<EmployeeSpecificRequirement__c> empSpecRequirementsList = new List<EmployeeSpecificRequirement__c>(); 
        List<SObject> mySObjectList = new List<SObject>(); 

            myQuery += ' WHERE EmployeeCertification__c IN : employeeCertId';
           	myQuery += ' AND Archived__c = '+ FALSE;
        	
            system.debug('The Query is $$'+myQuery);
           
              if(Test.isRunningTest() && DoFailTest) {
            myQuery = myQuery.replace('SELECT', 'FAIL') ;
            }

            
            try {
                
                empSpecRequirementsList = Database.query(myQuery); 

            } catch(QueryException qe) {

                system.debug(System.Label.SOQL_Query_Error + qe.getMessage());
                myErrorMessage = System.Label.QueryErrorSobjectException + qe.getMessage();
            }
        mySObjectList = empSpecRequirementsList; 

        SelectorWrapper myWrap = new SelectorWrapper(myErrorMessage, mySObjectList); 

        return myWrap;
    }
     /**
    *————————————————————————————————————————————————————
    * @Name: getDivisionEsr
    * @Description
    * Return Employee Specific Requirements having a Division
    * 
    * @returns  SelectorWrapper     A wrapper class containing the errorMessage and the List 
    *————————————————————————————————————————————————————
    **/
     public static SelectorWrapper getDivisionEsr() {

        String myQuery = getEmpSpecificReqQueryString();

        String myErrorMessage; 
        List<EmployeeSpecificRequirement__c> empSpecificRequirements = new List<EmployeeSpecificRequirement__c>(); 
        List<SObject> mySObjectList = new List<SObject>();

            myQuery += ' WHERE recordTypeId =\''+EmployeeSpecificRequirementStaticUtility.EMP_SPEC_REQ_SPARTNTARGET_RECTYPE_ID+'\''; 
            myQuery += ' AND DivisionOfObservation__c != null ';
            myQuery += ' AND Archived__c = '+ FALSE;
         
          system.debug('The check is '+myQuery);
         
            if(Test.isRunningTest() && DoFailTest) {
            myQuery = myQuery.replace('SELECT', 'FAIL') ;
            }

            
            try {
                
                empSpecificRequirements = Database.query(myQuery); 

            } catch(QueryException qe) {

                system.debug(System.Label.SOQL_Query_Error + qe.getMessage() );
                myErrorMessage = System.Label.QueryErrorSobjectException + qe.getMessage();
            }
         mySObjectList = empSpecificRequirements;


        SelectorWrapper myWrap = new SelectorWrapper(myErrorMessage, mySObjectList); 

        return myWrap;
    }
    
    
}
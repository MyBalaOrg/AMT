/**
*___________________________________________________
*@Name: 	EmployeeCertificationSelector
*@Author: 	Raj Kumar Pandy
*@Created: 	Date: 11/21/2017
*@Used_By: 	Global 
*___________________________________________________
*@Description: Selector class for EmployeeCertification__c object 
*___________________________________________________
*@Changes: 
* 05-29-2018 [Boom Bertetti] added "limiteNumber" param to getEmpCertByEmpIds method
**/
global with sharing class EmployeeCertificationSelector {

    public static Boolean DoFailTest = FALSE; 

    /**
    *————————————————————————————————————————————————————
    * @Name: getEmpCertQueryString
    * @Description
    * Specifically frames the query 
    * 
    *————————————————————————————————————————————————————
    * @params   
    * @returns  String      A method to frame the query
    *————————————————————————————————————————————————————
    **/
    public static String getEmpCertQueryString() {  
        String myQuery; 
        
        
        QueryUtilityWrapper myQuWrap = QueryUtility.beginDynamicQuery(Label.OBJAPI_EMPLOYEE_CERTIFICATION);   
        if(myQuWrap.ErrorMessage == null) { 
            myQuery = myQuWrap.QueryString; 
        }
        
        return myQuery;
    }

    /**
    *————————————————————————————————————————————————————
    * @Name: getEmpCertification 1
    * @Description
    * Specifically returns records 
    * 
    *————————————————————————————————————————————————————
    * @params   
    * @returns  SelectorWrapper     A wrapper class containing the errorMessage and the List 
    *————————————————————————————————————————————————————
    **/
    public static SelectorWrapper getEmpCertification(Set<ID> empCertIdSet) {  
        String myQuery = getEmpCertQueryString();

        String myErrorMessage; 
        List<EmployeeCertification__c> empCertificationList = new List<EmployeeCertification__c>(); 
        List<SObject> mySObjectList = new List<SObject>(); 

        myQuery += ' WHERE Id IN :empCertIdSet';  
        myQuery += ' AND Archived__c = '+ FALSE;

        myQuery = myQuery.replace('SELECT', 'SELECT Certification__r.Name,') ;

        if(Test.isRunningTest() && DoFailTest) {
            myQuery = myQuery.replace('SELECT', 'FAIL') ;
        }
        
        try {
            System.debug('&&& myQuery '+myQuery);
            empCertificationList = Database.query(myQuery); 
            System.debug('&&& empCertificationList '+empCertificationList);

        } catch(QueryException qe) {

            system.debug(System.Label.SOQL_Query_Error + qe.getMessage());
            myErrorMessage = System.Label.QueryErrorSobjectException + qe.getMessage();
        }
        mySObjectList = empCertificationList; 

        SelectorWrapper myWrap = new SelectorWrapper(myErrorMessage, mySObjectList); 

        return myWrap;
    }

    

    /**
    *————————————————————————————————————————————————————
    * @Name: getOccCertRelated 2
    * @Description
    * Specifically returns records 
    * 
    *————————————————————————————————————————————————————
    * @params  	
    * @returns  SelectorWrapper		A wrapper class containing the errorMessage and the List 
    *————————————————————————————————————————————————————
    **/
    public static SelectorWrapper getOccCertRelated(Set<ID> OccCertSet) {  
        String myQuery = getEmpCertQueryString();

        String myErrorMessage; 
        List<EmployeeCertification__c> empCertificationList = new List<EmployeeCertification__c>(); 
        List<SObject> mySObjectList = new List<SObject>(); 

        myQuery += ' WHERE Certification__c IN :  OccCertSet';
        myQuery += ' AND RecordTypeId =\''+EmployeeCertificationStaticUtility.EMPCERT_SPARTNCERT_RECTYPE_ID+'\'';
        myQuery += ' AND Archived__c = '+ FALSE;

        if(Test.isRunningTest() && DoFailTest) {
            myQuery = myQuery.replace('SELECT', 'FAIL') ;
        }
        
        try {
            
            empCertificationList = Database.query(myQuery); 

        } catch(QueryException qe) {

            system.debug(System.Label.SOQL_Query_Error + qe.getMessage());
            myErrorMessage = System.Label.QueryErrorSobjectException + qe.getMessage();
        }
        mySObjectList = empCertificationList; 

        SelectorWrapper myWrap = new SelectorWrapper(myErrorMessage, mySObjectList); 

        return myWrap;
    }

    /**
    *————————————————————————————————————————————————————
    * @Name: getActiveEmpCert 3
    * @Description
    * Specifically returns records which are actve
    * 
    *————————————————————————————————————————————————————
    * @params   
    * @returns  SelectorWrapper     A wrapper class containing the errorMessage and the List 
    *————————————————————————————————————————————————————
    **/
    public static SelectorWrapper getActiveEmpCert(Set<ID> OccCertSet) {  
        String myQuery = getEmpCertQueryString();

        String myErrorMessage; 
        List<EmployeeCertification__c> empCertificationList = new List<EmployeeCertification__c>(); 
        List<SObject> mySObjectList = new List<SObject>(); 

        if(Test.isRunningTest() && DoFailTest) {
            myQuery = myQuery.replace('SELECT', 'FAIL') ;
        }

        myQuery += ' WHERE Certification__c IN :  OccCertSet';
        myQuery += ' AND RecordTypeId =\''+EmployeeCertificationStaticUtility.EMPCERT_SPARTNCERT_RECTYPE_ID+'\'';
        myQuery += ' AND Status__c = \'Current\'';
        myQuery += ' AND Archived__c = '+ FALSE;
        try {
            
            empCertificationList = Database.query(myQuery); 

        } catch(QueryException qe) {

            system.debug(System.Label.SOQL_Query_Error + qe.getMessage());
            myErrorMessage = System.Label.QueryErrorSobjectException + qe.getMessage();
        }
        mySObjectList = empCertificationList; 

        SelectorWrapper myWrap = new SelectorWrapper(myErrorMessage, mySObjectList); 

        return myWrap;
    }

     /**
    *————————————————————————————————————————————————————
    * @Name: getSupervisorEmpCert 4
    * @Description
    * Returns Employee Certification records of Supervisor qualification record type with current as status
    * 
    *————————————————————————————————————————————————————
    * @params   
    * @returns  SelectorWrapper     A wrapper class containing the errorMessage and the List 
    *————————————————————————————————————————————————————
    **/
    public static SelectorWrapper getSupervisorEmpCert(Set<Id> contactIdSet) {  
        String myQuery = getEmpCertQueryString();

        String myErrorMessage; 
        List<EmployeeCertification__c> empCertificationList = new List<EmployeeCertification__c>(); 
        List<SObject> mySObjectList = new List<SObject>(); 

        myQuery += ' WHERE Employee__c IN : contactIdSet';
        myQuery += ' AND RecordTypeId =\''+EmployeeCertificationStaticUtility.EMPCERT_SPARTSUPV_RECTYPE_ID+'\'';
        myQuery += ' AND Status__c = \'Active\'';
        myQuery += ' AND Archived__c = '+ FALSE;

        // Sub in Employee Name 
        myQuery = myQuery.replace('SELECT', 'SELECT Employee__r.Name,') ;   

        if(Test.isRunningTest() && DoFailTest) {
            myQuery = myQuery.replace('SELECT', 'FAIL') ;
        }

        system.debug('&&& myQuery  ' + myQuery); 
        system.debug('&&& contactIdSet  ' + contactIdSet); 

        try {
            
            empCertificationList = Database.query(myQuery); 

        } catch(QueryException qe) {

            system.debug(System.Label.SOQL_Query_Error + qe.getMessage());
            myErrorMessage = System.Label.QueryErrorSobjectException + qe.getMessage();
        }
        mySObjectList = empCertificationList; 

        SelectorWrapper myWrap = new SelectorWrapper(myErrorMessage, mySObjectList); 

        return myWrap;
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Name: getEccCertFromId 5
    * @Description
    * Specifically returns records 
    * 
    *————————————————————————————————————————————————————
    * @params  	
    * @returns  SelectorWrapper		A wrapper class containing the errorMessage and the List 
    *————————————————————————————————————————————————————
    **/
    public static SelectorWrapper getEccCertFromId(List<EmployeeCertification__c> eccCertList) {  
        String myQuery = getEmpCertQueryString();

        String myErrorMessage; 
        List<EmployeeCertification__c> empCertificationList = new List<EmployeeCertification__c>(); 
        List<SObject> mySObjectList = new List<SObject>(); 

        myQuery += ' WHERE Id IN :eccCertList';
        myQuery += ' AND Archived__c = '+ FALSE; 

        if(Test.isRunningTest() && DoFailTest) {
            myQuery = myQuery.replace('SELECT', 'FAIL') ;
        }

        try {
            
            empCertificationList = Database.query(myQuery); 

        } catch(QueryException qe) {

            system.debug(System.Label.SOQL_Query_Error + qe.getMessage());
            myErrorMessage = System.Label.QueryErrorSobjectException + qe.getMessage();
        }
        mySObjectList = empCertificationList; 

        SelectorWrapper myWrap = new SelectorWrapper(myErrorMessage, mySObjectList); 

        return myWrap;
    }
    
	/**
    *——	——————————————————————————————————————————————————
    * @Name: generateCertificationId 6
    * @Description
    * Generates Certification Id for the active Certification
    * 
    *————————————————————————————————————————————————————
    * @params   
    * @returns  SelectorWrapper     Wrapper with list of EmployeeHierarchy Records
    *————————————————————————————————————————————————————
    **/
    public static SelectorWrapper generateCertificationId() {  
    	String myQuery;

    	String myErrorMessage; 
    	List<aggregateResult> AggrList = new List<aggregateResult>(); 
    	List<SObject> mySObjectList = new List<SObject>(); 
        
    	myQuery = 'SELECT max(BackEndSerialNumber__c)  ';
    	myQuery += ' FROM ' + Label.OBJAPI_EMPLOYEE_CERTIFICATION+' '; 
    	myQuery += ' WHERE BackEndSerialNumber__c != null';
        myQuery += ' AND Archived__c = '+ FALSE;
        system.debug('myQuery'+myQuery);

        if(Test.isRunningTest() && DoFailTest) {
            myQuery = myQuery.replace('SELECT', 'FAIL') ;
        }
        
    	try {

    		AggrList = Database.query(myQuery); 

    		} catch(QueryException qe) {

    			system.debug(System.Label.SOQL_Query_Error + qe.getMessage());
    			myErrorMessage = System.Label.QueryErrorSobjectException + qe.getMessage();
    		}

    		mySObjectList = AggrList; 

    		SelectorWrapper myWrap = new SelectorWrapper(myErrorMessage, mySObjectList); 

    		return myWrap;
    }    
    
     /**
    *————————————————————————————————————————————————————
    * @Name: getEmpCertFromoccCertId 7
    * @Description
    * Returns Employee Certification records based on the employeeCertIds passed
    * 
    *————————————————————————————————————————————————————
    * @params   
    * @returns  SelectorWrapper     A wrapper class containing the errorMessage and the List 
    *————————————————————————————————————————————————————
    **/
    
     public static SelectorWrapper getEmpCertFromOccCertId(Set<Id> employeeCertIds) {
        String myQuery = getEmpCertQueryString();

        String myErrorMessage; 
        List<EmployeeCertification__c> empCertificationList = new List<EmployeeCertification__c>(); 
        List<SObject> mySObjectList = new List<SObject>(); 
       
        myQuery += ' WHERE Certification__c IN :employeeCertIds';
        myQuery += ' AND Archived__c = '+ FALSE;

        if(Test.isRunningTest() && DoFailTest) {
            myQuery = myQuery.replace('SELECT', 'FAIL') ;
        }

        try {

            empCertificationList = Database.query(myQuery); 

        } catch(QueryException qe) {

            system.debug(System.Label.SOQL_Query_Error + qe.getMessage());
            myErrorMessage = System.Label.QueryErrorSobjectException + qe.getMessage();
        }

        mySObjectList = empCertificationList; 
        SelectorWrapper myWrap = new SelectorWrapper(myErrorMessage, mySObjectList); 
        return myWrap;

    }

    /**
    *————————————————————————————————————————————————————
    * @Name: getLatestEmployeeCertification 8
    * @Description
    * Returns Employee Certification records based on the Certification Number passed.
    * Fetches the latest 
    * 
    *————————————————————————————————————————————————————
    * @params   
    * @returns  SelectorWrapper     A wrapper class containing the errorMessage and the List 
    *————————————————————————————————————————————————————
    **/
    public static SelectorWrapper getLatestEmployeeCertification(String certificationNumber) {
        //String myQuery = getEmpCertQueryString();

        String myErrorMessage; 
        List<EmployeeCertification__c> empCertificationList = new List<EmployeeCertification__c>(); 
        List<SObject> mySObjectList = new List<SObject>(); 
       
       String myQuery = 'SELECT Id,CertificationNumber__c ';
        myQuery += ' FROM ' + Label.OBJAPI_EMPLOYEE_CERTIFICATION+' '; 
        myQuery += ' WHERE CertificationNumber__c = \''+certificationNumber+'\'';
        myQuery += ' AND Archived__c = '+ FALSE;
        myQuery += ' ORDER BY CreatedDate DESC LIMIT 1';

        if(Test.isRunningTest() && DoFailTest) {
            myQuery = myQuery.replace('SELECT', 'FAIL') ;
        }

        try {

            empCertificationList = Database.query(myQuery); 

        } catch(QueryException qe) {

            system.debug(System.Label.SOQL_Query_Error + qe.getMessage());
            myErrorMessage = System.Label.QueryErrorSobjectException + qe.getMessage();
        }

        mySObjectList = empCertificationList; 
        SelectorWrapper myWrap = new SelectorWrapper(myErrorMessage, mySObjectList); 
        return myWrap;

    }

    /**
    *————————————————————————————————————————————————————
    * @Name: getAllEmployeeCertification 9
    * @Description
    * Fetches all the employee certifications including archived records.
    * 
    *————————————————————————————————————————————————————
    * @params   
    * @returns  SelectorWrapper     A wrapper class containing the errorMessage and the List 
    *————————————————————————————————————————————————————
    **/
    public static SelectorWrapper getAllEmployeeCertification(Set<Id> certIdSet) {
        String myQuery = getEmpCertQueryString();

        String myErrorMessage; 
        List<EmployeeCertification__c> empCertificationList = new List<EmployeeCertification__c>(); 
        List<SObject> mySObjectList = new List<SObject>(); 
        
        myQuery += ' WHERE Id IN :certIdSet';

        if(Test.isRunningTest() && DoFailTest) {
            myQuery = myQuery.replace('SELECT', 'FAIL') ;
        }

        try {

            empCertificationList = Database.query(myQuery); 

        } catch(QueryException qe) {

            system.debug(System.Label.SOQL_Query_Error + qe.getMessage());
            myErrorMessage = System.Label.QueryErrorSobjectException + qe.getMessage();
        }

        mySObjectList = empCertificationList; 
        SelectorWrapper myWrap = new SelectorWrapper(myErrorMessage, mySObjectList); 
        return myWrap;

    }
    /**
    *————————————————————————————————————————————————————
    * @Name: getEmpCertByCertAndEmpIds 10
    * @Description
    * Returns Employee Certification records based on the employeeCertIds passed
    * 
    *————————————————————————————————————————————————————
    * @params   
    * @returns  SelectorWrapper     A wrapper class containing the errorMessage and the List 
    *————————————————————————————————————————————————————
    **/
    
     public static SelectorWrapper getEmpCertByCertAndEmpIds(Set<Id> theCertIdSet,
                                                             Set<Id> theEmpIdSet) {
        String myQuery = getEmpCertQueryString();
        Id myRecTypeId = EmployeeCertificationStaticUtility.EMPCERT_SPARTNCERT_RECTYPE_ID; 

        String myErrorMessage; 
        List<EmployeeCertification__c> empCertificationList = new List<EmployeeCertification__c>(); 
        List<SObject> mySObjectList = new List<SObject>(); 
       
        myQuery += ' WHERE RecordTypeId = :myRecTypeId ';
        myQuery += ' AND Archived__c = false ';
        myQuery += ' AND Certification__c IN :theCertIdSet ';
        myQuery += ' AND Employee__c IN :theEmpIdSet ';

        if(Test.isRunningTest() && DoFailTest) {
            myQuery = myQuery.replace('SELECT', 'FAIL') ;
        }

        try {

            empCertificationList = Database.query(myQuery); 

        } catch(QueryException qe) {

            system.debug(System.Label.SOQL_Query_Error + qe.getMessage());
            myErrorMessage = System.Label.QueryErrorSobjectException + qe.getMessage();
        }

        mySObjectList = empCertificationList; 
        SelectorWrapper myWrap = new SelectorWrapper(myErrorMessage, mySObjectList); 
        return myWrap;

    }
    /**
    *————————————————————————————————————————————————————
    * @Name: getEmpCertByEmpIds 11
    * @Description
    * Returns Employee Certification records based on the employeeCertIds passed
    * 
    *————————————————————————————————————————————————————
    * @params   
    * @returns  SelectorWrapper     A wrapper class containing the errorMessage and the List 
    *————————————————————————————————————————————————————
    **/
    
     public static SelectorWrapper getEmpCertByEmpIds(Set<Id> theEmpIdSet, String limitNumber) {
        String myQuery = getEmpCertQueryString();
        Id myRecTypeId = EmployeeCertificationStaticUtility.EMPCERT_SPARTNCERT_RECTYPE_ID; 

        String myErrorMessage; 
        List<EmployeeCertification__c> empCertificationList = new List<EmployeeCertification__c>(); 
        List<SObject> mySObjectList = new List<SObject>(); 

        myQuery += ' WHERE RecordTypeId = :myRecTypeId ';
        myQuery += ' AND Employee__c IN :theEmpIdSet ';
        myQuery += ' AND Archived__c = false ';
        myQuery += ' ORDER BY LastCertificationDate__c DESC ';
        if(!String.isEmpty(limitNumber)) {
            myQuery += ' LIMIT ' + limitNumber;
        }

        if(Test.isRunningTest() && DoFailTest) {
            myQuery = myQuery.replace('SELECT', 'FAIL') ;
        }

        try {

            empCertificationList = Database.query(myQuery); 

        } catch(QueryException qe) {

            system.debug(System.Label.SOQL_Query_Error + qe.getMessage());
            myErrorMessage = System.Label.QueryErrorSobjectException + qe.getMessage();
        }

        mySObjectList = empCertificationList; 
        SelectorWrapper myWrap = new SelectorWrapper(myErrorMessage, mySObjectList); 
        return myWrap;

    }
    /**
    *————————————————————————————————————————————————————
    * @Name: getByEmpIdAndCertType 12
    * @Description
    * Returns Employee Certification records based on the employeeCertIds passed
    * 
    *————————————————————————————————————————————————————
    * @params   
    * @returns  SelectorWrapper     A wrapper class containing the errorMessage and the List 
    *————————————————————————————————————————————————————
    **/
    
     public static SelectorWrapper getByEmpIdAndCertType(Set<Id>     theEmpIdSet,
                                                         Set<String> theCertTypeSet) {

        String myQuery = getEmpCertQueryString();
        Id myRecTypeId = EmployeeCertificationStaticUtility.EMPCERT_SPARTNCERT_RECTYPE_ID; 

        String myErrorMessage; 
        List<EmployeeCertification__c> empCertificationList = new List<EmployeeCertification__c>(); 
        List<SObject> mySObjectList = new List<SObject>(); 

        if(Test.isRunningTest() && DoFailTest) {
            myQuery = myQuery.replace('SELECT', 'FAIL') ;
        }
       
        myQuery += ' WHERE RecordTypeId = :myRecTypeId ';
        myQuery += ' AND Archived__c = false ';
        myQuery += ' AND CertificationType__c IN :theCertTypeSet ';
        myQuery += ' AND Employee__c IN :theEmpIdSet ';
        try {

            empCertificationList = Database.query(myQuery); 

        } catch(QueryException qe) {

            system.debug(System.Label.SOQL_Query_Error + qe.getMessage());
            myErrorMessage = System.Label.QueryErrorSobjectException + qe.getMessage();
        }

        mySObjectList = empCertificationList; 
        SelectorWrapper myWrap = new SelectorWrapper(myErrorMessage, mySObjectList); 
        return myWrap;

    }

    /**
    *————————————————————————————————————————————————————
    * @Name: getEmpCertByEmpId 13
    * @Description
    * Returns Employee Certification records based on the employeeCertIds passed
    * 
    *————————————————————————————————————————————————————
    * @params   
    * @returns  SelectorWrapper     A wrapper class containing the errorMessage and the List 
    *————————————————————————————————————————————————————
    **/
     public static SelectorWrapper getEmpCertByEmpId(Id theEmpId) {
        String myQuery = getEmpCertQueryString();
        Id myRecTypeId = EmployeeCertificationStaticUtility.EMPCERT_SPARTNCERT_RECTYPE_ID; 
        String certificateType = RevSys_StaticUtility.STUDENT_ENGINEER;

        String myErrorMessage; 
        List<EmployeeCertification__c> empCertificationList = new List<EmployeeCertification__c>(); 
        List<SObject> mySObjectList = new List<SObject>(); 
		
        myQuery += ' WHERE RecordTypeId = :myRecTypeId ';
        myQuery += ' AND Employee__c = :theEmpId ';
        myQuery += ' AND CertificationType__c = :certificateType ';
        myQuery += ' AND Archived__c = false ';
        myQuery += ' ORDER BY LastCertificationDate__c DESC LIMIT 1';

        if(Test.isRunningTest() && DoFailTest) {
            myQuery = myQuery.replace('SELECT', 'FAIL') ;
        }

        try {

            empCertificationList = Database.query(myQuery); 

        } catch(QueryException qe) {

            system.debug(System.Label.SOQL_Query_Error + qe.getMessage());
            myErrorMessage = System.Label.QueryErrorSobjectException + qe.getMessage();
        }

        mySObjectList = empCertificationList; 
        SelectorWrapper myWrap = new SelectorWrapper(myErrorMessage, mySObjectList); 
        return myWrap;

    }

}
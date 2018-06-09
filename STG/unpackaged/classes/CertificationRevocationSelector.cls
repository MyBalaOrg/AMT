/**
*___________________________________________________
*@Name: 	CertificationRevocationSelector
*@Author: 	Hemanth Kesapragada
*@Created: 	Date: 02/15/2018
*@Used_By: 	Global 
*___________________________________________________
*@Description: Selector class for CertificationRevocation__c object 
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/
public with sharing class CertificationRevocationSelector {
     public static Boolean DoFailTest = FALSE;
	/**
    *————————————————————————————————————————————————————
    * @Name: getQueryString
    * @Description
    * Specifically frames the query 
    * 
    *————————————————————————————————————————————————————
    * @params   
    * @returns  String      A method to frame the query
    *————————————————————————————————————————————————————
    **/
    public static String getQueryString() {  
        String myQuery; 
        QueryUtilityWrapper myQuWrap = QueryUtility.beginDynamicQuery(Label.OBJAPI_CERTIFICATION_REVOCATION);   
        if(myQuWrap.ErrorMessage == null) { 
            myQuery = myQuWrap.QueryString; 
        }
        
        return myQuery;
    }

     /**
    *————————————————————————————————————————————————————
    * @Name: getActiveRevocationRecords
    * @Description
    * Specifically returns records 
    * 
    *————————————————————————————————————————————————————
    * @params   
    * @returns  SelectorWrapper     A wrapper class containing the errorMessage and the List 
    *————————————————————————————————————————————————————
    **/
    public static SelectorWrapper getActiveRevocationRecords(Set<Id> empCertIdSet, String orderByField, String orderDirection) {  
        String myQuery = getQueryString();

        String myErrorMessage; 
        List<CertificationRevocation__c> certRevocList = new List<CertificationRevocation__c>(); 
        List<SObject> mySObjectList = new List<SObject>(); 
       // myQuery = myQuery.replace(System.Label.SELECT+' ',Label.SELECT+' EmployeeCertification__r.InitialIncidentDate__c,EmployeeCertification__r.ProbationEndDate__c,');
        myQuery += ' WHERE EmployeeCertification__c  IN  :empCertIdSet ' ;  
        myQuery += ' AND Status__c = \'Active\'';
        myQuery += ' AND Archived__c = '+ FALSE;
        if (!String.isBlank(orderByField)) {
            myQuery += ' ORDER BY ';
            myQuery += orderByField + ' ' + orderDirection ;
        }
        
        if(Test.isRunningTest() && DoFailTest) {
            myQuery = myQuery.replace('SELECT', 'FAIL') ;
            }
        
        try {
            System.debug('Udpated query '+myQuery);
            certRevocList = Database.query(myQuery); 

        } catch(QueryException qe) {

            system.debug(System.Label.SOQL_Query_Error + qe.getMessage());
            myErrorMessage = System.Label.QueryErrorSobjectException + qe.getMessage();
        }
        mySObjectList = certRevocList; 

        SelectorWrapper myWrap = new SelectorWrapper(myErrorMessage, mySObjectList); 

        return myWrap;
    }
    
    public static SelectorWrapper getCertRevocationbyEmpCertId(Set<ID> empCertIdSet) {  
    	String myQuery = getQueryString();

    	String myErrorMessage; 
    	List<CertificationRevocation__c> certRevocList = new List<CertificationRevocation__c>(); 
    	List<SObject> mySObjectList = new List<SObject>(); 

    	myQuery += ' WHERE EmployeeCertification__c IN :  empCertIdSet';  
    	myQuery += ' AND Archived__c = '+ FALSE;
        myQuery += ' ORDER BY IncidentDate__c ASC';
        
        if(Test.isRunningTest() && DoFailTest) {
            myQuery = myQuery.replace('SELECT', 'FAIL') ;
            }

    	try {

    		certRevocList = Database.query(myQuery); 

    		} catch(QueryException qe) {

    			system.debug(System.Label.SOQL_Query_Error + qe.getMessage());
    			myErrorMessage = System.Label.QueryErrorSobjectException + qe.getMessage();
    		}
    		mySObjectList = certRevocList; 

    		SelectorWrapper myWrap = new SelectorWrapper(myErrorMessage, mySObjectList); 

    		return myWrap;
    	}
}
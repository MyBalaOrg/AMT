/**
*___________________________________________________
*@Name: 	BatchProcessParameterSelector
*@Author: 	Hemanth Kesapragada
*@Created: 	Date: 12/04/2017
*@Used_By: 	Global 
*___________________________________________________
*@Description: Selector class for BatchProcessParameter__mdt object 
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/
global with sharing class BatchProcessParameterSelector  {
    public static Boolean DoFailTest = FALSE;
	/**
    *————————————————————————————————————————————————————
    * @Name: getBatchProcessParamRecords
    * @Description
    * Returns configuration records specifically to SPARTN
    * 
    *————————————————————————————————————————————————————
    * @params  	
    * @returns  SelectorWrapper		A wrapper class containing the errorMessage and the List 
    *————————————————————————————————————————————————————
    **/
    public static SelectorWrapper getBatchProcessParamRecords() {  
    	String myQuery; 

    	String myErrorMessage; 
    	List<BatchProcessParameter__mdt> batchProcessParamsList = new List<BatchProcessParameter__mdt>(); 
    	List<SObject> mySObjectList = new List<SObject>(); 

    	QueryUtilityWrapper myQuWrap = QueryUtility.beginDynamicQuery(Label.OBJAPI_BATCH_PROCESS_PARAMETER);   
    	if(myQuWrap.ErrorMessage == null) { 

    		myQuery = myQuWrap.QueryString; 
    		myQuery += System.Label.WHERE +' Application__c = \''+RevSys_StaticUtility.SPARTN+'\'';
    		myQuery += ' '+System.Label.AND+' Process__c = \''+RevSys_StaticUtility.EMPLOYEE_CERT_EMAIL+'\'';
            
             if(Test.isRunningTest() && DoFailTest) {
            myQuery = myQuery.replace('SELECT', 'FAIL') ;
            }

    		try {

    			batchProcessParamsList = Database.query(myQuery); 

    			} catch(QueryException qe) {

    				system.debug(System.Label.SOQL_Query_Error + qe.getMessage());
    				myErrorMessage = System.Label.QueryErrorSobjectException + qe.getMessage();
    			}
		}
		mySObjectList = batchProcessParamsList; 

		SelectorWrapper myWrap = new SelectorWrapper(myErrorMessage, mySObjectList); 

		return myWrap;

	}
}
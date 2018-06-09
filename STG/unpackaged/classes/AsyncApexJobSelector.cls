/**
*___________________________________________________
*@Name: 	AsynchApexJobSelector
*@Author: 	Hemanth Kesapragada
*@Created: 	Date: 12/07/2017
*@Used_By: 	SPARTN
*___________________________________________________
*@Description: Selector class for AsynchApexJobSelector
* 
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/
global with sharing class AsyncApexJobSelector {
     public static Boolean DoFailTest = FALSE;
	/**
    *————————————————————————————————————————————————————
    * @Name: getAsynApexJobs
    * @Description
    * Specifically frames the query 
    * 
    *————————————————————————————————————————————————————
    * @params   
    * @returns  String      A method to frame the query
    *————————————————————————————————————————————————————
    **/

	public static SelectorWrapper getAsyncApexJobs(String batchId) {  
        String myQuery;

        String myErrorMessage; 
        List<AsyncApexJob> apexJobs = new List<AsyncApexJob>(); 
        List<SObject> mySObjectList = new List<SObject>(); 

        QueryUtilityWrapper myQuWrap = QueryUtility.beginDynamicQuery(Label.OBJAPI_ASYNC_APEX_JOB);   
        if(myQuWrap.ErrorMessage == null) { 

        	myQuery = myQuWrap.QueryString; 
        	myQuery += System.Label.WHERE +' Id = :  batchId';
             if(Test.isRunningTest() && DoFailTest) {
                myQuery = myQuery.replace('SELECT', 'FAIL') ;
            }
			try {

        		apexJobs = Database.query(myQuery); 
               

    		} catch(QueryException qe) {

    			system.debug(System.Label.SOQL_Query_Error + qe.getMessage());
    			myErrorMessage = System.Label.QueryErrorSobjectException + qe.getMessage();
    		}
        }
        mySObjectList = apexJobs; 

        SelectorWrapper myWrap = new SelectorWrapper(myErrorMessage, mySObjectList); 

        return myWrap;
    }
}
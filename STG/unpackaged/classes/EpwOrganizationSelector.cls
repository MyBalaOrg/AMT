/**
*___________________________________________________
*@Name:     EpwOrganizationSelector
*@Author:   Chuck Walley
*@Created:  March 17, 2018
*@Used_By:  Global 
*___________________________________________________
*@Description: Selector class for EPW_Organization object 
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/
public with sharing class EpwOrganizationSelector {
	public static Boolean DoFailTest = FALSE; 
    /**
    *————————————————————————————————————————————————————
    * @Name: getById
    * @Description
    * Returns EPW_Organization records based on the Ids passed
    * 
    *————————————————————————————————————————————————————
    * @params   
    * @returns  SelectorWrapper     A wrapper class containing the errorMessage and the List 
    *————————————————————————————————————————————————————
    **/
    public static SelectorWrapper getById(Set<Id> epwOrgIdSet, Id orgRecTypeId) {  
        String myQuery; 

        String myErrorMessage; 
        List<EPW_Organization__c> myResultList = new List<EPW_Organization__c>(); 
        List<SObject> mySObjectList = new List<SObject>(); 

        

        QueryUtilityWrapper myQuWrap = QueryUtility.beginDynamicQuery(Label.OBJAPI_ORGANIZATION);   
        if(myQuWrap.ErrorMessage == null) { 

            myQuery = myQuWrap.QueryString; 
            myQuery += ' WHERE  RecordTypeId = :orgRecTypeId ' ;
            myQuery += '   AND  Id IN :epwOrgIdSet ' ;
            if(Test.isRunningTest() && DoFailTest) {
                myQuery = myQuery.replace('SELECT', 'FAIL') ;
            }

            System.debug(myQuery);

            try {
                myResultList = Database.query(myQuery); 

                } catch(QueryException qe) {

                    system.debug(System.Label.SOQL_Query_Error + qe.getMessage());
                    myErrorMessage = System.Label.QueryErrorSobjectException + qe.getMessage();
                }
        }
        mySObjectList = myResultList; 

        SelectorWrapper myWrap = new SelectorWrapper(myErrorMessage, mySObjectList); 

        return myWrap;
    }
}
/**
*___________________________________________________
*@Name:     AccountSelector
*@Author:   Chuck Walley
*@Created:  March 27, 2018
*@Used_By:  Global 
*___________________________________________________
*@Description: Selector class for the Account object 
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/
public with sharing class AccountSelector {
    public static Boolean DoFailTest = FALSE;
    
    /*
    //ORGANIZATION
    private static Id ORGANIZATION_AMTRAKORG_RECTYPE_ID
        = Schema.SObjectType.EPW_Organization__c.getRecordTypeInfosByName().get(Label.RevSys_Organiztion_RT_Label_AmtrakOrg).getRecordTypeId(); 

    private static Id ORGANIZATION_SPARTN_RECTYPE_ID
        = Schema.SObjectType.EPW_Organization__c.getRecordTypeInfosByName().get(Label.RevSys_Organiztion_RT_Label_Spartn).getRecordTypeId();     
    */ 
        
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
    /*
    public static SelectorWrapper getById(Set<Id> acctIdSet) {  
        String myQuery; 

        String myErrorMessage; 
        List<EPW_Organization__c> myResultList = new List<EPW_Organization__c>(); 
        List<SObject> mySObjectList = new List<SObject>(); 

        Id myAmtrakOrgRecTypeId = ORGANIZATION_AMTRAKORG_RECTYPE_ID; 

        QueryUtilityWrapper myQuWrap = QueryUtility.beginDynamicQuery(Label.OBJAPI_ORGANIZATION);   
        if(myQuWrap.ErrorMessage == null) { 

            myQuery = myQuWrap.QueryString; 
            myQuery += ' WHERE  Id IN :acctIdSet ' ;

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
    */ 
    /**
    *————————————————————————————————————————————————————
    * @Name: getAccountByName
    * @Description
    * Returns the SelectorWrapper with Account records 
    * 
    *————————————————————————————————————————————————————
    * @params   Set<String>         A set of Account Names
    * @returns  SelectorWrapper     A wrapper class containing the errorMessage and the List 
    *————————————————————————————————————————————————————
    **/
    public static SelectorWrapper getAccountByName(Set<String> accountNameSet) {  
        String myQuery; 

        String myErrorMessage; 
        List<Account> myResultList = new List<Account>(); 
        List<SObject> mySObjectList = new List<SObject>(); 

        QueryUtilityWrapper myQuWrap = QueryUtility.beginDynamicQuery(Label.OBJAPI_ACCOUNT);   
        if(myQuWrap.ErrorMessage == null) { 

            myQuery = myQuWrap.QueryString; 
            myQuery += ' '+Label.WHERE+' Name IN :accountNameSet ' ;

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
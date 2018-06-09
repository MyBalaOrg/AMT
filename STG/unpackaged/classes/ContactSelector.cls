/**
*___________________________________________________
*@Name: 	ContactSelector
*@Author: 	Hemanth Kesapragada
*@Created: 	Date: 12/12/2017
*@Used_By: 	Global 
*___________________________________________________
*@Description: Selector class for Contact object 
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/
public with sharing class ContactSelector {

    public static Boolean DoFailTest = FALSE;

    /**
    *————————————————————————————————————————————————————
    * @Name: getContacts
    * @Description
    * Returns contact records based on the contacts passed
    * 
    *————————————————————————————————————————————————————
    * @params  	
    * @returns  SelectorWrapper		A wrapper class containing the errorMessage and the List 
    *————————————————————————————————————————————————————
    **/
    public static SelectorWrapper getContacts(Set<Id> contactIdSet) {  
    	String myQuery; 

    	String myErrorMessage; 
    	List<Contact> contactsList = new List<Contact>(); 
    	List<SObject> mySObjectList = new List<SObject>(); 

    	QueryUtilityWrapper myQuWrap = QueryUtility.beginDynamicQuery(Label.OBJAPI_CONTACT);   
    	if(myQuWrap.ErrorMessage == null) { 
            System.debug('contactIdSet : ' + contactIdSet);
    		myQuery = myQuWrap.QueryString; 
            myQuery = myQuery.replace('SELECT', 'SELECT PositionLookup__r.Generated_Reports_To_Position__c,');
    		myQuery += ' WHERE Id IN :contactIdSet';
            System.debug('myQuery for contacct : ' + myQuery);
            
            if(Test.isRunningTest() && DoFailTest) {
            myQuery = myQuery.replace('SELECT', 'FAIL') ;
            }

    		try {

    			contactsList = Database.query(myQuery); 
                System.debug('contactsList : ' + contactsList);
                //System.debug(contactsList.get(0).PositionLookup__r.Generated_Reports_To_Position__c);

    			} catch(QueryException qe) {

    				system.debug(System.Label.SOQL_Query_Error + qe.getMessage());
    				myErrorMessage = System.Label.QueryErrorSobjectException + qe.getMessage();
    			}
		}
		mySObjectList = contactsList; 

		SelectorWrapper myWrap = new SelectorWrapper(myErrorMessage, mySObjectList); 

		return myWrap;

	}


    /**
    *————————————————————————————————————————————————————
    * @Name: getPositionIdFromContactId
    * @Description
    * Returns contact records based on the contacts passed
    * 
    *————————————————————————————————————————————————————
    * @params   Contacts ids
    * @returns  SelectorWrapper     A wrapper class containing the errorMessage and the List 
    *————————————————————————————————————————————————————
    **/
    public static SelectorWrapper getPositionIdFromContactId(List<Id> contactIdList) {
        String myQuery; 

        String myErrorMessage; 
        List<Contact> contactsList = new List<Contact>(); 
        List<SObject> mySObjectList = new List<SObject>();
        myQuery = 'SELECT Id, PositionLookup__c ';
        myQuery += ' FROM  ' + Label.OBJAPI_CONTACT;
        myQuery += ' WHERE Id IN :contactIdList';
		
        if(Test.isRunningTest() && DoFailTest) {
            myQuery = myQuery.replace('SELECT', 'FAIL') ;
            }
        try {

            contactsList = Database.query(myQuery); 

        } catch(QueryException qe) {

            system.debug(System.Label.SOQL_Query_Error + qe.getMessage());
            myErrorMessage = System.Label.QueryErrorSobjectException + qe.getMessage();
        }

        mySObjectList = contactsList; 
        SelectorWrapper myWrap = new SelectorWrapper(myErrorMessage, mySObjectList); 
        return myWrap;

    }

    /**
    *————————————————————————————————————————————————————
    * @Name: getContactsBySAPId
    * @Description
    * Returns contact records based on the SAP Id passed
    * 
    *————————————————————————————————————————————————————
    * @params   list of SAP Id
    * @returns  SelectorWrapper     A wrapper class containing the errorMessage and the List 
    *————————————————————————————————————————————————————
    **/
    public static SelectorWrapper getContactsBySAPId(Set<String> SAPIdList) {
        String myQuery; 

        String myErrorMessage; 
        List<Contact> contactsList = new List<Contact>(); 
        List<SObject> mySObjectList = new List<SObject>();

        QueryUtilityWrapper myQuWrap = QueryUtility.beginDynamicQuery(Label.OBJAPI_CONTACT);   
    	if(myQuWrap.ErrorMessage == null) { 
        myQuery = myQuWrap.QueryString; 
        myQuery += ' WHERE Personnel_ID__c IN :SAPIdList';    
        }    
        
        if(Test.isRunningTest() && DoFailTest) {
            myQuery = myQuery.replace('SELECT', 'FAIL') ;
            }
           try {

            contactsList = Database.query(myQuery); 

            } catch(QueryException qe) {

                system.debug(System.Label.SOQL_Query_Error + qe.getMessage());
                myErrorMessage = System.Label.QueryErrorSobjectException + qe.getMessage();
            }       
        

        mySObjectList = contactsList; 
        SelectorWrapper myWrap = new SelectorWrapper(myErrorMessage, mySObjectList); 
        return myWrap;

    }
/**
    *————————————————————————————————————————————————————
    * @Name: getContactsByDept
    * @Description
    * Returns contact records based on the contacts passed
    * 
    *————————————————————————————————————————————————————
    * @params  	
    * @returns  SelectorWrapper		A wrapper class containing the errorMessage and the List 
    *————————————————————————————————————————————————————
    **/
    public static SelectorWrapper getContactsByDept(Set<String> myDeptSet) {  
    	String myQuery; 

    	String myErrorMessage; 
    	List<Contact> contactsList = new List<Contact>(); 
    	List<SObject> mySObjectList = new List<SObject>(); 

    	QueryUtilityWrapper myQuWrap = QueryUtility.beginDynamicQuery(Label.OBJAPI_CONTACT);   
    	if(myQuWrap.ErrorMessage == null) { 

    		myQuery = myQuWrap.QueryString; 
    		myQuery += ' WHERE Department IN :myDeptSet';
			
            if(Test.isRunningTest() && DoFailTest) {
            myQuery = myQuery.replace('SELECT', 'FAIL') ;
            }
    		try {
    			contactsList = Database.query(myQuery); 

    			} catch(QueryException qe) {
    				system.debug(System.Label.SOQL_Query_Error + qe.getMessage());
    				myErrorMessage = System.Label.QueryErrorSobjectException + qe.getMessage();
    			}
		}
		mySObjectList = contactsList; 

		SelectorWrapper myWrap = new SelectorWrapper(myErrorMessage, mySObjectList); 

		return myWrap;

	}

    /**
    *————————————————————————————————————————————————————
    * @Name: getContactIdFromPosition
    * @Description
    * Returns contact records based on the positionId passed
    * 
    *————————————————————————————————————————————————————
    * @params   
    * @returns  SelectorWrapper     A wrapper class containing the errorMessage and the List 
    *————————————————————————————————————————————————————
    **/
     public static SelectorWrapper getContactIdFromPosition(List<Id> positionIds) {
        String myQuery; 

        String myErrorMessage; 
        List<Contact> contactsList = new List<Contact>(); 
        List<SObject> mySObjectList = new List<SObject>();
        //inclde more fields in the select clause if neeed. this is only used in RevSys_SetupMar_Helper Class
        myQuery =  'SELECT Id,PositionLookup__c, Department, Craft__c, Division__c'; 
        myQuery += ' FROM ' + Label.OBJAPI_CONTACT;
        myQuery += ' WHERE PositionLookup__c IN :positionIds';
		
         if(Test.isRunningTest() && DoFailTest) {
            myQuery = myQuery.replace('SELECT', 'FAIL') ;
            }
        try {

            contactsList = Database.query(myQuery); 
            System.debug('%% '+contactsList);

        } catch(QueryException qe) {

            system.debug(System.Label.SOQL_Query_Error + qe.getMessage());
            myErrorMessage = System.Label.QueryErrorSobjectException + qe.getMessage();
        }

        mySObjectList = contactsList; 
        SelectorWrapper myWrap = new SelectorWrapper(myErrorMessage, mySObjectList); 
        return myWrap;

    }
    /**
    *————————————————————————————————————————————————————
    * @Name: getContactsById
    * @Description
    * Returns contact records based on the Ids passed 
    * 
    *————————————————————————————————————————————————————
    * @params   
    * @returns  SelectorWrapper     A wrapper class containing the errorMessage and the List 
    *————————————————————————————————————————————————————
    **/
     public static SelectorWrapper getContactsById(Set<Id> contactIdSet) {
        String myQuery; 

        String myErrorMessage; 
        List<Contact> contactsList = new List<Contact>(); 
        List<SObject> mySObjectList = new List<SObject>();

        // myQuery = new QueryUtility().setSelectFields(IntExtList)

        myQuery  = ' SELECT Id, Name, Employee_Type__c, RecordTypeId, Account.Name '; 
        myQuery += ' FROM ' + Label.OBJAPI_CONTACT;
        myQuery += ' WHERE Id IN :contactIdSet';

        system.debug('MY QUERY: ' + myQuery); 
		
         if(Test.isRunningTest() && DoFailTest) {
            myQuery = myQuery.replace('SELECT', 'FAIL') ;
            }
        try {

            contactsList = Database.query(myQuery); 

        } catch(QueryException qe) {

            system.debug(System.Label.SOQL_Query_Error + qe.getMessage());
            myErrorMessage = System.Label.QueryErrorSobjectException + qe.getMessage();
        }

        mySObjectList = contactsList; 
        SelectorWrapper myWrap = new SelectorWrapper(myErrorMessage, mySObjectList); 
        return myWrap;

    }
    
}
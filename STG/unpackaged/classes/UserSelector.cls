/**
*___________________________________________________
*@Name: 	UserSelector
*@Author: 	Sudhindra Katti
*@Created: 	Date: 12/21/2017
*@Used_By: 	Global 
*___________________________________________________
*@Description: Selector class for User object 
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/
public with sharing class UserSelector {
	/**
    *————————————————————————————————————————————————————
    * @Name: getUsers
    * @Description
    * Returns User records based on the User Ids passed
    * 
    *————————————————————————————————————————————————————
    * @params  	
    * @returns  SelectorWrapper		A wrapper class containing the errorMessage and the List 
    *————————————————————————————————————————————————————
    **/
    public static SelectorWrapper getUsers(Set<Id> UserIdSet) {  
    	String myQuery; 
    	String myErrorMessage; 
    	List<User> UsersList = new List<User>(); 
    	List<SObject> mySObjectList = new List<SObject>(); 

    	QueryUtilityWrapper myQuWrap = QueryUtility.beginDynamicQuery(Label.OBJAPI_USER);   
    	if(myQuWrap.ErrorMessage == null) { 

    		myQuery = myQuWrap.QueryString; 
    		myQuery += ' '+System.Label.WHERE +' Id IN :UserIdSet';


    		try {

    			UsersList = Database.query(myQuery); 

    			} catch(QueryException qe) {

    				system.debug(System.Label.SOQL_Query_Error + qe.getMessage());
    				myErrorMessage = System.Label.QueryErrorSobjectException + qe.getMessage();
    			}
		}
		mySObjectList = UsersList; 

		SelectorWrapper myWrap = new SelectorWrapper(myErrorMessage, mySObjectList); 

		return myWrap;
	}


    /**
    *————————————————————————————————————————————————————
    * @Name: getUsersbyPersonalId
    * @Description
    * Returns User records based on the User Ids passed
    * 
    *————————————————————————————————————————————————————
    * @params  	
    * @returns  SelectorWrapper		A wrapper class containing the errorMessage and the List 
    *————————————————————————————————————————————————————
    **/
    public static SelectorWrapper getUsersbyPersonalId(Set<String> PersonalIdSet) {  
    	String myQuery; 
    	String myErrorMessage; 
    	List<User> UsersList = new List<User>(); 
    	List<SObject> mySObjectList = new List<SObject>(); 

    	QueryUtilityWrapper myQuWrap = QueryUtility.beginDynamicQuery(Label.OBJAPI_USER);   
    	if(myQuWrap.ErrorMessage == null) { 

    		myQuery = myQuWrap.QueryString; 
    		myQuery += ' '+System.Label.WHERE +' EmployeeNumber IN :PersonalIdSet';


    		try {

    			UsersList = Database.query(myQuery); 

    			} catch(QueryException qe) {

    				system.debug(System.Label.SOQL_Query_Error + qe.getMessage());
    				myErrorMessage = System.Label.QueryErrorSobjectException + qe.getMessage();
    			}
		}
		mySObjectList = UsersList; 

		SelectorWrapper myWrap = new SelectorWrapper(myErrorMessage, mySObjectList); 

		return myWrap;
	}
    /**
    *————————————————————————————————————————————————————
    * @Name: getCertAdmins
    * @Description
    * Returns User records based on the User Ids passed
    * 
    *————————————————————————————————————————————————————
    * @params  	
    * @returns  SelectorWrapper		A wrapper class containing the errorMessage and the List 
    *————————————————————————————————————————————————————
    **/
    public static SelectorWrapper getCertAdmin() {  
    	String myQuery; 
    	String myErrorMessage; 
        String grpName = 'SPARTN Certification Administrators';
    	List<User> UsersList = new List<User>(); 
    	List<SObject> mySObjectList = new List<SObject>(); 

    	QueryUtilityWrapper myQuWrap = QueryUtility.beginDynamicQuery(Label.OBJAPI_USER);   
    	if(myQuWrap.ErrorMessage == null) { 

    		myQuery = myQuWrap.QueryString; 
    		myQuery += ' '+System.Label.WHERE +' Id IN (SELECT UserOrGroupId FROM GroupMember where Group.Name =: grpName )';


    		try {

    			UsersList = Database.query(myQuery); 

    			} catch(QueryException qe) {

    				system.debug(System.Label.SOQL_Query_Error + qe.getMessage());
    				myErrorMessage = System.Label.QueryErrorSobjectException + qe.getMessage();
    			}
		}
		mySObjectList = UsersList; 

		SelectorWrapper myWrap = new SelectorWrapper(myErrorMessage, mySObjectList); 

		return myWrap;
	}
    
    
}
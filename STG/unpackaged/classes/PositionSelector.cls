/**
*___________________________________________________
*@Name: 	PositionSelector 
*@Author: 	Hemanth Kesapragada
*@Created: 	Date: 12/18/2017
*@Used_By: 	SPARTN
*___________________________________________________
*@Description: Selector class for Position__c
* 
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/
public with sharing class PositionSelector {
	/**
    *——	——————————————————————————————————————————————————
    * @Name: getPositionDetailsById
    * @Description
    * Fetches list of PositionRecords based on the Id
    * 
    *————————————————————————————————————————————————————
    * @params   
    * @returns  SelectorWrapper     Wrapper with list of EmployeeHierarchy Records
    *————————————————————————————————————————————————————
    **/
    public static SelectorWrapper getPositionDetailsById(List<Id> positionIds) {  
        String myQuery;

        String myErrorMessage; 
        List<Position__c> positions = new List<Position__c>(); 
        List<SObject> mySObjectList = new List<SObject>(); 

        QueryUtilityWrapper myQuWrap = QueryUtility.beginDynamicQuery(Label.OBJAPI_POSITION);   
        if(myQuWrap.ErrorMessage == null) { 

        	myQuery = myQuWrap.QueryString; 
        	myQuery += System.Label.WHERE +' Id IN :  positionIds';
			try {

        		positions = Database.query(myQuery); 

    		} catch(QueryException qe) {

    			system.debug(System.Label.SOQL_Query_Error + qe.getMessage());
    			myErrorMessage = System.Label.QueryErrorSobjectException + qe.getMessage();
    		}
        }
        mySObjectList = positions; 

        SelectorWrapper myWrap = new SelectorWrapper(myErrorMessage, mySObjectList); 

        return myWrap;
    }
    
    
    	/**
    *——	——————————————————————————————————————————————————
    * @Name: getPositionContactDetailsById
    * @Description
    * Fetches list of PositionRecords based on the Id
    * 
    *————————————————————————————————————————————————————
    * @params   
    * @returns  SelectorWrapper     Wrapper with list of EmployeeHierarchy Records
    *————————————————————————————————————————————————————
    **/
    public static SelectorWrapper getPositionContactDetailsById(List<Id> positionIds) {  
        String myQuery;

        String myErrorMessage; 
        List<Position__c> positions = new List<Position__c>(); 
        List<SObject> mySObjectList = new List<SObject>(); 

        QueryUtilityWrapper myQuWrap = QueryUtility.beginDynamicQuery(LABEL.OBJAPI_POSITION);   
        if(myQuWrap.ErrorMessage == null) { 
        myQuery = System.Label.SELECT+' Id,SpartnSupervisor__r.Personnel_Number__c  ';
    	myQuery += System.Label.FROM +' '+Label.OBJAPI_POSITION+' '; 
    	myQuery += System.Label.WHERE +' Id IN : positionIds';
			try {

        		positions = Database.query(myQuery); 

    		} catch(QueryException qe) {

    			system.debug(System.Label.SOQL_Query_Error + qe.getMessage());
    			myErrorMessage = System.Label.QueryErrorSobjectException + qe.getMessage();
    		}
        }
        mySObjectList = positions; 

        SelectorWrapper myWrap = new SelectorWrapper(myErrorMessage, mySObjectList); 

        return myWrap;
    }
    
    
}
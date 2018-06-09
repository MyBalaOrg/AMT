/**
*___________________________________________________
*@Name: 	HierarchyAssignmentSelector 
*@Author: 	Raj Pandy
*@Created: 	Date: 03/14/2018
*@Used_By: 	Global
*___________________________________________________
*@Description: Selector class for EPW_Hierarchy_Assignment__c
*@Update: 6-6-18 [Boom Bertetti] updated getSPARTNManagerByContact to use reference fields from SPARTN_Manager__c instead EPW_Contact__c
*___________________________________________________
**/

public with sharing class HierarchyAssignmentSelector {
    
    public static Boolean DoFailTest = FALSE;
    /**
    *——	——————————————————————————————————————————————————
    * @Name: getHrAssgnmentByContact
    * @Description
    * Fetches list of Hierarchy Assignment records for each employee
    * 
    *————————————————————————————————————————————————————
    * @params   
    * @returns  SelectorWrapper     Wrapper with list of HierarchyAssignment Records
    *————————————————————————————————————————————————————
    **/
    public static SelectorWrapper getHrAssgnmentByContact(Set<Id> contactIds) {
        String myQuery;

    	String myErrorMessage; 
    	List<EPW_Hierarchy_Assignment__c> haList = new List<EPW_Hierarchy_Assignment__c>(); 
    	List<SObject> mySObjectList = new List<SObject>(); 
        QueryUtilityWrapper myQuWrap = QueryUtility.beginDynamicQuery(Label.OBJAPI_HIERARCHY_ASSIGNMENT);   
        if(myQuWrap.ErrorMessage == null) { 
            myQuery = myQuWrap.QueryString;
            myQuery = myQuery.replace(System.Label.SELECT+' ',System.Label.SELECT+' EPW_Position_Hierarchy__r.EPW_Parent_Position_Hierarchy__c, EPW_Position_Hierarchy__r.EPW_Parent_Position_Hierarchy__r.RecordTypeId,');
            //myQuery += System.Label.FROM +' '+RevSys_StaticUtility.OBJAPI_HIERARCHY_ASSIGNMENT+' '; 
            myQuery += System.Label.WHERE +' EPW_Contact__c IN : contactIds';

            if(Test.isRunningTest() && DoFailTest){
                myQuery = myQuery.replace('SELECT', 'FAIL');
            }
            
            system.debug('myQuery  ' + myQuery); 
            system.debug('contactIds  ' + contactIds); 


            try {

              haList = Database.query(myQuery); 

              } catch(QueryException qe) {

                 system.debug(System.Label.SOQL_Query_Error + qe.getMessage());
                 myErrorMessage = System.Label.QueryErrorSobjectException + qe.getMessage();
             }
        }

    		mySObjectList = haList; 

    		SelectorWrapper myWrap = new SelectorWrapper(myErrorMessage, mySObjectList); 

    		return myWrap;
    }
    
    /**
    *——	——————————————————————————————————————————————————
    * @Name: getHrAssgnmentByPositionHierarchy
    * @Description
    * Fetches list of Hierarchy Assignment records for each position hierarchy
    * 
    *————————————————————————————————————————————————————
    * @params   
    * @returns  SelectorWrapper     Wrapper with list of HierarchyAssignment Records
    *————————————————————————————————————————————————————
    **/
    public static SelectorWrapper getHrAssgnmentByPositionHierarchy(Set<Id> positionHierarchyIds) {
        String myQuery;

    	String myErrorMessage; 
    	List<EPW_Hierarchy_Assignment__c> haList = new List<EPW_Hierarchy_Assignment__c>(); 
    	List<SObject> mySObjectList = new List<SObject>(); 
        QueryUtilityWrapper myQuWrap = QueryUtility.beginDynamicQuery(Label.OBJAPI_HIERARCHY_ASSIGNMENT);   
        if(myQuWrap.ErrorMessage == null) { 
            myQuery = myQuWrap.QueryString;
            myQuery = myQuery.replace(System.Label.SELECT+' ',System.Label.SELECT+' EPW_Position_Hierarchy__r.EPW_Parent_Position_Hierarchy__c,EPW_Position_Hierarchy__r.EPW_Parent_Position_Hierarchy__r.RecordTypeId,');
           // myQuery = System.Label.SELECT+' Id, EPW_Contact__c, EPW_Position_Hierarchy__r.EPW_Parent_Position_Hierarchy__c, EPW_Position_Hierarchy__r.EPW_Parent_Position_Hierarchy__r.RecordTypeId ';
            //myQuery += System.Label.FROM +' '+RevSys_StaticUtility.OBJAPI_HIERARCHY_ASSIGNMENT+' '; 
            myQuery += System.Label.WHERE +' EPW_Position_Hierarchy__c IN : positionHierarchyIds';

             if(Test.isRunningTest() && DoFailTest){
                myQuery = myQuery.replace('SELECT', 'FAIL');
            }
            
            system.debug('myQuery  ' + myQuery); 
            system.debug('positionHierarchyIds  ' + positionHierarchyIds); 

            try {

              haList = Database.query(myQuery); 

              } catch(QueryException qe) {

                 system.debug(System.Label.SOQL_Query_Error + qe.getMessage());
                 myErrorMessage = System.Label.QueryErrorSobjectException + qe.getMessage();
             }
        }

            system.debug('myErrorMessage  ' + myErrorMessage);
            system.debug('haList  ' + haList);

            mySObjectList = haList; 

    		SelectorWrapper myWrap = new SelectorWrapper(myErrorMessage, mySObjectList); 

    		return myWrap;
    }
    
     /**
    *——	——————————————————————————————————————————————————
    * @Name: getSPARTNManagerByContact
    * @Description
    * Fetches list of Hierarchy Assignment records for each employee
    * 
    *————————————————————————————————————————————————————
    * @params   
    * @returns  SelectorWrapper     Wrapper with list of HierarchyAssignment Records
    *————————————————————————————————————————————————————
    **/
    public static SelectorWrapper getSPARTNManagerByContact(Set<Id> contactIds) {
        String myQuery;

    	String myErrorMessage; 
    	List<EPW_Hierarchy_Assignment__c> haList = new List<EPW_Hierarchy_Assignment__c>(); 
    	List<SObject> mySObjectList = new List<SObject>(); 
        QueryUtilityWrapper myQuWrap = QueryUtility.beginDynamicQuery(Label.OBJAPI_HIERARCHY_ASSIGNMENT);   
        if(myQuWrap.ErrorMessage == null) { 
            myQuery = myQuWrap.QueryString;
            myQuery = myQuery.replace(System.Label.SELECT+' ',System.Label.SELECT+' SPARTN_Manager__r.Cost_Center__c, SPARTN_Manager__r.Craft__c, SPARTN_Manager__r.Department,SPARTN_Manager__r.Division__c,SPARTN_Manager__r.Occupation__c, SPARTN_Manager__r.Org_Unit_Number__c, SPARTN_Manager__r.Position_Abbrv__c, SPARTN_Manager__r.Region__c,EPW_Position_Hierarchy__r.RecordTypeId,');
            //myQuery += System.Label.FROM +' '+RevSys_StaticUtility.OBJAPI_HIERARCHY_ASSIGNMENT+' '; 
            myQuery += System.Label.WHERE +' EPW_Contact__c IN : contactIds';

            if(Test.isRunningTest() && DoFailTest){
                myQuery = myQuery.replace('SELECT', 'FAIL');
            }
            
            system.debug('myQuery  ' + myQuery); 
            system.debug('contactIds  ' + contactIds); 


            try {

              haList = Database.query(myQuery); 

              } catch(QueryException qe) {

                 system.debug(System.Label.SOQL_Query_Error + qe.getMessage());
                 myErrorMessage = System.Label.QueryErrorSobjectException + qe.getMessage();
             }
        }

    		mySObjectList = haList; 

    		SelectorWrapper myWrap = new SelectorWrapper(myErrorMessage, mySObjectList); 

    		return myWrap;
    }

    
    
    
    
    
}
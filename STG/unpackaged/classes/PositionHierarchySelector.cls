/**
*___________________________________________________
*@Name: PositionHierarchySelector
*@Author: Hemanth Kesapragada
*@Created: Date: 3/14/2017
*@Used_By: SPARTN
*___________________________________________________
*@Description: Handles business logic around Position hierarchy object
* 
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/
public with sharing class PositionHierarchySelector {
    public static Boolean DoFailTest = FALSE;
    /**
*————————————————————————————————————————————————————
* @Name: getHrAssgnmentQueryString
* @Description
* Specifically frames the query 
*————————————————————————————————————————————————————
* @params   
* @returns  String      A method to frame the query
*————————————————————————————————————————————————————
**/
    public static String getPosHrQueryString() {  
        String myQuery; 
        
        QueryUtilityWrapper myQuWrap = QueryUtility.beginDynamicQuery(Label.OBJAPI_POSITION_HIERARCHY);   
        if(myQuWrap.ErrorMessage == null) { 
            
            myQuery = myQuWrap.QueryString; 
            
        }
        
        return myQuery;
    }
    
    /**
*——	——————————————————————————————————————————————————
* @Name: getPositionHierarchyById
* @Description
* Fetches list of Position Hierarchy records by Id
* 
*————————————————————————————————————————————————————
* @params   
* @returns  SelectorWrapper     Wrapper with list of Position Hierarchy Records
*————————————————————————————————————————————————————
**/
    public static SelectorWrapper getPositionHierarchyById(Set<Id> positionHierarchySet) {
        String myQuery = getPosHrQueryString();
        
        String myErrorMessage; 
        List<EPW_Position_Hierarchy__c> phList = new List<EPW_Position_Hierarchy__c>(); 
        List<SObject> mySObjectList = new List<SObject>(); 
        
        
        myQuery += System.Label.WHERE +' Id IN : positionHierarchySet';
        if(Test.isRunningTest() && DoFailTest) {
                myQuery = myQuery.replace('SELECT', 'FAIL') ;
            }
        try {
            
            phList = Database.query(myQuery); 
            
        } catch(QueryException qe) {
            
            system.debug(System.Label.SOQL_Query_Error + qe.getMessage());
            myErrorMessage = System.Label.QueryErrorSobjectException + qe.getMessage();
        }
        
        mySObjectList = phList; 
        
        SelectorWrapper myWrap = new SelectorWrapper(myErrorMessage, mySObjectList); 
        
        return myWrap;
    }
}
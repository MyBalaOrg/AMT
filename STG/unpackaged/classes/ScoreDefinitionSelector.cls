/**
*___________________________________________________
*@Name: 	ScoreDefinitionSelector
*@Author: 	Sudhindra Katti
*@Created: 	Date: 2/27/2017
*@Used_By: 	Global 
*___________________________________________________
*@Description: Selector class for ScoreDefinitions__mdt 
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/
global with sharing class ScoreDefinitionSelector {

    /**
    *————————————————————————————————————————————————————
    * @Name: getScoreDefinitions
    * @Description
    * Specifically returns records based on a category list 
    * 
    *————————————————————————————————————————————————————
    * @params  	theCategoryList 	A list of Categories 
    * @returns  SelectorWrapper		A wrapper class containing the errorMessage and the List 
    *————————————————————————————————————————————————————
    **/ 
    public static SelectorWrapper getScoreDefinitions(String theAppName) {              
            
        String myQuery; 

        String myErrorMessage; 

        List<SPARTN_Score_Definition__mdt> mySasList = new List<SPARTN_Score_Definition__mdt>(); 
        List<SObject> mySObjectList = new List<SObject>(); 

        QueryUtilityWrapper myQuWrap = QueryUtility.beginDynamicQuery(RevSys_StaticUtility.OBJAPI_SCORE_DEFINITION_SETTING);   

        if(myQuWrap.ErrorMessage == null) { 

        	myQuery = myQuWrap.QueryString; 
			myQuery += System.Label.RevSys_ScoreDefinitions_WHERE; 
        
        system.debug('myquery$$$$'+myQuery);    
	        try {
	        	
				mySasList = Database.query(myQuery); 

			} catch(QueryException qe) {

	    		system.debug(System.Label.SOQL_Query_Error + qe.getMessage() );
	    		myErrorMessage = System.Label.StationAuditSetting_Query_Error + qe.getMessage();
			}
		}

		mySObjectList = mySasList; 

		SelectorWrapper myWrap = new SelectorWrapper(myErrorMessage, mySObjectList); 

        return myWrap;   
	}
}
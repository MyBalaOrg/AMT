/**
*___________________________________________________
*@Name: 	StationAuditSettingSelector
*@Author: 	Chuck Walley
*@Created: 	Date: 11/19/2017
*@Used_By: 	Global 
*___________________________________________________
*@Description: Selector class for Station_Audit_Setting__mdt 
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/
global with sharing class StationAuditSettingSelector {

    /**
    *————————————————————————————————————————————————————
    * @Name: getRevSysFindings
    * @Description
    * Specifically returns records based on a category list 
    * 
    *————————————————————————————————————————————————————
    * @params  	theCategoryList 	A list of Categories 
    * @returns  SelectorWrapper		A wrapper class containing the errorMessage and the List 
    *————————————————————————————————————————————————————
    **/ 
    public static SelectorWrapper getRevSysFindings(String theAppName, 
     									 		  List<String> theCategoryList) {              
            
        String myQuery; 

        String myErrorMessage; 

        List<Station_Audit_Setting__mdt> mySasList = new List<Station_Audit_Setting__mdt>(); 
        List<SObject> mySObjectList = new List<SObject>(); 

        QueryUtilityWrapper myQuWrap = QueryUtility.beginDynamicQuery(Label.OBJAPI_STATION_AUDIT_SETTING);   

        if(myQuWrap.ErrorMessage == null) { 

        	myQuery = myQuWrap.QueryString; 
			myQuery += System.Label.RevSys_StationAudit_WHERE; 
        	
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
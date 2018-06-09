/**
*___________________________________________________
*@Name:     FieldConversionMapSelector
*@Author:   Chuck Walley
*@Created:  March 16, 2018
*@Used_By:  Global 
*___________________________________________________
*@Description: Selector class for FieldConversionMap object 
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/
public with sharing class FieldConversionMapSelector {
	
	// Record Types
    private static Id FIELDCONVERSIONMAP_SPARTNCRAFT_RECTYPE_ID                 
        = Schema.SObjectType.FieldConversionMap__c.getRecordTypeInfosByName().get(Label.RevSys_FieldConversionMap_RT_Label_SPARTN_Craft).getRecordTypeId();
    private static Id FIELDCONVERSIONMAP_SPARTNLOCATION_RECTYPE_ID                 
        = Schema.SObjectType.FieldConversionMap__c.getRecordTypeInfosByName().get(Label.RevSys_FieldConversionMap_RT_Label_SPARTN_Location).getRecordTypeId();
	
	
	public static Boolean DoFailTest = FALSE;
    /**
    *————————————————————————————————————————————————————
    * @Name: getContacts
    * @Description
    * Returns contact records based on the contacts passed
    * 
    *————————————————————————————————————————————————————
    * @params   
    * @returns  SelectorWrapper     A wrapper class containing the errorMessage and the List 
    *————————————————————————————————————————————————————
    **/
    public static SelectorWrapper getByOrgUnitAndJobNumber(Set<String> jobCodeSet, 
                                                           Set<String> orgUnitSet) {  
        String myQuery; 

        String myErrorMessage; 
        List<FieldConversionMap__c> myFieldConMapList = new List<FieldConversionMap__c>(); 
        List<SObject> mySObjectList = new List<SObject>(); 

        Id myCraftRecTypeId    = FIELDCONVERSIONMAP_SPARTNCRAFT_RECTYPE_ID; 
        Id myLocationRecTypeId = FIELDCONVERSIONMAP_SPARTNLOCATION_RECTYPE_ID; 


        QueryUtilityWrapper myQuWrap = QueryUtility.beginDynamicQuery(Label.OBJAPI_FIELDCONVERSIONMAP);   
        if(myQuWrap.ErrorMessage == null) { 

            myQuery = myQuWrap.QueryString; 
            myQuery += ' WHERE  (RecordTypeID = :myCraftRecTypeId OR ' ;
            myQuery += '         RecordTypeID = :myLocationRecTypeId) ' ;
            myQuery += '   AND  (SAP_JobCode__c IN :jobCodeSet  OR ' ;
            myQuery += '         SAP_OrgUnit__c IN :orgUnitSet) ' ;
            System.debug(myQuery);
            	 if(Test.isRunningTest() && DoFailTest) {
            myQuery = myQuery.replace('SELECT', 'FAIL') ;
            }

            try {
                myFieldConMapList = Database.query(myQuery); 

                } catch(QueryException qe) {

                    system.debug(System.Label.SOQL_Query_Error + qe.getMessage());
                    myErrorMessage = System.Label.QueryErrorSobjectException + qe.getMessage();
                }
        }
        mySObjectList = myFieldConMapList; 

        SelectorWrapper myWrap = new SelectorWrapper(myErrorMessage, mySObjectList); 

        return myWrap;
    }
}
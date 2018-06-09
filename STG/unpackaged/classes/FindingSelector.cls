/**
*___________________________________________________
*@Name: 	FindingSelector
*@Author: 	Chuck Walley
*@Created: 	Date: 11/19/2017
*@Used_By: 	Global 
*___________________________________________________
*@Description: Selector class for Station_Audit_Setting__mdt 
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/
global with sharing class FindingSelector {
    public static Boolean DoFailTest = FALSE;
    private Set<Id> observationIdSet;
    private Set<Id> findingIdsSet;
    private String whereClause;
    private String orderBy;
    private String limitNumber;
    private String offsetNumber;
    private List<Schema.FieldSetMember> fields = Schema.SObjectType.Finding__c.fieldSets.SelectorFields.getFields();
    
    /**
    *————————————————————————————————————————————————————
    * @Name: getFieldsList
    * @Description
    * Specifically returns a list of Finding fields in the SelectorFields field set in the String format 
    * 
    *————————————————————————————————————————————————————
    * @returns  fieldsList     A list of string
    *————————————————————————————————————————————————————
    **/ 
    public List<String> getFieldsList() {
        List<String> fieldsList = new List<String>();
        for (Schema.FieldSetMember field : fields) {
            fieldsList.add(field.getFieldPath());
        }
        return fieldsList;
    }

    // Constructor
    public FindingSelector() {}
    // Constructor
    public FindingSelector(Set<Id> findingIdsSet) {
        this(findingIdsSet, new Map<String, String>());
    }   
    // Constructor
    /**
    * @Description
    * To set the values findingIdsSet with value from findingIdsSet param
    * and set whereClause, orderBy, limitNumber, offsetNumber with value in the 
    * soqlAttributes that has matching key.
    *----------------------------------------------------
    * @params findingIdsSet  A set of Finding Ids
    *         soqlAttributes A map of string contains keys:
    *                        'whereClause', 'orderBy', 'limitNumber' and 'offeetNumber'
    *----------------------------------------------------
    */
    public FindingSelector(Set<Id> findingIdsSet, Map<String, String> soqlAttributes) {
        this.findingIdsSet = findingIdsSet;
        if (soqlAttributes.containsKey('whereClause') != null) {
            this.whereClause = soqlAttributes.get('whereClause');
        }
        if (soqlAttributes.containsKey('orderBy') != null) {
            this.orderBy = soqlAttributes.get('orderBy');
        }
        if (soqlAttributes.containsKey('limitNumber') != null) {
            this.limitNumber = soqlAttributes.get('limitNumber');
        }
        if (soqlAttributes.containsKey('offsetNumber') != null) {
            this.offsetNumber = soqlAttributes.get('offsetNumber');
        }       
    }                                                     

    /**
    *————————————————————————————————————————————————————
    * @Name: getObsRelatedFindings
    * @Description
    * Specifically returns records based on a Observation ID List 
    *              without limits  
    * 
    *————————————————————————————————————————————————————
    * @params  	theObsIdSet 		A set of Observation Ids  
    * @returns  SelectorWrapper		A wrapper class containing the errorMessage and the List 
    *————————————————————————————————————————————————————
    **/ 
    public static SelectorWrapper getObsRelatedFindings(Set<Id> theObsIdSet) {              
            
        String myQuery; 

        String myErrorMessage; 

        List<Finding__c> myFindingList = new List<Finding__c>(); 
        List<SObject> mySObjectList = new List<SObject>(); 

        QueryUtilityWrapper myQuWrap = QueryUtility.beginDynamicQuery(Label.OBJAPI_FINDING);   

        if(myQuWrap.ErrorMessage == null) { 

        	myQuery = myQuWrap.QueryString; 
			myQuery += System.Label.RevSys_Finding_by_Obs_Id_WHERE; 
            
            if(Test.isRunningTest() && DoFailTest) {
                myQuery = myQuery.replace('SELECT', 'FAIL') ;
            }
	        try {
	        	
				myFindingList = Database.query(myQuery); 

			} catch(QueryException qe) {

	    		system.debug(System.Label.SOQL_Query_Error + qe.getMessage() );
	    		myErrorMessage = System.Label.Finding_Query_Error + qe.getMessage();
			}
		}

		mySObjectList = myFindingList; 

		SelectorWrapper myWrap = new SelectorWrapper(myErrorMessage, mySObjectList); 

        return myWrap;   
	}

    /**
    *————————————————————————————————————————————————————
    * @Name: getObsLimitedRelatedFindings
    * @Description
    * Specifically returns records based on a category list 
    * 
    *————————————————————————————————————————————————————
    * @params   theObsIdSet         A set of Observation Ids  
    * @returns  SelectorWrapper     A wrapper class containing the errorMessage and the List 
    *————————————————————————————————————————————————————
    **/ 
    public SelectorWrapper getObsLimitedRelatedFindings(Set<Id> theObsIdSet) {              

        String myErrorMessage;
        List<SObject> mySObjectList;

        orderBy = 'Observation__c, Sequence__c '; 
        limitNumber = '500'; 

        String soqlStr = new QueryUtility().setSelectFields(getFieldsList())
                                            .setWhereClause('Observation__c IN :theObsIdSet')
                                            .setObjectToSoql(RevSys_StaticUtility.OBJAPI_FINDING)
                                            .setOrderBy(orderBy)
                                            .setLimit(limitNumber)
                                            .setOffSet(offsetNumber)
                                            .setSOQLString();
         if(Test.isRunningTest() && DoFailTest) {
                soqlStr = soqlStr.replace('ORDER BY', '') ;
            }
        try {

            mySObjectList = Database.query(soqlStr); 
			System.debug('Finding'+soqlStr);
        } catch(QueryException qe) {

            system.debug(System.Label.SOQL_Query_Error + qe.getMessage());
            myErrorMessage = System.Label.QueryErrorSobjectException + qe.getMessage();
        }

        SelectorWrapper myWrap = new SelectorWrapper(myErrorMessage, mySObjectList); 

        return myWrap; 
    }

    /**
    *————————————————————————————————————————————————————
    * @Name: selectById
    * @Description
    * Selector method to get Findings by Id with the fields in the SelectorFields field set
    * 
    *————————————————————————————————————————————————————
    * @params   none         
    * @returns  SelectorWrapper     A wrapper class containing the errorMessage and the List 
    *————————————————————————————————————————————————————
    **/ 
    public SelectorWrapper selectById() {
        String myErrorMessage;
        List<SObject> mySObjectList;

        String soqlStr = new QueryUtility().setSelectFields(getFieldsList())
                                            .setWhereClause('Id IN :findingIdsSet')
                                            .setObjectToSoql(RevSys_StaticUtility.OBJAPI_FINDING)
                                            .setOrderBy(orderBy)
                                            .setLimit(limitNumber)
                                            .setOffSet(offsetNumber)
                                            .setSOQLString();
        try {

            mySObjectList = Database.query(soqlStr); 

        } catch(QueryException qe) {

            system.debug(System.Label.SOQL_Query_Error + qe.getMessage());
            myErrorMessage = System.Label.QueryErrorSobjectException + qe.getMessage();
        }

        SelectorWrapper myWrap = new SelectorWrapper(myErrorMessage, mySObjectList); 

        return myWrap;
    }                                                         

    /**
    *————————————————————————————————————————————————————
    * @Name: selectAllFieldsById
    * @Description
    * Selector method to get Findings by Id with the all the fields
    * 
    *————————————————————————————————————————————————————
    * @params   none         
    * @returns  SelectorWrapper     A wrapper class containing the errorMessage and the List 
    *————————————————————————————————————————————————————
    **/ 
    public SelectorWrapper selectAllFieldsById() {
        String myErrorMessage;
        List<SObject> mySObjectList;

        String soqlStr = new QueryUtility().setWhereClause('Id IN :findingIdsSet')
                                            .setObjectToSoql(RevSys_StaticUtility.OBJAPI_FINDING)
                                            .setOrderBy(orderBy)
                                            .setLimit(limitNumber)
                                            .setOffSet(offsetNumber)
                                            .soqlAllFields();
        try {

            mySObjectList = Database.query(soqlStr); 

        } catch(QueryException qe) {

            system.debug(System.Label.SOQL_Query_Error + qe.getMessage());
            myErrorMessage = System.Label.QueryErrorSobjectException + qe.getMessage();
        }

        SelectorWrapper myWrap = new SelectorWrapper(myErrorMessage, mySObjectList); 

        return myWrap;
    }                                                         

    /**
    *————————————————————————————————————————————————————
    * @Name: getSubQueryStr
    * @Description
    * Construct string for subquery of Finding in parent object query.
    * 
    *————————————————————————————————————————————————————
    * @params   fields             A list of fields in string format
    *           whereClause        WHERE clause for the sub soql
    *           orderBy            ORDER BYvalue for sub soql
    *           limitNumber        LIMIT number of return records
    *           offsetNumber       OFFSET number of return records
    *           relationshipName   the relationship name of Finding in the parent object
    * @returns  soqlStr     A string of soql
    *————————————————————————————————————————————————————
    **/ 
    public static String getSubQueryStr(List<String> fields, 
                                                 String whereClause, 
                                                 String orderBy, 
                                                 String limitNumber, 
                                                 String offsetNumber, 
                                                 String relationshipName) {
        String soqlStr = new QueryUtility().setSelectFields(fields)
                                            .setWhereClause(whereClause)
                                            .setOrderBy(orderBy)
                                            .setLimit(limitNumber)
                                            .setOffSet(offsetNumber)
                                            .setRelationshipName(relationshipName)
                                            .setSOQLString();

        return soqlStr;
    }
    
     /**
    *————————————————————————————————————————————————————
    * @Name: getObsLimitedRelatedFindingsVersion
    * @Description
    * Specifically returns records based on a category list 
    * 
    *————————————————————————————————————————————————————
    * @params   theObsIdSet, LastModifiedVersion         A set of Observation Ids  
    * @returns  SelectorWrapper     A wrapper class containing the errorMessage and the List 
    *————————————————————————————————————————————————————
    **/ 
    public SelectorWrapper getObsLimitedRelatedFindingsVersion(Set<Id> theObsIdSet, Integer LastModifiedVersion) {              

        String myErrorMessage;
        List<SObject> mySObjectList;

        orderBy = 'Observation__c, Sequence__c '; 
        limitNumber = '500'; 

        String soqlStr = new QueryUtility().setSelectFields(getFieldsList())
                                            .setWhereClause('Observation__c IN :theObsIdSet AND QuestionLastModifiedVersion__c= :LastModifiedVersion')
                                            .setObjectToSoql(RevSys_StaticUtility.OBJAPI_FINDING)
                                            .setOrderBy(orderBy)
                                            .setLimit(limitNumber)
                                            .setOffSet(offsetNumber)
                                            .setSOQLString();
        if(Test.isRunningTest() && DoFailTest) {
                soqlStr = soqlStr.replace('ORDER BY', '') ;
            }
        try {

            mySObjectList = Database.query(soqlStr); 
		System.debug('soqlStr Findings'+soqlStr+'versionNumber'+LastModifiedVersion);
        } catch(QueryException qe) {

            system.debug(System.Label.SOQL_Query_Error + qe.getMessage());
            myErrorMessage = System.Label.QueryErrorSobjectException + qe.getMessage();
        }

        SelectorWrapper myWrap = new SelectorWrapper(myErrorMessage, mySObjectList); 

        return myWrap; 
    }
 
}
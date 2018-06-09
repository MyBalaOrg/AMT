/**
*___________________________________________________
*@Name:    ObservationSelector
*@Author:  Boom Bertetti
*@Created:  Date: 12/20/2017
*@Used_By:  Global 
*___________________________________________________
*@Description: Selector class for Observation__c object 
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/
public class ObservationSelector {
     
    public Boolean DoFailTest = FALSE; 
    
	private Set<Id> observationIdsSet;
	private String whereClause;
	private String orderBy;
	private String limitNumber;
	private String offsetNumber;
	public static Boolean DoFailTest1 = FALSE; 
	private List<Schema.FieldSetMember> fields = Schema.SObjectType.Observation__c.fieldSets.SelectorFields.getFields();

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
	// Constuctor
	public ObservationSelector(Set<Id> observationIdsSet) {
		this(observationIdsSet, new Map<String, String>());
	}	

    // Constuctor
    public ObservationSelector() {}

    

    // Constructor
    /**
    * @Description
    * To set the values observationIdsSet with value from observationIdsSet param
    * and set whereClause, orderBy, limitNumber, offsetNumber with value in the 
    * soqlAttributes that has matching key.
    *----------------------------------------------------
    * @params observationIdsSet  A set of Observation Ids
    *         soqlAttributes A map of string contains keys:
    *                        'whereClause', 'orderBy', 'limitNumber' and 'offsetNumber'
    *----------------------------------------------------
    */
	public ObservationSelector(Set<Id> observationIdsSet, Map<String, String> soqlAttributes) {
		this.observationIdsSet = observationIdsSet;
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
    * @Name: selectById
    * @Description
    * Selector method to get Observations by Id with the fields in the SelectorFields field set
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
											.setWhereClause('Id IN :observationIdsSet')
											.setObjectToSoql(Label.OBJAPI_OBSERVATION)
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
    * Selector method to get Observations by Id with the all the fields
    * 
    *————————————————————————————————————————————————————
    * @params   none         
    * @returns  SelectorWrapper     A wrapper class containing the errorMessage and the List 
    *————————————————————————————————————————————————————
    **/ 
	public SelectorWrapper selectAllFieldsById() {
		String myErrorMessage;
		List<SObject> mySObjectList;

		String soqlStr = new QueryUtility().setWhereClause('Id IN :observationIdsSet')
											.setObjectToSoql(Label.OBJAPI_OBSERVATION)
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
    * @Name: selectByIdWithFindings
    * @Description
    * Selector method to get Observations with Findings by Id with the fields in the SelectorFields field set
    * 
    *————————————————————————————————————————————————————
    * @params   none         
    * @returns  SelectorWrapper     A wrapper class containing the errorMessage and the List 
    *————————————————————————————————————————————————————
    **/ 
	public SelectorWrapper selectByIdWithFindings() {
		String myErrorMessage;
		List<SObject> mySObjectList;
		List<String> findingFields = new FindingSelector().getFieldsList();
		String findingSubSoql = FindingSelector.getSubQueryStr(findingFields, 
				                                                      null, 
				                                                      'Sequence__c ASC, Sub_category__c ASC', 
				                                                      null, 
				                                                      null, 
				                                                      'Findings__r');

		String soqlStr = new QueryUtility().setSelectFields(getFieldsList())
											.setWhereClause('Id IN :observationIdsSet')
											.setObjectToSoql(Label.OBJAPI_OBSERVATION)
											.setSubQuery(findingSubSoql)
											.setOrderBy(orderBy)
											.setLimit(limitNumber)
											.setOffSet(offsetNumber)
											.setSOQLString();
        System.debug('soqlStr : ' + soqlStr);
		try {

			mySObjectList = Database.query(soqlStr); 

		} catch(QueryException qe) {

			system.debug(System.Label.SOQL_Query_Error + qe.getMessage());
			myErrorMessage = System.Label.QueryErrorSobjectException + qe.getMessage();
		}

		SelectorWrapper myWrap = new SelectorWrapper(myErrorMessage, mySObjectList); 

		return myWrap;
	}														  

    
 /*
    *————————————————————————————————————————————————————
    * @Name: selectByEmployee
    * @Description
    * Selector method to get Observations by EmployeeId with the all the fields
    * 
    *————————————————————————————————————————————————————
    * @params   Employee Id Set         
    * @returns  SelectorWrapper     A wrapper class containing the errorMessage and the List 
    *————————————————————————————————————————————————————
    **/ 
	public SelectorWrapper selectByEmployee(Set<ID> empIdSet) {
		String myErrorMessage;
        String myQuery;
		List<SObject> mySObjectList;

		QueryUtilityWrapper myQuWrap = QueryUtility.beginDynamicQuery(Label.OBJAPI_OBSERVATION);   
        if(myQuWrap.ErrorMessage == null) { 
            
            myQuery = myQuWrap.QueryString; 
            myQuery += ' '+System.Label.WHERE +' Employee__c IN : empIdSet';            
        }
         if(Test.isRunningTest() && DoFailTest) {
            myQuery = myQuery.replace('SELECT', 'FAIL') ;
        }
		System.debug('myQuery$$'+myQuery);
        try {

			mySObjectList = Database.query(myQuery); 

		} catch(QueryException qe) {

			system.debug(System.Label.SOQL_Query_Error + qe.getMessage());
			myErrorMessage = System.Label.QueryErrorSobjectException + qe.getMessage();
		}

		SelectorWrapper myWrap = new SelectorWrapper(myErrorMessage, mySObjectList); 

		return myWrap;
	}
    
    

	
	/**
    *————————————————————————————————————————————————————
    * @Name: selectByEvaluationDateAndEmployee
    * @Description
    * Selector method to get Observations by Id with the all the fields
    * 
    *————————————————————————————————————————————————————
    * @params   none         
    * @returns  SelectorWrapper     A wrapper class containing the errorMessage and the List 
    *————————————————————————————————————————————————————
    */
    public static SelectorWrapper selectByEmployeeOrderEvaluationDate(Set<Id> empIdSet) {  
    	String myQuery;

    	String myErrorMessage; 
    	List<Observation__c> observationList = new List<Observation__c>(); 
    	List<SObject> mySObjectList = new List<SObject>(); 
     
     	AggregateResult[] allObservations = [SELECT max(EvaluationDateTime__c) evdate, Employee__c from observation__c where Employee__c IN :empIdSet group by Employee__c];
           
        mySObjectList = allObservations; 
        SelectorWrapper myWrap = new SelectorWrapper(myErrorMessage, mySObjectList); 
        return myWrap;
    } 

/**
    *————————————————————————————————————————————————————
    * @Name: getObservationsbyId
    * @Description
    * Selector method to get Observations by Id with the all the fields
    * 
    *————————————————————————————————————————————————————
    * @params   Id         
    * @returns  SelectorWrapper     A wrapper class containing the errorMessage and the List 
    *————————————————————————————————————————————————————
    */
    public static SelectorWrapper getObservationsbyId(Set<Id> obsId) {  
    	String myQuery;
        String myErrorMessage;
        List<SObject> mySObjectList;

    	QueryUtilityWrapper myQuWrap = QueryUtility.beginDynamicQuery(Label.OBJAPI_OBSERVATION);   
        if(myQuWrap.ErrorMessage == null) { 
            
            myQuery = myQuWrap.QueryString; 
            myQuery += ' '+System.Label.WHERE +' Id IN : obsId';            
        }
      if(Test.isRunningTest() && DoFailTest1) {
            myQuery = myQuery.replace('SELECT', 'FAIL') ;
        }
		System.debug('myQuery$$'+myQuery);
        try {

			mySObjectList = Database.query(myQuery); 

		} catch(QueryException qe) {

			system.debug(System.Label.SOQL_Query_Error + qe.getMessage());
			myErrorMessage = System.Label.QueryErrorSobjectException + qe.getMessage();
		}

		SelectorWrapper myWrap = new SelectorWrapper(myErrorMessage, mySObjectList); 

		return myWrap;
    } 

    /*
    *————————————————————————————————————————————————————
    * @Name: selectByEmployeeAndTestNum
    * @Description
    * Selector method to get Observations by EmployeeId with the all the fields
    * 
    *————————————————————————————————————————————————————
    * @params   Employee Id Set         
    * @returns  SelectorWrapper     A wrapper class containing the errorMessage and the List 
    *————————————————————————————————————————————————————
    **/ 
    public SelectorWrapper selectByEmployeeAndTestNum(Set<ID> empIdSet, Set<String> testNumSet, DateTime dateTimeLimit) {
        String myErrorMessage;
        String myQuery;
        List<SObject> mySObjectList;

        QueryUtilityWrapper myQuWrap = QueryUtility.beginDynamicQuery(Label.OBJAPI_OBSERVATION);     
        if(myQuWrap.ErrorMessage == null) { 
            
            myQuery = myQuWrap.QueryString; 
            myQuery += ' '+System.Label.WHERE +' Employee__c   IN : empIdSet';
            myQuery += ' '+System.Label.AND   +' TestNumber__c IN : testNumSet';   
            myQuery += ' '+System.Label.AND   +' EvaluationDateTime__c >= : dateTimeLimit';             
        }
        System.debug('myQuery$$'+myQuery);
        try {

            mySObjectList = Database.query(myQuery); 

        } catch(QueryException qe) {

            system.debug(System.Label.SOQL_Query_Error + qe.getMessage());
            myErrorMessage = System.Label.QueryErrorSobjectException + qe.getMessage();
        }

        SelectorWrapper myWrap = new SelectorWrapper(myErrorMessage, mySObjectList); 

        return myWrap;
    }

    /*
    *————————————————————————————————————————————————————
    * @Name: selectByEmployeeAndRecType
    * @Description
    * Selector method to get Observations by EmployeeId with the all the fields
    * 
    *————————————————————————————————————————————————————
    * @params   Employee Id Set         
    * @returns  SelectorWrapper     A wrapper class containing the errorMessage and the List 
    *————————————————————————————————————————————————————
    **/ 
    public SelectorWrapper selectByEmployeeAndRecType(Set<ID> empIdSet, Set<Id> recTypeSet, DateTime dateTimeLimit) {
        String myErrorMessage;
        String myQuery;
        List<SObject> mySObjectList;

        QueryUtilityWrapper myQuWrap = QueryUtility.beginDynamicQuery(Label.OBJAPI_OBSERVATION);     
        if(myQuWrap.ErrorMessage == null) { 
            
            myQuery = myQuWrap.QueryString; 
            myQuery += ' '+System.Label.WHERE +' Employee__c   IN : empIdSet';
            myQuery += ' '+System.Label.AND   +' RecordTypeId  IN : recTypeSet';   
            myQuery += ' '+System.Label.AND   +' EvaluationDateTime__c >= : dateTimeLimit';             
        }
        if(Test.isRunningTest() && DoFailTest) {
            myQuery = myQuery.replace('SELECT', 'FAIL') ;
        }
        System.debug('myQuery$$'+myQuery);
        try {

            mySObjectList = Database.query(myQuery); 

        } catch(QueryException qe) {

            system.debug(System.Label.SOQL_Query_Error + qe.getMessage());
            myErrorMessage = System.Label.QueryErrorSobjectException + qe.getMessage();
        }

        SelectorWrapper myWrap = new SelectorWrapper(myErrorMessage, mySObjectList); 

        return myWrap;
    }
    
    
}
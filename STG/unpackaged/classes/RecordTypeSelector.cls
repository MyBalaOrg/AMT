/**
*___________________________________________________
*@Name:    RecordTypeSelector
*@Author:  Boom Bertetti
*@Created:  Date: 2/1/2018
*@Used_By:  Global 
*___________________________________________________
*@Description: Selector class for RecordType object 
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/
public class RecordTypeSelector {
	private Set<Id> recordTypeIdsSet;
	private String objectType;
	private String orderBy;
	private String limitNumber;
    
    public Boolean DoFailTest = FALSE;

	public RecordTypeSelector(String objectType, String orderBy) {
		this.objectType = objectType;
		this.orderBy    = orderBy;
	}

	public List<String> getFieldsList() {
		return new List<String>{'Id','Name','DeveloperName', 'IsActive', 'SobjectType'};
	}
    /**
    *————————————————————————————————————————————————————
    * @Name: selectActiveRecordTypes
    * @Description
    * Selector method to get active record types by SobjectType 
    * 
    *————————————————————————————————————————————————————
    * @params   none         
    * @returns  SelectorWrapper     A wrapper class containing the errorMessage and a List of record types
    *————————————————————————————————————————————————————
    **/ 
	public SelectorWrapper selectActiveRecordTypes() {
		String myErrorMessage;
		List<SObject> mySObjectList;
		String whereClause = ' SobjectType = \'' + objectType + '\' ';
		whereClause       += ' AND IsActive = TRUE ';

		String soqlStr = new QueryUtility().setSelectFields(getFieldsList())
											.setWhereClause(whereClause)
											.setObjectToSoql('RecordType')
											.setOrderBy(orderBy)
											.setLimit(limitNumber)
											.setSOQLString();
        if(Test.isRunningTest() && DoFailTest){
            soqlStr = soqlStr.replace('SELECT','FAIL');
        }
        
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
    * @Name: selectAllActiveRecordTypes
    * @Description
    * Selector method to get active record types  
    * 
    *————————————————————————————————————————————————————
    * @params   none         
    * @returns  SelectorWrapper     A wrapper class containing the errorMessage and a List of record types
    *————————————————————————————————————————————————————
    **/ 
    public SelectorWrapper selectAllActiveRecordTypes() {
        String myErrorMessage;
        List<SObject> mySObjectList;
        String whereClause = ' IsActive = TRUE ';


        String soqlStr = new QueryUtility().setSelectFields(getFieldsList())
                                            .setWhereClause(whereClause)
                                            .setObjectToSoql('RecordType')
                                            .setOrderBy(orderBy)
                                            .setLimit(limitNumber)
                                            .setSOQLString();
        if(Test.isRunningTest() && DoFailTest){
            soqlStr = soqlStr.replace('SELECT','FAIL');
        }
        try {
            mySObjectList = Database.query(soqlStr); 

        } catch(QueryException qe) {

            system.debug(System.Label.SOQL_Query_Error + qe.getMessage());
            myErrorMessage = System.Label.QueryErrorSobjectException + qe.getMessage();
        }

        SelectorWrapper myWrap = new SelectorWrapper(myErrorMessage, mySObjectList); 

        return myWrap;
    }                                                         

}
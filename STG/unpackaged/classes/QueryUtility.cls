/**
*___________________________________________________
*@Name: 	QueryUtility
*@Author: 	Chuck Walley
*@Created: 	Date: 11/19/2017
*@Used_By: 	Global 
*___________________________________________________
*@Description: General utilities or querying objects 
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/
global with sharing class QueryUtility {

    private String objectToSOQL;
    private Set<Id> idsSet;
    @testVisible
    private Set<String> fieldsSet;
    private String fieldsString;
    private String whereClause;
    private String orderBy;
    private String limitRecords;
    private String offsetRows;
    private String relationShipNameToSoql;
    private String subQuery;

    // Constructor
    public QueryUtility() {}

    /**
    *————————————————————————————————————————————————————
    * @Name: beginDynamicQuery
    * @Description
    * Queries all fields to which the current user has access and returns them in 
    * a format to begin a query. (i.e. SELECT Id, This__c, That__c FROM TheObject__c 
    *————————————————————————————————————————————————————
    * @params  objectname  String value of the object name
    * @returns             String value of a query with all object fields
    *————————————————————————————————————————————————————
    **/ 
    public static QueryUtilityWrapper beginDynamicQuery(string theObject) {                

    	system.debug('UTILITY QueryUtility beginDynamicQuery-Start');    
        
        String myErrorMessage; 
        string myStartOfQuery = System.Label.SELECT + ' ';  

        try {

			for (Schema.SObjectField field 
				:Schema.getGlobalDescribe().get(theObject).getDescribe().Fields.getMap().values()) {            
	        	myStartOfQuery += field.getDescribe().getName() + System.Label.COMMA;          
	        }
	        
	        if (myStartOfQuery.endsWith(System.Label.COMMA)) {
	            myStartOfQuery = myStartOfQuery.substring(0,myStartOfQuery.lastIndexOf(System.Label.COMMA));
	        }
	        
	        myStartOfQuery += ' ' + System.Label.FROM + ' ' + theObject + '  ';         

		} catch(SObjectException e) {

			system.debug(System.Label.SOQL_Query_Error + e.getMessage() );
    		myErrorMessage = System.Label.QueryErrorSobjectException + e.getMessage();
		
		} catch(Exception e) {

			system.debug(System.Label.SOQL_Query_Error + e.getMessage() );
    		myErrorMessage = System.Label.QueryErrorSobjectException + e.getMessage();
		}

		QueryUtilityWrapper myQuWrap = new QueryUtilityWrapper(myErrorMessage, myStartOfQuery); 
                       
        system.debug('UTILITY QueryUtility beginDynamicQuery-End');   
        system.debug('The query is '+myQuWrap);

        return myQuWrap;         
    }  

    // Method converts the list of fields to set to ensure only unique fields are in the dynamic query
    public QueryUtility setSelectFields(List<String> fieldsInString) {
        List<String> fieldsList = fieldsInString;
        fieldsSet = new Set<String>();
        for (String field : fieldsList) {
            this.fieldsSet.add(field);
        }
        return this;
    }

    // Method sets the FROM object in the dynamic query
    public QueryUtility setObjectToSoql(String theObject) {
        this.objectToSOQL = theObject;
        return this;
    }

    // Method sets the WHERE in the dynamic query
    public QueryUtility setWhereClause(String whereExpression) {
        this.whereClause = whereExpression;
        return this;
    }

    // Method sets the ORDER BY in the dynamic query
    public QueryUtility setOrderBy(String orderByString) {
        this.orderBy = orderByString;
        return this;
    }

    // Method sets the LIMIT in the dynamic query
    public QueryUtility setLimit(String limitNumber) {
        this.limitRecords = limitNumber;
        return this;
    }

    // Method sets the OFFSET in the dynamic query
    public QueryUtility setOffSet(String offsetNumber) {
        this.offsetRows = offsetNumber;
        return this;
    }

    // Method sets the relationship name in  FROM subquery of the dynamic query
    public QueryUtility setRelationshipName(String relationShipName) {
        this.relationShipNameToSoql = relationShipName;
        return this;
    }

    // Method sets the sub query after all the fields in the dynamic query
    public QueryUtility setSubQuery(String subQueryString) {
        this.subQuery = subQueryString;
        return this;
    }

    // Method joins the string to form soql string for dynamic query with only limit number of fields
    public String setSOQLString() {
        String theSOQL = 'SELECT ';
        // Add Id if the fieldsSet doesn't have any field.
        if (fieldsSet.size() == 0) {

            theSOQL += 'Id';

        } else {

            List<String> fieldsForSOQL = new List<String>(fieldsSet);
            theSOQL += String.join(fieldsForSOQL,', ');
        }

        if (subQuery != null) {
            theSOQL += ', (' + subQuery + ')';
        }

        if (relationShipNameToSoql != null) {
            theSOQL += ' FROM ' + relationShipNameToSoql;
        } else {
            theSOQL += ' FROM ' + objectToSOQL;
        }

        if (whereClause != null) {
            theSOQL += ' WHERE ' + whereClause;
        }

        if (orderBy != null) {
            theSOQL += ' ORDER BY ' + orderBy;
        }
    
        if (limitRecords != null) {
            theSOQL += ' LIMIT ' + limitRecords;
        }

        if (offsetRows != null) {
            theSOQL += ' OFFSET ' + limitRecords;
        }

        System.debug('UTILITY QueryUtility setSOQLString value: ' + theSOQL);

        return theSOQL;
    }

    // Method joins the string to form soql string for dynamic query with all the fields in the object
    public String soqlAllFields() {
        String theSOQL;
        QueryUtilityWrapper myQuWrap = beginDynamicQuery(objectToSOQL);

        if(myQuWrap.ErrorMessage == null) { 
            theSOQL = myQuWrap.QueryString;

            if (whereClause != null) {
                theSOQL += ' WHERE ' + whereClause;
            }

            if (orderBy != null) {
                theSOQL += ' ORDER BY ' + orderBy;
            }
        
            if (limitRecords != null) {
                theSOQL += ' LIMIT ' + limitRecords;
            }

            if (offsetRows != null) {
                theSOQL += ' OFFSET ' + limitRecords;
            }
        }
        System.debug('UTILITY QueryUtility soqlAllFields value: ' + theSOQL);

        return theSOQL;
    }

}
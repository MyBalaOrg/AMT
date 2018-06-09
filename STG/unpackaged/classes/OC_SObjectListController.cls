/**
* ********************************************************************************************************************************************************************************************************************************************
*	@Name			OC_SobjectListController
*	@Author			Nathan Shinn, Deloitte Digital
*	@Created Date	31st Jan 2017
*	@Used By		OC_SObjectList.cmp
*					OC_ExportListToCsv.cmp
*	*******************************************************************************************************************************************************************************************************************************************
*	@Description	This controller builds the Employee record and fetches data required by the component to be displayed.
*	*******************************************************************************************************************************************************************************************************************************************
*	@Changes
*	03-06-2017  Modified to support Alternate use
*	03-21-2017	Consolidated field list retrieval into a single method.
*	******************************************************************************************************************************************************************************************************************************************* 
**/

public with sharing class OC_SObjectListController {
	/**
     * Custom Exception class
     */
    private class sexception extends exception {}
    
    /**
     * Inner Class used to abstract the results
     * Contains the records, the api names and the field labels
     */
    public class sObjectWrapper 
    {
        @AuraEnabled
        public List<String> lstFieldApi { get;set; }
        
        @AuraEnabled
        public List<String> lstFieldLabel { get;set; }
        
        @AuraEnabled
        public List<SObject> lstSobject { get;set; }
        
        //constructor
        public sObjectWrapper(List<String> lstFieldApi, List<String> lstFieldLabel, List<SObject> lstSobject)
        {
            this.lstFieldApi = lstFieldApi;
            this.lstFieldLabel = lstFieldLabel;
            this.lstSobject = lstSobject;
        }
    }
    
    /**
     * Used to determine whether or ot a field is accessible to the running user
     */
    public static Boolean getFieldAccessibility(String strQuery) 
    { 
        String [] lstFieldsToCheck = new String []{};
        Map<String,Schema.SObjectField> mapFields;
        String strObject = '';
        if(strQuery.contains('WHERE'))
            strObject = strQuery.substringBetween('FROM','WHERE').trim();
        else
            strObject = strQuery.split('FROM')[1].trim();
        SObjectType objSObjectType = Schema.getGlobalDescribe().get(strObject);
        
        //Check accessisibility for sobject object
        if(objSObjectType.getDescribe().isAccessible())
          mapFields = objSObjectType.getDescribe().fields.getMap();
        else
          return false;
        
        lstFieldsToCheck = getQueryFieldList(strQuery);
        
        //Check accessisibility for fields 
        for (String strField : lstFieldsToCheck) 
        {
              if (mapFields.containsKey(strField) && !mapFields.get(strField).getDescribe().isAccessible()) 
              {
                return false;
              }
        }
        
        return true;        
    } 
    
    /**
     * Used to query and return a list of Records and their descriptors dynamically
     */
    @AuraEnabled
    public static sObjectWrapper fetchRecords(String strQuery)
    {
        List<String> lstFieldAPIs = new List<String>();
        List<String> lstFields = new List<String>();
        List<SObject> lstSobject = new List<SObject>();
        
        String queryString = '';
        //exception for inaccessible fields
        if(!getFieldAccessibility(strQuery))
        {
            sexception e = new sexception();
            e.setMessage('You do not have access to o. Please contact to your administrator.');
            throw e;
        }
            
        //query for the list of SObjects
        lstSobject = database.query(strQuery);
          
        //grab the field list from the supplied query string
        String strFields = strQuery.substringBetween('SELECT','FROM');
        
        //describe the object's fields via accessing the first record's Id
        Map<String, Schema.SObjectField> mfields = lstSobject[0].Id.getSObjectType().getDescribe().fields.getMap();
        
        //pull the descriptions of the fields using the field names supplied in the query
        for(String strField : strFields.split(','))
        {
            lstFieldAPIs.add(strField.trim());
            if(strField.contains('.'))
            {
                list<String> fieldParts = strField.split('.'); 
                lstFields.add(strField);
            }
            else
            	lstFields.add(String.valueOf(mfields.get(strField.trim()).getDescribe().getlabel()));
        }
        
        //return the generic wrapper containing the records, the api names and the field labels
        return new sObjectWrapper(lstFieldAPIs, lstFields, lstSobject);
    }
    
    static list<String> getQueryFieldList(String strQuery)
    {
        list<String> fieldList = new list<String>();
        
        String strFields = strQuery.substringBetween('SELECT','FROM');
                                        
        for(String strField : strFields.split(','))
        {
            fieldList.add(strField.trim());
        }
        
        return fieldList;
    }
}
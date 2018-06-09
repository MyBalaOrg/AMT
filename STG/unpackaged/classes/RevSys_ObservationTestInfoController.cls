/**
*___________________________________________________
*@Name: RevSys_ObservationTestInfoController
*@Author: Boom Bertewtti
*@Created: Date: 1/05/2018
*@Used_By: RevSys_Obs_TestInfoCmp.cmp
*___________________________________________________
*@Description: 
* Handles Lookup search 
*___________________________________________________
*@Changes: 
* 
**/
public with sharing class RevSys_ObservationTestInfoController {

    @AuraEnabled
    public static Map<String, String> getItemsForTypeaheadSearch(String searchKey, String objectName, List<String> fieldsToSearchList) {
        Map<String, String> response = new Map<String, String>();
        
        List<StaticUtils.SearchItem> listItems = new List<StaticUtils.SearchItem>();
        String selectQuery = '', whereQuery = '';

        for (String field : fieldsToSearchList) {
            selectQuery += ', ' + field;
            whereQuery += ' OR ' + field + ' LIKE \'%' + String.escapeSingleQuotes(searchKey) + '%\'';
        }
        
        String query = 'SELECT Id' + selectQuery; 
        query += ' FROM ' + String.escapeSingleQuotes(objectName) + ' WHERE (' + whereQuery.removeStartIgnoreCase(' OR') + ')';

        query += ' ORDER BY ' + fieldsToSearchList[0] + ' ASC LIMIT ' + Limits.getLimitDmlRows();
        
        List<sObject> searchResult = Database.query(query);
        
        for (Integer i = 0; i < searchResult.size(); i++) {
            StaticUtils.SearchItem item = new StaticUtils.SearchItem();
            item.recordId = String.valueOf(searchResult[i].get('Id'));
            item.label = String.valueOf(searchResult[i].get(fieldsToSearchList[0]));
            for (String field : fieldsToSearchList) {
                if (!field.contains('__r')) {
                    item.searchValue += String.valueOf(searchResult[i].get(field)) + ' ';
                }
            }
            listItems.add(item);
        }
        response.put('listItems', JSON.serialize(listItems));
        return response;
    }    
    
}
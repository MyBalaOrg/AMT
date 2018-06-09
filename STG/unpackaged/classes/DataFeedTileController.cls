/**
*___________________________________________________
*@Name: DataFeedTileController
*@Author: Alex Chang
*@Created: Date: 12/05/2017
*@Used_By: CEO Portal
*___________________________________________________
*@Description: Controller for CEO Portal methods. 
*___________________________________________________
**/

public with sharing class DataFeedTileController {

    /**
    *————————————————————————————————————————————————————
    * @Name: Alex Chang
    * @Description
    * Return records to generic tile based on
    *————————————————————————————————————————————————————
    * @param - Properties passed from lightning controller
    * 		  Properties index values
    *            0 - First Object
    *            1 - Record Type
    *            2 - First Field
    *            3 - Secondary Field on First Object
    *            4 - Secondary Object
    *            5 - Secondary Object Relationship field to Primary Object
    *            6 - Secondary Object Field
    *            7 - Number of rows to pull
    *            8 - URL Field
    *            9 - Order by Direction
    *           10 - Order By Field
    *           11 - Filter By Field
    *           12 - Filter By Criteria
    *           13 - Thumbnail
    * @return - Map with Header as key, Values are a List that contains Description and URL for header links
    *————————————————————————————————————————————————————
    **/ 
    @AuraEnabled
    public static Map<String,List<String>> retrieveLists (List<String> properties, Boolean viewPrivate){

        Map<Id,String> listDescriptions = new Map<Id,String>();
        Map<String, List<String>> returnMap = new Map<String,List<String>>();
        Boolean containsWhere = false;

        String primaryQuery = 'SELECT Id, ' + properties[2] ;

        // Check for second field on single object
        if(properties[3] != ''){
        	primaryQuery += ', ' + properties[3];
        }

        // Check for Hyperlink URL, add url to query string
        if(properties[8] != ''){
            primaryQuery += ', '+ properties[8];
        }

        // Check for Thumbnail
        if(properties[13] != ''){
            primaryQuery += ', '+ properties[13];
        }

        // Check for Case
        if(properties[0] == 'Case'){
        	primaryQuery += ', Subject ';
        }

        // Check for Portal Content
        if(properties[0] =='Portal_Content__c'){
            primaryQuery += ', Published_Date__c ';
        }

        // If secondary object exists, add inner soql
        if(properties[4] != ''){
        	primaryQuery += ', (SELECT ' + properties[6] + ',' + properties[5] + ' FROM ' + properties[4] ;

	        if(properties[4] == 'CaseComments' && !viewPrivate){
	        	primaryQuery += ' WHERE IsPublished = True ';
	        }
	        primaryQuery += ' ORDER BY LastModifiedDate DESC';
            primaryQuery += ' LIMIT 1) ';

        }

        primaryQuery += ' FROM ' + properties[0];	

         // Check for Filter Field, add Filter Criteria to String
        if(properties[11] != ''){
            primaryQuery += ' WHERE ' + properties[11] + '=' + '\'' + properties[12] + '\''; 
            containsWhere = true;
        }

        //Retrieve RecordTypeId, if no record type found, throw exception
        String recordTypeString = 'SELECT Id FROM RecordType WHERE Name=\'' + properties[1] + '\'';
        List<sObject> rtList = Database.query(recordTypeString);
        if(rtList.size()>0){
        	if(containsWhere){
    			primaryQuery += ' AND ';
    		}else{
    			primaryQuery += ' WHERE ';
    		}   
        	primaryQuery += ' RecordTypeId = \'' + rtList[0].Id + '\'' ;
   		}else{
   			return null;
   		}
   		primaryQuery += ' ORDER BY ' + properties[9] + ' ' + properties[10];

        if(properties[4] == ''){
            primaryQuery += ' LIMIT ' + properties[7];
        }
        
        System.debug('primaryQuery: ' + primaryQuery);
        
   		//Iterate through list of primaryObjects
        List<SObject> primaryObjects = Database.query(primaryQuery);
        for(Integer i = 0; i<primaryObjects.size(); i++){  
        	// If a single object, populate map without .getSobjects, else check for existence of child Sobjects and check returnMap size 
            // because all parent records may not have child records and only want to display records with children
            List<String> params = new List<String>();
        	if(properties[4] == ''){
                if(properties[3] == ''){
                    params.add('');
                    buildParams(properties, params, i, primaryObjects);  
                }else{
                    params.add((String)primaryObjects.get(i).get(properties[3]));
                    buildParams(properties, params, i, primaryObjects);         
                }   		
                returnMap.put((String)primaryObjects.get(i).get(properties[2]), params);

    		}else if(primaryObjects.get(i).getSobjects(properties[4]) != null && returnMap.size()<Integer.valueOf(properties[7])){     		
                Sobject[] secondary = primaryObjects.get(i).getSobjects(properties[4]);
            	params.add((String)secondary.get(0).get(properties[6]));
                buildParams(properties, params, i, primaryObjects);
            	returnMap.put((String)primaryObjects.get(i).get(properties[2]), params);
    		}
		}

        try{
            return returnMap;
        }catch (Exception e){
            system.debug('ERROR '+ e.getMessage());
            return null;
        }
        
    }  

    /**
    *————————————————————————————————————————————————————
    * @Name: Alex Chang
    * @Description
    * Add parameters to List for returnMap
    *————————————————————————————————————————————————————
    * @param - Properties passed from retrieveLists method
    *             properties List - String
    *             params List - String
    *             index - Integer
    *             primaryObjects - List - SObject
    * @return - List of parameters that are mapped based on index
    *————————————————————————————————————————————————————
    **/ 

    private static List<String> buildParams (List<String> properties, List<String> params, Integer index, List<SObject> primaryObjects){

        System.debug(properties[8]);
  
        //URL Field
        if(properties[8] != '' ){
            params.add((String)primaryObjects.get(index).get(properties[8]));
        }else{
            if(properties[0] == 'Portal_Content__c'){
                params.add('/ceocorner/s/fullarticledetail?id=' + (String)primaryObjects.get(index).get('Id'));
            }else{
                params.add('');
            }
        }
        
        //Primary object
        if(properties[0] == 'Case'){
            params.add((String)primaryObjects.get(index).get('Subject'));
        }else{
            params.add('More Info');
        }

        //Thumbnail field
        if(properties[13] != ''){
            if(primaryObjects.get(index).get(properties[13]) != null){
                params.add((String)primaryObjects.get(index).get(properties[13]));
            }else{
                params.add('noThumbnail');
            }
        }else{
            params.add('noThumbnail');
        }

        // Code for adding Date Time before Secondary row
        if(properties[0] == 'Portal_Content__c' && String.valueOf(primaryObjects.get(index).get('Published_Date__c')) != null){
            String str = String.valueOf(primaryObjects.get(index).get('Published_Date__c'));
            String substr = str.substring(0,10);
            substr += ' - ';
            params.add(substr);
        }else{
            params.add('');
        }

        return params;
    }
    
}
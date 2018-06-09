/**
* ********************************************************************************************************************************************************************************************************************************************
*   @Name           OC_SobjectListController
*   @Author         Nathan Shinn, Deloitte Digital
*   @Created Date   31st Jan 2017
*   @Used By        OC_SObjectSearch.cmp
*   *******************************************************************************************************************************************************************************************************************************************
*   @Description    This controller builds supports the SobjectSearch components and retrieves data from via SOQL.
*   *******************************************************************************************************************************************************************************************************************************************
*   @Changes
*   03-06-2017  Modified to support Position Specific functionality
*   ******************************************************************************************************************************************************************************************************************************************* 
**/

public class OC_SObjectSearchController {
        /**
     * Aura enabled method to search a specified SObject for a specific string
     */
    private class sexception extends exception {}
    @AuraEnabled
    public static Result[] lookup(String searchString, String sObjectAPIName, list<String> fieldList)
    {
        // Sanitze the input
        String sanitizedSearchString = String.escapeSingleQuotes(searchString);
        String sanitizedSObjectAPIName = String.escapeSingleQuotes(sObjectAPIName);
        if(fieldList == null || fieldList.size() == 0)
            return new list<Result>{new Result('','ERROR - FIELD LIST NOT SPECIFIED')};
                
        List<Result> results = new List<Result>();
        String fields = String.join(fieldList,',');
        integer ctr = 0;
        string whereClause = ' WHERE ';
        for(String strField : fieldList)
        {
            if(ctr > 0)
                whereClause += ' OR ';
                
                whereClause += strField +' LIKE \'%'+sanitizedSearchString+'%\' ';
        }
        whereClause = '';
        // Build our SOSL query
        String searchQuery = 'FIND \'' + sanitizedSearchString + '*\' IN ALL FIELDS RETURNING ' 
                                       + sanitizedSObjectAPIName 
                                       + '('+ fields
                                       + whereClause
                                       +') Limit 50'; 
 
        // Execute the Query
        
        List<List<SObject>> searchList = search.query(searchQuery);
        if(searchList.size() == 0 || searchList[0].size() == 0)
            return results;
        
        Map<String, Schema.SObjectField> mfields = searchList[0][0].Id.getSObjectType().getDescribe().fields.getMap();
        
        
        // Create a list of matches to return
        for (SObject so : searchList[0])
        {
            string resultString = '';
            Integer cnt = 0;
            for(String strField : fieldList)
            {
                if(strField.equalsIgnoreCase('Id'))
                    continue;
                
                if(cnt > 0)
                    resultString += ', ';
                
                resultString += String.valueOf('<b>'+mfields.get(strField.trim()).getDescribe().getlabel())+'</b>: '
                             + String.ValueOf(so.get(strField.trim())) ;
                cnt ++;
            }
            results.add(new Result(resultString, so.Id));
            
        }
         
        return results;
    }
    /**
     * Employee and Position related search
     */
    @AuraEnabled
    public static Result[] lookupEmployeePosition(String searchString)
    {
        //create a set of Ids for the COntact and Position Objects
        set<Id> positionIds = new set<Id>();
        set<String> contactIds = new set<String>();
        
        //prepare result sets for contacts aw well as positions
        list<Result> contacts = lookup(searchString, 'Contact', 'Id,PositionLookup__c'.split(','));
        list<Result> positions = lookup(searchString , 'Position__c', 'Id,Name'.split(','));
        list<Result> results = new list<Result>();
        
       
        
        //Get Active and Terminated Statuses
        List<String> activeStatusesList = new List<String>();
         String activeStatuses = Label.OC_Active_Status;
         activeStatusesList = activeStatuses.split('\\,');
         
         
        List<String> terminatedStatusesList = new List<String>();	
         String terminatedStatuses = Label.OC_Terminated_Status;
         terminatedStatusesList = terminatedStatuses .split('\\,');
       
       
        //iterate through the contacts retrieving the Position Ids
        for(Result r : contacts)
        {

            string posId = r.SObjectLabel.split(':')[1].trim();
            string contactId = r.SobjectId;
            
            if(posId != null && posId != 'null'){
                positionIds.add(posId);
               
            }
            
            if(contactId!=null){
                contactIds.add(contactId);
            }
        }
        
         system.debug('Contactsids '+contactIds);
        //Iterate through the positions returned by the SOSL query and retrieve the position Ids
        for(Result r : positions)
        {
            if(r.SObjectId != null)
                positionIds.add(r.SObjectId);
        }
        system.debug('Contactsids '+contactIds);
        system.debug('positionIds '+positionIds);
        //retrieve the fields used in the search for filtering and display
        map<String, set<OC_Component_FieldList__c>> componentFeldList = new map<String, set<OC_Component_FieldList__c>>();
        
        for(OC_Component_FieldList__c cf : [select DisplayLabel__c
                                              , DisplaySequence__c 
                                              , SobjectField__c     
                                              , SobjectName__c 
                                            from OC_Component_FieldList__c 
                                           where ApplicationContext__c = 'OrgChartEmployeeSearch'
                                          order by DisplaySequence__c asc])
        {
            if(componentFeldList.containsKey(cf.SobjectName__c))
            {
                set<OC_Component_FieldList__c> l = componentFeldList.get(cf.SobjectName__c);
                l.add(cf);
            }
            else
            {
                componentFeldList.put(cf.SobjectName__c,new set<OC_Component_FieldList__c>{cf});   
            }
        }
        
        //construct the query based on configured fields from the custom setting
        string soql = 'SELECT Id ';
        //Position Fields
        set<String> positionFields = new set<String>();
        for(OC_Component_FieldList__c cl : componentFeldList.get('Position__c'))
        {
            soql += ','+cl.SobjectField__c;
            positionFields.add(cl.SobjectField__c);
        }
        
        //generate the Contact subquery
        soql += ',(SELECT Id ';
        set<String> contactFields = new set<String>();
        for(OC_Component_FieldList__c cl : componentFeldList.get('Contact'))
        {
            soql += ','+cl.SobjectField__c;
            contactFields.add(cl.SobjectField__c);
        }
        
       
        
        
        //if the search includes the "Name" field, also include FirstName, LastName, MiddleName and Suffix if they don't exist
        if(contactFields.contains('Name'))
        {
               if(!contactFields.contains('FirstName')) 
                   soql += ',FirstName';
               if(!contactFields.contains('LastName')) 
                   soql += ',LastName';
               if(!contactFields.contains('MiddleName')) 
                   soql += ',MiddleName';
               if(!contactFields.contains('Suffix')) 
                   soql += ',Suffix';
                   
        }
         
         
         
        //Contact Fields
        soql += ' FROM Contacts__r WHERE Employment_Status__c IN :activeStatusesList ) '+
                'FROM Position__c '+
                'WHERE Id IN :positionIds AND Employment_Status__c NOT IN :terminatedStatusesList  ';
        
        
        //Use the position Ids returned from the SOSL to query for positions and contacts driven from the position
        for(Position__c p : (list<Position__c>)database.query(soql))
        {
            //construct the return string and Id pairs to return as search results
            string label = '';
            //if there are contacts, use the contact data to populate the name field
            if(p.Contacts__r.size() > 0)
            {
                for(Contact c : p.Contacts__r)
                {
                    //manage the filter dynamicaly
                    //if(isFieldValueMatch(String Sobject, String searchString, map<String, list<Component_FieldList__c>> componentFeldList, SObject sobj))
                    if(isFieldValueMatch('Contact', searchString, contactFields, c)
                      ||isFieldValueMatch('Position__c', searchString, positionFields, p))
                    {
                        //label = 'Name: ' + c.Name + ', Org Unit: ' + p.Organization_Unit_Name__c + ', Title: ' + p.Position_Title__c;
                        results.add(generateResult(componentFeldList,'Contact',c,p));
                    }
                    
                    
                }
            }
            else if(isFieldValueMatch('Position__c', searchString, positionFields, p))
            {
                
                //if no contact exists, populate the hard-coded, "Vacant Position" value.
                //label = 'Name: Vacant Position,  Org Unit: '+p.Organization_Unit_Name__c+ ',  Title: '+ p.Position_Title__c;
                results.add(generateResult(componentFeldList,'Position__c',null,p));
                system.debug('Position only result debug: ' + results.size());
            }
            
        }
        
        
        //return the results
        return results;
        
        
    }
    
    /**
     * Function for determining if there is a match based on a string value, Sobject and Configured Filter
     */
    static Boolean isFieldValueMatch(String SobjectName, String searchString
                                   , set<String> fieldsToCheck, SObject sobj)
    {
        boolean match = false;
        
        if(SobjectName == 'Contact')
        {
            Contact c = (Contact)sobj;
            for(String s : fieldsToCheck)
            {
                if(s == 'Name')//special case for Contact Name since its a combination of first, last, middle and suffix
                {
                     if(c.Name.replace(' ','').containsIgnoreCase(searchString.replace(' ',''))
                        ||(c.FirstName + c.LastName).containsIgnoreCase(searchString.replace(' ',''))
                        ||(c.LastName + c.FirstName).containsIgnoreCase(searchString.replace(' ','')))
                     {
                         match = true;
                     }
                }
                 //Jialin Ding CR-CH527088 add null checker - 2017/06/01
                else if(String.valueOf(c.get(s))!=null && String.valueOf(c.get(s)).replace(' ','').containsIgnoreCase(searchString.replace(' ','')))
                {
                        match = true;
                }
            }
        }
        else
        {
            Position__c p = (Position__c)sobj;
            for(String s : fieldsToCheck)
            {   
                 //Jialin Ding CR-CH527088 add null checker - 2017/06/01
                if(String.valueOf(p.get(s))!=null && String.valueOf(p.get(s)).replace(' ','').containsIgnoreCase(searchString.replace(' ','')))
                        match = true;
            }
        }
        
        return match;
    }
      
    /*
     * Used to generate the search results label
     */
    public static Result generateResult(map<String, set<OC_Component_FieldList__c>> componentFeldList
                                       ,String SObjectName
                                       ,Contact con
                                       ,Position__c pos)
    {
        string resultString = '';
        Integer cnt = 0;
        //Contact Fields
        for(OC_Component_FieldList__c field : componentFeldList.get('Contact'))
        {
            
                if(cnt > 0)
                    resultString += ', ';
                if(con == null)//no contact. Need the "Vacant Position Rule"
                {
                   for(OC_Component_FieldList__c cfield : componentFeldList.get('Contact')) 
                   {
                       if(cfield.SobjectField__c == 'Name'){
                            resultString += '<b>'+cfield.DisplayLabel__c+'</b>: Vacant Position ';
                           cnt ++;
                       }
                        
                   }
                    
                   break;
                            
                }
                else{
                    resultString += '<b>'+field.DisplayLabel__c+'</b>: '
                                  + String.ValueOf(con.get(field.SobjectField__c.trim())) ;
                    
                }
                
                cnt ++;
        }
        //Position Fields
        for(OC_Component_FieldList__c field : componentFeldList.get('Position__c'))
        {
                if(cnt > 0)
                    resultString += ', ';
                
                resultString += '<b>'+field.DisplayLabel__c+'</b>: '
                              + String.ValueOf(pos.get(field.SobjectField__c.trim())) ;
                cnt ++;
         }
        
        system.debug('resultstring '+resultString);
        //Sarang 6-12-2017: Modified to send the contact id if the entity is not Vacant else send the pos id
        if(con!=null) return new Result(resultString, con.Id); 
        else return new Result(resultString, pos.Id);                   
    }
    
    /**
     * Inner class to wrap up an SObject Label and its Id
     */
    public class Result
    {
        @AuraEnabled public String SObjectLabel {get; set;}
        @AuraEnabled public Id SObjectId {get; set;}
         
        public Result(String sObjectLabel, Id sObjectId)
        {
            this.SObjectLabel = sObjectLabel;
            this.SObjectId = sObjectId;
        }
    }
    
    

}
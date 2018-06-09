global with sharing class EIS_contactTriggerHelper {
    
    public static void updatePositionContact(List<SObject> newList,List<SObject> oldList,Map<Id,SObject> newMap,Map<Id,SObject> oldMap){
        
        system.debug('Inside :- updatePositionContact');
        set<Id> positionIds = new set<Id>();
        for(Contact con: (List<Contact>) newList){
            if(con.PositionLookup__C !=null || con.PositionLookup__c !=''){
                positionIds.add(con.PositionLookup__c);
            }
        }
        
        if(oldList != null && oldList.size() > 0) {
            for(Contact con: (List<Contact>)oldList){
                if(con.PositionLookup__C !=null || con.PositionLookup__c !=''){
                    positionIds.add(con.PositionLookup__c);
                }
            } 
        }
        
        
        system.debug('Inside :- positionIds: ' + positionIds);
        
        list<Position__c> listOfPosition = [select id,primary_contact__C,name,
                                            (select id,name,lastName,firstName from Contacts__r
                                             order by LastModifiedDate desc
                                             limit 1)
                                            from position__c
                                            where id in :positionIds                                         
                                           ];
        
        system.debug('Inside :- listOfPosition: ' + listOfPosition);
        
        map<Id,Position__c> mapOfPosition = new map<Id,Position__c>(listOfPosition);
        list<Position__c> listOfNewPosition = new list<Position__c> ();
        if(listOfPosition.size()>0){
                for(position__C posRecord : listOfPosition){
                if(posRecord.Contacts__r != null && posRecord.Contacts__r.size() > 0){
                listOfNewPosition.add(new Position__c(id= posRecord.id,primary_contact__c = posRecord.Contacts__r[0].name));
                    }
                    else{
                       listOfNewPosition.add(new Position__c(id= posRecord.id,primary_contact__c = '')); 
                    }
            }
        }
        
        system.debug('Inside :- listOfNewPosition: ' + listOfNewPosition);
        
        update listOfNewPosition;
    }
}
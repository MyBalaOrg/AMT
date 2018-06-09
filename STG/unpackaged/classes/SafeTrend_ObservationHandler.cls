/**
*___________________________________________________
*@Name: SafeTrend_ObservationHandler
*@Author: Gani Amsath
*@Created: Date: 7/20/2017
*@Used_By: SafeTrends App
*___________________________________________________
*@Description: This class has the methods to share the Observation and Findings records to the process specific Public groups and observers.
*This class will be invoked from the ObservationHandler class which is invoked from the Observation trigger.
*
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/

public class SafeTrend_ObservationHandler {
    
    //Method to provide sharing access to process specific public groups and observer
    public static void shareObservationAfterInsert(List<Observation__c> newObservationList){        
        
        //Method variables declaration
        Set<Id> processIdSet = new Set<Id>();
        List<String> groupList = new List<String>();
        Map<String,Group> nameToGroup = new Map<String,Group>();
        Map<String,String> idToProcessName = new Map<String,String>();
        Map<String,String> obIdToObserverUserId = new Map<String,String>();
        List<Observation__Share> observationShareInsertList = new List<Observation__Share>();
        
        try{
            //Get the unique set of process Ids            
            for(Observation__c ob:newObservationList) {
                if(ob.Process__c!=null){
                    processIdSet.add(ob.Process__c);
                }                
            }
            
            //Loop through the process records to add them to a list containing the group names 
            for(Process__c pr : [Select Id, Name from Process__c where Id IN:processIdSet]){
                groupList.add(pr.Name+' '+System.Label.Safe_Trend_Data_Entry_Role);
                groupList.add(pr.Name+' '+System.Label.Safe_Trend_Facilitator_Role);
                idToProcessName.put(pr.Id, pr.Name);		   			   	
            }
            
            //Loop through group records to populate the group name and group map
            for(Group gr : [Select Name, Id from Group where Name IN:groupList]){			
                nameToGroup.put(gr.Name, gr);
            }                     
            
            //Loop through Observation and related records to populate the observation id and user id map for active users
            for(Observation__c ob : [Select Id, Observer_ID_Process_Team__r.User__c, Observer_ID_Process_Team__r.User__r.IsActive, Observer_ID_Process_Team__c From Observation__c where Id IN:newObservationList]){
                if(ob.Observer_ID_Process_Team__r.User__r.IsActive == TRUE){
                    obIdToObserverUserId.put(ob.Id, ob.Observer_ID_Process_Team__r.User__c);
                }
            }
            
            //Loop through observation list and populate the observation_share records
            for(Observation__c ob:newObservationList) {                
                if(ob.Process__c!=null){
                    String processName = idToProcessName.get(ob.Process__c);   
                    
                    //Create an observation_share instance for Data Entry Group                    
                    if(nameToGroup.get(processName+' '+System.Label.Safe_Trend_Data_Entry_Role) !=null){
                        Observation__Share osDataEntryGroup = addObservationSharing(ob.Id, nameToGroup.get(processName+' '+System.Label.Safe_Trend_Data_Entry_Role).Id, 'Read');                          
                        observationShareInsertList.add(osDataEntryGroup);                        
                    }
                    
                    //Create an observation_share instance for Facilitator Group   
                    if(nameToGroup.get(processName+' '+System.Label.Safe_Trend_Facilitator_Role) !=null){
                        Observation__Share osFacilitatorGroup = addObservationSharing(ob.Id, nameToGroup.get(processName+' '+System.Label.Safe_Trend_Facilitator_Role).Id, 'Edit');                          
                        observationShareInsertList.add(osFacilitatorGroup);  
                    }                      
                }
                
                //Create an observation_share instance for Observer if the observer is not the creator and observer is a valid user
                if(obIdToObserverUserId.get(ob.Id) !=null && obIdToObserverUserId.get(ob.Id) !=ob.OwnerId){
                    Observation__Share osObserverUser = addObservationSharing(ob.Id, obIdToObserverUserId.get(ob.Id), 'Read');                          			
                    observationShareInsertList.add(osObserverUser);  
                }                  
            }            
            
            //Perform database insert if list not empty
            if(!observationShareInsertList.isEmpty()){   
                insert observationShareInsertList;
            }
            
        } catch(Exception e) {
            system.debug('ERROR '+e.getMessage());
        }        
    }
    
    //Method to update - add and remove sharing access when observer values are modified
    public static void shareObservationAfterUpdate(List<Observation__c> newObservationList){
        
        //Method variables declaration
        Map<String,String> obIdToObserverUserId = new Map<String,String>();
        List<Observation__Share> observationShareInsertList = new List<Observation__Share>();
        List<Observation__Share> observationShareKeyValuesDeleteList = new List<Observation__Share>();
        List<Observation__Share> observationShareDeleteList = new List<Observation__Share>();
        Set<Id> processIdSet = new Set<Id>();
        Map<String,String> processTeamIdToUserId = new Map<String,String>();
        List<String> oldObservationList = new List<String>();
        String findingRecordTypeId = Schema.SObjectType.Finding__c.getRecordTypeInfosByName().get(System.Label.ST_FindingRecordTypeName).getRecordTypeId();
        List<Finding__Share> findingShareInsertList = new List<Finding__Share>();
        List<Finding__Share> findingShareKeyValuesDeleteList = new List<Finding__Share>();
        List<Finding__Share> findingShareDeleteList = new List<Finding__Share>();
        List<String> oldFindingList = new List<String>();        
        
        try{           
            //Loop through Observation list to populate the observation id,user id map and unique process ids
            for(Observation__c ob : [Select Id, Observer_ID_Process_Team__r.User__c, Observer_ID_Process_Team__r.User__r.IsActive, Process__c, Observer_ID_Process_Team__c From Observation__c where Id IN:newObservationList]){
                if(ob.Observer_ID_Process_Team__r.User__r.IsActive == TRUE){
                    obIdToObserverUserId.put(ob.Id, ob.Observer_ID_Process_Team__r.User__c);
                }
                if(ob.Process__c!=null){
                    processIdSet.add(ob.Process__c);
                }  
            }
            
            //Query process teams to populate the process team id and user id map
            for(Process_Team__c pt : [Select Id, User__c From Process_Team__c where Process__c IN:processIdSet AND User__r.IsActive = TRUE]){
                processTeamIdToUserId.put(pt.Id, pt.User__c);
            }           
            
            //Loop through the Observation list and its related child Findings to add and remove records to the Observation_Share collection           
            for(Observation__c ob: [Select Id,Observer_ID_Process_Team__c,OwnerId,  (Select Id, OwnerId, Observation__c From Findings__r where RecordTypeId =:findingRecordTypeId) From Observation__c where Id IN:newObservationList]) {
                
                //Get old Observation value for comparison
                
                Observation__c oldObj = (Observation__c)Trigger.oldMap.get(ob.Id);
                
                //Check if Observer is changed                
                if(ob.Observer_ID_Process_Team__c != oldObj.Observer_ID_Process_Team__c){
                    //If Observer has a User assigned                   
                    if(obIdToObserverUserId.get(ob.Id) !=null){
                        
                        //Add the new observer to Observation sharing  
                        if(obIdToObserverUserId.get(ob.Id) !=ob.OwnerId){
                            Observation__Share osObserverUser = addObservationSharing(ob.Id, obIdToObserverUserId.get(ob.Id), 'Read');
                            observationShareInsertList.add(osObserverUser);                       
                        }
                        
                        //Loop through the related child Findings to add sharing
                        for(Finding__c fi : ob.Findings__r){
                            if(obIdToObserverUserId.get(ob.Id) !=fi.OwnerId){
                                Finding__Share fiShareObserverUser = new Finding__Share();
                                fiShareObserverUser.ParentId = fi.Id;
                                fiShareObserverUser.UserOrGroupId = obIdToObserverUserId.get(ob.Id);
                                fiShareObserverUser.AccessLevel = 'Read';
                                fiShareObserverUser.RowCause = Schema.Finding__Share.RowCause.Apex__c;		
                                findingShareInsertList.add(fiShareObserverUser);                        
                            }
                        }                        
                    }
                    
                    
                    //Logic to identify the Users to be removed from observer record sharing
                    //Check if the old Observer_Process Team has a valid user and not the owner
                    if(oldObj.Observer_ID_Process_Team__c !=null && processTeamIdToUserId.get(oldObj.Observer_ID_Process_Team__c) !=null && processTeamIdToUserId.get(oldObj.Observer_ID_Process_Team__c) !=ob.OwnerId){                        
                        Observation__Share osOldObserverUser = new Observation__Share();
                        osOldObserverUser.ParentId = ob.Id;
                        osOldObserverUser.UserOrGroupId = processTeamIdToUserId.get(oldObj.Observer_ID_Process_Team__c);                        
                        observationShareKeyValuesDeleteList.add(osOldObserverUser);  
                        oldObservationList.add(oldObj.Id);
                        
                        //Logic to identify the Users to be removed from finding record sharing
                        for(Finding__c fi : ob.Findings__r){
                            Finding__Share fiShareOldObserverUser = new Finding__Share();
                            fiShareOldObserverUser.ParentId = fi.Id;
                            fiShareOldObserverUser.UserOrGroupId = processTeamIdToUserId.get(oldObj.Observer_ID_Process_Team__c);	
                            findingShareKeyValuesDeleteList.add(fiShareOldObserverUser);  
                            oldFindingList.add(fi.Id);
                        }
                    }                    
                }  
            }            
            
            //Loop through the Observation Share records add the Share record Ids to be deleted
            for(Observation__Share  obSh : [Select Id, ParentId, UserOrGroupId From Observation__Share where ParentId IN:oldObservationList]){
                for(Observation__Share obKey : observationShareKeyValuesDeleteList){
                    if(obSh.ParentId == obKey.ParentId && obSh.UserOrGroupId == obKey.UserOrGroupId ){
                        Observation__Share obDelete = new Observation__Share(Id = obSh.Id);
                        observationShareDeleteList.add(obDelete);                        
                    }
                }                
            }
            
            //Loop through the Finding Share records add the Share Ids to be deleted
            for(Finding__Share  fiSh : [Select Id, ParentId, UserOrGroupId From Finding__Share where ParentId IN:oldFindingList]){
                for(Finding__Share fiKey : findingShareKeyValuesDeleteList){
                    if(fiSh.ParentId == fiKey.ParentId && fiSh.UserOrGroupId == fiKey.UserOrGroupId ){
                        Finding__Share fiDelete = new Finding__Share(Id = fiSh.Id);
                        findingShareDeleteList.add(fiDelete);                        
                    }
                }                
            }
            
            //Perform database insert if list not empty
            if(!observationShareInsertList.isEmpty()){
                insert observationShareInsertList;
            }
            //Perform database delete if list not empty
            if(!observationShareDeleteList.isEmpty()){
                delete observationShareDeleteList;
            }  
            //Perform database insert if list not empty
            if(!findingShareInsertList.isEmpty()){
                insert findingShareInsertList;
            }          
            //Perform database delete if list not empty
            if(!findingShareDeleteList.isEmpty()){
                delete findingShareDeleteList;
            }   
            
        } catch(Exception e) {
            system.debug('ERROR '+e.getMessage());
        }
    }    
    
    //Helper method to add users and groups to the Observation sharing sobject and return the return the record
    public static Observation__Share addObservationSharing(Id obParentId, Id userOrGroupId, String accessLevel){
        
        //Local variable declaration
        Observation__Share obShare = new Observation__Share();        
        try{
            //Create an observation_share instance based on the passed parameters            
            obShare.ParentId = obParentId;
            obShare.UserOrGroupId = userOrGroupId;
            obShare.AccessLevel = accessLevel;
            obShare.RowCause = Schema.Observation__Share.RowCause.Apex__c;
        } catch(Exception e) {
            system.debug('ERROR '+e.getMessage());
        }   
        return obShare;
    }
    
}
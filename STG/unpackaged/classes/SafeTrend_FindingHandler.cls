/**
*___________________________________________________
*@Name: SafeTrend_FindingHandler
*@Author: Gani Amsath
*@Created: Date: 7/24/2017
*@Used_By: SafeTrends App 
*___________________________________________________
*@Description: This class has the methods to share the Findings records to the process specific Public groups and observers.
*This class will be invoked from the FindingHandler class which is invoked from the Finding trigger.
*
*___________________________________________________
*@Changes:
* MM-DD-YYY. Explanation of the change.
**/
public class SafeTrend_FindingHandler {
    
    //Method to provide sharing access to process specific public groups and observer
    public static void shareFindingAfterInsert(List<Finding__c> newFindingList){
        
        //Method variables declaration
        String stFindingRecordTypeId = Schema.SObjectType.Finding__c.getRecordTypeInfosByName().get(System.Label.ST_FindingRecordTypeName).getRecordTypeId();
        List<Finding__c> findingList = new List<Finding__c>();
        Set<Id> observationIdSet = new Set<Id>();        
        Set<Id> processIdSet = new Set<Id>();        
        List<String> groupList = new List<String>();
        Map<String,Group> nameToGroup = new Map<String,Group>();
        Map<String,String> idToProcessName = new Map<String,String>();
        Map<String,String> obIdToObserverUserId = new Map<String,String>();
        List<Finding__Share> findingShareInsertList = new List<Finding__Share>();
        
        try{  
            //Loop through and get only Safe Trends specific Finding records and its related Observations
            for(Finding__c fi:newFindingList) {
                if(fi.Observation__c!=null && fi.RecordTypeId==stFindingRecordTypeId){
                    findingList.add(fi);
                    observationIdSet.add(fi.Observation__c);
                }                
            }
            
            //Execute further process only when the finding list contains Safe Trends specific Finding records
            if(!findingList.isEmpty()){
                
                //Collection of Observation data specific to findings in context
                Map<String,Observation__c> obIdToObservation = new  Map<String,Observation__c>([Select Id, Observer_ID_Process_Team__c, Process__c from Observation__c where Id IN:observationIdSet]);
                
                //Loop through observation records and get the unique process Ids
                for(Observation__c ob:obIdToObservation.values()) {
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
                for(Observation__c ob : [Select Id, Observer_ID_Process_Team__r.User__c,Observer_ID_Process_Team__r.User__r.IsActive, Observer_ID_Process_Team__c From Observation__c where Id IN:observationIdSet]){
                    if(ob.Observer_ID_Process_Team__r.User__r.IsActive == TRUE){
                        obIdToObserverUserId.put(ob.Id, ob.Observer_ID_Process_Team__r.User__c);    
                    }                      
                }
                
                //Loop through the Safe Trends finding list and populate the finding_share records
                for(Finding__c fi:findingList) {                 
                    String processId = obIdToObservation.get(fi.Observation__c).Process__c;           
                    String processName = idToProcessName.get(processId);     
                    
                    //Create a finding_share instance for Data Entry Group                     
                    if(nameToGroup.get(processName+' '+System.Label.Safe_Trend_Data_Entry_Role) !=null){                        
                        Finding__Share fiDataEntryGroup = addFindingSharing(fi.Id, nameToGroup.get(processName+' '+System.Label.Safe_Trend_Data_Entry_Role).Id, 'Read');
                        findingShareInsertList.add(fiDataEntryGroup);                        
                    }
                    
                    //Create a finding_share instance for Facilitator Group   
                    if(nameToGroup.get(processName+' '+System.Label.Safe_Trend_Facilitator_Role) !=null){                    
                        Finding__Share fiFacilitatorGroup = addFindingSharing(fi.Id, nameToGroup.get(processName+' '+System.Label.Safe_Trend_Facilitator_Role).Id, 'Edit'); 			
                        findingShareInsertList.add(fiFacilitatorGroup);  
                    }                      
                    
                    //Create a finding share instance for Observer if the observer is not the owner(creator) and the Observer is a valid user
                    if(obIdToObserverUserId.get(fi.Observation__c) !=null && obIdToObserverUserId.get(fi.Observation__c) !=fi.OwnerId){
                        Finding__Share fiObserverUser = addFindingSharing(fi.Id, obIdToObserverUserId.get(fi.Observation__c), 'Read');                        	
                        findingShareInsertList.add(fiObserverUser);  
                    }                       
                }            
                
                //Perform database insert if list not empty
                if(!findingShareInsertList.isEmpty()){               
                    insert findingShareInsertList;
                }                
            }
        } catch(Exception e) {
            system.debug('ERROR '+e.getMessage());
        }        
    }
    
    //Helper method to add users and groups to the Finding sharing sobject and return the record
    public static Finding__Share addFindingSharing(Id fiParentId, Id userOrGroupId, String accessLevel){
        
        //Local variable declaration
        Finding__Share fiShare = new Finding__Share();        
        try{
            //Create a finding instance based on the passed parameters            
            fiShare.ParentId = fiParentId;
            fiShare.UserOrGroupId = userOrGroupId;
            fiShare.AccessLevel = accessLevel;
            fiShare.RowCause = Schema.Finding__Share.RowCause.Apex__c;
        } catch(Exception e) {
            system.debug('ERROR '+e.getMessage());
        }   
        return fiShare;
    }
}
/**
*___________________________________________________
*@Name: RevSys_SupervisorManagerHelper
*@Author: Hemanth Kesapragada
*@Created: Date: 12/18/2017
*@Used_By: Review Systems
*___________________________________________________
*@Description: Get Supervisors and Managers of the Employee
*___________________________________________________
*@Changes: 
* 01-14-2018 cwalley -  Added check to ensure an email address was present before 
*                       adding to a map. Doing this to prevent exception if email 
*                       address is missing. This should not occur in a production 
*                       environment, but will cause issues during acceptanct testing. 
**/public with sharing class RevSys_SupervisorManagerHelper {
	

	/**
    *————————————————————————————————————————————————————
    * @Name: retrieveSupervisorId
    * @Description
    * get supervisor Ids from Contact Ids
    * 
    *————————————————————————————————————————————————————
    * @params   
    * @returns  Map of Id and Id      supervisorId and ContactId
    *————————————————————————————————————————————————————
    **/
	public static Map<Id,Id> retrieveSupervisorId(List<Id> contactIds) {
        System.debug('$$ RevSys_SupervisorManagerHelper-------retrieveSupervisorId------START');
		Map<Id,Id> supervisorByEmployeeMap = new Map<Id,Id>();
        Set<Id> conIds = new Set<Id>();
        Set<Id> postionHierarchyIds = new Set<Id>();
        Map<Id,Id> contactByParentHierarchy = new Map<Id,Id>();
        Map<Id,EPW_Hierarchy_Assignment__c> hrAssgmntByPosHrchy = new Map<Id,EPW_Hierarchy_Assignment__c>();
        
        if(contactIds != NULL){
            conIds.addAll(contactIds);
        }
        
		SelectorWrapper wrapper = HierarchyAssignmentSelector.getHrAssgnmentByContact(conIds);
        System.debug('10 wrapper '+wrapper);
		if(wrapper!=null) {
			for(EPW_Hierarchy_Assignment__c haObj : (List<EPW_Hierarchy_Assignment__c>) wrapper.sobjectList) {

                if(haObj.EPW_Position_Hierarchy__r.EPW_Parent_Position_Hierarchy__r.RecordTypeId == RevSys_StaticUtility.POSITION_HIERARCHY_SPARTN_RECTYPE_ID) {          // raj 02/13/2018
                    postionHierarchyIds.add(haObj.EPW_Position_Hierarchy__r.EPW_Parent_Position_Hierarchy__c);
                    contactByParentHierarchy.put(haObj.EPW_Contact__c, haObj.EPW_Position_Hierarchy__r.EPW_Parent_Position_Hierarchy__c);
                }
			}
		}
        
        if(postionHierarchyIds != null){
            SelectorWrapper myWrapper = HierarchyAssignmentSelector.getHrAssgnmentByPositionHierarchy(postionHierarchyIds);
            if(myWrapper!=null) {
                for(EPW_Hierarchy_Assignment__c tempHaObj : (List<EPW_Hierarchy_Assignment__c>) myWrapper.sobjectList){
                    hrAssgmntByPosHrchy.put(tempHaObj.EPW_Position_Hierarchy__c, tempHaObj);
                }
            }
        }
        
        if(conIds != null){
            for(Id conId : conIds){
                if(contactByParentHierarchy.containsKey(conId)){
                    if(hrAssgmntByPosHrchy.containsKey(contactByParentHierarchy.get(conId))){
                        supervisorByEmployeeMap.put(conId,hrAssgmntByPosHrchy.get(contactByParentHierarchy.get(conId)).EPW_Contact__c);
                    }
                }
            }
        }
        
        System.debug('$$ RevSys_SupervisorManagerHelper-------retrieveSupervisorId------END');
		return supervisorByEmployeeMap;
	}


	/**
    *————————————————————————————————————————————————————
    * @Name: retrieveManagerId
    * @Description
    * get Manager Ids from Contact Ids
    * 
    *————————————————————————————————————————————————————
    * @params   
    * @returns  Map of Id and Id      contactId and managerId
    *————————————————————————————————————————————————————
    **/
    public static Map<Id,Id> retrieveManagerId(List<Id> contactIds) {
    	System.debug('$$ RevSys_SupervisorManagerHelper-------retrieveManagerId------START');
    	Map<Id,Id> myPositionIdByContactIdMap = new Map<Id,Id>();
    	Map<Id,String> mySapIdByPositionId = new Map<Id,String>();
        Set<String> sapIdSet = new Set<String>();
    	Map<String,Id> myContactIdBySapId = new Map<String,Id>();
        
        Set<Id> conIds = new Set<Id>();
        Map<Id,Id> contactByParentHierarchy = new Map<Id,Id>();
        Set<Id> postionHierarchyIds = new Set<Id>();
        Map<Id,EPW_Hierarchy_Assignment__c> hrAssgmntByPosHrchy = new Map<Id,EPW_Hierarchy_Assignment__c>();

    	Map<Id,Id> myManagerIdByEmployeeIdMap = new Map<Id,Id>();
        
        if(contactIds != NULL){
            conIds.addAll(contactIds);
        }
        
        SelectorWrapper wrapper = HierarchyAssignmentSelector.getHrAssgnmentByContact(conIds);
        if(wrapper!=null) {
			for(EPW_Hierarchy_Assignment__c haObj : (List<EPW_Hierarchy_Assignment__c>) wrapper.sobjectList) {

                if(haObj.EPW_Position_Hierarchy__r.EPW_Parent_Position_Hierarchy__r.RecordTypeId == RevSys_StaticUtility.POSITION_HIERARCHY_AMTRAK_RECTYPE_ID) {          // raj 02/13/2018
                    postionHierarchyIds.add(haObj.EPW_Position_Hierarchy__r.EPW_Parent_Position_Hierarchy__c);
                    contactByParentHierarchy.put(haObj.EPW_Contact__c, haObj.EPW_Position_Hierarchy__r.EPW_Parent_Position_Hierarchy__c);
                }
			}
		}
        
        if(postionHierarchyIds != null){
            SelectorWrapper myWrapper = HierarchyAssignmentSelector.getHrAssgnmentByPositionHierarchy(postionHierarchyIds);
            if(myWrapper!=null) {
                for(EPW_Hierarchy_Assignment__c tempHaObj : (List<EPW_Hierarchy_Assignment__c>) myWrapper.sobjectList){
                    hrAssgmntByPosHrchy.put(tempHaObj.EPW_Position_Hierarchy__c, tempHaObj);
                }
            }
        }
        
        if(conIds != null){
            for(Id conId : conIds){
                if(contactByParentHierarchy.containsKey(conId)){
                    if(hrAssgmntByPosHrchy.containsKey(contactByParentHierarchy.get(conId))){
                        myManagerIdByEmployeeIdMap.put(conId,hrAssgmntByPosHrchy.get(contactByParentHierarchy.get(conId)).EPW_Contact__c);
                    }
                }
            }
        }
        
    	System.debug('$$ RevSys_SupervisorManagerHelper-------retrieveManagerId------END');
    	return myManagerIdByEmployeeIdMap;
    }
}
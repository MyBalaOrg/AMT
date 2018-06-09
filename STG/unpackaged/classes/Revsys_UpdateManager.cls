/**
*___________________________________________________
*@Name: Revsys_UpdateManager
*@Author: Sarang Padhye
*@Created: Date: March 26, 2018
*@Used_By: SPARTN
*___________________________________________________
*@Description: EPW_Hierarchy_Assignment Trigger Handler for SPARTN Systems Records 
* This class extends the Trigger Handler and invokes helper and utility classes 
* for further logic.
* Put the logic in a helper/utility class. 
*___________________________________________________
*@Changes: 
* 
**/
public class Revsys_UpdateManager {
    
      /**
    *————————————————————————————————————————————————————
    * @Name: updateManagerBeforeUpdate
    * @Description - Updates the position record upon selecting a Manager Contact record on the Hierarchy
    * 				Assignment Record.
    * 
    * @param    List<EPW_Hierarchy_Assignment__c> haList - list of Hierarchy Assignment
    *                                             records from the trigger 
    * @returns  void
    *————————————————————————————————————————————————————
    **/
    public static String updateManagerBeforeUpdate(List<EPW_Hierarchy_Assignment__c> haList){
        system.debug('BEGIN updateManagerBeforeUpdate');
        
     	ID revSysPosHierarchyRecordType = Schema.SObjectType.EPW_Position_Hierarchy__c.getRecordTypeInfosByName().get(Label.RevSys_PositionHierarchy_RT_Label).getRecordTypeId();
        Set<ID> currPosIds = new Set<ID>();
        Set<ID> targetConIds = new Set<ID>();
        Set<ID> targetPosIdSet = new Set<ID>();
        Map<ID,ID> targetConToPosMap = new Map<ID,ID>();
        List<EPW_Position_Hierarchy__c> positionsToUpdate = new List<EPW_Position_Hierarchy__c>();
        //Get the position Id and the contact Id related to the hierarchy assignment record
        for(EPW_Hierarchy_Assignment__c ha : haList) {
            EPW_Hierarchy_Assignment__c oldHa = (EPW_Hierarchy_Assignment__c)Trigger.oldMap.get(ha.Id);
            
            ID oldManagerId = oldHa.SPARTN_Manager__c;
            Id newManagerId = ha.SPARTN_Manager__c;
            
            if(ha.SPARTN_Manager__c != null && (oldManagerId != newManagerId)) {
                currPosIds.add(ha.EPW_Position_Hierarchy__c);
                targetConIds.add(ha.SPARTN_Manager__c);
            }
        }
        
        //Get Hierarchy Assignment Records for the selected Contacts
        Map<ID,EPW_Hierarchy_Assignment__c> targetHaAssignmentMap = new Map<Id,EPW_Hierarchy_Assignment__c>(
            [select EPW_Position_Hierarchy__c, EPW_Contact__c
             from EPW_Hierarchy_Assignment__c where EPW_Contact__c =: targetConIds]);
        
        system.debug('targetHaAssignmentMap '+targetHaAssignmentMap);
        
        //Get the corresponding position Ids and create map con --> pos.
        if(targetHaAssignmentMap.size() > 0) {
            for(Id key : targetHaAssignmentMap.keySet()) {
                Id posId = targetHaAssignmentMap.get(key).EPW_Position_Hierarchy__c;
                //Get only those records which have position associated with it.
                if(posId != null) {
                    targetPosIdSet.add(posId);
                    targetConToPosMap.put(targetHaAssignmentMap.get(key).EPW_Contact__c,targetHaAssignmentMap.get(key).EPW_Position_Hierarchy__c);
                }
            }            
        }
        //Get the target postion Records for only SPARTN record type
        Map<ID,EPW_Position_Hierarchy__c> targetPosHierarchyMap = new Map<Id,EPW_Position_Hierarchy__c>(
            [select EPW_Parent_Position_Hierarchy__c,recordTypeId
             from EPW_Position_Hierarchy__c where Id =: targetPosIdSet and recordtypeid =:revSysPosHierarchyRecordType]);
        
        //Get the current positon Records for only SPARTN record type
        Map<ID,EPW_Position_Hierarchy__c> currentPosHierarchyMap = new Map<Id,EPW_Position_Hierarchy__c>([select EPW_Parent_Position_Hierarchy__c,recordTypeId
                                                                                                          from EPW_Position_Hierarchy__c where Id =: currPosIds and recordtypeid =:revSysPosHierarchyRecordType]);
        Id targetPosId;
       
        Set<Id>     myContactIdSet = new Set<Id>(); 
        Set<String> myEmpNumSet    = new Set<String>(); 

        Map<Id,String> myEmpNumByContactIdMap = new Map<Id,String>(); 
        Map<Id,Id> mySuperContIdByEmployeeContIdMap = new Map<Id,Id>(); 
        Map<String,Id> myUserIdByEmpNumMap = new Map<String,Id>(); 


        for(EPW_Hierarchy_Assignment__c ha : haList) {
            myContactIdSet.add(ha.EPW_Contact__c); 

            if(ha.SPARTN_Manager__c != null) { 
                myContactIdSet.add(ha.SPARTN_Manager__c); 
            }
            myContactIdSet.add(ha.EPW_Contact__c); 
        }

        SelectorWrapper myContactRap = ContactSelector.getContacts(myContactIdSet); 

        String errMsg = myContactRap.ErrorMessage; 

        if(myContactRap.ErrorMessage == null && myContactRap.SObjectList.size() > 0) {
            for(Contact myContact :(List<Contact>)myContactRap.SObjectList) {

                if(myContact.Personnel_Number__c != null) { 
                    myEmpNumByContactIdMap.put(myContact.Id,String.valueOf(myContact.Personnel_Number__c) );

                    String myEmpNum = String.valueOf(myContact.Personnel_Number__c);
                    myEmpNumSet.add(myEmpNum); 
                    myEmpNum = myEmpNum.leftPad(8,'0');
                    myEmpNumSet.add(myEmpNum); 
                }
            }
            myContactRap = null; 
        }

        SelectorWrapper myUserRap = UserSelector.getUsersbyPersonalId(myEmpNumSet); 

        errMsg = myUserRap.ErrorMessage; 

        if(myUserRap.ErrorMessage == null && myUserRap.SObjectList.size() > 0) {
            for(User myUser :(List<User>)myUserRap.SObjectList) {
                // Now, take out the leading zeros 
                String myEmpNum = myUser.EmployeeNumber;

                myEmpNum = myEmpNum.replaceFirst('^0+','');
                myUserIdByEmpNumMap.put(myEmpNum, myUser.Id); 
            }
        }

        for(EPW_Hierarchy_Assignment__c ha : haList) {
            
            if(currentPosHierarchyMap.size() > 0) {
                if(targetPosHierarchyMap.size() > 0) {

                    system.debug('myEmpNumByContactIdMap  ' + myEmpNumByContactIdMap); 
                    system.debug('myUserIdByEmpNumMap  ' + myUserIdByEmpNumMap); 

                    String mySuperEmpNum = myEmpNumByContactIdMap.get(ha.SPARTN_Manager__c); 

                    system.debug('mySuperEmpNum  ' + mySuperEmpNum); 

                    Id mySuperUserId = myUserIdByEmpNumMap.get(mySuperEmpNum); 

                    system.debug('mySuperUserId  ' + mySuperUserId); 

                    //Get current Pos
                    EPW_Position_Hierarchy__c currentPos = currentPosHierarchyMap.get(ha.EPW_Position_Hierarchy__c);
                    if (targetConToPosMap!= null) {
                        //Get Target Position
                        targetPosId = targetConToPosMap.get(ha.SPARTN_Manager__c);
                        EPW_Position_Hierarchy__c targetPos = targetPosHierarchyMap.get(targetPosId); 




                        if(targetPos != null && (currentPos.RecordTypeId == targetPos.RecordTypeId)) {

                            if(mySuperUserId != null) {
                                ha.OwnerId = mySuperUserId;
                            }
                            else {
                                ha.OwnerId = UserInfo.getUserId(); 
                            }

                            currentPos.EPW_Parent_Position_Hierarchy__c = targetPos.Id;

                            positionsToUpdate.add(currentPos);
                        }
                        else {
                            ha.addError('No Position is Allocated to this manager. Please contact the System Administator', false);
                        }
                    }
                }
                else {
                    ha.addError('No Position is Allocated to this manager. Please contact the System Administator', false);
                }
            }
            
            else {
                system.debug('Current Manager is Blank');
                
            }
            
        }
        //update positions
        if(positionsToUpdate.size() > 0){

            system.debug('positionsToUpdate  ' + positionsToUpdate);

            //errMsg = DmlHelper.updateList(positionsToUpdate); 
        }
        
        system.debug('END updateManagerBeforeUpdate');

        return errMsg;  
    }
    

}
/**
*___________________________________________________
*@Name: Revsys_PositionHierarchyHelper2
*@Author: Hemanth Kesapragada
*@Created: Date: 3/14/2017
*@Used_By: Review Systems
*___________________________________________________
*@Description: Handles business logic around Position hierarchy object
* 
*___________________________________________________
*@Changes: 
* 04-26-2018 Added assignTargets() method
**/
public with sharing class Revsys_PositionHierarchyHelper2 {

    public static Map<Id,Id> processSupervisorPositionHierarchy(List<EPW_Position_Hierarchy__c> posHierarchyRecords) {

        system.debug('HELPER Revsys_PositionHierarchyHelperCW processSupervisorPositionHierarchy-Start');   

        String errMsg = '';
        SPARTN_Custom_Settings__c customSet = SPARTN_Custom_Settings__c.getValues('Valid Employee Department');
        List<String> deptCodesList = new List<String>();
        String deptCodeStr = String.valueOf(customSet.CsvString__c);
        Set<Id> parentPositionHierarchyList = new Set<Id>();
        Map<Id,Id> parentContactMap = new Map<Id,Id>();
        Map<Id,List<Id>> contactAndPosHierarchy = new Map<Id,List<Id>>();
        Set<Id> positionIdSetFromContact = new Set<Id>();
        Map<Id,EPW_Position_Hierarchy__c> phierarchyMap = new Map<Id,EPW_Position_Hierarchy__c>();
        Map<Id,Id> contactOtherOrgPH = new Map<Id,Id>();
        Map<Id,Id> contactSpartnPH = new Map<Id,Id>();
        Map<Id,EPW_Position_Hierarchy__c> phToBeInserted = new  Map<Id,EPW_Position_Hierarchy__c>();
        List<EPW_Hierarchy_Assignment__c> haRecordToBeInserted = new List<EPW_Hierarchy_Assignment__c>();

        if(String.isNotBlank(deptCodeStr)) {
            deptCodesList = deptCodeStr.toUpperCase().split(',');
        }

        system.debug('10 deptCodesList  ' + deptCodesList);

        //New Position Hierarchy - Am Org record type
        //It has an Id and it has ParentPosition Hierarchy field filled with an Id 
        //It has a department = "Transportation, Engineering or Mechanical." 

        if(posHierarchyRecords!=null) {
            for(EPW_Position_Hierarchy__c pos : posHierarchyRecords) {
                if(pos.RecordTypeId==RevSys_StaticUtility.POSITION_HIERARCHY_AMTRAK_RECTYPE_ID &&
                    pos.EPW_Parent_Position_Hierarchy__c!=null && 
                    String.isNotBlank(pos.EPW_Dept_Code_Description__c) && deptCodesList.contains(pos.EPW_Dept_Code_Description__c.toUpperCase())) {
                    parentPositionHierarchyList.add(pos.EPW_Parent_Position_Hierarchy__c);
                }
            }
        }

        system.debug('20 parentPositionHierarchyList  ' + parentPositionHierarchyList);

        //Query the Hierarchy Assignment where Position Hierarchy = Parent Position Hierarchy 
        SelectorWrapper wrapper = HierarchyAssignmentSelector.getHrAssgnmentByPositionHierarchy(parentPositionHierarchyList);
        if(wrapper!=null && String.isBlank(wrapper.ErrorMessage)) {
            for(EPW_Hierarchy_Assignment__c hr : (List<EPW_Hierarchy_Assignment__c>)wrapper.sObjectList) {
                //It will return you a list.. but assumption is that it will have only one record.
                //Contact record for our spervisor position record
                parentContactMap.put(hr.EPW_Position_Hierarchy__c, hr.EPW_Contact__c);
            }
        }  

        system.debug('30 parentContactMap  ' + parentContactMap);

        //we have to determine what org is associated to the Hierarchy Assignment record. 
        if(!parentContactMap.isEmpty()) {
            //get everything in a set
            Set<Id> cSet = new Set<Id>();
            for(Id cId :parentContactMap.values() ) {
                cSet.add(cId);
            }

            system.debug('31 cSet  ' + cSet);

            List<EPW_Hierarchy_Assignment__c> mylist = new List<EPW_Hierarchy_Assignment__c>
            ( 
                [SELECT Id, Name, EPW_Contact__c, EPW_Position_Hierarchy__c from EPW_Hierarchy_Assignment__c]
            );
            system.debug('31 mylist  ' + mylist);

            SelectorWrapper wrapper2 = HierarchyAssignmentSelector.getHrAssgnmentByContact(cSet);

            system.debug('32 wrapper2  ' + wrapper2);

            if(wrapper2!=null && String.isBlank(wrapper2.ErrorMessage)) {
                for(EPW_Hierarchy_Assignment__c hr : (List<EPW_Hierarchy_Assignment__c>)wrapper2.sObjectList) {
                    //For each Contact in Hierarchy Assignment put the Position in a set. 
                    positionIdSetFromContact.add(hr.EPW_Position_Hierarchy__c);
                    if(contactAndPosHierarchy.containsKey(hr.EPW_Contact__c)) {
                        contactAndPosHierarchy.get(hr.EPW_Contact__c).add(hr.EPW_Position_Hierarchy__c);
                    } else {
                        contactAndPosHierarchy.put(hr.EPW_Contact__c,new List<Id>{hr.EPW_Position_Hierarchy__c});

                    }
                }
            }
        }

        system.debug('40 contactAndPosHierarchy  ' + contactAndPosHierarchy);

        //Query the Position Hierarchy using the PositionHierarchy Set Ids. 
        if(!positionIdSetFromContact.isEmpty()) {
            SelectorWrapper swrap = PositionHierarchySelector.getPositionHierarchyById(positionIdSetFromContact);

            system.debug('40 swrap  ' + swrap);

            if(swrap!=null && String.isBlank(swrap.ErrorMessage)) {
                for(EPW_Position_Hierarchy__c posRec : (List<EPW_Position_Hierarchy__c>) swrap.sObjectList ) {
                    phierarchyMap.put(posRec.Id,posRec);
                }
            }
        }

        system.debug('50 phierarchyMap  ' + phierarchyMap);

        // Loop through the results 
        // When we find the Amtrak org record type, cache the record. We may want it later.
        //if we find a Spartn record type -- It is supervisor PH
        if(!phierarchyMap.isEmpty()) {
            for(Id contactId : contactAndPosHierarchy.keySet()) {
                String amtrakPHId='';
                String spartnPHId='';
                for(Id phId : contactAndPosHierarchy.get(contactId)) {
                    if(phierarchyMap.containsKey(phId)) {
                        EPW_Position_Hierarchy__c phRecord = phierarchyMap.get(phId);
                        if(phRecord.RecordTypeId==RevSys_StaticUtility.POSITION_HIERARCHY_AMTRAK_RECTYPE_ID) {
                            amtrakPHId = phRecord.id;
                        } else if(phRecord.RecordTypeId==RevSys_StaticUtility.POSITION_HIERARCHY_SPARTN_RECTYPE_ID) {
                            spartnPHId = phRecord.id;
                            amtrakPHId='';
                            break;
                        }
                    }
                }
                if(String.isNotBlank(spartnPHId)) {
                    //Doing nothing if we are finding a supervisor
                    contactSpartnPH.put(contactId,spartnPHId);
                } else if(String.isNotBlank(amtrakPHId)) {
                    contactOtherOrgPH.put(contactId,amtrakPHId);
                }
            }
        }

        system.debug('60 contactSpartnPH  ' + contactSpartnPH);
        system.debug('60 contactOtherOrgPH  ' + contactOtherOrgPH);

        //If we don't find a Position Hierarchy supervisor record for the SPARTN org, we need to insert one. 
        if(!contactOtherOrgPH.isEmpty() && !phierarchyMap.isEmpty()) {
            for(Id contRec : contactOtherOrgPH.keySet()) {
                if(phierarchyMap.containsKey(contactOtherOrgPH.get(contRec))) {
                    EPW_Position_Hierarchy__c pos = phierarchyMap.get(contactOtherOrgPH.get(contRec));
                    EPW_Position_Hierarchy__c newSpartnPos = pos.clone(); 
                    newSpartnPos.RecordTypeId = RevSys_StaticUtility.POSITION_HIERARCHY_SPARTN_RECTYPE_ID;
                    newSpartnPos.EPW_Parent_Position_Hierarchy__c = null;
                    phToBeInserted.put(contRec,newSpartnPos);
                }
            }
        }

        system.debug('70 phToBeInserted  ' + phToBeInserted);

        //Position Records to be created with SPARTN Record Type
        if(!phToBeInserted.isEmpty()) {
            errMsg = DMLHelper.insertList(phToBeInserted.values());
        }

        system.debug('80 errMsg  ' + errMsg);

        //this is our Supervisor Hierarchy Record and create Hierarchy Assignment
        if(String.isBlank(errMsg) && !phToBeInserted.isEmpty()) {
            for(Id contactId : phToBeInserted.keySet()) {
                if(String.isNotBlank(phToBeInserted.get(contactId).Id)) {
                    EPW_Hierarchy_Assignment__c newHA = new EPW_Hierarchy_Assignment__c();
                    newHA.EPW_Contact__c = contactId;
                    newHA.EPW_Position_Hierarchy__c = phToBeInserted.get(contactId).Id;
                    haRecordToBeInserted.add(newHA);
                }
            }
            
        }

        system.debug('90 haRecordToBeInserted  ' + haRecordToBeInserted);

        //Assign the HIerarchy ASsignment records
        if(!haRecordToBeInserted.isEmpty()) {
            errMsg = DMLHelper.insertList(haRecordToBeInserted);
        }

        system.debug('100 errMsg  ' + errMsg);
       
        Map<Id,Id> mySupervisorPhIdBySuperviseeContactIdMap = new Map<Id,Id>(); 

        for(EPW_Hierarchy_Assignment__c ha :haRecordToBeInserted) { 
            contactSpartnPH.put(ha.EPW_Contact__c, ha.EPW_Position_Hierarchy__c); 

        }

        system.debug('110 contactSpartnPH  ' + contactSpartnPH);

        return contactSpartnPH;

        // returns a Map of the SPARTN Supervisor Id by Contact Id; 
    }

    /**
    *————————————————————————————————————————————————————
    * @Name: updateSupervisorDetails
    * @Description - Called whenever the Position Hierarchy records are updated. 
    *               Fetches the parent position hierarchy records and its related HierarchyAssignment.
    *               Stamps the supervisor email and Name on the hierarchy assignment record.
    * 
    * @param    List<EPW_Position_Hierarchy__c> newHassList - list of Position Hierarchy records
    *                                             records from the trigger 
    *          Map<Id,EPW_Position_Hierarchy__c> old Map
    * @returns  String - error message from the process. 
    *————————————————————————————————————————————————————
    **/
    //To be implemented
    public static String updateSupervisorDetails(List<EPW_Position_Hierarchy__c> posList, Map<Id,EPW_Position_Hierarchy__c> oldPosMap) {
        system.debug('HELPER Revsys_PositionHierarchyHelper2 updateSupervisorDetails-Start');   
        Set<Id> positionHSet = new Set<Id>();
        Map<Id,EPW_Position_Hierarchy__c> myPosHierRecMap = new  Map<Id,EPW_Position_Hierarchy__c>();
        Set<Id> contactIds = new Set<Id>();
        Map<Id,Contact> employeeMap = new Map<Id,Contact>();
        Map<Id,EPW_Hierarchy_Assignment__c> hAByPoHMap = new Map<Id,EPW_Hierarchy_Assignment__c>();
        Map<Id,EPW_Hierarchy_Assignment__c> mapToUpdate = new  Map<Id,EPW_Hierarchy_Assignment__c>();
        String error;

        //Run only when it is an update
        if(posList!=null && oldPosMap!=null) {
            for(EPW_Position_Hierarchy__c posHRec : posList) {
                EPW_Position_Hierarchy__c oldRec = oldPosMap.get(posHRec.Id);
                //process only the parent position hierarcy is changed and is a SPARTN Record Type
                if(posHRec.RecordTypeId==RevSys_StaticUtility.POSITION_HIERARCHY_SPARTN_RECTYPE_ID &&
                    (String.isNotBlank(posHRec.EPW_Parent_Position_Hierarchy__c) && posHRec.EPW_Parent_Position_Hierarchy__c!= oldRec.EPW_Parent_Position_Hierarchy__c)) {
                    //Add all the position Hierarchy records into a single set to fetch the hierarchy assignments
                    positionHSet.add(posHRec.EPW_Parent_Position_Hierarchy__c);
                    if(String.isNotBlank(oldRec.EPW_Parent_Position_Hierarchy__c)) {
                        positionHSet.add(oldRec.EPW_Parent_Position_Hierarchy__c);
                    }
                    positionHSet.add(posHRec.Id);
                    //Add all the valid entries in to a map to process this further instead of trigger list
                    myPosHierRecMap.put(posHRec.Id,posHRec);
                }
            }
        }

        //Process the HA of the all the position Hierarchy records captured
        if(!positionHSet.isEmpty()) {
            SelectorWrapper hAWrap = HierarchyAssignmentSelector.getHrAssgnmentByPositionHierarchy(positionHSet);
            if(String.isBlank(hAWrap.ErrorMessage)) {
                for(EPW_Hierarchy_Assignment__c haRec : (List<EPW_Hierarchy_Assignment__c>)hAWrap.sObjectList) {
                    //Add all the contacts into a set to fetch the contact details from the selector
                    contactIds.add(haRec.EPW_Contact__c);
                    //Create a map of positionHierarchy and HA record for processing.
                    //Assumption -  ONly one HA record will be present for one PH
                    hAByPoHMap.put(haRec.EPW_Position_Hierarchy__c,haRec);
                }
            } else {
                error = hAWrap.ErrorMessage;
            }
        }

        //Get all the contact information
        if(!contactIds.isEmpty()) {
            SelectorWrapper conWrap = ContactSelector.getContacts(contactIds);
            if(String.isBlank(conWrap.ErrorMessage)) {
                for(Contact emp : (List<Contact>)conWrap.sObjectList) {
                    employeeMap.put(emp.Id,emp);
                }
            } else {
                error = conWrap.ErrorMessage;
            }
        }

        if(!myPosHierRecMap.isEmpty() && !employeeMap.isEmpty() && !hAByPoHMap.isEmpty()) {
            for(EPW_Position_Hierarchy__c posHRecord : myPosHierRecMap.values()) {
                //Get the HA record to process
                if(hAByPoHMap.containsKey(posHRecord.Id)) {
                    EPW_Hierarchy_Assignment__c eHrec = hAByPoHMap.get(posHRecord.Id);
                    //Nullify all the fields
                    eHrec.SupervisorEmail__c = '';
                    eHrec.SupervisorName__c='';
                    eHrec.OldSupervisorEmail__c='';
                    ehRec.OldSupervisorName__c='';
                    String newSupPosId = posHRecord.EPW_Parent_Position_Hierarchy__c;
                    String oldSupPosId  = oldPosMap.get(posHRecord.Id).EPW_Parent_Position_Hierarchy__c;
                    //Process the updated Position Hierarchy Record and store it in Supervisor Email
                    if(hAByPoHMap.containsKey(newSupPosId)) {
                        String contactId = hAByPoHMap.get(newSupPosId).EPW_Contact__c;
                        if(employeeMap.containsKey(contactId)) {

                            eHrec.SupervisorEmail__c = employeeMap.get(contactId).Email;
                            eHrec.SupervisorName__c = employeeMap.get(contactId).Name;
                            //Update the reference in a map 
                            mapToUpdate.put(eHrec.Id, eHrec);
                        }
                    }

                    //Process the old Position Hierarchy Record (if exists) and store it in Old Supervisor Email and name fields
                    if(String.isNotBlank(oldSupPosId)) {
                        if(hAByPoHMap.containsKey(oldSupPosId)) {
                            String contactId = hAByPoHMap.get(oldSupPosId).EPW_Contact__c;
                            if(employeeMap.containsKey(contactId)) {
                                eHrec.OldSupervisorEmail__c = employeeMap.get(contactId).Email;
                                eHrec.OldSupervisorName__c = employeeMap.get(contactId).Name;
                                mapToUpdate.put(eHrec.Id, eHrec);
                            }
                        }
                    }
                }
            }
        }

        //Update only if there is a changeed and the list is not empty
        if(!mapToUpdate.isEmpty()) {
            //TO prevent before trigger on HierarchyAssignmentTrigger, Set the flat to true
            Revsys_HierarchyAssignmentHelper.doNotExecute=true;
            error = DMLHelper.updateList(mapToUpdate.values());
        }

        system.debug('HELPER Revsys_PositionHierarchyHelper2 updateSupervisorDetails-End'); 
        return error;
    }

    /**
    *————————————————————————————————————————————————————
    * @Name: assignTargets
    * @Description - Called whenever the Position Hierarchy records are updated. 
    *               Fetches the parent position hierarchy records and its related HierarchyAssignment.
    *               Stamps the supervisor email and Name on the hierarchy assignment record.
    * 
    * @param    List<EPW_Position_Hierarchy__c> newPoHiList - list of Position Hierarchy records
    *                                             records from the trigger 
    *         
    * @returns  String - error message from the process. 
    *————————————————————————————————————————————————————
    **/
    public static String assignTargets(List<EPW_Position_Hierarchy__c> newPoHiList) {
        system.debug('HELPER Revsys_PositionHierarchyHelper2 assignTargets-Start');   
        String errorMsg; 

        // Get the custom settings to set up our checks 

        SPARTN_Custom_Settings__c customSet = SPARTN_Custom_Settings__c.getValues('Valid Employee Department');
        List<String> deptCodesList = new List<String>();
        String deptCodeStr = String.valueOf(customSet.CsvString__c);
        if(String.isNotBlank(deptCodeStr)) {
            deptCodesList = deptCodeStr.toUpperCase().split(',');
        }

        // Roll through the triggr list to pull all Amtrak records with a department 
        // of Transportation, Engineering or Mechanical 

        Set<Id> mycheckPosHiIdSet = new Set<Id>(); 

        for(EPW_Position_Hierarchy__c newPoHi :newPoHiList) {
            if(newPoHi.RecordTypeId == RevSys_StaticUtility.POSITION_HIERARCHY_AMTRAK_RECTYPE_ID) {
                if(String.isNotBlank(newPoHi.EPW_Dept_Code_Description__c) && 
                deptCodesList.contains(newPoHi.EPW_Dept_Code_Description__c.toUpperCase())) { 
                    mycheckPosHiIdSet.add(newPoHi.Id); 
                }
            }
        }

        Set<Id> myContactIdSet = new Set<Id>(); 

        if(myCheckPosHiIdSet.size() > 0) {

            // Now, get the related Hierarchy Assignment records 

            SelectorWrapper myHaWrap = HierarchyAssignmentSelector.getHrAssgnmentByPositionHierarchy(myCheckPosHiIdSet); 

            errorMsg = myHaWrap.ErrorMessage; 

            if(myHaWrap.ErrorMessage == null && myHaWrap.SObjectList.size() > 0) {

                // Get the Contact Ids from the HA records 
                for(EPW_Hierarchy_Assignment__c myHa :(List<EPW_Hierarchy_Assignment__c>)myHaWrap.SObjectList) {

                    myContactIdSet.add(myHa.EPW_Contact__c); 
                }

                // Query the related contacts 

                If(myContactIdSet.size() > 0) {

                    SelectorWrapper myEmpWrap = ContactSelector.getContacts(myContactIdSet); 

                    errorMsg = myEmpWrap.ErrorMessage; 

                    if(myEmpWrap.ErrorMessage == null && myEmpWrap.SObjectList.size() > 0) {

                        // Send them to establish Targets 
                        errorMsg = RevSys_EstablishTargetHelper.establistTargetsFromContact( (List<Contact>)myEmpWrap.SObjectList, 
                                                                                             RevSys_StaticUtility.OCCUPATION ); 
                    }
                }
            }
        }

        return errorMsg; 

        system.debug('HELPER Revsys_PositionHierarchyHelper2 assignTargets-End'); 
        return errorMsg;
    }

}
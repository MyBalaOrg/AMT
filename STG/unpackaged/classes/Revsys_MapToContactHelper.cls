/**
*___________________________________________________
*@Name:      Revsys_MapToContactHelper    
*@Author:    Chuck Walley   
*@Created:   March 15, 2018
*@Used_By:   SPARTN
*___________________________________________________
*@Description: 
* Handles SPARTN business logic concerning the Hierarchy 
* Assignment object
* be called
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/
public class Revsys_MapToContactHelper {

   
    /**
    *————————————————————————————————————————————————————
    * @Name: startFromHierarchyAssignment
    * @Description - Starts the mapping from the Hierarchy Assignment perspective. This, 
    *  generally occurs when 
    * 
    * @param    List<EPW_Hierarchy_Assignment__c> newHassList - list of Hierarchy Assignment
    *                                             records from the trigger 
    * @returns  String - error message from the process. 
    *————————————————————————————————————————————————————
    **/
    public static String startFromHierarchyAssignment(List<EPW_Hierarchy_Assignment__c> newHassList) {
      
        system.debug('HELPER Revsys_MapToContactHelper addNewEmployee-Start');   

        String errMsg; 

        List<EPW_Position_Hierarchy__c> myCheckPosHiList 
            = Revsys_HierarchyAssignmentHelper.separateAmtrakRecords(newHassList); 

        if(myCheckPosHiList.size() > 0) { 
           errMsg = mapInfoToContact(myCheckPosHiList,newHassList);  
        }

        system.debug('HELPER Revsys_MapToContactHelper addNewEmployee-End');    
        return errMsg; 
    }

    /**
    *————————————————————————————————————————————————————
    * @Name: startFromPositionHierarchy
    * @Description - 
    * 
    * @param    List<EPW_Hierarchy_Assignment__c> newHassList - list of Hierarchy Assignment
    *                                             records from the trigger 
    * @returns  String - error message from the process. 
    *————————————————————————————————————————————————————
    **/
    public static String startFromPositionHierarchy(List<EPW_Position_Hierarchy__c> newPosHiList) {
      
        system.debug('HELPER Revsys_MapToContactHelper addNewEmployee-Start');   

        String errMsg; 

        // Get the custom settings for valid departments 
        SPARTN_Custom_Settings__c customSet = SPARTN_Custom_Settings__c.getValues('Valid Employee Department');
        List<String> deptCodesList = new List<String>();
        String deptCodeStr = String.valueOf(customSet.CsvString__c);
        if(String.isNotBlank(deptCodeStr)) {
            deptCodesList = deptCodeStr.toUpperCase().split(',');
        }

        // We want only Amtrak Org records 

        Set<Id> myAmtrakPosHiIdSet = new Set<Id>(); 
        List<EPW_Position_Hierarchy__c> myCheckPosHiList = new List<EPW_Position_Hierarchy__c>(); 

        for(EPW_Position_Hierarchy__c myPosHi :newPosHiList) {

            if(myPosHi.RecordTypeId == RevSys_StaticUtility.POSITION_HIERARCHY_AMTRAK_RECTYPE_ID) {
                if(String.isNotBlank(myPosHi.EPW_Dept_Code_Description__c) && 
                deptCodesList.contains(myPosHi.EPW_Dept_Code_Description__c.toUpperCase())) {
                    myCheckPosHiList.add(myPosHi); 
                    myAmtrakPosHiIdSet.add(myPosHi.Id); 
                }
            }
        }

        SelectorWrapper mySelWrap 
            = HierarchyAssignmentSelector.getHrAssgnmentByPositionHierarchy(myAmtrakPosHiIdSet);

        if(mySelWrap.SObjectList.size() > 0 && mySelWrap.ErrorMessage == null) {

            
            errMsg = mapInfoToContact(myCheckPosHiList,
                                      (List<EPW_Hierarchy_Assignment__c>)mySelWrap.sObjectList);
        }
        system.debug('HELPER Revsys_MapToContactHelper addNewEmployee-End');  
        return errMsg; 
    }

   /**
    *————————————————————————————————————————————————————
    * @Name: mapInfoToContact
    * @Description 
    * 
    * @param    List<EPW_Position_Hierarchy__c> amPosHiList - Amtrak Position Hierarchy records 
    * @returns  String - the error message
    *————————————————————————————————————————————————————
    **/
    public static String mapInfoToContact(List<EPW_Position_Hierarchy__c>   amPosHiList,
                                          List<EPW_Hierarchy_Assignment__c> newHassList) {
        
        system.debug('HELPER Revsys_MapToContactHelper mapInfoToContact-Start');   

        String errMsg; 

        // Create Sets and a Map of Contacts by Positions 
        Set<Id> myContactIdSet = new Set<Id>(); 
        Set<Id> myPosHiIdSet   = new Set<Id>(); 
        Set<Id> myOrgIdSet     = new Set<Id>(); 
        Map<Id,Id> myContactIdByPositionIdMap = new Map<Id,Id>(); 

        for(EPW_Hierarchy_Assignment__c newHass :newHassList) {
            myContactIdSet.add(newHass.EPW_Contact__c); 
            myPosHiIdSet.add(newHass.EPW_Position_Hierarchy__c); 
            myContactIdByPositionIdMap.put(newHass.EPW_Position_Hierarchy__c, 
                                           newHass.EPW_Contact__c); 
        }

        // Get and map the Contacts 
        SelectorWrapper myConWrap = ContactSelector.getContacts(myContactIdSet);

        Map<Id,Contact> myContactMap = new Map<Id,Contact>(); 

        for(Contact myContact :(List<Contact>)myConWrap.sObjectList) {
            myContactMap.put(myContact.Id,myContact); 
        }
        myConWrap = null; 

        // Get the Job Number and Org Unit for each position 
        Set<String> myOrgUnitSet = new Set<String>(); 
        Set<String> myJobCodeSet = new Set<String>(); 

        for(EPW_Position_Hierarchy__c amPosHi :amPosHiList) { 
            myJobCodeSet.add(amPosHi.EPW_Job_Number__c); 
            myOrgIdSet.add(amPosHi.EPW_Position_Organization__c); 
        }

        // Get and Map Organizations 

        Map<Id,EPW_Organization__c> myEpwOrgMap = new Map<Id,EPW_Organization__c>(); 
        
        Id myAmtrakOrgRecTypeId = Revsys_StaticUtility.ORGANIZATION_AMTRAKORG_RECTYPE_ID; 

        SelectorWrapper myOrgSelWrap = EpwOrganizationSelector.getById(myOrgIdSet, myAmtrakOrgRecTypeId);

        if(myOrgSelWrap.ErrorMessage == null && myOrgSelWrap.SObjectList.size() > 0) {
            for(EPW_Organization__c myOrg :(List<EPW_Organization__c>)myOrgSelWrap.SObjectList) {
                myEpwOrgMap.put(myOrg.Id, myOrg);
                myOrgUnitSet.add(myOrg.EPW_Organization_Number__c); 
            }
        }
        myOrgSelWrap = null; 

        // Query and Map the Field Conversion Map values

        Map<String,FieldConversionMap__c> myJobCodeMap = new Map<String,FieldConversionMap__c>(); 
        Map<String,FieldConversionMap__c> myOrgUnitMap = new Map<String,FieldConversionMap__c>(); 

        SelectorWrapper myFieldConWrap 
            = FieldConversionMapSelector.getByOrgUnitAndJobNumber(myJobCodeSet,myOrgUnitSet);

        if(myFieldConWrap.ErrorMessage == null && myFieldConWrap.SObjectList.size() > 0 ) { 

            for(FieldConversionMap__c myFc :(List<FieldConversionMap__c>)myFieldConWrap.sObjectList) {
                if(myFc.SAP_JobCode__c != null) {
                    myJobCodeMap.put(myFc.SAP_JobCode__c,myFc); 
                }
                if(myFc.SAP_OrgUnit__c != null) {
                    myOrgUnitMap.put(myFc.SAP_OrgUnit__c,myFc); 
                }
            }
        }
        myFieldConWrap = null; 

        // Now we're ready to Map

        List<Contact> myUpdateContactList = new List<Contact>(); 



        for(EPW_Position_Hierarchy__c amPosHi :amPosHiList) {

            String myDivisionName, myCraftName;

            // Pull Division Name from the map 
            EPW_Organization__c myEpwOrg = myEpwOrgMap.get(amPosHi.EPW_Position_Organization__c); 

            //system.debug('myEpwOrg ' + myEpwOrg); 
            //system.debug('myEpwOrg.EPW_Organization_Number__c ' + myEpwOrg.EPW_Organization_Number__c); 
            //system.debug('myOrgUnitMap ' + myOrgUnitMap); 

            if(myEpwOrg != null) {
                FieldConversionMap__c myDivFcmRec = myOrgUnitMap.get(myEpwOrg.EPW_Organization_Number__c); 

                if(myDivFcmRec != null) {
                    myDivisionName = myDivFcmRec.ResultingValueA__c; 
                }
            }
          
            // Pull Craft Name from the map 
            FieldConversionMap__c myCraftFcmRec = myJobCodeMap.get(amPosHi.EPW_Job_Number__c); 

            if(myCraftFcmRec != null) {
                myCraftName = myCraftFcmRec.ResultingValueA__c; 
            }

            // Get the Contact and add the mapped values 
            Id myContactId = myContactIdByPositionIdMap.get(amPosHi.Id); 

            if(myContactId != null) {

                Contact myContact = myContactMap.get(myContactId); 

                // Don't mess up the current test data!
                if(myContact != null) {

                    Boolean updateContact = FALSE; 

                    if(myDivisionName != null) {
                        myContact.Division__c = myDivisionName;
                        updateContact = TRUE; 
                    }
                    if(myCraftName != null) {
                        myContact.Craft__c    = myCraftName;
                        updateContact = TRUE; 
                    }
                    if(amPosHi.EPW_Dept_Code_Description__c != null) {
                        myContact.Department  = amPosHi.EPW_Dept_Code_Description__c; 
                        updateContact = TRUE; 
                    }
                    if(updateContact == TRUE) {
                        myUpdateContactList.add(myContact); 
                    }
                }
            }
        }

        // Update the Contacts 
        if(myUpdateContactList.size() > 0 ) {
            errMsg = DmlHelper.updateList(myUpdateContactList); 
        }

        system.debug('HELPER Revsys_MapToContactHelper mapInfoToContact-End'); 
        return errMsg;    
    }

}
/**
*___________________________________________________
*@Name: RevSys_PositionHelper
*@Author: Chuck Walley
*@Created: Date: June 6, 2018
*@Used_By: SPARTN
*___________________________________________________
*@Description: Runs logic agains the Position object, namely for 
* stamping information on the associated Contact record
*
* 
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
* 
**/

global with sharing class RevSys_PositionHelper {
    
    /**
    *————————————————————————————————————————————————————
    * @Name: checkToUpdateSpartnContact()
    * @Description
    * Grabs any SPARTN related Contacts (via Dept_Code_Description__c) and preps them for 
    * updates from the Position object 
    *————————————————————————————————————————————————————
    * @param    theNewPosList   List of Position records, generally from the trigger
    *           theOldPosMap    A map of the old Position records from the trigger 
    * @return   String          Error message
    *————————————————————————————————————————————————————
    **/ 
    public static SelectorWrapper checkToUpdateSpartnContact(List<Contact> theContactList)  
    {
        system.debug('HANDLER RevSys_PositionHelper checkToUpdateSpartnContact2-START');
        String errMsg; 
        
        SelectorWrapper myWrap = new SelectorWrapper(null,null); 
        
        List<Position__c> myCheckPosList = new List<Position__c>(); 
        
        List<String> deptCodesList = new List<String>();
        deptCodesList.add(label.Revsys_Department_ENGINEERING); 
        deptCodesList.add(label.Revsys_Department_MECHANICAL); 
        deptCodesList.add(label.Revsys_Department_TRANSPORTATION); 
        
        List<Id> myPosIdList = new List<Id>(); 
        
        // Collect the Position Ids from the Contact list 
        for(Contact theCon :theContactList) { 
            myPosIdList.add(theCon.PositionLookup__c); 
        }
        
        if(myPosIdList.size() > 0) { 
        
            SelectorWrapper myPosWrap = PositionSelector.getPositionDetailsById(myPosIdList); 
            
            errMsg = myPosWrap.ErrorMessage; 
            myWrap.ErrorMessage = errMsg; 
            
            if(myPosWrap.SObjectList.size() > 0 && myPosWrap.ErrorMessage == null) { 
                
                
                Map<Id,Position__c> myPosMap = new Map<Id,Position__c>(); 
                
                for(Position__c myPos :(List<Position__c>)myPosWrap.SObjectList) {
                    myPosMap.put(myPos.Id,myPos); 
                }
                
                for(Contact theCon :theContactList) { 
                 
                    Position__c myCheckPos = myPosMap.get(theCon.PositionLookup__c); 
                    
                    if(myCheckPos != null) { 
                        if(String.isNotBlank(myCheckPos.Dept_Code_Description__c) && 
                           deptCodesList.contains(myCheckPos.Dept_Code_Description__c.toUpperCase())) { 
                               myCheckPosList.add(myCheckPos); 
                        }
                    }
                }
            }
        }
        
        if(myCheckPosList.size() > 0) { 
            myWrap = prepSpartnContactFromPosition(myCheckPosList); 
        }
        
        
        system.debug('HANDLER RevSys_PositionHelper checkToUpdateSpartnContact2-END');
        return myWrap;
    }
    /**
    *————————————————————————————————————————————————————
    * @Name: checkToUpdateSpartnContact()
    * @Description
    * Culls Position records associated with SPARTN and having a new Dept, Job Number or Org Number
    *————————————————————————————————————————————————————
    * @param    theNewPosList   List of Position records, generally from the trigger
    *           theOldPosMap    A map of the old Position records from the trigger 
    * @return   String          Error message
    *————————————————————————————————————————————————————
    **/ 
    public static SelectorWrapper checkToUpdateSpartnContact(List<Position__c> theNewPosList, Map<Id,SObject> theOldSobjMap)  
    {
        system.debug('HANDLER RevSys_PositionHelper checkToUpdateSpartnContact-START');
        String errMsg; 
        SelectorWrapper myWrap = new SelectorWrapper(null,null); 
        
        List<Position__c> myProcessPosList = new List<Position__c>(); 
        
        // Get the custom setting which tells us the departments which are a part of SPARTN 
        
        List<String> deptCodesList = new List<String>();
        deptCodesList.add(label.Revsys_Department_ENGINEERING); 
        deptCodesList.add(label.Revsys_Department_MECHANICAL); 
        deptCodesList.add(label.Revsys_Department_TRANSPORTATION); 
        
        // Roll through the records from the trigger 
        for(Position__c theNewPos :theNewPosList) {
            
            if(theOldSobjMap != null) { 
                
                SObject     theOldSObj = theOldSObjMap.get(theNewPos.Id);       
                Position__c theOldPos  = (Position__c)theOldSObj; 
                
                system.debug('theNewPos '     + theNewPos); 
                system.debug('theOldPos '     + theOldPos);
                system.debug('deptCodesList ' + deptCodesList);
                
                Boolean isSpartnRecord = false; 
                
                if(String.isNotBlank(theNewPos.Dept_Code_Description__c) && 
                   deptCodesList.contains(theNewPos.Dept_Code_Description__c.toUpperCase())) { 
                       isSpartnRecord = true; 
                }
                
                if(String.isNotBlank(theOldPos.Dept_Code_Description__c) && 
                   deptCodesList.contains(theOldPos.Dept_Code_Description__c.toUpperCase())) { 
                        isSpartnRecord = true; 
                }
            
                // We've determined if we have a SPARTN record 
                
                system.debug('isSpartnRecord '     + isSpartnRecord);
                
                if(isSpartnRecord == true) { 
                
                    // Determine of one of the key fields have changed 
                    if(theNewPos.Dept_Code_Description__c != theOldPos.Dept_Code_Description__c  ||
                       theNewPos.Job_Number__c            != theOldPos.Job_Number__c             ||
                       theNewPos.Org_Unit_Number__c       != theOldPos.Org_Unit_Number__c)          { 
                           
                           myProcessPosList.add(theNewPos); 
                    }
                }
            }
        }
        
        // Check to see if we have records to process 
        
        if(myProcessPosList.size() > 0) { 
            myWrap = prepSpartnContactFromPosition(myProcessPosList); 
        }
        
        system.debug('HANDLER RevSys_PositionHelper checkToUpdateSpartnContact-END');
        return myWrap;
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Name: prepSpartnContactFromPosition()
    * @Description
    * Gathers FieldMapConversion records, puts them into Craft and Division maps and 
    * gets the associated Contacts 
    *————————————————————————————————————————————————————
    * @param    thePosList      List of Position records 
    * @return   String          Error message
    *————————————————————————————————————————————————————
    **/ 
    public static SelectorWrapper prepSpartnContactFromPosition(List<Position__c> thePosList)  
    {
        system.debug('HANDLER RevSys_PositionHelper prepSpartnContactFromPosition-START');
        String errMsg; 
        
        SelectorWrapper myWrap = new SelectorWrapper(null,null); 
                
        List<Id>    myPosIdList  = new List<Id>();         
        Set<String> myJobCodeSet = new Set<String>(); 
        Set<String> myOrgUnitSet = new Set<String>();          
        
        Map<String,FieldConversionMap__c> myJobCodeMap = new Map<String,FieldConversionMap__c>(); 
        Map<String,FieldConversionMap__c> myOrgUnitMap = new Map<String,FieldConversionMap__c>(); 
        
        for(Position__c thePos :thePosList) { 
            myJobCodeSet.add(thePos.Job_Number__c); 
            myOrgUnitSet.add(thePos.Org_Unit_Number__c); 
            myPosIdList.add(thePos.Id);
        }
        
        // Query and Map the Field Conversion Map values
        
        SelectorWrapper myFieldConWrap 
            = FieldConversionMapSelector.getByOrgUnitAndJobNumber(myJobCodeSet,myOrgUnitSet);
		errMsg = myFieldConWrap.ErrorMessage; 
		myWrap.ErrorMessage = errMsg; 
		
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
        
        if(errMsg == null) {
            
        	SelectorWrapper myConWrap = ContactSelector.getContactIdFromPosition(myPosIdList); 
            
            errMsg = myConWrap.ErrorMessage; 
            myWrap.ErrorMessage = errMsg; 
            
            if(myConWrap.SObjectList.size() > 0 && myConWrap.ErrorMessage == null) { 
            	
                List<Contact> myConList = myConWrap.SObjectList;
                
                myWrap = updateSpartnContactFromPosition(thePosList, myConList,
                										 myJobCodeMap, myOrgUnitMap); 
            }            
        }
        
        system.debug('HANDLER RevSys_PositionHelper prepSpartnContactFromPosition-END');
        return myWrap;
    }
    /**
    *————————————————————————————————————————————————————
    * @Name: updateSpartnContactFromPosition()
    * @Description
    * Matches the position with the contact and grabs the Craft and Division from 
    * the FieldConversionMaps 
    *————————————————————————————————————————————————————
    * @param    thePosList      List of Position records 
    *           theConList      List of Contact records 
    *           theJobCodeMap   Map to determine the Craft 
    *           theOrgUnitMap   Map to determine the Division 
    * @return   String          Error message
    *————————————————————————————————————————————————————
    **/ 
    public static SelectorWrapper updateSpartnContactFromPosition(List<Position__c> thePosList, List<Contact> theConList, 
                                                         Map<String,FieldConversionMap__c> theJobCodeMap,
                                                         Map<String,FieldConversionMap__c> theOrgUnitMap)   {  
    
        system.debug('HANDLER RevSys_PositionHelper updateSpartnContactFromPosition-START');
        String errMsg; 
        
        List<Contact> myUpdateContactList = new List<Contact>(); 
        
        // Make a Position Map 
        
        Map<Id,Position__c> myPosMap = new Map<Id,Position__c>(); 
        
        for(Position__c thePos :thePosList) {  
        	myPosMap.put(thePos.Id, thePos);         
        }
        
        // Roll through the Contats 
        
        for(Contact theCon :theConList) { 
            
            if(theCon.PositionLookup__c != null) {
            
                // Get the Position 
                Position__c myPos = myPosMap.get(theCon.PositionLookup__c); 
                
                if(myPos != null) { 
                    
                    // Determine the Craft 
                    String myNewCraft; 
                    FieldConversionMap__c myJobFc = theJobCodeMap.get(myPos.Job_Number__c); 
                    if(myJobFc != null) { 
                        myNewCraft = myJobFc.ResultingValueA__c;     
                    }
                    
                    // Determine the Division 
                    String myNewDivision; 
                    FieldConversionMap__c myDivFc = theOrgUnitMap.get(myPos.Org_Unit_Number__c); 
                    if(myDivFc != null) { 
                        myNewDivision = myDivFc.ResultingValueA__c;     
                    }
                    
                    // Update the contact
                    
                    theCon.Department  = myPos.Dept_Code_Description__c; 
                    theCon.Craft__c    = myNewCraft; 
                    theCon.Division__c = myNewDivision; 
                    
                    myUpdateContactList.add(theCon);
                }
            }
        }
        
        // Update the list 
        if(myUpdateContactList.size() > 0) { 
            
            errMsg = DMLHelper.updateList(myUpdateContactList); 
        } 
        
        List<SObject> mySObjectList = myUpdateContactList;
        SelectorWrapper myWrap = new SelectorWrapper(errMsg, mySObjectList); 
        
        system.debug('HANDLER RevSys_PositionHelper updateSpartnContactFromPosition-END');
        return myWrap;
    }
    
}
/**
*___________________________________________________
*@Name: RevSys_ContactHelper
*@Author: Hemanth Kesapragada
*@Created: Date: 11/22/2017
*@Used_By: SPARTN
*___________________________________________________
*@Description: Its purpose is to establish new targets and assign it to the employee
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/
public class RevSys_ContactHelper {
    
   
    /**
    *————————————————————————————————————————————————————
    * @Name: establishTargets
    * @Description
    * Creates targets (Employee Specific Requirement records) and associates it to the employee (Contact).
    * @param    List of employees (Contacts)
    * @returns  String      Error message if any
    *————————————————————————————————————————————————————
    **/
    public static String establishTargets(List<Contact> contactList, String context) {
        String errorMsg  = RevSys_EstablishTargetHelper.establistTargetsFromContact(contactList,context);
        return errorMsg;
    }
    
    public static void defaultFieldValue(List<Contact> contacts){
        
        List<String> deptCodesList = new List<String>();
        Account amtrakAccount;
        List<Contact> newContactList = validDeptContacts(contacts);
        SelectorWrapper accWrap = AccountSelector.getAccountByName(new Set<String>{Label.RevSys_Generic_Amtrak});
        if(String.isBlank(accWrap.ErrorMessage) && accWrap.SObjectList.size()>0) {
            amtrakAccount = (Account)accWrap.SObjectList.get(0);
        }
        if(amtrakAccount!=null) {
           for(Contact con : newContactList){
                //con.Railroad__c = Label.RevSys_Generic_Amtrak;
                //Check if it is a internal employee
                if(con.RecordTypeId==null) {
                    con.AccountId = amtrakAccount.Id;
                }
            }
        }
       
    }

    private static List<Contact> validDeptContacts(List<Contact> contactList) {
        //get valid Dept codes of the employee csv from custom setting
        REVSYS_Custom_Settings__c customSet = REVSYS_Custom_Settings__c.getValues('Valid Employee Department');
        List<String> deptCodesList = new List<String>();
        List<Contact> newContactList =  new List<Contact>();
        if(customSet!=null) {
            String deptCodeStr = String.valueOf(customSet.CsvString__c);

            if(String.isNotBlank(deptCodeStr)) {
                deptCodesList = deptCodeStr.toUpperCase().split(',');
            }

            for(Contact emp : contactList) {
                if(String.isNotBlank(emp.Department)) {
                    if(deptCodesList.contains(emp.Department.toUpperCase())) {
                        newContactList.add(emp);
                    }
                }
            }
        }
        return newContactList;
    }
    /**
    *————————————————————————————————————————————————————
    * @Name: checkToUpdateSpartnContactWithPositionInfo()
    * @Description
    * Grabs any SPARTN related Contacts (via Dept_Code_Description__c) and preps them for 
    * updates from the Position object 
    *————————————————————————————————————————————————————
    * @param    theNewPosList   List of Position records, generally from the trigger
    *           theOldPosMap    A map of the old Position records from the trigger 
    * @return   String          Error message
    *————————————————————————————————————————————————————
    **/ 
    public static String checkToUpdateSpartnContactWithPositionInfo(List<Contact> theContactList)  
    {
        system.debug('HANDLER RevSys_PositionHelper checkToUpdateSpartnContact2-START');
        String errMsg; 
        
        Set<String> myJobCodeSet = new Set<String>(); 
        Set<String> myOrgUnitSet = new Set<String>(); 
        
        List<Id> myPosIdList = new List<Id>(); 
        
        Map<String,FieldConversionMap__c> myJobCodeMap = new Map<String,FieldConversionMap__c>(); 
        Map<String,FieldConversionMap__c> myOrgUnitMap = new Map<String,FieldConversionMap__c>(); 
        
        List<Position__c> myCheckPosList = new List<Position__c>(); 
        
        //SPARTN_Custom_Settings__c customSet = SPARTN_Custom_Settings__c.getValues(label.Revsys_Valid_Employee_Department);
        
        //
        //String deptCodeStr = String.valueOf(customSet.CsvString__c);
        //if(String.isNotBlank(deptCodeStr)) {
        //    deptCodesList = deptCodeStr.toUpperCase().split(',');
        //}
        
        List<String> deptCodesList = new List<String>();
        deptCodesList.add(label.Revsys_Department_ENGINEERING); 
        deptCodesList.add(label.Revsys_Department_MECHANICAL); 
        deptCodesList.add(label.Revsys_Department_TRANSPORTATION); 
        
        // Collect the Position Ids from the Contact list 
        for(Contact theCon :theContactList) { 
            myPosIdList.add(theCon.PositionLookup__c); 
            
        }
        
        if(myPosIdList.size() > 0) { 
        
            SelectorWrapper myPosWrap = PositionSelector.getPositionDetailsById(myPosIdList); 
            
            errMsg = myPosWrap.ErrorMessage; 
            
            
            if(myPosWrap.SObjectList.size() > 0 && myPosWrap.ErrorMessage == null) { 
                
                
                Map<Id,Position__c> myPosMap = new Map<Id,Position__c>(); 
                
                for(Position__c myPos :(List<Position__c>)myPosWrap.SObjectList) {
                    myPosMap.put(myPos.Id,myPos); 
                    myJobCodeSet.add(myPos.Job_Number__c); 
                    myOrgUnitSet.add(myPos.Org_Unit_Number__c); 
                }
                
                // Query and Map the Field Conversion Map values
        
                SelectorWrapper myFieldConWrap 
                    = FieldConversionMapSelector.getByOrgUnitAndJobNumber(myJobCodeSet,myOrgUnitSet);
        		errMsg = myFieldConWrap.ErrorMessage; 
        		
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
                
                for(Contact theCon :theContactList) { 
                 
                    Position__c myCheckPos = myPosMap.get(theCon.PositionLookup__c); 
                    
                    if(myCheckPos != null) { 
                        if(String.isNotBlank(myCheckPos.Dept_Code_Description__c) && 
                           deptCodesList.contains(myCheckPos.Dept_Code_Description__c.toUpperCase())) { 
                                
                                
                                // Determine the Craft 
                                String myNewCraft; 
                                FieldConversionMap__c myJobFc = myJobCodeMap.get(myCheckPos.Job_Number__c); 
                                if(myJobFc != null) { 
                                    theCon.Craft__c = myJobFc.ResultingValueA__c; 
                                }
                                
                                // Determine the Division 
                                String myNewDivision; 
                                FieldConversionMap__c myDivFc = myOrgUnitMap.get(myCheckPos.Org_Unit_Number__c); 
                                if(myDivFc != null) { 
                                    theCon.Division__c = myDivFc.ResultingValueA__c; 
                                }
                                
                                // Update the contact
                                theCon.Department  = myCheckPos.Dept_Code_Description__c; 
                        }
                    }
                }
            }
        }
        
        system.debug('HANDLER RevSys_PositionHelper checkToUpdateSpartnContact2-END');
        return errMsg;
    }
}
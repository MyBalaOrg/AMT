/**
*___________________________________________________
*@Name:      Revsys_HierarchyAssignmentHelper    
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
* 04-26-2018 Added assignTargets() method
* 05-04-2018 Use padded Employee Number when searching for Users
**/
public class Revsys_HierarchyAssignmentHelper {
    public static Boolean doNotExecute = false;
     
    /**
    *————————————————————————————————————————————————————
    * @Name: addNewEmployee
    * @Description - Begins the process of adding SPARTN employees to their 
    *                Management Accountability Roster. This method checks 
    *                to ensure they are Transporation, Mechanical or Engineering 
    *                enployees and are being added to a record associated with the 
    *                Amtrak Org. It passes the culled records to checkAmtrakRecords(). 
    * 
    * @param    List<EPW_Hierarchy_Assignment__c> newHassList - list of Hierarchy Assignment
    *                                             records from the trigger 
    * @returns  String - error message from the process. 
    *————————————————————————————————————————————————————
    **/
    public static String addNewEmployee(List<EPW_Hierarchy_Assignment__c> newHassList) {
      
        system.debug('HELPER Revsys_HierarchyAssignmentHelper addNewEmployee-Start');   
        system.debug('newHassList  ' + newHassList); 

        String errMsg; 

        List<EPW_Position_Hierarchy__c> myCheckPosHiList 
            = separateAmtrakRecords(newHassList); 

        if(myCheckPosHiList.size() > 0) { 
           errMsg = checkAmtrakRecords(myCheckPosHiList);  
        }
       

        system.debug('HELPER Revsys_HierarchyAssignmentHelper addNewEmployee-End');  
        return errMsg; 
    }

    /**
    *————————————————————————————————————————————————————
    * @Name: assignTargets
    * @Description - checks to see if this is a SPARTN Employee and if so
    * queries the Contact, puts it into a list and sends it to see if any 
    * Targets need to be established or updated 
    *
    * 
    * @param    List<EPW_Hierarchy_Assignment__c> newHassList - list of Hierarchy Assignment
    *                                             records from the trigger 
    * @returns  SelectorWrapper     wrapper class with the result  
    *————————————————————————————————————————————————————
    **/
    public static String assignTargets(List<EPW_Hierarchy_Assignment__c> newHassList) {
      
        system.debug('HELPER Revsys_HierarchyAssignmentHelper assignTargets-Start');   
        system.debug('newHassList  ' + newHassList); 

        String errMsg; 


        // We want only Hierarchy Assignment Records associated with the Amtrak Org.
        // (While we are updating SPARTN Employees, we are not working with their MAR records - 
        // we are working with Amtrak records)


        // Get the associated Amtrak Position Hierarchy Records and the Ids in a Set
        List<EPW_Position_Hierarchy__c> separatedAmtrakPoHiList = separateAmtrakRecords(newHassList);

        Set<Id> separatedAmtrakPoHiSet = new Set<Id>(); 

        for(EPW_Position_Hierarchy__c separatedAmtrakPoHi :separatedAmtrakPoHiList) {
            separatedAmtrakPoHiSet.add(separatedAmtrakPoHi.Id); 
        }

        // Check to see if the Hierarchy Assignment records is part of the Separated Amtrak Position Hierarchy Set

        Set<Id> myContactIdSet = new Set<Id>(); 

        for(EPW_Hierarchy_Assignment__c newHass :newHassList) {

            if(separatedAmtrakPoHiSet.contains(newHass.EPW_Position_Hierarchy__c)) {
                myContactIdSet.add(newHass.EPW_Contact__c); 
            }
        }

        SelectorWrapper myContactWrap = ContactSelector.getContacts(myContactIdSet); 

        errMsg = myContactWrap.ErrorMessage;

        if(myContactWrap.ErrorMessage == null && myContactWrap.SObjectList.size() > 0) {

            errMsg = RevSys_EstablishTargetHelper.establistTargetsFromContact( (List<Contact>)myContactWrap.SObjectList, RevSys_StaticUtility.OCCUPATION ); 
        }

        system.debug('HELPER Revsys_HierarchyAssignmentHelper assignTargets-End');  
        return errMsg; 
    }


    /**
    *————————————————————————————————————————————————————
    * @Name: checkAmtrakRecords
    * @Description - Called from addNewEmployee(), this method calls 
    *  Revsys_PositionHierarchyHelper.processSupervisorPositionHierarchy() to 
    *  ensure the supervisor has been added to the SPARTN org and returns a map 
    *  of the contact and Supervisor's Position Hierarchy Id. Then, it creates a 
    *  Map of the employees and supervisors by Position. With this information, 
    *  control is passed to createRecords(). 
    * 
    * @param    List<EPW_Position_Hierarchy__c> amPosHiList - Amtrak Position Hierarchy records 
    * @returns  String - the error message
    *————————————————————————————————————————————————————
    **/
    public static String checkAmtrakRecords(List<EPW_Position_Hierarchy__c> amPosHiList) {
        
        system.debug('HELPER Revsys_HierarchyAssignmentHelper checkAmtrakRecords-Start');   
        system.debug('amPosHiList  ' + amPosHiList); 

        String errMsg; 

        // Create a Map of my SPARTN Supervisor by Contact Id 

        Map<Id,Id> spartnPhIdByContactIdMap 
            = Revsys_PositionHierarchyHelper2.processSupervisorPositionHierarchy(amPosHiList);

        system.debug('spartnPhIdByContactIdMap  ' + spartnPhIdByContactIdMap); 

        // Get the Amtrak Supervisor Position Ids from the list 

        Set<Id> myAmtrakSupervisorPhIdSet = new Set<Id>(); 
        Set<Id> myAmtrakEmployeePhIdSet = new Set<Id>(); 
        Set<Id> myAmtrakCombinedPhIdSet = new Set<Id>(); 

        for(EPW_Position_Hierarchy__c amPosHi :amPosHiList) {
            if(amPosHi.EPW_Parent_Position_Hierarchy__c != null) {
                myAmtrakSupervisorPhIdSet.add(amPosHi.EPW_Parent_Position_Hierarchy__c); 
                myAmtrakEmployeePhIdSet.add(amPosHi.Id); 

                myAmtrakCombinedPhIdSet.add(amPosHi.EPW_Parent_Position_Hierarchy__c); 
                myAmtrakCombinedPhIdSet.add(amPosHi.Id); 
            }
        }

        Map<Id,Id> amContactIdByPhId = new Map<Id,Id>(); 



        // Create a Map of Amtrak Supervisor and Employee Contacts By Position 
        SelectorWrapper selwrap  
            = HierarchyAssignmentSelector.getHrAssgnmentByPositionHierarchy(myAmtrakCombinedPhIdSet);
        errMsg = selwrap.ErrorMessage; 
        List<EPW_Hierarchy_Assignment__c> myHaList = selwrap.SObjectList; 

        if(errMsg == null && myHaList.size() > 0) {
            for(EPW_Hierarchy_Assignment__c myHa :myHaList) {
                amContactIdByPhId.put(myHa.EPW_Position_Hierarchy__c, 
                                      myHa.EPW_Contact__c); 
            }
        }

        errMsg = createRecords(amPosHiList, amContactIdByPhId, spartnPhIdByContactIdMap); 
       

        system.debug('HELPER Revsys_HierarchyAssignmentHelper checkAmtrakRecords-End'); 
        return errMsg;    
    }
    /**
    *————————————————————————————————————————————————————
    * @Name: createRecords
    * @Description - Called from checkAmtrakRecords(), this method matches the 
    *  supervisor to the employee's SPARTN position hierarchy record and inserts it. 
    *  It also creates the associated Hierarchy Assignment. 
    * 
    * @param    List<EPW_Position_Hierarchy__c> amPosHiList - list of Amtrak Position Hierarchy recs
                Map<Id,Id> amContactIdByPhId - Amtrak Contacts by Position History Id
                Map<Id,Id> spartnPhIdByContactIdMap - Spartn Position Hierarchy Ids by Contact Id 
    * @returns  String - error Message. 
    *————————————————————————————————————————————————————
    **/
    public static String createRecords(List<EPW_Position_Hierarchy__c> amPosHiList,
                                        Map<Id,Id> amContactIdByPhId, 
                                        Map<Id,Id> spartnPhIdByContactIdMap) {

        system.debug('HELPER Revsys_HierarchyAssignmentHelper createRecords-Start');  
        system.debug('amPosHiList  ' + amPosHiList); 
        system.debug('amContactIdByPhId  ' + amContactIdByPhId); 
        system.debug('spartnPhIdByContactIdMap  ' + spartnPhIdByContactIdMap); 
    
        String errMsg; 

        // Find the Users associated with the Contacts and Map them. We want to 
        // know the Users so we can make them the owners of the SPARTN HA records. 
        // This allows them to see their records in a list view  

        Set<Id>     myContactIdSet = new Set<Id>(); 
        Set<String> myEmpNumSet    = new Set<String>(); 

        myContactIdSet.addAll( amContactIdByPhId.values() ); 


        Map<Id,String> myEmpNumByContactIdMap = new Map<Id,String>(); 
        Map<Id,Id> mySuperContIdByEmployeeContIdMap = new Map<Id,Id>(); 
        Map<String,Id> myUserIdByEmpNumMap = new Map<String,Id>(); 

        SelectorWrapper myContactRap = ContactSelector.getContacts(myContactIdSet); 

        errMsg = myContactRap.ErrorMessage; 

        if(myContactRap.ErrorMessage == null && myContactRap.SObjectList.size() > 0) {
            for(Contact myContact :(List<Contact>)myContactRap.SObjectList) {
                myEmpNumByContactIdMap.put(myContact.Id,String.valueOf(myContact.Personnel_Number__c) );

                String myEmpNum = String.valueOf(myContact.Personnel_Number__c);
                myEmpNumSet.add(myEmpNum); 
                myEmpNum = myEmpNum.leftPad(8,'0');
                myEmpNumSet.add(myEmpNum); 
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

        Map<Id,EPW_Position_Hierarchy__c> spartnPhbyContactIdMap 
            = new Map<Id,EPW_Position_Hierarchy__c>(); 

        for(EPW_Position_Hierarchy__c amPosHi :amPosHiList) {

            Id mySuperContact    = amContactIdByPhId.get(amPosHi.EPW_Parent_Position_Hierarchy__c); 
            Id myEmployeeContact = amContactIdByPhId.get(amPosHi.Id); 

            mySuperContIdByEmployeeContIdMap.put(myEmployeeContact, mySuperContact); 

            if(myEmployeeContact != null) {

                Id mySuperPosition = spartnPhIdByContactIdMap.get(mySuperContact); 

                if(mySuperPosition != null) {
                    EPW_Position_Hierarchy__c newSpartnPos = amPosHi.clone(false,false,false,false);  
                    newSpartnPos.RecordTypeId = RevSys_StaticUtility.POSITION_HIERARCHY_SPARTN_RECTYPE_ID;
                    newSpartnPos.EPW_Parent_Position_Hierarchy__c = mySuperPosition;
                    spartnPhbyContactIdMap.put(myEmployeeContact,newSpartnPos);
                }
            }
        }

        if(spartnPhbyContactIdMap.size() > 0) {
            errMsg = DMLHelper.insertList(spartnPhbyContactIdMap.values());

            //this is our Supervisor Hierarchy Record and create Hierarchy Assignment
            if(errMsg == null) {

                List<EPW_Hierarchy_Assignment__c> haListToBeInserted = new List<EPW_Hierarchy_Assignment__c>(); 
                for(Id contactId : spartnPhbyContactIdMap.keySet()) {
                    if(String.isNotBlank(spartnPhbyContactIdMap.get(contactId).Id)) {

                        Id mySuperContactId = mySuperContIdByEmployeeContIdMap.get(contactId); 
                        String mySuperEmpNum = myEmpNumByContactIdMap.get(mySuperContactId); 
                        Id mySuperUserId = myUserIdByEmpNumMap.get(mySuperEmpNum); 

                        EPW_Hierarchy_Assignment__c newHA = new EPW_Hierarchy_Assignment__c();
                        newHA.EPW_Contact__c = contactId;
                        newHA.EPW_Position_Hierarchy__c = spartnPhbyContactIdMap.get(contactId).Id;
                        newHA.SPARTN_Manager__c = mySuperContactId; 

                        if(mySuperUserId != null) { 
                            newHA.OwnerId = mySuperUserId; 
                        }

                        haListToBeInserted.add(newHA);
                    }
                }
                //Insert the Hierarchy Assignment records
                if(haListToBeInserted.size() > 0) {
                    errMsg = DMLHelper.insertList(haListToBeInserted);
                }
            }
        }

        system.debug('HELPER Revsys_HierarchyAssignmentHelper createRecords-End');  
        return errMsg;    
    }

    /**
    *————————————————————————————————————————————————————
    * @Name: separateAmtrakRecords
    * @Description - Begins the process of adding SPARTN employees to their 
    *                Management Accountability Roster. This method checks 
    *                to ensure they are Transporation, Mechanical or Engineering 
    *                enployees and are being added to a record associated with the 
    *                Amtrak Org. It passes the culled records to checkAmtrakRecords(). 
    * 
    * @param    List<EPW_Hierarchy_Assignment__c> newHassList - list of Hierarchy Assignment
    *                                             records from the trigger 
    * @returns  String - error message from the process. 
    *————————————————————————————————————————————————————
    **/
    public static List<EPW_Position_Hierarchy__c> separateAmtrakRecords(List<EPW_Hierarchy_Assignment__c> newHassList) {
      
        system.debug('HELPER Revsys_HierarchyAssignmentHelper separateAmtrakRecords-Start');   
        system.debug('newHassList  ' + newHassList); 

        /*
        SPARTN_Custom_Settings__c customSet = SPARTN_Custom_Settings__c.getValues('Valid Employee Department');
        List<String> deptCodesList = new List<String>();
        String deptCodeStr = String.valueOf(customSet.CsvString__c);
        if(String.isNotBlank(deptCodeStr)) {
            deptCodesList = deptCodeStr.toUpperCase().split(',');
        }
        */ 

        Set<Id> myContactIdSet = new Set<Id>(); 
        Set<Id> myPosHiIdSet   = new Set<Id>(); 

        for(EPW_Hierarchy_Assignment__c newHass :newHassList) {
            myContactIdSet.add(newHass.EPW_Contact__c);   
            myPosHiIdSet.add(newHass.EPW_Position_Hierarchy__c);     
        }

        String errMsg; 

        SelectorWrapper myPosHiSelWrap 
            = PositionHierarchySelector.getPositionHierarchyById(myPosHiIdSet); 

        system.debug('myPosHiIdSet  ' + myPosHiIdSet); 
        system.debug('myPosHiSelWrap  ' + myPosHiSelWrap); 

        errMsg = myPosHiSelWrap.ErrorMessage; 
        List<EPW_Position_Hierarchy__c> myPosHiList = myPosHiSelWrap.SObjectList; 

        List<EPW_Position_Hierarchy__c> myCheckPosHiList = new List<EPW_Position_Hierarchy__c>(); 

        if(errMsg == null && myPosHiList.size() > 0) {
           
            List<String> deptCodesList = new List<String>();

            for(EPW_Position_Hierarchy__c myPosHi :myPosHiList) {
                if(myPosHi.RecordTypeId == RevSys_StaticUtility.POSITION_HIERARCHY_AMTRAK_RECTYPE_ID) {

                    if(deptCodesList.size() == 0) { 
                        SPARTN_Custom_Settings__c customSet = SPARTN_Custom_Settings__c.getValues('Valid Employee Department');
                        String deptCodeStr = String.valueOf(customSet.CsvString__c);
                        if(String.isNotBlank(deptCodeStr)) {
                            deptCodesList = deptCodeStr.toUpperCase().split(',');
                        }
                    }

                    if(String.isNotBlank(myPosHi.EPW_Dept_Code_Description__c) && 
                    deptCodesList.contains(myPosHi.EPW_Dept_Code_Description__c.toUpperCase())) { 
                        myCheckPosHiList.add(myPosHi); 
                    }
                }
            }
        }

        system.debug('HELPER Revsys_HierarchyAssignmentHelper separateAmtrakRecords-End');  
        system.debug('myCheckPosHiList  ' + myCheckPosHiList); 
        return myCheckPosHiList; 
    }

    /**
    *————————————————————————————————————————————————————
    * @Name: getSupervisorEmail
    * @Description - Fetches the supervisor email from the Position Hierarchy and saves it on the Hierarchy assignment record
    * 
    * @param    List<EPW_Hierarchy_Assignment__c> amPosHiList - list of Amtrak Hierarchy Assignment recs
    * @returns  String - error Message. 
    *————————————————————————————————————————————————————
    **/
    public static String getSupervisorEmail(List<EPW_Hierarchy_Assignment__c> newHassList, Map<Id,EPW_Hierarchy_Assignment__c> oldMap) {
        String errMsg ;
        if(!doNotExecute) {
            system.debug('HELPER Revsys_HierarchyAssignmentHelper getSupervisorEmail-Start');

            Set<Id> myContactIdSet = new Set<Id>(); 
            Map<Id,Contact> myContactMap = new Map<Id,Contact>(); 

            for(EPW_Hierarchy_Assignment__c newHass :newHassList) {

                Id myOldContactId; 

                // Get the old record, if we have one. 
                EPW_Hierarchy_Assignment__c oldHass = null; 
                if(oldMap != null ) {
                    oldHass = oldMap.get(newHass.Id); 
                    myContactIdSet.add( oldHass.SPARTN_Manager__c);  
                }

                myContactIdSet.add(newHass.SPARTN_Manager__c); 
            }

            SelectorWrapper myContWrap = ContactSelector.getContacts(myContactIdSet); 

            errMsg = myContWrap.ErrorMessage; 

            if(myContwrap.ErrorMessage == null && myContWrap.SObjectList.size() > 0) { 

                for(Contact myContact :(List<Contact>)myContWrap.SObjectList ) { 

                    myContactMap.put(myContact.Id, myContact); 
                }
            }

            // Now we have our contacts mapped, roll through the new list and assign names and email addresses 

            for(EPW_Hierarchy_Assignment__c newHass :newHassList) {

                Id oldContactId; 
                Contact oldContact;

                // Get the old record, if we have one. 
                EPW_Hierarchy_Assignment__c oldHass = null; 
                if(oldMap != null ) {
                    oldHass = oldMap.get(newHass.Id); 
                    oldContact = myContactMap.get(oldHass.SPARTN_Manager__c); 

                    if(oldContact != null) { 
                        newHass.OldSupervisorName__c    = oldContact.Name;
                        newHass.OldSupervisorEmail__c   = oldContact.Email;
                    }
                }

                Contact newContact = myContactMap.get(newHass.SPARTN_Manager__c); 

                if(newContact != null) {
                    newHass.SupervisorName__c   = newContact.Name;
                    newHass.SupervisorEmail__c  = newContact.Email;
                    //newHass.SPARTN_Manager__c   = newContact.Id; 
                }
            }
        }

        return errMsg; 
 }


  
 /**
    *————————————————————————————————————————————————————
    * @Name: updateContactLastTesttakenDate
   
    *————————————————————————————————————————————————————
    **/
    public static String updateContactLastTesttakenDate(List<EPW_Hierarchy_Assignment__c> newHierarchyList,
                                                        Map<Id,EPW_Hierarchy_Assignment__c> oldMap)
    {
        String errorMessage;
        if(!doNotExecute) {
            
            System.debug('Revsys_HierarchyAssignmentHelper - updateEmployeeLastTesttakenDate - Start');                                                        
            Set<Id> empIdSet = new Set<Id>();
            
            Map<Id,DateTime> ContactLastTestTakenDateMap = new Map<Id,DateTime>();
            
            if(newHierarchyList!=null) {
                for(EPW_Hierarchy_Assignment__c HierarchyAssign : newHierarchyList) {
                    empIdSet.add(HierarchyAssign.EPW_Contact__c);
                }
                
            }
            system.debug('ContactLastTestTakenDateMap $$'+ContactLastTestTakenDateMap);
            if(!empIdSet.isEmpty()) {        
                system.debug('empIdSet$$'+empIdSet);
                SelectorWrapper wrapper = ObservationSelector.selectByEmployeeOrderEvaluationDate(empIdSet);          
                system.debug('wrapper$$'+wrapper);
                system.debug('String.isBlank(wrapper.ErrorMessage) $$'+String.isBlank(wrapper.ErrorMessage));
                system.debug('wrapper.SObjectLis $$'+wrapper.SObjectList.size());
                if(String.isBlank(wrapper.ErrorMessage) && wrapper.SObjectList.size()!=0) {
                    for(sObject obs : wrapper.sObjectList) {
                        ContactLastTestTakenDateMap.put((Id)obs.get('Employee__c'), (DateTime)obs.get('evdate'));                
                    }
                } else {
                    errorMessage = wrapper.ErrorMessage;
                }
            }
            
            system.debug('ContactLastTestTakenDateMap427 $$'+ContactLastTestTakenDateMap);
            if(!ContactLastTestTakenDateMap.isEmpty()) {  
                
                for(EPW_Hierarchy_Assignment__c hierarchyAssign : newHierarchyList) { 
                    
                    if(ContactLastTestTakenDateMap.containsKey(hierarchyAssign.EPW_Contact__c)) {	
                        
                        System.debug('ContactLastTestTakenDateMap.get(hierarchyAssign.EPW_Contact__c)'+ContactLastTestTakenDateMap.get(hierarchyAssign.EPW_Contact__c));
                        hierarchyAssign.SPARTN_LastTestCompletionDate__c = ContactLastTestTakenDateMap.get(hierarchyAssign.EPW_Contact__c);					
                        
                    }
                }
            }
            System.debug('REvsys_EmployeeHierarchyHelper - updateEmployeeLastTesttakenDate - End');
                                                           
        }
        return errorMessage;
    }

}
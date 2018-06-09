/**
* ********************************************************************************************************************************************************************************************************************************************
*   @Name           OC_OrgChartTopLevelApexController
*   @Author         Sarang, Deloitte Digital
*   @Created Date   30th Jan 2017
*   @Used By        OC_VerticalOrgChartComponent    
*   *******************************************************************************************************************************************************************************************************************************************
*   @Description    This controller builds the Employee record and fetches data required by the component to be displayed.
*   *******************************************************************************************************************************************************************************************************************************************
*   @Changes
	8th June 2017 -Modified to hold contact information sitting on an position as part of ENHC 12
*   ******************************************************************************************************************************************************************************************************************************************* 
**/

public with sharing class OC_OrgChartTopLevelApexController {
    
    
    //Inner Class representing Employee containing both position and contact records
    public class Employee
    {
        // Constructor for Employee class
        @AuraEnabled
        public Boolean isRootNode{get;set;}
        
        @AuraEnabled
        public position__c position{get;set;}
        
        @AuraEnabled
        public List<Contact> contacts{get;set;}
        
        @AuraEnabled
        public Boolean isDummy { get;set; }
        
        @AuraEnabled
        public Boolean isVacant{get;set;}
        
        @AuraEnabled
        public Boolean hasMultipleEmployees{get;set;}
        
        @AuraEnabled
        public Boolean hasManager{get;set;}
        
        @AuraEnabled
        public Boolean hasSubordinates{get;set;}
        
        //ENHC 12 Modified Constructor to hold multiple contacts on one position
        public Employee(position__c position,List<contact> contacts) {
            String originTitle = OC_OrgChartTopLevelApexControllerHelper.getOriginTile();
            this.position = position;
            this.contacts = contacts;
            this.isDummy = false;
            this.isVacant = false;
            this.hasMultipleEmployees = false;
            this.hasManager = false;
            this.hasSubordinates = false;
            this.isRootNode = false;
            //Root Node - Amtrak Summary
             if(this.contacts.size() > 0) {
                for(contact c: this.contacts) {
                    if(c.lastname == originTitle) {
                        this.isRootNode = true;
                        this.isDummy = true;
                        break;
                    }
                }
            }        
            //Vacant check
            if(this.contacts.size() <= 0 && !this.position.Position_ID__c.startsWith('D')) this.isVacant = true;
            //Multiple Employees Check
            if(this.contacts.size() > 1) this.hasMultipleEmployees = true;
            //Dummy Position Check
            if(this.position.Position_ID__c.startsWith('D')) this.isDummy = true;
            // subordinate check
            if(this.position.Number_of_Dir_Reports__c > 0) this.hasSubordinates = true;
            // manager check
            if(this.position.Generated_Reports_To_Position__c !=null) this.hasmanager = true;
        }
        
    }
  
    //Used for Search, List and export functions to supply configured 
    //field lists with associated labels
    public class FieldList
    {
        @AuraEnabled
        public list<String> sobjectFields{get;set;}
        @AuraEnabled
        public list<String> displayLabels{get;set;}
        
        public FieldList()
        {
            sobjectFields = new list<String>();
            displayLabels = new list<String>();
        }
    }
    
    // Query for the position with a certain ID and its associated Contact
    // Return a default (Amtrak Summary) if no position exists with the passed in ID
    
    //Sarang - Changed method name from queryContact to querySelectedEmployee 6/6/2017
    @AuraEnabled
    public static Employee querySelectedEmployee(String positionId) {

        String originTitle = OC_OrgChartTopLevelApexControllerHelper.getOriginTile();
        List<Position__c> positions = new List<Position__c>();
        
        if(positionId != null && positionId != '')
            positions = doPositionQuery('Id = \'' + positionId + '\'');
        else
            positions = doPositionQuery(' Id IN (SELECT PositionLookup__c FROM Contact WHERE LastName=\'' + originTitle + '\')');
        
        if(positions.size() > 0)
            return getEmployeeRecord(positions.get(0));
        else
            return null;
    }
    
    // Query for positions that report to the position with a certain ID, return data about the positions and associated contacts
    // Sarang - Modified to point to the new data structure 6/6/2017
    @AuraEnabled
    public static List<Employee> querySubordinates(String managerId) {            
        List<Employee> employees = new List<Employee>();
        
        //get all the subordinates
        List<Position__c> positions = doPositionQuery('Generated_Reports_To_Position__c= \'' + managerId + '\'');
        if(!positions.isEmpty()) {
            for(Position__c position : Positions) {
                //load the Employee record from the position
                employees.add(new Employee(position,position.Contacts__r));
            }            
            for(Employee emp : employees) {
                system.debug('subordinat '+emp.contacts);
            }
            //Need a way to sort here
            return employees;
        } else {
            System.debug('no subordinates found');
            return null;
        }
        
    }
    
    // Query for the position that a position with a certain ID reports to, return data about the position and associated contact
    // Sarang : Modified to point to the new data structure 6/62017
    @AuraEnabled
    public static Employee queryManager(String subId) {
        
      
        String originTitle = OC_OrgChartTopLevelApexControllerHelper.getOriginTile();
        
        List<Position__c> subList = [SELECT Id, Generated_Reports_To_Position__c FROM Position__c WHERE Id=:subId];
        
        if(subList.size() > 0 && sublist.get(0).Generated_Reports_To_Position__c != null) {
            Position__c sub = sublist.get(0);
            
            List<Position__c> positions = doPositionQuery('Id= \'' + sub.Generated_Reports_To_Position__c + '\'');
            
            if(!positions.isEmpty()) {
                return getEmployeeRecord(positions.get(0));    
            } else {
                System.debug('no position with that Id');
                return null;
            }
        } else {
            System.debug('Invalid position ID passed to OrgChartTopLevelApexController.queryManager() or this position does not report to any other');
            return null;
        }
        
    }
    
    // Query for the custom setting storing the url for this environment's advanced search page
    @AuraEnabled
    public static String retrieveSearchUrl() {
        Organization_Chart__c orgChart = Organization_Chart__c.getValues('OrgChartData');
        String searchUrl = orgChart.Advanced_Search_URL__c;
        return searchUrl;
    }
    
    // Reusable method for querying the long list of required fields
    // Modified to include Position_Level__c as part of ENHC 3
    private static List<Position__c> doPositionQuery(String whereClause) {
        List<String> activeStatus = new List<String>();
        List<String> terminatedStatus = new List<String>();
        
        terminatedStatus = OC_OrgChartTopLevelApexControllerHelper.getTerminatedStatuses();
        activeStatus  = OC_OrgChartTopLevelApexControllerHelper.getActiveStatuses();
        String originTitle = OC_OrgChartTopLevelApexControllerHelper.getOriginTile();
        String query = 'SELECT Id, Position_Level__c,Position_Title__c,Number_of_Part_Time__c,Number_of_Management__c,Number_of_Interns__c,Name, Position_ID__c, Personnel_Area__c,Personnel_SubArea_Text__c,Cost_Center__c,Job_Abbrev__c,Org_Unit_Number__c,Position_Abbrv__c, Generated_Reports_To_Position__c, Employee_Group_Text__c, Employee_Subgroup_Text__c, Job_Title__c,Organization_Unit_Name__c,Number_of_Active_Employees__c,Number_of_Contractors__c,Number_of_Dir_Reports__c,Number_of_Full_Time__c,Number_of_Hourly__c, (SELECT FirstName, MiddleName, LastName, Suffix, Job_Abbrev__c, Org_Unit_Number__c, Organization_Unit_Name__c, Cost_Center__c, Personnel_Area__c, Personnel_SubArea_Text__c, Work_Schedule__c, Time_Admin__c, Payroll_Admin__c, Org_Key__c, Corp_Function__c, Hire_Date__c, Employment_Status__c FROM Contacts__r WHERE Employment_Status__c IN :activeStatus OR LastName=\''
            + originTitle + '\') FROM Position__c WHERE ' + whereClause+ 'AND Employment_Status__c NOT IN :terminatedStatus ';
  
        List<Position__c> positions = Database.query(query);
        return positions;
    }
    
    //Used to configure the fields on the search, List and Export Components
    @AuraEnabled
    public static FieldList getFieldList(String ApplicationContext) {
        //create a new FieldList object
        FieldList fl = new FieldList();
        
        //query the Component_FieldList__c object filtering by S Object Name
        fl = OC_OrgChartTopLevelApexControllerHelper.retrieveFieldList(ApplicationContext);
        
        //return the field list
        return fl;
    }
    
    // Retrieve the url for the report from custom settings
    @AuraEnabled
    public static String retrieveReportURL(){
        return OC_OrgChartTopLevelApexControllerHelper.exportAllURL();
    }
    
    public Static Employee getEmployeeRecord(Position__c pos)
    {
        return new Employee(pos,pos.Contacts__r);
    }
    
    //Fetch the Document Url
    @AuraEnabled
    public static String downloadDocument(String docName) {
        return OC_OrgChartTopLevelApexControllerHelper.getJobAidDoc(docName);
    }
    
    //Get the object name coming through the search.
    @AuraEnabled
    public static String getObjectName(String pre) {
       if(pre !='' && pre!=null)
        return OC_OrgChartTopLevelApexControllerHelper.findObjectNameFromRecordIdPrefix(pre);
    	else return null;
    }
    
    //Get the contact object for search
    @AuraEnabled
    public static contact getContactOnSearch(String id) {
        Contact contact;
        try{
            contact = OC_OrgChartTopLevelApexControllerHelper.getContact(id);
        } catch(Exception e) {
            system.debug(e.getMessage());
        }
        return contact;
    }
    
}
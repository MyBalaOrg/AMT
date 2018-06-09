/**
*————————————————————————————————————————————————————
* @Name             ODILR_Case_MainCtrl
* @Author           Duy Tran
* @Created Date     07-05-2017
* @Used By          ODILR_Case_Main.cmp
*————————————————————————————————————————————————————
* @Description
* Controller class to generate and handle DML operations for Case record
* 
*————————————————————————————————————————————————————
* @Changes
*
**/
public with sharing class ODILR_Case_MainCtrl {
    private static Boolean userIsAppAdmin = StaticUtils.userIsSystemAdmin() || StaticUtils.verifyUserPermissionSet(new List<String> {Label.ODILR_Permission_Set_API_App_Admin});
    
    //Wrapper class to hold Case metadata and field values
    public class CaseWrapper {
        public String fieldType {get; set;}
        public String fieldName {get; set;}
        public String fieldLabel {get; set;}
        public String referenceValue {get; set;}
        public String referenceToSObject {get; set;}
        public String helperText {get; set;}
        public Integer maxLength {get; set;}
        public Object fieldValue {get; set;}
        public Boolean accessible {get; set;}
        public Boolean editable {get; set;}
        public Boolean required {get; set;}
        public Boolean dataChanged {get; set;}
        public List<String> picklistValues {get; set;}
        
        public CaseWrapper(Schema.DescribeFieldResult dfr, Case caseData) {
            this.fieldType = String.valueOf(dfr.getType()).toLowerCase();
            this.fieldName = dfr.getName();
            this.fieldLabel = dfr.getLabel();
            if (this.fieldLabel.containsIgnoreCase(' - L2')) {
                this.fieldLabel = this.fieldLabel.removeEndIgnoreCase(' - L2');
            } else if (this.fieldLabel.containsIgnoreCase(' - L3')) {
                this.fieldLabel = this.fieldLabel.removeEndIgnoreCase(' - L3');
            }
            
            this.helperText = dfr.getInlineHelpText();
            if (caseData != null) {
                this.fieldValue = caseData.get(fieldName);
                try {
                    this.referenceValue = String.valueOf(caseData.get(fieldName));
                } catch (Exception e) {
                    System.debug(e.getMessage());
                }
            }
            
            this.accessible = dfr.isAccessible();
            this.editable = dfr.isUpdateable() && dfr.isCreateable();
            this.maxLength = dfr.getLength();
            if (this.fieldType == 'picklist') {
                this.picklistValues = StaticUtils.getPicklistValues(dfr);
            }
            if (dfr.getReferenceTo() != null && !dfr.getReferenceTo().isEmpty()) {
                this.referenceToSObject = String.valueOf(dfr.getReferenceTo().get(0));
            }
            this.dataChanged = false;
        }
    }
    public class CaseSectionWrapper {
        List<CaseWrapper> caseWrappers {get; set;}
        String sectionName {get; set;}
        String sldsFieldSize {get; set;}
        
        public CaseSectionWrapper (String recordTypeName, String sectionName, Case caseData, String sldsFieldSize) {
            caseWrappers = getCaseWrappersForCaseCreation(recordTypeName, sectionName, caseData);
            this.sectionName = sectionName;
            this.sldsFieldSize = sldsFieldSize;
        }
    }
    
    /**
*————————————————————————————————————————————————————
* @Description
* Retrieve a set of data for Case creation
*————————————————————————————————————————————————————
* @param    recordTypeName          Record Type Label
* @return   Map<String, String>     Data to populate lightning component and error messages
*————————————————————————————————————————————————————
**/
    @AuraEnabled
    public static Map<String, String> initializeCaseCreationPage(String recordTypeName) {
        Map<String, String> response = new Map<String, String>();
        
        try {
            List<CaseSectionWrapper> sectionWrappers = new List<CaseSectionWrapper>();
            for (String sectionName : getCaseSectionListTop()) {
                sectionWrappers.add(new CaseSectionWrapper(recordTypeName, sectionName, null, 'slds-size_1-of-4'));
            }
            response.put('sectionWrappers', JSON.serialize(sectionWrappers));
            
            sectionWrappers = new List<CaseSectionWrapper>();
            for (String sectionName : getCaseSectionListBottom()) {
                sectionWrappers.add(new CaseSectionWrapper(recordTypeName, sectionName, null, 'slds-size_1-of-3'));
            }
            response.put('sectionWrappersBottom', JSON.serialize(sectionWrappers));
            
            List<String> tabList = getCaseTabList(recordTypeName);
            List<CaseSectionWrapper> tabsWrappers = new List<CaseSectionWrapper>();
            for (String tabName : tabList) {
                tabsWrappers.add(new CaseSectionWrapper(recordTypeName, tabName, null, 'slds-size_1-of-4'));
            }
            response.put('tabsWrappers', JSON.serialize(tabsWrappers));
            response.put('tabList', JSON.serialize(tabList));
            response.put('selectedTab', tabList[0]);
        } catch (DmlException e) {
            response.put('errorMsg', e.getDmlMessage(0));
        } catch (Exception e) {
            response.put('errorMsg', e.getMessage());
        }
        
        return response;
    }
    
    // Helper method to retrieve case wrapper for a section/tab
    private static List<CaseWrapper> getCaseWrappersForCaseCreation(String recordTypeName, String selectedTab, Case caseData) {
        String fieldNames = (recordTypeName == Label.ODILR_Discipline_Record_Type) ? getDisciplineCaseFields(selectedTab) : getClaimsCaseFields(selectedTab);
        List<CaseWrapper> caseWrappers = getCaseWrapperList(fieldNames.split(' '), caseData);
        return caseWrappers;
    }
    
    /**
*————————————————————————————————————————————————————
* @Description
* Insert new case from custom case creation page
*————————————————————————————————————————————————————
* @param    recordTypeName      Record Type Label
* @param    caseJSON            Case record JSON to be parsed and inserted
* @return   Map<String, String>     Data to populate lightning component and error messages
*————————————————————————————————————————————————————
**/
    @AuraEnabled
    public static Map<String, String> saveNewCaseRecord(String caseJSON) {
        Map<String, String> response = new Map<String, String>();
        try {
            Case newCase = (Case)JSON.deserialize(caseJSON, Case.class);
            insert newCase;
            response.put('recordId', newCase.Id);
        } catch (DmlException e) {
            response.put('errorMsg', e.getDmlMessage(0));
        } catch (Exception e) {
            response.put('errorMsg', e.getMessage());
        }
        return response;
    }
    
    /**
*————————————————————————————————————————————————————
* @Description
* Retrieve a set of data for Case Record
*————————————————————————————————————————————————————
* @param    recordTypeName          Record Type Label
* @return   Map<String, String>     Data to populate lightning component and error messages
*————————————————————————————————————————————————————
**/
    @AuraEnabled
    public static Map<String, String> initializeCaseRecord(String caseId, String recordTypeName) {
        Map<String, String> response = new Map<String, String>();
        
        try {
            if (String.isBlank(recordTypeName)) {
                Case tempCase = [SELECT RecordType.Name FROM Case WHERE Id = :caseId];
                recordTypeName = tempCase.RecordType.Name;
                tempCase = null;
            }
            
            List<String> recordTypes = new List<String>();
            for(RecordTypeInfo info: Case.SObjectType.getDescribe().getRecordTypeInfos()) {
                if (info.isAvailable() && !'Master'.equalsIgnoreCase(info.getName())) {
                    recordTypes.add(info.getName());
                }
            }
            response.put('recordTypeName', recordTypeName);
            response.put('recordTypes', JSON.serialize(recordTypes));
            response.put('disableRecordType', JSON.serialize(!userIsAppAdmin));
                    
            List<String> tabList = getCaseTabList(recordTypeName);
            Case caseData = getCaseDynamicQuery(getCaseFieldsForDynamicQuery(recordTypeName, tabList), caseId);
            
            List<CaseSectionWrapper> sectionWrappers = new List<CaseSectionWrapper>();
            for (String sectionName : getCaseSectionListTop()) {
                sectionWrappers.add(new CaseSectionWrapper(recordTypeName, sectionName, caseData, 'slds-size_1-of-3'));
            }
            response.put('sectionWrappers', JSON.serialize(sectionWrappers));
            
            sectionWrappers = new List<CaseSectionWrapper>();
            for (String sectionName : getCaseSectionListBottom()) {
                sectionWrappers.add(new CaseSectionWrapper(recordTypeName, sectionName, caseData, 'slds-size_1-of-3'));
            }
            response.put('sectionWrappersBottom', JSON.serialize(sectionWrappers));
            
            List<CaseSectionWrapper> tabsWrappers = new List<CaseSectionWrapper>();
            for (String tabName : tabList) {
                tabsWrappers.add(new CaseSectionWrapper(recordTypeName, tabName, caseData, 'slds-size_1-of-3'));
            }
            response.put('tabsWrappers', JSON.serialize(tabsWrappers));
            response.put('tabList', JSON.serialize(tabList));
            response.put('selectedTab', tabList[0]);
        } catch (DmlException e) {
            response.put('errorMsg', e.getDmlMessage(0));
        } catch (Exception e) {
            response.put('errorMsg', e.getMessage());
        }
        
        return response;
    }
    
    /**
*————————————————————————————————————————————————————
* @Description
* Parse the Case record and update
*————————————————————————————————————————————————————
* @param    params                  contains Case JSON for update operation
* @return   Map<String, String>     contains error message if update failed any server side validation
*————————————————————————————————————————————————————
**/
    @AuraEnabled
    public static Map<String, String> saveCaseRecord(String recordTypeName, String caseJSON) {
        Map<String, String> response = new Map<String, String>();
        try {
            Case caseRecord = (Case)JSON.deserialize(caseJSON, Case.class);
            caseRecord.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
            update caseRecord;
            response = initializeCaseRecord(caseRecord.Id, caseRecord.RecordType.Name);
        } catch (DmlException e) {
            response.put('errorMsg', e.getDmlMessage(0));
        } catch (Exception e) {
            response.put('errorMsg', e.getMessage());
        }
        
        return response;
    }
    
    /**
*————————————————————————————————————————————————————
* @Description
* Query for results when user enter search key into TypeaheadSearch components
*————————————————————————————————————————————————————
* @param    searchKey               Key value to match Name value of desired records
* @param    objectName              sObject that the search should be querying from
* @return   Map<String, String>     Contains search result for user to select from
*————————————————————————————————————————————————————
**/
    @AuraEnabled
    public static Map<String, String> getItemsForTypeaheadSearch(String searchKey, String objectName, String fieldName) {
        Map<String, String> response = new Map<String, String>();

        //ARSS204 fetch field describe for selected object
        Map<String, Schema.SObjectField> fieldsDescribe = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
        
        List<StaticUtils.SearchItem> listItems = new List<StaticUtils.SearchItem>();
        List<String> additionalFields = getAdditionalSearchFields(objectName);
        String selectQuery = '', whereQuery = '';
        for (String field : additionalFields) {
            selectQuery += ', ' + field;
            
            //ARSS204 perform search only in string type fields
            if(fieldsDescribe.get(field).getDescribe().getType() == Schema.DisplayType.STRING) {
            	whereQuery += ' OR ' + field + ' LIKE \'%' + String.escapeSingleQuotes(searchKey) + '%\'';
            } /*else {
                whereQuery += ' OR ' + field + ' = \'' + String.escapeSingleQuotes(searchKey) + '\'';
            }*/
        }
        
        String query = 'SELECT Id' + selectQuery; 
        query += ' FROM ' + String.escapeSingleQuotes(objectName) + ' WHERE (' + whereQuery.removeStartIgnoreCase(' OR') + ')';
        //Adding Lookup Filter for certain field
        if (fieldName.equalsIgnoreCase('ODILR_Hearing_Officer__c')) {
            query += ' AND ODILR_Is_Hearing_Officer__c = TRUE ';
        } else if ('ODILR_Advocate__c ODILR_Handler_Second_Level__c ODILR_Handler_Third_Level__c Prep_Writer__c Amtrak_Board_Member__c'.containsIgnoreCase(fieldName)) {
            query += ' AND ODILR_Is_LR_Handler__c = TRUE ';
        }
        query += ' ORDER BY ' + additionalFields[0] + ' ASC LIMIT ' + Limits.getLimitDmlRows();
        
        List<sObject> searchResult = Database.query(query);
        
        for (Integer i = 0; i < searchResult.size(); i++) {
            StaticUtils.SearchItem item = new StaticUtils.SearchItem();
            item.additionalFields = new List<StaticUtils.AdditionalField>();
            item.recordId = String.valueOf(searchResult[i].get('Id'));
            item.label = String.valueOf(searchResult[i].get(additionalFields[0]));
            for (String field : additionalFields) {
                item.searchValue += String.valueOf(searchResult[i].get(field)) + ' ';
                //ARSS204
                item.additionalFields.add(
                    new StaticUtils.AdditionalField(field,
                                                    fieldsDescribe.get(field).getDescribe().getLabel(), 
                                                    String.valueOf(searchResult[i].get(field)))
                );
            }
            listItems.add(item);
        }
        response.put('listItems', JSON.serialize(listItems));
        return response;
    }
    
    /**
*————————————————————————————————————————————————————
* @Description
* Add additional fields for Typeahead Search
*————————————————————————————————————————————————————
* @param    objectName          sObject that the search should be querying from
* @return   List<String>        Contains additional fields to be searched on
*————————————————————————————————————————————————————
**/
    private static List<String> getAdditionalSearchFields(String objectName) {
        List<String> fields = new List<String>();
        if ('Case'.equalsIgnoreCase(objectName)) {
            fields.add('CaseNumber');
        } else {
            fields.add('Name');
        }
        
        if ('Contact'.equalsIgnoreCase(objectName)) {
            fields.add('Personnel_Number_Text__c');
            fields.add('Email');
            fields.add('Personnel_Number__c');
            fields.add('Cost_Center__c');
            fields.add('Position_Title__c');
            fields.add('Department');
        }
        
        return fields;
    }
    
    /**
*————————————————————————————————————————————————————
* @Description
* Retrieve fieldMap from Schema of Case object and gather its metadata to generate CaseWrapper objects
* Only iterate through the fields that were set for the selected tab
* Check for cross object references and retrieve the reference value and its label
*————————————————————————————————————————————————————
* @param    fieldNames              Fields that belong to the selected tab
* @param    caseData                Queried Case record
* @return   List<CaseWrapper>       List of wrapper objects that control the lightning component's content
*————————————————————————————————————————————————————
**/
    public static List<CaseWrapper> getCaseWrapperList(List<String> fieldNames, Case caseData) { 
        Map<String, CaseWrapper> cwMap = new Map<String, CaseWrapper>();
        Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Case.fields.getMap();
        for (String fieldName : fieldNames) {
            if (fieldName.contains('.')) {
                List<String> lookupChain = fieldName.split('\\.');
                if (lookupChain != null && !lookupChain.isEmpty() && caseData != null) {
                    sObject child = caseData.getSobject(lookupChain[0]);
                    for (Integer i = 1; i < lookupChain.size() - 1; i++) {
                        if (child == null) {
                            break;
                        }
                        child = child.getSobject(lookupChain[i]);
                    }
                    if (child != null) {
                        cwMap.get(getFieldNameFromReferenceName(lookupChain[0])).referenceValue = String.valueOf(child.get(lookupChain[lookupChain.size()-1]));
                    }
                }
            } else {
                if (fieldMap.get(fieldName) != null) {
                    cwMap.put(fieldName, new CaseWrapper(fieldMap.get(fieldName).getDescribe(), caseData));
                }
            }
        }
        setAdditionalPropertiesToCaseWrapper(cwMap, caseData);
        List<CaseWrapper> cwList = new List<CaseWrapper>();
        for (String fieldName : fieldNames) {
            if (cwMap.get(fieldName) != null) {
                if (fieldName.endsWithIgnoreCase('id') && 'reference'.equalsIgnoreCase(cwMap.get(fieldName).fieldType)) {
                    String oldLabel = cwMap.get(fieldName).fieldLabel;
                    cwMap.get(fieldName).fieldLabel = oldLabel.removeEndIgnoreCase(' ID');
                }
                cwList.add(cwMap.get(fieldName));
            }
        }
        return cwList;
    }
    
    /**
*————————————————————————————————————————————————————
* @Description
* Helper method to replace reference field value
*————————————————————————————————————————————————————
* @param    refName     Reference field name
* @return   String      Actual field name
*————————————————————————————————————————————————————
**/
    @TestVisible private static String getFieldNameFromReferenceName(String refName) {
        String fieldName = refName + 'id';
        Integer length = refName.length();
        if (refName.indexOf('__r', length - 4) >= 0) {
            fieldName = refName.removeEnd('__r') + '__c';
        }        
        return fieldName;
    }
    
    /**
*————————————————————————————————————————————————————
* @Description
* Set editable and required properties for fields
*————————————————————————————————————————————————————
* @param    cwMap   Map of CaseWrapper and its field name key
* @return   void
*————————————————————————————————————————————————————
**/
    private static void setAdditionalPropertiesToCaseWrapper(Map<String, CaseWrapper> cwMap, Case caseData) {
        // DO NOT REMOVE in case Owner field is added back to the UI
        if (cwMap.get('ownerid') != null) {
            cwMap.get('ownerid').editable = userIsAppAdmin && caseData != null;
            cwMap.get('ownerid').referenceToSObject = 'User';
        }
    }
    
    /**
*————————————————————————————————————————————————————
* @Description
* Retrieve list of tab names
*————————————————————————————————————————————————————
* @param    recordType      Record Type Name of the current Case record
* @return   List<String>    List of available tabs for current Case record
*————————————————————————————————————————————————————
**/
    @TestVisible private static List<String> getCaseTabList(String recordType) {
        List<String> tabList = new List<String>();
        if (recordType == Label.ODILR_Discipline_Record_Type) {
            tabList.add(Label.ODILR_Case_Tab_Label_ODI);
            tabList.add(Label.ODILR_Case_Tab_Label_ODI_Outcome);
        }
        tabList.add(Label.ODILR_Case_Tab_Label_LR2);
        tabList.add(Label.ODILR_Case_Tab_Label_LR3);
        tabList.add(Label.ODILR_Case_Tab_Label_Board);
        return tabList;
    }
    
    @TestVisible private static List<String> getCaseSectionListTop() {
        List<String> sectionList = new List<String>();
        sectionList.add(Label.ODILR_Case_Tab_Label_Detail);
        sectionList.add(Label.ODILR_Case_Tab_Label_Employee_Info);
        return sectionList;
    }
    
    @TestVisible private static List<String> getCaseSectionListBottom() {
        List<String> sectionList = new List<String>();
        sectionList.add(Label.ODILR_Case_Tab_Label_Describe_Offense);
        return sectionList;
    }
    
    /**
*————————————————————————————————————————————————————
* @Description
* Generate the dynamic query String to query the Case record
*————————————————————————————————————————————————————
* @param    fieldNames      List of desired fields from the selected tab
* @param    caseId          Id of the current Case record
* @return   Case            Queried Case result
*————————————————————————————————————————————————————
**/
    private static Case getCaseDynamicQuery(String fieldNames, String caseId) {
        if (String.isBlank(caseId)) return null;
        
        String query = 'SELECT Id,RecordType.DeveloperName,';
        query += fieldNames.replaceAll(' ', ',');
        query += ' FROM Case WHERE Id = \'' + caseId + '\'';
        Case c = Database.query(query);
        return c;
    }
    
    /**
*————————————————————————————————————————————————————
* @Description
* Retrieve all picklist values from a picklist field
*————————————————————————————————————————————————————
* @param    fieldResult     DescribeFieldResult of the desired picklist field
* @return   List<String>    List of String of picklist values
*————————————————————————————————————————————————————
**/
    private static String getCaseFieldsForDynamicQuery(String recordTypeName, List<String> oldTabList) {
        String fieldNames = '';
        Set<String> fieldSet = new Set<String>();
        List<String> tabList = new List<String>();
        tabList.addAll(oldTabList);
        tabList.add(Label.ODILR_Case_Tab_Label_Detail);
        tabList.add(Label.ODILR_Case_Tab_Label_Employee_Info);
        tabList.add(Label.ODILR_Case_Tab_Label_Describe_Offense);
        if (String.valueOf(recordTypeName).equalsIgnoreCase(String.valueOf(Label.ODILR_Discipline_Record_Type))) {
            for (String tabLabel : tabList) {
                fieldSet.addAll(getDisciplineCaseFields(tabLabel).split(' '));
            }
        } else {
            for (String tabLabel : tabList) {
                fieldSet.addAll(getClaimsCaseFields(tabLabel).split(' '));
            }
        }
        for (String field : fieldSet) {
            fieldNames += field + ',';
        }
        return fieldNames.removeEnd(',');
    }
    
    /**
*————————————————————————————————————————————————————
* @Description
* Generate a list of field names based on selected tab of the Claims Case Record Type
* Look up fields should have their reference values placed on the same line for easy organization
*————————————————————————————————————————————————————
* @param    tabLabel        Label of the selected tab
* @return   String          List of field names separated by space
*————————————————————————————————————————————————————
**/
    @TestVisible private static String getClaimsCaseFields(String tabLabel) {
        String fieldNames = ''; 
        if (tabLabel == Label.ODILR_Case_Tab_Label_Detail) {
            fieldNames = 'ParentId Parent.CaseNumber '
                + 'Incident_Date__c '
                + 'Case_Level__c '
                + 'No_Of_Case_Disciplinary_Actions__c '
                + 'No_Of_Case_Agreement_Issues__c '
                + 'Inactive__c '
                + 'Age_of_Case__c '
                //+ 'Description '
                + 'Describe_Offense__c '
                + 'Documentum_Link__c ';
        } else if (tabLabel == Label.ODILR_Case_Tab_Label_Employee_Info) {
            fieldNames = 'ContactId Contact.Name '
                + 'First_Name__c '
                + 'Last_Name__c '
                + 'Is_Group__c '
                + 'SAP_Number__c '
                + 'Job_Title__c '
                + 'Job_Code__c '
                + 'Pay_Rate__c '
                + 'Seniority_Date__c '
                + 'Location__c '
                + 'Union__c Union__r.Name '
                + 'Department__c '
                + 'Personnel_Area__c '
                + 'Organization__c ';
        } else if (tabLabel == Label.ODILR_Case_Tab_Label_Describe_Offense) {
            fieldNames = 'Description '//'Describe_Offense__c '
                + 'Legacy_Information__c Legacy_Information__r.Name '
                + 'ODILR_For_Admin_Use_Only_Admin_1__c '
                + 'ODILR_For_Admin_Use_Only_Admin_2__c '
                + 'ODILR_For_Admin_Use_Only_Admin_3__c '
                + 'LastModifiedById LastModifiedBy.Name '
                + 'LastModifiedDate '
                + 'CreatedById CreatedBy.Name '
                + 'CreatedDate ';
        } else if (tabLabel == Label.ODILR_Case_Tab_Label_LR2) {
            fieldNames = 'ODILR_LR_Office__c '
                + 'ODILR_File_Number_Second_Level__c '
                + 'Appeal_Received_Date_Second_Level__c '
                + 'Response_Due_Date_Second_Level__c '
                + 'Conference_Scheduled_Date__c '
                + 'Decision_Second_Level__c '
                + 'Decision_Date_Second_Level__c '
                + 'ODILR_Handler_Second_Level__c ODILR_Handler_Second_Level__r.Name '
                + 'Claimed__c '
                + 'ODILR_Paid_Second_Level__c '
                + 'Date_Sent_to_LRO__c '
                + 'Fact_Sheet_Sent_To__c '
                + 'Fact_Sheet_Received__c '
                + 'ODILR_Joint_Submission_Requested_Date__c '
                + 'ODILR_Joint_Submission_Sent__c '
                + 'ODILR_Joint_Submission_Accepted_Rejected__c '
                + 'ODILR_Joint_Submission_Req_Received_Date__c '
                + 'ODILR_Proposed_Facts_Rejected_Date__c '
                + 'ODILR_Revised_Proposed_Facts_Sent_Date__c '
                + 'ODILR_Revised_Proposed_Facts_Accepted_Dt__c '
                + 'ODILR_Revised_Proposed_Facts_Rejected_Dt__c '
                + 'ODILR_Parties_JtSubmission_Completion_Dt__c '
                + 'ODILR_Union_Ex_Part_Received_Date__c '
                + 'ODILR_Company_Ex_Parte_Completion_Date__c '
                + 'ODILR_Company_Ex_Parte_Sent_Date__c '
                + 'Union_File_Number__c '
                + 'Date_Sent_to_Third_Level__c '
                + 'ODILR_Abeyance_Lead_Case_Second_Level__c '
                + 'Comments_Second_Level__c '
                + 'ODILR_Documentum_Upload_Second_Level__c ';
        } else if (tabLabel == Label.ODILR_Case_Tab_Label_LR3) {
            fieldNames = 'ODILR_File_Number_Third_Level__c '
                + 'ODILR_Paid_Third_Level__c '
                + 'ODILR_Not_Paid_Third_Level__c '
                + 'Appeal_Received_Date_Third_Level__c '
                + 'Date_Of_Conference__c '
                + 'Response_Due_Date_Third_Level__c '
                + 'Decision_Third_Level__c '
                + 'Decision_Date_Third_Level__c '
                + 'ODILR_Handler_Third_Level__c ODILR_Handler_Third_Level__r.Name '
                + 'ODILR_Abeyance_Lead_Case_Third_Level__c '
                + 'Comments_Third_Level__c '
                + 'ODILR_Documentum_Upload_Third_Level__c ';
        } else if (tabLabel == Label.ODILR_Case_Tab_Label_Board) {
            fieldNames = 'Date_Appealed_Board__c '
                + 'Date_Listed__c '
                + 'Date_Referee_Assigned__c '
                + 'Board_Number__c '
                + 'Board_Level_Case_Number__c '
                + 'Docket_Number__c '
                + 'Award_Number__c '
                + 'Award_Date__c '
                + 'Referee__c '
                + 'Prep_Writer__c Prep_Writer__r.Name '
                + 'Prep_Due_Date__c '
                + 'Prep_Written_Date__c '
                + 'Prep_Type__c '
                + 'ODILR_Advocate__c ODILR_Advocate__r.Name '
                + 'Hearing_Date_Board_Level__c '
                + 'Amtrak_Board_Member__c Amtrak_Board_Member__r.Name '
                + 'Decision_Board_Level__c '
                + 'Entered_Date__c '
                + 'Continuing_Liability_Date__c '
                + 'Monthly_Liability__c '
                + 'ODILR_Paid_Board_Level__c '
                + 'ODILR_Not_Paid_Board_Level__c '
                + 'Index_Codes__c '
                + 'Estimated_Liability__c '
                + 'ODILR_Abeyance_Lead_Case_Board_Level__c '
                + 'Comments_Board_Level__c '
                + 'ODILR_Documentum_Upload_Board_Level__c ';
        }
        
        return fieldNames.toLowerCase().trim();
    }
    
    /**
*————————————————————————————————————————————————————
* @Description
* Generate a list of field names based on selected tab of the Discipline Case Record Type
* Look up fields should have their reference values placed on the same line for easy organization
*————————————————————————————————————————————————————
* @param    tabLabel        Label of the selected tab
* @return   String          List of field names separated by space
*————————————————————————————————————————————————————
**/
    @TestVisible private static String getDisciplineCaseFields(String tabLabel) {
        String fieldNames = ''; 
        if (tabLabel == Label.ODILR_Case_Tab_Label_Detail) {
            fieldNames = 'ODILR_ODI_Number__c '
                + 'ParentId Parent.CaseNumber '
                + 'Incident_Date__c '
                + 'Charge_Date__c '
                + 'Case_Level__c '
                + 'No_Of_Case_Disciplinary_Actions__c '
                + 'No_Of_Case_Violations__c '
                + 'Inactive__c '
                + 'Age_of_Case__c '
                //+ 'Description '
                + 'Describe_Offense__c '
                + 'Documentum_Link__c ';
        } else if (tabLabel == Label.ODILR_Case_Tab_Label_Employee_Info) {
            fieldNames = 'ContactId Contact.Name '
                + 'First_Name__c '
                + 'Last_Name__c '
                + 'Is_Group__c '
                + 'SAP_Number__c '
                + 'Job_Title__c '
                + 'Job_Code__c '
                + 'Pay_Rate__c '
                + 'Seniority_Date__c '
                + 'Location__c '
                + 'Union__c Union__r.Name '
                + 'Division__c '
                + 'Department__c '
                + 'Personnel_Area__c '
                + 'Organization__c ';
        } else if (tabLabel == Label.ODILR_Case_Tab_Label_Describe_Offense) {
            fieldNames = 'Description ' //'Describe_Offense__c '
                + 'Legacy_Information__c Legacy_Information__r.Name '
                + 'ODILR_For_Admin_Use_Only_Admin_1__c '
                + 'ODILR_For_Admin_Use_Only_Admin_2__c '
                + 'ODILR_For_Admin_Use_Only_Admin_3__c '
                + 'LastModifiedById LastModifiedBy.Name '
                + 'LastModifiedDate '
                + 'CreatedById CreatedBy.Name '
                + 'CreatedDate ';
        } else if (tabLabel == Label.ODILR_Case_Tab_Label_ODI) {
            fieldNames = 'ODILR_ODI_Office__c '
                + 'Close_Date__c '
                + 'Management_First_Known__c '
                + 'Status '
                + 'Out_of_Service__c '
                + 'Out_of_Service_Date__c '
                + 'Hearing_Date__c '
                + 'ODILR_Charging_Officer_ODI__c ODILR_Charging_Officer_ODI__r.Name '
                + 'ODILR_Hearing_Officer__c ODILR_Hearing_Officer__r.Name '
                + 'Open_Recess_Date__c '
                + 'ODILR_Proposed_Hearing_Date_Details__c '
                + 'Notice_Of_Intent_Meeting_Date__c '
                + 'Case_Notes__c ';
        } else if (tabLabel == Label.ODILR_Case_Tab_Label_ODI_Outcome) {
            fieldNames = 'Outcome__c '
                + 'Outcome_Date__c '
                + 'Rule_G_Waiver__c '
                + 'Decision__c '
                + 'Decertification__c '
                + 'Decertification_Date__c ';
        } else if (tabLabel == Label.ODILR_Case_Tab_Label_LR2) {
            fieldNames = 'ODILR_LR_Office__c '
                + 'ODILR_File_Number_Second_Level__c '
                + 'Appeal_Received_Date_Second_Level__c '
                + 'Response_Due_Date_Second_Level__c '
                + 'Conference_Scheduled_Date__c '
                + 'Decision_Second_Level__c '
                + 'Decision_Date_Second_Level__c '
                + 'ODILR_Handler_Second_Level__c ODILR_Handler_Second_Level__r.Name '
                + 'ODILR_Not_Paid_Second_Level__c '
                + 'ODILR_Paid_Second_Level__c '
                + 'Date_Sent_to_LRO__c '
                + 'Union_File_Number__c '
                + 'Date_Sent_to_Third_Level__c '
                + 'ODILR_Abeyance_Lead_Case_Second_Level__c '
                + 'Comments_Second_Level__c '
                + 'ODILR_Documentum_Upload_Second_Level__c ';
        } else if (tabLabel == Label.ODILR_Case_Tab_Label_LR3) {
            fieldNames = 'ODILR_File_Number_Third_Level__c '
                + 'ODILR_Paid_Third_Level__c '
                + 'ODILR_Not_Paid_Third_Level__c '
                + 'Appeal_Received_Date_Third_Level__c '
                + 'Date_Of_Conference__c '
                + 'Response_Due_Date_Third_Level__c '
                + 'Decision_Third_Level__c '
                + 'Decision_Date_Third_Level__c '
                + 'ODILR_Handler_Third_Level__c ODILR_Handler_Third_Level__r.Name '
                + 'ODILR_Abeyance_Lead_Case_Third_Level__c '
                + 'Comments_Third_Level__c '
                + 'ODILR_Documentum_Upload_Third_Level__c ';
        } else if (tabLabel == Label.ODILR_Case_Tab_Label_Board) {
            fieldNames = 'Date_Appealed_Board__c '
                + 'Date_Listed__c '
                + 'Date_Referee_Assigned__c '
                + 'Board_Number__c '
                + 'Board_Level_Case_Number__c '
                + 'Docket_Number__c '
                + 'Award_Number__c '
                + 'Award_Date__c '
                + 'Referee__c '
                + 'Prep_Writer__c Prep_Writer__r.Name '
                + 'Prep_Due_Date__c '
                + 'Prep_Written_Date__c '
                + 'Prep_Type__c '
                + 'ODILR_Advocate__c ODILR_Advocate__r.Name '
                + 'Hearing_Date_Board_Level__c '
                + 'Amtrak_Board_Member__c Amtrak_Board_Member__r.Name '
                + 'Decision_Board_Level__c '
                + 'Entered_Date__c '
                + 'Continuing_Liability_Date__c '
                + 'Monthly_Liability__c '
                + 'ODILR_Paid_Board_Level__c '
                + 'ODILR_Not_Paid_Board_Level__c '
                + 'Index_Codes__c '
                + 'Estimated_Liability__c '
                + 'ODILR_Abeyance_Lead_Case_Board_Level__c '
                + 'Comments_Board_Level__c '
                + 'ODILR_Documentum_Upload_Board_Level__c ';
        }
        
        return fieldNames.toLowerCase().trim();
    }
    
}
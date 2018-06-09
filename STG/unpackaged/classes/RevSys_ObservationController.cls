/**
*___________________________________________________
*@Name: RevSys_ObservationController
*@Author: Boom Bertetti
*@Created: Date: 2/05/2018
*@Used_By: RevSys_ObservationFormController and RevSys_ObservationMainController
*___________________________________________________
*@Description: 
* Controller for all the custom SPARTN Observation Lightning pages.
*___________________________________________________
*@Changes: 
* 5-29-2018 [Boom Bertetti] Updated to accomodate ETR-1231
**/
public with sharing class RevSys_ObservationController {

    @AuraEnabled
    public static Map<String, String> initPage(Map<String, String> params) {
        Map<String, String> response = new Map<String, String>();
        Map<String, String> fieldLabelMap = new Map<String, String>();
        Map<String, List<String>> picklistMap = new Map<String, List<String>>();
        Map<String, String> responseMap = new Map<String, String>();

        try {
            if (params.get('targetPage') != null) {
                String targetPage = params.get('targetPage');
                if (targetPage == 'recordDetail') {
                    responseMap = getRecordDetailResponseMap(params);
                }
                else if (targetPage == 'obsTab') {
                    responseMap = getSelectFormResponseMap(params);
                }
            }
            for (String rKey : responseMap.keySet()) {
                response.put(rKey, responseMap.get(rKey));  
            }

            for (Schema.SObjectField field : Schema.getGlobalDescribe().get('Observation__c').getDescribe().Fields.getMap().values()) {    

                fieldLabelMap.put(field.getDescribe().getName(), field.getDescribe().getLabel()); 

                String fieldType = String.valueOf(field.getDescribe().getType());
                if (fieldType.equalsIgnoreCase('picklist')) {
                    picklistMap.put(field.getDescribe().getName(), StaticUtils.getPicklistValues(field.getDescribe()));
                }
            }
            response.put('picklistMap', JSON.serialize(picklistMap));
            response.put('fieldLabelMap', JSON.serialize(fieldLabelMap));
            response.put('readOnlyFields', JSON.serialize( LightningFieldSetHandler.getFields('Observation__c', 'SPARTN_EmployeeInformation')));
            Map<String, List<String>> picklistMapRegionState = StaticUtils.getDependentOptionsImpl(Observation__c.State__c.getDescribe().getSObjectField(),
                                                                                                   Observation__c.RegionProperty__c.getDescribe().getSObjectField());
            
            response.put('picklistMapRegionState', JSON.serialize(picklistMapRegionState));
            
            Map<String, List<String>> picklistMapMovementPosting = StaticUtils.getDependentOptionsImpl(Observation__c.SectionTower__c.getDescribe().getSObjectField(),
                                                                                                   Observation__c.MovementOffice__c.getDescribe().getSObjectField());
            
            response.put('picklistMapMovementPosting', JSON.serialize(picklistMapMovementPosting));
            
            Map<String, List<String>> picklistMapFormTypeDivision = StaticUtils.getDependentOptionsImpl(Observation__c.RegionProperty__c.getDescribe().getSObjectField(),
                                                                                                   Observation__c.FormType__c.getDescribe().getSObjectField());
            
            response.put('picklistMapFormTypeDivision', JSON.serialize(picklistMapFormTypeDivision));
            
            Map<String, List<String>> picklistMapStateSubDivision = StaticUtils.getDependentOptionsImpl(Observation__c.Subdivision__c.getDescribe().getSObjectField(),
                                                                                                   Observation__c.State__c.getDescribe().getSObjectField());

            system.debug('picklistMapStateSubDivision from StaticUtils ' + picklistMapStateSubDivision); 
            
            response.put('picklistMapStateSubDivision', JSON.serialize(picklistMapStateSubDivision));
            
            //Get the allowed permission set for updating observation after 48 hours of evaluation date
            Map<String, String> targetAdminPermissionMap = RevSys_GenericUtility.getAllowedPermissionSet('Enable Observation Soft Delete');
            response.putAll(targetAdminPermissionMap);
            
        } catch (Exception e) {
            response.put('errorMsg', e.getMessage());
            response.put('consolelog', e.getStackTraceString());
            System.debug(e.getStackTraceString());
            System.debug(e.getMessage());
       }
        
        return response;
    }

    @AuraEnabled
    public static Map<String, String> getItemsForTypeaheadSearch(String searchKey, String objectName, List<String> fieldsToSearchList) {
        Map<String, String> response = new Map<String, String>();
        
        List<StaticUtils.SearchItem> listItems = new List<StaticUtils.SearchItem>();
        String selectQuery = '', whereQuery = '';

        for (String field : fieldsToSearchList) {
            selectQuery += ', ' + field;
            whereQuery += ' OR ' + field + ' LIKE \'%' + String.escapeSingleQuotes(searchKey) + '%\'';
        }
        
        String query = 'SELECT Id' + selectQuery; 
        query += ' FROM ' + String.escapeSingleQuotes(objectName) + ' WHERE (' + whereQuery.removeStartIgnoreCase(' OR') + ')';

        query += ' ORDER BY ' + fieldsToSearchList[0] + ' ASC LIMIT ' + Limits.getLimitDmlRows();
        
        List<sObject> searchResult = Database.query(query);
        
        for (Integer i = 0; i < searchResult.size(); i++) {
            StaticUtils.SearchItem item = new StaticUtils.SearchItem();
            item.recordId = String.valueOf(searchResult[i].get('Id'));
            item.label = String.valueOf(searchResult[i].get(fieldsToSearchList[0]));
            for (String field : fieldsToSearchList) {
                if (!field.contains('__r')) {
                    item.searchValue += String.valueOf(searchResult[i].get(field)) + ' ';
                }
            }
            listItems.add(item);
        }
        response.put('listItems', JSON.serialize(listItems));
        return response;
    }  

    @AuraEnabled
    public static Map<String, String> insertNon1872(Map<String, String> params) {
        Map<String, String> response = new Map<String, String>();
        Savepoint sp = Database.setSavepoint();
        try {
            String rtName = params.get('rtName');

            Observation__c observation = (Observation__c)JSON.deserialize(params.get('observationJSON'), Observation__c.class);  
            
            system.debug('*** observation : ' + observation);

            if(observation.RecordTypeId == RevSys_StaticUtility.OBSERVATION_TEST1876_RECTYPE_ID){
                List<EmployeeCertification__c> empCertList = new List<EmployeeCertification__c>();
                SelectorWrapper wrapper = EmployeeCertificationSelector.getEmpCertByEmpId(observation.Employee__c);
                empCertList = (List<EmployeeCertification__c>)wrapper.SObjectList; 
                if(!empCertList.isEmpty()){
                    observation.OjtStartDate__c  = empCertList.get(0).LastCertificationDate__c;
                }
            }else if(observation.RecordTypeId == RevSys_StaticUtility.OBSERVATION_TEST1878_RECTYPE_ID){
                observation.OjtStartDate__c = [select OnTheJobTrainingStartDate__c from Contact where Id =: observation.Employee__c limit 1].OnTheJobTrainingStartDate__c;
            }
            
            insert observation;

            Map<String, List<Finding__c>> findingsByRecordTypes = getTestQuestionMap();
            List<Finding__c> observationFindings = findingsByRecordTypes.get(rtName);

            for (Finding__c finding : observationFindings) {
                finding.Observation__c = observation.Id;
            }
            insert observationFindings;
            System.debug('observation id from controller: ' + observation.Id);
            response.put('observation', JSON.serialize(observation));                                   
            response.put('findings', JSON.serialize(observationFindings));   

        } catch (DmlException e) {
            String errorMsg = '';
            for (Integer i = 0; i < e.getNumDml(); i++) {
                errorMsg += e.getDmlMessage(i) + '. ';
                System.debug('----------- Record Id: ' + e.getDmlId(i));
                System.debug(e.getDmlFieldNames(i));
                System.debug(e.getDmlMessage(i));
            }
            response.put('errorMsg', errorMsg);
            response.put('consolelog', e.getStackTraceString());
            System.debug(e.getStackTraceString());
        } catch (Exception e) {
            Database.rollback(sp);
            response.put('errorMsg', e.getMessage());
            response.put('consolelog', e.getStackTraceString());
            System.debug(e.getStackTraceString());
        }
        
        System.debug('AURAENABLED RevSys_ObservationFormController.insertNon1872() END');
        return response;
    }

    @AuraEnabled
    public static Map<String, String> updateObservation(Map<String, String> params) {
        Map<String, String> response = new Map<String, String>();
        Map <String, String> resMap = new Map <String, String>();
        Map<String,String> resEmpSummMap = new Map <String, String>();
		List<EmployeeResultSummary__c> resEmpSummList = new List<EmployeeResultSummary__c>();
        
        Savepoint sp = Database.setSavepoint();
        try {
            String rtName = params.get('rtName');

            List<Finding__c> findingList = (List<Finding__c>)JSON.deserialize(params.get('findingListJSON'), List<Finding__c>.class);
            update findingList;
            
            Observation__c observation = (Observation__c)JSON.deserialize(params.get('observationJSON'), Observation__c.class);  

            
            // Create a placeholder observation to save the reference fields values
            Observation__c placeholderObs = new Observation__c();
            placeholderObs.OperatedFromCode__r = observation.OperatedFromCode__r;
            placeholderObs.OperatedToCode__r = observation.OperatedToCode__r;
            placeholderObs.Nearest_Station_Interlocking__r = observation.Nearest_Station_Interlocking__r;
            placeholderObs.Train__r = observation.Train__r;

            // Null out all the reference fields (__r) to prevent error below
            // "Cannot specify both an external ID reference OperatedToCode__r and a salesforce id, OperatedToCode__c."
            observation.OperatedFromCode__r = null;
            observation.OperatedToCode__r = null;
            observation.Nearest_Station_Interlocking__r = null;
            observation.Train__r = null;
            observation.Status__c = 'Submitted';
            system.debug('## observation : ' + observation);
            update observation;
            
            // Put the reference field value back to the observation before we put it back to the response.
            // This will keep the lookup values to show up on the page after refresh the page.
            observation.OperatedFromCode__r = placeholderObs.OperatedFromCode__r;
            observation.OperatedToCode__r = placeholderObs.OperatedToCode__r;
            observation.Nearest_Station_Interlocking__r = placeholderObs.Nearest_Station_Interlocking__r;
            observation.Train__r = placeholderObs.Train__r;

            //List<Observation__c> obsList  = new List<Observation__c>(Observation); 
            System.debug('observation.Id$$'+observation.Id);
            if(observation!=null){            
                resMap = getTotalTestTaken(observation.Id, rtName);             
            }
            System.debug('resmap$$'+resMap);
            System.debug('AURAENABLED RevSys_ObservationFormController.insertNon1872() END');
            
            //Get Employee Summary records
             if(observation!=null){            
                 //resEmpSummMap = getEmploymentSummaryRecords(observation.Id);               
                 resEmpSummList = getEmploymentSummaryRecords(observation.Id);               
            }
            System.debug('resmap$$'+resMap);
            String obNumber = [SELECT Name FROM Observation__c WHERE Id = :observation.Id Limit 1].Name;

            response.put('findingList', JSON.serialize(findingList));      
            response.put('observation', JSON.serialize(observation)); 
            response.put('totalTests', JSON.serialize(resMap)); 
            //response.put('resEmpSummMap', JSON.serialize(resEmpSummMap)); 
            response.put('resEmpSummList', JSON.serialize(resEmpSummList)); 
            response.put('observationNumber', obNumber);
            
        } catch (DmlException e) {
            String errorMsg = '';
            for (Integer i = 0; i < e.getNumDml(); i++) {
                errorMsg += e.getDmlMessage(i) + '. ';
                System.debug('----------- Record Id: ' + e.getDmlId(i));
                System.debug(e.getDmlFieldNames(i));
                System.debug(e.getDmlMessage(i));
            }
            response.put('errorMsg', errorMsg);
            response.put('consolelog', e.getStackTraceString());
            System.debug(e.getStackTraceString());
        } catch (Exception e) {
            Database.rollback(sp);
            response.put('errorMsg', e.getMessage());
            response.put('consolelog', e.getStackTraceString());
            System.debug(e.getStackTraceString());
        }
        
        System.debug('AURAENABLED RevSys_ObservationFormController.updateObtest() END');
        return response;
    }

    @AuraEnabled
    public static Map<String, String> saveObservation(Map<String, String> params) {
        Map<String, String> response = new Map<String, String>();
        Savepoint sp = Database.setSavepoint();
        try {
        //    List<Finding__c> findingList = (List<Finding__c>)JSON.deserialize(params.get('findingsJSON'), List<Finding__c>.class);   
        //    update findingList;    

            Observation__c observation = (Observation__c)JSON.deserialize(params.get('observationJSON'), Observation__c.class);            
            update observation;

            response.put('observation', JSON.serialize(observation));                                   
        //    response.put('findingList', JSON.serialize(findingList));                                   
        } catch (DmlException e) {
            String errorMsg = '';
            for (Integer i = 0; i < e.getNumDml(); i++) {
                errorMsg += e.getDmlMessage(i) + '. ';
                System.debug('----------- Record Id: ' + e.getDmlId(i));
                System.debug(e.getDmlFieldNames(i));
                System.debug(e.getDmlMessage(i));
            }
            response.put('errorMsg', errorMsg);
            response.put('consolelog', e.getStackTraceString());
            System.debug(e.getStackTraceString());
        } catch (Exception e) {
            Database.rollback(sp);
            response.put('errorMsg', e.getMessage());
            response.put('consolelog', e.getStackTraceString());
            System.debug(e.getStackTraceString());
        }
        
        System.debug('AURAENABLED RevSys_ObservationFormController.saveObservation() END');
        return response;
    }

    /**
    *————————————————————————————————————————————————————
    * @Name: searchForEmployee
    * @Description
    * Search and populate wrapper object with employee information
    *————————————————————————————————————————————————————
    * @param    params                  Map of values retrieved from Lightning Component
    * @return   Map<String, String>     Map of response values to be used by Lightning Component
    *————————————————————————————————————————————————————
    **/ 
    @AuraEnabled
    public static Map<String, String> searchForEmployee(Map<String, String> params) {
        System.debug('AURAENABLED RevSys_ObservationController.searchForEmployee() START');
        Map<String, String> response = new Map<String, String>();
        system.debug('params$$$'+params);
        try {
            String desiredFields = String.valueOf(REVSYS_Custom_Settings__c.getValues('Obs Search Employee Field Names').CSV_String__c);
            String fieldsToQuery = String.valueOf(REVSYS_Custom_Settings__c.getValues('Obs Search Employee SOQL Fields').CSV_String__c);
            String fieldsToDisplay = String.valueOf(REVSYS_Custom_Settings__c.getValues('Obs Search Employee Display Columns').CSV_String__c);
            RecordType rt = (RecordType)JSON.deserialize(params.get('recordType'), RecordType.class);
            String whereClause = '';
            // ETR-1198
            String filterLogic;

            // Setting up conditional statement for form that will be filtered by current Employee Certification
            if (REVSYS_Custom_Settings__c.getValues('Observation ' + rt.Name + ' Certification') != null) {
                String certType = REVSYS_Custom_Settings__c.getValues('Observation ' + rt.Name + ' Certification').CSV_String__c;
                
                whereClause += ' AND Id IN (SELECT Employee__c FROM EmployeeCertification__c ';
               // whereClause += ' WHERE Status__c = \'' + Label.RevSys_Employee_Certification_Status_Current + '\'';
                whereClause += ' WHERE CertificationType__c = \'' + certType + '\')';
            }

            // ETR-1198
            // Setting up conditional statement for form that will be filtered by class of service
            if (REVSYS_Custom_Settings__c.getValues('Observation ' + rt.Name + ' Class of Service') != null) {
                String cos = REVSYS_Custom_Settings__c.getValues('Observation ' + rt.Name + ' Class of Service').CSV_String__c;
                if (!String.isBlank(cos)) {
                    List<String> cosList = cos.split(',');
                    whereClause += ' AND ClassOfService__c IN :cosList';
                }
            }

            // Setting up conditional statement for Name
            if (String.isNotBlank(params.get('searchKey'))) {
                String searchKey = String.escapeSingleQuotes(params.get('searchKey'));
                for (String keyWord : searchKey.split(' ')) {
                    whereClause += ' AND (Name LIKE \'%' + keyWord + '%\' OR Personnel_ID__c LIKE \'%' + keyWord + '%\')';
                }
            }
            // Get the where clause for Department and Craft
            if (String.isNotBlank(params.get('filterMap'))) {
                Map<String, String> filterMap = (Map<String, String>)JSON.deserialize(params.get('filterMap'), Map<String, String>.class);
                System.debug('filtermap: ' + filtermap);
                if (String.isNotBlank(filterMap.get('Department'))) {
                    String departmentFilter = filterMap.get('Department');
                    whereClause += ' AND (Department = \'' + departmentFilter + '\'';
                    whereClause += ' OR Dept_Code_Desc__c = \'' + departmentFilter + '\')';
                }
                if (String.isNotBlank(filterMap.get('Craft'))) {
                    String craftFilter = filterMap.get('Craft');
                    
                    list<String> craftFilterStringList = null;
                    list<String> craftFilterStrList = new list<String>();
                    craftFilterStringList = craftFilter.split(',');
                    System.debug('*** craftFilterStringList : ' + craftFilterStringList);
                    if(craftFilterStringList != null){
                        for(String craftFilterStr : craftFilterStringList){
                            craftFilterStrList.add('\'' + craftFilterStr + '\'');
                        }
                        craftFilter = String.join(craftFilterStrList,',');
                    }
                    
                    // ETR-1198
                    // Setting up filter logic 
                    if (REVSYS_Custom_Settings__c.getValues('Observation ' + rt.Name + ' Filter Logic') != null) {
                        filterLogic = REVSYS_Custom_Settings__c.getValues('Observation ' + rt.Name + ' Filter Logic').CSV_String__c;
                        if (!String.isBlank(filterLogic)) {
                            whereClause += ' ' + filterLogic + ' (Craft__c In (' + craftFilter + '))';
                        }
                        else {
                            whereClause += ' AND (Craft__c In (' + craftFilter + '))';
                        }
                    } else {
                        whereClause += ' AND (Craft__c In (' + craftFilter + '))';
                    }
                }

            }
            System.debug('=====> whereClause: ' + whereClause);
            whereClause = whereClause.removeStart(' AND');
            if (String.isNotBlank(whereClause)) {
                whereClause += ' AND';
            }
            
            String query = 'SELECT Id,' + fieldsToQuery + ' FROM Contact';
            if (String.isNotBlank(whereClause)) {
                query += ' WHERE ' + whereClause.removeEnd(' AND');
            }
            query += ' ORDER BY Name, Department, Craft__c LIMIT 500';
            System.debug('search query : ' + query);
            
            List<Contact> empList = Database.query(query);
            if (empList != null && empList.size() >= 500) {
                response.put('limitBreak', 'There are over 500 results returned. Please make your search more specific for better results.');
            }
            system.debug('*** empList : ' + empList);
            List<SearchTabularItemWrapper> resultList = new List<SearchTabularItemWrapper>();
            for (Contact emp : empList) {
                SearchTabularItemWrapper item = new SearchTabularItemWrapper();
                item.selected = false;
                item.recordId = emp.Id;
                item.fieldNames = fieldsToDisplay.split(',');
                item.fieldValues = new List<String>();
                item.additionalFieldandValueMap = new Map<String, String>();
                if (fieldsToDisplay.contains('Name')) {
                    item.theName = emp.Name;
                }
                if (fieldsToDisplay.contains('Personnel_ID__c') || fieldsToDisplay.contains('Employee_ID__c')) {
                    item.theNumber = String.isNotBlank(emp.Personnel_ID__c) ? emp.Personnel_ID__c : emp.Employee_ID__c;
                }
                if (fieldsToDisplay.contains('Department')) {
                    item.department = String.isNotBlank(emp.Department) ? emp.Department : emp.Dept_Code_Desc__c;
                }
                if (fieldsToDisplay.contains('Craft__c')) {
                    //item.craft = String.isNotBlank(emp.Craft_Code_Desc__c) ? emp.Craft_Code_Desc__c : emp.Craft__c;
                    item.craft = emp.Craft__c;
                }
                for (String fieldName : item.fieldNames) {
                    if (fieldName == 'Personnel_ID__c') {
                        item.fieldValues.add(item.theNumber);
                    }
                    else if (fieldName == 'Department') {
                        item.fieldValues.add(item.department);
                    }
                    else if (fieldName == 'Craft__c') {
                        item.fieldValues.add(item.craft);
                    }
                    else {
                        item.fieldValues.add(String.valueOf(emp.get(fieldName)));
                    }

                    if (fieldName == 'Division__c') {
                        item.additionalFieldandValueMap.put('Division__c', String.valueOf(emp.get(fieldName)));
                    }
                    if (fieldName == 'Region__c') {
                        item.additionalFieldandValueMap.put('Region__c', String.valueOf(emp.get(fieldName)));
                    }
                    if (fieldName == 'Occupation__c') {
                        item.additionalFieldandValueMap.put('Occupation__c', String.valueOf(emp.get(fieldName)));
                    }
                //    if (fieldName == 'Supervisor__c') {
                //        item.additionalFieldandValueMap.put('Supervisor__c', String.valueOf(emp.get(fieldName)));
                //    }
                }
                resultList.add(item);
            }
            response.put('resultList', JSON.serialize(resultList));
            response.put('fieldLabels', JSON.serialize(getContactFieldLabels(fieldsToDisplay)));
        } catch(QueryException qe) {

            response.put('errorMsg', qe.getMessage());
            response.put('consolelog', qe.getStackTraceString());
            System.debug(qe.getStackTraceString());
            System.debug('Error query: ' + qe.getMessage());
        } catch (Exception e) {
            response.put('errorMsg', e.getMessage());
            response.put('consolelog', e.getStackTraceString());
            System.debug(e.getStackTraceString());
            System.debug(e.getLineNumber() + ', ' + e.getMessage());
        }
        
        System.debug('AURAENABLED RevSys_ObservationController.searchForEmployee() END');
        return response;
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Name: loadTestSelection
    * @Description
    * Query for Tests based on selected employee departments and crafts
    *————————————————————————————————————————————————————
    * @param    params                  Map of values retrieved from Lightning Component
    * @return   Map<String, String>     Map of response values to be used by Lightning Component
    *————————————————————————————————————————————————————
    **/    
    @AuraEnabled
    public static Map<String, String> loadTestSelection(Map<String, String> params) {
        System.debug('AURAENABLED RevSys_ObservationController.loadTestSelection() START');
        Map<String, String> response = new Map<String, String>();
        List<String> fraTestsList = new List<String>();
        if (REVSYS_Custom_Settings__c.getValues('Obs Form-1872 Efficiency Test Numbers') != null) {
            String fraTests = String.valueOf(REVSYS_Custom_Settings__c.getValues('Obs Form-1872 Efficiency Test Numbers').CSV_String__c);
            fraTestsList = fraTests.split(',');
        }
 
        try {
            Set<String> departmentSet = new Set<String>();
            Map<String, List<SearchTabularItemWrapper>> employeeByDeptCraft = new Map<String, List<SearchTabularItemWrapper>>();
             system.debug('*** params BEFORE :: ' + params);
             system.debug('*** selectedEmployees BEFORE :: ' + params.get('selectedEmployees'));
            if (String.isNotBlank(params.get('selectedEmployees'))) {
                List<SearchTabularItemWrapper> selectedEmployees = (List<SearchTabularItemWrapper>)JSON.deserialize(params.get('selectedEmployees'), List<SearchTabularItemWrapper>.class);
                system.debug('*** selectedEmployees :: ' + selectedEmployees);
                for (SearchTabularItemWrapper employee : selectedEmployees) {
                    string deptCraft = employee.department + '-' + employee.craft;
                    if (!employeeByDeptCraft.containsKey(deptCraft)) {
                        employeeByDeptCraft.put(deptCraft, new List<SearchTabularItemWrapper>());
                    }
                    if(!departmentSet.contains(employee.department)){
                        departmentSet.add(employee.department);    
                    }
                    employeeByDeptCraft.get(deptCraft).add(employee);
                }
                
                system.debug('*** employeeByDeptCraft : ' + employeeByDeptCraft);
            }

            Map<String, String> testMapbyNumber = new Map<String, String>();
            List<RevSys_TestWithObservationsWrapper> testWithObservationsList = new List<RevSys_TestWithObservationsWrapper>();
            Map<String, List<RevSys_TestEntryWrapper>> testEntryByTestMap = new Map<String, List<RevSys_TestEntryWrapper>>();
            
            system.debug('*** departmentSet :: ' + departmentSet);
            // ===== START long process
            for (OccupationSpecificRequirement__c osr : [SELECT Id, ObservationDepartment2__c, ObservationCraft2__c, 
                                                                Observation__r.TestNumber__c, Observation__r.TestName__c, 
                                                                Observation__r.SpeedCheckMethod__c, Observation__r.Check_Method_Required__c
                                                         FROM OccupationSpecificRequirement__c 
                                                         WHERE RecordTypeId = :RevSys_StaticUtility.OCCSPECREQUIREMENT_DEPTCERT_FOR_OBS_RECTYPE_ID 
                                                         AND Status__c = :Label.RevSys_Generic_Status_Active
                                                         AND ObservationDepartment2__c IN :departmentSet
                                                         AND Observation__r.TestNumber__c != null
                                                         AND Observation__r.Status__c = :Label.RevSys_Generic_Status_Active
                                                         ORDER BY Observation__r.TestNumber__c]) {
                testMapbyNumber.put(osr.Observation__r.TestNumber__c, osr.Observation__r.TestName__c);
                String deptCraft = osr.ObservationDepartment2__c + '-' + osr.ObservationCraft2__c;
                if (!testEntryByTestMap.containsKey(osr.Observation__r.TestNumber__c)) {
                    testEntryByTestMap.put(osr.Observation__r.TestNumber__c, new List<RevSys_TestEntryWrapper>());
                }
                for (String key : employeeByDeptCraft.keySet()) {
                    String department = key.substringBefore('-');
                    for (SearchTabularItemWrapper emp : employeeByDeptCraft.get(key)) {
                        Observation__c obs = new Observation__c();
                        obs.OccupationSpecificRequirement__c = osr.Id;
                        obs.Employee__c = emp.recordId;
                    //    RevSys_TestEntryWrapper testEntryWrap = new RevSys_TestEntryWrapper(osr, obs);
                    //    String employeeInfo;
                    //    if (emp.theNumber != null || emp.department != null || emp.craft != null) {
                    //        employeeInfo = emp.theNumber + ',' + emp.department + ',' + emp.craft;
                    //    }
                    //    
                    
                        Boolean isExist = false;
                        list<RevSys_TestEntryWrapper> testEntryWrapList = testEntryByTestMap.get(osr.Observation__r.TestNumber__c);
                        if(testEntryWrapList != null && testEntryWrapList.size() > 0){
                            list<String> employeeIdStrList = new list<String>();
                            for(RevSys_TestEntryWrapper testEntry : testEntryWrapList){
                                employeeIdStrList.add(testEntry.employeeName);
                            }
                            if(employeeIdStrList != null && employeeIdStrList.size() > 0){
                                isExist = (employeeIdStrList.contains(emp.theName)) ? true : false;
                            }
                        }
                        if(!isExist){
                            if (key == deptCraft) {
                                testEntryByTestMap.get(osr.Observation__r.TestNumber__c).add(new RevSys_TestEntryWrapper(osr, obs, emp, fraTestsList));
                            }else if (osr.ObservationDepartment2__c == department && osr.ObservationCraft2__c == 'All') {
                                testEntryByTestMap.get(osr.Observation__r.TestNumber__c).add(new RevSys_TestEntryWrapper(osr, obs, emp, fraTestsList));
                            }
                        }
                    }
                }
            }

            system.debug('*** testEntryByTestMap :: ' + testEntryByTestMap);
            for (String testNumber : testMapbyNumber.keySet()) {
                String testName = testMapbyNumber.get(testNumber);
                if (testEntryByTestMap.containsKey(testNumber)) {
                    List<RevSys_TestEntryWrapper> testEntryList = testEntryByTestMap.get(testNumber);
                    if (!testEntryList.isEmpty() && testEntryList != null) {
                        testWithObservationsList.add(new RevSys_TestWithObservationsWrapper(testNumber, testName, testEntryList));
                    }
                }
            }
            System.debug('********** testWithObservationsList: ' + testWithObservationsList);
            response.put('testWithObservationsList', JSON.serialize(testWithObservationsList));
             
        } catch(QueryException qe) {

            response.put('errorMsg', qe.getMessage());
            response.put('consolelog', qe.getStackTraceString());
            System.debug(qe.getStackTraceString());
            System.debug('Error query: ' + qe.getMessage());
        } catch (Exception e) {
            response.put('errorMsg', e.getMessage());
            response.put('consolelog', e.getStackTraceString());
            System.debug(e.getStackTraceString());
        }
        
       
        System.debug('AURAENABLED RevSys_ObservationController.loadTestSelection() END');
        return response;
    }
    
    @AuraEnabled
    public static Map<String, String> insertForm1872(Map<String, String> params) {
        System.debug('AURAENABLED insertForm1872() START');
        Map<String, String> response = new Map<String, String>();
        Map <String, String> resMap = new Map <String, String>();
        
        Savepoint sp = Database.setSavepoint();
        try {
            List<RevSys_TestEntryWrapper> teWrapperList = (List<RevSys_TestEntryWrapper>)JSON.deserialize(params.get('testEntryJSON'), List<RevSys_TestEntryWrapper>.class);
            System.debug('### testEntryJSON JSON : ' + params.get('testEntryJSON'));
            System.debug('### testEntryJSON : ' + teWrapperList);
            List<Observation__c> toBeInsertedList = new List<Observation__c>();
            for (RevSys_TestEntryWrapper teWrapper : teWrapperList) {
                Observation__c cloneObs = teWrapper.obs.clone();
                system.debug('teWrapper.entryKey : ' + teWrapper.entryKey.split('-')[1]);
                cloneObs.OccupationSpecificRequirement__c = teWrapper.entryKey.split('-')[0];
                cloneObs.Employee__c = teWrapper.entryKey.split('-')[1];
                cloneObs.Status__c = Label.RevSys_Observation_Status_Complete;
                toBeInsertedList.add(cloneObs);
                cloneObs = null;
            }
            System.debug('toBeInsertedList BFORE $$' + toBeInsertedList);
            insert toBeInsertedList;              
            
            response.put('trWrapperList', JSON.serialize(getTestResultWrapperList(toBeInsertedList)));
            System.debug('toBeInsertedList$$' + toBeInsertedList);
            
            
            String obsId;
             for (Observation__c lst : toBeInsertedList) {
                 obsId = lst.Id;
             }
            
            System.debug('obsId$$' + obsId);
            if(toBeInsertedList!=null){            
                resMap = getTotalTestTaken(obsId,  Label.RevSys_Observation_RT_Label_Test_1872);            
            }
            
             response.put('totalTests', JSON.serialize(resMap));
            
            //delete toBeInsertedList;
        } catch (DmlException e) {
            String errorMsg = '';
            for (Integer i = 0; i < e.getNumDml(); i++) {
                errorMsg += e.getDmlMessage(i) + '. ';
                System.debug('----------- Record Id: ' + e.getDmlId(i));
                System.debug(e.getDmlFieldNames(i));
                System.debug(e.getDmlMessage(i));
                system.debug('error in inset1872 : ' + e.getLineNumber() + e.getMessage() + e.getStackTraceString());
            }
            response.put('errorMsg', errorMsg);
            response.put('consolelog', e.getStackTraceString());
            System.debug(e.getStackTraceString() + ' ' + e.getMessage());
        } catch (Exception e) {
            Database.rollback(sp);
            response.put('errorMsg', e.getMessage());
            response.put('consolelog', e.getStackTraceString());
            System.debug(e.getStackTraceString());
        }
        
        System.debug('AURAENABLED RevSys_Obs_RecordDetailCtrl.multiTestFormSaveAndPreview() END');
        return response;
    }
    
    private static List<RevSys_TestResultWrapper> getTestResultWrapperList(List<Observation__c> observationsList) {
        Set<Id> observationIdsSet = new Set<Id>();

        for (Observation__c obs : observationsList) {
            observationIdsSet.add(obs.Id);
        }
        Map<String, String>selectorAttsMap = new Map<String, String>();
        selectorAttsMap.put('orderBy','Employee__r.Name,TestNumber__c');
        
        List<Observation__c> testResults;
        SelectorWrapper sw = new ObservationSelector(observationIdsSet, selectorAttsMap).selectById();
        
        if (sw.ErrorMessage != null) {
            return null;
        }

        testResults = (List<Observation__c>)sw.SObjectList;  
        
        Set<String> empIdSet = new Set<String>();
        List<RevSys_TestResultWrapper> trWrapperList = new List<RevSys_TestResultWrapper>();
        RevSys_TestResultWrapper trWrapper;
        for (Observation__c obs : testResults) {
            if (empIdSet.add(obs.Employee__r.Name)) {
                trWrapper = new RevSys_TestResultWrapper();
                trWrapper.employeeName = obs.Employee__r.Name;
                trWrapper.testResults = new List<Observation__c>();
                trWrapperList.add(trWrapper);
            }
            System.debug(obs);
            trWrapper.testResults.add(obs);
        }
        
        return trWrapperList;
    }

    /**
    *————————————————————————————————————————————————————
    * @Name: getContactFieldLabels
    * @Description
    * Fetch the list of field labels from Schema
    *————————————————————————————————————————————————————
    * @param    desiredFields       CSV string of field's API Name
    * @return   List<String>        List of field's label
    *————————————————————————————————————————————————————
    **/ 
    private static List<String> getContactFieldLabels(String desiredFields) {
        List<String> fieldLabels = new List<String>();
        Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Contact.fields.getMap();
        for (String fieldName : desiredFields.split(',')) {
            fieldLabels.add(String.valueOf(fieldMap.get(fieldName).getDescribe().getLabel()));
        }
        System.debug(fieldLabels);
        return fieldLabels;
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Name: getScoreListMap
    * @Description
    * Fetch the list of scores from custom settings
    *————————————————————————————————————————————————————
    * @param    obsRecordTypes                  List of Record Types
    * @return   Map<String, List<Integer>>      List of scores goruped by Record Type Id
    *————————————————————————————————————————————————————
    **/ 
    private static Map<String, List<Integer>> getScoreListMap(List<RecordType> obsRecordTypes) {
        Map<String, List<Integer>> scoreListMap = new Map<String, List<Integer>>();
        for (RecordType rt: obsRecordTypes) {
            if (REVSYS_Custom_Settings__c.getValues('Observation ' + rt.Name + ' Score List') != null) {
                String scoreListString = String.valueOf(REVSYS_Custom_Settings__c.getValues('Observation ' + rt.Name + ' Score List').CSV_String__c);
                
                List<Integer> scoreList = new List<Integer>();
                for (String score: scoreListString.split(',')) {
                    scoreList.add(Integer.valueOf(score));
                }
                scoreListMap.put(String.valueOf(rt.Id), scoreList);
            }
        }
        
        return scoreListMap;
    }

    /**
    *————————————————————————————————————————————————————
    * @Name: getAllRequiredFieldsMap
    * @Description
    * Create a map of required fields grouped by the Observation's record type
    *————————————————————————————————————————————————————
    * @param    head                Header value of the custom setting record's name
    * @param    tail                Trailing value of the custom setting record's name
    * @param    obsRecordTypes      List of Obervation's record type
    * @return   Map<String, Map<String, Boolean>>       Map of field's API Name with boolean value as required flag. Group by Record Type Id
    *————————————————————————————————————————————————————
    **/ 
    private static Map<String, Map<String, Boolean>> getAllRequiredFieldsMap(String head, String tail, List<RecordType> obsRecordTypes) {
        Map<String, Map<String, Boolean>> allRequiredFieldsMap = new Map<String, Map<String, Boolean>>();
        for (RecordType rt : obsRecordTypes) {
            if (REVSYS_Custom_Settings__c.getValues(head + rt.Name + tail) != null) {
                String requiredFields = String.valueOf(REVSYS_Custom_Settings__c.getValues(head + rt.Name + tail).CSV_String__c);
                Map<String, Boolean> rfMap = new Map<String, Boolean>();
                if (String.isNotBlank(requiredFields)) {
                    for (String fieldAPI : requiredFields.split(',')) {
                        rfMap.put(fieldAPI, true);
                    }
                }
                allRequiredFieldsMap.put(rt.Id, rfMap);
            }
        }
        return allRequiredFieldsMap;
    }

    /**
    *————————————————————————————————————————————————————
    * @Name: getAllEditableFieldsMap
    * @Description
    * Create a map of FieldSetMemberWrapper grouped by record type name
    * for editable fields that will be used in the custom observation form
    *————————————————————————————————————————————————————
    * @param    obsRecordTypes      All SPARTN record types  
    * @return   Map<String, List<FieldSetMemberWrapper>>  Map of List<FieldSetMemberWrapper> by record type
    *————————————————————————————————————————————————————
    **/ 
    private static Map<String, List<FieldSetMemberWrapper>> getAllEditableFieldsMap(List<RecordType> obsRecordTypes) {
        System.debug('$$$insidegetAllEditableFieldsMap');
        Map<String, List<FieldSetMemberWrapper>> allEditableFieldsMap = new Map<String, List<FieldSetMemberWrapper>>();
        for (RecordType rt : obsRecordTypes) {
            String formNumber = rt.Name.right(4);
            String fieldSetName = 'SPARTN_TestInfo' + formNumber;
            List<FieldSetMemberWrapper> fieldsetWrapperList = LightningFieldSetHandler.getFields('Observation__c', fieldSetName);
            if (fieldsetWrapperList != null) {
                allEditableFieldsMap.put(rt.Name, fieldsetWrapperList);
            }
        }
        return allEditableFieldsMap;
    }

    /**
    *————————————————————————————————————————————————————
    * @Name: getNeedImprovementMap
    * @Description
    * Fetch the list of need improvement scores from custom settings
    *————————————————————————————————————————————————————
    * @param    obsRecordTypes                       List of Record Types
    * @return   Map<String, Map<String, Boolean>>    Map of need imrpovement scores grouped by Record Type Id
    *————————————————————————————————————————————————————
    **/
    private static Map<String, Map<String, Boolean>> getNeedImprovementMap(List<RecordType> obsRecordTypes) {
        Map<String, Map<String, Boolean>> needImprovementMap = new Map<String, Map<String, Boolean>>();
        for (RecordType rt: obsRecordTypes) {
            if (REVSYS_Custom_Settings__c.getValues('Obs ' + rt.Name + ' Need Improvement') != null) {
                String scoreListString = String.valueOf(REVSYS_Custom_Settings__c.getValues('Obs ' + rt.Name + ' Need Improvement').CSV_String__c);
                Map<String, Boolean> scoreMap = new Map<String, Boolean>();
                for (String score: scoreListString.split(',')) {
                    scoreMap.put(score, true);
                }
                needImprovementMap.put(String.valueOf(rt.Id), scoreMap);
            }
        }
        return needImprovementMap;
    }

    /**
    *————————————————————————————————————————————————————
    * @Name: getAtLeastOneRequiredMap
    * @Description
    * Fetch the list of at least one of the fields is required values from custom settings
    *————————————————————————————————————————————————————
    * @param    obsRecordTypes                       List of Record Types
    * @return   Map<String, Map<String, List<String>>    Map of the pair of field that at least one field is required grouped by Record Type Id
    *————————————————————————————————————————————————————
    **/
    private static Map<String, Map<String, String>> getAtLeastOneRequiredMap(List<RecordType> obsRecordTypes) {
        Map<String, Map<String, String>> allOneIsRequiredMap = new Map<String, Map<String, String>>();
        for (RecordType rt: obsRecordTypes) {
            if (REVSYS_Custom_Settings__c.getValues('Obs ' + rt.Name + ' At least one required') != null) {
                String oneIsRquiredString = String.valueOf(REVSYS_Custom_Settings__c.getValues('Obs ' + rt.Name + ' At least one required').CSV_String__c);
                Map<String, String> oneIsRquiredMap = new Map<String, String>();
                for (String thePair: oneIsRquiredString.split(',')) {
                    String firstField = thePair.substringBefore('-');
                    String secondField = thePair.substringAfter('-');
                    oneIsRquiredMap.put(firstField, secondField);
                    oneIsRquiredMap.put(secondField, firstField);
                }
                allOneIsRequiredMap.put(String.valueOf(rt.Id), oneIsRquiredMap);
            }
        }
        return allOneIsRequiredMap;
    }

    /**
    *————————————————————————————————————————————————————
    * @Name: getFormCraftMap
    * @Description
    * Fetch a map of specific craft name by form number
    *————————————————————————————————————————————————————
    * @param    obsRecordTypes                       List of Record Types
    * @return   Map<String, String>    Map of craft by Record Type Id
    *————————————————————————————————————————————————————
    **/
    private static Map<String, String> getFormCraftMap(List<RecordType> obsRecordTypes) {
        Map<String, String> formCraftMap = new Map<String, String>();
        for (RecordType rt: obsRecordTypes) {
            if (REVSYS_Custom_Settings__c.getValues('Observation ' + rt.Name + ' Craft') != null) {
                String craft = REVSYS_Custom_Settings__c.getValues('Observation ' + rt.Name + ' Craft').CSV_String__c;
                if (!String.isBlank(craft)) {
                    formCraftMap.put(String.valueOf(rt.Id), craft);
                }
            }
        }
        return formCraftMap;
    }

    /**
    *————————————————————————————————————————————————————
    * @Name: getScoreDefinitionsMap
    * @Description
    * Fetch a map of specific score definition for a from number
    *————————————————————————————————————————————————————
    * @param    obsRecordTypes                       List of Record Types
    * @return   Map<String, String>    Map of craft by Record Type Id
    *————————————————————————————————————————————————————
    **/
    private static Map<String, String> getScoreDefinitionsMap(List<RecordType> obsRecordTypes) {
        System.debug('getScoreDefinitionsMap$$'); 
        Map<String, String> scoreDefMap = new Map<String, String>();
        
        SelectorWrapper myReturnedWrap 
            = ScoreDefinitionSelector.getScoreDefinitions(RevSys_StaticUtility.REVSYS_APP_NAME);  

        String ErrorMsg = myReturnedWrap.ErrorMessage; 

        if(ErrorMsg == null)
        {
            List<SPARTN_Score_Definition__mdt> myScoreDefList = myReturnedWrap.SObjectList; 

            // Separate the questions into maps of tests. 

            for(SPARTN_Score_Definition__mdt scodef :myScoreDefList) {                      
                       
                    scoreDefMap.put(scodef.MasterLabel, scodef.CSV_String__c );    
            }
        }    
        
        System.debug('scoreDefMap$$'+scoreDefMap);        
        return scoreDefMap;        
    }
    
    
    /**
    *————————————————————————————————————————————————————
    * @Name: getTestQuestionMap
    * @Description
    * Retrieve Findings for list of questions to display on non-1872 forms
    *————————————————————————————————————————————————————
    * @return   Map<String, List<Finding__c>>    Map of Findings list indexed by Form number (Observation RecordType Name)
    *————————————————————————————————————————————————————
    **/ 
    public static Map<String, List<Finding__c>> getTestQuestionMap() {
        
        List<String> myCatToSelectList = new List<String>();

        for (RecordType rt : getRecordTypes()) {
            myCatToSelectList.add(rt.Name);
        }

        Map<String, List<Finding__c>> testQuestionMap = new Map<String, List<Finding__c>>();
        Map<String,List<Station_Audit_Setting__mdt>> myQuestionListByTestNameMap = RevSys_CreateTestQuestionsHelper.queryForQuestions(myCatToSelectList);   

        for (String testName : myQuestionListByTestNameMap.keySet()) {
            List<Finding__c> findingForQuestionsList = new List<Finding__c>();
            for(Station_Audit_Setting__mdt myQuestion :  myQuestionListByTestNameMap.get(testName)) {

                Finding__c myNewFinding = new Finding__c(); 
            
                myNewFinding.RecordTypeId    = RevSys_StaticUtility.FINDING_REVIEW_SYSTEMS_RECTYPE_ID;
                myNewFinding.Category__c     = myQuestion.Category__c;
                myNewFinding.Sub_category__c = myQuestion.Sub_category__c;
                myNewFinding.Sequence__c     = myQuestion.Sub_category_sequence__c;
                myNewFinding.Score__c        = 0;
                myNewFinding.IsCriticalItem__c = myQuestion.IsCriticalItem__c;
                 

                findingForQuestionsList.add(myNewFinding); 
            }

            testQuestionMap.put(testName, findingForQuestionsList);
        }     
        return testQuestionMap;
    }

    /**
    *————————————————————————————————————————————————————
    * @Name: getUserFullName
    * @Description
    * Retrieve current user's full name to dispaly on the form
    *————————————————————————————————————————————————————
    * @return   String user full name
    *————————————————————————————————————————————————————
    **/ 
    public static String getUserFullName() {
        return UserInfo.getName();
    }

    /**
    *————————————————————————————————————————————————————
    * @Name: getRecordTypes
    * @Description
    * Retrieve Observation Record Types that have name start with Form
    *————————————————————————————————————————————————————
    * @return   List<RecordType> List of Observation record types
    *————————————————————————————————————————————————————
    **/ 
    public static List<RecordType> getRecordTypes() {
        // Set up RecordType warpper object
        List<RecordType> obsRecordTypes = new List<RecordType>();

        Schema.DescribeSObjectResult obsDescribe = Schema.SObjectType.Observation__c; 
        Map<Id,Schema.RecordTypeInfo> rtMapById = obsDescribe.getRecordTypeInfosById();

        for (RecordType rt : [SELECT Id, Name, DeveloperName FROM RecordType 
                                           WHERE SobjectType = 'Observation__c' AND Name LIKE 'Form%'
                                           ORDER BY Name ASC]) {
            Schema.RecordTypeInfo rtById =  rtMapById.get(rt.id);
            if (rtById.isAvailable()) {
                obsRecordTypes.add(rt);
            }
        }
        return obsRecordTypes;
    }

    /**
    *————————————————————————————————————————————————————
    * @Name: getRecordDetailResponseMap
    * @Description
    * Returns reponse for the page that used in an observation record detail page.
    *————————————————————————————————————————————————————
    * @param    params                       Map<String, String>
    * @return   Map<String, String>          Map of object, fields to display, required fields
    *                                        needs imporvement conditions, score list and findings
    *————————————————————————————————————————————————————
    **/
    private static Map<String, String> getRecordDetailResponseMap(Map<String, String> params) {
        Map<String, String> response = new Map<String, String>();
        List<String> fraTestsList = new List<String>();
        if (REVSYS_Custom_Settings__c.getValues('Obs Form-1872 Efficiency Test Numbers') != null) {
            String fraTests = String.valueOf(REVSYS_Custom_Settings__c.getValues('Obs Form-1872 Efficiency Test Numbers').CSV_String__c);
            fraTestsList = fraTests.split(',');
        }

        try {
            Observation__c observation = new Observation__c();
            RecordType rt;
            System.debug('params.get(obsId)' + params.get('obsId'));
            // Create field label map from field set
            if (params.get('obsId') != null) {
                System.debug('=====> found obsId');
                
                String obsId = params.get('obsId');
                List<Observation__c> obsList;
                Set<Id> observationIdsSet = new Set<Id>();

                observationIdsSet.add(obsId);

                SelectorWrapper sw = new ObservationSelector(observationIdsSet).selectByIdWithFindings();
                if (sw.ErrorMessage == null) {
                    obsList = (List<Observation__c>)sw.SObjectList;
                }
                else {
                    response.put('errorMsg', sw.ErrorMessage);
                    System.debug('getTestResultWrapperListWithFinding error');
                    return response;
                }
                observation = obsList[0];
                system.debug('*** observation : ' + observation);
                OccupationSpecificRequirement__c osrRecord = null;
                if(observation.OccupationSpecificRequirement__c != null){
                    osrRecord = [select Id, Observation__c	, Department__c from OccupationSpecificRequirement__c where Id = :observation.OccupationSpecificRequirement__c limit 1];    
                }
                
                
                response.put('observation', JSON.serialize(observation));
                response.put('findingList', JSON.serialize(observation.Findings__r));
                response.put('occupationSpecificReq', JSON.serialize(osrRecord));

                List<RecordType> recordTypesList = new List<RecordType>([SELECT Id, Name, DeveloperName FROM RecordType WHERE Id = :observation.RecordTypeId]);

                if (!recordTypesList.isEmpty()) {
                    rt = recordTypesList[0];
                    response.put('recordType', JSON.serialize(rt));
                }

                if (fraTestsList.contains(observation.TestNumber__c)) {
                    response.put('isFRA', 'true');
                }
                else {
                    response.put('isFRA', 'false');
                }
            }

            String formNumber = rt.Name.right(4);
            String fieldSetName = 'SPARTN_TestInfo' + formNumber;
            response.put('editableFields', JSON.serialize( LightningFieldSetHandler.getFields('Observation__c', fieldSetName)));
            
            Map<String, Map<String, Boolean>> requiredFieldsByRt= getAllRequiredFieldsMap('Obs ', ' Info Required Fields', new List<RecordType>{rt});
            Map<String, Boolean> requiredFieldMap = requiredFieldsByRt.get(rt.Id);
            response.put('requiredFieldMap', JSON.serialize(requiredFieldMap));
            // Set up Dependent Picklist map
            Map<String, List<String>> testInfoPicklistMapRegionState = StaticUtils.getDependentOptionsImpl(Observation__c.State__c.getDescribe().getSObjectField(),
                                                                                                   Observation__c.RegionProperty__c.getDescribe().getSObjectField());
            response.put('picklistMapRegionState', JSON.serialize(testInfoPicklistMapRegionState));
            if (!rt.Name.contains('1872')) {
	            Map<String, Map<String, Boolean>> needImprovementByRt= getNeedImprovementMap(new List<RecordType>{rt});
	            Map<String, Boolean> needImprovementMap = needImprovementByRt.get(rt.Id);
	            response.put('needImprovementMap', JSON.serialize(needImprovementMap));

	            String scoreListString = String.valueOf(REVSYS_Custom_Settings__c.getValues('Observation ' + rt.Name + ' Score List').CSV_String__c);
	            response.put('scoreListString', scoreListString);

	            Map<String, Map<String, String>> atLeastOneReqByRt = getAtLeastOneRequiredMap(new List<RecordType>{rt});
	            Map<String, String> oneIsRequiredMap = atLeastOneReqByRt.get(rt.Id);
	            response.put('oneIsRequiredMap', JSON.serialize(oneIsRequiredMap));
	              // Generate score-definition mapping
	            response.put('allFormScoreDefinitionMap', JSON.serialize(getScoreDefinitionsMap(new List<RecordType>{rt})));
	        }
	        // Get Speed Check Method
	        if (observation.OccupationSpecificRequirement__c != null) {
	        	response.put('speedCheckMethodList', JSON.serialize(getObservationSpeedCheckMethod(observation.OccupationSpecificRequirement__c)));
                
                Map<String, Boolean> checkMethodReqMap = getObservationCheckMethodReq(observation.OccupationSpecificRequirement__c);
                if(checkMethodReqMap != null && checkMethodReqMap.size() > 0){
                    response.put('checkMethodPermitted', JSON.serialize(checkMethodReqMap.get('checkMethodPermitted')));
                    response.put('checkMethodReq', JSON.serialize(checkMethodReqMap.get('checkMethodReq')));
                }
	        }
        } catch (Exception e) {
            response.put('errorMsg', e.getMessage());
            response.put('consolelog', e.getStackTraceString());
            System.debug(e.getStackTraceString());
            System.debug(e.getMessage());
        }
        return response;
    }

    /**
    *————————————————————————————————————————————————————
    * @Name: getSelectFormResponseMap
    * @Description
    * Returns reponse for the page that used in a custom SPARTN form page
    *————————————————————————————————————————————————————
    * @param    params                       Map<String, String>
    * @return   Map<String, String>          Map of object, fields to display, required fields
    *                                        needs imporvement conditions, score list and findings
    *————————————————————————————————————————————————————
    **/
    private static Map<String, String> getSelectFormResponseMap(Map<String, String> params) {
        Map<String, String> response = new Map<String, String>();
        try {
            // Set up RecordType warpper object
            List<RecordType> obsRecordTypes = getRecordTypes();

            response.put('obsRecordTypes', JSON.serialize(obsRecordTypes));

            Observation__c obs = new Observation__c();
            response.put('observation', JSON.serialize(obs));
                        
            String recordTypeToDisplayTestNumbers = Schema.SObjectType.Observation__c.getRecordTypeInfosByName().get(Label.RevSys_Observation_RT_Label_Test_1872).getRecordTypeId();
            response.put('recordTypeToDisplayTestNumbers', recordTypeToDisplayTestNumbers);
            
            // Generate required fields mapping
            response.put('allRequiredFieldMap', JSON.serialize(getAllRequiredFieldsMap('Obs ', ' Info Required Fields', obsRecordTypes)));
            
            //String scoreListString = String.valueOf(REVSYS_Custom_Settings__c.getValues('Observation ' + obs.RecordType.Name + ' Score List').CSV_String__c);
            
            // Set up Test Number wrapper object
            // clean up not using this
         //   response.put('osrWrapperList', JSON.serialize(getOSRWrapperList()));
            
            // Set up Dependent Picklist map
            Map<String, List<String>> testInfoPicklistMapRegionState = StaticUtils.getDependentOptionsImpl(Observation__c.State__c.getDescribe().getSObjectField(),
                                                                                                   Observation__c.RegionProperty__c.getDescribe().getSObjectField());
            response.put('testInfoPicklistMapRegionState', JSON.serialize(testInfoPicklistMapRegionState));
            

            // Set up Test questions wrapper object for score grid
            response.put('testQuestionMap', JSON.serialize(getTestQuestionMap()));            
            // Set up Score List for each record type
            response.put('scoreListMap', JSON.serialize(getScoreListMap(obsRecordTypes))); 
            response.put('needImprovementMap', JSON.serialize(getNeedImprovementMap(obsRecordTypes)));
            response.put('currentUser', getUserFullName());
            // Get all the editable fields
            response.put('allEditableFieldMap', JSON.serialize(getAllEditableFieldsMap(obsRecordTypes)));
            // Generate at least one is required mapping
            response.put('allOneIsRequiredMap', JSON.serialize(getAtLeastOneRequiredMap(obsRecordTypes)));
            // Generate form-craft mapping
            response.put('allFormCraftMap', JSON.serialize(getFormCraftMap(obsRecordTypes)));
            // Generate score-definition mapping
            response.put('allFormScoreDefinitionMap', JSON.serialize(getScoreDefinitionsMap(obsRecordTypes)));
            
        } catch (Exception e) {
            response.put('errorMsg', e.getMessage());
            response.put('consolelog', e.getStackTraceString());
            System.debug(e.getStackTraceString());
            System.debug('Exception error: ' + e.getMessage());
        }
        return response;
    }
 
   /**
    *————————————————————————————————————————————————————
    * @Name: getTotalTestTaken
    * @Description
    * Fetch the list of at lead one of the fields is required values from custom settings
    *————————————————————————————————————————————————————
    * @param    obsRecordTypes                       List of Record Types
    * @return   Map<String, Map<String, List<String>>    Map of the pair of field that at least one field is required grouped by Record Type Id
    *————————————————————————————————————————————————————
    **/
    private static Map<String, String> getTotalTestTaken(Id ObsId, String rtname) {
        Map<String, String> responsemap = new Map<String, String>();
        Map<Id, String> craftDeptmap = new Map<Id, String>();
        Set<String> mycraft = new Set<String>();
        Set<String> myDept = new Set<String>();
        Set<Id> mySupervisor = new Set<Id>();
        Set<Id> myTarget = new Set<Id>();
        set<Id> obsIdSet = new Set<Id>(); 
        set<String> targetType = new Set<String>(); 
       
        List<EmployeeSpecificRequirement__c> oEmpSpecReqList = new List<EmployeeSpecificRequirement__c>();
        
        System.debug('Id$$'+ObsId);
        
        List<Observation__c> ObsList = new List <Observation__c>();
        
        obsIdSet.add(ObsId);
        
        SelectorWrapper wrapper = ObservationSelector.getObservationsbyId(obsIdSet);
        if(wrapper!=null) {
            ObsList = (List<Observation__c>)wrapper.SobjectList;
        }      
        
        //form set for craft, dept and supervisor
        for(observation__c obs : ObsList)
        {     
           mySupervisor.add(obs.Supervisor__c);
        } 
        //query on ESR with target and employee to get active ESR record
        targettype.add('Supervisor');
        system.debug('## mySupervisor : ' + mySupervisor);
        system.debug('## targetType : ' + targetType);
        wrapper = EmployeeSpecificRequirementSelector.geActivetEmpSpecReqFrmEmpAndTarget(mySupervisor,targetType);
        if(wrapper!=null) {
            oEmpSpecReqList = (List<EmployeeSpecificRequirement__c>)wrapper.SobjectList;
        }   
         System.debug('oEmpSpecReqList$$'+oEmpSpecReqList);
         System.debug('rtname'+rtname);
         //prepare ESC id set
        
           String totachieved = '0';
           Integer sumtotachieved = 0;
           String totRequired = '0';
           Integer sumtotRequired = 0;  
           String target =  '';
           String endDate = '0';   
        
        for(EmployeeSpecificRequirement__c esr : oEmpSpecReqList)
        {      
            
            if(esr.TotalAchieved__c!=null){totachieved = String.valueOf(esr.TotalAchieved__c);}             
            if(esr.TotalRequired__c!=null){totRequired = String.valueOf(esr.TotalRequired__c);}           
            if(esr.target__r.name!=null){target =  esr.target__r.name;}            
            sumtotachieved = sumtotachieved+ Integer.valueOf(totachieved);
            sumtotRequired = sumtotRequired+ Integer.valueOf(totRequired);
             System.debug('insidefor4'+rtname);
            if(esr.EndDate__c!=null){endDate = String.valueof(esr.EndDate__c);}            
            if (rtname != Label.RevSys_Observation_RT_Label_Test_1872){
                 System.debug('insidefor5'+rtname);
                responsemap.Put(esr.Id, 'You have administered '+ totachieved +' tests out of a target of '+ totRequired +' for the '+ target +' Target ending on '+ endDate +'.');
            }
        }
         if (rtname == Label.RevSys_Observation_RT_Label_Test_1872){
            responsemap.Put('1872msg', 'You have completed '+ sumtotachieved +' out of  '+ sumtotRequired +' observations for this quarter.');
         }
         System.debug('responsemap$$'+responsemap);
        return responsemap;
    }
    
    
  
 /**
    *————————————————————————————————————————————————————
    * @Name: getEmploymentSummaryRecords
    * @Description
    * Fetch the list of at lead one of the fields is required values from custom settings
    *————————————————————————————————————————————————————
    * @param    obsRecordTypes                       List of Record Types
    * @return   Map<String, Map<String, List<String>>    Map of the pair of field that at least one field is required grouped by Record Type Id
    *————————————————————————————————————————————————————
    **/
    private static List<EmployeeResultSummary__c> getEmploymentSummaryRecords(Id ObsId) {
        Map<String, String> responsemap = new Map<String, String>();
        Map<String, String> empSummarymap = new Map<String, String>();
        List<Observation__c> ObsList = new List <Observation__c>();
        set<Id> obsIdSet = new Set<Id>();        
        set<Id> myEmployee = new Set<Id>();
        set<Id> myRecordTypeIdSet = new Set<Id>();
        
        List<EmployeeResultSummary__c> oEmpResSummList = new List<EmployeeResultSummary__c>();
        obsIdSet.add(ObsId);
        myRecordTypeIdSet.add(RevSys_StaticUtility.EMP_RES_SUMM_TEST1878_RECTYPE_ID);
        
        SelectorWrapper wrapper = ObservationSelector.getObservationsbyId(obsIdSet);
        if(wrapper!=null) {
            ObsList = (List<Observation__c>)wrapper.SobjectList;
        }      
        
        //form set for craft, dept and supervisor
        for(observation__c obs : ObsList)
        {     
           myEmployee.add(obs.Employee__c); 
        }
        System.debug('myEmployee$$$'+myEmployee+'myRecordTypeIdSet$$'+myRecordTypeIdSet);
        //query on ESR with target and employee to get active ESR record
        wrapper = EmployeeResultSummarySelector.getEmployeeSummaryRecords(myEmployee,myRecordTypeIdSet);
        if(wrapper!=null) {
            oEmpResSummList = (List<EmployeeResultSummary__c>)wrapper.SobjectList;
        }
        
		for(EmployeeResultSummary__c empResSummary : oEmpResSummList)
        {     
            String postingLocation = empResSummary.Observation__r.SectionTower__c;
            if (postingLocation==null){postingLocation='PostingLocation1';}
            
            if(!empSummarymap.containsKey(postingLocation))
            {
                empSummarymap.put(postingLocation, String.valueOf(empResSummary.Observation__r.OverallScore__c));//When the Key already exists
            }
            else
            {
                empSummarymap.put(postingLocation, empSummarymap.get(postingLocation) +','+ empResSummary.Observation__r.OverallScore__c);
            }
        }
        
        
        System.debug('EmpResSumm$$'+oEmpResSummList);  
     	System.debug('EmpResSummMap$$'+empSummarymap); 
        //return empSummarymap;
        return oEmpResSummList;
    }

 	/**
    *————————————————————————————————————————————————————
    * @Name: getObservationSpeedCheckMethod
    * @Description
    * Fetch the list of Speed Check Mothod picklist value based on TEST number
    *————————————————————————————————————————————————————
    * @param    osrId OccupationSpecificRequirement__c Id
    * @return   List<String>    List of Speed Check Method Values
    *————————————————————————————————————————————————————
    **/
    private static List<String> getObservationSpeedCheckMethod(Id osrId) {
    	List<String> speedCheckMethodList = new List<String>();
        List<OccupationSpecificRequirement__c> osrList = [
            SELECT Id, Observation__r.TestNumber__c, Observation__r.TestName__c, Observation__r.SpeedCheckMethod__c
            FROM OccupationSpecificRequirement__c 
            WHERE Id = :osrId
        ];

        if (osrList != null && osrList[0].Observation__r.SpeedCheckMethod__c != null) {
        	speedCheckMethodList = osrList[0].Observation__r.SpeedCheckMethod__c.split(';');
        }
        return speedCheckMethodList;
    }
    
    @TestVisible
    private static Map<String, Boolean> getObservationCheckMethodReq(Id osrId) {
    	Map<String, Boolean> checkMethodReqMap = new Map<String, Boolean>();
        List<OccupationSpecificRequirement__c> osrList = [
            SELECT Id, Observation__r.Check_Method_Required__c
            FROM OccupationSpecificRequirement__c 
            WHERE Id = :osrId
        ];
		string checkMethodReqInOR = null;
        if (osrList != null && osrList[0].Observation__r.Check_Method_Required__c != null) {
        	checkMethodReqInOR = osrList[0].Observation__r.Check_Method_Required__c;
        }
        if(checkMethodReqInOR != null){
            if(checkMethodReqInOR.equalsIgnoreCase('Yes - Required')){
                checkMethodReqMap.put('checkMethodPermitted', true);
                checkMethodReqMap.put('checkMethodReq', true);
            }else if (checkMethodReqInOR.equalsIgnoreCase('Yes - Not Required')){
                checkMethodReqMap.put('checkMethodPermitted', true);
                checkMethodReqMap.put('checkMethodReq', false);
            }else{
                checkMethodReqMap.put('checkMethodPermitted', false);
                checkMethodReqMap.put('checkMethodReq', false);
            }
        }else{
            checkMethodReqMap.put('checkMethodPermitted', false);
            checkMethodReqMap.put('checkMethodReq', false);
        }
        return checkMethodReqMap;
    }
        
        
}
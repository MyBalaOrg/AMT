/**__
*________________________________________________
*@Name: RevSys_Obs_RecordDetailCtrl
*@Author: Duy Tran
*@Created: Date: 11/06/2017
*@Used_By: RevSys_Obs_RecordDetail.cmp
*___________________________________________________
*@Description: 
* Query and process data to be populated on the Lightning component.
* Save finding records
*___________________________________________________
*@Changes: 
* 12-18-2017. Updated initializeTestSelectionComponent method to set default value for
*             Observation__c.Date__c, Observation__c.TimeHH__c and Observation.TineMM__c.
**/
public with sharing class RevSys_Obs_RecordDetailCtrl {
    /*
    public class OSRWrapper {  
        public Boolean selected {get; set;}
        public String testNumber {get; set;}
        public String testName {get; set;}
        public Map<String, Map<String, Boolean>> deptCraftMap {get; set;}
        public Map<String, Boolean> allCraftDeptMap {get; set;}
        public List<OccupationSpecificRequirement__c> osrList {get; set;}
        
        public OSRWrapper() {
            this.selected = false;
        }
        
        public OSRWrapper(OccupationSpecificRequirement__c osr) {
            this.selected = false;
            this.deptCraftMap = new Map<String, Map<String, Boolean>>();
            this.allCraftDeptMap = new Map<String, Boolean>();
            this.testNumber = osr.Observation__r.TestNumber__c;
            this.testName = osr.Observation__r.TestName__c;
        }
    }
    
    */
    
  @AuraEnabled
    public static Map<String, String> initializeTestSelectionComponent(Map<String, String> params) {
        System.debug('AURAENABLED RevSys_Obs_RecordDetailCtrl.initializeTestSelectionComponent() START');
        Map<String, String> response = new Map<String, String>();
        try {
            // Set up RecordType warpper object
            String recordTypeNameList = String.valueOf(REVSYS_Custom_Settings__c.getValues('Observation Record Type Test List').CsvString__c);
            List<RecordType> obsRecordTypes = [
                SELECT Id, Name, DeveloperName FROM RecordType 
                WHERE SobjectType = 'Observation__c' AND Name IN :recordTypeNameList.split(',')
                ORDER BY Name ASC
                ];

            response.put('obsRecordTypes', JSON.serialize(obsRecordTypes));

            // Updated by Boom Bertetti
            Datetime currentDT = System.DateTime.now();
            Integer  myHour    = currentDT.hour(); 
            Integer  myMinute  = currentDT.minute(); 

            Observation__c obs = new Observation__c();
            obs.Date__c   = Date.today();
            obs.TimeHH__c = String.valueOf(myHour).length() == 2 ? String.valueOf(myHour) : '0' + String.valueOf(myHour);
            obs.TimeMM__c = String.valueOf(myMinute).length() == 2 ? String.valueOf(myMinute) : '0' + String.valueOf(myMinute);
            response.put('obsTemplate', JSON.serialize(obs));
            
            // Create field label map from field set
            Map<String, Schema.SObjectField> obsFieldMap = Schema.SObjectType.Observation__c.fields.getMap();
            Map<String, String> obsFieldLabelMap = new Map<String, String>();
            for (String fieldDevName : obsFieldMap.keySet()) {
                obsFieldLabelMap.put(fieldDevName, String.valueOf(obsFieldMap.get(fieldDevName).getDescribe().getLabel()));
            }
            response.put('obsFieldLabelMap', JSON.serialize(obsFieldLabelMap));
            
            // Append additional record type Id that should see the Test Numbers list
            // Changed by Boom Bertetti 12/19/2017 from recordTypeToDisplayInfo to recordTypeToDisplayTestNumbers
            String recordTypeToDisplayTestNumbers = Schema.SObjectType.Observation__c.getRecordTypeInfosByName().get(Label.RevSys_Observation_RT_Label_Test_1872).getRecordTypeId();
            response.put('recordTypeToDisplayTestNumbers', recordTypeToDisplayTestNumbers);
            
            // Generate required fields mapping
            response.put('allInfoReqFieldsMap', JSON.serialize(getAllRequiredFieldsMap('Obs ', ' Info Required Fields', obsRecordTypes)));
            response.put('allEntryReqFieldsMap', JSON.serialize(getAllRequiredFieldsMap('Obs ', ' Entry Required Fields', obsRecordTypes)));
            
            //String scoreListString = String.valueOf(REVSYS_Custom_Settings__c.getValues('Observation ' + obs.RecordType.Name + ' Score List').CsvString__c);
            
            // Set up Test Number wrapper object
            response.put('osrWrapperList', JSON.serialize(getOSRWrapperList()));
            
            // Set up Dependent Picklist map
            Map<String, List<String>> testInfoPicklistMapRegionState = StaticUtils.getDependentOptionsImpl(Observation__c.State__c.getDescribe().getSObjectField(),
                                                                                                   Observation__c.RegionProperty__c.getDescribe().getSObjectField());
            response.put('testInfoPicklistMapRegionState', JSON.serialize(testInfoPicklistMapRegionState));
            
            // Set up all Piclist value for Test result
            Map<String, List<String>> testPicklistMap = new Map<String, List<String>>();
            // Set up Piclist value for Test Info
            Map<String, List<String>> testInfoPicklistMap = new Map<String, List<String>>();
            testInfoPicklistMap.put('RailroadRule__c', StaticUtils.getPicklistValues(Observation__c.RailroadRule__c.getDescribe()));
            testInfoPicklistMap.put('NearestStationOrInterlocking__c', StaticUtils.getPicklistValues(Observation__c.NearestStationOrInterlocking__c.getDescribe()));
            testInfoPicklistMap.put('MpSg__c', StaticUtils.getPicklistValues(Observation__c.MpSg__c.getDescribe()));
            testInfoPicklistMap.put('SpeedCheckMethod__c', StaticUtils.getPicklistValues(Observation__c.SpeedCheckMethod__c.getDescribe()));
            testInfoPicklistMap.put('State__c', new List<String>());
            testInfoPicklistMap.put('RegionProperty__c', StaticUtils.getPicklistValues(Observation__c.RegionProperty__c.getDescribe()));
            testInfoPicklistMap.put('TimeHH__c', StaticUtils.getPicklistValues(Observation__c.TimeHH__c.getDescribe()));
            testInfoPicklistMap.put('TimeMM__c', StaticUtils.getPicklistValues(Observation__c.TimeMM__c.getDescribe()));
            testInfoPicklistMap.put('Method__c', StaticUtils.getPicklistValues(Observation__c.ObservationMethod__c.getDescribe()));
            testInfoPicklistMap.put('Position__c', StaticUtils.getPicklistValues(Observation__c.Position__c.getDescribe()));
            testInfoPicklistMap.put('SectionTower__c', StaticUtils.getPicklistValues(Observation__c.SectionTower__c.getDescribe()));
            testInfoPicklistMap.put('InitialQualification__c', StaticUtils.getPicklistValues(Observation__c.InitialQualification__c.getDescribe()));
            testInfoPicklistMap.put('Department__c', StaticUtils.getPicklistValues(OccupationCertification__c.Department__c.getDescribe()));
            testInfoPicklistMap.put('Craft__c', StaticUtils.getPicklistValues(OccupationCertification__c.Craft__c.getDescribe()));
            testInfoPicklistMap.put('QualificationStatus__c', StaticUtils.getPicklistValues(Observation__c.QualificationStatus__c.getDescribe()));
            response.put('testInfoPicklistMap', JSON.serialize(testInfoPicklistMap));

            testPicklistMap.put('RailroadRule__c', StaticUtils.getPicklistValues(Observation__c.RailroadRule__c.getDescribe()));
            testPicklistMap.put('NearestStationOrInterlocking__c', StaticUtils.getPicklistValues(Observation__c.NearestStationOrInterlocking__c.getDescribe()));
            testPicklistMap.put('MpSg__c', StaticUtils.getPicklistValues(Observation__c.MpSg__c.getDescribe()));
            testPicklistMap.put('SpeedCheckMethod__c', StaticUtils.getPicklistValues(Observation__c.SpeedCheckMethod__c.getDescribe()));
            testPicklistMap.put('State__c', new List<String>());
            testPicklistMap.put('RegionProperty__c', StaticUtils.getPicklistValues(Observation__c.RegionProperty__c.getDescribe()));
            testPicklistMap.put('TimeHH__c', StaticUtils.getPicklistValues(Observation__c.TimeHH__c.getDescribe()));
            testPicklistMap.put('TimeMM__c', StaticUtils.getPicklistValues(Observation__c.TimeMM__c.getDescribe()));
            testPicklistMap.put('Method__c', StaticUtils.getPicklistValues(Observation__c.ObservationMethod__c.getDescribe()));
            testPicklistMap.put('Position__c', StaticUtils.getPicklistValues(Observation__c.Position__c.getDescribe()));
            testPicklistMap.put('SectionTower__c', StaticUtils.getPicklistValues(Observation__c.SectionTower__c.getDescribe()));
            testPicklistMap.put('InitialQualification__c', StaticUtils.getPicklistValues(Observation__c.InitialQualification__c.getDescribe()));
            testPicklistMap.put('Department__c', StaticUtils.getPicklistValues(OccupationCertification__c.Department__c.getDescribe()));
            testPicklistMap.put('Craft__c', StaticUtils.getPicklistValues(OccupationCertification__c.Craft__c.getDescribe()));
            
            // Set up Piclist value for Test Entry
            Map<String, List<String>> testEntryPicklistMap = new Map<String, List<String>>();
            testEntryPicklistMap.put('Result__c', StaticUtils.getPicklistValues(Observation__c.Result__c.getDescribe()));
            testEntryPicklistMap.put('PersonallyObserved__c', StaticUtils.getPicklistValues(Observation__c.PersonallyObserved__c.getDescribe()));
            testEntryPicklistMap.put('Discussed_with_Employee__c', StaticUtils.getPicklistValues(Observation__c.DiscussedWithEmployee__c.getDescribe()));
            testEntryPicklistMap.put('SupervisorsCommentSelection__c', StaticUtils.getPicklistValues(Observation__c.SupervisorsCommentSelection__c.getDescribe()));
            testEntryPicklistMap.put('TimeHH__c', StaticUtils.getPicklistValues(Observation__c.TimeHH__c.getDescribe()));
            testEntryPicklistMap.put('TimeMM__c', StaticUtils.getPicklistValues(Observation__c.TimeMM__c.getDescribe()));
            testEntryPicklistMap.put('MpSg__c', StaticUtils.getPicklistValues(Observation__c.MpSg__c.getDescribe()));
            testEntryPicklistMap.put('SpeedCheckMethod__c', StaticUtils.getPicklistValues(Observation__c.SpeedCheckMethod__c.getDescribe()));
            testEntryPicklistMap.put('QualificationStatus__c', StaticUtils.getPicklistValues(Observation__c.QualificationStatus__c.getDescribe()));
            response.put('testEntryPicklistMap', JSON.serialize(testEntryPicklistMap));

            testPicklistMap.put('Result__c', StaticUtils.getPicklistValues(Observation__c.Result__c.getDescribe()));
            testPicklistMap.put('PersonallyObserved__c', StaticUtils.getPicklistValues(Observation__c.PersonallyObserved__c.getDescribe()));
            testPicklistMap.put('Discussed_with_Employee__c', StaticUtils.getPicklistValues(Observation__c.DiscussedWithEmployee__c.getDescribe()));
            testPicklistMap.put('SupervisorsCommentSelection__c', StaticUtils.getPicklistValues(Observation__c.SupervisorsCommentSelection__c.getDescribe()));
            response.put('testPicklistMap', JSON.serialize(testPicklistMap));

            // Set up Test questions wrapper object for score grid
            response.put('testQuestionMap', JSON.serialize(getTestQuestionMap()));            
            // Set up Score List for each record type
            response.put('scoreListMap', JSON.serialize(getScoreListMap(obsRecordTypes))); 
            response.put('needImprovementMap', JSON.serialize(getNeedImprovementMap(obsRecordTypes)));
            response.put('currentUser', getUserFullName());
            
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
            response.put('errorMsg', e.getMessage());
            response.put('consolelog', e.getStackTraceString());
            System.debug(e.getStackTraceString());
            System.debug('Exception error: ' + e.getMessage());
        }
        System.debug('AURAENABLED RevSys_Obs_RecordDetailCtrl.initializeTestSelectionComponent() END');
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
        System.debug('AURAENABLED RevSys_Obs_RecordDetailCtrl.searchForEmployee() START');
        Map<String, String> response = new Map<String, String>();
        try {
            String desiredFields = String.valueOf(REVSYS_Custom_Settings__c.getValues('Obs Search Employee Field Names').CsvString__c);
            String whereClause = '';
            // Setting up conditional statement for Name
            if (String.isNotBlank(params.get('searchKey'))) {
                String searchKey = String.escapeSingleQuotes(params.get('searchKey'));
                for (String keyWord : searchKey.split(' ')) {
                    whereClause += ' AND (Name LIKE \'%' + keyWord + '%\' OR Personnel_ID__c LIKE \'%' + keyWord + '%\' OR Employee_ID__c LIKE \'%' + keyWord + '%\')';
                }
            }
            // Setting up conditional statement for all Craft and Department
            String allCraftDeptWhereClause = '';
            if (String.isNotBlank(params.get('allCraftDeptMapJSON'))) {
                Map<String, Boolean> allCraftDeptMap = (Map<String, Boolean>)JSON.deserialize(params.get('allCraftDeptMapJSON'), Map<String, Boolean>.class);
                if (allCraftDeptMap != null && !allCraftDeptMap.isEmpty()) {
                    allCraftDeptWhereClause += ' Department IN (';
                    for (String dept: allCraftDeptMap.keySet()) {
                        allCraftDeptWhereClause += '\'' + String.escapeSingleQuotes(dept) + '\',';
                    }
                    allCraftDeptWhereClause = allCraftDeptWhereClause.removeEnd(',') + ')';
                }
            }
            // Setting up conditional statement for Department
            String deptCraftWhereClause = '';
            if (String.isNotBlank(params.get('deptCraftMapJSON'))) {
                Map<String, Map<String, Boolean>> deptCraftMap = (Map<String, Map<String, Boolean>>)JSON.deserialize(params.get('deptCraftMapJSON'), Map<String, Map<String, Boolean>>.class);
                if (deptCraftMap != null) {
                    deptCraftWhereClause += ' (';
                    String tempWhere = '';
                    for (String dept: deptCraftMap.keySet()) {
                        if (!deptCraftMap.get(dept).isEmpty()) {
                            tempWhere += ' OR (Department = \'' + String.escapeSingleQuotes(dept) + '\' AND Craft__c IN (';
                            for (String craft: deptCraftMap.get(dept).keySet()) {
                                tempWhere += '\'' + String.escapeSingleQuotes(craft) + '\',';
                            }
                            tempWhere = tempWhere.removeEnd(',') + '))';
                        }
                    }
                    deptCraftWhereClause += tempWhere.removeStart(' OR ') + ')';
                }
            }
            whereClause = whereClause.removeStart(' AND');
            if (String.isNotBlank(whereClause)) {
                whereClause += ' AND';
            }
            if (String.isNotBlank(allCraftDeptWhereClause) && String.isNotBlank(deptCraftWhereClause)) {
                whereClause += ' (' + allCraftDeptWhereClause + ' OR ' + deptCraftWhereClause + ')';
            } else if (String.isNotBlank(allCraftDeptWhereClause)) {
                whereClause += ' (' + allCraftDeptWhereClause + ')';
            } else if (String.isNotBlank(deptCraftWhereClause)) {
                whereClause += ' (' + deptCraftWhereClause + ')';
            }
            
            String query = 'SELECT Id,' + desiredFields + ' FROM Contact';
            if (String.isNotBlank(whereClause)) {
                query += ' WHERE ' + whereClause.removeEnd(' AND');
            }
            query += ' ORDER BY Name, Department, Craft__c LIMIT 500';
            System.debug('search query : ' + query);
            
            List<Contact> empList = Database.query(query);
            if (empList != null && empList.size() >= 500) {
                response.put('limitBreak', 'There are over 500 results returned. Please make your search more specific for better results.');
            }
            
            List<StaticUtils.SearchTabularItem> resultList = new List<StaticUtils.SearchTabularItem>();
            for (Contact emp : empList) {
                StaticUtils.SearchTabularItem item = new StaticUtils.SearchTabularItem();
                item.selected = false;
                item.recordId = emp.Id;
                item.fieldNames = desiredFields.split(',');
                item.fieldValues = new List<String>();
                for (String fieldName : item.fieldNames) {
                    item.fieldValues.add(String.valueOf(emp.get(fieldName)));
                }
                resultList.add(item);
            }
            response.put('resultList', JSON.serialize(resultList));
            response.put('fieldLabels', JSON.serialize(getContactFieldLabels(desiredFields)));
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
            response.put('errorMsg', e.getMessage());
            response.put('consolelog', e.getStackTraceString());
            System.debug(e.getStackTraceString());
        }
        
        System.debug('AURAENABLED RevSys_Obs_RecordDetailCtrl.searchForEmployee() END');
        return response;
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
                String scoreListString = String.valueOf(REVSYS_Custom_Settings__c.getValues('Observation ' + rt.Name + ' Score List').CsvString__c);
                
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
    * @Name: getScoreListMap
    * @Description
    * Fetch the list of need improvement scores from custom settings
    *————————————————————————————————————————————————————
    * @param    obsRecordTypes                      List of Record Types
    * @return   Map<String, Map<String, Boolean>>    Map of need imrpovement scores goruped by Record Type Id
    *————————————————————————————————————————————————————
    **/
  private static Map<String, Map<String, Boolean>> getNeedImprovementMap(List<RecordType> obsRecordTypes) {
        Map<String, Map<String, Boolean>> needImprovementMap = new Map<String, Map<String, Boolean>>();
        for (RecordType rt: obsRecordTypes) {
            if (REVSYS_Custom_Settings__c.getValues('Obs ' + rt.Name + ' Need Improvement') != null) {
                String scoreListString = String.valueOf(REVSYS_Custom_Settings__c.getValues('Obs ' + rt.Name + ' Need Improvement').CsvString__c);
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
                String requiredFields = String.valueOf(REVSYS_Custom_Settings__c.getValues(head + rt.Name + tail).CsvString__c);
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
    * @Name: getOSRWrapperList
    * @Description
    * Retrieve OccupationSpecificRequirement__c records and organize them into Map of test numbers with mapping of department/craft
    *————————————————————————————————————————————————————
    * @return   List<SPARTN_OccSpecReqWrapper>        List of the ObservationSpecificRequirement Wrapper objects
    *————————————————————————————————————————————————————
    **/ 
   private static List<SPARTN_OccSpecReqWrapper> getOSRWrapperList() {
        List<OccupationSpecificRequirement__c> osrList = [
            SELECT Id, DepartmentCraft__r.Department__c, DepartmentCraft__r.Craft__c, Observation__r.TestNumber__c, Observation__r.TestName__c, Observation__r.SpeedCheckMethod__c
            FROM OccupationSpecificRequirement__c 
            WHERE RecordType.DeveloperName = :Label.RevSys_OccSpecificReq_RT_API_Dept_Craft AND Status__c = :Label.RevSys_Generic_Status_Active
            ORDER BY Observation__r.TestNumber__c
        ];
        List<SPARTN_OccSpecReqWrapper> osrWrapperList = new List<SPARTN_OccSpecReqWrapper>();
        Set<String> testNumberSet = new Set<String>();
        Integer index = 0;
        for (OccupationSpecificRequirement__c osr : osrList) {
            if (String.isNotBlank(osr.Observation__r.TestNumber__c)) {
                
                String department = String.valueOf(osr.DepartmentCraft__r.Department__c);
                String craft = String.valueOf(osr.DepartmentCraft__r.Craft__c);
                if (testNumberSet.add(osr.Observation__r.TestNumber__c)) {
                    osrWrapperList.add(new SPARTN_OccSpecReqWrapper(osr));
                    index = osrWrapperList.size() - 1;
                }
                // Set value to first layer of the Map - department
                if (String.isNotBlank(department) && osrWrapperList[index].deptCraftMap.get(department) == null) {
                    osrWrapperList[index].deptCraftMap.put(department, new Map<String, Boolean>());
                }
                // Set value to the second layer of the Map - craft
                if (String.isNotBlank(craft) && osrWrapperList[index].deptCraftMap.get(department) != null) {
                    osrWrapperList[index].deptCraftMap.get(department).put(craft, true);
                }
                // Set value to map that perform search for All craft's departments
                if (craft == 'All') {
                    osrWrapperList[index].allCraftDeptMap.put(department, true);
                }
            }
        }
        
        return osrWrapperList;
    }

    private static Map<String, List<Finding__c>> getTestQuestionMap() {
        
        List<String> myCatToSelectList = new List<String>();
        
        myCatToSelectList.add(RevSys_StaticUtility.OBSERVATION_TEST1872_RECTYPE_NAME);
        myCatToSelectList.add(RevSys_StaticUtility.OBSERVATION_TEST1875_RECTYPE_NAME);
        myCatToSelectList.add(RevSys_StaticUtility.OBSERVATION_TEST1876_RECTYPE_NAME);
        myCatToSelectList.add(RevSys_StaticUtility.OBSERVATION_TEST1877_RECTYPE_NAME);
        myCatToSelectList.add(RevSys_StaticUtility.OBSERVATION_TEST1878_RECTYPE_NAME);

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
                myNewFinding.Score__c        = null;
                myNewFinding.IsCriticalItem__c = myQuestion.IsCriticalItem__c;
                 

                findingForQuestionsList.add(myNewFinding); 
            }

            testQuestionMap.put(testName, findingForQuestionsList);
        }     
        return testQuestionMap;
    }
    
/* Not used
    private static Map<String, String> getScoreListMapsadsd() {

        Map<String, String> scoreListByRecordTypeMap = new Map<String, String>();

        for (RecordType rt : [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Observation__c' AND IsActive = TRUE]) {
            scoreListByRecordTypeMap.put(rt.Name, String.valueOf(REVSYS_Custom_Settings__c.getValues('Observation ' + rt.Name + ' Score List').CsvString__c));
        }
        
        return scoreListByRecordTypeMap;
    } 
*/
    /**
    *————————————————————————————————————————————————————
    * @Name: multiTestFormSaveAndPreview
    * @Description
    * Insert tests for each employee per test numbers chosen
    * Requery and process wrapper object to manage UI layout
    *————————————————————————————————————————————————————
    * @param    params                  Map of values retrieved from Lightning Component
    * @return   Map<String, String>     Map of response values to be used by Lightning Component
    *————————————————————————————————————————————————————
    **/ 
   @AuraEnabled
    public static Map<String, String> multiTestFormSaveAndPreview(Map<String, String> params) {
        System.debug('AURAENABLED RevSys_Obs_RecordDetailCtrl.multiTestFormSaveAndPreview() START');
        Map<String, String> response = new Map<String, String>();
        Savepoint sp = Database.setSavepoint();
        try {
            List<SPARTN_TestEntryWrapper> teWrapperList = (List<SPARTN_TestEntryWrapper>)JSON.deserialize(params.get('testEntryWrapperListJSON'), List<SPARTN_TestEntryWrapper>.class);
            System.debug('### teWrapperList JSON : ' + params.get('testEntryWrapperListJSON'));
            System.debug('### teWrapperList : ' + teWrapperList);
            List<Observation__c> toBeInsertedList = new List<Observation__c>();
            for (SPARTN_TestEntryWrapper teWrapper : teWrapperList) {
                
                for (SPARTN_EmployeeWrapper empWrapper : teWrapper.empList) {
                    if (empWrapper.selected) {
                        Observation__c cloneObs = teWrapper.obs.clone();
                        cloneObs.Employee__c = empWrapper.recordId;
                        toBeInsertedList.add(cloneObs);
                        cloneObs = null;
                    }
                }
                
            }
            insert toBeInsertedList;
            response.put('trWrapperList', JSON.serialize(getTestResultWrapperList(toBeInsertedList)));
            //delete toBeInsertedList;
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
        
        System.debug('AURAENABLED RevSys_Obs_RecordDetailCtrl.multiTestFormSaveAndPreview() END');
        return response;
    }
    
    @AuraEnabled
    public static Map<String, String> multiTestFormSaveAndPreviewNon1872(Map<String, String> params) {
        System.debug('AURAENABLED RevSys_Obs_RecordDetailCtrl.multiTestFormSaveAndPreviewNon1872() START');
        Map<String, String> response = new Map<String, String>();
        Savepoint sp = Database.setSavepoint();
        try {
            List<String> empIdList = (List<String>)JSON.deserialize(params.get('empListJSON'), List<String>.class);
            List<Observation__c> toBeInsertedObsList = new List<Observation__c>();
            List<Finding__c> toBeInsertedFindingList = new List<Finding__c>();
            String needImprovement = String.valueOf(params.get('needImprovement'));
            String comments = String.valueOf(params.get('comments'));
            for (String empId : empIdList) {
                Observation__c obs = (Observation__c)JSON.deserialize(params.get('obsJSON'), Observation__c.class);
                obs.Employee__c = empId;
                obs.NeedsImprovement__c = needImprovement;
                obs.Comments__c = comments;
                toBeInsertedObsList.add(obs);
            }
           // RevSys_ObservationHandler.donotExecute = true;
            insert toBeInsertedObsList;
            //RevSys_ObservationHandler.donotExecute = false;
            
            for (Observation__c insertedObs : toBeInsertedObsList) {
                List<Finding__c> findingList = (List<Finding__c>)JSON.deserializeStrict(params.get('testQuestionListJSON'), List<Finding__c>.class);
                for (Finding__c finding : findingList) {
                    finding.Observation__c = insertedObs.Id;
                    toBeInsertedFindingList.add(finding);
                }
            }
            insert toBeInsertedFindingList;
            System.debug('=====> toBeInsertedObsList: ' + toBeInsertedObsList[0]);
            response.put('trWrapperList', JSON.serialize(getTestResultWrapperListWithFinding(toBeInsertedObsList)));
            //delete toBeInsertedList;
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
        
        System.debug('AURAENABLED RevSys_Obs_RecordDetailCtrl.multiTestFormSaveAndPreviewNon1872() END');
        return response;
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Name: multiTestFormSaveAndPreview
    * @Description
    * Insert tests for each employee per test numbers chosen
    * Requery and process wrapper object to manage UI layout
    *————————————————————————————————————————————————————
    * @param    params                  Map of values retrieved from Lightning Component
    * @return   Map<String, String>     Map of response values to be used by Lightning Component
    *————————————————————————————————————————————————————
    **/ 
   @AuraEnabled
    public static Map<String, String> multiTestFormSaveAndSubmit(Map<String, String> params) {
        System.debug('AURAENABLED RevSys_Obs_RecordDetailCtrl.multiTestFormSaveAndPreview() START');
        Map<String, String> response = new Map<String, String>();
        Savepoint sp = Database.setSavepoint();
        try {
            boolean isForm1872 = true;
            List<RevSys_TestResultWrapper> trWrapperList = (List<RevSys_TestResultWrapper>)JSON.deserialize(params.get('trWrapperListJSON'), List<RevSys_TestResultWrapper>.class);
            system.debug('trWrapperList final : ' + JSON.serialize(trWrapperList));
            List<Observation__c> toBeSubmittedList = new List<Observation__c>();
            List<Finding__c> toBeUpdatedFindingList = new List<Finding__c>();
            
            for (RevSys_TestResultWrapper trWrapper : trWrapperList) {
                for (Observation__c obs : trWrapper.testResults) {
                    if(obs.RecordType.Name != 'Form-1872'){
                        isForm1872 = false;
                    }
                    //toBeSubmittedList.add(new Observation__c(Id = obs.Id, Status__c = Label.RevSys_Observation_Status_Complete));
                    obs.Status__c = Label.RevSys_Observation_Status_Complete;
                    obs.OperatedFromCode__r = null;
                    obs.OperatedToCode__r = null;
                    obs.NearestStationInterlocking__r = null;
                    toBeSubmittedList.add(obs);
                }
                
                if(!isForm1872 && trWrapper.findingList.size() > 0){
                    for (Finding__c finding : trWrapper.findingList) {
                        toBeUpdatedFindingList.add(finding);
                    }
                }
            }
            system.debug('isForm1872 : ' + isForm1872);
            system.debug('toBeSubmittedList : ' + toBeSubmittedList);
            system.debug('toBeUpdatedFindingList : ' + toBeUpdatedFindingList);
            
            if(toBeUpdatedFindingList.size() > 0) {
                update toBeUpdatedFindingList;
            }

            update toBeSubmittedList;
                      
            if(isForm1872){
              response.put('trWrapperList', JSON.serialize(getTestResultWrapperList(toBeSubmittedList)));    
            } else {
                response.put('trWrapperList', JSON.serialize(getTestResultWrapperListWithFinding(toBeSubmittedList)));
            }
      system.debug('trWrapperList response : ' + response);
            
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
        
        System.debug('AURAENABLED RevSys_Obs_RecordDetailCtrl.multiTestFormSaveAndPreview() END');
        return response;
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Name: reloadRevSys_TestResultWrapper
    * @Description
    * Requery Observations and add them to RevSys_TestResultWrapper 
    * to show the updated values on the TestResult page after user edit observation individually
    * @Author: Boom Bertetti 12/15/2017
    *————————————————————————————————————————————————————
    * @param    params                  Map of values retrieved from Lightning Component
    * @return   Map<String, String>     Map of response values to be used by Lightning Component
    *————————————————————————————————————————————————————
    **/ 
 @AuraEnabled
    public static Map<String, String> reloadTestResultWrapper(Map<String, String> params) {
        System.debug('AURAENABLED RevSys_Obs_RecordDetailCtrl.reloadTestResultWrapper() START');
        Map<String, String> response = new Map<String, String>();
        try {
            List<RevSys_TestResultWrapper> trWrapperList = (List<RevSys_TestResultWrapper>)JSON.deserialize(params.get('trWrapperListJSON'), List<RevSys_TestResultWrapper>.class);
            List<Observation__c> updatedObservationsList = new List<Observation__c>();
            for (RevSys_TestResultWrapper trWrapper : trWrapperList) {
                for (Observation__c obs : trWrapper.testResults) {
                    updatedObservationsList.add(obs);
                }
            }
            if (params.get('RecordTypeName') == Label.RevSys_Observation_RT_Label_Test_1872) {
                response.put('trWrapperList', JSON.serialize(getTestResultWrapperList(updatedObservationsList)));
            } else {
                response.put('trWrapperList', JSON.serialize(getTestResultWrapperListWithFinding(updatedObservationsList)));
            }
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
            response.put('errorMsg', e.getMessage());
            response.put('consolelog', e.getStackTraceString());
            System.debug(e.getStackTraceString());
        }
        
        System.debug('AURAENABLED RevSys_Obs_RecordDetailCtrl.reloadTestResultWrapper() END');
        return response;
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Name: saveEditedTestQuestions
    * @Description
    * Update the list of finding and need improvement
    * @Author: Duy Tran 01/10/2018
    *————————————————————————————————————————————————————
    * @param    params                  Map of values retrieved from Lightning Component
    * @return   Map<String, String>     Map of response values to be used by Lightning Component
    *————————————————————————————————————————————————————
    **/ 
   @AuraEnabled
    public static Map<String, String> saveEditedTestQuestions(Map<String, String> params) {
    System.debug('AURAENABLED RevSys_Obs_RecordDetailCtrl.saveEditedTestQuestions() START');
        Map<String, String> response = new Map<String, String>();
        try {
            List<Finding__c> findingList = (List<Finding__c>)JSON.deserialize(params.get('findingListJSON'), List<Finding__c>.class);
            update findingList;
            Observation__c obs = new Observation__c(
                Id = params.get('obsId'),
                NeedsImprovement__c = params.get('needImprovement'),
                Comments__c = params.get('comments')
            );
            update obs;
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
            response.put('errorMsg', e.getMessage());
            response.put('consolelog', e.getStackTraceString());
            System.debug(e.getStackTraceString());
        }
        
        System.debug('AURAENABLED RevSys_Obs_RecordDetailCtrl.saveEditedTestQuestions() END');
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
    
    private static List<RevSys_TestResultWrapper> getTestResultWrapperListWithFinding(List<Observation__c> observationsList) {
        List<Observation__c> obsList;

        Set<Id> observationIdsSet = new Set<Id>();

        for (Observation__c obs : observationsList) {
            observationIdsSet.add(obs.Id);
        }

        SelectorWrapper sw = new ObservationSelector(observationIdsSet).selectByIdWithFindings();
        if (sw.ErrorMessage == null) {
            obsList = (List<Observation__c>)sw.SObjectList;
        }
        else {
            System.debug('getTestResultWrapperListWithFinding error');
        }

        
        Set<String> empIdSet = new Set<String>();
        List<RevSys_TestResultWrapper> trWrapperList = new List<RevSys_TestResultWrapper>();
        RevSys_TestResultWrapper trWrapper;
        for (Observation__c obs : obsList) {
            if (empIdSet.add(obs.Employee__r.Name)) {
                trWrapper = new RevSys_TestResultWrapper();
                trWrapper.employeeName = obs.Employee__r.Name;
                trWrapper.testResults = new List<Observation__c>();
                trWrapper.findingList = new List<Finding__c>();
                trWrapperList.add(trWrapper);
            }
            trWrapper.testResults.add(obs);
            trWrapper.findingList.addAll(obs.Findings__r);
        }
        
        System.debug('trWrapperList ====> ' + trWrapperList);
        return trWrapperList;
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Name: initializeObservationDetailPage
    * @Description
    * Query for Finding records that belong to current Observation record
    * Process each record and generate appropriate wrapper objects
    *————————————————————————————————————————————————————
    * @param    params                  Map of values retrieved from Lightning Component
    * @return   Map<String, String>     Map of response values to be used by Lightning Component
    *————————————————————————————————————————————————————
    **/ 
   @AuraEnabled
    public static Map<String, String> initializeObservationDetailPage(Map<String, String> params) {
        System.debug('AURAENABLED RevSys_Obs_RecordDetailCtrl.initializeObservationDetailPage() START');
        Map<String, String> response = new Map<String, String>();

        Id obsId = Id.valueOf(params.get('obsId'));
        Set<Id> observationIdsSet = new Set<Id>{obsId};
        
        List<Observation__c> myObservations;
        SelectorWrapper sw = new ObservationSelector(observationIdsSet).selectByIdWithFindings();
        if (sw.ErrorMessage == null) {
            myObservations = (List<Observation__c>)sw.SObjectList;
        }
        else {
            response.put('errorMsg',sw.ErrorMessage);
            return response;
        }
        RecordType rt;
        try {
            Observation__c obs = myObservations[0];
            response.put('obs', JSON.serialize(obs));

            List<Finding__c> findingList = new List<Finding__c>();
            if (obs != null) {
                for (Finding__c finding : obs.Findings__r) {
                    findingList.add(finding);
                }
            }

            rt = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Observation__c' AND Id = :obs.RecordTypeId LIMIT 1];
            response.put('findingList', JSON.serialize(findingList));
            System.debug('obs.RecordType.Name : ' + obs.RecordType.Name);
            String scoreListString = String.valueOf(REVSYS_Custom_Settings__c.getValues('Observation ' + obs.RecordType.Name + ' Score List').CsvString__c);
            response.put('scoreListString', scoreListString);
            response.put('recordtype', JSON.serialize(rt));
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
            response.put('errorMsg', e.getMessage());
            response.put('consolelog', e.getStackTraceString());
            System.debug(e.getStackTraceString() + e.getLineNumber() + e.getMessage());
        }

        // Generate required fields mapping
        response.put('allInfoReqFieldsMap', JSON.serialize(getAllRequiredFieldsMap('Obs ', ' Info Required Fields', new List<RecordType>{rt})));
        response.put('allEntryReqFieldsMap', JSON.serialize(getAllRequiredFieldsMap('Obs ', ' Entry Required Fields', new List<RecordType>{rt})));
        System.debug('=====> allInfoReqFieldsMap: '+ response.get('allInfoReqFieldsMap'));
                
        // Set up all Piclist value for Test result
        Map<String, List<String>> testPicklistMap = new Map<String, List<String>>();

        testPicklistMap.put('RailroadRule__c', StaticUtils.getPicklistValues(Observation__c.RailroadRule__c.getDescribe()));
        testPicklistMap.put('NearestStationOrInterlocking__c', StaticUtils.getPicklistValues(Observation__c.NearestStationOrInterlocking__c.getDescribe()));
        testPicklistMap.put('MpSg__c', StaticUtils.getPicklistValues(Observation__c.MpSg__c.getDescribe()));
        testPicklistMap.put('SpeedCheckMethod__c', StaticUtils.getPicklistValues(Observation__c.SpeedCheckMethod__c.getDescribe()));
        testPicklistMap.put('State__c', new List<String>());
        testPicklistMap.put('RegionProperty__c', StaticUtils.getPicklistValues(Observation__c.RegionProperty__c.getDescribe()));
        testPicklistMap.put('TimeHH__c', StaticUtils.getPicklistValues(Observation__c.TimeHH__c.getDescribe()));
        testPicklistMap.put('TimeMM__c', StaticUtils.getPicklistValues(Observation__c.TimeMM__c.getDescribe()));
        testPicklistMap.put('Method__c', StaticUtils.getPicklistValues(Observation__c.ObservationMethod__c.getDescribe()));
        testPicklistMap.put('Position__c', StaticUtils.getPicklistValues(Observation__c.Position__c.getDescribe()));
        testPicklistMap.put('SectionTower__c', StaticUtils.getPicklistValues(Observation__c.SectionTower__c.getDescribe()));
        testPicklistMap.put('InitialQualification__c', StaticUtils.getPicklistValues(Observation__c.InitialQualification__c.getDescribe()));
        testPicklistMap.put('Department__c', StaticUtils.getPicklistValues(OccupationCertification__c.Department__c.getDescribe()));
        testPicklistMap.put('Craft__c', StaticUtils.getPicklistValues(OccupationCertification__c.Craft__c.getDescribe()));
        testPicklistMap.put('Result__c', StaticUtils.getPicklistValues(Observation__c.Result__c.getDescribe()));
        testPicklistMap.put('PersonallyObserved__c', StaticUtils.getPicklistValues(Observation__c.PersonallyObserved__c.getDescribe()));
        testPicklistMap.put('Discussed_with_Employee__c', StaticUtils.getPicklistValues(Observation__c.DiscussedWithEmployee__c.getDescribe()));
        testPicklistMap.put('SupervisorsCommentSelection__c', StaticUtils.getPicklistValues(Observation__c.SupervisorsCommentSelection__c.getDescribe()));
        testPicklistMap.put('QualificationStatus__c', StaticUtils.getPicklistValues(Observation__c.QualificationStatus__c.getDescribe()));
        response.put('testPicklistMap', JSON.serialize(testPicklistMap));

        // Create field label map from field set
        Map<String, Schema.SObjectField> obsFieldMap = Schema.SObjectType.Observation__c.fields.getMap();
        Map<String, String> obsFieldLabelMap = new Map<String, String>();
        for (String fieldDevName : obsFieldMap.keySet()) {
            obsFieldLabelMap.put(fieldDevName, String.valueOf(obsFieldMap.get(fieldDevName).getDescribe().getLabel()));
        //    String fieldType = String.valueOf(obsFieldMap.get(fieldDevName).getDescribe().getType());
        //    if (fieldType.equalsIgnoreCase('picklist')) {
        //        testPicklistMap.put(fieldDevName, StaticUtils.getPicklistValues(obsFieldMap.get(fieldDevName).getDescribe()));

        //    }
        }
        System.debug('=====> field label map: '+ obsFieldLabelMap.get('date__c'));
        response.put('obsFieldLabelMap', JSON.serialize(obsFieldLabelMap));
    //    response.put('testPicklistMap', JSON.serialize(testPicklistMap));
        
        System.debug('AURAENABLED RevSys_Obs_RecordDetailCtrl.initializeObservationDetailPage() END');
        return response;
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Name: saveFindings
    * @Description
    * Parse the wrapper objects and retrieve all Finding records for update
    *————————————————————————————————————————————————————
    * @param    params                  Map of values retrieved from Lightning Component
    * @return   Map<String, String>     Map of response values to be used by Lightning Component
    *————————————————————————————————————————————————————
    **/ 
   @AuraEnabled
    public static Map<String, String> saveFindings(Map<String, String> params) {
        System.debug('AURAENABLED RevSys_Obs_RecordDetailCtrl.saveFindings() START');
        Map<String, String> response = new Map<String, String>();
        Integer questionLastModifiedVersion=0;
        Savepoint sp = Database.setSavepoint();
        try {
            if (String.isNotBlank(params.get('findingListJSON'))) {
                Set<Id> obsIdSet = new set<Id>();
                obsIdSet.add(params.get('obsId'));
                System.debug('obsIdSet : ' + obsIdSet);
                
                List<Observation__c> myObservations = new list<Observation__c>();
                SelectorWrapper sw = new ObservationSelector(obsIdSet).selectById();
                
                if (sw.ErrorMessage == null) {
                    myObservations = (List<Observation__c>)sw.SObjectList;
                    if(myObservations.size()>0){
                        questionLastModifiedVersion = (Integer) myObservations.get(0).QuestionLastModifiedVersion__c;
                    }                    
     
                }                               
                
                List<Finding__c> findingList = (List<Finding__c>)JSON.deserialize(params.get('findingListJSON'), List<Finding__c>.class);
                if (!findingList.isEmpty()) {
                    Integer totalScore = 0, numFinding = 0;
                    for (Finding__c finding : findingList) {
                        System.debug('finding.Version Number : ' + finding.QuestionLastModifiedVersion__c +'questionLastModifiedVersion'+questionLastModifiedVersion);
                     finding.QuestionLastModifiedVersion__c = questionLastModifiedVersion;
                        if (finding.Score__c > 0) { 
                          
                            totalScore += Integer.valueOf(finding.Score__c);                            
                            numFinding++;
                        }
                    }
                    update findingList;
                  System.debug('version number : ' + questionLastModifiedVersion);
                    System.debug('findingList : ' + findingList);
                    Observation__c obs = new Observation__c(
                        Id = params.get('obsId'),
                        OverallScore__c = (numFinding > 0) ? (totalScore / numFinding) : 0,
                        QuestionLastModifiedVersion__c=(questionLastModifiedVersion != null) ? questionLastModifiedVersion + 1 : 1
                    );
                    if (String.isNotBlank(params.get('obsStatus'))) {
                        obs.Status__c = params.get('obsStatus');
                    }
                    update obs;
                    System.debug('obs : ' + obs);
                    response.put('obs', JSON.serialize(obs));
                }
            }
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
        
        System.debug('AURAENABLED RevSys_Obs_RecordDetailCtrl.saveFindings() END');
        return response;
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Name: getObservation
    * @Description
    * Fetch the current saved observation to facilitate cloning
    * @Author:- Tejas
    *————————————————————————————————————————————————————
    * @param    obsId               Observation Id  retrieved from Lightning Component
    * @return   Observation__c      Observation object be used by Lightning Component
    *————————————————————————————————————————————————————
    **/ 
    @AuraEnabled
    public static Observation__c getObservation(Id obsId)
    {
        Set<Id> observationIdsSet = new Set<Id>{obsId};
        
        List<Observation__c> myObservations;
        SelectorWrapper sw = new ObservationSelector(observationIdsSet).selectAllFieldsById();

        if (sw.ErrorMessage == null) {
            myObservations = (List<Observation__c>)sw.SObjectList;
            return  myObservations[0];
        }
        else {
            return null;
        }       
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Name: getObservation
    * @Description
    * Fetch the current saved observation to facilitate cloning
    * @Author:- Tejas
    *————————————————————————————————————————————————————
    * @param    obsId                   Observation Id  retrieved from Lightning Component
    * @return   Observation__c      Observation object be used by Lightning Component
    *————————————————————————————————————————————————————
    **/ 
    @AuraEnabled
    public static String updateObservationRecord(Observation__c obs)
    {
        update obs;
        return null;
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

    public static String getUserFullName()
    {
        return UserInfo.getName();
    }
    
}
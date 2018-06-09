/**
*————————————————————————————————————————————————————
* @Name             EIS_Audit_BodyCtrl
* @Author           Duy Tran
* @Created Date     07-05-2017
* @Used By          EIS_Audit_Body.cmp
*————————————————————————————————————————————————————
* @Description
* Controller class to generate and handle DML operations for Audit form
* 
*————————————————————————————————————————————————————
* @Changes
* Lakshmi 12/20/2017 - Changes to fix ARSS-142 
**/
public without sharing class EIS_Audit_BodyCtrl {
    /**
    *————————————————————————————————————————————————————
    * @Description
    * Wrapper classes to control ligtning pages
    * Allow safer parsing of request/response data with lightning pages
    *————————————————————————————————————————————————————
    **/
/********** BEGIN WRAPPER CLASSES **********/
    // Represent the information a side tab could control
    public class SideTab {
        public String label {get; set;}
        public Integer numberOfCA {get; set;}
        public Integer departmentScore {get; set;}
        public Boolean selected {get; set;}
        public Boolean corrected {get; set;}
        public List<QuestionSection> customSectionList {get; set;}
        
        public SideTab(String sideTabName) {
            label = sideTabName;
            numberofCA = 0;
            selected = false;
            corrected = false;
            customSectionList = new List<QuestionSection>();
        }
        public SideTab(String sideTabName, List<QuestionSection> sectionList) {
            label = sideTabName;
            customSectionList = sectionList;
        }
    }
    // Represent information under a section
    public class QuestionSection {
        public String sideTabName {get; set;}
        public String sectionHeader {get; set;}
        public Boolean display {get; set;}
        public List<Question> customQuestionList {get; set;}
        
        public QuestionSection(String header, String tabName) {
            sideTabName = tabName;
            sectionHeader = header;
            customQuestionList = new List<Question>();
        }
    }
    // Represent information under a question
    public class Question {
        public Boolean display {get; set;}
        public EIS_Audit_Question__mdt metaQuestion {get; set;}
        public Questions__c question {get; set;}
        public List<Observation> customObservationList {get; set;}
        public Question(EIS_Audit_Question__mdt metaQ, String auditId) {
            // Creation of a Question__c record, all below fields are required because default values don't exist until after record is inserted
            // These default values are needed for styling control on the front end
            question = new Questions__c(
                RecordTypeId = EIS_StaticUtils.QUESTIONS_INSPECTION_RTID,
                Audit_Inspections__c = auditId,
                Points__c = Integer.valueOf(Label.EIS_Question_Points_PV), 
                EIS_Issued__c = false, EIS_Corrected__c = true, EIS_Criticality__c = Label.EIS_Questions_Criticality_Critical,
                EIS_Count_Finding_Transportation__c = 0, EIS_Count_Finding_Engineering__c = 0, EIS_Count_Finding_Environment__c = 0, EIS_Count_Finding_Material__c = 0, 
                EIS_Count_Finding_Mechanical__c = 0, EIS_Count_Repeat_Transportation__c = 0, EIS_Count_Repeat_Engineering__c = 0, EIS_Count_Repeat_Environment__c = 0, 
                EIS_Count_Repeat_Material__c = 0, EIS_Count_Repeat_Mechanical__c = 0, EIS_Observation_Level__c = Label.EIS_Questions_Obs_Level_PV,
                EIS_Metadata_Question_Id__c = metaQ.Question_Id__c,
                EIS_Question_Text__c = metaQ.Question_Name__c,
                EIS_Qualifier_Name__c = metaQ.Qualifier_Name__c,
                EIS_Protocol_Name__c = metaQ.Protocol_Name__c
            );
            customObservationList = new List<Observation>();
            metaQuestion = metaQ;
        }
        public Question(Boolean display, Questions__c question, List<Observation> customObservationList) {
            this.display = display;
            this.question = question;
            this.customObservationList = customObservationList;
        }
    }
    // This wrapper class was created for Finding__c and has zero relation to the Observation sObject.
    public class Observation {
        public Finding__c finding {get; set;}
        public List<Corrective_Action__c> caList {get; set;}
        public List<PicklistItem> customDeptList {get; set;}
        // Constructor used for a new Observation that does not have any Finding record
        public Observation(List<String> departments, String regulatoryCitation) {
            finding = new Finding__c(
                EIS_Description__c = '', EIS_Regulatory_Citation__c = regulatoryCitation, RecordTypeId = EIS_StaticUtils.FINDING_INSPECTION_RTID
            );
            caList = new List<Corrective_Action__c>();
            caList.add(new Corrective_Action__c(RecordTypeId = EIS_StaticUtils.CORRECTIVEACTION_INSPECTION_RTID, EIS_Status__c = Label.EIS_Corrective_Action_Status_Not_Started));
            customDeptList = new List<PicklistItem>();
            for (String dept : departments) {
                customDeptList.add(new PicklistItem(dept, false));
            }
        }
        // Constructor used to create Observation with existing Finding record and its Corrective Action records
        public Observation(Finding__c finding, List<Corrective_Action__c> caList, List<String> findingDepartments) {
            this.finding = finding;
            if (caList == null || caList.isEmpty()) {
                this.caList = new List<Corrective_Action__c>();
                this.caList.add(new Corrective_Action__c(RecordTypeId = EIS_StaticUtils.CORRECTIVEACTION_INSPECTION_RTID, EIS_Status__c = Label.EIS_Corrective_Action_Status_Not_Started));
            } else {
                this.caList = caList;
            }
            customDeptList = new List<PicklistItem>();
            Set<String> selectedDepartments = new Set<String>();
            if (String.isNotBlank(finding.EIS_Responsible_Department__c)) {
                selectedDepartments.addAll(finding.EIS_Responsible_Department__c.split(';'));
            }
            for (String dept : findingDepartments) {
                customDeptList.add(new PicklistItem(dept, !selectedDepartments.add(dept)));
            }
        }
    }
    // Hold picklist values for custom picklist components
    public class PicklistItem {
        public String label {get; set;}
        public Boolean selected {get; set;}
        
        public PicklistItem(String itemLabel, Boolean itemSelected) {
            label = itemLabel;
            selected = itemSelected;
        }
    }
/********** END WRAPPER CLASSES **********/
    
    /**
    *————————————————————————————————————————————————————
    * @Description
    * Parse params data and generate Wrapper Class data to send to initialize Protocol Tabs
    *————————————————————————————————————————————————————
    * @param    params                  contains data to help querying the right information
    * @return   Map<String, String>     data to populate EIS_Audit_Body lightning component and its children
    *————————————————————————————————————————————————————
    **/
    @AuraEnabled
    public static Map<String, String> initializeProtocols(Map<String, String> params) {
        Map<String, String> response = new Map<String, String>();
        try {
            Audit_Inspections__c audit = getAuditById(params.get('auditId'));
            List<SideTab> protocols = getSideTabs(audit.EIS_Protocol_Name__c);
            protocols[0].selected = true;
            protocols[0].customSectionList = getProtocolQuestionSections(protocols[0].label, params.get('auditId'), audit.RecordType.DeveloperName);
            protocols.add(new SideTab(Label.EIS_Audit_Form_SideTab_Positive_Finding));
            
            // Determine if certain sections on the Audit form should be disabled
            setDisablesInResponse(response, audit);
            response.put('audit', JSON.serialize(audit));
            response.put('sideTabList', JSON.serialize(protocols));
        } catch (Exception e) {
            // Rollback not needed since there were no DML action
            response.put('errorMsg', e.getMessage());
        }
        return response;
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Description
    * Parse params data and generate Wrapper Class data to send to initialize Department Tabs
    *————————————————————————————————————————————————————
    * @param    params                  contains data to help querying the right information
    * @return   Map<String, String>     data to populate EIS_Audit_Body lightning component and its children
    *————————————————————————————————————————————————————
    **/
    @AuraEnabled
    public static Map<String, String> initializeDepartments(Map<String, String> params) {
        Map<String, String> response = new Map<String, String>();
        try {
            Audit_Inspections__c audit = getAuditById(params.get('auditId'));
            // TODO : Add Record Type specific values. Currently not possible for Salesforce APEX
            Schema.DescribeFieldResult fieldResult = Finding__c.EIS_Responsible_Department__c.getDescribe();
            Map<String, List<QuestionSection>> resultMap = getDepartmentQuestionSections(params.get('auditId'));
            List<SideTab> departments = new List<SideTab>();
            for (String dept : StaticUtils.getPicklistValues(fieldResult)) {
                if (resultMap != null && resultMap.get(dept) != null) {
                    departments.add(new SideTab(dept, resultMap.get(dept)));
                } else {
                    departments.add(new SideTab(dept));
                }
            }
            departments[0].selected = true;
            
            departments[0].departmentScore = Integer.valueOf(audit.EIS_Department_Score_Engineering__c);
            departments[1].departmentScore = Integer.valueOf(audit.EIS_Department_Score_Environment__c);
            departments[2].departmentScore = Integer.valueOf(audit.EIS_Department_Score_Material__c);
            departments[3].departmentScore = Integer.valueOf(audit.EIS_Department_Score_Mechanical__c);
            departments[4].departmentScore = Integer.valueOf(audit.EIS_Department_Score_Transportation__c);
            
            response.put('audit', JSON.serialize(audit));
            response.put('sideTabList', JSON.serialize(departments));
            setDisablesInResponse(response, audit);
        } catch (Exception e) {
            // Rollback not needed since there were no DML action
            response.put('errorMsg', e.getMessage());
        }
        
        return response;
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Description
    * Query for all Findings and Corrective Actions to check for empty required fields
    * Delete all records that are not part of the selected protocols
    *————————————————————————————————————————————————————
    * @param    audit                   Id of the current Audit / SFA form
    * @return   Map<String, String>     response Map that holds list of all missing values
    *————————————————————————————————————————————————————
    **/
    private static Map<String, String> submitFullFormValidation(Audit_Inspections__c audit) {
        Map<String, String> response = new Map<String, String>();
        
        // Get the set of protocols selected for this Audit record
        Set<String> selectedProtocols = new Set<String>();
        selectedProtocols.addAll(audit.EIS_Protocol_Name__c.split(';'));
        // Retrieve all findings, corrective actions, and their protocols to perform validation and forgotten records clean up
        List<Finding__c> findingList = [
            SELECT Id, EIS_Description__c, EIS_Responsible_Department__c, Question__c,
                Question__r.EIS_Protocol_Name__c, Question__r.EIS_Qualifier_Name__c, Question__r.EIS_Metadata_Question_Id__c,
                (SELECT Id, EIS_Description__c, EIS_Due_Date__c, EIS_Assigned_To__c FROM Corrective_Actions__r)
            FROM Finding__c WHERE Question__r.Audit_Inspections__c = :audit.Id
        ];
        // Map to store question Id of questions that are missing information in findings and corrective actions, grouped by protocol
        Map<String, Set<String>> missingQuestionMap = new Map<String, Set<String>>();
        for (String protocol : selectedProtocols) {
            missingQuestionMap.put(protocol, new Set<String>());
        }
        // Placeholder for forgotten records to be deleted
        List<Questions__c> deleteQuestions = new List<Questions__c>();
        List<Finding__c> deleteFindings = new List<Finding__c>();
        List<Corrective_Action__c> deleteCAs = new List<Corrective_Action__c>();
        
        for (Finding__c finding : findingList) {
            // If the protocol of finding is in the selected protocols list, then validation will happen
            if (selectedProtocols.contains(finding.Question__r.EIS_Protocol_Name__c)) {
                if (String.isBlank(finding.EIS_Description__c)) {
                    missingQuestionMap.get(finding.Question__r.EIS_Protocol_Name__c).add(finding.Question__r.EIS_Metadata_Question_Id__c);
                    response.put('hasError', 'true');
                } else {
                    for (Corrective_Action__c ca : finding.Corrective_Actions__r) {
                        if (String.isBlank(ca.EIS_Description__c) || String.isBlank(String.valueOf(ca.EIS_Due_Date__c)) || String.isBlank(ca.EIS_Assigned_To__c)) {
                            missingQuestionMap.get(finding.Question__r.EIS_Protocol_Name__c).add(finding.Question__r.EIS_Metadata_Question_Id__c);
                            response.put('hasError', 'true');
                            break;
                        }
                    }
                }
            } else {
                // Protocol isn't in the selected list, all related records will be added to forgotten list for clean up
                deleteQuestions.add(new Questions__c(Id = finding.Question__c));
                deleteFindings.add(finding);
                deleteCAs.addAll(finding.Corrective_Actions__r);
            }
        }
        
        if (!deleteQuestions.isEmpty()) {
            // Deletion of forgotten children records that should have been deleted
            audit.EIS_Count_Negative_Finding__c -= deleteFindings.size();
            update audit;
            delete deleteCAs; 
            delete deleteFindings; 
            delete deleteQuestions;
        }
        // List of Strings to display Protocols and Question Id of records that required attention
        List<String> missingQuestionList = new List<String>();
        for (String protocol : missingQuestionMap.keySet()) {
            if (!missingQuestionMap.get(protocol).isEmpty()) {
                String missingQuestionIds = protocol + ': ';
                for (String qId : missingQuestionMap.get(protocol)) {
                    missingQuestionIds += qId + ', ';
                }
                missingQuestionList.add(missingQuestionIds.removeEnd(', '));
            }
        }
        
        response.put('missingQuestionList', JSON.serialize(missingQuestionList));
        return response;
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Description
    * Handle actions made on the Header buttons. Update Audit/SFA form's approval status and its Corrective Action's status
    *————————————————————————————————————————————————————
    * @param    params                  contains data to help querying the right information
    * @return   Map<String, String>     data to populate EIS_Audit_Body lightning component and its children
    *————————————————————————————————————————————————————
    **/
    @AuraEnabled
    public static Map<String, String> updateSubmitStatus(Map<String, String> params) {
        Map<String, String> response = new Map<String, String>();
        
        Savepoint sp = Database.setSavepoint();
        try {
            Audit_Inspections__c audit = getAuditById(params.get('auditId'));
            String newSubmitStatus = params.get('newSubmitStatus');
            // Check the entire form for missing required fields
            if (newSubmitStatus.equalsIgnoreCase(Label.EIS_Form_Button_Final_Submit)) {
                Integer openCAs = (Integer)(audit.EIS_Count_Open_Immediate_CA__c + audit.EIS_Count_Open_Long_Term_CA__c);
                if (openCAs > 0) {
                    String errorMsg = 'There are ' + openCAs + ' open Corrective Actions. Please complete and mark them as Corrected before requesting for CAP Closure.';
                    if (openCAs == 1) {
                        errorMsg = 'There is ' + openCAs + ' open Corrective Action. Please complete and mark it as Corrected before requesting for CAP Closure.';
                    }
                    response.put('errorMsg', errorMsg);
                    return response;
                }
                audit.EIS_Final_CA_Closure__c = true;
                newSubmitStatus = Label.EIS_Audit_Inspection_Submit_Status_Submit;
            }
            if (newSubmitStatus.equalsIgnoreCase(Label.EIS_Audit_Inspection_Submit_Status_Submit)) {
                response = submitFullFormValidation(audit);
                if (String.isNotBlank(response.get('hasError'))) {
                    return response;
                }
                audit.EIS_Re_Submit_Toggle__c = !audit.EIS_Re_Submit_Toggle__c;
                response = new Map<String, String>();
            }
            
            if (newSubmitStatus.equalsIgnoreCase('toggleAuditInactivity')) {
                audit.EIS_Is_Active__c = !audit.EIS_Is_Active__c;
            } else {
                if (newSubmitStatus.equalsIgnoreCase(Label.EIS_Audit_Inspection_Submit_Status_Reject)) {
                    audit.EIS_Reason_For_Rejection__c = params.get('rejectionNote');
                    audit.EIS_Final_CA_Closure__c = false;
                }
                audit.PH_Submission_Status__c = newSubmitStatus;
            }
            update audit;
            response.put('audit', JSON.serialize(audit));
        } catch (Exception e) {
            Database.rollback(sp);
            response.put('errorMsg', e.getMessage());
        }
        
        return response;
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Description
    * Parse params data and generate data for each section based on params value
    *————————————————————————————————————————————————————
    * @param    params                  contains data to help querying the right information
    * @return   Map<String, String>     data to populate EIS_Audit_Body lightning component and its children
    *————————————————————————————————————————————————————
    **/
    @AuraEnabled
    public static Map<String, String> getCustomSections(Map<String, String> params) {
        Map<String, String> response = new Map<String, String>();
        try {
            List<QuestionSection> customSectionList;
            if (Label.EIS_Audit_Form_Tab_Protocol.equalsIgnoreCase(params.get('tabName'))) {
                customSectionList = getProtocolQuestionSections(params.get('sideTabName'), params.get('auditId'), null);
            } else if (Label.EIS_Audit_Form_Tab_Department.equalsIgnoreCase(params.get('tabName'))) {
                customSectionList = getDepartmentQuestionSectionByDepartment(params.get('sideTabName'), params.get('auditId'));
            }
            response.put('customSectionList', JSON.serialize(customSectionList));
        } catch (Exception e) {
            response.put('errorMsg', e.getMessage());
        }
        
        return response;
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Description
    * Parse params data for positive finding values and save them
    *————————————————————————————————————————————————————
    * @param    params                  contains data for accurate update of audit record
    * @return   Audit_Inspections__c    updated Audit record
    *————————————————————————————————————————————————————
    **/
    @AuraEnabled
    public static Map<String, String> saveNewPositiveFinding(Map<String, String> params) {
        Map<String, String> response = new Map<String, String>();
        Savepoint sp = Database.setSavepoint();
        try {
            Audit_Inspections__c audit = getAuditById(params.get('auditId'));
            // Logic for separation of positive findings in a single field
            if (String.isEmpty(audit.EIS_Positive_Findings__c)) {
                audit.EIS_Positive_Findings__c = '';
                audit.EIS_Positive_Findings_Departments__c = '';
            } else {
                audit.EIS_Positive_Findings__c += ';';
                audit.EIS_Positive_Findings_Departments__c += ';';
            }
            // Appending new positive finding and its selected departments
            audit.EIS_Positive_Findings__c += params.get('newPositiveFinding');
            audit.EIS_Positive_Findings_Departments__c += params.get('selectedDepartments');
            audit.EIS_Positive_Findings_Total_Score__c += 0.5;
            audit.EIS_Count_Positive_Finding__c += 1;
            
            List<String> selectedDeptList = params.get('selectedDepartments').split('');
            updatePositiveFindingScoresByDepartment(audit, selectedDeptList, 1, 0.5);
            
            update audit;
            response.put('audit', JSON.serialize(audit));
        } catch (Exception e) {
            Database.rollback(sp);
            response.put('errorMsg', e.getMessage());
        }
        return response;
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Description
    * Parse params data for positive finding values and edit based on index chosen
    *————————————————————————————————————————————————————
    * @param    params                  contains data for accurate update of audit record
    * @return   Audit_Inspections__c    updated Audit record
    *————————————————————————————————————————————————————
    **/
    @AuraEnabled
    public static Map<String, String> editPositiveFinding(Map<String, String> params) {
        Map<String, String> response = new Map<String, String>();
        Savepoint sp = Database.setSavepoint();
        try {
            Audit_Inspections__c audit = getAuditById(params.get('auditId'));
            Integer index = (Integer)JSON.deserialize(params.get('pfIndex'), Integer.class);
            List<String> pfList = audit.EIS_Positive_Findings__c.split(';');
            List<String> pfDeptList = audit.EIS_Positive_Findings_Departments__c.split(';');
            
            //Deduct points and counter from old department tracking
            List<String> selectedDeptList = pfDeptList[index].split('');
            updatePositiveFindingScoresByDepartment(audit, selectedDeptList, -1, -0.5);
            
            //Add points and counter from new selected departments
            selectedDeptList = params.get('selectedDepartments').split('');
            updatePositiveFindingScoresByDepartment(audit, selectedDeptList, 1, 0.5);
            
            pfList[index] = params.get('newPositiveFinding');
            pfDeptList[index] = params.get('selectedDepartments');
            String positiveFinding = '';
            String positiveFindingDept = '';
            for (Integer i = 0 ; i < pfList.size(); i++) {
                positiveFinding += pfList[i];
                positiveFindingDept += pfDeptList[i];
                if (i < pfList.size() - 1) {
                    positiveFinding += ';';
                    positiveFindingDept += ';';
                }
            }
            
            audit.EIS_Positive_Findings__c = positiveFinding;
            audit.EIS_Positive_Findings_Departments__c = positiveFindingDept;
            update audit;
            response.put('audit', JSON.serialize(audit));
        } catch (Exception e) {
            Database.rollback(sp);
            response.put('errorMsg', e.getMessage());
        }
        return response;
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Description
    * Parse params data for positive finding values and delete based on index chosen
    *————————————————————————————————————————————————————
    * @param    params                  contains data for accurate update of audit record
    * @return   Audit_Inspections__c    updated Audit record
    *————————————————————————————————————————————————————
    **/
    @AuraEnabled
    public static Map<String, String> deletePositiveFinding(Map<String, String> params) {
        Map<String, String> response = new Map<String, String>();
        Savepoint sp = Database.setSavepoint();
        try {
            Audit_Inspections__c audit = (Audit_Inspections__c)JSON.deserialize(params.get('auditJSON'), Audit_Inspections__c.class);
            Integer deleteIndex = Integer.valueOf(params.get('deleteIndex'));
            String positiveFinding = audit.EIS_Positive_Findings__c;
            String positiveFindingDept = audit.EIS_Positive_Findings_Departments__c;
            List<String> pfList = positiveFinding.split(';');
            List<String> pfDeptList = positiveFindingDept.split(';');
            
            positiveFinding = '';
            positiveFindingDept = '';
            // Iterating through the list of positive findings to delete the selected index
            for (Integer i = 0 ; i < pfList.size(); i++) {
                if (i != deleteIndex) {
                    if (String.isNotBlank(positiveFinding)) {
                        positiveFinding += ';';
                        positiveFindingDept += ';';
                    }
                    positiveFinding += pfList[i];
                    positiveFindingDept += pfDeptList[i];
                } else {
                    audit.EIS_Positive_Findings_Total_Score__c -= 0.5;
                    audit.EIS_Count_Positive_Finding__c -= 1;
                }
            }
            
            List<String> selectedDeptList = params.get('selectedDepartments').split('');
            updatePositiveFindingScoresByDepartment(audit, selectedDeptList, -1, -0.5);
            
            audit.EIS_Positive_Findings__c = positiveFinding;
            audit.EIS_Positive_Findings_Departments__c = positiveFindingDept;
            update audit;
            response.put('audit', JSON.serialize(audit));
        } catch (Exception e) {
            Database.rollback(sp);
            response.put('errorMsg', e.getMessage());
        }
        return response;
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Description
    * Helper method for Positive Finding calculation on the Audit record
    *————————————————————————————————————————————————————
    * @param    audit               The current Audit/Inspection record
    * @param    selectedDeptList    Departments selected for the positive finding. 1 means selected, 0 means not selected
    * @param    pfCount             The number of positive findings that changes. Usually value of 1 or -1 as Positive Findings are added 1 at a time
    * @param    deptScore           Score value for each department when a positive finding was found for that department
    * @return   void    
    *————————————————————————————————————————————————————
    **/
    private static void updatePositiveFindingScoresByDepartment(Audit_Inspections__c audit, List<String> selectedDeptList, Integer pfCount, Decimal deptScore) {
        if ('1'.equals(selectedDeptList[0])) {
            audit.EIS_Positive_Finding_Engineering__c += pfCount;
            audit.EIS_Department_Score_Engineering__c += deptScore;
        }
        if ('1'.equals(selectedDeptList[1])) {
            audit.EIS_Positive_Finding_Environment__c += pfCount;
            audit.EIS_Department_Score_Environment__c += deptScore;
        }
        if ('1'.equals(selectedDeptList[2])) {
            audit.EIS_Positive_Finding_Material__c += pfCount;
            audit.EIS_Department_Score_Material__c += deptScore;
        }
        if ('1'.equals(selectedDeptList[3])) {
            audit.EIS_Positive_Finding_Mechanical__c += pfCount;
            audit.EIS_Department_Score_Mechanical__c += deptScore;
        }
        if ('1'.equals(selectedDeptList[4])) {
            audit.EIS_Positive_Finding_Transportation__c += pfCount;
            audit.EIS_Department_Score_Transportation__c += deptScore;
        }
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Description
    * Helper method to return a set of Qualifiers from a list of Questions
    *————————————————————————————————————————————————————
    * @param    questions       List of Questions__c records
    * @return   Set<String>     Set of qualifier values
    *————————————————————————————————————————————————————
    **/
    public static Set<String> getVisibleQualifiers(List<Questions__c> questions) {
        Set<String> qualifiers = new Set<String>();
        for (Questions__c q : questions) {
            qualifiers.add(q.EIS_Qualifier_Name__c);
        }
        return qualifiers;
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Description
    * Helper method to populate and properly map Section wrapper object
    * QuestionSection control each section on the Audit form
    *————————————————————————————————————————————————————
    * @param    sideTabName             String value of side tab name
    * @param    auditId                 Id value of Audit record
    * @return   List<QuestionSection>   List of QuestionSection wrapper objects
    *————————————————————————————————————————————————————
    **/
    private static List<QuestionSection> getProtocolQuestionSections(String sideTabName, String auditId, String recordTypeAPI) {
        List<QuestionSection> customSectionList = new List<QuestionSection>();
        List<EIS_Audit_Question__mdt> metaQuestions = getMetaAuditQuestions(sideTabName, auditId, recordTypeAPI);
        List<Questions__c> questions = getQuestionListWithFindings(auditId);
        Set<String> qualifiers = getVisibleQualifiers(questions);
        List<Id> findingIdList = new List<Id>();
        // Must be called first to populate findingIdList
        Map<String, Questions__c> questionMap = EIS_Inspection_MainCtrl.getQuestionMap(questions, findingIdList);   
        List<Corrective_Action__c> caList = getCaListByFindingIds(findingIdList);
        Map<String, List<Corrective_Action__c>> caFindingMap = EIS_Inspection_MainCtrl.getCaFindingMap(caList);
        caList = null;
        findingIdList = null;
        // TODO : Add Record Type specific values. Currently not possible for Salesforce APEX
        List<String> findingDepartments = StaticUtils.getPicklistValues(Finding__c.EIS_Responsible_Department__c.getDescribe());
        String currentQualifier = '';
        Integer sectionIndex = 0;
        // Iterate through all master questions and generate wrapper objects to be used on lightning component
        for (Integer i = 0; i < metaQuestions.size(); i++) { 
            if (!currentQualifier.equalsIgnoreCase(metaQuestions[i].Qualifier_Name__c)) {
                sectionIndex = customSectionList.size();    // Set sectionIndex to the last index in the list
                currentQualifier = metaQuestions[i].Qualifier_Name__c;  
                customSectionList.add(new QuestionSection(currentQualifier, metaQuestions[i].Protocol_Name__c)); // add new Section to the list
            }
            if (qualifiers.contains(metaQuestions[i].Qualifier_Name__c)) {
                Questions__c question = questionMap.get(metaQuestions[i].Question_Id__c);
                // If a record already exist, populate the Question wrapper with all of its information, including its children
                if (question != null) {
                    Question customQuestion = new Question(true, question, new List<Observation>());
                    customQuestion.metaQuestion = metaQuestions[i];
                    for (Finding__c finding : question.Findings__r) {
                        customQuestion.customObservationList.add(new Observation(finding, caFindingMap.get(finding.Id), findingDepartments));
                    }
                    customSectionList[sectionIndex].customQuestionList.add(customQuestion);
                    customSectionList[sectionIndex].display = true;
                } else {
                    // No question record exist, create a Question wrapper placeholder with default values for Questions__c, Finding__c, Corrective_Action__c
                    Question customQuestion = new Question(metaQuestions[i], auditId);
                    customQuestion.customObservationList.add(new Observation(findingDepartments, metaQuestions[i].Question_Citation__c + ''));
                    customSectionList[sectionIndex].customQuestionList.add(customQuestion);
                }
            }
        }
        
        return customSectionList;
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Description
    * Helper method to map Question Sections to their respective departments
    * QuestionSection control each section on the Audit form
    *————————————————————————————————————————————————————
    * @param    auditId                             Id value of Audit record
    * @return   Map<String, List<QuestionSection>>  Map of List of QuestionSection wrapper objects organized by department label
    *————————————————————————————————————————————————————
    **/
    private static Map<String, List<QuestionSection>> getDepartmentQuestionSections(String auditId) {
        Map<String, List<QuestionSection>> resultMap = new Map<String, List<QuestionSection>>();
        List<Questions__c> questions = getQuestionListWithFindings(auditId);
        if (questions.isEmpty()) {
            return null;
        }
        // Retrieve all questions from this audit record and group them by department selected from their findings
        Map<String, List<Questions__c>> deptQuestionsMap = getDepartmentQuestionsMap(questions);
        List<Id> findingIdList = new List<Id>();
        Map<String, Questions__c> questionMap = EIS_Inspection_MainCtrl.getQuestionMap(questions, findingIdList); //Must be called first to populate findingIdList
        List<Corrective_Action__c> caList = getCaListByFindingIds(findingIdList);
        Map<String, List<Corrective_Action__c>> caFindingMap = EIS_Inspection_MainCtrl.getCaFindingMap(caList);
        caList = null;
        findingIdList = null;
        
        List<String> findingDepartments = StaticUtils.getPicklistValues(Finding__c.EIS_Responsible_Department__c.getDescribe());
        List<QuestionSection> customSectionList = new List<QuestionSection>();
        String sectionLabel = '';
        String tempSectionLabel = '';
        Integer sectionIndex = 0;
        Boolean sideTabSelected = false;
        for (String departmentName : deptQuestionsMap.keySet()) {
            customSectionList = new List<QuestionSection>();
            sectionLabel = '';
            tempSectionLabel = '';
            questions = deptQuestionsMap.get(departmentName);
            for (Integer i = 0; i < questions.size(); i++) {
                sectionLabel = questions[i].EIS_Protocol_Name__c + ' - ' + questions[i].EIS_Qualifier_Name__c;
                if (!tempSectionLabel.equalsIgnoreCase(sectionLabel)) {
                    // If a new section is detected, add a new section to the section list
                    sectionIndex = customSectionList.size();
                    tempSectionLabel = sectionLabel;
                    customSectionList.add(new QuestionSection(sectionLabel, departmentName));
                }
                // Add new question wrapper with placeholder list of observation/finding
                Question customQuestion = new Question(true, questions[i], new List<Observation>());
                for (Finding__c finding : questions[i].Findings__r) {
                    customQuestion.customObservationList.add(new Observation(finding, caFindingMap.get(finding.Id), findingDepartments));
                }
                customSectionList[sectionIndex].customQuestionList.add(customQuestion);
                customSectionList[sectionIndex].display = true;
            }
            if (!customSectionList.isEmpty()) {
                resultMap.put(departmentName, customSectionList);
            }
        }
        
        return resultMap;
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Description
    * Helper method to retrieve Question Section based on department label
    * QuestionSection control each section on the Audit form
    *————————————————————————————————————————————————————
    * @param    departmentName          String value of department label
    * @param    auditId                 Id value of Audit record
    * @return   List<QuestionSection>   List of QuestionSection wrapper objects 
    *————————————————————————————————————————————————————
    **/
    private static List<QuestionSection> getDepartmentQuestionSectionByDepartment(String departmentName, String auditId) {
        List<QuestionSection> customSectionList = new List<QuestionSection>();
        List<Questions__c> questions = getQuestionListWithFindingsByDepartment(departmentName, auditId);
        if (questions.isEmpty()) { return customSectionList; }
        
        List<Id> findingIdList = new List<Id>(); // List of all finding Ids under the list of questions
        Map<String, Questions__c> questionMap = EIS_Inspection_MainCtrl.getQuestionMap(questions, findingIdList); // Must be called first to populate findingIdList
        List<Corrective_Action__c> caList = getCaListByFindingIds(findingIdList);   
        Map<String, List<Corrective_Action__c>> caFindingMap = EIS_Inspection_MainCtrl.getCaFindingMap(caList);
        caList = null;
        findingIdList = null;
        
        List<String> findingDepartments = StaticUtils.getPicklistValues(Finding__c.EIS_Responsible_Department__c.getDescribe());
        String sectionLabel = '';
        String tempSectionLabel = '';
        Integer sectionIndex = 0;
        for (Integer i = 0; i < questions.size(); i++) {
            // Iterate throuh each question record and check if there are any findings
            if (questions[i].Findings__r != null && !questions[i].Findings__r.isEmpty()) {
                sectionLabel = questions[i].EIS_Protocol_Name__c + ' - ' + questions[i].EIS_Qualifier_Name__c;
                if (!tempSectionLabel.equalsIgnoreCase(sectionLabel)) {
                    // Creating a new section label and append it to section list
                    sectionIndex = customSectionList.size();
                    tempSectionLabel = sectionLabel;
                    customSectionList.add(new QuestionSection(sectionLabel, departmentName));
                }
                Question customQuestion = new Question(true, questions[i], new List<Observation>());
                for (Finding__c finding : questions[i].Findings__r) {
                    customQuestion.customObservationList.add(new Observation(finding, caFindingMap.get(finding.Id), findingDepartments));
                }
                customSectionList[sectionIndex].customQuestionList.add(customQuestion);
                customSectionList[sectionIndex].display = true;
            }
        }
        return customSectionList;
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Description
    * Helper method to retrieve Questions__c records and map them by department label
    *————————————————————————————————————————————————————
    * @param    questions                           List of Questions__c records
    * @return   Map<String, List<Questions__c>>     Map of department labels and their Questions__c records
    *————————————————————————————————————————————————————
    **/
    private static Map<String, List<Questions__c>> getDepartmentQuestionsMap(List<Questions__c> questions) {
        Map<String, List<Questions__c>> dqMap = new Map<String, List<Questions__c>>();
        for (Questions__c q : questions) {
            Set<String> deptNames = new Set<String>();
            for (Finding__c f : q.Findings__r) {
                if (String.isNotBlank(f.EIS_Responsible_Department__c)) {
                    deptNames.addAll(f.EIS_Responsible_Department__c.split(';'));
                }
            }
            for (String dName : deptNames) {
                if (dqMap.get(dName) == null) {
                    dqMap.put(dName, new List<Questions__c>());
                }
                dqMap.get(dName).add(q);
            }
        }
        return dqMap;
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Description
    * Helper method to retrieve metadata question records
    *————————————————————————————————————————————————————
    * @param    protocol                            Protocol label
    * @return   List<EIS_Audit_Question__mdt>       List of metadata question records for Audit form
    *————————————————————————————————————————————————————
    **/
    private static List<EIS_Audit_Question__mdt> getMetaAuditQuestions(String protocol, String auditId, String recordTypeAPI) {
        String formName = '%' + recordTypeAPI + '%';
        if (String.isBlank(recordTypeAPI)) {
            Audit_Inspections__c audit = [SELECT Id, RecordType.DeveloperName FROM Audit_Inspections__c WHERE Id = :auditId];
            formName = '%' + audit.RecordType.DeveloperName + '%';
        }
        
        List<EIS_Audit_Question__mdt> metaQuestions = [
            SELECT Id, Point__c, Protocol_Name__c, Qualifier_Name__c, Question_Id__c, Question_Name__c, Review_Checklist__c, Question_Citation__c
            FROM EIS_Audit_Question__mdt
            WHERE Form__c LIKE :formName AND Protocol_Name__c = :protocol
            ORDER BY Question_Id__c ASC
        ];
        return metaQuestions;
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Description
    * Helper method to iterate through protocol multipicklist values and generate a SideTab wrapper object
    *————————————————————————————————————————————————————
    * @param    protocol            Protocol label
    * @return   List<SideTab>       List of SideTab wrapper objects
    *————————————————————————————————————————————————————
    **/
    private static List<SideTab> getSideTabs(String protocols) {
        List<SideTab> sideTabs = new List<SideTab>();
        if (String.isNotBlank(protocols)) {
            for(String p : protocols.split(';')){
                sideTabs.add(new SideTab(p));
            }
        }
        return sideTabs;
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Description
    * Helper method to control disabilities on the Audit form
    * Retrieve persona map by using permission API name to control disability values
    *————————————————————————————————————————————————————
    * @param    response            Map of values to be returned to lightning component
    * @return   void
    *————————————————————————————————————————————————————
    **/
    private static void setDisablesInResponse(Map<String, String> response, Audit_Inspections__c audit) {
        if (!StaticUtils.userIsSystemAdmin()) {
            // Only disable the form if user isn't System Admin
            Map<String, Boolean> personaMap = getPersonasMap(); // Retrieve map of personas
            System.debug(personaMap);
            Boolean disableFindings = true, disableCorrectiveActions = true, disableHeaderButtons = true, disablePositiveFindings = true;
            if (audit.EIS_Is_Active__c) {
                if (audit.EIS_Final_CA_Closure__c) {
                    disableHeaderButtons = !personaMap.get(Label.EIS_Permission_Set_API_APM);
                    disableFindings = !personaMap.get(Label.EIS_Permission_Set_API_APM);
                    disablePositiveFindings = !personaMap.get(Label.EIS_Permission_Set_API_APM);
                    disableCorrectiveActions = !personaMap.get(Label.EIS_Permission_Set_API_APM);
                } else {
                    if (audit.RecordTypeId.equals(EIS_StaticUtils.INSPECTION_AUDIT_FORM_RTID)) {
                        // Disabling components on form based on current persona for Audit Form
                        disableFindings = !personaMap.get(Label.EIS_Permission_Set_API_APM) && 
                            !personaMap.get(Label.EIS_Permission_Set_API_EMA) &&
                            !personaMap.get(Label.EIS_Permission_Set_API_Interns);
                        disablePositiveFindings = !personaMap.get(Label.EIS_Permission_Set_API_APM) && 
                            !personaMap.get(Label.EIS_Permission_Set_API_EMA);
                        disableCorrectiveActions = !personaMap.get(Label.EIS_Permission_Set_API_APM) && 
                            !personaMap.get(Label.EIS_Permission_Set_API_EMA) &&
                            !personaMap.get(Label.EIS_Permission_Set_API_FES) && 
                            !personaMap.get(Label.EIS_Permission_Set_API_LES);
                    } else if (audit.RecordTypeId.equals(EIS_StaticUtils.INSPECTION_SFA_FORM_RTID)) {
                        // Disabling components on form based on current persona for SFA Form
                        disableFindings = !personaMap.get(Label.EIS_Permission_Set_API_APM) && 
                            !personaMap.get(Label.EIS_Permission_Set_API_EMA) &&
                            !personaMap.get(Label.EIS_Permission_Set_API_FES) && 
                            !personaMap.get(Label.EIS_Permission_Set_API_LES);
                        disablePositiveFindings = !personaMap.get(Label.EIS_Permission_Set_API_APM) && 
                            !personaMap.get(Label.EIS_Permission_Set_API_EMA);
                        disableCorrectiveActions = !personaMap.get(Label.EIS_Permission_Set_API_APM) && 
                            !personaMap.get(Label.EIS_Permission_Set_API_EMA) &&
                            !personaMap.get(Label.EIS_Permission_Set_API_FES) && 
                            !personaMap.get(Label.EIS_Permission_Set_API_LES);
                    }
                    disableHeaderButtons = false;
                }
            } 
            
            response.put('userIsAPM', JSON.serialize(personaMap.get(Label.EIS_Permission_Set_API_APM)));
            response.put('disableFindings', JSON.serialize(disableFindings));
            response.put('disablePositiveFindings', JSON.serialize(disablePositiveFindings));
            response.put('disableCorrectiveActions', JSON.serialize(disableCorrectiveActions));
            response.put('disableHeaderButtons', JSON.serialize(disableHeaderButtons));
        } else {
            response.put('userIsAPM', JSON.serialize(true));
        }
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Description
    * Compute a Map of personas that match current user's profile info
    *————————————————————————————————————————————————————
    * @return   Map<String, Boolean>    Map of boolean value to flag if current user belong to the key permission set
    *————————————————————————————————————————————————————
    **/
    public static Map<String, Boolean> getPersonasMap() {
        Map<String, Boolean> personaMap = new Map<String, Boolean>();
        // Appending personas that may have access to audit form
        personaMap.put(Label.EIS_Permission_Set_API_Interns, false);
        personaMap.put(Label.EIS_Permission_Set_API_APM, false);
        personaMap.put(Label.EIS_Permission_Set_API_FES, false);
        personaMap.put(Label.EIS_Permission_Set_API_EMA, false);
        personaMap.put(Label.EIS_Permission_Set_API_LES, false);
        List<PermissionSet> psList = [SELECT Id, Label, Name FROM PermissionSet WHERE Name IN :personaMap.keySet()];
        List<PermissionSetAssignment> psaList = [SELECT Id, PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId = :UserInfo.getUserId() AND PermissionSetId IN :psList];
        if (!psaList.isEmpty()) {
            for (PermissionSet ps : psList) {
                if (psaList[0].PermissionSetId == ps.Id) {
                    personaMap.put(ps.Name, true);
                }
            }
        } 
        return personaMap;
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Description
    * Query for Corrective Action records using its parent Id
    *————————————————————————————————————————————————————
    * @param    findingIdList   List of Id
    * @return   List<Corrective_Action__c>      return queried Corrective Actions
    *————————————————————————————————————————————————————
    **/
    private static List<Corrective_Action__c> getCaListByFindingIds(List<Id> findingIdList) {
        List<Corrective_Action__c> caList = [
            SELECT Id, RecordTypeId, EIS_Status__c, EIS_Description__c, EIS_Assigned_to__c, EIS_Finding__c, EIS_Due_Date__c, EIS_Date_of_Corrected_Status__c, 
            EIS_Date_of_Correction_Failed_Status__c, EIS_Progress_Notes__c, EIS_Rejection_Notes__c, EIS_RAO_Sign_Off__c, EIS_Sign_Off_Date__c, EIS_Closed_By__c,
            EIS_Assigned_to__r.Name, EIS_Assigned_to__r.Phone, EIS_RAO_Sign_Off__r.Name, EIS_Date_of_Approved_Status__c, EIS_Root_Cause__c, EIS_Corrective_Action_Type__c
            FROM Corrective_Action__c
            WHERE EIS_Finding__c IN: findingIdList
            ORDER BY CreatedDate
        ];
        return caList;
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Description
    * Query for Question records along with Findings using its Audit/Inspection Id
    *————————————————————————————————————————————————————
    * @param    auditId     Id of inspection record
    * @return   List<Questions__c>      return queried Questions
    *————————————————————————————————————————————————————
    **/
    private static List<Questions__c> getQuestionListWithFindings(String auditId) {
        List<Questions__c> questions = [
            SELECT Id, RecordTypeId, EIS_Metadata_Question_Id__c, Points__c, EIS_Issued__c, EIS_Corrected__c, EIS_Question_Text__c, EIS_Observation_Level__c,
            EIS_Count_Not_Corrected_CA__c, EIS_Count_Corrected_CA__c, EIS_Criticality__c, EIS_Protocol_Name__c, EIS_Qualifier_Name__c, EIS_Potential_Violation__c,
            EIS_Count_Open_Immediate_CA__c, EIS_Count_Closed_Immediate_CA__c, EIS_Count_Open_Long_Term_CA__c, EIS_Count_Closed_Long_Term_CA__c, EIS_Repeat_Violation__c,
            EIS_Count_Repeat_Transportation__c, EIS_Count_Repeat_Engineering__c, EIS_Count_Repeat_Environment__c, EIS_Count_Repeat_Material__c, EIS_Count_Repeat_Mechanical__c,
            EIS_Count_Finding_Engineering__c, EIS_Count_Finding_Environment__c, EIS_Count_Finding_Material__c, EIS_Count_Finding_Mechanical__c, EIS_Count_Finding_Transportation__c,
            Audit_Inspections__c,
                (SELECT Id, RecordTypeId, EIS_Description__c, EIS_Regulatory_Citation__c, EIS_Responsible_Department__c, EIS_Repeat_Finding__c 
                 FROM Findings__r ORDER BY CreatedDate)
            FROM Questions__c WHERE Audit_Inspections__c = :auditId ORDER BY EIS_Metadata_Question_Id__c
        ];
        return questions;
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Description
    * Query for Question records along with Findings using its Audit/Inspection Id and department name
    *————————————————————————————————————————————————————
    * @param    auditId             Id of inspection record
    * @param    departmentName      String value of department name
    * @return   List<Questions__c>      return queried Questions
    *————————————————————————————————————————————————————
    **/
    private static List<Questions__c> getQuestionListWithFindingsByDepartment(String departmentName, String auditId) {
        List<Questions__c> questions = [
            SELECT Id, RecordTypeId, EIS_Metadata_Question_Id__c, Points__c, EIS_Issued__c, EIS_Corrected__c, EIS_Question_Text__c, EIS_Observation_Level__c,
            EIS_Count_Not_Corrected_CA__c, EIS_Count_Corrected_CA__c, EIS_Criticality__c, EIS_Protocol_Name__c, EIS_Qualifier_Name__c, EIS_Potential_Violation__c,
            EIS_Count_Open_Immediate_CA__c, EIS_Count_Closed_Immediate_CA__c, EIS_Count_Open_Long_Term_CA__c, EIS_Count_Closed_Long_Term_CA__c, EIS_Repeat_Violation__c,
            EIS_Count_Repeat_Transportation__c, EIS_Count_Repeat_Engineering__c, EIS_Count_Repeat_Environment__c, EIS_Count_Repeat_Material__c, EIS_Count_Repeat_Mechanical__c,
            EIS_Count_Finding_Engineering__c, EIS_Count_Finding_Environment__c, EIS_Count_Finding_Material__c, EIS_Count_Finding_Mechanical__c, EIS_Count_Finding_Transportation__c,
            Audit_Inspections__c,
                (SELECT Id, RecordTypeId, EIS_Description__c, EIS_Regulatory_Citation__c, EIS_Responsible_Department__c, EIS_Repeat_Finding__c  
                 FROM Findings__r WHERE EIS_Responsible_Department__c INCLUDES (:departmentName) ORDER BY CreatedDate)
            FROM Questions__c WHERE Audit_Inspections__c = :auditId ORDER BY EIS_Metadata_Question_Id__c ASC
        ];
        return questions;
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Description
    * Query for inspection data with audit's Id
    *————————————————————————————————————————————————————
    * @param    recordId                audit Id
    * @return   Audit_Inspections__c    return queried audit
    *————————————————————————————————————————————————————
    **/
    public static Audit_Inspections__c getAuditById(String recordId) {
        Audit_Inspections__c audit = [
            SELECT Id, EIS_Audit_Name__c, EIS_Audit_Score__c, RecordType.Name, RecordType.DeveloperName, RecordTypeId, EIS_Positive_Findings_Departments__c,
            EIS_Positive_Findings__c, EIS_Positive_Findings_Total_Score__c, EIS_Count_Open_Immediate_CA__c, EIS_Count_Closed_Immediate_CA__c, EIS_Reason_For_Rejection__c,
            EIS_Count_Open_Long_Term_CA__c, EIS_Count_Closed_Long_Term_CA__c, EIS_Protocol_Name__c, EIS_Start_Date__c, EIS_End_Date__c, EIS_Is_Active__c, 
            EIS_Auditor_1__r.Name, EIS_Count_Positive_Finding__c, EIS_Count_Negative_Finding__c, EIS_Count_Not_Corrected_CA__c, PH_Submission_Status__c,
            EIS_Positive_Finding_Engineering__c, EIS_Positive_Finding_Environment__c, EIS_Positive_Finding_Material__c, EIS_Positive_Finding_Mechanical__c, 
            EIS_Positive_Finding_Transportation__c, EIS_Management_Practice_Engineering__c, EIS_Management_Practice_Environment__c, EIS_Final_CA_Closure__c, EIS_Re_Submit_Toggle__c,
            EIS_Management_Practice_Material__c, EIS_Management_Practice_Mechanical__c, EIS_Management_Practice_Transportation__c,
            EIS_Potential_Violation_Engineering__c, EIS_Potential_Violation_Environment__c, EIS_Potential_Violation_Material__c, 
            EIS_Potential_Violation_Mechanical__c, EIS_Potential_Violation_Transportation__c, EIS_Department_Score_Engineering__c, 
            EIS_Department_Score_Environment__c, EIS_Department_Score_Material__c, EIS_Department_Score_Mechanical__c, EIS_Department_Score_Transportation__c, 
            EIS_Department_Weight_Transportation__c, EIS_Department_Weight_Environment__c, EIS_Department_Weight_Engineering__c, EIS_Department_Weight_Material__c, EIS_Department_Weight_Mechanical__c 
            FROM Audit_Inspections__c 
            WHERE Id =: recordId
        ];
        return audit;
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Description
    * Query for Questions__c record using its Id
    *————————————————————————————————————————————————————
    * @param    recordId                question Id
    * @return   Questions__c    return queried Questions__c
    *————————————————————————————————————————————————————
    **/
    public static Questions__c getQuestionById(String recordId) {
        Questions__c question = [
            SELECT Id, RecordTypeId, EIS_Metadata_Question_Id__c, Points__c, EIS_Issued__c, EIS_Corrected__c, EIS_Question_Text__c, EIS_Observation_Level__c,
            EIS_Count_Not_Corrected_CA__c, EIS_Count_Corrected_CA__c, EIS_Criticality__c, EIS_Protocol_Name__c, EIS_Qualifier_Name__c, EIS_Potential_Violation__c,
            EIS_Count_Open_Immediate_CA__c, EIS_Count_Closed_Immediate_CA__c, EIS_Count_Open_Long_Term_CA__c, EIS_Repeat_Violation__c, EIS_Count_Closed_Long_Term_CA__c,
            EIS_Count_Finding_Engineering__c, EIS_Count_Finding_Environment__c, EIS_Count_Finding_Material__c, EIS_Count_Finding_Mechanical__c, EIS_Count_Finding_Transportation__c,
            EIS_Count_Repeat_Transportation__c, EIS_Count_Repeat_Engineering__c, EIS_Count_Repeat_Environment__c, EIS_Count_Repeat_Material__c, EIS_Count_Repeat_Mechanical__c,
            Audit_Inspections__c
            FROM Questions__c WHERE Id = :recordId
        ];
        return question;
    }
}
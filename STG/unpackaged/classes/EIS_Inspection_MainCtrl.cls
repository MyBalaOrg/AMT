/**
*————————————————————————————————————————————————————
* @Name             EIS_Inspection_MainCtrl
* @Author           Duy Tran
* @Created Date     06-10-2017
* @Used By          EIS_Inspection_Main.cmp
*————————————————————————————————————————————————————
* @Description
* Controller class to generate and handle DML operations for 
* 
*————————————————————————————————————————————————————
* @Changes
* 06-10-2017	Initial creation. Designed InspectionForm class to control interactions on Lightning Components
* 06-11-2017	Completed initialization of InspectionForm to collect data for Lighting Components
* 06-12-2017	Completed Save Progress functionality and Submit functionality
* 06-13-2017	Refactored getContentForInspectionForm() to handle all Record Types of Inspection
* 06-14-2017	Added saving of Corrective Actions to Save Progress and Submit, also delete empty Questions and its children records
* 06-15-2017	Added additional default values to newly created records (all objects)
* 06-18-2017	Clean up save method and changed Submit functionality
**/
public class EIS_Inspection_MainCtrl {
    /**
    *————————————————————————————————————————————————————
    * @Description
    * Custom classes to control ligtning pages
    * Safer parsing of JSON requests from lightning pages
    *————————————————————————————————————————————————————
    **/
    public class InspectionForm {
        public String recordId {get; set;}
        public List<QuestionSection> sectionList {get; set;}
    }
    public class QuestionSection {
        public String sectionHeader {get; set;}
        public List<Question> questionList {get; set;}
    }
    public class Question {
        public EIS_Questions__mdt metaQuestion {get; set;}
        public Questions__c question {get; set;}
        public List<Finding> findingList {get; set;}
    }
    public class Finding {
        public Finding__c finding {get; set;}
        public List<Corrective_Action__c> caList {get; set;}
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Description
    * Parse inspectionFormJSON into the InspectionForm object and traverse its data tree
    * Collect non-empty data, set default values, and upsert records
    * Set inspection's status to SUBMIT
    *————————————————————————————————————————————————————
    * @param    recordId				Id of the Audit_Inspections__c record
    * @param	inspectionFormJSON		String representation of the InspectionForm to be parsed
    * @return   Map<String, String>		data to populate EIS_Inspection_Main lightning component and its children
    *————————————————————————————————————————————————————
    **/
    @auraEnabled
    public static Map<String, String> submitInspectionForm(String recordId) {
        Map<String, String> response = new Map<String, String>();
        SavePoint sp = Database.setSavepoint();
        try {
            Audit_Inspections__c inspection = getInspectionRecord(recordId);
            inspection.PH_Submission_Status__c = Label.EIS_Audit_Inspection_Submit_Status_Submit;        
            if (inspection.EIS_Correction_Deadline__c == null || String.isBlank(inspection.EIS_Correction_Deadline__c + '')) {
                Integer daysFromToday = Integer.valueOf(AEPHIS_Settings__c.getValues('Inspection Correction Deadline').EIS_Integer_Value__c);
                Date deadline = Date.today();
                deadline = deadline.addDays(daysFromToday); 
                inspection.EIS_Correction_Deadline__c = deadline;
            }
            
            update inspection;
            response.put('inspection', JSON.serialize(inspection));
            setDisablesInResponse(inspection, response);
        } catch (Exception e) {
            response.put('errorMsg', e.getMessage());
            Database.rollback(sp);
        }
        return response;
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Description
    * Set inspection's status to Rejected and update the front end
    *————————————————————————————————————————————————————
    * @param    recordId				Id of the Audit_Inspections__c record
    * @param	inspectionFormJSON		String representation of the InspectionForm to be parsed
    * @return   Map<String, String>		data to populate EIS_Inspection_Main lightning component and its children
    *————————————————————————————————————————————————————
    **/
    @auraEnabled
    public static Map<String, String> rejectInspectionForm(String recordId, String reasonForRejection) {
        Map<String, String> response = new Map<String, String>();
        SavePoint sp = Database.setSavepoint();
        try {
            Audit_Inspections__c inspection = getInspectionRecord(recordId);
            inspection.PH_Submission_Status__c = Label.EIS_Audit_Inspection_Submit_Status_Reject;
            inspection.EIS_Reason_For_Rejection__c = reasonForRejection;
            update inspection;
            response.put('inspection', JSON.serialize(inspection));
            setDisablesInResponse(inspection, response);
        } catch (Exception e) {
            response.put('errorMsg', e.getMessage());
            Database.rollback(sp);
        }
        return response;
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Description
    * Set inspection's status to Approved and update the front end
    *————————————————————————————————————————————————————
    * @param    recordId				Id of the Audit_Inspections__c record
    * @param	inspectionFormJSON		String representation of the InspectionForm to be parsed
    * @return   Map<String, String>		data to populate EIS_Inspection_Main lightning component and its children
    *————————————————————————————————————————————————————
    **/
    @AuraEnabled
    public static Map<String, String> approveInspectionForm(String recordId) {
        Map<String, String> response = new Map<String, String>();
        SavePoint sp = Database.setSavepoint();
        try {
            Audit_Inspections__c inspection = getInspectionRecord(recordId);
            inspection.PH_Submission_Status__c = Label.EIS_Audit_Inspection_Submit_Status_Approve;
            update inspection;
            response.put('inspection', JSON.serialize(inspection));
            setDisablesInResponse(inspection, response);
        } catch (Exception e) {
            response.put('errorMsg', e.getMessage());
            Database.rollback(sp);
        }
        return response;
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Description
    * Check inspection's record type and collect the correct set of data
    *————————————————————————————————————————————————————
    * @param    recordId	Id of the Audit_Inspections__c record
    * @return   Map<String, String>		data to populate EIS_Inspection_Main lightning component and its children
    *————————————————————————————————————————————————————
    **/
	@AuraEnabled
    public static Map<String, String> initInspection(String recordId) {
        Map<String, String> response = new Map<String, String>();
        try {
            Audit_Inspections__c inspection = getInspectionRecord(recordId);
            InspectionForm iForm = null;
            if (inspection.RecordTypeId == EIS_StaticUtils.INSPECTION_COMMISSARY_RTID) {
                iForm = getContentForInspectionForm(recordId, EIS_StaticUtils.METAQUESTION_FORM_API_COMMISSARY);
            } else if (inspection.RecordTypeId == EIS_StaticUtils.INSPECTION_WATERPOINT_RTID) {
                iForm = getContentForInspectionForm(recordId, EIS_StaticUtils.METAQUESTION_FORM_API_WATERPOINT);
            } else if (inspection.RecordTypeId == EIS_StaticUtils.INSPECTION_VENDOR_RTID) {
                iForm = getContentForInspectionForm(recordId, EIS_StaticUtils.METAQUESTION_FORM_API_VENDOR);
            } else if (inspection.RecordTypeId == EIS_StaticUtils.INSPECTION_FOOD_CAR_RTID) {
                iForm = getContentForInspectionForm(recordId, EIS_StaticUtils.METAQUESTION_FORM_API_FOOD_CART);
            }
            
            response.put('inspection', JSON.serialize(inspection));
            response.put('inspectionForm', JSON.serialize(iForm));
            setDisablesInResponse(inspection, response);
        } catch (Exception e) {
            response.put('errorMsg', e.getMessage());
        }
        return response;
    }
	
    /**
    *————————————————————————————————————————————————————
    * @Description
    * Turn on/off inactivity status of the inspection form
    *————————————————————————————————————————————————————
    * @param    recordId		Id of the Audit_Inspections__c record
    * @return   void	
    *————————————————————————————————————————————————————
    **/  
    @AuraEnabled
    public static Map<String, String> toggleIsActive(String recordId) {
        Map<String, String> response = new Map<String, String>();
        SavePoint sp = Database.setSavepoint();
        try {
            Audit_Inspections__c inspection = getInspectionRecord(recordId);
            inspection.EIS_Is_Active__c = !inspection.EIS_Is_Active__c;
            update inspection;
            setDisablesInResponse(inspection, response);
        } catch (Exception e) {
            response.put('errorMsg', e.getMessage());
            Database.rollback(sp);
        }
        return response;
    }
    
	/**
    *————————————————————————————————————————————————————
    * @Description
    * Update user's input for the Additional Notes field
    *————————————————————————————————————————————————————
    * @param    inspectionId		Id of the Audit_Inspections__c record
    * @param    additionalNotes		String value of user's input
    * @return   void	
    *————————————————————————————————————————————————————
    **/    
    @AuraEnabled
    public static void updateAdditionalNotes(String inspectionId, String additionalNotes) {
        try {
            Audit_Inspections__c inspection = new Audit_Inspections__c(
                Id = inspectionId,
                EIS_Additional_Notes__c = additionalNotes
            );
            update inspection;
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Description
    * Query for Metadata Questions to control inspection lay out
    * Query for Questions__c, Finding__c, and Corrective_Action__c and populate them in Map
    * Set default values for each objects to provide better client component control
    *————————————————————————————————————————————————————
    * @param    recordId			Id of the Audit_Inspections__c record
    * @param	metaFormType		Type of questions (Commissary, Waterpoint ...)
    * @return   InspectionForm		Custom class to store all data to be used on client lightning component
    *————————————————————————————————————————————————————
    **/
    @TestVisible
    private static InspectionForm getContentForInspectionForm(String recordId, String metaFormType) {
        InspectionForm iForm = new InspectionForm();
        iForm.recordId = recordId;
        iForm.sectionList = new List<QuestionSection>();
        
        List<EIS_Questions__mdt> metaQuestions = [
            SELECT Id, Question__c, Sr_No__c, Weightage__c, Criticality__c, Section_Name__c
            FROM EIS_Questions__mdt
            WHERE Form__c = :metaFormType
            ORDER BY Sr_No__c ASC
        ];
        List<Questions__c> questions = [
            SELECT Id, EIS_Metadata_Question_Id__c, EIS_Issued__c, Points__c, EIS_Corrected__c, EIS_Criticality__c,
            	(SELECT Id, EIS_Description__c FROM Findings__r ORDER BY CreatedDate)
            FROM Questions__c
            WHERE Audit_Inspections__c =: recordId
        ];
        
        List<Id> findingIdList = new List<Id>();
        Map<String, Questions__c> questionMap = getQuestionMap(questions, findingIdList);
        List<Corrective_Action__c> caList = getCaListByFindingIds(findingIdList);
        Map<String, List<Corrective_Action__c>> caFindingMap = getCaFindingMap(caList);
        caList = null;
        findingIdList = null;
        
        Map<String, QuestionSection> sectionMap = new Map<String, QuestionSection>();
        List<String> orderedSectionNames = new List<String>();
        for (EIS_Questions__mdt metaQuestion : metaQuestions) {
            Question customQuestion = new Question();
            customQuestion.metaQuestion = metaQuestion;
            customQuestion.question = questionMap.get(metaQuestion.Id);
            customQuestion.findingList = new List<Finding>();
            
            Finding customFinding = new Finding();
            customFinding.finding = new Finding__c(
                EIS_Description__c = '',
            	RecordTypeId = EIS_StaticUtils.FINDING_INSPECTION_RTID
            );
            customFinding.caList = new List<Corrective_Action__c>();
            customFinding.caList.add(new Corrective_Action__c(RecordTypeId = EIS_StaticUtils.CORRECTIVEACTION_INSPECTION_RTID));
            if (customQuestion.question == null) {
                customQuestion.question = new Questions__c(
                    RecordTypeId = EIS_StaticUtils.QUESTIONS_INSPECTION_RTID,
                    Audit_Inspections__c = recordId,
                    EIS_Metadata_Question_Id__c = metaQuestion.Id,
                    Points__c = metaQuestion.Weightage__c,
                    EIS_Issued__c = false,
                    EIS_Corrected__c = true,
                    EIS_Criticality__c = metaQuestion.Criticality__c,
                    EIS_Question_Text__c = metaQuestion.Question__c,
                    EIS_Section_Name__c = metaQuestion.Section_Name__c
                );
                customQuestion.findingList.add(customFinding);
            } else {
                List<Finding__c> findingList = questionMap.get(metaQuestion.Id).Findings__r;
                if (findingList != null && findingList.size() > 0) {
                    for (Finding__c f : findingList) {
                        Finding tempCustomFinding = new Finding();
                        tempCustomFinding.finding = f;
                        tempCustomFinding.caList = caFindingMap.get(f.Id);
                        if (tempCustomFinding.caList == null || tempCustomFinding.caList.size() == 0) {
							tempCustomFinding.caList = new List<Corrective_Action__c>();   
                            tempCustomFinding.caList.add(new Corrective_Action__c(
                                RecordTypeId = EIS_StaticUtils.CORRECTIVEACTION_INSPECTION_RTID,
                                EIS_Description__c = '', EIS_Finding__c = f.Id
                            ));
                        }
                        customQuestion.findingList.add(tempCustomFinding);
                        tempCustomFinding = null;
                    }
                } else {
                    customQuestion.findingList.add(customFinding);
                }
            }
            
            if (sectionMap.get(metaQuestion.Section_Name__c) == null) {
                sectionMap.put(metaQuestion.Section_Name__c, new QuestionSection());
                sectionMap.get(metaQuestion.Section_Name__c).sectionHeader = metaQuestion.Section_Name__c + ' ' + Label.EIS_Inspection_Form_Section_Postfix;
                sectionMap.get(metaQuestion.Section_Name__c).questionList = new List<Question>();
                orderedSectionNames.add(metaQuestion.Section_Name__c);
            }
            sectionMap.get(metaQuestion.Section_Name__c).questionList.add(customQuestion);
        }
        
        //Adding each section into the Inspection Form
        for (String sectionName : orderedSectionNames) {
            iForm.sectionList.add(sectionMap.get(sectionName));
        }
        
        return iForm;
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Description
    * Generate a Map for Metadata question Id and its Questions__c objects
    * Append correct Findings Id to be used in getCaFindingMap()
    *————————————————————————————————————————————————————
    * @param    questions		List of Questions__c for the current Inspection record
    * 			findingIdList	List of findingIds to be used by getCaFindingMap()
    * @return   Map<String, Questions__c>	Map of Questions__c and its Metada key
    *————————————————————————————————————————————————————
    **/
    public static Map<String, Questions__c> getQuestionMap(List<Questions__c> questions, List<Id> findingIdList) {
        Map<String, Questions__c> questionMap = new Map<String, Questions__c>();
        for (Questions__c q: questions) {
            if (String.isNotBlank(q.EIS_Metadata_Question_Id__c)) {
                questionMap.put(q.EIS_Metadata_Question_Id__c, q);
                for (Finding__c f: q.Findings__r) {
                    findingIdList.add(f.Id);
                }
            }
        }
        
        return questionMap;
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Description
    * Generate a Map for of Corrective Action List so they can be added to the correct Findings
    *————————————————————————————————————————————————————
    * @param    findingIdList	List of findingIds to be used for querying Corrective_Actions
    * @return   Map<String, List<Corrective_Action__c>> 	Map of Corrective Actions to be appended to its parent Finding__c
    *————————————————————————————————————————————————————
    **/
    public static Map<String, List<Corrective_Action__c>> getCaFindingMap(List<Corrective_Action__c> caList) {
        Map<String, List<Corrective_Action__c>> caFindingMap = new Map<String, List<Corrective_Action__c>>();
        for (Corrective_Action__c ca : caList) {
            if (caFindingMap.get(ca.EIS_Finding__c) == null) {
                caFindingMap.put(ca.EIS_Finding__c, new List<Corrective_Action__c>());
            }
            caFindingMap.get(ca.EIS_Finding__c).add(ca);
        }
        return caFindingMap;
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Description
    * Query for Corrective Action records using its parent Id
    *————————————————————————————————————————————————————
    * @param    findingIdList	List of Id
    * @return   List<Corrective_Action__c> 		return queried Corrective Actions
    *————————————————————————————————————————————————————
    **/
    private static List<Corrective_Action__c> getCaListByFindingIds(List<Id> findingIdList) {
        if (findingIdList.isEmpty()) {
            return new List<Corrective_Action__c>();
        }
        List<Corrective_Action__c> caList = [
            SELECT Id, EIS_Status__c, EIS_Date_of_Not_Started_Status__c, EIS_Description__c, EIS_Assigned_to__c, EIS_Assigned_to__r.Name, EIS_Finding__c,
            	EIS_Date_of_In_Progress_Status__c, EIS_Date_of_Corrected_Status__c, EIS_Date_of_Correction_Failed_Status__c
        	FROM Corrective_Action__c
            WHERE EIS_Finding__c IN: findingIdList
            ORDER BY CreatedDate
        ];
        return caList;
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Description
    * Return TRUE if current user is a Public Health Inspector
    *————————————————————————————————————————————————————
    * @return   Boolean		TRUE if current user is a Public Health Inspector
    *————————————————————————————————————————————————————
    **/
    public static Boolean userIsPublicHealthInspector() {
        List<PermissionSet> psList = [SELECT Id, Label, Name FROM PermissionSet WHERE Name = :Label.EIS_Permission_Set_API_PHI];
        List<PermissionSetAssignment> psaList = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :UserInfo.getUserId() AND PermissionSetId IN :psList];
        
        return !psaList.isEmpty();
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Description
    * Compute logic for disabling Finding components on inspection form
    *————————————————————————————————————————————————————
    * @param    status			Current submission status of inspection form
    * @param    isActive		Current inactivity status of inspection form
    * @param    isInspector		TRUE if current user is a Public Health Inspector
    * @return   Boolean 		TRUE if Finding components should be disabled
    *————————————————————————————————————————————————————
    **/
    public static Boolean disableFindings(String status, Boolean isActive, Boolean isInspector) {
        if (!isActive) { return true; }
        if (!isInspector) { return false; }
        if (status.equals(Label.EIS_Audit_Inspection_Submit_Status_Submit) || status.equals(Label.EIS_Audit_Inspection_Submit_Status_Approve)) {
            return true;
        }
        return false;
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Description
    * Compute logic for disabling Corrective Actions components on inspection form
    *————————————————————————————————————————————————————
    * @param    status			Current submission status of inspection form
    * @param    isActive		Current inactivity status of inspection form
    * @param    isInspector		TRUE if current user is a Public Health Inspector
    * @return   Boolean 		TRUE if Corrective Action components should be disabled
    *————————————————————————————————————————————————————
    **/
    public static Boolean disableCorrectiveActions(String status, Boolean isActive, Boolean isInspector) {
        if (!isActive) { return true; }
        if (!isInspector) { return false; }
        if (status.equals(Label.EIS_Audit_Inspection_Submit_Status_Submit)) {
            return true;
        }
        return false;
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Description
    * Compute logic for disabling header buttons on inspection form
    *————————————————————————————————————————————————————
    * @param    status			Current submission status of inspection form
    * @param    isActive		Current inactivity status of inspection form
    * @param    isInspector		TRUE if current user is a Public Health Inspector
    * @return   Boolean 		TRUE if header buttons should be disabled
    *————————————————————————————————————————————————————
    **/
    public static Boolean disableHeaderButtons(String status, Boolean isActive, Boolean isInspector) {
        if (!isActive) { return true; }
        if (status.equals(Label.EIS_Audit_Inspection_Submit_Status_Draft) || status.equals(Label.EIS_Audit_Inspection_Submit_Status_Reject)) {
            return false;
        } else if (status.equals(Label.EIS_Audit_Inspection_Submit_Status_Submit)) {
            return isInspector;
        }
        return true;
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Description
    * Set disable boolean for Finding, Corrective Action, and Header
    *————————————————————————————————————————————————————
    * @param    inspection		Current inspection record
    * @param    response		Map of JSON to be sent to front end
    * @return   void
    *————————————————————————————————————————————————————
    **/
    public static void setDisablesInResponse(Audit_Inspections__c inspection, Map<String, String> response) {
        if (!EIS_StaticUtils.userIsSystemAdmin()) {
            Boolean isInspector = userIsPublicHealthInspector();
            Boolean disableFindings = disableFindings(inspection.PH_Submission_Status__c, inspection.EIS_Is_Active__c, isInspector);
            Boolean disableCorrectiveActions = disableCorrectiveActions(inspection.PH_Submission_Status__c, inspection.EIS_Is_Active__c, isInspector);
            Boolean disableHeaderButtons = disableHeaderButtons(inspection.PH_Submission_Status__c, inspection.EIS_Is_Active__c, isInspector);
            response.put('disableFindings', JSON.serialize(disableFindings));
            response.put('disableCorrectiveActions', JSON.serialize(disableCorrectiveActions));
            response.put('disableHeaderButtons', JSON.serialize(disableHeaderButtons));
        }
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Description
    * Query for inspection data with inspection's Id
    *————————————————————————————————————————————————————
    * @param    recordId				inspection Id
    * @return   Audit_Inspections__c 	return queried Inspection
    *————————————————————————————————————————————————————
    **/
    public static Audit_Inspections__c getInspectionRecord(String recordId) {
        Audit_Inspections__c inspection = [
            SELECT Id, Name, PH_Score__c, RecordType.DeveloperName, RecordType.Name, RecordTypeId, PH_Report_Status__c, EIS_Count_Corrected_CA__c, PH_Submission_Status__c, EIS_Correction_Deadline__c,
            PH_Facility__r.Name, EIS_Count_Started_CA__c, EIS_Count_Not_Corrected_CA__c, EIS_Count_In_Progress_CA__c, PH_Corrective_Action_Status__c, EIS_Additional_Notes__c,
            EIS_Count_Critical_Questions__c, EIS_Count_Critical_Corrected_CA__c, EIS_Count_Critical_Not_Corrected_CA__c, EIS_Train__c,
            EIS_Reason_For_Rejection__c, EIS_Is_Active__c, Inspected_By__r.Id, Inspected_By__r.Email,  OBS_Critical_Violations__c, OBS_Points_Missed__c,Mech_Critical_Violations__c, Mech_Points_Missed__c
            FROM Audit_Inspections__c 
            WHERE Id =: recordId
        ];
        return inspection;
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Description
    * Query for Questions__c record using its Id
    *————————————————————————————————————————————————————
    * @param    recordId				question Id
    * @return   Audit_Inspections__c 	return queried Questions__c
    *————————————————————————————————————————————————————
    **/
    public static Questions__c getQuestionsRecord(String recordId) {
        Questions__c question = [
            SELECT Id, RecordTypeId, EIS_Metadata_Question_Id__c, Points__c, EIS_Issued__c, EIS_Corrected__c, 
            EIS_Count_Not_Corrected_CA__c, EIS_Count_Corrected_CA__c, EIS_Criticality__c, EIS_Question_Text__c 
            FROM Questions__c WHERE Id = :recordId
        ];
        return question;
    }
	
}
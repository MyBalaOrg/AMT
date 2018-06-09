/**
*—————————————————————————————————————————————————————————————————————————
* @Name             EIS_Inspection_MainCtrlReport
* @Author           Kumar Suyash
* @Created Date     07-1-2017
* @Used By          EIS_AuditInspection_Pdf_genration
*—————————————————————————————————————————————————————————————————————————
* @Description
* Send value to the EIS_AuditInspection_Pdf_genrationan 
*—————————————————————————————————————————————————————————————————————————
* @Changes
* 8/14/2017 Change Query to referr to the new Tracking object
* Akshay  11/26/2017 Changes to fix ARSS-153
* Lakshmi 01/11/2018 Changes to fix ARSS-142
**/
public without sharing class EIS_Inspection_MainCtrlReport {
    
    private final Audit_Inspections__c inspection; 
    public List<Id> findingIdList = new List<Id>();
    public List<Corrective_Action__c> correctiveActions; 
    
    public List<Questions__c> questions;
    public List<EIS_Questions__mdt> allQuestions;
    public List<wQuestions> objWQuestions {get;set;}
    public Audit_Inspections__c auditIns{get;set;}
    public List<tracking__c> allTrackingRecs{get;set;}
    public List<tracking__c> freezerTempRecs{get;set;}
    public List<tracking__c> refrigerationTempRecs{get;set;}
    public List<tracking__C> handWashRecs{get;set;}
    public List<tracking__c> internalTempRecs{get;set;}
    public List<tracking__c> hydrantsList{get;set;}
    public list<Finding__c> FindingList ; 
    public list<QuestionWrapper > QuestionWrapperList {get;set;}
    public string CADueDates{get;set;}
   
    
    
    //StandardController Constructor
    public EIS_Inspection_MainCtrlReport (ApexPages.StandardController controller) {
        
        allTrackingRecs = new List<tracking__c>();
        refrigerationTempRecs = new List<tracking__c>();
        freezerTempRecs = new List<tracking__c>();
        handWashRecs = new List<tracking__c>();
        internalTempRecs = new List<tracking__c>();
        hydrantsList = new List<tracking__c>();
        
        inspection = (Audit_Inspections__c)controller.getRecord();
        auditIns = [Select Id,RecordType.DeveloperName ,PH_Code__c,
                    EIS_Positive_Finding_Engineering__c,EIS_Positive_Finding_Environment__c,EIS_Positive_Finding_Material__c,EIS_Positive_Finding_Mechanical__c,EIS_Positive_Finding_Transportation__c,
                    EIS_Management_Practice_Engineering__c,EIS_Management_Practice_Environment__c,EIS_Management_Practice_Material__c,EIS_Management_Practice_Mechanical__c,EIS_Management_Practice_Transportation__c,
                    EIS_Potential_Violation_Engineering__c,EIS_Potential_Violation_Environment__c,EIS_Potential_Violation_Material__c,EIS_Potential_Violation_Mechanical__c,EIS_Potential_Violation_Transportation__c,
                    EIS_Department_Score_Engineering__c,EIS_Department_Score_Environment__c,EIS_Department_Score_Material__c,EIS_Department_Score_Mechanical__c,EIS_Department_Score_Transportation__c,
                    EIS_Audit_Review_Call_Phone__c, EIS_Audit_Review_Call_Date_Time__c, EIS_Audit_Review_Call_Code__c, EIS_Status_Review_Due_Dates__c, EIS_Department_Weight_Environment__c, EIS_Department_Weight_Engineering__c, 
                    EIS_Department_Weight_Material__c, EIS_Department_Weight_Mechanical__c, EIS_Department_Weight_Transportation__c, EIS_Audit_Name__c, Name, EIS_Site_Division__c, EIS_Auditor_1__c, EIS_Auditor_2__c, EIS_Start_Date__c, 
                    EIS_End_Date__c, EIS_Protocol_Name__c, Auditor_1_Name__c, Auditor_2_Name__c, Date_and_Time__c, Inspected_in__c, Inspector_Name__c, Food_Car_Number__c, EIS_Train__c, Route_Location_Inspected_Start__c, 
                    Route_Location_Inspected_End__c, EIS_Route__c, EIS_Region_Food_Ins__c, Pest_Control_Location__c, Pest_Control_Date__c, OBS_Train_Manager_Crew_Base__c, OBS_Train_Manager_Name__c, Chef_Crew_Base__c, Chef_Name__c,
                    EIS_Mechanical_Food_Ins__c, Next_PM_Due_Date__c, EIS_Site__r.Name, Next_PM_Location__c, LSA_Crew_Base__c, LSA_Name__c, EIS_Site_Name_Audit_Inspection__c, Employee_Responsible_Name__c, PH_Region__c
                    from Audit_Inspections__c 
                    where id =:inspection.id limit 1];
            
                    allTrackingRecs = [select EIS_Food_Item__c,EIS_Location__c,EIS_Location_Type__c,EIS_Temperature__c,EIS_Temperature_Type__c,EIS_Unit__c from tracking__c where EIS_Inspection_Form__c =: inspection.id order by EIS_Location__c asc];
        
        String currentRecordTypeName = this.auditIns.RecordType.DeveloperName;
        if(allTrackingRecs.size() > 0) {
            if(currentRecordTypeName.equals(Label.EIS_Commissary_Inspection_Form_Record_Type) || currentRecordTypeName.equals(Label.EIS_Vendor_Inspection_Form_Record_Type)) {
                //populate refrigeration values
                //populate freezer values
                freezerTempRecs = getTrackingRecords(allTrackingRecs,Label.EIS_Tracking_Temp_Type_Freezer);
                
                //populate handwash values
                handWashRecs = getTrackingRecords(allTrackingRecs,Label.EIS_Tracking_Temp_Type_Hand_Wash);
                
                //populate Internal Food Item
                internalTempRecs = getTrackingRecords(allTrackingRecs,Label.EIS_Tracking_Temp_Type_Food_Item);   
            }
            
            if(currentRecordTypeName.equals(Label.EIS_Waterpoint_Inspection_Form_Record_Type)) {
                //populate hydrants
                hydrantsList = getTrackingRecords(allTrackingRecs,Label.EIS_Tracking_Temp_Type_Hydrant);
                
            }
        }
        QuestionWrapperList =RecordQuestions_Query();
        
    }
   
   
    public List<wQuestions> getAllQuestions(){
        
        allQuestions =  [SELECT Criticality__c,Form__c,Question__c,Sr_No__c,Id,Weightage__c
                         FROM EIS_Questions__mdt
                         WHERE Form__c =: auditIns.RecordType.DeveloperName
                         ORDER BY Sr_No__c ASC];
        
        questions    = [SELECT Id, EIS_Metadata_Question_Id__c, EIS_Issued__c, Points__c, EIS_Corrected__c, EIS_Criticality__c, EIS_Observation_Level__c,
                        EIS_Question_Text__c, Name, 
                        (SELECT Name, Id, EIS_Description__c, Question__r.Points__c, Question__r.EIS_Criticality__c, Question__r.EIS_Observation_Level__c,
                         Question__r.EIS_Question_Text__c,  Question__r.EIS_Corrected__c
                         FROM Findings__r ORDER BY CreatedDate)
                        FROM Questions__c
                        WHERE Audit_Inspections__c =: inspection.id];
            
           
            
        
        objWQuestions = new List<wQuestions>();
        set<string> setString = new set<string>();     
        for(questions__c q : questions){
            setString.add(q.EIS_Metadata_Question_Id__c);
        }
        
        for(EIS_Questions__mdt q: allQuestions ){
            wQuestions objWQuestions1 = new wQuestions();
            objWQuestions1.ques = q;
            objWQuestions1.checkQues = setString.contains(q.id);
            objWQuestions.add(objWQuestions1);
        }
        
        return objWQuestions;
    }
    public List<QuestionWrapper> RecordQuestions_Query(){
        List<Questions__c> questionList = [SELECT Id, EIS_Metadata_Question_Id__c, EIS_Issued__c, Points__c, EIS_Corrected__c, EIS_Criticality__c, EIS_Observation_Level__c,
                                           EIS_Question_Text__c, Name, 
                                           (SELECT Name, Id, EIS_Description__c, Question__r.Points__c, Question__r.EIS_Criticality__c, Question__r.EIS_Observation_Level__c,
                                            Question__r.EIS_Question_Text__c,  Question__r.EIS_Corrected__c
                                            FROM Findings__r ORDER BY CreatedDate)
                                           FROM Questions__c
                                           WHERE Audit_Inspections__c =: inspection.id];
        for (Questions__c q: questionList) {
            if (String.isNotBlank(q.EIS_Metadata_Question_Id__c)) {
                for (Finding__c f: q.Findings__r) { findingIdList.add(f.Id); }
            }
        }
       
         CADUeDates = '';
        Map<id,FindingWrapper> FindingMap = new Map<id,FindingWrapper>();
        for(Finding__c find: [select id,name,EIS_Description__c, Question__r.Points__c, Question__r.EIS_Criticality__c, Question__r.EIS_Observation_Level__c,
                                            Question__r.EIS_Question_Text__c,  Question__r.EIS_Corrected__c,
                                   (SELECT Id, EIS_Status__c, EIS_Date_of_Not_Started_Status__c, EIS_Description__c, EIS_Assigned_to__c, EIS_Finding__r.EIS_Description__c, EIS_Finding__c,
                             EIS_Date_of_In_Progress_Status__c, EIS_Date_of_Corrected_Status__c, EIS_Date_of_Correction_Failed_Status__c, EIS_Due_Date__c, EIS_Finding__r.Name,
                             EIS_Finding__r.Question__c FROM Corrective_Actions__r
                             ORDER BY EIS_Finding__r.Name) from Finding__c where id In :findingIdList]){
                                 
                                 for(Corrective_Action__c cor: find.Corrective_actions__r){
                                 if(cor.EIS_Due_Date__c !=Null) {                                
                                 
                                 CADueDates +=' '+cor.EIS_Due_Date__c.month()+'/'+cor.EIS_Due_Date__c.day() +'/'+cor.EIS_Due_Date__c.year()+',';//Lakshmi
                                 //CADueDates = CADueDates.substring(0,CADueDates.length());
                                 }
                             }
                             
                                  
                                FindingMap.put(find.id,new FindingWrapper(find,find.Corrective_Actions__r));
                             
        }  
        QuestionWrapperList = new list<QuestionWrapper>();
        for (Questions__c q: questionList) {
                        
            if(q.EIS_Observation_Level__c==Label.EIS_Questions_Obs_Level_PV){
                q.Points__c=4;
            }
            else{
                q.Points__c=2; 
            }
            list<FindingWrapper> FindingList1 = new list<FindingWrapper>();         
            if (String.isNotBlank(q.EIS_Metadata_Question_Id__c)) {
                
                for (Finding__c find : q.Findings__r) { 
                    FindingList1.add(findingMap.get(find.id));
                }
            }
            
           QuestionWrapperList.add(new QuestionWrapper(q,Findinglist1));  
     }
          // return questionList;
          
        //if(CADueDates.length() > 6)
                            // CADueDates = CADueDates.substring(0,CADueDates.length()-1); 
       return QuestionWrapperList ;
    }
    public class QuestionWrapper{
        public Questions__c Question{get;set;}
        public list<FindingWrapper> FindingList{get;set;}
        public QuestionWrapper(Questions__c que, list<FindingWrapper> findlist){
            Question = que; FindingList = findlist ;
        }
    }
    public class FindingWrapper {
        public Finding__c Finding{get;set;}
        public list<Corrective_Action__c>CorrectiveActionList{get;set;}
        public FindingWrapper( Finding__c find,list<Corrective_Action__c> Corlist){
            CorrectiveActionList = new List<Corrective_Action__c>();
            Finding = find; 
            for(Corrective_Action__c corrAction : corList) {
                if(corrAction.EIS_Description__c != null)
                    CorrectiveActionList.add(corrAction);
            }
        }
    }
    public list<Corrective_Action__c> getCorrectiveActions(){
        System.debug('FindingIdList : ' + findingIdList);
        correctiveActions = [SELECT Id, EIS_Status__c, EIS_Date_of_Not_Started_Status__c, EIS_Description__c, EIS_Assigned_to__c, EIS_Finding__r.EIS_Description__c, EIS_Finding__c,
                             EIS_Date_of_In_Progress_Status__c, EIS_Date_of_Corrected_Status__c, EIS_Date_of_Correction_Failed_Status__c, EIS_Due_Date__c, EIS_Finding__r.Name,
                             EIS_Finding__r.Question__c FROM Corrective_Action__c
                             WHERE EIS_Finding__c IN: findingIdList
                             ORDER BY EIS_Finding__r.Name];
        FindingList = [select id,name,(SELECT Id, EIS_Status__c, EIS_Date_of_Not_Started_Status__c, EIS_Description__c, EIS_Assigned_to__c, EIS_Finding__r.EIS_Description__c, EIS_Finding__c,
                             EIS_Date_of_In_Progress_Status__c, EIS_Date_of_Corrected_Status__c, EIS_Date_of_Correction_Failed_Status__c, EIS_Due_Date__c, EIS_Finding__r.Name,
                             EIS_Finding__r.Question__c FROM Corrective_Actions__r
                             ORDER BY EIS_Finding__r.Name) from Finding__c where id In :findingIdList];   
      System.debug('EIS_Finding__r.Name : ' + correctiveActions);
        
       // CorrectiveActionsMap = new Map<id,list<Corrective_Action__c>>();
       
        return CorrectiveActions;
        
       
    }
     
    Public class wQuestions{
        Public EIS_Questions__mdt ques{get;set;}
        Public Boolean checkQues{get;set;}
    }
    
    public List<tracking__c> getTrackingRecords(List<tracking__c> allTrackingRecs,String temparatureType) {
        system.debug('AllTracking Recs '+allTrackingRecs);
        List<tracking__c> listTobePopulated = new List<tracking__c>();
        if(allTrackingRecs.size() > 0) {
            if(temparatureType!=null) {
                for(tracking__c tr : allTrackingRecs) {
                    if(tr.EIS_Temperature_Type__c.equals(temparatureType)) {
                        listTobePopulated.add(tr);
                    }
                }
            }
        }
        
        return listTobePopulated;
    }
}
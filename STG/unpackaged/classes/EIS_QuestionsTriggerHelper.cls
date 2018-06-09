/**
*————————————————————————————————————————————————————
* @Name             EIS_QuestionsTriggerHelper
* @Author           Duy Tran
* @Created Date     06-17-2017
* @Used By          QuestionsTriggerHandler.apxc
*————————————————————————————————————————————————————
* @Description
* Helper class to handle trigger logic for Questions__c object
* 
*————————————————————————————————————————————————————
* @Changes
* 06-17-2017    Initial creation. Increment Questions count and scores on Audit_Inspections__c, Inspection Record Type related
* 07-06-2017    Implemented logic for food cart record type
**/
public class EIS_QuestionsTriggerHelper {
    @TestVisible private static final Integer POTENTIAL_VIOLATION_POINTS = Integer.valueOf(AEPHIS_Settings__c.getValues('Question Point: Potential Violation').EIS_Integer_Value__c);
    @TestVisible private static final Integer MANAGEMENT_PRACTICE_POINTS = Integer.valueOf(AEPHIS_Settings__c.getValues('Question Point: Management Practice').EIS_Integer_Value__c);
    @TestVisible private static final Integer REPEAT_FINDING_POINTS = Integer.valueOf(AEPHIS_Settings__c.getValues('Question Point: Repeat Finding').EIS_Integer_Value__c);
    /**
    *————————————————————————————————————————————————————
    * @Description
    * Update Questions__c counts and scores on Audit_Inspection__c after insert
    * Only perform update on Inspection record type 
    *————————————————————————————————————————————————————
    * @param    newList     List of newly inserted Questions__c
    * @return   void
    *————————————————————————————————————————————————————
    **/
    public void updateInspections_AfterInsert(List<Questions__c> newList) {
        Map<String, List<Questions__c>> questionMap = new Map<String, List<Questions__c>>();
        for (Questions__c q : newList) {
            if (q.RecordTypeId == EIS_StaticUtils.QUESTIONS_INSPECTION_RTID) {
                if (questionMap.get(q.Audit_Inspections__c) == null) {
                    questionMap.put(q.Audit_Inspections__c, new List<Questions__c>());
                }
                questionMap.get(q.Audit_Inspections__c).add(q);
            }
        }
        
        List<Audit_Inspections__c> inspectionList = getInspectionList(questionMap.keySet());

        for (Integer i = 0; i < inspectionList.size(); i++) {
            //Check for Food Car record type
            if (inspectionList[i].RecordTypeId == EIS_StaticUtils.INSPECTION_FOOD_CAR_RTID) {
                for (Questions__c q : questionMap.get(inspectionList[i].Id)) {
                    inspectionList[i].PH_Score__c -= (Integer)q.Points__c;
                    if (q.EIS_Section_Name__c != null && q.EIS_Section_Name__c.containsIgnoreCase(Label.EIS_Questions_Section_OBS_Critical)) {
                        inspectionList[i].OBS_Critical_Violations__c += 1;
                        inspectionList[i].OBS_Points_Missed__c += q.Points__c;
                    } else if (q.EIS_Section_Name__c != null && q.EIS_Section_Name__c.containsIgnoreCase(Label.EIS_Questions_Section_Mech_Critical)) {
                        inspectionList[i].Mech_Critical_Violations__c += 1;
                        inspectionList[i].Mech_Points_Missed__c += q.Points__c;
                    } else {
                        if (Label.EIS_Questions_Section_OBS_Other.equalsIgnoreCase(q.EIS_Section_Name__c)) {
                            inspectionList[i].OBS_Noncritical_Violations__c += 1;
                            inspectionList[i].OBS_Points_Missed__c += q.Points__c;
                        } else if (Label.EIS_Questions_Section_Mech_Other.equalsIgnoreCase(q.EIS_Section_Name__c)) {
                            inspectionList[i].Mech_Noncritical_Violations__c += 1;
                            inspectionList[i].Mech_Points_Missed__c += q.Points__c;
                        }
                    }
                    
                    if (Label.EIS_Questions_Criticality_Critical.equalsIgnoreCase(q.EIS_Criticality__c)) {
                        inspectionList[i].EIS_Count_Critical_Questions__c += 1;
                    } else {
                        inspectionList[i].EIS_Count_Non_Critical_Questions__c += 1;
                    }
                    if (inspectionList[i].PH_Score__c < 90 || inspectionList[i].EIS_Count_Critical_Questions__c > 0) {
                        inspectionList[i].PH_Report_Status__c = Label.EIS_Audit_Inspection_Report_Status_Conditional;
                    } else {
                        inspectionList[i].PH_Report_Status__c = Label.EIS_Audit_Inspection_Report_Status_Satisfactory;
                    }
                }
            } else if (inspectionList[i].RecordTypeId == EIS_StaticUtils.INSPECTION_COMMISSARY_RTID ||
                       inspectionList[i].RecordTypeId == EIS_StaticUtils.INSPECTION_WATERPOINT_RTID ||
                       inspectionList[i].RecordTypeId == EIS_StaticUtils.INSPECTION_VENDOR_RTID) {
                for (Questions__c q : questionMap.get(inspectionList[i].Id)) {
                    inspectionList[i].PH_Score__c -= (Integer)q.Points__c;
                    if (Label.EIS_Questions_Criticality_Critical.equalsIgnoreCase(q.EIS_Criticality__c)) {
                        inspectionList[i].EIS_Count_Critical_Questions__c += 1;
                    } else {
                        inspectionList[i].EIS_Count_Non_Critical_Questions__c += 1;
                    }
                    if (inspectionList[i].PH_Score__c < 90 || inspectionList[i].EIS_Count_Critical_Questions__c > 0) {
                        inspectionList[i].PH_Report_Status__c = Label.EIS_Audit_Inspection_Report_Status_Conditional;
                    } else {
                        inspectionList[i].PH_Report_Status__c = Label.EIS_Audit_Inspection_Report_Status_Satisfactory;
                    }
                }
            } else if (inspectionList[i].RecordTypeId == EIS_StaticUtils.INSPECTION_AUDIT_FORM_RTID || inspectionList[i].RecordTypeId == EIS_StaticUtils.INSPECTION_SFA_FORM_RTID) {
                for (Questions__c q : questionMap.get(inspectionList[i].Id)) {
                    Boolean isPV = Label.EIS_Questions_Obs_Level_PV.equalsIgnoreCase(q.EIS_Observation_Level__c);
                    if ((q.EIS_Count_Finding_Engineering__c + q.EIS_Count_Repeat_Engineering__c) > 0) {
                        inspectionList[i].EIS_Department_Score_Engineering__c -= (isPV ? POTENTIAL_VIOLATION_POINTS : MANAGEMENT_PRACTICE_POINTS);
                    }
                    if ((q.EIS_Count_Finding_Environment__c + q.EIS_Count_Repeat_Environment__c) > 0) {
                        inspectionList[i].EIS_Department_Score_Environment__c -= (isPV ? POTENTIAL_VIOLATION_POINTS : MANAGEMENT_PRACTICE_POINTS);
                    }
                    if ((q.EIS_Count_Finding_Material__c + q.EIS_Count_Repeat_Material__c) > 0) {
                        inspectionList[i].EIS_Department_Score_Material__c -= (isPV ? POTENTIAL_VIOLATION_POINTS : MANAGEMENT_PRACTICE_POINTS);
                    }
                    if ((q.EIS_Count_Finding_Mechanical__c + q.EIS_Count_Repeat_Mechanical__c) > 0) {
                        inspectionList[i].EIS_Department_Score_Mechanical__c -= (isPV ? POTENTIAL_VIOLATION_POINTS : MANAGEMENT_PRACTICE_POINTS);
                    }
                    if ((q.EIS_Count_Finding_Transportation__c + q.EIS_Count_Repeat_Transportation__c) > 0) {
                        inspectionList[i].EIS_Department_Score_Transportation__c -= (isPV ? POTENTIAL_VIOLATION_POINTS : MANAGEMENT_PRACTICE_POINTS);
                    }
                    
                    if (q.EIS_Count_Repeat_Engineering__c > 0) inspectionList[i].EIS_Department_Score_Engineering__c -= REPEAT_FINDING_POINTS;
                    if (q.EIS_Count_Repeat_Environment__c > 0) inspectionList[i].EIS_Department_Score_Environment__c -= REPEAT_FINDING_POINTS;
                    if (q.EIS_Count_Repeat_Material__c > 0) inspectionList[i].EIS_Department_Score_Material__c -= REPEAT_FINDING_POINTS;
                    if (q.EIS_Count_Repeat_Mechanical__c > 0) inspectionList[i].EIS_Department_Score_Mechanical__c -= REPEAT_FINDING_POINTS;
                    if (q.EIS_Count_Repeat_Transportation__c > 0) inspectionList[i].EIS_Department_Score_Transportation__c -= REPEAT_FINDING_POINTS;
                    
                    if (isPV) {
                        inspectionList[i].EIS_Potential_Violation_Engineering__c += (q.EIS_Count_Finding_Engineering__c + q.EIS_Count_Repeat_Engineering__c);
                        inspectionList[i].EIS_Potential_Violation_Environment__c += (q.EIS_Count_Finding_Environment__c + q.EIS_Count_Repeat_Environment__c);
                        inspectionList[i].EIS_Potential_Violation_Material__c += (q.EIS_Count_Finding_Material__c + q.EIS_Count_Repeat_Material__c);
                        inspectionList[i].EIS_Potential_Violation_Mechanical__c += (q.EIS_Count_Finding_Mechanical__c + q.EIS_Count_Repeat_Mechanical__c);
                        inspectionList[i].EIS_Potential_Violation_Transportation__c += (q.EIS_Count_Finding_Transportation__c + q.EIS_Count_Repeat_Transportation__c);
                    } else {
                        inspectionList[i].EIS_Management_Practice_Engineering__c += (q.EIS_Count_Finding_Engineering__c + q.EIS_Count_Repeat_Engineering__c);
                        inspectionList[i].EIS_Management_Practice_Environment__c += (q.EIS_Count_Finding_Environment__c + q.EIS_Count_Repeat_Environment__c);
                        inspectionList[i].EIS_Management_Practice_Material__c += (q.EIS_Count_Finding_Material__c + q.EIS_Count_Repeat_Material__c);
                        inspectionList[i].EIS_Management_Practice_Mechanical__c += (q.EIS_Count_Finding_Mechanical__c + q.EIS_Count_Repeat_Mechanical__c);
                        inspectionList[i].EIS_Management_Practice_Transportation__c += (q.EIS_Count_Finding_Transportation__c + q.EIS_Count_Repeat_Transportation__c);
                    }
                }
            }
        }
        update inspectionList;
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Description
    * Update Questions__c counts and scores on Audit_Inspection__c after delete
    * Only perform update on Inspection record type 
    *————————————————————————————————————————————————————
    * @param    oldList     List of to be deleted Questions__c
    * @return   void
    *————————————————————————————————————————————————————
    **/
    public void updateInspections_AfterDelete(List<Questions__c> oldList) {
        Map<String, List<Questions__c>> questionMap = new Map<String, List<Questions__c>>();
        for (Questions__c q : oldList) {
            if (q.RecordTypeId == EIS_StaticUtils.QUESTIONS_INSPECTION_RTID) {
                if (questionMap.get(q.Audit_Inspections__c) == null) {
                    questionMap.put(q.Audit_Inspections__c, new List<Questions__c>());
                }
                questionMap.get(q.Audit_Inspections__c).add(q);
            }
        }
        List<Audit_Inspections__c> inspectionList = getInspectionList(questionMap.keySet());
        for (Integer i = 0; i < inspectionList.size(); i++) {
            if (inspectionList[i].RecordTypeId == EIS_StaticUtils.INSPECTION_FOOD_CAR_RTID) {
                for (Questions__c q : questionMap.get(inspectionList[i].Id)) {
                    inspectionList[i].PH_Score__c += (Integer)q.Points__c;
                    if (q.EIS_Section_Name__c != null && q.EIS_Section_Name__c.containsIgnoreCase(Label.EIS_Questions_Section_OBS_Critical)) {
                        inspectionList[i].OBS_Critical_Violations__c -= 1;
                        inspectionList[i].OBS_Points_Missed__c -= q.Points__c;
                    } else if (q.EIS_Section_Name__c != null && q.EIS_Section_Name__c.containsIgnoreCase(Label.EIS_Questions_Section_Mech_Critical)) {
                        inspectionList[i].Mech_Critical_Violations__c -= 1;
                        inspectionList[i].Mech_Points_Missed__c -= q.Points__c;
                    } else {
                        if (Label.EIS_Questions_Section_OBS_Other.equalsIgnoreCase(q.EIS_Section_Name__c)) {
                            inspectionList[i].OBS_Noncritical_Violations__c -= 1;
                            inspectionList[i].OBS_Points_Missed__c -= q.Points__c;
                        } else if (Label.EIS_Questions_Section_Mech_Other.equalsIgnoreCase(q.EIS_Section_Name__c)) {
                            inspectionList[i].Mech_Noncritical_Violations__c -= 1;
                            inspectionList[i].Mech_Points_Missed__c -= q.Points__c;
                        }
                    }
                    
                    if (Label.EIS_Questions_Criticality_Critical.equalsIgnoreCase(q.EIS_Criticality__c)) {
                        inspectionList[i].EIS_Count_Critical_Questions__c -= 1;
                    } else {
                        inspectionList[i].EIS_Count_Non_Critical_Questions__c -= 1;
                    }
                    if (inspectionList[i].PH_Score__c < 90 || inspectionList[i].EIS_Count_Critical_Questions__c > 0) {
                        inspectionList[i].PH_Report_Status__c = Label.EIS_Audit_Inspection_Report_Status_Conditional;
                    } else {
                        inspectionList[i].PH_Report_Status__c = Label.EIS_Audit_Inspection_Report_Status_Satisfactory;
                    }
                }
            } else if (inspectionList[i].RecordTypeId == EIS_StaticUtils.INSPECTION_COMMISSARY_RTID || 
                       inspectionList[i].RecordTypeId == EIS_StaticUtils.INSPECTION_WATERPOINT_RTID || 
                       inspectionList[i].RecordTypeId == EIS_StaticUtils.INSPECTION_VENDOR_RTID) {
                for (Questions__c q : questionMap.get(inspectionList[i].Id)) {
                    inspectionList[i].PH_Score__c += (Integer)q.Points__c;
                    if (Label.EIS_Questions_Criticality_Critical.equalsIgnoreCase(q.EIS_Criticality__c)) {
                        inspectionList[i].EIS_Count_Critical_Questions__c -= 1;
                    } else {
                        inspectionList[i].EIS_Count_Non_Critical_Questions__c -= 1;
                    }
                    if (inspectionList[i].PH_Score__c < 90 || inspectionList[i].EIS_Count_Critical_Questions__c > 0) {
                        inspectionList[i].PH_Report_Status__c = Label.EIS_Audit_Inspection_Report_Status_Conditional;
                    } else {
                        inspectionList[i].PH_Report_Status__c = Label.EIS_Audit_Inspection_Report_Status_Satisfactory;
                    }
                }
            } else if (inspectionList[i].RecordTypeId == EIS_StaticUtils.INSPECTION_AUDIT_FORM_RTID || inspectionList[i].RecordTypeId == EIS_StaticUtils.INSPECTION_SFA_FORM_RTID) {
                for (Questions__c q : questionMap.get(inspectionList[i].Id)) {
                    Boolean isPV = Label.EIS_Questions_Obs_Level_PV.equalsIgnoreCase(q.EIS_Observation_Level__c);
                    if ((q.EIS_Count_Finding_Engineering__c + q.EIS_Count_Repeat_Engineering__c) > 0) {
                        inspectionList[i].EIS_Department_Score_Engineering__c += (isPV ? POTENTIAL_VIOLATION_POINTS : MANAGEMENT_PRACTICE_POINTS);
                    }
                    if ((q.EIS_Count_Finding_Environment__c + q.EIS_Count_Repeat_Environment__c) > 0) {
                        inspectionList[i].EIS_Department_Score_Environment__c += (isPV ? POTENTIAL_VIOLATION_POINTS : MANAGEMENT_PRACTICE_POINTS);
                    }
                    if ((q.EIS_Count_Finding_Material__c + q.EIS_Count_Repeat_Material__c) > 0) {
                        inspectionList[i].EIS_Department_Score_Material__c += (isPV ? POTENTIAL_VIOLATION_POINTS : MANAGEMENT_PRACTICE_POINTS);
                    }
                    if ((q.EIS_Count_Finding_Mechanical__c + q.EIS_Count_Repeat_Mechanical__c) > 0) {
                        inspectionList[i].EIS_Department_Score_Mechanical__c += (isPV ? POTENTIAL_VIOLATION_POINTS : MANAGEMENT_PRACTICE_POINTS);
                    }
                    if ((q.EIS_Count_Finding_Transportation__c + q.EIS_Count_Repeat_Transportation__c) > 0) {
                        inspectionList[i].EIS_Department_Score_Transportation__c += (isPV ? POTENTIAL_VIOLATION_POINTS : MANAGEMENT_PRACTICE_POINTS);
                    }
                    
                    if (q.EIS_Count_Repeat_Engineering__c > 0) inspectionList[i].EIS_Department_Score_Engineering__c += REPEAT_FINDING_POINTS;
                    if (q.EIS_Count_Repeat_Environment__c > 0) inspectionList[i].EIS_Department_Score_Environment__c += REPEAT_FINDING_POINTS;
                    if (q.EIS_Count_Repeat_Material__c > 0) inspectionList[i].EIS_Department_Score_Material__c += REPEAT_FINDING_POINTS;
                    if (q.EIS_Count_Repeat_Mechanical__c > 0) inspectionList[i].EIS_Department_Score_Mechanical__c += REPEAT_FINDING_POINTS;
                    if (q.EIS_Count_Repeat_Transportation__c > 0) inspectionList[i].EIS_Department_Score_Transportation__c += REPEAT_FINDING_POINTS;
                    
                    if (isPV) {
                        inspectionList[i].EIS_Potential_Violation_Engineering__c -= (q.EIS_Count_Finding_Engineering__c + q.EIS_Count_Repeat_Engineering__c);
                        inspectionList[i].EIS_Potential_Violation_Environment__c -= (q.EIS_Count_Finding_Environment__c + q.EIS_Count_Repeat_Environment__c);
                        inspectionList[i].EIS_Potential_Violation_Material__c -= (q.EIS_Count_Finding_Material__c + q.EIS_Count_Repeat_Material__c);
                        inspectionList[i].EIS_Potential_Violation_Mechanical__c -= (q.EIS_Count_Finding_Mechanical__c + q.EIS_Count_Repeat_Mechanical__c);
                        inspectionList[i].EIS_Potential_Violation_Transportation__c -= (q.EIS_Count_Finding_Transportation__c + q.EIS_Count_Repeat_Transportation__c);
                    } else {
                        inspectionList[i].EIS_Management_Practice_Engineering__c -= (q.EIS_Count_Finding_Engineering__c + q.EIS_Count_Repeat_Engineering__c);
                        inspectionList[i].EIS_Management_Practice_Environment__c -= (q.EIS_Count_Finding_Environment__c + q.EIS_Count_Repeat_Environment__c);
                        inspectionList[i].EIS_Management_Practice_Material__c -= (q.EIS_Count_Finding_Material__c + q.EIS_Count_Repeat_Material__c);
                        inspectionList[i].EIS_Management_Practice_Mechanical__c -= (q.EIS_Count_Finding_Mechanical__c + q.EIS_Count_Repeat_Mechanical__c);
                        inspectionList[i].EIS_Management_Practice_Transportation__c -= (q.EIS_Count_Finding_Transportation__c + q.EIS_Count_Repeat_Transportation__c);
                    }
                }
            }
        }
        update inspectionList;
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Description
    * Update Questions__c counts and scores on Audit_Inspection__c after Update
    * Only perform update on Inspection record type 
    *————————————————————————————————————————————————————
    * @param    oldList     List of old Questions__c
    * @param    newList     List of newly updated Questions__c
    * @return   void
    *————————————————————————————————————————————————————
    **/
    public void updateInspections_AfterUpdate(List<Questions__c> oldList, List<Questions__c> newList) {
        Map<Id, List<Questions__c>> questionMapOld = new Map<Id, List<Questions__c>>();
        Map<Id, List<Questions__c>> questionMapNew = new Map<Id, List<Questions__c>>();
        for (Questions__c q : oldList) {
            if (q.RecordTypeId == EIS_StaticUtils.QUESTIONS_INSPECTION_RTID) {
                if (questionMapOld.get(q.Audit_Inspections__c) == null) {
                    questionMapOld.put(q.Audit_Inspections__c, new List<Questions__c>());
                }
                questionMapOld.get(q.Audit_Inspections__c).add(q);
            }
        }
        for (Questions__c q : newList) {
            if (q.RecordTypeId == EIS_StaticUtils.QUESTIONS_INSPECTION_RTID) {
                if (questionMapNew.get(q.Audit_Inspections__c) == null) {
                    questionMapNew.put(q.Audit_Inspections__c, new List<Questions__c>());
                }
                questionMapNew.get(q.Audit_Inspections__c).add(q);
            }
        }
        List<Audit_Inspections__c> inspectionList = [
            SELECT Id, PH_Score__c, EIS_Count_Critical_Questions__c, EIS_Count_Non_Critical_Questions__c,
            EIS_Count_Open_Immediate_CA__c, EIS_Count_Closed_Immediate_CA__c, EIS_Count_Open_Long_Term_CA__c, EIS_Count_Closed_Long_Term_CA__c, EIS_Department_Score_Engineering__c, 
            EIS_Department_Score_Environment__c, EIS_Department_Score_Material__c, EIS_Department_Score_Mechanical__c, EIS_Department_Score_Transportation__c,
            EIS_Management_Practice_Engineering__c, EIS_Management_Practice_Environment__c, 
            EIS_Management_Practice_Material__c, EIS_Management_Practice_Mechanical__c, EIS_Management_Practice_Transportation__c,
            EIS_Potential_Violation_Engineering__c, EIS_Potential_Violation_Environment__c, EIS_Potential_Violation_Material__c, 
            EIS_Potential_Violation_Mechanical__c, EIS_Potential_Violation_Transportation__c
            FROM Audit_Inspections__c 
            WHERE Id IN :questionMapOld.keySet() AND RecordTypeId IN (:EIS_StaticUtils.INSPECTION_AUDIT_FORM_RTID,:EIS_StaticUtils.INSPECTION_SFA_FORM_RTID)
        ];
        for (Integer i = 0; i < inspectionList.size(); i++) {
            for (Questions__c q : questionMapOld.get(inspectionList[i].Id)) {
                inspectionList[i].EIS_Count_Open_Immediate_CA__c -= q.EIS_Count_Open_Immediate_CA__c;
                inspectionList[i].EIS_Count_Closed_Immediate_CA__c -= q.EIS_Count_Closed_Immediate_CA__c;
                inspectionList[i].EIS_Count_Open_Long_Term_CA__c -= q.EIS_Count_Open_Long_Term_CA__c;
                inspectionList[i].EIS_Count_Closed_Long_Term_CA__c -= q.EIS_Count_Closed_Long_Term_CA__c;
                
                Boolean isPV = Label.EIS_Questions_Obs_Level_PV.equalsIgnoreCase(q.EIS_Observation_Level__c);
                if ((q.EIS_Count_Finding_Engineering__c + q.EIS_Count_Repeat_Engineering__c) > 0) {
                    inspectionList[i].EIS_Department_Score_Engineering__c += (isPV ? POTENTIAL_VIOLATION_POINTS : MANAGEMENT_PRACTICE_POINTS);
                }
                if ((q.EIS_Count_Finding_Environment__c + q.EIS_Count_Repeat_Environment__c) > 0) {
                    inspectionList[i].EIS_Department_Score_Environment__c += (isPV ? POTENTIAL_VIOLATION_POINTS : MANAGEMENT_PRACTICE_POINTS);
                }
                if ((q.EIS_Count_Finding_Material__c + q.EIS_Count_Repeat_Material__c) > 0) {
                    inspectionList[i].EIS_Department_Score_Material__c += (isPV ? POTENTIAL_VIOLATION_POINTS : MANAGEMENT_PRACTICE_POINTS);
                }
                if ((q.EIS_Count_Finding_Mechanical__c + q.EIS_Count_Repeat_Mechanical__c) > 0) {
                    inspectionList[i].EIS_Department_Score_Mechanical__c += (isPV ? POTENTIAL_VIOLATION_POINTS : MANAGEMENT_PRACTICE_POINTS);
                }
                if ((q.EIS_Count_Finding_Transportation__c + q.EIS_Count_Repeat_Transportation__c) > 0) {
                    inspectionList[i].EIS_Department_Score_Transportation__c += (isPV ? POTENTIAL_VIOLATION_POINTS : MANAGEMENT_PRACTICE_POINTS);
                }
                
                if (q.EIS_Count_Repeat_Engineering__c > 0) inspectionList[i].EIS_Department_Score_Engineering__c += REPEAT_FINDING_POINTS;
                if (q.EIS_Count_Repeat_Environment__c > 0) inspectionList[i].EIS_Department_Score_Environment__c += REPEAT_FINDING_POINTS;
                if (q.EIS_Count_Repeat_Material__c > 0) inspectionList[i].EIS_Department_Score_Material__c += REPEAT_FINDING_POINTS;
                if (q.EIS_Count_Repeat_Mechanical__c > 0) inspectionList[i].EIS_Department_Score_Mechanical__c += REPEAT_FINDING_POINTS;
                if (q.EIS_Count_Repeat_Transportation__c > 0) inspectionList[i].EIS_Department_Score_Transportation__c += REPEAT_FINDING_POINTS;
                
                if (isPV) {
                    inspectionList[i].EIS_Potential_Violation_Engineering__c -= (q.EIS_Count_Finding_Engineering__c + q.EIS_Count_Repeat_Engineering__c);
                    inspectionList[i].EIS_Potential_Violation_Environment__c -= (q.EIS_Count_Finding_Environment__c + q.EIS_Count_Repeat_Environment__c);
                    inspectionList[i].EIS_Potential_Violation_Material__c -= (q.EIS_Count_Finding_Material__c + q.EIS_Count_Repeat_Material__c);
                    inspectionList[i].EIS_Potential_Violation_Mechanical__c -= (q.EIS_Count_Finding_Mechanical__c + q.EIS_Count_Repeat_Mechanical__c);
                    inspectionList[i].EIS_Potential_Violation_Transportation__c -= (q.EIS_Count_Finding_Transportation__c + q.EIS_Count_Repeat_Transportation__c);
                } else {
                    inspectionList[i].EIS_Management_Practice_Engineering__c -= (q.EIS_Count_Finding_Engineering__c + q.EIS_Count_Repeat_Engineering__c);
                    inspectionList[i].EIS_Management_Practice_Environment__c -= (q.EIS_Count_Finding_Environment__c + q.EIS_Count_Repeat_Environment__c);
                    inspectionList[i].EIS_Management_Practice_Material__c -= (q.EIS_Count_Finding_Material__c + q.EIS_Count_Repeat_Material__c);
                    inspectionList[i].EIS_Management_Practice_Mechanical__c -= (q.EIS_Count_Finding_Mechanical__c + q.EIS_Count_Repeat_Mechanical__c);
                    inspectionList[i].EIS_Management_Practice_Transportation__c -= (q.EIS_Count_Finding_Transportation__c + q.EIS_Count_Repeat_Transportation__c);
                }
            }
            for (Questions__c q : questionMapNew.get(inspectionList[i].Id)) {
                inspectionList[i].EIS_Count_Open_Immediate_CA__c += q.EIS_Count_Open_Immediate_CA__c;
                inspectionList[i].EIS_Count_Closed_Immediate_CA__c += q.EIS_Count_Closed_Immediate_CA__c;
                inspectionList[i].EIS_Count_Open_Long_Term_CA__c += q.EIS_Count_Open_Long_Term_CA__c;
                inspectionList[i].EIS_Count_Closed_Long_Term_CA__c += q.EIS_Count_Closed_Long_Term_CA__c;
                
                Boolean isPV = Label.EIS_Questions_Obs_Level_PV.equalsIgnoreCase(q.EIS_Observation_Level__c);
                if ((q.EIS_Count_Finding_Engineering__c + q.EIS_Count_Repeat_Engineering__c) > 0) {
                    inspectionList[i].EIS_Department_Score_Engineering__c -= (isPV ? POTENTIAL_VIOLATION_POINTS : MANAGEMENT_PRACTICE_POINTS);
                }
                if ((q.EIS_Count_Finding_Environment__c + q.EIS_Count_Repeat_Environment__c) > 0) {
                    inspectionList[i].EIS_Department_Score_Environment__c -= (isPV ? POTENTIAL_VIOLATION_POINTS : MANAGEMENT_PRACTICE_POINTS);
                }
                if ((q.EIS_Count_Finding_Material__c + q.EIS_Count_Repeat_Material__c) > 0) {
                    inspectionList[i].EIS_Department_Score_Material__c -= (isPV ? POTENTIAL_VIOLATION_POINTS : MANAGEMENT_PRACTICE_POINTS);
                }
                if ((q.EIS_Count_Finding_Mechanical__c + q.EIS_Count_Repeat_Mechanical__c) > 0) {
                    inspectionList[i].EIS_Department_Score_Mechanical__c -= (isPV ? POTENTIAL_VIOLATION_POINTS : MANAGEMENT_PRACTICE_POINTS);
                }
                if ((q.EIS_Count_Finding_Transportation__c + q.EIS_Count_Repeat_Transportation__c) > 0) {
                    inspectionList[i].EIS_Department_Score_Transportation__c -= (isPV ? POTENTIAL_VIOLATION_POINTS : MANAGEMENT_PRACTICE_POINTS);
                }
                
                if (q.EIS_Count_Repeat_Engineering__c > 0) inspectionList[i].EIS_Department_Score_Engineering__c -= REPEAT_FINDING_POINTS;
                if (q.EIS_Count_Repeat_Environment__c > 0) inspectionList[i].EIS_Department_Score_Environment__c -= REPEAT_FINDING_POINTS;
                if (q.EIS_Count_Repeat_Material__c > 0) inspectionList[i].EIS_Department_Score_Material__c -= REPEAT_FINDING_POINTS;
                if (q.EIS_Count_Repeat_Mechanical__c > 0) inspectionList[i].EIS_Department_Score_Mechanical__c -= REPEAT_FINDING_POINTS;
                if (q.EIS_Count_Repeat_Transportation__c > 0) inspectionList[i].EIS_Department_Score_Transportation__c -= REPEAT_FINDING_POINTS;
                
                if (isPV) {
                    inspectionList[i].EIS_Potential_Violation_Engineering__c += (q.EIS_Count_Finding_Engineering__c + q.EIS_Count_Repeat_Engineering__c);
                    inspectionList[i].EIS_Potential_Violation_Environment__c += (q.EIS_Count_Finding_Environment__c + q.EIS_Count_Repeat_Environment__c);
                    inspectionList[i].EIS_Potential_Violation_Material__c += (q.EIS_Count_Finding_Material__c + q.EIS_Count_Repeat_Material__c);
                    inspectionList[i].EIS_Potential_Violation_Mechanical__c += (q.EIS_Count_Finding_Mechanical__c + q.EIS_Count_Repeat_Mechanical__c);
                    inspectionList[i].EIS_Potential_Violation_Transportation__c += (q.EIS_Count_Finding_Transportation__c + q.EIS_Count_Repeat_Transportation__c);
                } else {
                    inspectionList[i].EIS_Management_Practice_Engineering__c += (q.EIS_Count_Finding_Engineering__c + q.EIS_Count_Repeat_Engineering__c);
                    inspectionList[i].EIS_Management_Practice_Environment__c += (q.EIS_Count_Finding_Environment__c + q.EIS_Count_Repeat_Environment__c);
                    inspectionList[i].EIS_Management_Practice_Material__c += (q.EIS_Count_Finding_Material__c + q.EIS_Count_Repeat_Material__c);
                    inspectionList[i].EIS_Management_Practice_Mechanical__c += (q.EIS_Count_Finding_Mechanical__c + q.EIS_Count_Repeat_Mechanical__c);
                    inspectionList[i].EIS_Management_Practice_Transportation__c += (q.EIS_Count_Finding_Transportation__c + q.EIS_Count_Repeat_Transportation__c);
                }
            }
        }
        update inspectionList;
    }
    
    //Query for Audit/Inspection fields that need to be updated
    private static List<Audit_Inspections__c> getInspectionList(Set<String> keySet) {
        return [SELECT Id, PH_Score__c, EIS_Count_Critical_Questions__c, EIS_Count_Non_Critical_Questions__c, RecordTypeId, 
            OBS_Critical_Violations__c, OBS_Points_Missed__c,Mech_Critical_Violations__c, Mech_Points_Missed__c,
            OBS_Noncritical_Violations__c, Mech_Noncritical_Violations__c, EIS_Department_Score_Engineering__c, 
            EIS_Department_Score_Environment__c, EIS_Department_Score_Material__c, EIS_Department_Score_Mechanical__c, EIS_Department_Score_Transportation__c,
            EIS_Management_Practice_Engineering__c, EIS_Management_Practice_Environment__c, 
            EIS_Management_Practice_Material__c, EIS_Management_Practice_Mechanical__c, EIS_Management_Practice_Transportation__c,
            EIS_Potential_Violation_Engineering__c, EIS_Potential_Violation_Environment__c, EIS_Potential_Violation_Material__c, 
            EIS_Potential_Violation_Mechanical__c, EIS_Potential_Violation_Transportation__c
            FROM Audit_Inspections__c WHERE Id IN :keySet
        ];
    }
}
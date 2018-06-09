/**
*————————————————————————————————————————————————————
* @Name             EIS_CorrectiveActionTriggerHelper
* @Author           Duy Tran
* @Created Date     06-15-2017
* @Used By          CorrectiveActionTriggerHandler.apxc
*————————————————————————————————————————————————————
* @Description
* Helper class to handle trigger logic for Questions__c object
* 
*————————————————————————————————————————————————————
* @Changes
* 06-15-2017	Initial creation. Increment Corrective Action counts on Questions__c and Audit_Inspections__c, Inspection Record Type related
* 06-17-2017	Added more fields to be updated from Questions__c and Audit_Inspections__c, Inspection Record Type related
**/
public class EIS_CorrectiveActionTriggerHelper {
    private static final String STATUS_OPEN = ' Open';
    private static final String STATUS_CLOSED = ' Closed';
    private static final String CRITICAL = Label.EIS_Questions_Criticality_Critical;
    private static final String NONCRITICAL = Label.EIS_Questions_Criticality_Non_Critical;
    /**
    *————————————————————————————————————————————————————
    * @Description
    * Update Corrective Action count fields on Questions__c and Audit_Inspections after insert
    * Only perform update on Inspection record type 
    *————————————————————————————————————————————————————
    * @param    newList		List of newly inserted Corrective Actions
    * @return   void
    *————————————————————————————————————————————————————
    **/
    public void updateInspectionCorrectiveActionCount_AfterInsert(List<Corrective_Action__c> newList) {
        Map<Id,List<String>> statusMap = new Map<Id, List<String>>();			//Key: Finding Id, Value: List of CA status
        Map<Id,List<String>> auditStatusMap = new Map<Id, List<String>>();		//Key: Finding Id, Value: List of CA status
        populateStatusMaps(statusMap, auditStatusMap, newList);
        
        if (!statusMap.isEmpty() || !auditStatusMap.isEmpty()) {
            List<Finding__c> fList = [SELECT Id, Question__c, Question__r.Audit_Inspections__c, Question__r.EIS_Criticality__c 
                                      FROM Finding__c WHERE Id IN :statusMap.keySet() OR Id IN :auditStatusMap.keySet()];
            if (!fList.isEmpty()) {
                List<Id> qIds = new List<Id>();
                List<Id> aiIds = new List<Id>();
                List<Boolean> isCriticalList = new List<Boolean>();
                for (Finding__c f : fList) {
                    qIds.add(f.Question__c);
                    aiIds.add(f.Question__r.Audit_Inspections__c);
                    isCriticalList.add(CRITICAL.equalsIgnoreCase(f.Question__r.EIS_Criticality__c));
                }
                List<Questions__c> qList = getQuestionList(qIds);
                for (Integer j = 0; j < fList.size(); j++) {
                    for (Integer i = 0; i < qList.size(); i++) {
                        if (qList[i].Id == fList[j].Question__c) {
                            if (statusMap.get(fList[j].Id) != null) {
                                for (String status : statusMap.get(fList[j].Id)) {
                                    if (!status.equalsIgnoreCase(Label.EIS_Corrective_Action_Status_Correct)) {
                                        qList[i].EIS_Count_Not_Corrected_CA__c += 1;
                                    } else {
                                        qList[i].EIS_Count_Corrected_CA__c += 1;
                                    }
                                }
                                qList[i].EIS_Corrected__c = qList[i].EIS_Count_Not_Corrected_CA__c == 0 && qList[i].EIS_Count_Corrected_CA__c > 0;
                            }
                            if (auditStatusMap.get(fList[j].Id) != null) {
                                for (String status : auditStatusMap.get(fList[j].Id)) {
                                    if (status.equalsIgnoreCase(Label.EIS_Corrective_Action_Type_Immediate + STATUS_CLOSED)) {
                                        qList[i].EIS_Count_Closed_Immediate_CA__c += 1;
                                    } else if (status.equalsIgnoreCase(Label.EIS_Corrective_Action_Type_Immediate + STATUS_OPEN)) {
                                        qList[i].EIS_Count_Open_Immediate_CA__c += 1;
                                    } else if (status.equalsIgnoreCase(Label.EIS_Corrective_Action_Type_Long_Term + STATUS_CLOSED)) {
                                        qList[i].EIS_Count_Closed_Long_Term_CA__c += 1;
                                    } else {
                                        qList[i].EIS_Count_Open_Long_Term_CA__c += 1;
                                    }
                                }
                                qList[i].EIS_Corrected__c = ((qList[i].EIS_Count_Closed_Immediate_CA__c > 0 || qList[i].EIS_Count_Closed_Long_Term_CA__c > 0) && 
                                                             qList[i].EIS_Count_Open_Immediate_CA__c == 0 && qList[i].EIS_Count_Open_Long_Term_CA__c == 0);
                            }
                            if ((qList[i].EIS_Count_Closed_Immediate_CA__c + qList[i].EIS_Count_Open_Immediate_CA__c) > 0) {
                                qList[i].EIS_Criticality__c = CRITICAL;
                            } else if ((qList[i].EIS_Count_Closed_Long_Term_CA__c + qList[i].EIS_Count_Open_Long_Term_CA__c) > 0) {
                                qList[i].EIS_Criticality__c = NONCRITICAL;
                            }
                        }
                    }
                }
                update qList;    
                List<Audit_Inspections__c> aiList = getInspectionList(aiIds);
                for (Integer j = 0; j < fList.size(); j++) {    
                    for (Integer k = 0; k < aiList.size(); k++) {
                        if (aiList[k].Id == fList[j].Question__r.Audit_Inspections__c) {
                            if (statusMap.get(fList[j].Id) != null) {
                                for (String status : statusMap.get(fList[j].Id)) {
                                    if (!status.equalsIgnoreCase(Label.EIS_Corrective_Action_Status_Correct)) {
                                        aiList[k].EIS_Count_Not_Corrected_CA__c += 1;
                                        if (isCriticalList[j]) {
                                            aiList[k].EIS_Count_Critical_Not_Corrected_CA__c += 1;
                                        }
                                    } else {
                                        if (isCriticalList[j]) {
                                            aiList[k].EIS_Count_Critical_Corrected_CA__c += 1;
                                        }
                                        aiList[k].EIS_Count_Corrected_CA__c += 1;
                                    }
                                    if (status.equalsIgnoreCase(Label.EIS_Corrective_Action_Status_In_Progress)) {
                                        aiList[k].EIS_Count_In_Progress_CA__c += 1;
                                    }
                                    if (!status.equalsIgnoreCase(Label.EIS_Corrective_Action_Status_Not_Started)) {
                                        aiList[k].EIS_Count_Started_CA__c += 1;
                                    }
                                }                            
                                if (aiList[k].EIS_Count_Not_Corrected_CA__c == 0 && aiList[k].EIS_Count_Corrected_CA__c > 0) {
                                    aiList[k].PH_Corrective_Action_Status__c = Label.EIS_Audit_Inspection_Corrective_Status_Correct;
                                } else if (aiList[k].PH_Score__c > 89 && aiList[k].EIS_Count_Critical_Questions__c == 0) {
                                    aiList[k].PH_Corrective_Action_Status__c = Label.EIS_Audit_Inspection_Corrective_Status_Not_Required;
                                } else if (aiList[k].EIS_Count_Started_CA__c == 0) {
                                    aiList[k].PH_Corrective_Action_Status__c = Label.EIS_Audit_Inspection_Corrective_Status_Not_Started;
                                } else {
                                    aiList[k].PH_Corrective_Action_Status__c = Label.EIS_Audit_Inspection_Corrective_Status_In_Progress;
                                }
                            }
                        }
                    }
                }
                update aiList;
            }
        }
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Description
    * Update Corrective Action count fields on Questions__c and Audit_Inspections after delete
    * Only perform update on Inspection record type 
    *————————————————————————————————————————————————————
    * @param    oldList		List of Corrective Actions before they were deleted
    * @return   void
    *————————————————————————————————————————————————————
    **/
    public void updateInspectionCorrectiveActionCount_AfterDelete(List<Corrective_Action__c> oldList) {
        Map<Id,List<String>> statusMap = new Map<Id, List<String>>();			//Key: Finding Id, Value: List of CA status
        Map<Id,List<String>> auditStatusMap = new Map<Id, List<String>>();		//Key: Finding Id, Value: List of CA status
        populateStatusMaps(statusMap, auditStatusMap, oldList);
        
        if (!statusMap.isEmpty() || !auditStatusMap.isEmpty()) {
            List<Finding__c> fList = [SELECT Id, Question__c, Question__r.Audit_Inspections__c, Question__r.EIS_Criticality__c 
                                      FROM Finding__c WHERE Id IN :statusMap.keySet() OR Id IN :auditStatusMap.keySet()];
            if (!fList.isEmpty()) {
                List<Id> qIds = new List<Id>();
                List<Id> aiIds = new List<Id>();
                List<Boolean> isCriticalList = new List<Boolean>();
                for (Finding__c f : fList) {
                    qIds.add(f.Question__c);
                    aiIds.add(f.Question__r.Audit_Inspections__c);
                    isCriticalList.add(CRITICAL.equalsIgnoreCase(f.Question__r.EIS_Criticality__c));
                }
                List<Questions__c> qList = getQuestionList(qIds);
                for (Integer j = 0; j < fList.size(); j++) {
                    for (Integer i = 0; i < qList.size(); i++) {
                        if (qList[i].Id == fList[j].Question__c) {
                            if (statusMap.get(fList[j].Id) != null) {
                                for (String status : statusMap.get(fList[j].Id)) {
                                    if (!status.equalsIgnoreCase(Label.EIS_Corrective_Action_Status_Correct)) {
                                        qList[i].EIS_Count_Not_Corrected_CA__c -= 1;
                                    } else {
                                        qList[i].EIS_Count_Corrected_CA__c -= 1;
                                    }
                                }
                                qList[i].EIS_Corrected__c = qList[i].EIS_Count_Not_Corrected_CA__c == 0 && qList[i].EIS_Count_Corrected_CA__c > 0;
                            }
                            if (auditStatusMap.get(fList[j].Id) != null) {
                                for (String status : auditStatusMap.get(fList[j].Id)) {
                                    if (status.equalsIgnoreCase(Label.EIS_Corrective_Action_Type_Immediate + STATUS_CLOSED)) {
                                        qList[i].EIS_Count_Closed_Immediate_CA__c -= 1;
                                    } else if (status.equalsIgnoreCase(Label.EIS_Corrective_Action_Type_Immediate + STATUS_OPEN)) {
                                        qList[i].EIS_Count_Open_Immediate_CA__c -= 1;
                                    } else if (status.equalsIgnoreCase(Label.EIS_Corrective_Action_Type_Long_Term + STATUS_CLOSED)) {
                                        qList[i].EIS_Count_Closed_Long_Term_CA__c -= 1;
                                    } else {
                                        qList[i].EIS_Count_Open_Long_Term_CA__c -= 1;
                                    }
                                }
                                qList[i].EIS_Corrected__c = ((qList[i].EIS_Count_Closed_Immediate_CA__c > 0 || qList[i].EIS_Count_Closed_Long_Term_CA__c > 0) && 
                                                             qList[i].EIS_Count_Open_Immediate_CA__c == 0 && qList[i].EIS_Count_Open_Long_Term_CA__c == 0);
                            }
                            if ((qList[i].EIS_Count_Closed_Immediate_CA__c + qList[i].EIS_Count_Open_Immediate_CA__c) > 0) {
                                qList[i].EIS_Criticality__c = CRITICAL;
                            } else if ((qList[i].EIS_Count_Closed_Long_Term_CA__c + qList[i].EIS_Count_Open_Long_Term_CA__c) > 0) {
                                qList[i].EIS_Criticality__c = NONCRITICAL;
                            }
                        }
                    }
                    
                }
                update qList;
                List<Audit_Inspections__c> aiList = getInspectionList(aiIds);
                for (Integer j = 0; j < fList.size(); j++) {
                	for (Integer k = 0; k < aiList.size(); k++) {
                        if (aiList[k].Id == fList[j].Question__r.Audit_Inspections__c) {
                            if (statusMap.get(fList[j].Id) != null) {
                                for (String status : statusMap.get(fList[j].Id)) {
                                    if (!status.equalsIgnoreCase(Label.EIS_Corrective_Action_Status_Correct)) {
                                        aiList[k].EIS_Count_Not_Corrected_CA__c -= 1;
                                        if (isCriticalList[j]) {
                                            aiList[k].EIS_Count_Critical_Not_Corrected_CA__c -= 1;
                                        }
                                    } else {
                                        if (isCriticalList[j]) {
                                            aiList[k].EIS_Count_Critical_Corrected_CA__c -= 1;
                                        }
                                        aiList[k].EIS_Count_Corrected_CA__c -= 1;
                                    }
                                    if (status.equalsIgnoreCase(Label.EIS_Corrective_Action_Status_In_Progress)) {
                                        aiList[k].EIS_Count_In_Progress_CA__c -= 1;
                                    }
                                    if (!status.equalsIgnoreCase(Label.EIS_Corrective_Action_Status_Not_Started)) {
                                        aiList[k].EIS_Count_Started_CA__c -= 1;
                                    }
                                }
                                
                                if (aiList[k].EIS_Count_Not_Corrected_CA__c == 0 && aiList[k].EIS_Count_Corrected_CA__c > 0) {
                                    aiList[k].PH_Corrective_Action_Status__c = Label.EIS_Audit_Inspection_Corrective_Status_Correct;
                                } else if (aiList[k].PH_Score__c > 89 && aiList[k].EIS_Count_Critical_Questions__c == 0) {
                                    aiList[k].PH_Corrective_Action_Status__c = Label.EIS_Audit_Inspection_Corrective_Status_Not_Required;
                                } else if (aiList[k].EIS_Count_Started_CA__c == 0) {
                                    aiList[k].PH_Corrective_Action_Status__c = Label.EIS_Audit_Inspection_Corrective_Status_Not_Started;
                                } else {
                                    aiList[k].PH_Corrective_Action_Status__c = Label.EIS_Audit_Inspection_Corrective_Status_In_Progress;
                                }
                            }
                        }
                    }
                }
                update aiList;
            }
        }
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Description
    * Update Corrective Action count fields on Questions__c and Audit_Inspections after update
    * Only perform update on Inspection record type 
    *————————————————————————————————————————————————————
    * @param    newList		List of updated Corrective Actions
    * @param	oldList		List of Corrective Actions before they were updated
    * @return   void
    *————————————————————————————————————————————————————
    **/
    public void updateInspectionCorrectiveActionCount_AfterUpdate(List<Corrective_Action__c> oldList, List<Corrective_Action__c> newList) {
        Map<Id,List<String>> statusMapOld = new Map<Id, List<String>>();
        Map<Id,List<String>> statusMapNew = new Map<Id, List<String>>();
        Map<Id,List<String>> auditStatusMapOld = new Map<Id, List<String>>();
        Map<Id,List<String>> auditStatusMapNew = new Map<Id, List<String>>();
        populateStatusMaps(statusMapOld, auditStatusMapOld, oldList);
        populateStatusMaps(statusMapNew, auditStatusMapNew, newList);
        
        if (!statusMapOld.isEmpty() || !auditStatusMapOld.isEmpty()) {
            List<Finding__c> fList = [SELECT Id, Question__c, Question__r.Audit_Inspections__c, Question__r.EIS_Criticality__c 
                                      FROM Finding__c WHERE Id IN :statusMapOld.keySet() OR Id IN :auditStatusMapOld.keySet()];
            if (!fList.isEmpty()) {
                List<Id> qIds = new List<Id>();
                List<Id> aiIds = new List<Id>();
                List<Boolean> isCriticalList = new List<Boolean>();
                for (Finding__c f : fList) {
                    qIds.add(f.Question__c);
                    aiIds.add(f.Question__r.Audit_Inspections__c);
                    isCriticalList.add(CRITICAL.equalsIgnoreCase(f.Question__r.EIS_Criticality__c));
                }
                List<Questions__c> qList = getQuestionList(qIds);
                for (Integer j = 0; j < fList.size(); j++) {
                    for (Integer i = 0; i < qList.size(); i++) {
                        if (qList[i].Id == fList[j].Question__c) {
                            if (statusMapOld.get(fList[j].Id) != null) {
                                for (Integer sIndex = 0; sIndex < statusMapOld.get(fList[j].Id).size(); sIndex++) {
                                    String oldStatus = statusMapOld.get(fList[j].Id).get(sIndex);
                                    String newStatus = statusMapNew.get(fList[j].Id).get(sIndex);
                                    if (!oldStatus.equalsIgnoreCase(Label.EIS_Corrective_Action_Status_Correct)) {
                                        if (newStatus.equalsIgnoreCase(Label.EIS_Corrective_Action_Status_Correct)) {
                                            qList[i].EIS_Count_Not_Corrected_CA__c -= 1;
                                            qList[i].EIS_Count_Corrected_CA__c += 1;
                                        }
                                    } else {
                                        if (!newStatus.equalsIgnoreCase(Label.EIS_Corrective_Action_Status_Correct)) {
                                            qList[i].EIS_Count_Not_Corrected_CA__c += 1;
                                            qList[i].EIS_Count_Corrected_CA__c -= 1;
                                        }
                                    }
                                }
                                qList[i].EIS_Corrected__c = qList[i].EIS_Count_Not_Corrected_CA__c == 0 && qList[i].EIS_Count_Corrected_CA__c > 0;
                            }
                            if (auditStatusMapOld.get(fList[j].Id) != null) {
                                for (Integer sIndex = 0; sIndex < auditStatusMapOld.get(fList[j].Id).size(); sIndex++) {
                                    String oldStatus = auditStatusMapOld.get(fList[j].Id).get(sIndex);
                                    String newStatus = auditStatusMapNew.get(fList[j].Id).get(sIndex);
                                    if (oldStatus.equalsIgnoreCase(Label.EIS_Corrective_Action_Type_Immediate + STATUS_CLOSED)) {
                                        if (newStatus.equalsIgnoreCase(Label.EIS_Corrective_Action_Type_Immediate + STATUS_CLOSED)) {
                                            qList[i].EIS_Count_Closed_Immediate_CA__c += 1;
                                        } else if (newStatus.equalsIgnoreCase(Label.EIS_Corrective_Action_Type_Immediate + STATUS_OPEN)) {
                                            qList[i].EIS_Count_Open_Immediate_CA__c += 1;
                                        } else if (newStatus.equalsIgnoreCase(Label.EIS_Corrective_Action_Type_Long_Term + STATUS_CLOSED)) {
                                            qList[i].EIS_Count_Closed_Long_Term_CA__c += 1;
                                        } else {
                                            qList[i].EIS_Count_Open_Long_Term_CA__c += 1;
                                        }
                                        qList[i].EIS_Count_Closed_Immediate_CA__c -= 1;
                                    } else if (oldStatus.equalsIgnoreCase(Label.EIS_Corrective_Action_Type_Immediate + STATUS_OPEN)) {
                                        if (newStatus.equalsIgnoreCase(Label.EIS_Corrective_Action_Type_Immediate + STATUS_CLOSED)) {
                                            qList[i].EIS_Count_Closed_Immediate_CA__c += 1;
                                        } else if (newStatus.equalsIgnoreCase(Label.EIS_Corrective_Action_Type_Immediate + STATUS_OPEN)) {
                                            qList[i].EIS_Count_Open_Immediate_CA__c += 1;
                                        } else if (newStatus.equalsIgnoreCase(Label.EIS_Corrective_Action_Type_Long_Term + STATUS_CLOSED)) {
                                            qList[i].EIS_Count_Closed_Long_Term_CA__c += 1;
                                        } else {
                                            qList[i].EIS_Count_Open_Long_Term_CA__c += 1;
                                        }
                                        qList[i].EIS_Count_Open_Immediate_CA__c -= 1;
                                    } else if (oldStatus.equalsIgnoreCase(Label.EIS_Corrective_Action_Type_Long_Term + STATUS_CLOSED)) {
                                        if (newStatus.equalsIgnoreCase(Label.EIS_Corrective_Action_Type_Immediate + STATUS_CLOSED)) {
                                            qList[i].EIS_Count_Closed_Immediate_CA__c += 1;
                                        } else if (newStatus.equalsIgnoreCase(Label.EIS_Corrective_Action_Type_Immediate + STATUS_OPEN)) {
                                            qList[i].EIS_Count_Open_Immediate_CA__c += 1;
                                        } else if (newStatus.equalsIgnoreCase(Label.EIS_Corrective_Action_Type_Long_Term + STATUS_CLOSED)) {
                                            qList[i].EIS_Count_Closed_Long_Term_CA__c += 1;
                                        } else {
                                            qList[i].EIS_Count_Open_Long_Term_CA__c += 1;
                                        }
                                        qList[i].EIS_Count_Closed_Long_Term_CA__c -= 1;
                                    } else {
                                        if (newStatus.equalsIgnoreCase(Label.EIS_Corrective_Action_Type_Immediate + STATUS_CLOSED)) {
                                            qList[i].EIS_Count_Closed_Immediate_CA__c += 1;
                                        } else if (newStatus.equalsIgnoreCase(Label.EIS_Corrective_Action_Type_Immediate + STATUS_OPEN)) {
                                            qList[i].EIS_Count_Open_Immediate_CA__c += 1;
                                        } else if (newStatus.equalsIgnoreCase(Label.EIS_Corrective_Action_Type_Long_Term + STATUS_CLOSED)) {
                                            qList[i].EIS_Count_Closed_Long_Term_CA__c += 1;
                                        } else {
                                            qList[i].EIS_Count_Open_Long_Term_CA__c += 1;
                                        }
                                        qList[i].EIS_Count_Open_Long_Term_CA__c -= 1;
                                    }
                                }
                                qList[i].EIS_Corrected__c = ((qList[i].EIS_Count_Closed_Immediate_CA__c > 0 || qList[i].EIS_Count_Closed_Long_Term_CA__c > 0) && 
                                                             qList[i].EIS_Count_Open_Immediate_CA__c == 0 && qList[i].EIS_Count_Open_Long_Term_CA__c == 0);
                            }
                            if ((qList[i].EIS_Count_Closed_Immediate_CA__c + qList[i].EIS_Count_Open_Immediate_CA__c) > 0) {
                                qList[i].EIS_Criticality__c = CRITICAL;
                            } else if ((qList[i].EIS_Count_Closed_Long_Term_CA__c + qList[i].EIS_Count_Open_Long_Term_CA__c) > 0) {
                                qList[i].EIS_Criticality__c = NONCRITICAL;
                            }
                        }
                    }
                    
                }
                update qList;
                List<Audit_Inspections__c> aiList = getInspectionList(aiIds);
                for (Integer j = 0; j < fList.size(); j++) {
                	for (Integer k = 0; k < aiList.size(); k++) {
                        if (aiList[k].Id == fList[j].Question__r.Audit_Inspections__c) {
                            if (statusMapOld.get(fList[j].Id) != null) {
                                for (Integer sIndex = 0; sIndex < statusMapOld.get(fList[j].Id).size(); sIndex++) {
                                    String oldStatus = statusMapOld.get(fList[j].Id).get(sIndex);
                                    String newStatus = statusMapNew.get(fList[j].Id).get(sIndex);
                                    
                                    if (!oldStatus.equalsIgnoreCase(Label.EIS_Corrective_Action_Status_Correct)) {
                                        if (newStatus.equalsIgnoreCase(Label.EIS_Corrective_Action_Status_Correct)) {
                                            aiList[k].EIS_Count_Not_Corrected_CA__c -= 1;
                                            aiList[k].EIS_Count_Corrected_CA__c += 1;
                                            if (isCriticalList[j]) {
                                                aiList[k].EIS_Count_Critical_Not_Corrected_CA__c -= 1;
                                                aiList[k].EIS_Count_Critical_Corrected_CA__c += 1;
                                            }
                                        }
                                    } else {
                                        if (!newStatus.equalsIgnoreCase(Label.EIS_Corrective_Action_Status_Correct)) {
                                            aiList[k].EIS_Count_Not_Corrected_CA__c += 1;
                                            aiList[k].EIS_Count_Corrected_CA__c -= 1;
                                            if (isCriticalList[j]) {
                                                aiList[k].EIS_Count_Critical_Corrected_CA__c -= 1;
                                                aiList[k].EIS_Count_Critical_Not_Corrected_CA__c += 1;
                                            }
                                        }
                                    }
                                    
                                    if (!oldStatus.equalsIgnoreCase(Label.EIS_Corrective_Action_Status_In_Progress)) {
                                        if (newStatus.equalsIgnoreCase(Label.EIS_Corrective_Action_Status_In_Progress)) {
                                            aiList[k].EIS_Count_In_Progress_CA__c += 1;
                                        }
                                    } else {
                                        if (!newStatus.equalsIgnoreCase(Label.EIS_Corrective_Action_Status_In_Progress)) {
                                            aiList[k].EIS_Count_In_Progress_CA__c -= 1;
                                        }
                                    }
                                    
                                    if (!oldStatus.equalsIgnoreCase(Label.EIS_Corrective_Action_Status_Not_Started)) {
                                        if (newStatus.equalsIgnoreCase(Label.EIS_Corrective_Action_Status_Not_Started)) {
                                            aiList[k].EIS_Count_Started_CA__c -= 1;
                                        }    
                                    } else {
                                        if (!newStatus.equalsIgnoreCase(Label.EIS_Corrective_Action_Status_Not_Started)) {
                                            aiList[k].EIS_Count_Started_CA__c += 1;
                                        } 
                                    }
                                }
                                
                                if (aiList[k].EIS_Count_Not_Corrected_CA__c == 0 && aiList[k].EIS_Count_Corrected_CA__c > 0) {
                                    aiList[k].PH_Corrective_Action_Status__c = Label.EIS_Audit_Inspection_Corrective_Status_Correct;
                                } else if (aiList[k].PH_Score__c > 89 && aiList[k].EIS_Count_Critical_Questions__c == 0) {
                                    aiList[k].PH_Corrective_Action_Status__c = Label.EIS_Audit_Inspection_Corrective_Status_Not_Required;
                                } else if (aiList[k].EIS_Count_Started_CA__c == 0) {
                                    aiList[k].PH_Corrective_Action_Status__c = Label.EIS_Audit_Inspection_Corrective_Status_Not_Started;
                                } else {
                                    aiList[k].PH_Corrective_Action_Status__c = Label.EIS_Audit_Inspection_Corrective_Status_In_Progress;
                                }
                            }
                        }
                    }
                }
                update aiList;
            }
        }
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Description
    * Iterate through the List of corrective action and assign values to both statusMaps
    *————————————————————————————————————————————————————
    * @param    statusMap			Map of statuses from inpsection's corrective actions
    * @param	auditStatusMap		Map of statuses from audit's corrective actions
    * @param	caList				List of corrective action records
    * @return   void
    *————————————————————————————————————————————————————
    **/
    private void populateStatusMaps(Map<Id,List<String>> statusMap, Map<Id,List<String>> auditStatusMap, List<Corrective_Action__c> caList) {
        for (Corrective_Action__c ca : caList) {
            if (ca.RecordTypeId == EIS_StaticUtils.CORRECTIVEACTION_INSPECTION_RTID) {
                if (String.isNotBlank(ca.EIS_Corrective_Action_Type__c)) {
                    if (auditStatusMap.get(ca.EIS_Finding__c) == null) {
                        auditStatusMap.put(ca.EIS_Finding__c, new List<String>());
                    }
                    if (Label.EIS_Corrective_Action_Status_Approve.equals(ca.EIS_Status__c) ||
                        Label.EIS_Corrective_Action_Status_Correct.equals(ca.EIS_Status__c)) {
                        auditStatusMap.get(ca.EIS_Finding__c).add(ca.EIS_Corrective_Action_Type__c + STATUS_CLOSED);
                    } else {
                        auditStatusMap.get(ca.EIS_Finding__c).add(ca.EIS_Corrective_Action_Type__c + STATUS_OPEN);
                    }
                } 
                if (statusMap.get(ca.EIS_Finding__c) == null) {
                    statusMap.put(ca.EIS_Finding__c, new List<String>());
                }
                statusMap.get(ca.EIS_Finding__c).add(ca.EIS_Status__c);
            }
        }
        System.debug(statusMap);
        System.debug(auditStatusMap);
    }
    
    //Query for Questions__c fields to be updated
    private List<Questions__c> getQuestionList(List<Id> qIds) {
        return [SELECT Id, EIS_Count_Not_Corrected_CA__c, EIS_Count_Corrected_CA__c, EIS_Corrected__c, EIS_Criticality__c,
            	EIS_Count_Open_Immediate_CA__c, EIS_Count_Closed_Immediate_CA__c, EIS_Count_Open_Long_Term_CA__c, EIS_Count_Closed_Long_Term_CA__c
                FROM Questions__c WHERE Id IN :qIds];
    }
    //Queery for Audit_Inspections__c fields to be updated
    private List<Audit_Inspections__c> getInspectionList(List<Id> aiIds) {
        return [SELECT Id, EIS_Count_Not_Corrected_CA__c, EIS_Count_In_Progress_CA__c, EIS_Count_Started_CA__c, PH_Corrective_Action_Status__c,
                EIS_Count_Critical_Not_Corrected_CA__c, EIS_Count_Critical_Corrected_CA__c, EIS_Count_Corrected_CA__c, PH_Score__c, EIS_Count_Critical_Questions__c
                FROM Audit_Inspections__c WHERE Id In :aiIds];
    }
}
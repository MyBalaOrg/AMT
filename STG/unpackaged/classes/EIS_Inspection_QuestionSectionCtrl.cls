/**
*————————————————————————————————————————————————————
* @Name             EIS_Inspection_QuestionSectionCtrl
* @Author           Duy Tran
* @Created Date     06-09-2017
* @Used By          EIS_Inspection_QuestionSection.cmp
*————————————————————————————————————————————————————
* @Description
* Controller class to query data for Question Section lightning component
*————————————————————————————————————————————————————
* @Changes
**/
public class EIS_Inspection_QuestionSectionCtrl {
    /**
    *————————————————————————————————————————————————————
    * @Description
    * Count the number of critical/noncritical/corrected/uncorrected Corrective Actions under a Section
    *————————————————————————————————————————————————————
    * @param    questionIdsJSON 	JSON representation of list of Id
    * @return   List<Integer> 		List of number counting Corrective Actions
    *————————————————————————————————————————————————————
    **/
	@AuraEnabled
    public static List<Integer> countCorrectiveActions(String questionIdsJSON) {
        List<Integer> caCountList = new List<Integer>();
        try {
            List<Id> idList = (List<Id>)JSON.deserialize(questionIdsJSON, List<Id>.class);
            List<Finding__c> critFindings = [
                SELECT Id, (SELECT Id, EIS_Status__c FROM Corrective_Actions__r) 
                FROM Finding__c 
                WHERE Question__c IN :idList AND Question__r.EIS_Criticality__c = :Label.EIS_Questions_Criticality_Critical
            ];
            List<Finding__c> noncritFindings = [
                SELECT Id, (SELECT Id, EIS_Status__c FROM Corrective_Actions__r) 
                FROM Finding__c 
                WHERE Question__c IN :idList AND Question__r.EIS_Criticality__c = :Label.EIS_Questions_Criticality_Non_Critical
            ];
            
            Integer noncritCorrected = 0, noncritUncorrected = 0, critCorrected = 0, critUncorrected = 0;
            for (Finding__c f : critFindings) {
                for (Corrective_Action__c ca : f.Corrective_Actions__r) {
                    if (Label.EIS_Corrective_Action_Status_Correct.equals(ca.EIS_Status__c)) {
                        critCorrected++;
                    } else {
                        critUncorrected++;
                    }
                }
            }
            for (Finding__c f : noncritFindings) {
                for (Corrective_Action__c ca : f.Corrective_Actions__r) {
                    if (Label.EIS_Corrective_Action_Status_Correct.equals(ca.EIS_Status__c)) {
                        noncritCorrected++;
                    } else {
                        noncritUncorrected++;
                    }
                }
            }
            
            caCountList.add(critCorrected);
            caCountList.add(critUncorrected);
            caCountList.add(noncritCorrected);
            caCountList.add(noncritUncorrected);
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
        return caCountList;
    }
}
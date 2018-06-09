public with sharing class EIS_Inspection_MainHeaderCtrl {
    
    /**
*———————————————————————————————————————————————————— 
* @Description
* Query for ContentVersion record using its Id
*————————————————————————————————————————————————————
* @param    recordId                auditInspection Id
* @return   ContentVersion  return  ContentSize
*————————————————————————————————————————————————————
**/
    @AuraEnabled
    public static Double getContentSize(Id auditInspection) {
      
        System.debug('inspection'+ auditInspection );
        List<ContentDocumentLink> conDocumentLink = new  List<ContentDocumentLink>([SELECT id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink where LinkedEntityId =: auditInspection]);
        Set<Id> contentDocumentId  = new Set<Id>();
            for(ContentDocumentLink cdl : conDocumentLink ){
                contentDocumentId.add(cdl.ContentDocumentId);
            }

        AggregateResult[] groupedResults = [SELECT SUM(contentsize) con FROM ContentVersion where ContentDocumentId IN: contentDocumentId ];
        Double sumSize = (Double)groupedResults[0].get('con');
        system.debug('size'+sumSize);
        return sumSize;
    }
    
}
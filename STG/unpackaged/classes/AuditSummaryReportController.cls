public class AuditSummaryReportController {
    
    public String auditID;
    public List<findingWrapperClass> findingWrapperList;
    
    @TestVisible private Boolean eventIdSet = false;
    
    //Inner Class
    public class findingWrapperClass {
        public String caseId{get;set;}
        public String category{get;set;}
        public String compliantCount{get;set;}
        public String nonCompliantCount{get;set;}
        
        public findingWrapperClass() {
            caseID = '';
            category = '';
            compliantCount = '';
            nonCompliantCount = '';
        }
    }
    
    public String getAuditID() {
        system.debug('getAAudit Id' +auditId); 
        return auditId;
    }
    
    public void setAuditID(String Id) {
        system.debug('In setAuditID' +Id);
        auditID = Id;
        setEventIdSet(auditID);
        
    }
    
    
    @TestVisible private AggregateResult[] getCompliantFindingsByCat() {
        AggregateResult[] groupedResults= [SELECT Category__c, COUNT(id) FROM Finding__c WHERE Audit__c =: auditID AND isCompliant__c = 'Yes' GROUP BY Category__c ];
      
        return groupedResults;
    }
    
    @TestVisible private AggregateResult[] getNonCompliantFindingsByCat() {
          AggregateResult[] groupedResults= [SELECT Category__c, COUNT(id) FROM Finding__c WHERE Audit__c =: auditID AND isCompliant__c = 'No' GROUP BY Category__c ];
 
        return groupedResults;
    }
    
    public void setEventIdSet(String theId) {
        List<findingWrapperClass> tempWrapperList = new List<findingWrapperClass>();
        try {
        if(!eventIdSet) {
            AggregateResult[] compliantGroupedResult = getCompliantFindingsByCat();
            AggregateResult[] nonCompliantGroupedResult = getNonCompliantFindingsByCat();
            
            Map<String,String> compliantGroupMap = new Map<String,String>();
            Map<String,String> nonCompliantGroupMap = new Map<String,String>();
            
            //populate compliant map
            for(aggregateresult ar : compliantGroupedResult) {
                String category = (String) ar.get('Category__c');
                Integer intCount =(Integer) ar.get('expr0');
                String count = String.valueOf(intCount);
                compliantGroupMap.put(category, count);
            }
            
            //populate non compilant map
            for(aggregateresult ar : nonCompliantGroupedResult) {
                String category = (String) ar.get('Category__c');
                Integer intCount = (Integer)ar.get('expr0');
                String count = String.valueOf(intCount);
                nonCompliantGroupMap.put(category, count);
            }
            
            //get All Categories picklist values
            List<String> pickEntries = getCategoryPicklistValues();
            
            //Iterate through all categories
            for(String s : pickEntries) {
                String compliantCountValue = compliantGroupMap.get(s);
                String nonCompliantValue = nonCompliantGroupMap.get(s);
                findingWrapperClass fw = new findingWrapperClass();
                fw.category = s;
                //Case 1 - No Compilant and Non Compilant Findings are not present
                if(compliantCountValue == null && nonCompliantValue == null) {
                    fw.compliantCount = 'NA';
                    fw.nonCompliantCount = 'NA';
                    //Case 2 - Compilant - No NonCompliant - Yes 
                } else if(compliantCountValue == null && nonCompliantValue != null) {
                    fw.compliantCount = '0';
                    fw.nonCompliantCount = nonCompliantValue;
                    //Case 3 - Compliant - Yes Non Compliant - No
                } else if(compliantCountValue != null && nonCompliantValue == null) {
                    fw.compliantCount = compliantCountValue;
                    fw.nonCompliantCount = '0';
                    //Case 4 - Both exists
                } else {
                    fw.compliantCount = compliantCountValue;
                    fw.nonCompliantCount = nonCompliantValue;
                }

                tempWrapperList.add(fw);
            }
            //Set the Wrapper List
            setFindingWrapperList(tempWrapperList);
        }
        
        eventIdSet = true;
        } catch(Exception e) {
            system.debug('ERROR-'+e.getMessage());
        }
    }
    
    @TestVisible private List<String> getCategoryPicklistValues() {
        List<String> pickEntries = new List<String>();
        try {
        Schema.DescribeFieldResult fieldResult = Station_Audit_Setting__mdt.Category__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for(Schema.PicklistEntry p : ple) {
            pickEntries.add(p.getValue());
        }
        } catch(Exception e) {
            system.debug('ERROR - '+e.getMessage());
        }
        return pickEntries;
    }
    
    public List<findingwrapperclass> getFindingWrapperList() {
        return findingWrapperList;
    }
    
    public void setFindingWrapperList(List<findingwrapperclass> tempList) {
        findingWrapperList = tempList;
    }
    
}
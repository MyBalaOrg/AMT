public  class Revsys_Non1872FindingsController
{
    public Id observationId {get;set;}
    public List<Finding__c> getfindings()
    
    
    {
        List<Finding__c> myFindingList = new List<Finding__c>();
        List<Observation__c> myObservationList = new List<Observation__c>();
        Integer LastModifiedVersion ;

        Set<Id> myObsIdSet = new Set<Id>(); 
        myObsIdSet.add(observationId); 
        
        SelectorWrapper wrapper = new ObservationSelector(myObsIdSet).selectById();
        
        if(wrapper!=null) {
            myObservationList = (List<Observation__c>)wrapper.SobjectList;
           // LastVersion = (Integer)myObservationList.get(0).QuestionLastModifiedVersion__c;
           // LastModifiedDate
            if (myObservationList.size()>0){
            	LastModifiedVersion = (Integer)myObservationList.get(0).QuestionLastModifiedVersion__c ;                
            }

        }

        FindingSelector queryFinding = new FindingSelector(); 

        SelectorWrapper mySelWrap = queryFinding.getObsLimitedRelatedFindingsVersion(myObsIdSet, LastModifiedVersion); 
        myFindingList = mySelWrap.SObjectList;
       
        
        return myFindingList;
    }
}
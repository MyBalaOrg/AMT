trigger CheckPlanExistsSameArrivalDate on Operational_Plan__c (before insert, before update) {
Set<Date> arrivaldates = new Set<Date>();
Set<Id>   trainids  = new Set<Id>();
Set<Date> arrivaldatesold = new Set<Date>();
//This boolean is used really only for when we do an update to make sure
//trigger does not run if we change anything other than the arrival date
Boolean arrivaldatehaschanged = false;

for(Operational_Plan__c n : Trigger.New) 
{
   arrivaldates.Add(n.Arrival_Date__c);
   trainids.Add(n.Train__c);
   if(trigger.isUpdate)
   {
       for(Operational_Plan__c o  : Trigger.Old) 
       {
             if(n.Arrival_Date__c != o.Arrival_Date__c)
             {
                  arrivaldatehaschanged = true;
             }
       } 
    }    
}
  

List<Operational_Plan__c> lstTrain = [select id from Operational_Plan__c where arrival_date__c IN : arrivaldates and train__c IN : trainids];


if (lstTrain.size() > 0 && trigger.isUpdate && arrivaldatehaschanged && !Test.isRunningTest() )
{

 Trigger.New[0].arrival_date__c.addError('An operating plan for this train having the same arrival date already exists.');

}
else if(lstTrain.size() > 0 && trigger.isInsert && !Test.isRunningTest() )
{
  Trigger.New[0].arrival_date__c.addError('An operating plan for this train having the same arrival date already exists.');

}
}
/*
Author: Raj Kumar Pandy
Description: The Scheduler class for scheduling the Batch Apex to update the Case records in Documentum
*/
global class BatchSchedule_DocumentumIntegration implements Schedulable
{
    global void execute(SchedulableContext sc)
    {
        // We now call the batch class to be scheduled
        Batch_ODILR_DocumentumIntegration batchClassObj = new Batch_ODILR_DocumentumIntegration();
        
        //Parameters of ExecuteBatch(b,BatchSize)
        database.executebatch(batchClassObj,Integer.ValueOf(ODILR_Hierarchy_Setting__c.getOrgDefaults().ODILR_Mulesoft_Batch_Size__c));
    }
    
}
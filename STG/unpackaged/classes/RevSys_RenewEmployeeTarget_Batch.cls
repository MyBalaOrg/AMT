/**
*___________________________________________________
*@Name:     RevSys_RenewEmployeeTarget_Batch
*@Author:   Namit Pal   
*@Created:  Date: 02/01/2018    
*@Used_By:  SPARTN
*___________________________________________________
*@Description: Batch class to renew the Employee Targets
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change
* 01-12-2018 Removed the override finish method
*            Updated the execute schedulable to set failure subject and failure email in the runJob method
*/

public class RevSys_RenewEmployeeTarget_Batch extends BatchSchedule_Handler{

    /**
    *————————————————————————————————————————————————————
    * @Name: processBatch
    * @Description
    * This method generates the query required for the batch job dynamically and returns the same.
    * 
    *————————————————————————————————————————————————————
    * @params   -
    * @returns  The dynamically generated Query
    *————————————————————————————————————————————————————
    **/ 
    public String processBatch(){
    String query = '';
    Date limitDate = System.today().addDays(7);

    
    QueryUtilityWrapper myQuWrap = QueryUtility.beginDynamicQuery(RevSys_StaticUtility.OBJAPI_EMPLOYEE_SPECIFIC_REQUIREMENT); 

    if(myQuWrap.ErrorMessage == null) { 
        query = myQuWrap.QueryString; 
        query += System.Label.WHERE +' EndDate__c <= '+AMTRAK_DateUtility.processDate(limitDate);
        query += ' '+System.Label.AND +' EndDate__c >='+AMTRAK_DateUtility.processDate(System.today());
        query += ' '+System.Label.AND +' Status__c =\''+RevSys_StaticUtility.ACTIVE+'\'';
        query += ' '+System.Label.AND +' FollowOnTargetCreated__c = false';
        query += ' '+System.Label.AND +' RecordType.Id =\''+RevSys_StaticUtility.EMP_SPEC_REQ_SPARTNTARGET_RECTYPE_ID+'\'';

    }
        System.debug('$$ query '+query);
        return query;
    }
         /**
        *————————————————————————————————————————————————————
        * @Name: execute
        * @Description
        * Executes the following functionalities :
        * 1. Send Esr.Frequency to Amtrak_DateUtility.determineNextStartDate(). 
        * 2. Send Esr.Frequency to Amtrak_DateUtility.determineNextEndDate(). 
        * 3. Get the Reporting Period from Amtrak_DateUtility.determineNextPeriod().  
        * 4. Clone the ESR record and add the new Start and End Dates and the reporting period.
        * 5. Set the current record FollowOnTargetCreated__c to TRUE.
        * 
        *————————————————————————————————————————————————————
        * @params   - BatchableContext, List of sObject-EmployeeSpecificRequirement__c
        * @returns  void
        *————————————————————————————————————————————————————
        **/ 
        public override void execute(Database.BatchableContext BC, List<sObject> scope) {
        List<EmployeeSpecificRequirement__c> recordsToBeUpserted = new List<EmployeeSpecificRequirement__c>();  
        if(scope!=null) {
            Date currentDate = System.today(); 
            for(EmployeeSpecificRequirement__c esrRecord : (List<EmployeeSpecificRequirement__c>)scope){
                Date newStartDate = AMTRAK_DateUtility.determineNextStartDate(esrRecord.TargetFrequency__c, currentDate);
                Date newEndDate = AMTRAK_DateUtility.determineNextEndDate(esrRecord.TargetFrequency__c, currentDate);
                String myPeriod = AMTRAK_DateUtility.determineNextPeriod(esrRecord.TargetFrequency__c, currentDate);
                esrRecord.FollowOnTargetCreated__c = true;
                EmployeeSpecificRequirement__c newEsrRecord = esrRecord.clone();
                newEsrRecord.RecordTypeId = RevSys_StaticUtility.EMP_SPEC_REQ_SPARTNTARGET_RECTYPE_ID;
                newEsrRecord.EmployeeTarget__c = EsrRecord.Employee__c;
                newEsrRecord.FollowOnTargetCreated__c = false;
                newEsrRecord.TotalAchieved__c = 0;
                newEsrRecord.StartDate__c = newStartDate;
                newEsrRecord.EndDate__c = newEndDate;
                newEsrRecord.PeriodName__c = myPeriod;
                recordsToBeUpserted.add(newEsrRecord);
                recordsToBeUpserted.add(esrRecord);
            }
        }
            upsert recordsToBeUpserted;
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Name: execute
    * @Description
    * Executes the batch class with the help of the BatchSchedule_Handler class method - runJob.
    *
    *————————————————————————————————————————————————————
    * @params   - BatchableContext
    * @returns  - void
    *————————————————————————————————————————————————————
    **/ 
   
    public override void execute(SchedulableContext sc) {
        Type batchClass = Type.forName('RevSys_RenewEmployeeTarget_Batch');
        String failureSubj = System.label.RevSys_Batch_Failure_Email_Subject;
        String failureEmail = System.label.RevSys_Batch_Failure_Email;
        BatchSchedule_Handler.runJob(batchClass,processBatch(), failureSubj, failureEmail);
    }


}
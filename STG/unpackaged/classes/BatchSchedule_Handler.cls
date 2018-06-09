/**
*___________________________________________________
*@Name: BatchSchedule_Handler
*@Author: Boom Bertetti - Deloitte Consulting
*@Created: Date: 12/6/2017
*@Used_By: All Enterprise
*___________________________________________________
*@Description: Super class for all batch/schedule classes. 
* When a new batch class is created it should extend this super class.
* In the implementation class, the following virtual methods can be overridden as per need.
* - execute(Database.BatchableContext BC, List<sObject> scope);
* - finish(Database.BatchableContext BC);
* - execute(SchedulableContext sc);
*___________________________________________________
* Usage:
* Batch class extension:
*
* public class Whatever_Batch extends BatchSchedule_Handler {
*	 // *** Mandatory
*    public override void execute(Database.BatchableContext context, List<SObject> scope) {
*       List<SomeObject__c> myList = new List<SomeObject__c>();
*       myList.addAll((List<SomeObject__c>)(scope));
*       // Do whatever we need to do (use the object's helper class to do the process)   
*       // Replace "SomeObject__c" with the object you want the batch to run
*
*    }
*	 // *** Mandatory
*    public override void execute(SchedulableContext sc) {
*      
*		Type batchClass = Type.forName('Whatever_Batch');
*       // Replace "Whatever_Batch" with the name of your extension class
* 		String queryString = 'Select Id from SomeObject__c where SomeField__c = \'value\' ';
*       String emailSubject = 'This subject for finish email';
*       String emailRecipients = 'someone@email.com';
*		BatchSchedule_Handler.runJob(batchClass, queryStrig, emailSubject, emailRecipients);
*       // Replace the queryStrig, emailSubject and emailRecipients with the values of your own
*
*    }
*	 // *** This is optional
*    public override void finish(Database.BatchableContext context) {
*       
*       // And finish up
*       // You can override the finish method below if you want to process more than just sending batch error email.
*    }
* }
*
* Execute the batch:
* - In the execute anonymous block
*		Type batchClass = Type.forName('Whatever_Batch');
*       // Replace "Whatever_Batch" with the name of your extension class
* 		String queryString = 'Select Id from SomeObject__c where SomeField__c = \'value\' ';
*       String emailSubject = 'This subject for finish email';
*       String emailRecipients = 'someone@email.com';
*		BatchSchedule_Handler.runJob(batchClass, queryStrig, emailSubject, emailRecipients);
*       // Replace the queryStrig, emailSubject and emailRecipients with the values of your own
*
* Schedule the batch:
* - In the execute anonymous block
*       Whatever_Batch myJob = new Whatever_Batch(); // Replace with you batch class name
*       String sch = '0 0 22 * * ? 2017'; // Replace with CRON of the schedule you want to set
*       String jobID = system.schedule('Job Name', sch, myJob); 
*_____________________________________________________
*
*@Changes: 
* 01-11-2018. (by Boom Bertetti) Updated Finish to use virtual with default action to send batch error email
*             Updated runJob method to accept parameters for emailSubject and emailRecipients
* 06-07-2018  [walley] added ability to run batch with a different batch size. 
**/

global abstract class BatchSchedule_Handler implements Database.Batchable<sObject> , Database.Stateful, Schedulable{
	
	String query;
	String className;
	String emailSubject;
	String emailRecipients;
    
    Public String batchErrorMessage; 

	global BatchSchedule_Handler() {
		
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
        system.debug(query);
		return Database.getQueryLocator(query);
	}

   	global abstract void execute(Database.BatchableContext BC, List<sObject> scope);
	
	global virtual void finish(Database.BatchableContext BC) {
		if(bc!=null) {
			SelectorWrapper wrapper = AsyncApexJobSelector.getAsyncApexJobs(bc.getJobId());
			if(wrapper!=null) {
				List<AsyncApexJob> apexJobList = (List<AsyncApexJob>) wrapper.sObjectList;
				AsyncApexJob apexJob;
				if(apexJobList!=null && apexJobList.size()!=0) {
					apexJob = apexJobList.get(0);
					if(batchErrorMessage != null || apexJob.NumberOfErrors>0) {
						List<Messaging.SingleEmailMessage> errorEmails = generateErrorEmail(apexJob);
						Messaging.sendEmail(errorEmails);
					}
				}
			}	
		}
	}

	global abstract void execute(SchedulableContext sc);

    public static void runJob(Type batchClass, String withQuery, String emailSubject, String emailRecipients) {
	    BatchSchedule_Handler theJob = (BatchSchedule_Handler)batchClass.newInstance();
	    String batchClassName = batchClass.getName();
	    theJob.setAttributes(withQuery, batchClassName, emailSubject, emailRecipients);
	    Database.executeBatch(theJob);
	}
    
    public static void runJobwithBatchSize(Type batchClass, String withQuery, String emailSubject, String emailRecipients, Integer scopeSize) {
	    BatchSchedule_Handler theJob = (BatchSchedule_Handler)batchClass.newInstance();
	    String batchClassName = batchClass.getName();
	    theJob.setAttributes(withQuery, batchClassName, emailSubject, emailRecipients);
	    Database.executeBatch(theJob, scopeSize);
	}

    public void setAttributes(String query, String className, String emailSubject, String emailRecipients) {
        this.query = query;
        this.className = className;
        this.emailSubject = emailSubject;
        this.emailRecipients = emailRecipients;
    }

    public List<Messaging.SingleEmailMessage> generateErrorEmail(AsyncApexJob apexJob) {
		List<Messaging.SingleEmailMessage> emailsList = new List<Messaging.SingleEmailMessage>();

		String emailMessage = 'The batch job '
		+ '<b> '
		+ className
		+ '</b> '
		+ 'has finished.  It executed ' 
		+ apexJob.totalJobItems 
		+ ' batches.  Of which, ' + apexJob.jobitemsprocessed 
		+ ' processed and ' 
		+ apexJob.numberOfErrors + ' batches threw unhandled exceptions. '
        + '</br> '
        + 'Additional message: '
        + batchErrorMessage;  


		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		List<String> toAddresses = new List<String>(); 
		toAddresses.add(emailRecipients); 
		mail.setToAddresses(toAddresses);
		mail.setReplyTo(UserInfo.getUserEmail());
		mail.setSenderDisplayName('Batch Job Summary');
		mail.setSubject(emailSubject);
		mail.setPlainTextBody(emailMessage);
		mail.setHtmlBody(emailMessage);
		emailsList.add(mail);


    	return emailsList;
    }
		
}
/**
*___________________________________________________
*@Name: 	RevSys_EmployeeCertification_Batch
*@Author: 	Hemanth Kesapragada
*@Created: 	Date: 12/04/2017
*@Used_By: 	SPARTN
*___________________________________________________
*@Description: Batch class to send notifications based on the configuration
* 
*___________________________________________________
*@Changes: 
* 01-11-2018 Removed the override finish method
*            Updated the execute schedulable to set failure subject and failure email in the runJob method
* 06-07-2018  [walley] added ability to run batch with a different batch size. 
**/
public class RevSys_EmployeeCertification_Batch extends BatchSchedule_Handler {

	/**
	*————————————————————————————————————————————————————
	* @Name: processBatch
	* @Description
	* Builds the dynamic query to process the batch
	*————————————————————————————————————————————————————
	* @param    
	* @return   String            dynamic Query
	*————————————————————————————————————————————————————
	**/ 
	public String processBatch() {
	String query='';
	SelectorWrapper wrapper =  BatchProcessParameterSelector.getBatchProcessParamRecords();
		List<Date> paramDateList = new List<Date>();
		Date myLatestDate;
		System.debug('=====> wrapper: ' + wrapper);
		if(wrapper!=null) {
			for(BatchProcessParameter__mdt bppRec : (List<BatchProcessParameter__mdt>) wrapper.sObjectList) {
				Integer lengthOfPeriod = Integer.valueOf(bppRec.LengthOfPeriod__c);
				Date myParameterDate = AMTRAK_DateUtility.determineDate(bppRec.Frequency__c,lengthOfPeriod);
				paramDateList.add(myParameterDate);
			}
		}

		if(!paramDateList.isEmpty()) {
			paramDateList.sort();
			myLatestDate = paramDateList.get(paramDateList.size()-1);
			
			Id empCertRecordTypeId = EmployeeCertificationStaticUtility.EMPCERT_SPARTNCERT_RECTYPE_ID; 

			QueryUtilityWrapper myQuWrap = QueryUtility.beginDynamicQuery(label.OBJAPI_EMPLOYEE_CERTIFICATION);   
			if(myQuWrap.ErrorMessage == null) { 
				query = myQuWrap.QueryString; 
				query += ' WHERE RecordTypeId = \'' + empCertRecordTypeId + '\''; 
				query += ' AND ExpirationDate__c <='+AMTRAK_DateUtility.processDate(myLatestDate);
				query += ' AND Status__c =\''+RevSys_StaticUtility.CURRENT+'\'';
				query += ' AND Archived__c = '+ FALSE;
			}

		}
		return query;
	}
	

	/**
	*————————————————————————————————————————————————————
	* @Name: execute
	* @Description
	* Implemented to process the results of the query
	*————————————————————————————————————————————————————
	* @param    BatchableContext
	*			scope			List of records returned by the query
	* @return  	void
	*————————————————————————————————————————————————————
	**/ 
   	public override void execute(Database.BatchableContext BC, List<sObject> scope) {
   		if(scope!=null) {
   			RevSys_EmailHelper.employeeCert((List<EmployeeCertification__c>)scope);
   		}
	}
	
	/**
	*————————————————————————————————————————————————————
	* @Name: execute
	* @Description
	* Related to the schedulable interface. Schedules the batch job. Check method definition in BatchHandler
	*————————————————————————————————————————————————————
	* @param    SchedulableContext
	* @return   void
	*————————————————————————————————————————————————————
	**/ 	
	public override void execute(SchedulableContext sc) {        
        
        Type batchClass = Type.forName('RevSys_EmployeeCertification_Batch');
		String failureSubj = System.label.RevSys_Batch_Failure_Email_Subject;
		String failureEmail = System.label.RevSys_Batch_Failure_Email;   
        Integer scopeSize = Integer.valueOf(label.RevSys_EmployeeCertification_Batch_Size);

		BatchSchedule_Handler.runJobwithBatchSize(batchClass,processBatch(), failureSubj, failureEmail, scopeSize);
	}
		
}
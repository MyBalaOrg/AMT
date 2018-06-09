/**
*___________________________________________________
*@Name: 	RevSys_RenewEmployeeTarget_Batch_Test
*@Author: 	Namit Pal
*@Created: 	Date: 01/03/2018
*@Used_By: 	SPARTN
*___________________________________________________
*@Description: Test for RevSys_RenewEmployeeTarget_Batch_Test
* 
*/

@isTest
private class RevSys_RenewEmployeeTarget_Batch_Test {

    @testSetup
    static void setup(){
        Contact testCon = new Contact();
        testCon.LastName = 'TestName';
        insert testCon;
        system.debug('Contact is :::::'+testCon.id);
        List<EmployeeSpecificRequirement__c> empSReqList = new List<EmployeeSpecificRequirement__c>();
        for(integer i = 0; i<10; i++){
            EmployeeSpecificRequirement__c empSReq = new EmployeeSpecificRequirement__c();
            empSReq.Employee__c = testCon.id;
            empSReq.EndDate__c = System.today().addDays(4);
            empSReq.FollowOnTargetCreated__c = false;
            empSReq.RecordTypeId = RevSys_StaticUtility.EMP_SPEC_REQ_SPARTNTARGET_RECTYPE_ID;
            empSReq.Status__c = RevSys_StaticUtility.ACTIVE;
            system.debug('empSReq::::'+empSReq);
            empSReqList.add(empSReq);
        }
    insert empSReqList;
        system.debug('empSReqList::::'+empSReqList);
    }
    
    
    
    static testmethod void testRenewTargets(){
        test.startTest();
        RevSys_RenewEmployeeTarget_Batch renewTarget = new RevSys_RenewEmployeeTarget_Batch();
        //Id batchId = Database.executeBatch(renewTarget);
        String sch = '00 03 * * * ? *';
        String jobID = system.schedule('Test'+Math.random(), sch, renewTarget);
        test.stopTest();
        
    }
   
	/*private static String processDate() {
		DateTime dt = System.now();
		String seconds = String.valueOf(dt.addSeconds(10).second());
		String minutes = String.valueOf(dt.minute());
		String hours = String.valueOf(dt.hour());
		String day = String.valueOf(dt.day());
		String month = String.valueOf(dt.month());
		String year = String.valueOf(dt.year());
		String cronExpression = seconds+' '+minutes+' '+hours+' '+day+' '+month+' ? '+year;
		System.debug(cronExpression);
		return cronExpression;
	}*/
    
}
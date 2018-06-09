/**
*___________________________________________________
*@Name: RevSys_ViolationHelper_Test
*@Author: Mona Bhutada
*@Created: Date: 01/31/2018
*@Used_By: SPARTN
*___________________________________________________
*@Description: Test class for RevSys_ViolationHelper class
* 
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
* 1-22-2018 [Abhishek] Added populateEmployeeSupervisor to update Employee's supervisor on Employee Certification
**/
@isTest
public class RevSys_ViolationHelper_Test {

    //Loads the data required for Test execution
    @TestSetup
    public static void loadtestData() {
         Contact employee = new Contact
        (
            LastName            ='Employee', 
            FirstName           ='Amy', 
            Personnel_Number__c = 1234567,
            Email               = 'test.test@amtrak.com'
        );
        insert employee;

        Violation__c violation = new Violation__c();
        violation.Employee__c = employee.Id;
        violation.RecordTypeId = RevSys_StaticUtility.VIOLATION_SPARTN_EMP_RECTYPE_ID;
        insert violation;
        
    }

    //Testing Violation Trigger -  Creating Violation records creates OC records and ESR records.
    public static testmethod void createOccupationCertificationRecordTest(){
        Test.startTest();
            
            // Get all Violation records
            QueryUtilityWrapper myQuWrap = QueryUtility.beginDynamicQuery(RevSys_StaticUtility.OBJAPI_VIOLATION);   
            String myQuery = myQuWrap.QueryString; 
            List<Violation__c> myVioList = Database.query(myQuery); 

            Violation__c vRecord = myVioList[0]; 


            Contact employee = [Select Id,Name from Contact Limit 1];
            List<OccupationCertification__c> oc = [Select Id,Name from OccupationCertification__c where RecordTypeId=:RevSys_StaticUtility.OCC_CERT_SPARTN_VIOLATION_RECTYPE_ID];

            //One target gets created for the Violation
            System.assertEquals(1,oc.size());

            //violation ty
            System.assertEquals(vRecord.Name+' '+employee.Name+' ' + Label.SPARTN_Violation_Target_Label,oc.get(0).Name);

            vRecord.ReturnedToServiceDate__c = system.today(); 
            //vRecord.Status__c = 'Active'; 

            UPDATE vRecord; 

            vRecord.ReturnedToServiceDate__c = system.today().addDays(33); 


            List<Violation__c> myVioList2 = new List<Violation__c>(); 
            myVioList2.add(vRecord); 

            String errMsg = RevSys_ViolationHelper.inactivateEsr(myVioList2); 




            List<EmployeeSpecificRequirement__c> esr = [Select Id,Employee__c from EmployeeSpecificRequirement__c where Target__c in :oc];

            //One ESR gets created for the target
            //System.assertEquals(1,esr.size());

            //ESR is associated to the employee
            //System.assertEquals(employee.Id,esr.get(0).Employee__c);

        Test.stopTest();

    }
}
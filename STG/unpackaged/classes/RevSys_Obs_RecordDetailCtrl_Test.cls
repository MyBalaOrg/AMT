/**
*___________________________________________________
*@Name: RevSys_Obs_RecordDetailCtrl_Test
*@Author: Duy Tran
*@Created: Date: 11/09/2017
*@Used_By: Test Coverage stuff
*___________________________________________________
*@Description: 
* Test Coverage for RevSys_Obs_RecordDetailCtrl
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/
@isTest
public class RevSys_Obs_RecordDetailCtrl_Test {
    
    @TestSetup
    public static void loadTestData() {
        Observation__c obs = new Observation__c();
        obs.RecordTypeId = RevSys_StaticUtility.OBSERVATION_TEST1872_RECTYPE_ID;
        obs.Status__c = 'Submitted';
        obs.Date__c = Date.today();
        obs.Department__c = 'Mechanical';
        //obs.Employee__c = employee.Id;
        obs.FormType__c = 'Form-1872';
        obs.RegionProperty__c = 'Central';
        obs.OperatedFromText__c = 'Test Operated From';
        obs.OperatedToText__c = 'Test Operated To';
        obs.NearestStationInterlockingDescription__c = 'Test Nearest Station';
        obs.Result__c = 'C = Compliance';
        insert obs;

        REVSYS_Custom_Settings__c revSys = new REVSYS_Custom_Settings__c();
        revSys.Name = 'Observation Record Type Test List';
        revSys.CsvString__c = Label.RevSys_Observation_RT_Label_Test_1872 + ',' + Label.RevSys_Observation_RT_Label_Test_1875;
        insert revSys;
    }

    public static testMethod void testInitializeTestSelectionComponent() {
        Map<String, String> response = RevSys_Obs_RecordDetailCtrl.initializeTestSelectionComponent(new Map<String, String>());

    }
/*    
    public static testMethod void  testRevSys_Obs_RecordDetailCtrl() {
        // Query the Observation Id
        Id ObsId = [Select Id from Observation__c where Status__c = 'Submitted' limit 1].Id;
        
        // Invoke the Wrapper 
        RevSys_Obs_RecordDetailCtrl.ObsRecordType wrapper = new RevSys_Obs_RecordDetailCtrl.ObsRecordType('Test-1872');
        system.assertEquals(False,String.isBlank(wrapper.label));
        system.assertEquals(False,String.isBlank(wrapper.recordTypeId ));
        system.assertEquals(False,wrapper.selected);
        
        // Invoke getObservation method
        Observation__c getObs; 
        system.assertEquals(True,getObs==null);
        getObs = RevSys_Obs_RecordDetailCtrl.getObservation(ObsId);
        system.assertEquals(False,getObs==null);
        
        // Invoke updateObservationRecord method
        String UpdateObRec = RevSys_Obs_RecordDetailCtrl.updateObservationRecord(getObs);
        system.assertEquals(True,String.isBlank(UpdateObRec));
        
        Map<String,String> params = new Map<String,String>();
        params.put('obsId',ObsId);
        RevSys_Obs_RecordDetailCtrl.saveFindings(RevSys_Obs_RecordDetailCtrl.initializeObservationDetailPage(params));
    }
    */
}
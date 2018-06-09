/**
*___________________________________________________
*@Name: SafeTrend_FindingHandler_Test
*@Author: Gani Amsath
*@Created: Date: 7/31/2017
*@Used_By: SafeTrends App
*___________________________________________________
*@Description: This class is used to test the SafeTrend_FindingHandler
*___________________________________________________
*@Changes:
* MM-DD-YYY. Explanation of the change. 
**/

@isTest
private class SafeTrend_FindingHandler_Test {
    
    @testSetup static void setupMethod() {
        ST_Bypass_Trigger_Settings__c stBTS = new ST_Bypass_Trigger_Settings__c();
        stBTS.ObservationTrigger__c = FALSE;
        stBTS.FindingTrigger__c = FALSE;
        stBTS.ProcessTeamTrigger__c = FALSE;
        insert stBTS;
    }
    
    static testmethod void insertFindingasFacilitator(){
        
        //Local variables
        String processName = 'Bear Backshop';
        String stFindingRecordTypeId = Schema.SObjectType.Finding__c.getRecordTypeInfosByName().get(System.Label.ST_FindingRecordTypeName).getRecordTypeId();
        
        //Create test records
        User currentUser = [Select id,EmployeeNumber,name from User where id=: Userinfo.getUserId()];
        
        Profile pf = [SELECT Id FROM Profile WHERE Name =:System.Label.Safe_Trends_Profile];        
        User facilitatorUser = TestHandler.createTestUser(null, pf.Id, 'Test FirstName', 'Test LastName');
        insert facilitatorUser;       
        
        facilitatorUser.employeenumber = '80000000';
        update facilitatorUser;        
        
        Id permissionsetId = [Select Id FROM PermissionSet WHERE Name =: System.Label.Safe_Trend_Facilitator_Permission_Set].id; 
        PermissionsetAssignment permSetAssigment = new PermissionsetAssignment(PermissionSetId = permissionsetId, AssigneeId = facilitatorUser.id); 
        insert permSetAssigment; 
        
        //Run in current user context
        system.runAs(currentUser){
            
            Contact contact = SafeTrendsTestHelper.createContact('Test First Name', 'Test Last Name', 80000000);
            
            Process__c process = SafeTrendsTestHelper.createProcess(processName);
            process.ownerid = facilitatorUser.id;
            update process;
            
            Location__c location = SafeTrendsTestHelper.createLocation(process);
            Location__c area = SafeTrendsTestHelper.createArea(process, location );
            SBI__c sb1 = SafeTrendsTestHelper.createSBI('1.1 Line of Fire');
            
            Process_Team__c pt = SafeTrendsTestHelper.createProcessTeam(process, contact, 'Observer', 'Active'); 
            
            Observation__c obs = SafeTrendsTestHelper.createObservation(process, pt,location, area);
            
            //Run in Facilitator user context
            system.runAs(facilitatorUser){
                
                Finding__c finding1 = new Finding__c();
                finding1.Observation__c = obs.Id;
                finding1.SBI_Name__c = sb1.Id;
                finding1.Safe_Checkbox__c= true;
                finding1.At_Risk_Checkbox__c= false;
                finding1.RecordTypeId = stFindingRecordTypeId;                
                
                Test.startTest();     
                insert finding1;
                Test.stopTest();                
            }
        }
    }
    
    static testmethod void insertFindingforAnotherUser(){
        
        //Local variables
        String processName = 'Bear Backshop';
        String stFindingRecordTypeId = Schema.SObjectType.Finding__c.getRecordTypeInfosByName().get(System.Label.ST_FindingRecordTypeName).getRecordTypeId();
        
        //Create test records
        User currentUser = [Select id,EmployeeNumber,name from User where id=: Userinfo.getUserId()];
        
        Profile pf = [SELECT Id FROM Profile WHERE Name =:System.Label.Safe_Trends_Profile];        
        User facilitatorUser = TestHandler.createTestUser(null, pf.Id, 'Test FirstName', 'Test LastName');
        insert facilitatorUser;       
        
        facilitatorUser.employeenumber = '80000000';
        update facilitatorUser;        
        
        Id permissionsetId = [Select Id FROM PermissionSet WHERE Name =: System.Label.Safe_Trend_Facilitator_Permission_Set].id; 
        PermissionsetAssignment permSetAssigment = new PermissionsetAssignment(PermissionSetId = permissionsetId, AssigneeId = facilitatorUser.id); 
        insert permSetAssigment; 
        
        //Run in current user context to insert finding for another user
        system.runAs(currentUser){  
            
            Contact contact = SafeTrendsTestHelper.createContact('Test First Name', 'Test Last Name', 80000000);
            
            Process__c process = SafeTrendsTestHelper.createProcess(processName);
            process.ownerid = facilitatorUser.id;
            update process;
            
            Location__c location = SafeTrendsTestHelper.createLocation(process);
            Location__c area = SafeTrendsTestHelper.createArea(process, location );
            SBI__c sb1 = SafeTrendsTestHelper.createSBI('1.1 Line of Fire');
            
            Process_Team__c pt = SafeTrendsTestHelper.createProcessTeam(process, contact, 'Observer', 'Active'); 
            
            Observation__c obs = SafeTrendsTestHelper.createObservation(process, pt,location, area);
            
            Finding__c finding1 = new Finding__c();
            finding1.Observation__c = obs.Id;
            finding1.SBI_Name__c = sb1.Id;
            finding1.Safe_Checkbox__c= true;
            finding1.At_Risk_Checkbox__c= false;
            finding1.RecordTypeId = stFindingRecordTypeId;                
            
            Test.startTest();     
            insert finding1;
            Test.stopTest();             
        }
    }
}
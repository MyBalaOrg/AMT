/**
*___________________________________________________
*@Name: SafeTrend_ObservationHandler_Test
*@Author: Gani Amsath
*@Created: Date: 7/28/2017
*@Used_By: SafeTrends App 
*___________________________________________________
*@Description: This class is used to test the SafeTrend_ObservationHandler
*___________________________________________________
*@Changes:
* MM-DD-YYY. Explanation of the change.
**/

@isTest
private class SafeTrend_ObservationHandler_Test {
    
    @testSetup static void setupMethod() {
        ST_Bypass_Trigger_Settings__c stBTS = new ST_Bypass_Trigger_Settings__c();
        stBTS.ObservationTrigger__c = FALSE;
        stBTS.FindingTrigger__c = FALSE;
        stBTS.ProcessTeamTrigger__c = FALSE;
        insert stBTS;
    }
    
    static testmethod void insertObservationForAnotherUser(){      
        
        //Local variables
        String processName = 'Bear Backshop';
        
        //Create test records
        User currentUser = [Select id,EmployeeNumber,name from User where id=: Userinfo.getUserId()];       
        
        Profile pf = [SELECT Id FROM Profile WHERE Name =:System.Label.Safe_Trends_Profile];        
        User dataEntryUser = TestHandler.createTestUser(null, pf.Id, 'Data Entry FirstName', 'Test LastName');
        insert dataEntryUser;       
        
        dataEntryUser.employeenumber = '70000000';
        update dataEntryUser;        
        
        Id permissionsetIdDataEntry = [Select Id FROM PermissionSet WHERE Name =: System.Label.Safe_Trend_Data_Entry_Clerk_Permission_Set].id; 
        PermissionsetAssignment permSetAssigmentDataEntry = new PermissionsetAssignment(PermissionSetId = permissionsetIdDataEntry, AssigneeId = dataEntryUser.id); 
        insert permSetAssigmentDataEntry; 
        
        User facilitatorUser = TestHandler.createTestUser(null, pf.Id, 'Facilitator FirstName', 'Test LastName');
        insert facilitatorUser;       
        
        facilitatorUser.employeenumber = '90000000';
        update facilitatorUser;        
        
        Id permissionsetId = [Select Id FROM PermissionSet WHERE Name =: System.Label.Safe_Trend_Facilitator_Permission_Set].id; 
        PermissionsetAssignment permSetAssigment = new PermissionsetAssignment(PermissionSetId = permissionsetId, AssigneeId = facilitatorUser.id); 
        insert permSetAssigment; 
        
        //Run in current user context
        System.runAs(currentUser){                         
            
            Contact contact = SafeTrendsTestHelper.createContact('Test First Name', 'Test Last Name', 90000000);
            
            Process__c process = SafeTrendsTestHelper.createProcess(processName);
            process.ownerid = facilitatorUser.id;
            update process;
            
            Location__c location = SafeTrendsTestHelper.createLocation(process);
            Location__c area = SafeTrendsTestHelper.createArea(process, location );            
            
            Process_Team__c pt = SafeTrendsTestHelper.createProcessTeam(process, contact, 'Observer', 'Active'); 
            
            //Run in Data Entry User context
            System.runAs(dataEntryUser){                   
                
                Test.startTest();
                Observation__c obs = SafeTrendsTestHelper.createObservation(process, pt,location, area); 
                Test.stopTest();                
            }
        }        
    }
    
    static testmethod void insertAndUpdateObservation(){
        //Local variables
        String stFindingRecordTypeId = Schema.SObjectType.Finding__c.getRecordTypeInfosByName().get(System.Label.ST_FindingRecordTypeName).getRecordTypeId();
        String processName = 'Bear Backshop';
        
        //Create test records
        User currentUser = [Select id,EmployeeNumber,name from User where id=: Userinfo.getUserId()];        
        
        Profile pf = [SELECT Id FROM Profile WHERE Name =:System.Label.Safe_Trends_Profile];        
        User dataEntryUser = TestHandler.createTestUser(null, pf.Id, 'Data Entry FirstName', 'Test LastName');
        insert dataEntryUser;       
        
        dataEntryUser.employeenumber = '60000000';
        update dataEntryUser;        
        
        Id permissionsetIdDataEntry = [Select Id FROM PermissionSet WHERE Name =: System.Label.Safe_Trend_Data_Entry_Clerk_Permission_Set].id; 
        PermissionsetAssignment permSetAssigmentDataEntry = new PermissionsetAssignment(PermissionSetId = permissionsetIdDataEntry, AssigneeId = dataEntryUser.id); 
        insert permSetAssigmentDataEntry; 
        
        User facilitatorUser = TestHandler.createTestUser(null, pf.Id, 'Facilitator FirstName', 'Test LastName');
        insert facilitatorUser;       
        
        facilitatorUser.employeenumber = '50000000';
        update facilitatorUser;        
        
        Id permissionsetId = [Select Id FROM PermissionSet WHERE Name =: System.Label.Safe_Trend_Facilitator_Permission_Set].id; 
        PermissionsetAssignment permSetAssigment = new PermissionsetAssignment(PermissionSetId = permissionsetId, AssigneeId = facilitatorUser.id); 
        insert permSetAssigment; 
        
        User facilitatorUser2 = TestHandler.createTestUser(null, pf.Id, 'Facilitator2 FirstName', 'Test LastName');
        insert facilitatorUser2;       
        
        facilitatorUser2.employeenumber = '40000000';
        update facilitatorUser2;       
        
        PermissionsetAssignment permSetAssigment2 = new PermissionsetAssignment(PermissionSetId = permissionsetId, AssigneeId = facilitatorUser2.id); 
        insert permSetAssigment2; 
        
        //Run in current user context
        System.runAs(currentUser){
            
            Contact contact = SafeTrendsTestHelper.createContact('Facilitator1 First Name', 'Test Last Name', 50000000);
            Contact contact2 = SafeTrendsTestHelper.createContact('Facilitator2 First Name', 'Test Last Name', 40000000);
            
            Process__c process = SafeTrendsTestHelper.createProcess(processName);
            process.ownerid = facilitatorUser.id;
            update process;
            
            Location__c location = SafeTrendsTestHelper.createLocation(process);
            Location__c area = SafeTrendsTestHelper.createArea(process, location );
            SBI__c sb1 = SafeTrendsTestHelper.createSBI('1.1 Line of Fire');            
            
            Process_Team__c pt = SafeTrendsTestHelper.createProcessTeam(process, contact, 'Observer', 'Active'); 
            
            Process_Team__c pt2 = SafeTrendsTestHelper.createProcessTeam(process, contact2, 'Observer', 'Active'); 
            pt2.User__c = facilitatorUser2.Id;
            update pt2;
            
            //Run in Data Entry User context
            System.runAs(dataEntryUser){
                
                Observation__c obs = SafeTrendsTestHelper.createObservation(process, pt,location, area);
                
                Finding__c finding1 = new Finding__c();
                finding1.Observation__c = obs.Id;
                finding1.SBI_Name__c = sb1.Id;
                finding1.Safe_Checkbox__c= true;
                finding1.At_Risk_Checkbox__c= false;
                finding1.RecordTypeId = stFindingRecordTypeId;    
                insert finding1; 
                
                Test.startTest();                
                TriggerHandler.processedClasses.clear();                              
                obs.Observer_ID_Process_Team__c = pt2.Id;
                update obs;                        
                Test.stopTest();                               
            }
        }
    }
    
    
    
}
/**
*___________________________________________________
*@Name: SafeTrend_ProcessTeamHandler_Test
*@Author: Gani Amsath
*@Created: Date: 8/1/2017
*@Used_By: SafeTrends App
*___________________________________________________
*@Description: This class is used to test the SafeTrend_ProcessTeamHandler
*___________________________________________________
*@Changes:
* MM-DD-YYY. Explanation of the change.
**/

@isTest
private class SafeTrend_ProcessTeamHandler_Test {
    
    @testSetup static void setupMethod() {
        ST_Bypass_Trigger_Settings__c stBTS = new ST_Bypass_Trigger_Settings__c();
        stBTS.ObservationTrigger__c = FALSE;
        stBTS.FindingTrigger__c = FALSE;
        stBTS.ProcessTeamTrigger__c = FALSE;
        insert stBTS;
    }
    
    static testmethod void insertProcessTeam(){
        
        //Local variables
        String processName = 'Bear Backshop';
        
        //Create test records
        User currentUser = [Select id,EmployeeNumber,name from User where id=: Userinfo.getUserId()];
        
        Profile pf = [SELECT Id FROM Profile WHERE Name =:System.Label.Safe_Trends_Profile];        
        User facilitatorUser = TestHandler.createTestUser(null, pf.Id, 'Test FirstName', 'Test LastName');
        insert facilitatorUser;       
        
        facilitatorUser.employeenumber = '80000000';
        facilitatorUser.isActive = true;
        update facilitatorUser;        
        
        Id permissionsetId = [Select Id FROM PermissionSet WHERE Name =: system.label.Safe_Trend_Facilitator_Permission_Set].id; 
        PermissionsetAssignment permSetAssigment = new PermissionsetAssignment(PermissionSetId = permissionsetId, AssigneeId = facilitatorUser.id); 
        insert permSetAssigment;         
        
        //Run in current user context
        system.runAs(currentUser){
            Contact contact = SafeTrendsTestHelper.createContact('Test First Name', 'Test Last Name', 80000000);
            
            Process__c process = SafeTrendsTestHelper.createProcess(processName);
            process.ownerid = facilitatorUser.id;
            update process;
            
            //Run in Facilitator user context
            system.runAs(facilitatorUser){                                               
                Test.startTest();     
                Process_Team__c pt = SafeTrendsTestHelper.createProcessTeam(process, contact, 'Data Entry', 'Active'); 
                Test.stopTest();                
            }
        }
    }
    
    
    static testmethod void updateProcessTeamForInactiveUser(){
        
        //Local variables
        String processName = 'Bear Backshop';
        
        //Create test records
        User currentUser = [Select id,EmployeeNumber,name from User where id=: Userinfo.getUserId()];
        
        Profile pf = [SELECT Id FROM Profile WHERE Name =:System.Label.Safe_Trends_Profile];        
        User facilitatorUser = TestHandler.createTestUser(null, pf.Id, 'Test FirstName', 'Test LastName');
        insert facilitatorUser;       
        
        facilitatorUser.employeenumber = '80000000';
        facilitatorUser.isActive = true;
        update facilitatorUser;        
        
        Id permissionsetId = [Select Id FROM PermissionSet WHERE Name =: system.label.Safe_Trend_Facilitator_Permission_Set].id; 
        PermissionsetAssignment permSetAssigment = new PermissionsetAssignment(PermissionSetId = permissionsetId, AssigneeId = facilitatorUser.id); 
        insert permSetAssigment;         
        
        //Run in current user context
        system.runAs(currentUser){
            
            
            Contact contact = SafeTrendsTestHelper.createContact('Test First Name', 'Test Last Name', 80000000);
            
            Process__c process = SafeTrendsTestHelper.createProcess(processName);
            process.ownerid = facilitatorUser.id;
            update process;
            
            Process_Team__c pt = SafeTrendsTestHelper.createProcessTeam(process, contact, 'Data Entry', 'Inactive'); 
            
            //Run in Facilitator user context
            system.runAs(facilitatorUser){ 
                TriggerHandler.processedClasses.clear();
                Test.startTest();
                pt.Team_Member_Status__c = 'Active';
                update pt;
                Test.stopTest();     
                
            }
        }
    }
    
    
    static testmethod void updateProcessTeamForActiveUser(){
        
        //Local variables
        String processName = 'Bear Backshop';
        
        //Create test records
        User currentUser = [Select id,EmployeeNumber,name from User where id=: Userinfo.getUserId()];
        
        Profile pf = [SELECT Id FROM Profile WHERE Name =:System.Label.Safe_Trends_Profile];        
        User facilitatorUser = TestHandler.createTestUser(null, pf.Id, 'Test FirstName', 'Test LastName');
        insert facilitatorUser;       
        
        facilitatorUser.employeenumber = '80000000';
        facilitatorUser.isActive = true;
        update facilitatorUser;        
        
        Id permissionsetId = [Select Id FROM PermissionSet WHERE Name =: system.label.Safe_Trend_Facilitator_Permission_Set].id; 
        PermissionsetAssignment permSetAssigment = new PermissionsetAssignment(PermissionSetId = permissionsetId, AssigneeId = facilitatorUser.id); 
        insert permSetAssigment;         
        
        //Run in current user context
        system.runAs(currentUser){
            
            
            Contact contact = SafeTrendsTestHelper.createContact('Test First Name', 'Test Last Name', 80000000);
            Process__c process = SafeTrendsTestHelper.createProcess(processName);
            process.ownerid = facilitatorUser.id;
            update process;
            
            Process_Team__c pt = SafeTrendsTestHelper.createProcessTeam(process, contact, 'Data Entry', 'Active'); 
            
            //Run in Facilitator user context
            
            Test.startTest();
            TriggerHandler.processedClasses.clear(); 
            pt.Team_Member_Status__c = 'Inactive';
            update pt;
            Test.stopTest();
            
        }
    }
    
    static testmethod void updateProcessTeamForActiveUserRoleChanged(){
        
        //Local variables
        String processName = 'Bear Backshop';
        
        //Create test records
        User currentUser = [Select id,EmployeeNumber,name from User where id=: Userinfo.getUserId()];
        
        Profile pf = [SELECT Id FROM Profile WHERE Name =:System.Label.Safe_Trends_Profile];        
        User facilitatorUser = TestHandler.createTestUser(null, pf.Id, 'Test FirstName', 'Test LastName');
        insert facilitatorUser;       
        
        facilitatorUser.employeenumber = '80000000';
        facilitatorUser.isActive = true;
        update facilitatorUser;        
        
       Id permissionsetId = [Select Id FROM PermissionSet WHERE Name =: system.label.Safe_Trend_Facilitator_Permission_Set].id; 
        PermissionsetAssignment permSetAssigment = new PermissionsetAssignment(PermissionSetId = permissionsetId, AssigneeId = facilitatorUser.id); 
        insert permSetAssigment; 
        
        //Run in current user context
        system.runAs(currentUser){
            
            
            Contact contact = SafeTrendsTestHelper.createContact('Test First Name', 'Test Last Name', 80000000);
            
            Process__c process = SafeTrendsTestHelper.createProcess(processName);
            
            
            Process_Team__c pt = SafeTrendsTestHelper.createProcessTeam(process, contact, 'Data entry', 'Active'); 
            
            //Run in Facilitator user context
            
            TriggerHandler.processedClasses.clear(); 
            pt.Team_Role__c = 'Observer';
            update pt;
            
            
        }
    }
    
    
    
}
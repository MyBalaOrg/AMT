/**
*___________________________________________________
*@Name: ST_ObservationController_Test
*@Author: Max Paquin
*@Created: Date: 5/17/2017
*@Used_By: SafeTrends App
*___________________________________________________
*@Description: This class is used to test the ST_ObservationController
*___________________________________________________
*@Changes:
* MM-DD-YYY. Explanation of the change.
**/
@isTest
private class ST_ObservationController_Test {
    
    @testSetup static void setupMethod() {
        ST_Bypass_Trigger_Settings__c stBTS = new ST_Bypass_Trigger_Settings__c();
        stBTS.ObservationTrigger__c = FALSE;
        stBTS.FindingTrigger__c = FALSE;
        stBTS.ProcessTeamTrigger__c = FALSE;
        insert stBTS;
        
        ST_Bypass_Rules_Settings__c stBTSRules = new ST_Bypass_Rules_Settings__c();
        stBTSRules.Validation_Rules__c = FALSE;
        stBTSRules.Workflow_Rules__c = FALSE;
        insert stBTSRules;
            }
    
    @isTest static void testPickListOptions() {
        
        Test.startTest();
        
        ST_ObservationController.getDepartmentPickval();
        ST_ObservationController.getShiftPickval();
        ST_ObservationController.getCraftPickval();
        ST_ObservationController.getBehaviorPickVal();
        ST_ObservationController.getDependentOptionsImpl('Observation__c','Department__c', 'Craft__c');
        ST_ObservationController.getBehaviorPickVal();
        Test.stopTest();
    }
    
    @isTest static void validInsertion() {
        //create all test data
        String processName = 'Bear Backshop';
        User currentUser = [Select id,EmployeeNumber,name from User where id=: Userinfo.getUserId()];
        
        Profile pf = [SELECT Id FROM Profile WHERE Name =:System.Label.Safe_Trends_Profile];        
        User facilitatorUser = TestHandler.createTestUser(null, pf.Id, 'Test FirstName', 'Test LastName');
        insert facilitatorUser;       
        
        facilitatorUser.employeenumber = '80000000';
        update facilitatorUser;
        
        system.runAs(currentUser){
            Id permissionsetId = [Select Id FROM PermissionSet WHERE Name =: 'Facilitator'].id; 
            PermissionsetAssignment permSetAssigment = new PermissionsetAssignment(PermissionSetId = permissionsetId, AssigneeId = facilitatorUser.id); 
            insert permSetAssigment; 
            
            Process__c process = SafeTrendsTestHelper.createProcess(processName);
            process.ownerid = facilitatorUser.id;
            update process;
            Location__c location = SafeTrendsTestHelper.createLocation(process);
            Location__c area = SafeTrendsTestHelper.createArea(process, location );
            SBI__c sb1 = SafeTrendsTestHelper.createSBI('1.1 Line of Fire');
            SBI__c sb2 = SafeTrendsTestHelper.createSBI('1.2 Pinch Points');
            
            Contact contact = SafeTrendsTestHelper.createContact('Test First Name', 'Test Last Name',80000000);
            
            Process_Team__c pt = SafeTrendsTestHelper.createProcessTeam(process, contact, 'Facilitator', 'Active');
            
            system.debug('pt '+pt);
            System.runAs(facilitatorUser){
                Observation__c observation = new Observation__c();
                //observation.RecordTypeId = recordTypeId_obs;
                observation.Observer_ID_Process_Team__c = pt.Id;
                observation.Number_of_Workers_Observed__c = 2;
                observation.date__c = Date.Today();
                observation.process__c = process.Id;
                observation.location__c = location.Id;
                observation.Area__c = area.Id;
                observation.department__c = 'Mechanical';
                
                List<Finding__c> findingList = new List<Finding__c>();
                Finding__c f1 = new Finding__c();
                f1.SBI_Name__c = sb1.Id;
                f1.Behavior__c ='Difficult';
                f1.While__c ='tst';
                f1.Was__c ='tst';
                f1.Because__c ='tst';
                f1.Solution__c ='tst';
                f1.Try__c ='Yes';
                f1.At_Risk_Checkbox__c = true;
                findingList.add(f1);
                
                Finding__c f2 = new Finding__c();
                f2.SBI_Name__c = sb2.Id;
                f2.Safe_Checkbox__c = true;
                findingList.add(f2);
                
                Test.startTest();
                String dmlMessage = ST_ObservationController.insertObservation(observation,findingList);
                String erroMSG = ST_ObservationController.getServerSideMessage();
                ST_ObservationController.findObserverOrCoach(facilitatorUser.EmployeeNumber, process.Id);
                ST_ObservationController.getSBIs(observation.Department__c);
                ST_ObservationController.getCurrentUserObserver(process.id);
                ST_ObservationController.getAreas(location.Id);
                ST_ObservationController.getCurrentUserProcesses();
                ST_ObservationController.findAllLocations('%', process.Id);
                system.assertEquals('Success',dmlMessage, 'the insertion was a success');
                Test.stopTest();
            }
        }
        
    }
    
    @isTest static void invalidObservation() {
        //create all test data
        String processName = 'Bear Backshop';
        
        
         User currentUser = [Select id,EmployeeNumber,name from User where id=: Userinfo.getUserId()];
        
        Profile pf = [SELECT Id FROM Profile WHERE Name =:System.Label.Safe_Trends_Profile];        
        User facilitatorUser = TestHandler.createTestUser(null, pf.Id, 'Test FirstName', 'Test LastName');
        insert facilitatorUser;       
        
        facilitatorUser.employeenumber = '80000000';
        update facilitatorUser;
        
        
        system.runAs(currentUser){
            
            Id permissionsetId = [Select Id FROM PermissionSet WHERE Name =: 'Facilitator'].id; 
            PermissionsetAssignment permSetAssigment = new PermissionsetAssignment(PermissionSetId = permissionsetId, AssigneeId = facilitatorUser.id); 
            insert permSetAssigment;  
            
            Process__c process = SafeTrendsTestHelper.createProcess(processName);
            Location__c location = SafeTrendsTestHelper.createLocation(process);
            Location__c area = SafeTrendsTestHelper.createArea(process, location );
            SBI__c sb1 = SafeTrendsTestHelper.createSBI('1.1 Line of Fire');
            SBI__c sb2 = SafeTrendsTestHelper.createSBI('1.2 Pinch Points');
            
            Contact contact = SafeTrendsTestHelper.createContact('Test First Name', 'Test Last Name', 80000000);
            Process_Team__c pt = SafeTrendsTestHelper.createProcessTeam(process, contact, 'Facilitator', 'Active');
            
            System.runAs(facilitatorUser){
                Observation__c obs = new Observation__c();
                obs.Observer_ID_Process_Team__c = pt.Id;
                obs.Process__c = process.Id;
                //obs.Coached_ID__c =;
                //obs.Location__c =location.Id;
                //obs.Number_of_Workers_Observed__c = 1;
                obs.Area__c = area.Id;
                //obs.Date__c = Date.today();
                //obs.Department__c ='Mechanical';
                obs.Shift__c = '7am - 3pm';
                obs.Craft__c = 'Mechanical';
                obs.Overall_Comments__c ='test class test';
                
                List<Finding__c> findingList = new List<Finding__c>();
                Finding__c f1 = new Finding__c();
                f1.SBI_Name__c = sb1.Id;
                f1.Behavior__c ='Difficult';
                f1.While__c ='tst';
                f1.Was__c ='tst';
                f1.Because__c ='tst';
                f1.Solution__c ='tst';
                f1.Try__c ='Yes';
                f1.At_Risk_Checkbox__c = true;
                findingList.add(f1);
                
                Finding__c f2 = new Finding__c();
                f2.SBI_Name__c = sb2.Id;
                f2.Safe_Checkbox__c = true;
                findingList.add(f2);
                
                Test.startTest();
                String dmlMessage = ST_ObservationController.insertObservation(obs,findingList);
                String erroMSG = ST_ObservationController.getServerSideMessage();
                system.assertEquals('Error_observations',dmlMessage, 'The observation insertion failed as expected');
                Test.stopTest();
            }
        }
        
    }
    @isTest static void invalidFindings() {
        //create all test data
        String processName = 'Bear Backshop';
        
        
        //Create test records
        User currentUser = [Select id,EmployeeNumber,name from User where id=: Userinfo.getUserId()];
        
        Profile pf = [SELECT Id FROM Profile WHERE Name =:System.Label.Safe_Trends_Profile];        
        User facilitatorUser = TestHandler.createTestUser(null, pf.Id, 'Test FirstName', 'Test LastName');
        insert facilitatorUser;       
        
        facilitatorUser.employeenumber = '80000000';
        update facilitatorUser;
        
        Id permissionsetId = [Select Id FROM PermissionSet WHERE Name =: 'Facilitator'].id; 
        PermissionsetAssignment permSetAssigment = new PermissionsetAssignment(PermissionSetId = permissionsetId, AssigneeId = facilitatorUser.id); 
        insert permSetAssigment;  
        
        system.runAs(currentUser){
            
            Process__c process = SafeTrendsTestHelper.createProcess(processName);
            process.ownerid = facilitatorUser.id;
            update process;
            Location__c location = SafeTrendsTestHelper.createLocation(process);
            Location__c area = SafeTrendsTestHelper.createArea(process, location );
            SBI__c sb1 = SafeTrendsTestHelper.createSBI('1.1 Line of Fire');
            SBI__c sb2 = SafeTrendsTestHelper.createSBI('1.2 Pinch Points');
            
            Contact contact = SafeTrendsTestHelper.createContact('Test First Name', 'Test Last Name', 80000000);
            Process_Team__c pt = SafeTrendsTestHelper.createProcessTeam(process, contact, 'Facilitator', 'Active');
            System.runAs(facilitatorUser){
                Observation__c observation = new Observation__c();
                //observation.RecordTypeId = recordTypeId_obs;
                observation.Observer_ID_Process_Team__c = pt.Id;
                observation.Number_of_Workers_Observed__c = 2;
                observation.date__c = Date.Today();
                observation.process__c = process.Id;
                observation.location__c = location.Id;
                observation.Area__c = area.Id;
                observation.department__c = 'Mechanical';
                
                List<Finding__c> findingList = new List<Finding__c>();
                Finding__c f1 = new Finding__c();
                f1.SBI_Name__c = sb1.Id;
                f1.Behavior__c ='Difficult';
                f1.While__c ='tst';
                f1.Was__c ='tst';
                f1.Because__c ='tst';
                f1.Solution__c ='tst';
                f1.Try__c ='Yes';
                f1.At_Risk_Checkbox__c = true;
                f1.Safe_Checkbox__c = true;
                findingList.add(f1);
                
                Finding__c f2 = new Finding__c();
                f2.SBI_Name__c = sb2.Id;
                f2.Safe_Checkbox__c = true;
                findingList.add(f2);
                
                Test.startTest();
                String dmlMessage = ST_ObservationController.insertObservation(observation,findingList);
                String erroMSG = ST_ObservationController.getServerSideMessage();
                system.assertEquals('Error_findings',dmlMessage, 'The Findings insertion failed as expected');
                Test.stopTest();
            }
        }
        
    }
    
    @isTest static void testPicklistEntryWrapper() {
        ST_PicklistEntryWrapper cmp = new ST_PicklistEntryWrapper();
    }
    
}
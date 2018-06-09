//tests  CheckPlanExistsSameArrivalDate - Tim Harrington 5\19
@isTest
public class CheckPlanExistsSameArrivalDate_Test {
    public static testmethod void test_insertOperationalPlan(){
        
        Route__c oRoute = new Route__c(Name='Test Route');
        insert oRoute;
        Train__c oTrain = new Train__c(Name='7',Route__c = oRoute.Id);
        insert oTrain;
        Station__c oStation = new Station__c(Name='Test  Station');
        insert oStation;
        Date arrivalDate = Date.newInstance(2017,08,17);
        Operational_Plan__c oPlan = new Operational_Plan__c(Name = 'Test Plan',Arrival_Date__c = arrivalDate,Arrival_Track__c='7',Station_del__c = oStation.Id,Train__c = oTrain.Id);
        insert oPlan ;
             
        //now update
        Date newArrivalDate = Date.newInstance(2017,08,18);
        Operational_Plan__c plan = [SELECT Id,  Arrival_Date__c FROM Operational_Plan__c where Name = 'Test Plan' limit 1];
        plan.Arrival_Date__c=newArrivalDate;
        update plan;
      
    }
}
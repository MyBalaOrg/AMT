/**
* ********************************************************************************************************************************************************************************************************************************************
*	@Name			OC_SmallContactTileApexController
*	@Author			Luke Kanter, Deloitte Digital
*	@Created Date	7th Feb 2017
*	@Used By		OC_SmallContactTile.cmp
*	*******************************************************************************************************************************************************************************************************************************************
*	@Description	This controller queries database to support the component.
*	*******************************************************************************************************************************************************************************************************************************************
*	@Changes
*	Modified to use new Position-Contact Data structure 
*	******************************************************************************************************************************************************************************************************************************************* 
**/
public with sharing class OC_SmallContactTileApexController {
    // Query database to see if a certain contact has direct reports
    @AuraEnabled
    public static Boolean hasSubordinates(String positionId) {
        List<Position__c> positions
            = [SELECT Id, Name, Generated_Reports_To_Position__c 
               FROM Position__c WHERE Generated_Reports_To_Position__c=:positionId];
        
        if(!positions.isEmpty()) {
            return true;
        } else {
            System.debug('no subordinates found');
            return false;
        }
    }
    
    // Query database to see if a certain contact has a manager
    @AuraEnabled
    public static Boolean hasManager(String positionId) {
        List<Position__c> positions = [SELECT Id, Generated_Reports_To_Position__c FROM Position__c WHERE Id=:positionId];
        if(!positions.isEmpty()) {
            if(positions.get(0).Generated_Reports_To_Position__c != null) {
                return true;
            } else {
                System.debug('No manager found');
                return false;
            }
        } else {
            System.debug('No ID passed in for hasManager function');
            return false;
        }
        /*List<Position__c> subList = [SELECT Id, Generated_Reports_To_Position__c FROM Position__c WHERE Id=:positionId];
        if(subList.size() > 0) {
            Position__c sub = subList.get(0);
            List<Position__c> positions
                = [SELECT Id, Name, Position_ID__c, Position_Abbrv__c, Generated_Reports_To_Position__c,
                   (SELECT FirstName, MiddleName, LastName, Job_Abbrev__c, Org_Unit_Number__c, Organization_Unit_Name__c, Cost_Center__c, 
                    Personnel_Area__c, Personnel_SubArea_Text__c, Employee_Group_Text__c, Employee_Subgroup_Text__c, Work_Schedule__c, 
                    Time_Admin__c, Payroll_Admin__c, Org_Key__c, Corp_Function__c, Hire_Date__c, Employment_Status__c 
                    FROM Contacts__r WHERE Employment_Status__c='Active') 
                   FROM Position__c WHERE Id=:sub.Generated_Reports_To_Position__c];
            if(!positions.isEmpty()) {
                Position__c pos = positions.get(0);
                return true;
            }  else {
                System.debug('no manager found');
                return false;
            }
        } else {
            System.debug('no results for passed in');
            return null;
        }*/
    }
    
}
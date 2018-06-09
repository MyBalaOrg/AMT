/**
*___________________________________________________
*@Name: CaseController
*@Author: Gaurav Dharra
*@Created: Date: 12/04/2017
*@Used_By: CEO Systems
*___________________________________________________
*@Description: CEO New Question Creation Functionality
*___________________________________________________
**/

public with sharing class CaseController {

    public static Id userId = UserInfo.getUserId();

   /**
    *————————————————————————————————————————————————————
    * @Name: Gaurav Dharra
    * @Description
    * Return User information to populate on the Case Creation form
    *————————————————————————————————————————————————————
    * @param    
    * @return   
    *————————————————————————————————————————————————————
    **/ 
    
    @AuraEnabled
    public static User getUserInfo() {
        userId = UserInfo.getUserId();
        return [SELECT FirstName, LastName, Email, EmployeeNumber FROM User WHERE Id =: userId];
    }
    
   /**
    *————————————————————————————————————————————————————
    * @Name: Gaurav Dharra
    * @Description
    * Fetch Contact associated to a User based on employee number
    *————————————————————————————————————————————————————
    * @param    employeeNumber - Employee Number field on User
    * @return   Contact - Contact object 
    *————————————————————————————————————————————————————
    **/  
    @AuraEnabled
    public static List<Contact> fetchContactFromUser(String employeeNumber){
        System.debug('hey');
        System.debug(employeeNumber);
        List<Contact> testList = [Select id, FirstName, LastName, OtherCity, OtherState from Contact where Formatted_Personnel_Num__c =: employeeNumber];
        return testList;
    }
    
  /**
    *————————————————————————————————————————————————————
    * @Name: Gaurav Dharra
    * @Description
    * New Case creation
    *————————————————————————————————————————————————————
    * @param    c - case object
    * @return   String message - Success/Error Message based on the result of DML
    *————————————————————————————————————————————————————
    **/  
    @AuraEnabled
    public static String insertNewCase(Case c) {
        String returnMessage = null;
        if(c != null) {
         	Id recTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(System.Label.CEO_Case_Record_Type).getRecordTypeId();
            c.RecordTypeId = recTypeId;
            try {
                insert c;
                returnMessage = 'Success';
            } catch (Exception e) {
                system.debug('ERROR '+ e.getMessage());
                returnMessage = e.getMessage();
            }   
        }
        return returnMessage;
    }
}
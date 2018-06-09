/**
*___________________________________________________
*@Name:   ViolationSelector
*@Author:   Mona Bhutada
*@Created:   Date: 01/30/2017
*@Used_By:   SPARTN
*___________________________________________________
*@Description: Selector class for Violation__c
* 
*___________________________________________________
*@Changes: 
* 
**/
public with sharing class ViolationSelector {
  
     public static Boolean DoFailTest = FALSE;
    
  /**
    *——  ——————————————————————————————————————————————————
    * @Name: getViolationRecords
    * @Description
    * Fetches list of Name for each violation
    * 
    *————————————————————————————————————————————————————
    * @params   
    * @returns  SelectorWrapper     Wrapper with list of violation Records
    *————————————————————————————————————————————————————
    **/
    public static SelectorWrapper getViolationRecords(List<Violation__c> violationList) {  
      String myQuery;

      String myErrorMessage; 
      List<Violation__c> empViolationList = new List<Violation__c>(); 
      List<SObject> mySObjectList = new List<SObject>(); 
      myQuery = System.Label.SELECT+' Id, Employee__r.Name  ';
      myQuery += System.Label.FROM +' '+Label.OBJAPI_VIOLATION +' '; 
      myQuery += System.Label.WHERE +' ID IN: ViolationList ';
        
        if(Test.isRunningTest() && DoFailTest) {
            myQuery = myQuery.replace('SELECT', 'FAIL') ;
        }
      try {

        empViolationList = Database.query(myQuery); 

        } catch(QueryException qe) {

          system.debug(System.Label.SOQL_Query_Error + qe.getMessage());
          myErrorMessage = System.Label.QueryErrorSobjectException + qe.getMessage();
        }

        mySObjectList = empViolationList; 

        SelectorWrapper myWrap = new SelectorWrapper(myErrorMessage, mySObjectList); 

        return myWrap;
    }

}
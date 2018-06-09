@isTest
public class Revsys_GenericUtility_Test {
    public static testMethod void testGetAssignedPermissionSet(){
        
        List<REVSYS_Custom_Settings__c> revSysCs = new List<REVSYS_Custom_Settings__c>();
        REVSYS_Custom_Settings__c r = new REVSYS_Custom_Settings__c();
        r.CSV_String__c='SPARTN_Certification_Administrator,SPARTN_Manager_of_Train_Operations,SPARTN_Road_Foreman,SPARTN_Target_Administrator,SPARTN_Train_Master,SPARTN_Testing_Officer';       
       	r.Name='PermissionsforObservations';
        Insert r;     
        Revsys_GenericUtility.getAssignedPermissionSet();
    }
}
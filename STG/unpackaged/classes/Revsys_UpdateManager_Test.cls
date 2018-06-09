@isTest
public class Revsys_UpdateManager_Test {
    
    @testSetup static void setup() {
		SPARTN_Custom_Settings__c setting = new SPARTN_Custom_Settings__c();
        setting.Name = 'Valid Employee Department';
        setting.CsvString__c = 'TRANSPORTATION,ENGINEERING,MECHANICAL';
        insert setting;
    }
    
     
    testmethod static void updateSpartnManager(){
      ID revSysPosHierarchyRecordType = Schema.SObjectType.EPW_Position_Hierarchy__c.getRecordTypeInfosByName().get(Label.RevSys_PositionHierarchy_RT_Label).getRecordTypeId();
      ID revOrgRecordType = Schema.SObjectType.EPW_Position_Hierarchy__c.getRecordTypeInfosByName().get(Label.RevSys_Organization_RT_Label).getRecordTypeId();
        //Create org Spartn
        EPW_Organization__c org = new EPW_Organization__c(
            name='TestSpartnOrg',
            RecordTypeId=  Schema.SObjectType.EPW_Organization__c.getRecordTypeInfosByName().get('Spartn').getRecordTypeId(),
            EPW_Organization_Number__c = 'test123');
        insert org;
        
        //Create position 1 	AppManager
        EPW_Position_Hierarchy__c  pos1 = new EPW_Position_Hierarchy__c(
            name='TestAppManager',
            RecordTypeId=  revSysPosHierarchyRecordType,
            EPW_position_id__C='testpos123',
            EPW_Position_Organization__C= org.Id);
        insert pos1;
        
        //Create position 2 (Salesforce Manager) with parent Pos1 
        EPW_Position_Hierarchy__c  pos2 = new EPW_Position_Hierarchy__c(
            name='TestSFManager',
            RecordTypeId=  revSysPosHierarchyRecordType,
            EPW_position_id__C='testpos12345',
            EPW_Parent_Position_Hierarchy__C= pos1.Id);
        insert pos2;
        
        //Create position 3 Manager
        EPW_Position_Hierarchy__c  pos3 = new EPW_Position_Hierarchy__c(
            name='Manager',
            RecordTypeId=  revSysPosHierarchyRecordType,
            EPW_position_id__C='testpos12377',
            EPW_Position_Organization__C= org.Id);
        insert pos3;
        
        //Create Contact C1
        Contact c1  = new Contact(
            lastname = 'test',
            firstName='trigger1',
            email='testt@abc.com');
        insert c1;
        
        //Create Contact C2
        Contact c2  = new Contact(
            lastname = 'ManagerContact',
            firstName='test',
            email='test12@abc.com');
        insert c2;
        
        //Create Hierarchy Assignment with c1 , pos 2
        EPW_Hierarchy_Assignment__c ha1 = new EPW_Hierarchy_Assignment__c(
            EPW_Contact__C= c1.Id,
            EPW_Position_Hierarchy__c=pos2.Id );
        Insert ha1;
    
        
        //Create Hierarchy Assignment with c2 , pos3     
        EPW_Hierarchy_Assignment__c ha2 = new EPW_Hierarchy_Assignment__c(
            EPW_Contact__C= c2.Id,
            EPW_Position_Hierarchy__c=pos3.Id );
        Insert ha2;     
            
        
        Test.startTest();
       EPW_Hierarchy_Assignment__c ha = [select Id,EPW_Contact__C,EPW_Position_Hierarchy__c,SPARTN_Manager__C from EPW_Hierarchy_Assignment__c where Id = :ha1.Id];
        ha.SPARTN_Manager__c = c2.Id;
       
        Update ha;
        
        EPW_Position_Hierarchy__C pos = [select Id,EPW_Parent_Position_Hierarchy__C from EPW_Position_Hierarchy__C where Id= :pos2.Id ];
        
        Test.stopTest();
        system.debug('compare Expected :- ' +pos.EPW_Parent_Position_Hierarchy__c + '  Actual :-' +pos3.Id);
        //system.assertEquals(pos.EPW_Parent_Position_Hierarchy__c, pos3.Id);
    }

}
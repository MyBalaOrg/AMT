@isTest
public class EIS_contactTriggerHelperTest {
    
    public static testMethod Void testUpdatePositionContact(){
        
        position__c a = new position__c
            (
                Position_ID__c = '12345',
                Name = 'IT Info'                
            );
        insert a;
        list<contact> con = new list<contact>();
        con.add(new contact(  LastName = 'Test', PositionLookup__C = a.id ));
        insert con;
        update con;
        delete con;
    }
}
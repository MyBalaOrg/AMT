/**
*___________________________________________________
*@Name: RevSys_CertificationRevocation_Test
*@Author: Shiva
*@Created: Date: 03/17/2018
*@Used_By: SPARTN
*___________________________________________________
*@Description: Test class for FieldSetMemberWrapper class
* 
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/
@isTest
public class FieldSetMemberWrapper_Test {
    static testmethod void test1(){
        Schema.SObjectType targetType         = Schema.getGlobalDescribe().get('Observation__c');
        Schema.DescribeSObjectResult describe = targetType.getDescribe();
        Map<String, Schema.FieldSet> fsMap    = describe.fieldSets.getMap();
        Schema.FieldSet fs                    = fsMap.get('SPARTN_TestInfo1878');
        List<Schema.FieldSetMember> fieldSet  = fs.getFields();
        Test.startTest();
        FieldSetMemberWrapper field = new FieldSetMemberWrapper(fieldSet[0]);
        Test.stopTest();
    }
    
}
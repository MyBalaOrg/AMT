/*--------------------------------------------------------------------------------------------------------
FlowDynamicRecordChoiceCnvrtToLst_Test
Author:  Chuck Walley, Deloitte
Modifications:      
02/05/2018  Chuck Walley      New Class
--------------------------------------------------------------------------------------------------------*/
@isTest(SeeAllData=false)
public class FlowDynamicRecordChoiceCnvrtToLst_Test {   
    static testMethod void test1Convert() 
    {
        String myStringToConvert = 'aaa; bbb; ccc; ddd; eee; fff;' ;

        List<String> myStringList = new List<String>(); 
        myStringList.add(myStringToConvert); 

        List<List<String>> myAnswerListList 
                = FlowDynamicRecordChoiceConvertToList.convert(myStringList); 

        system.assertEquals(1,myAnswerListList.size()); 

        List<String> myAnswerList = myAnswerListList[0]; 

        system.assertEquals(6,myAnswerList.size() ); 

    }
    static testMethod void test2Convert() 
    {
        String myStringToConvert = 'aaa; bbb; ccc; ddd; eee; fff' ;

        List<String> myStringList = new List<String>(); 
        myStringList.add(myStringToConvert); 

        List<List<String>> myAnswerListList 
                = FlowDynamicRecordChoiceConvertToList.convert(myStringList); 

        system.assertEquals(1,myAnswerListList.size()); 

        List<String> myAnswerList = myAnswerListList[0]; 

        system.assertEquals(6,myAnswerList.size() ); 

    }
    static testMethod void test3Convert() 
    {
        String myStringToConvert = 'aaa bbb ccc ddd eee; fff' ;

        List<String> myStringList = new List<String>(); 
        myStringList.add(myStringToConvert); 

        List<List<String>> myAnswerListList 
                = FlowDynamicRecordChoiceConvertToList.convert(myStringList); 

        system.assertEquals(1,myAnswerListList.size()); 

        List<String> myAnswerList = myAnswerListList[0]; 

        system.assertEquals(2,myAnswerList.size() ); 

    }
}
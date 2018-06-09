/*--------------------------------------------------------------------------------------------------------
FlowDedupeStringList_Test
Author:  Chuck Walley, Deloitte
Modifications:      
02/12/2018  Chuck Walley      New Class
--------------------------------------------------------------------------------------------------------*/
@isTest(SeeAllData=false)
public class FlowDedupeStringList_Test {   
    static testMethod void test1() 
    {
        List<List<String>> myListList = new List<List<String>>(); 
        List<String>       myStringList = new List<String>(); 


        myStringList.add('ThisString');
        myStringList.add('ThisString');
        myStringList.add('ThisString');
        myStringList.add('ThisString');
        myStringList.add('ThisString');
        myStringList.add('ThisString');
        myStringList.add('ThisString');
        myStringList.add('ThisString');
        myStringList.add('ThisString');
        myStringList.add('ThisString');

        myListList.add(myStringList); 

        myStringList = new List<String>(); 

        myStringList.add('ThisString1');
        myStringList.add('ThisString2');
        myStringList.add('ThisString3');
        myStringList.add('ThisString4');
        myStringList.add('ThisString5');
        myStringList.add('ThisString6');
        myStringList.add('ThisString7');
        myStringList.add('ThisString8');
        myStringList.add('ThisString9');
        myStringList.add('ThisString10');

        myListList.add(myStringList); 

        myStringList = new List<String>(); 

        myStringList.add('ThisString1');
        myStringList.add('ThisString1');
        myStringList.add('ThisString2');
        myStringList.add('ThisString3');
        myStringList.add('ThisString4');
        myStringList.add('ThisString5');
        myStringList.add('ThisString6');
        myStringList.add('ThisString7');
        myStringList.add('ThisString8');
        myStringList.add('ThisString9');
        myStringList.add('ThisString10');

        myListList.add(myStringList); 

        List<List<String>> myAnswerListList = FlowDedupeStringList.dedupe(myListList); 

   
        List<String> myAnswerList = myAnswerListList[0]; 
        system.assertEquals(1, myAnswerList.size() ); 

        myAnswerList = myAnswerListList[1]; 
        system.assertEquals(10, myAnswerList.size() ); 

        myAnswerList = myAnswerListList[2]; 
        system.assertEquals(10, myAnswerList.size() ); 
 
    }

}
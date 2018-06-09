/*--------------------------------------------------------------------------------------------------------
FlowCreateWizardGuid_Test
Author:  Chuck Walley, Deloitte
Modifications:      
04/22/2018  Chuck Walley      New Class
--------------------------------------------------------------------------------------------------------*/
@isTest(SeeAllData=false)
public class FlowCreateWizardGuid_Test {   
    static testMethod void test1() 
    {
       List<String>       myStringList = new List<String>(); 

        String myString = '12345678'; 

        myStringList.add(myString); 

        List<List<String>> myAnswerListList = FlowCreateWizardGuid.convert(myStringList); 
   
        List<String> myAnswerList = myAnswerListList[0]; 
        system.assertEquals(1, myAnswerList.size() ); 
    }

}
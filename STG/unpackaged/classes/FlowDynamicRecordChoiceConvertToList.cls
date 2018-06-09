/*-------------------------------------------------------------------------------------------
FlowDynamicRecordChoiceConvertToList  
Used to complement Flows where Dynamic Record Choices are used and multile results 
are required. 
Test Class:     FlowDynamicRecordChoiceCnvrtToLst_Test
Modifications:  
02/04/2018      Chuck Walley   New  
--------------------------------------------------------------------------------------------*/
global class FlowDynamicRecordChoiceConvertToList {
    @InvocableMethod
    public static List<List<String>> convert(List<String> theChoiceStringList) {   

        List<List<String>> myAnswerList = new List<List<String>>(); 

        for(String theChoiceString :theChoiceStringList) {
            
            List<String> myList = new List<String>(); 
            myList = theChoiceString.split(';', 0); 
            myAnswerList.add(myList); 
        }

        return myAnswerList; 
    }    
}
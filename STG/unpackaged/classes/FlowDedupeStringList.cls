/*-------------------------------------------------------------------------------------------
FlowDedupeStringList  
Used to complement Flows where Dynamic Record Choices are used and multile results 
are required. This class will remove duplicates from the choices 
Test Class:     FlowDedupeStringList
Modifications:  
02/11/2018      Chuck Walley   New  
05/02/2018      cwalley - Compensate for Flows inconsistantly returning some values with a 
                          leading space
--------------------------------------------------------------------------------------------*/
global class FlowDedupeStringList {
    @InvocableMethod
    public static List<List<String>> dedupe(List<List<String>> theChoiceLists) {   

        List<List<String>> myAnswerList = new List<List<String>>(); 

        for(List<String> theList :theChoiceLists) {
            
            Set<String> myStringSet = new Set<String>(); 

            for(String theString :theList) { 
                myStringSet.add(theString.trim()); 
            }

            List<String> myNewList = new List<String>(); 
            myNewList.addAll(myStringSet); 

            myAnswerList.add(myNewList); 
        }

        return myAnswerList; 
    }    
}
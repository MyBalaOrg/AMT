/*-------------------------------------------------------------------------------------------
FlowBreadCrumb  
Used to complement Process or Flow to print the whereabouts of logic in the debug log. 
Test Class:		FlowBreadCrumbTest
Modifications:  
10/02/2017     	Chuck Walley   New  
--------------------------------------------------------------------------------------------*/
global class FlowBreadCrumb {
    @InvocableMethod
    public static void path(List<String> thePath_List) {   
        system.debug(LoggingLevel.INFO,'-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0- PATH ' + thePath_List[0]); 
    }    
}
/*--------------------------------------------------------------------------------------------------------
FlowBreadCrumbTest
Author:  Chuck Walley, Deloitte
Modifications:      
10/02/2017	Chuck Walley      New Class
--------------------------------------------------------------------------------------------------------*/
@isTest(SeeAllData=false)
public class FlowBreadCrumbTest {   
    static testMethod void testPath() {
    	List<String> myPathList = new List<String>(); 
    	myPathList.add('the path'); 
    	FlowBreadCrumb.path(myPathList); 
    }
}
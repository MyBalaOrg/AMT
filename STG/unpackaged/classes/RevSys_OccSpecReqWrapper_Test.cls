/**
*___________________________________________________
*@Name:     RevSys_OccSpecReqWrapper_Test
*@Author:   Kumar Suyash
*@Created:  Date: 17/03/2018
*@Used_By:  SPARTN
*___________________________________________________
*@Description: Test for RevSys_OccSpecReqWrapper 
* 
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/
@isTest
public class RevSys_OccSpecReqWrapper_Test {
    public static testmethod void test1()
    {  
        
        RevSys_OccSpecReqWrapper occSpecReqWrapper = new RevSys_OccSpecReqWrapper();
        occSpecReqWrapper.selected = true;
        occSpecReqWrapper.testNumber ='Test Num';
        occSpecReqWrapper.testName ='Test Name';
        
        Map<String,Boolean> map1 = new Map<String,Boolean>();
        Map1.put('Test Straing',true);
        
        occSpecReqWrapper.allCraftDeptMap = map1;
        Map<String, Map<String, Boolean>> map2 = new Map<String, Map<String, Boolean>>();
        Map2.put('Test String',map1);
        
        occSpecReqWrapper.deptCraftMap = map2;
        
        List<OccupationSpecificRequirement__c> occList = new List<OccupationSpecificRequirement__c>();
        occSpecReqWrapper.osrList = occList;
        
        List<String> strList = new List<String>();
        occSpecReqWrapper.speedCheckMethodList = strList;
        
        OccupationSpecificRequirement__c c = new OccupationSpecificRequirement__c();
        
        RevSys_OccSpecReqWrapper occSpeReqWrap = new RevSys_OccSpecReqWrapper(c);
    }
    
}
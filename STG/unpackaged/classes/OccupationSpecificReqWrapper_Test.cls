/**
*___________________________________________________
*@Name:     OccupationSpecificReqWrapper_Test
*@Author:   Kumar Suyash
*@Created:  Date: 17/03/2018
*@Used_By:  SPARTN
*___________________________________________________
*@Description: Test for OccupationSpecificRequriementWrapper 
* 
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/
@isTest
public class OccupationSpecificReqWrapper_Test {
    public static  testmethod void test1(){
        OccupationSpecificRequriementWrapper occSpecReqWrapper = new OccupationSpecificRequriementWrapper();
        occSpecReqWrapper.EarliestDate = 'testDate';
        occSpecReqWrapper.oscrequirements = null; 
        set<ID> setIds = new set<ID>();
   		occSpecReqWrapper.OccupationSpecificRequriementWrapper(setIds);
    }
}
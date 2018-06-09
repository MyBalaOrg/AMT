/**
*————————————————————————————————————————————————————
* @Name             RevSys_EmployeeWrapper_Test
* @Author           Shiva Prasad
* @Created Date     01-08-2018
* @Used By          RevSys_TestEntryWrapper
*————————————————————————————————————————————————————
* @Description
* Wrapper Class for custom SPARTN Observation form
*————————————————————————————————————————————————————
* @Changes
* 04/02/2018 Changed by Boom Betetti - Remove myUnitTest2() to accomodate the deprecation of SPARTN_EmployeeWrapper
**/
@isTest
public with sharing class RevSys_EmployeeWrapper_Test 
{
    
    public static testmethod void myUnitTest()
    {
        RevSys_EmployeeWrapper empWrap = new RevSys_EmployeeWrapper();
        empWrap.selected=TRUE;
        empWrap.name='test';
        empWrap.recordId='SPARTN_Form1872';
        empWrap.department='Mechanical';
         empWrap.craftList = new List<String>();
        empWrap.craftList.add('Test Craft');
    }
}
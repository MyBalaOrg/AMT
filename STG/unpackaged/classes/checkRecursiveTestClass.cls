/*
Class Name:     checkRecursiveTestClass
Author:         Urvish Shah
Created Date:   10/3/2016
Description:    To test checkRecursive class that stops any trigger from entering into infinite loop while doing the update DML in after/before Update trigger
Modified:       Class modified to add commentsand System.assert statements; by Anupama Ajith for SAF -282,285 on 2/7/17
*/

@isTest 
private class checkRecursiveTestClass 
{
    static testMethod void validateCheckRecursive() 
    {
        boolean status = checkRecursive.runOnce();
        System.assert(True, status);
        
        checkRecursive.run = false;
        status = checkRecursive.runOnce();
        System.assert(True, status);
    }
}
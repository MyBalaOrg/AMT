/*--------------------------------------------------------------------------------------------------------
DmlHelperTest
Author:  Chuck Walley, Deloitte
Date:    November 4, 2017

Modifications:      
11/04/2017	Chuck Walley      New Class
--------------------------------------------------------------------------------------------------------*/
@isTest(SeeAllData=false)

public class DmlHelperTest         
{   
    static testMethod void test_Insert()
    {
    	
    	List<Account> myAccountList = new List<Account>(); 
    	Account myAcct = new Account
    	(
    		Name = 'Test 1'
    	);

    	myAccountList.add(myAcct); 

    	String errorMsg = DmlHelper.insertList(myAccountList); 
    }
    static testMethod void test_Update()
    {
    	
    	List<Account> myAccountList = new List<Account>(); 
    	Account myAcct = new Account
    	(
    		Name = 'Test 1'
    	);

    	myAccountList.add(myAcct); 

    	String errorMsg = DmlHelper.insertList(myAccountList); 

    	myAcct.Name = 'Test 2'; 

    	errorMsg = DmlHelper.updateList(myAccountList); 
    }
    
    static testMethod void test_Crash()
    {
    	
    	List<Account> myAccountList = new List<Account>(); 
    	Account myAcct = new Account
    	(
    		Name = null
    	);

    	myAccountList.add(myAcct); 

    	String errorMsg = DmlHelper.insertList(myAccountList);     	
    }
}
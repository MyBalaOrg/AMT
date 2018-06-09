/**
*___________________________________________________
*@Name: 	QueryUtilityWrapper
*@Author: 	Chuck Walley
*@Created: 	Date: 11/19/2017
*@Used_By: 	Global 
*___________________________________________________
*@Description: 
* This class is used as a wrapper
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/
public with sharing class QueryUtilityWrapper {
	Public String 	ErrorMessage; 
	Public String 	QueryString;

	public QueryUtilityWrapper(String theErrorMessage, String theQueryString) 
	{
		this.ErrorMessage 	= theErrorMessage; 
		this.QueryString 	= theQueryString; 
	}
}
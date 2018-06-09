/**
*___________________________________________________
*@Name: 	SelectorWrapper
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
public with sharing class SelectorWrapper {
	Public String 			ErrorMessage; 
	Public List<SObject> 	SObjectList;

	public SelectorWrapper(String theErrorMessage, List<SObject> theSObjectList) 
	{
		this.ErrorMessage 	= theErrorMessage; 
		this.SObjectList 	= theSObjectList; 
	}
}
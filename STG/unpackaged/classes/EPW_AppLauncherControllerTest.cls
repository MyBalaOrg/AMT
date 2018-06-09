/**
*___________________________________________________
*@Name: EPW_AppLauncherControllerTest
*@Author: Tejas Khamakar
*@Created: Date: 19/03/2018
*@Used_By: Used to test EPW_AppLauncherController class
*___________________________________________________
*@Description: This class is used to test EPW_AppLauncherController class
*___________________________________________________
*@Changes: 
**/ 
@isTest
private class EPW_AppLauncherControllerTest {
	/**
    *------------------------------------------
    * @Name: testGetApplicationsWithApplications
    * @Description
    * tests getApplications method of EPW_AppLauncherController class with applications in evironment
    *------------------------------------------
    * @param    
    * @return   
    *------------------------------------------
    **/ 
    testmethod static void testGetApplicationsWithApplications() {
        //execute mail logic
        Test.startTest();
        List<AppMenuItem> applicationsFound = EPW_AppLauncherController.getApplications('Network');
        Test.stopTest();
        
        //assert the result
        System.assertNotEquals(0, applicationsFound.size());
    }
    
}
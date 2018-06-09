/**
*___________________________________________________
*@Name: EPW_AppLauncherController
*@Author: Tejas Khamakar
*@Created: Date: 15/03/2018
*@Used_By: Used to test EPW_AppLauncher lightning component
*___________________________________________________
*@Description: This class is used by EPW_AppLauncher lightning component
*___________________________________________________
*@Changes: 
**/ 
public class EPW_AppLauncherController {
    /**
    *------------------------------------------
    * @Name: getApplications
    * @Description
    * returns the List of applications within the organizations
    *------------------------------------------
    * @param    
    * @return   List<AppMenuItem>			list of applications within the organization
    *------------------------------------------
    **/ 
	@AuraEnabled
    public static List<AppMenuItem> getApplications(string applicationType) {
        String searchText;
        
        if(applicationType == '' )
            searchText = 'ConnectedApplication,Network';
        else
            searchText = applicationType;
        
     	List<String> lstApplicationType = new List<string>();
        
        for(String str : searchText.split(','))
        {
            str= '\'' +str+ '\'';
            lstApplicationType.add(str);
        }
        String queryString = 'SELECT Label, StartUrl, LogoUrl, Description, MobileStartUrl,ApplicationId, Type FROM AppMenuItem WHERE IsAccessible = true AND Type IN '+ lstApplicationType + ' ORDER BY Label';
        List<AppMenuItem> appMenuItemResult = Database.query(queryString);
        return appMenuItemResult;
    }
}
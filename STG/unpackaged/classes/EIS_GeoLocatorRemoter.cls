/**
*————————————————————————————————————————————————————
* @Name             EIS_GeoLocatorRemoter
* @Author           Kumar Suyash
* @Created Date     08-02-2017
* @Used By          EIS_Map Page
*————————————————————————————————————————————————————
* @Description
* Used to send data to EIS_Map page 
* 
*————————————————————————————————————————————————————
* @Changes
* @Modified by Venkata - 
1.Users want the ability to filter results based on start and end date.
2. Display only the records which have a latitude and longitude. 

Added forllowing for the change:
Methods- getAllIncidents; resetSearch; SearchIncidents
**/


global with sharing class EIS_GeoLocatorRemoter {
    ApexPages.StandardSetController controller; 
    
    public static String incidentStartDate {get; set;}
    
    /** No Param Constructor **/
    public EIS_GeoLocatorRemoter(){
        if (AEPHIS_Settings__c.getValues('Initial GeoLocator Start Date') != null) {
            incidentStartDate = AEPHIS_Settings__c.getValues('Initial GeoLocator Start Date').EIS_Text_Value__c;
        }
    }
    /********* Begin Code Change Venkata -9/7/2017 ***************************************/
    // This is the list variable which will hold the incident records to be displayed on the front end 
    public List<Incidents__c> IncidentList {
        get {
            if (IncidentList == null)
            {
                system.debug('assign list');
                IncidentList= getAllIncidents(incidentStartDate,null);
                //return findAll();
            }
            return IncidentList;
        }
        set;
    }
    
    /*******************************************************************************************************
* @description - return List of incidents that are to be displayed to the user 
* @param dateTime - start date, EndDate
* @return List<Incidents__c>
* This method can be called by setting both the params as null, this will not affect the query
*/
    @RemoteAction
    global static List<Incidents__c> getAllIncidents(string FilterStartDate,string FilterEnDate)
    {
        datetime startdate2;
        datetime endDate2;
         
        if(FilterStartDate!=null  && FilterStartDate!='' )
        {
            startdate2 = date.parse(FilterStartDate.replace('-', '/'));
        }
        
        if(FilterEnDate!=null  && FilterEnDate!='')
        {
            endDate2= date.parse(FilterEnDate.replace('-', '/'));
        }
        
        
        system.debug('executing query start date is'+FilterStartDate+'  end date is  '+FilterEnDate);
        
        list<Incidents__c> lstIn = [select id, name,EIS_Site__c,SpillLocation__Latitude__s,SpillLocation__Longitude__s ,
                                    EIS_Site__r.name,EIS_Site__r.id,EIS_Site__r.EIS_Site_Location__c,EIS_Date_Time_of_Incident__c
                                    from 
                                    Incidents__c where EIS_Date_Time_of_Incident__c>=:startdate2 
                                    and 
                                    EIS_Date_Time_of_Incident__c<=:endDate2  
                                    and (SpillLocation__Latitude__s != null)
                                    AND (SpillLocation__Longitude__s != null) and recordtype.DeveloperName=:Label.EIS_Spills_Main_Record_Type
                                    order by name asc 
                                    LIMIT :Limits.getLimitQueryRows()
                                   ];
        system.debug('incidentList>>'+lstIn);
        return lstIn;
    } 
    
    /*******************************************************************************************************
* @description - returns null; 
this is a page refernece method which is called from UI when user wants to reset the filter 
* @param - none
* @return null(pagereference)
* This method can be called by setting both the params as null, this will not affect the query
*/
    
    public PageReference resetSearch(){
        IncidentList.clear(); // clear the old list
        incidentStartDate = '';
        IncidentList = getAllIncidents(null,null); // Assign all the records to IncidentList
        return null;
    }
    
    /*******************************************************************************************************
* @description - returns null; 
this is a page refernece method which is called from UI when user wants to filter on incidents
* @param - none
* @return null(pagereference)
* This method can be called by setting both the params as null, this will not affect the query
*/
    public PageReference SearchIncidents(){
        IncidentList.clear(); //clear the old list
        // Get the start and end dates UI input 
        string startDate1 = Apexpages.currentPage().getParameters().get('startDatevf'); 
        string endDate1 = Apexpages.currentPage().getParameters().get('endDatevf');
        // formatting the date space
        IncidentList = getAllIncidents(startDate1,endDate1);
        return null;
    }
    
    /********* End Code Change Venkata -9/7/2017 ***************************************/
}
/*-------------------------------------------------------------------------------------------
FlowCreateDateTime  
Used to complement Flows where Dynamic Record Choices are used and multile results 
are required. 
Test Class:     FlowCreateDateTime_Test
Modifications:  
02/12/2018      Chuck Walley   New  
--------------------------------------------------------------------------------------------*/
global class FlowCreateDateTime {
    @InvocableMethod
    public static List<DateTime> convert(List<List<String>> theChoiceLists) {   

        List<DateTime> myAnswerList = new List<DateTime>(); 

        for(List<String> theDateTimeList :theChoiceLists) {
            
            String myDateString = theDateTimeList[0]; 
            String myTimeString = theDateTimeList[1]; 


            List<String> myDateList = new List<String>(); 
            myDateList = myDateString.split(' ', 0); 
            Integer myMonthInt  = AMTRAK_DateUtility.convertMonthStringToInt(myDateList[0]); 
            String  myDayString = myDateList[1].remove(',');
            Integer myDayInt    = Integer.valueOf(myDayString); 
            Integer myYearInt   = Integer.valueOf(myDateList[2]); 

            List<String> myTimeList = new List<String>(); 
            myTimeList = myTimeString.split(':', 0); 

            Integer myHourInt   = Integer.valueOf(myTimeList[0]); 
            Integer myMinInt    = Integer.valueOf(myTimeList[1]); 

            Datetime myDateTime = Datetime.newInstance(myYearInt, myMonthInt, myDayInt, myHourInt, myMinInt, 0);
            myAnswerList.add(myDateTime); 
        }

        return myAnswerList; 
    }    
 
}
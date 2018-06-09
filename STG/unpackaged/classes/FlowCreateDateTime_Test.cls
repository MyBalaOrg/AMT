/*--------------------------------------------------------------------------------------------------------
FlowCreateDateTime_Test
Author:  Chuck Walley, Deloitte
Modifications:      
02/12/2018  Chuck Walley      New Class
--------------------------------------------------------------------------------------------------------*/
@isTest(SeeAllData=false)
public class FlowCreateDateTime_Test {   
    static testMethod void test1Convert() 
    {
        List<List<String>> myListList = new List<List<String>>(); 
        List<String>       myStringList = new List<String>(); 

        String myTime = '23:59'; 
        String myDate = 'January 1, 2018'; 
        myStringList.add(myDate); 
        myStringList.add(myTime); 
        myListList.add(myStringList);

        myStringList = new List<String>(); 
        myDate = 'February 1, 2018'; 
        myStringList.add(myDate); 
        myStringList.add(myTime); 
        myListList.add(myStringList);

        myStringList = new List<String>(); 
        myDate = 'March 1, 2018'; 
        myStringList.add(myDate); 
        myStringList.add(myTime); 
        myListList.add(myStringList);

        myStringList = new List<String>(); 
        myDate = 'April 1, 2018'; 
        myStringList.add(myDate); 
        myStringList.add(myTime); 
        myListList.add(myStringList);

        myStringList = new List<String>(); 
        myDate = 'May 1, 2018'; 
        myStringList.add(myDate); 
        myStringList.add(myTime); 
        myListList.add(myStringList);

        myStringList = new List<String>(); 
        myDate = 'June 1, 2018'; 
        myStringList.add(myDate); 
        myStringList.add(myTime); 
        myListList.add(myStringList);

        myStringList = new List<String>(); 
        myDate = 'July 1, 2018'; 
        myStringList.add(myDate); 
        myStringList.add(myTime); 
        myListList.add(myStringList);

        myStringList = new List<String>(); 
        myDate = 'August 1, 2018'; 
        myStringList.add(myDate); 
        myStringList.add(myTime); 
        myListList.add(myStringList);

        myStringList = new List<String>(); 
        myDate = 'September 1, 2018'; 
        myStringList.add(myDate); 
        myStringList.add(myTime); 
        myListList.add(myStringList);

        myStringList = new List<String>(); 
        myDate = 'October 1, 2018'; 
        myStringList.add(myDate); 
        myStringList.add(myTime); 
        myListList.add(myStringList);

        myStringList = new List<String>(); 
        myDate = 'November 1, 2018'; 
        myStringList.add(myDate); 
        myStringList.add(myTime); 
        myListList.add(myStringList);

        myStringList = new List<String>(); 
        myDate = 'December 1, 2018'; 
        myStringList.add(myDate); 
        myStringList.add(myTime); 
        myListList.add(myStringList);

        List<DateTime> myDateTimeList = FlowCreateDateTime.convert(myListList); 

        //January
        DateTime myCheckDateTime = DateTime.newInstance(2018,1,1,23,59,00); 
        system.assertEquals(myCheckDateTime, myDateTimeList[0]); 

        //February
        myCheckDateTime = DateTime.newInstance(2018,2,1,23,59,00); 
        system.assertEquals(myCheckDateTime, myDateTimeList[1]); 

        // March
        myCheckDateTime = DateTime.newInstance(2018,3,1,23,59,00); 
        system.assertEquals(myCheckDateTime, myDateTimeList[2]); 

        //April
        myCheckDateTime = DateTime.newInstance(2018,4,1,23,59,00); 
        system.assertEquals(myCheckDateTime, myDateTimeList[3]); 

        //May
        myCheckDateTime = DateTime.newInstance(2018,5,1,23,59,00); 
        system.assertEquals(myCheckDateTime, myDateTimeList[4]); 

        //June
        myCheckDateTime = DateTime.newInstance(2018,6,1,23,59,00); 
        system.assertEquals(myCheckDateTime, myDateTimeList[5]); 

        //July
        myCheckDateTime = DateTime.newInstance(2018,7,1,23,59,00); 
        system.assertEquals(myCheckDateTime, myDateTimeList[6]); 

        //August
        myCheckDateTime = DateTime.newInstance(2018,8,1,23,59,00); 
        system.assertEquals(myCheckDateTime, myDateTimeList[7]); 

        //September
        myCheckDateTime = DateTime.newInstance(2018,9,1,23,59,00); 
        system.assertEquals(myCheckDateTime, myDateTimeList[8]); 

        //October
        myCheckDateTime = DateTime.newInstance(2018,10,1,23,59,00); 
        system.assertEquals(myCheckDateTime, myDateTimeList[9]); 

        //November
        myCheckDateTime = DateTime.newInstance(2018,11,1,23,59,00); 
        system.assertEquals(myCheckDateTime, myDateTimeList[10]); 

        //December
        myCheckDateTime = DateTime.newInstance(2018,12,1,23,59,00); 
        system.assertEquals(myCheckDateTime, myDateTimeList[11]); 

    }

}
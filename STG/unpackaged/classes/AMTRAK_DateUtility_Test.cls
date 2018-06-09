/**
*___________________________________________________
*@Name: 	AMTRAK_DateUtility_test
*@Author: 	Hemanth Kesapragada
*@Created: 	Date: 12/12/2017
*@Used_By: 	Global
*___________________________________________________
*@Description: Test class for generic Date Utility class
* 
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/
@isTest
private class AMTRAK_DateUtility_Test {

	/**
    *————————————————————————————————————————————————————
    * @Name: testDetermineDate
    * @Description
    * Test processed date based on the frequency and length of the period passed
    *————————————————————————————————————————————————————
    **/
	public static testMethod void testDetermineDate() {
		Test.startTest();
		Date processedDate = AMTRAK_DateUtility.determineDate('Days',1) ;
		System.assertEquals(System.today().addDays(1),processedDate);

		processedDate = AMTRAK_DateUtility.determineDate('Months',1) ;
		System.assertEquals(System.today().addMonths(1),processedDate);

		processedDate = AMTRAK_DateUtility.determineDate('Weeks',1) ;
		Integer noOfWeeks = 1*7; //7 days
		System.assertEquals(System.today().addDays(noOfWeeks),processedDate);

		processedDate = AMTRAK_DateUtility.determineDate('Years',1) ;
		System.assertEquals(System.today().addYears(1),processedDate);
		            
// This start Date validation

        date mydate=date.newInstance(2018, 1, 8);
        processedDate = AMTRAK_DateUtility.determineThisStartDate('Months',mydate);
		System.assertEquals(date.newInstance(2018, 1, 1),processedDate);
       
        mydate=date.newInstance(2018, 1, 8);
        processedDate = AMTRAK_DateUtility.determineThisStartDate('Quarters',mydate);
		System.assertEquals(date.newInstance(2018, 1, 1),processedDate);

        mydate=date.newInstance(2018, 5, 8);
        processedDate = AMTRAK_DateUtility.determineThisStartDate('Quarters',mydate);
		System.assertEquals(date.newInstance(2018, 4, 1),processedDate);
        
        mydate=date.newInstance(2018, 9, 8);
        processedDate = AMTRAK_DateUtility.determineThisStartDate('Quarters',mydate);
		System.assertEquals(date.newInstance(2018, 7, 1),processedDate);
        
        mydate=date.newInstance(2018, 12, 8);
        processedDate = AMTRAK_DateUtility.determineThisStartDate('Quarters',mydate);
		System.assertEquals(date.newInstance(2018, 10, 1),processedDate);
        
        mydate=date.newInstance(2018, 2, 8);
        processedDate = AMTRAK_DateUtility.determineThisStartDate('Half-Years',mydate);
		System.assertEquals(date.newInstance(2018, 1, 1),processedDate);

        mydate=date.newInstance(2018, 10, 8);
        processedDate = AMTRAK_DateUtility.determineThisStartDate('Half-Years',mydate);
		System.assertEquals(date.newInstance(2018, 7, 1),processedDate);
        
        mydate=date.newInstance(2018, 2, 8);
        processedDate = AMTRAK_DateUtility.determineThisStartDate('Calendar-Years',mydate);
		System.assertEquals(date.newInstance(2018, 1, 1),processedDate);
        
        mydate=date.newInstance(2018, 1, 8);
        processedDate = AMTRAK_DateUtility.determineThisEndDate('Months', mydate);
		System.assertEquals(date.newInstance(2018, 1, 31),processedDate);
       

        mydate=date.newInstance(2018, 01, 8);
        processedDate = AMTRAK_DateUtility.determineThisEndDate('Quarters',mydate);
		System.assertEquals(date.newInstance(2018, 3, 31),processedDate);

        mydate=date.newInstance(2018, 05, 8);
        processedDate = AMTRAK_DateUtility.determineThisEndDate('Quarters',mydate);
		System.assertEquals(date.newInstance(2018, 06, 30),processedDate);
        
        mydate=date.newInstance(2018, 07, 8);
        processedDate = AMTRAK_DateUtility.determineThisEndDate('Quarters',mydate);
		System.assertEquals(date.newInstance(2018, 9, 30),processedDate);
        
        mydate=date.newInstance(2018, 11, 8);
        processedDate = AMTRAK_DateUtility.determineThisEndDate('Quarters',mydate);
		System.assertEquals(date.newInstance(2018, 12, 31),processedDate);
        
        mydate=date.newInstance(2018, 2, 8);
        processedDate = AMTRAK_DateUtility.determineThisEndDate('Half-Years',mydate);
		System.assertEquals(date.newInstance(2018, 6, 30),processedDate);

        mydate=date.newInstance(2018, 10, 8);
        processedDate = AMTRAK_DateUtility.determineThisEndDate('Half-Years',mydate);
		System.assertEquals(date.newInstance(2018, 12, 31),processedDate);
        
        mydate=date.newInstance(2018, 2, 8);
        processedDate = AMTRAK_DateUtility.determineThisEndDate('Calendar-Years',mydate);
		System.assertEquals(date.newInstance(2018, 12, 31),processedDate);
        
        mydate=date.newInstance(2018, 1, 8);
        String myPeriod = AMTRAK_DateUtility.determineThisPeriod('Months',mydate);
		System.assertEquals('2018-01',myPeriod);  

        mydate=date.newInstance(2018, 1, 8);
        myPeriod = AMTRAK_DateUtility.determineThisPeriod('Quarters',mydate);
		System.assertEquals('2018-Q1',myPeriod);
		
        mydate=date.newInstance(2018, 4, 8);
        myPeriod = AMTRAK_DateUtility.determineThisPeriod('Quarters',mydate);
		System.assertEquals('2018-Q2',myPeriod);

        mydate=date.newInstance(2018, 8, 8);
        myPeriod = AMTRAK_DateUtility.determineThisPeriod('Quarters',mydate);
		System.assertEquals('2018-Q3',myPeriod);
        
        mydate=date.newInstance(2018, 11, 8);
        myPeriod = AMTRAK_DateUtility.determineThisPeriod('Quarters',mydate);
		System.assertEquals('2018-Q4',myPeriod);

        mydate=date.newInstance(2018, 2, 8);
        myPeriod = AMTRAK_DateUtility.determineThisPeriod('Half-Years',mydate);
		System.assertEquals('H1',myPeriod);

        mydate=date.newInstance(2018, 9, 8);
        myPeriod = AMTRAK_DateUtility.determineThisPeriod('Half-Years',mydate);
		System.assertEquals('H2',myPeriod);
        mydate=date.newInstance(2018, 2, 8);
        
        myPeriod = AMTRAK_DateUtility.determineThisPeriod('Calendar-Years',mydate);
		System.assertEquals('2018',myPeriod);

// Next start Date validation

        mydate=date.newInstance(2018, 1, 8);
        processedDate = AMTRAK_DateUtility.determineNextStartDate('Months',mydate);
		System.assertEquals(date.newInstance(2018, 2, 1),processedDate);
       

        mydate=date.newInstance(2018, 1, 8);
        processedDate = AMTRAK_DateUtility.determineNextStartDate('Quarters',mydate);
		System.assertEquals(date.newInstance(2018, 4, 1),processedDate);

        mydate=date.newInstance(2018, 5, 8);
        processedDate = AMTRAK_DateUtility.determineNextStartDate('Quarters',mydate);
		System.assertEquals(date.newInstance(2018, 7, 1),processedDate);
        
        mydate=date.newInstance(2018, 9, 8);
        processedDate = AMTRAK_DateUtility.determineNextStartDate('Quarters',mydate);
		System.assertEquals(date.newInstance(2018, 10, 1),processedDate);
        
        mydate=date.newInstance(2018, 12, 8);
        processedDate = AMTRAK_DateUtility.determineNextStartDate('Quarters',mydate);
		System.assertEquals(date.newInstance(2019, 1, 1),processedDate);
        
        mydate=date.newInstance(2018, 2, 8);
        processedDate = AMTRAK_DateUtility.determineNextStartDate('Half-Years',mydate);
		System.assertEquals(date.newInstance(2018, 7, 1),processedDate);

        mydate=date.newInstance(2018, 10, 8);
        processedDate = AMTRAK_DateUtility.determineNextStartDate('Half-Years',mydate);
		System.assertEquals(date.newInstance(2019, 1, 1),processedDate);
        
        mydate=date.newInstance(2018, 2, 8);
        processedDate = AMTRAK_DateUtility.determineNextStartDate('Calendar-Years',mydate);
		System.assertEquals(date.newInstance(2019, 1, 1),processedDate);
        
        mydate=date.newInstance(2018, 1, 8);
        processedDate = AMTRAK_DateUtility.determineNextEndDate('Months', mydate);
		System.assertEquals(date.newInstance(2018, 2, 28),processedDate);
       
        mydate=date.newInstance(2018, 01, 8);
        processedDate = AMTRAK_DateUtility.determineNextEndDate('Quarters',mydate);
		System.assertEquals(date.newInstance(2018, 6, 30),processedDate);

        mydate=date.newInstance(2018, 05, 8);
        processedDate = AMTRAK_DateUtility.determineNextEndDate('Quarters',mydate);
		System.assertEquals(date.newInstance(2018, 9, 30),processedDate);
        
        mydate=date.newInstance(2018, 07, 8);
        processedDate = AMTRAK_DateUtility.determineNextEndDate('Quarters',mydate);
		System.assertEquals(date.newInstance(2018, 12, 31),processedDate);
        
        mydate=date.newInstance(2018, 11, 8);
        processedDate = AMTRAK_DateUtility.determineNextEndDate('Quarters',mydate);
		System.assertEquals(date.newInstance(2019, 3, 31),processedDate);
        
        mydate=date.newInstance(2018, 2, 8);
        processedDate = AMTRAK_DateUtility.determineNextEndDate('Half-Years',mydate);
		System.assertEquals(date.newInstance(2018, 12, 31),processedDate);

        mydate=date.newInstance(2018, 10, 8);
        processedDate = AMTRAK_DateUtility.determineNextEndDate('Half-Years',mydate);
		System.assertEquals(date.newInstance(2019, 06, 30),processedDate);
        
        mydate=date.newInstance(2018, 2, 8);
        processedDate = AMTRAK_DateUtility.determineNextEndDate('Calendar-Years',mydate);
		System.assertEquals(date.newInstance(2019, 12, 31),processedDate);
        
       mydate=date.newInstance(2018, 1, 8);
        myPeriod = AMTRAK_DateUtility.determineNextPeriod('Months',mydate);
		System.assertEquals('2018-02',myPeriod);  

        mydate=date.newInstance(2018, 1, 8);
        myPeriod = AMTRAK_DateUtility.determineNextPeriod('Quarters',mydate);
		System.assertEquals('2018-Q2',myPeriod);
		
        mydate=date.newInstance(2018, 4, 8);
        myPeriod = AMTRAK_DateUtility.determineNextPeriod('Quarters',mydate);
		System.assertEquals('2018-Q3',myPeriod);

        mydate=date.newInstance(2018, 8, 8);
        myPeriod = AMTRAK_DateUtility.determineNextPeriod('Quarters',mydate);
		System.assertEquals('2018-Q4',myPeriod);
        
        mydate=date.newInstance(2018, 11, 8);
        myPeriod = AMTRAK_DateUtility.determineNextPeriod('Quarters',mydate);
		System.assertEquals('2019-Q1',myPeriod);

        mydate=date.newInstance(2018, 2, 8);
        myPeriod = AMTRAK_DateUtility.determineNextPeriod('Half-Years',mydate);
		System.assertEquals('H2',myPeriod);

        mydate=date.newInstance(2018, 9, 8);
        myPeriod = AMTRAK_DateUtility.determineNextPeriod('Half-Years',mydate);
		System.assertEquals('H1',myPeriod);
        
        mydate=date.newInstance(2018, 2, 8);
        myPeriod = AMTRAK_DateUtility.determineNextPeriod('Calendar-Years',mydate);
		System.assertEquals('2019',myPeriod);

        String expectedValue = '2018-06-08';
        String actualValue = AMTRAK_DateUtility.processDate(Date.newInstance(2018,6 ,8));
        System.assertEquals(expectedValue,actualValue);
                   
        
        Test.stopTest();
	}

}
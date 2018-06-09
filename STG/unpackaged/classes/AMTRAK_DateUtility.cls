/**
*___________________________________________________
*@Name: 	AMTRAK_DateUtility
*@Author: 	Hemanth Kesapragada
*@Created: 	Date: 12/04/2017
*@Used_By: 	Global
*___________________________________________________
*@Description: Generic Date Utility class for the date calculations for start date, next date for different frequencies. 
*Can we be leveraged across all components.
* 
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
* 01-04-2018 - Created functions to calculate start date and next date for month, quarter, half year and year frequency
**/
public with sharing class AMTRAK_DateUtility {

	public static final Date currentDate = System.today();
	public static final Integer DAYS_IN_A_WEEK = 7;
	public static final String DAYS = label.Amtrak_Frequency_Days;
	public static final String WEEKS = label.Amtrak_Frequency_Weeks;
	public static final String MONTHS = label.Amtrak_Frequency_Months;
	public static final String YEARS = label.Amtrak_Frequency_Years;
    public static final String QUARTER = label.Amtrak_Frequency_Quarters;
    public static final String HALFYEAR = label.Amtrak_Frequency_HalfYears;
    public static final String CALENDARYEAR = label.Amtrak_Frequency_CalendarYears;

	/**
    *————————————————————————————————————————————————————
    * @Name: determineDate
    * @Description
    * Returns processed Date from the current date based on the frequency
    * 
    *————————————————————————————————————————————————————
    * @params  	Frequency - Days/Weeks/Months/Years : String
    *			Length Of Period : Date
    * @returns  Date	Date based on the frequency and Length of the period
    *————————————————————————————————————————————————————
    **/
	public static Date determineDate(String frequency, Integer lengthOfPeriod) {

		Date myDate;
		try {
			if(String.isNotBlank(frequency)) {
				if(frequency.equalsIgnoreCase(DAYS)) {
					myDate = processDays(lengthOfPeriod);
				} else if (frequency.equalsIgnoreCase(WEEKS)) {
					myDate = processWeeks(lengthOfPeriod);
				} else if (frequency.equalsIgnoreCase(MONTHS)) {
					myDate = processMonths(lengthOfPeriod);
				} else if (frequency.equalsIgnoreCase(YEARS)) {
					myDate = processYears(lengthOfPeriod);
				}
			}
		} catch(Exception e) {
			System.debug('Exception '+e.getMessage()+' '+e.getLineNumber());
		}
		return mydate;
	}

	/**
    *————————————————————————————————————————————————————
    * @Name: processDays
    * @Description
    * Adds number of days to the current date
    * 
    *————————————————————————————————————————————————————
    * @params  	Length Of Period : Number
    *			
    * @returns  Date	Current Date + Number of Days
    *————————————————————————————————————————————————————
    **/
	public static Date processDays(Integer lengthOfPeriod) {
		Date newDate;
		if(lengthOfPeriod!=null) {
			newDate = currentDate.addDays(lengthOfPeriod);
		}
		return newDate;
	}

	/**
    *————————————————————————————————————————————————————
    * @Name: processWeeks
    * @Description
    * Adds number of Weeks to the current date
    * 
    *————————————————————————————————————————————————————
    * @params  	Length Of Period : Number
    *			
    * @returns  Date	Current Date + Number of weeks
    *————————————————————————————————————————————————————
    **/
	public static Date processWeeks(Integer lengthOfPeriod) {
		Date newDate;

		if(lengthOfPeriod!=null) {
			Integer numberOfDays = lengthOfPeriod * DAYS_IN_A_WEEK;
			newDate = currentDate.addDays(numberOfDays);
		}
		return newDate;
	}

	/**
    *————————————————————————————————————————————————————
    * @Name: processMonths
    * @Description
    * Adds months to the current date
    * 
    *————————————————————————————————————————————————————
    * @params  	Length Of Period : Number
    *			
    * @returns  Date	Current Date + months
    *————————————————————————————————————————————————————
    **/
	public static Date processMonths(Integer lengthOfPeriod) {
		Date newDate;
		if(lengthOfPeriod!=null) {
			newDate = currentDate.addMonths(lengthOfPeriod);
		}
		return newDate;
	}

	/**
    *————————————————————————————————————————————————————
    * @Name: processYears
    * @Description
    * Adds years to the current date
    * 
    *————————————————————————————————————————————————————
    * @params  	Length Of Period : Number
    *			
    * @returns  Date	Current Date + years
    *————————————————————————————————————————————————————
    **/
	public static Date processYears(Integer lengthOfPeriod) {
		Date newDate;
		if(lengthOfPeriod!=null) {
			newDate = currentDate.addYears(lengthOfPeriod);
		}
		return newDate;
	}
    
    /**
    *————————————————————————————————————————————————————
    * @Name: determineThisStartDate
    * @Description
    * Adds years to the current date
    * 
    *————————————————————————————————————————————————————
    * @params  	Frequecy : String
    *			
    * @returns  Date	
    *————————————————————————————————————————————————————
    **/
	public static Date determineThisStartDate(String frequency, Date curDate) {
        
		Date myDate;
        //Date curDate= System.Date.today();
        Date startOfYear = date.newInstance(curDate.year(), 1, 1);
        Integer currentMonth = curDate.month();
        
         System.debug('Inside method determineThisStartDate'+frequency);
        
		try {
			if(String.isNotBlank(frequency)) {
				if(frequency.equalsIgnoreCase(MONTHS)) {
					myDate = curDate.toStartOfMonth();				
				}
                else if (frequency.equalsIgnoreCase(QUARTER)) {
                    if(currentMonth>0 & currentMonth<=3){
                        myDate = startOfYear; 
                    }
                    else if(currentMonth>3 & currentMonth<=6){
                         myDate = startOfYear.addMonths(3);
                    }
                     else if(currentMonth>6 & currentMonth<=9){
                         myDate = startOfYear.addMonths(6);
                    }
                     else if(currentMonth>9 & currentMonth<=12){
                         myDate = startOfYear.addMonths(9);
                    }                    
                }
                else if(frequency.equalsIgnoreCase(HALFYEAR)){
                    if(currentMonth>0 & currentMonth<=6){
                        myDate = startOfYear; 
                    }
                    else if(currentMonth>6 & currentMonth<=12){
                         myDate = startOfYear.addMonths(6);
                    }
                }
                else if(frequency.equalsIgnoreCase(CALENDARYEAR)){                    
                        myDate = startOfYear;                                     
                }
                else{
                    myDate = curDate;
                }
                    
			}
		} catch(Exception e) {
			System.debug('Exception '+e.getMessage()+' '+e.getLineNumber());
		}
		return mydate;
	}
    
    
      /**
    *————————————————————————————————————————————————————
    * @Name: determineThisEndDate
    * @Description
    * Adds years to the current date
    * 
    *————————————————————————————————————————————————————
    * @params  	Frequecy : String
    *			
    * @returns  Date	
    *————————————————————————————————————————————————————
    **/
	public static Date determineThisEndDate(String frequency, Date CurDate) {
        
		Date myDate;
        //Date curDate= System.Date.today();
        Date startOfYear = date.newInstance(curDate.year(), 1, 1);
        Integer currentMonth = curDate.month();
        Integer numberOfDays;
        
		try {
			if(String.isNotBlank(frequency)) {
				if(frequency.equalsIgnoreCase(MONTHS)) {
                    numberOfDays = Date.daysInMonth(curDate.year(), curDate.month());
                    myDate = Date.newInstance(curdate.year(), curdate.month(), numberOfDays);									
				}
                else if (frequency.equalsIgnoreCase(QUARTER)) {
                    if(currentMonth>0 & currentMonth<=3){
                        curDate = startOfYear.addMonths(2); 
                        numberOfDays = Date.daysInMonth(curDate.year(), curDate.month());
                    	myDate = Date.newInstance(curdate.year(), curdate.month(), numberOfDays);	                        
                    }
                    else if(currentMonth>3 & currentMonth<=6){
                        curDate = startOfYear.addMonths(5); 
                        numberOfDays = Date.daysInMonth(curDate.year(), curDate.month());
                    	myDate = Date.newInstance(curdate.year(), curdate.month(), numberOfDays);	
                    }
                     else if(currentMonth>6 & currentMonth<=9){
                        curDate = startOfYear.addMonths(8); 
                        numberOfDays = Date.daysInMonth(curDate.year(), curDate.month());
                    	myDate = Date.newInstance(curdate.year(), curdate.month(), numberOfDays);	
                    }
                     else if(currentMonth>9 & currentMonth<=12){
                        curDate = startOfYear.addMonths(11); 
                        numberOfDays = Date.daysInMonth(curDate.year(), curDate.month());
                    	myDate = Date.newInstance(curdate.year(), curdate.month(), numberOfDays);	
                    }                    
                }
                else if(frequency.equalsIgnoreCase(HALFYEAR)){
                    if(currentMonth>0 & currentMonth<=6){
                        curDate = startOfYear.addMonths(5); 
                        numberOfDays = Date.daysInMonth(curDate.year(), curDate.month());
                    	myDate = Date.newInstance(curdate.year(), curdate.month(), numberOfDays);
                    }
                    else if(currentMonth>6 & currentMonth<=12){
                        curDate = startOfYear.addMonths(11); 
                        numberOfDays = Date.daysInMonth(curDate.year(), curDate.month());
                    	myDate = Date.newInstance(curdate.year(), curdate.month(), numberOfDays);
                    }
                }
                else if(frequency.equalsIgnoreCase(CALENDARYEAR)){                    
                        curDate = startOfYear.addMonths(11); 
                        numberOfDays = Date.daysInMonth(curDate.year(), curDate.month());
                    	myDate = Date.newInstance(curdate.year(), curdate.month(), numberOfDays);                                    
                }				
			}
		} catch(Exception e) {
			System.debug('Exception '+e.getMessage()+' '+e.getLineNumber());
		}
		return mydate;
	}
    
    
      /**
    *————————————————————————————————————————————————————
    * @Name: determineNextStartDate
    * @Description
    * Adds years to the current date
    * 
    *————————————————————————————————————————————————————
    * @params  	Frequecy : String
    *			
    * @returns  Date	
    *————————————————————————————————————————————————————
    **/
	public static Date determineNextStartDate(String frequency, Date curDate)  {
        
		Date myDate;
        //Date curDate= System.Date.today();
        Date startOfYear = date.newInstance(curDate.year(), 1, 1);
        Integer currentMonth = curDate.month();
        
		try {
			if(String.isNotBlank(frequency)) {
				if(frequency.equalsIgnoreCase(MONTHS)) {
					myDate = curDate.toStartOfMonth();
                    myDate=mydate.addMonths(1);
				}
                else if (frequency.equalsIgnoreCase(QUARTER)) {
                    if(currentMonth>0 & currentMonth<=3){
                        myDate = startOfYear; 
                        myDate=mydate.addMonths(3);
                    }
                    else if(currentMonth>3 & currentMonth<=6){
                         myDate = startOfYear.addMonths(3);
                          myDate=mydate.addMonths(3);
                    }
                     else if(currentMonth>6 & currentMonth<=9){
                         myDate = startOfYear.addMonths(6);
                        myDate=mydate.addMonths(3);
                    }
                     else if(currentMonth>9 & currentMonth<=12){
                         myDate = startOfYear.addMonths(9);
                          myDate=mydate.addMonths(3);
                    }                    
                }
                else if(frequency.equalsIgnoreCase(HALFYEAR)){
                    if(currentMonth>0 & currentMonth<=6){
                        myDate = startOfYear; 
                         myDate=mydate.addMonths(6);
                    }
                    else if(currentMonth>6 & currentMonth<=12){
                         myDate = startOfYear.addMonths(6);
                         myDate=mydate.addMonths(6);
                    }
                }
                else if(frequency.equalsIgnoreCase(CALENDARYEAR)){                    
                        myDate = startOfYear;  
                    	myDate=mydate.addMonths(12);
                }                
			}
		} catch(Exception e) {
			System.debug('Exception '+e.getMessage()+' '+e.getLineNumber());
		}
		return mydate;
	}
   
    
    
    
    
    /**
    *————————————————————————————————————————————————————
    * @Name: determineNextEndDate
    * @Description
    * Adds years to the current date
    * 
    *————————————————————————————————————————————————————
    * @params  	Frequecy : String
    *			
    * @returns  Date	
    *————————————————————————————————————————————————————
    **/
	public static Date determineNextEndDate(String frequency, Date curDate) {
        
	    
		Date myDate;
        //Date curDate= System.Date.today();
        Date startOfYear = date.newInstance(curDate.year(), 1, 1);
        Integer currentMonth = curDate.month();
        Integer numberOfDays;
        
		try {
			if(String.isNotBlank(frequency)) {
				if(frequency.equalsIgnoreCase(MONTHS)) {
                    numberOfDays = Date.daysInMonth(curDate.year(), curDate.month());
                    myDate = Date.newInstance(curdate.year(), curdate.month(), numberOfDays);	
                    myDate=mydate.addMonths(1);
				}
                else if (frequency.equalsIgnoreCase(QUARTER)) {
                    if(currentMonth>0 & currentMonth<=3){
                        curDate = startOfYear.addMonths(5); 
                        numberOfDays = Date.daysInMonth(curDate.year(), curDate.month());
                    	myDate = Date.newInstance(curdate.year(), curdate.month(), numberOfDays);
                    }
                    else if(currentMonth>3 & currentMonth<=6){
                        curDate = startOfYear.addMonths(8); 
                        numberOfDays = Date.daysInMonth(curDate.year(), curDate.month());
                    	myDate = Date.newInstance(curdate.year(), curdate.month(), numberOfDays);                        
                    }
                     else if(currentMonth>6 & currentMonth<=9){
                        curDate = startOfYear.addMonths(11); 
                        numberOfDays = Date.daysInMonth(curDate.year(), curDate.month());
                        System.debug('numberofdays'+numberOfDays+'CurDate'+curDate);
                    	myDate = Date.newInstance(curdate.year(), curdate.month(), numberOfDays);	                        
                    }
                     else if(currentMonth>9 & currentMonth<=12){
                        curDate = startOfYear.addMonths(14); 
                        numberOfDays = Date.daysInMonth(curDate.year(), curDate.month());
                    	myDate = Date.newInstance(curdate.year(), curdate.month(), numberOfDays);                        
                    }                    
                }
                else if(frequency.equalsIgnoreCase(HALFYEAR)){
                    if(currentMonth>0 & currentMonth<=6){
                        curDate = startOfYear.addMonths(11); 
                        numberOfDays = Date.daysInMonth(curDate.year(), curDate.month());
                    	myDate = Date.newInstance(curdate.year(), curdate.month(), numberOfDays);
                        
                    }
                    else if(currentMonth>6 & currentMonth<=12){
                        curDate = startOfYear.addMonths(17); 
                        numberOfDays = Date.daysInMonth(curDate.year(), curDate.month());
                    	myDate = Date.newInstance(curdate.year(), curdate.month(), numberOfDays);                        
                    }
                }
                else if(frequency.equalsIgnoreCase(CALENDARYEAR)){                    
                        curDate = startOfYear.addMonths(11); 
                        numberOfDays = Date.daysInMonth(curDate.year(), curDate.month());
                    	myDate = Date.newInstance(curdate.year(), curdate.month(), numberOfDays);
                    	myDate=mydate.addMonths(12);
                }
				                
			}
		} catch(Exception e) {
			System.debug('Exception '+e.getMessage()+' '+e.getLineNumber());
		}
		return mydate;
        
    }
    
   /**
    *————————————————————————————————————————————————————
    * @Name: determineThisPeriod
    * @Description
    * Adds years to the current date
    * 
    *————————————————————————————————————————————————————
    * @params  	Frequecy : String
    *			
    * @returns  String	
    *————————————————————————————————————————————————————
    **/
   
    
    public static String determineThisPeriod(String frequency, Date curDate) {
        
		String myPeriod;
        //Date curDate= System.Date.today();
        Integer curYear =  curDate.Year();     
        Integer currentMonth = curDate.month();
        String currentMonthString;
        
        System.debug('Inside method determineThisPeriod '+frequency);
        
		try {
             if (currentMonth>9){
                currentMonthString = String.valueOf(currentMonth);
             }
             else
             {
                currentMonthString = '0'+currentMonth;
             }
			if(String.isNotBlank(frequency)) {
				if(frequency.equalsIgnoreCase(MONTHS)) {
					myPeriod = curYear +'-'+ currentMonthString;			
				}
                else if (frequency.equalsIgnoreCase(QUARTER)) {
                    if(currentMonth>0 & currentMonth<=3){
                        myPeriod = curYear +'-Q1';
                    }
                    else if(currentMonth>3 & currentMonth<=6){
                         myPeriod = curYear +'-Q2';
                    }
                     else if(currentMonth>6 & currentMonth<=9){
                         myPeriod = curYear +'-Q3';
                    }
                     else if(currentMonth>9 & currentMonth<=12){
                         myPeriod = curYear +'-Q4';
                    }                    
                }
                else if(frequency.equalsIgnoreCase(HALFYEAR)){
                    if(currentMonth>0 & currentMonth<=6){
                        myPeriod = 'H1'; 
                    }
                    else if(currentMonth>6 & currentMonth<=12){
                         myPeriod = 'H2';
                    }
                }
                else if(frequency.equalsIgnoreCase(CALENDARYEAR)){                    
                        myPeriod = String.valueOf(curYear);                                     
                }                
			}
		} catch(Exception e) {
			System.debug('Exception '+e.getMessage()+' '+e.getLineNumber());
		}
		return myPeriod;
	}
    
    /**
    *————————————————————————————————————————————————————
    * @Name: determineNextPeriod
    * @Description
    * Adds years to the current date
    * 
    *————————————————————————————————————————————————————
    * @params  	Frequecy : String
    *			
    * @returns  Date	
    *————————————————————————————————————————————————————
    **/
	public static String determineNextPeriod(String frequency, Date curDate) {
        
		String myPeriod;
        //Date curDate= System.Date.today();
        Integer curYear =  curDate.Year();     
        Integer currentMonth = curDate.month();
        String NextMonthString;
                       
		try {
            if (currentMonth>9){
                NextMonthString = String.valueOf(currentMonth+1);
            }
            else
            {
                NextMonthString = '0'+ (currentMonth+1);
            }
            
            
            if(String.isNotBlank(frequency)) {
				if(frequency.equalsIgnoreCase(MONTHS)) {
                    curDate=curDate.addMonths(1);
					myPeriod = curYear +'-'+ NextMonthString;			
				}
                else if (frequency.equalsIgnoreCase(QUARTER)) {
                    if(currentMonth>0 & currentMonth<=3){
                        myPeriod = curYear +'-Q2';
                    }
                    else if(currentMonth>3 & currentMonth<=6){
                         myPeriod = curYear +'-Q3';
                    }
                     else if(currentMonth>6 & currentMonth<=9){
                         myPeriod = curYear +'-Q4';
                    }
                     else if(currentMonth>9 & currentMonth<=12){
                         myPeriod = (curYear+1) +'-Q1';
                    }                    
                }
                else if(frequency.equalsIgnoreCase(HALFYEAR)){
                    if(currentMonth>0 & currentMonth<=6){
                        myPeriod = 'H2'; 
                    }
                    else if(currentMonth>6 & currentMonth<=12){
                         myPeriod = 'H1';
                    }
                }
                else if(frequency.equalsIgnoreCase(CALENDARYEAR)){                    
                        myPeriod = String.valueOf(curYear+1);                                     
                }                
			}
		} catch(Exception e) {
			System.debug('Exception '+e.getMessage()+' '+e.getLineNumber());
		}
		return myPeriod;
	}

    /**
    *————————————————————————————————————————————————————
    * @Name: processDate
    * @Description
    * Returns current date in String format for Dynamic Query
    * 
    *————————————————————————————————————————————————————
    * @params   Frequecy : String
    *           
    * @returns  Date    
    *————————————————————————————————————————————————————
    **/
    public static String processDate(Date datetoProcess) {
        String processedString;
        if(datetoProcess!=null) {
            String day = datetoProcess.day() <10?'0'+datetoProcess.day():''+datetoProcess.day();
            String month = datetoProcess.month() <10?'0'+datetoProcess.month():''+datetoProcess.month();
            String year = ''+datetoProcess.year();
            processedString = year+'-'+month+'-'+day;
        }
        return processedString;
    }

    /**
    *————————————————————————————————————————————————————
    * @Name: convertMonthStringToInt
    * @Description
    * Returns month in Integer format 
    * 
    *————————————————————————————————————————————————————
    * @params   theMonth : String
    *           
    * @returns  Integer    
    *————————————————————————————————————————————————————
    **/
    public static Integer convertMonthStringToInt(String theMonth) {   

        Map<String, Integer> myMonthMap = new Map<String, Integer>();  
        myMonthMap.put('January',1);  
        myMonthMap.put('February',2); 
        myMonthMap.put('March',3); 
        myMonthMap.put('April',4); 
        myMonthMap.put('May',5); 
        myMonthMap.put('June',6); 
        myMonthMap.put('July',7); 
        myMonthMap.put('August',8); 
        myMonthMap.put('September',9); 
        myMonthMap.put('October',10); 
        myMonthMap.put('November',11); 
        myMonthMap.put('December',12); 

        Integer myMonthInteger = myMonthMap.get(theMonth); 

        return myMonthInteger; 
    }    
    
}
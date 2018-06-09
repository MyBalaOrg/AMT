/**
*___________________________________________________
*@Name: RevSys_StartTarget
*@Author: Raj Kumar Pandy
*@Created: Date: 02/20/2018
*@Used_By: SPARTN
*___________________________________________________
*@Description:  
* This class determines whether the Target can be applied on a specific period
* Put the logic in a helper/utility class. 
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/
public class RevSys_StartTarget {
    
    /**
    *————————————————————————————————————————————————————
    * @Name: checkTargetPeriod()
    * @Description
    * Checks whether the Target can be applied on a specific period
    *————————————————————————————————————————————————————
    * @param    checkDate   	Date for which the period needs to be evaluated, generally the current date
    * @return   Boolean         Whether the period can be applied or not 
    *————————————————————————————————————————————————————
    **/ 
    public static Boolean checkTargetPeriod(Date checkDate, String Frequency){
        Boolean canBeApplied;
        Date startDate;
        Date endDate;
        Double totalDays;
        Double elapsedDays;
        Double daysAvailable;
        
        system.debug('HELPER RevSys_StartTarget checkTargetPeriod-Start');
        
        startDate = AMTRAK_DateUtility.determineThisStartDate(Frequency, checkDate);
        endDate = AMTRAK_DateUtility.determineThisEndDate(Frequency, checkDate);
        
        totalDays = startDate.daysBetween(endDate);
        elapsedDays = startDate.daysBetween(checkDate);
        daysAvailable = elapsedDays/totalDays;
        
        if(daysAvailable <= 0.33){
            canBeApplied = TRUE;
        }
        else{
            canBeApplied = FALSE;
        }
        
        system.debug('HELPER RevSys_StartTarget checkTargetPeriod-End');
        
        return canBeApplied;
    }

}
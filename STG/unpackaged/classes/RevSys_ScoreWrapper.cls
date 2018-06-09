/**
*___________________________________________________
*@Name:     RevSys_ScoreWrapper
*@Author:   Chuck Walley
*@Created:  Date: 11/19/2017
*@Used_By:  Global 
*___________________________________________________
*@Description: 
* This class is used as a wrapper
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/
public class RevSys_ScoreWrapper {
    Public Integer         OverallScore; 
    Public Boolean         PassedCriticalItems;

    public RevSys_ScoreWrapper(Integer theOverallScore, Boolean thePassedCriticalItems) {     
        OverallScore        = theOverallScore;
        PassedCriticalItems = thePassedCriticalItems; 
    }
}
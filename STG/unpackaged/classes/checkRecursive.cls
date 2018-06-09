/*
Class Name:     checkRecursive
Author:         Urvish Shah
Created Date:   10/3/2016
Description:    To stop trigger from entering into infinite loop while doing the update DML in after/before Update trigger
Modified:       Class modified to add comments; by Anupama Ajith on 2/7/17
*/

public Class checkRecursive{
    @TestVisible private static boolean run = true;
    public static boolean runOnce(){
    if(run){
     run=false;
     return true;
    }else{
        return run;
    }
    }
}
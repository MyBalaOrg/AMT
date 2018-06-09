/**
 *	*********************************************************************************************************************
 *	@Name			OC_SmallContactTileController.js 
 * 	@Author			Luke Kanter, Deloitte Digital
 * 	@Created Date	2nd Feb 2017	
 * 	@Used By		OC_SmallContactTile.cmp
 *	**********************************************************************************************************************
 *	@Description	This is the javascript helper for OC_SmallContactTile which checks the hierchy in order to find
 					next level subordinates
 *	**********************************************************************************************************************
 *	@Changes
 					05-31-2017 Modify the code to suppress the SOQLs to find the next level of
 *					subordinates
 *	**********************************************************************************************************************
 **/ 

({
    checkHiearchy : function(cmp,selectedEmp) {
        var level = cmp.get("v.level");
        //Check for subordinates at the subordinate level
        
        if(level == "subordinate") {
            if(selectedEmp.hasSubordinates == true) {
                cmp.set("v.hasSubs",true);
            } else cmp.set("v.hasSubs",false);
        }
        if(level == "manager") {
            if(selectedEmp.hasManager == true) cmp.set("v.hasManager",true);
            else cmp.set("v.hasManager",false);
        }
    }
})
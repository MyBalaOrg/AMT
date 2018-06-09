({
    validateEvaluationDate : function(testResult, fieldName, cmp, completed) {
        
        var evaluationDate = testResult.obs[fieldName];	//return a string (yyyy-mm-dd) format
        
        if (!$A.util.isEmpty(evaluationDate)) {
            //convert a string to date
            var evaluationDateSplit = evaluationDate.split("-");
            var year = parseInt(evaluationDateSplit[0]);
            var month = parseInt(evaluationDateSplit[1] - 1);
            var date = parseInt(evaluationDateSplit[2]);
            var dateVal = new Date(year, month, date);
            
            var currentDate = new Date();
            currentDate.setHours(0,0,0,0);
            
            if(dateVal > currentDate){
                cmp.set("v.errors",  [{message:"Evaluation Date should not be future date."}]);
                completed = false;
            }
            else {
                cmp.set("v.errors",  null);
                completed = completed && !$A.util.isEmpty(testResult.obs[fieldName]);                 
            }
            
            if(testResult.obs["PersonallyObserved__c"] == "Yes"){
                var date10DayOld = new Date();
                date10DayOld.setDate(date10DayOld.getDate() - 11);
                if(dateVal < date10DayOld) {
                    cmp.set("v.errors",  [{message:"Evaluation Date should not be greater than 10 calendar days."}]);
                    completed = false;
                }else if(dateVal > currentDate){
                    console.log("*** inside error.. !");
                    cmp.set("v.errors",  [{message:"Evaluation Date should not be future date."}]);
                    completed = false;
                }else {
                    cmp.set("v.errors",  null);
                    completed = completed && !$A.util.isEmpty(testResult.obs[fieldName]); 
                }
                
            } else if (testResult.obs["PersonallyObserved__c"] == "No") {
                var date90DayOld = new Date();
                date90DayOld.setDate(date90DayOld.getDate() - 91);	//use 91 to skip counting of today
                
                if(dateVal < date90DayOld){
                    cmp.set("v.errors",  [{message:"Evaluation Date should not be greater than 90 calendar days."}]);
                    completed = false;
                }else if(dateVal > currentDate){
                    cmp.set("v.errors",  [{message:"Evaluation Date should not be future date."}]);
                    completed = false;
                }else {
                    cmp.set("v.errors",  null);
                    completed = completed && !$A.util.isEmpty(testResult.obs[fieldName]); 
                }
            }
        } 
        return completed;
    }

})
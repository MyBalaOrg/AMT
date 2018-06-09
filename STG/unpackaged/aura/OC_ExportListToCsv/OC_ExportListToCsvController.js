/**
 *	*********************************************************************************************************************
 *	@Name			OC_ExportListToCsvController.js 
 * 	@Author			Nathan Shinn, Deloitte Digital
 * 	@Created Date	14th Feb 2017	
 * 	@Used By		OC_ExportListToCsv.cmp
 *	**********************************************************************************************************************
 *	@Description	This is the javascript controller for OC_ExportListToCsv which handles events and 
 					interaction and forwards the request to helper methods for further processing.
 *	**********************************************************************************************************************
 *	@Changes
 
 *	**********************************************************************************************************************
 **/     
({
    /**
     * Initialize the first set of results
     */
	doInit : function(component, event, helper) {
        console.log("init:: ");
        //retrieve the list of SObjects from the query
        helper.loadSobjects(component);
	},
    /**
     * Refresh the result set
     */
    requery : function(component, event, helper){
        console.log("event query handled");
  		//get the query set in the event's query parameter
  		var qry = event.getParam("query");
  		var lstSobject = event.getParam("lstSobject");
        var lstFieldApi = event.getParam("lstFieldApi");
		var lstFieldLabel = event.getParam("lstFieldLabel");
        
        //set the query and other attributes from the requery event
  		component.set("v.query", qry);
        component.set("v.lstSobject", lstSobject);
        component.set("v.lstFieldApi", lstFieldApi);
        component.set("v.lstFieldLabel", lstFieldLabel);
        
        //requery
        helper.loadSobjects(component);
    },
    /**
     * Perform the actual csv construction and file download
     */
    exportToCsv : function(component, event, helper){
		var csvContent = "";
        
        var records = component.get("v.lstSobject");
        var labels = component.get("v.lstFieldLabel");
        var fields = component.get("v.lstFieldApi");
        
        //Add the Column Headers
        for(var x = 0; x <labels.length; x++ )
        {
            if(x==0)
                csvContent += "\""+labels[x]+"\"" ;
            else
                csvContent += ",\""+labels[x]+"\"" ;
            
        }
        //add in the data
        if(records != null) {    
        for (var i=0; i<records.length; i++)
        {
            csvContent += "\n";
            for(var c =0; c<fields.length; c++)
            {
                
                var varSobject = records[i];
                var api = fields[c];
                var arrayRecords = varSobject[api.split('.')[0]];
                if(arrayRecords != undefined && api.indexOf('.')>= 0)
                {
                    var val = arrayRecords[api.split('.')[1]]==null?"":arrayRecords[api.split('.')[1]];
                    if(c==0)
                        csvContent += "\""+val+"\"" ;            
                    else
                        csvContent += ",\""+val+"\"" ;
                }
                else
                {
                    var val2 = varSobject[api]==null?"":varSobject[api];
                    if(c==0)
                        csvContent += "\""+val2+"\"" ;            
                    else
                        csvContent += ",\""+val2+"\"" ;
                }
                    
            }
                    
        }
    
        var timestamp = Date.now();
        var filename = "export"+timestamp+".csv";//add in the date
    
        //create the file and Download
        var blob = new Blob([csvContent], {type: 'text/csv;charset=utf-8;'});
        if (navigator.msSaveBlob) { // IE 10+
            navigator.msSaveBlob(blob, filename);
        }
        else {
            var link = document.createElement("a");
            link.setAttribute("download", filename);
            var a = window.document.createElement("a");
                a.href = window.URL.createObjectURL(blob, {type: "text/csv"});
                a.download = filename;
                document.body.appendChild(a);
                a.click();  // IE: "Access is denied"; see: https://connect.microsoft.com/IE/feedback/details/797361/ie-10-treats-blob-url-as-cross-origin-and-denies-access
                document.body.removeChild(a);
            }
        } else {
            alert("This contact does not have any subordinates to export");
        }
  }
})
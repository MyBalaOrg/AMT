/**
 **********************************************************************************************************************
 *	@Name			OC_VerticalOrgChartComponentHelper.js 
 * 	@Author			Luke Kanter, Deloitte Digital
 * 	@Created Date	14th Feb 2017	
 * 	@Used By		OC_VerticalOrgChartComponentController.js
 ***********************************************************************************************************************
 *	@Description	This is the javascript helper controller for OC_VerticalOrgChartComponent which processes requests
 					from the controller and calls the apex controller methods to process data and display results
                    back to the component.
 ***********************************************************************************************************************
 *	@Changes
    8th June 2017 - Modified to handle multiple contacts per position
 ***********************************************************************************************************************
 **/ 

({
    /**
     * **********************************************************************************************************************
     * @Description
     * This method checks url for the passed in contact id
     * **********************************************************************************************************************
     * @param	cmp		component passed from the controller	
     * **********************************************************************************************************************
     **/
    parseUrlAndQueryForContact : function(cmp) {
        // Save the page's url to a variable
        var pageUrl = decodeURIComponent(window.location);
        cmp.set("v.url", pageUrl);
        // Parse url for contact parameter
        if(pageUrl != null) {
            console.log('pageUrl not null. here it is: \n' + pageUrl);
        } else {
            console.log("yep it's totally null");
            return;
        }
        var splitUrl = pageUrl.split('?');
        if(splitUrl != null) {
            var paramString = splitUrl[1];
            var idPair = paramString.split('=');
            var contactId = idPair[1];
            // Set selectedContact attribute to passed url parameter, 
            // if null a default (Amtrak Summary) will be returned
            this.selectEmployee(cmp, contactId);
        } else {
            console.log('problem splitting parameters');
            return;
        }     
        
    },
    
    /**
     * **********************************************************************************************************************
     * @Description
     * This method calls the apex controller to query for a specific position id
     * **********************************************************************************************************************
     * @param	cmp			component passed from the controller
     * @param	contactId	Id of the selected position
     * **********************************************************************************************************************
     **/
    //Sarang : Changed the methodname from selectContact to selectEmployee 6/6/2017
    selectEmployee : function(cmp, contactId) {
        //Sarang : Changed the action from queryContact to selectEmployee 6/6/2017
        var conAction = cmp.get("c.querySelectedEmployee");
        conAction.setParams({
            positionId : contactId
        });
        
        conAction.setCallback(this, function(response) {
            var state = response.getState();
            if (cmp.isValid() && state === "SUCCESS") {
                if(response.getReturnValue() != null) {
                    cmp.set("v.selectedEntity", response.getReturnValue());
                    //Get the Id of the selected position
                    var selectedEmp = cmp.get("v.selectedEntity");
                    var selectedPosId = selectedEmp.position.Id;
                   
                    cmp.set("v.hasManager",selectedEmp.hasManager);
                    cmp.set("v.hasSubordinates",selectedEmp.hasSubordinates)
                    
                    if(typeof selectedEmp != "undefined") {
                        //If the position has single contact then assign the only contact directly
                        if(selectedEmp.hasMultipleEmployees == false && selectedEmp.isVacant == false ){
                            cmp.set("v.selectedContact",selectedEmp.contacts[0]);
                            var selectedContact = cmp.get("v.selectedContact");
                        }
                    }
                    // Call functions to update manager and subordinate tiles
                    this.findManager(cmp, selectedPosId);
                    this.findSubordinates(cmp, selectedPosId);
                } else {
                    // Placeholder for function returning null
                }
                
            } else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(conAction);
    },
    
    /**
     * **********************************************************************************************************************
     * @Description
     * This method calls the apex controller to query the contact that the selected contact reports to
     * **********************************************************************************************************************
     * @param	cmp		component passed from the controller
     * @param	subId	Id of the subordinate contact
     * **********************************************************************************************************************
     **/
    findManager : function(cmp, subId) {
        var manAction = cmp.get("c.queryManager");
        manAction.setParams({
            subId : subId 
        });
        manAction.setCallback(this, function(response) {
            var state = response.getState();
            if (cmp.isValid() && state === "SUCCESS") {
                if(response.getReturnValue() != null) {
                    var manager = response.getReturnValue();
                    cmp.set("v.manager", response.getReturnValue());
                    cmp.set("v.hasManager",true);
                   
                }
                else {
                    
                    console.log('no Manager exists')
                    var manager = cmp.get("v.manager");
                    cmp.set("v.hasManager",false);
              
                }
            } else {
                console.log("Failed with state: " + state);
                
            }
        });
        $A.enqueueAction(manAction);
    },
    /**
     * **********************************************************************************************************************
     * @Description
     * This method calls the apex controller to query all contacts that report to the selected contact.
     * **********************************************************************************************************************
     * @param	cmp			component passed from the controller
     * @param	managerID	ID of the manager
     * **********************************************************************************************************************
     **/
    findSubordinates : function(cmp, managerId) {
        var subAction = cmp.get("c.querySubordinates");
        subAction.setParams({
            managerId : managerId
        });
        subAction.setCallback(this, function(response) {
            var state = response.getState();
            if (cmp.isValid() && state === "SUCCESS") {
                if(response.getReturnValue() != null) {
                    var subordinates = response.getReturnValue();
                    cmp.set("v.listOfSubordinates", response.getReturnValue());
                }
            } else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(subAction);
    },
    /**
     * **********************************************************************************************************************
     * @Description
     * This method calls the apex controller to get the url for the advanced search button.
     * **********************************************************************************************************************
     * @param	cmp			component passed from the controller
     * **********************************************************************************************************************
     **/
    querySearchUrl : function(cmp) {
        var urlAction = cmp.get("c.retrieveSearchUrl");
        urlAction.setCallback(this, function(response) {
            var state = response.getState();
            if (cmp.isValid() && state === "SUCCESS") {
                if(response.getReturnValue() != null) {
                    cmp.set("v.searchUrl", response.getReturnValue());
                }
            } else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(urlAction);
    },
    
    /**
     * **********************************************************************************************************************
     * @Description
     * This method calls the apex controller to get the list of fields that should be searchable.
     * **********************************************************************************************************************
     * @param	cmp			component passed from the controller
     * **********************************************************************************************************************
     **/
    querySearchFieldList : function(cmp) {
        var fieldListAction = cmp.get("c.getFieldList");
        fieldListAction.setParams({ ApplicationContext : "EmployeeSearch" });
        
        fieldListAction.setCallback(this, function(response) {
            var state = response.getState();
            if (cmp.isValid() && state === "SUCCESS") {
                if(response.getReturnValue() != null) {
                    cmp.set("v.searchFieldList", response.getReturnValue().sobjectFields);
                }
            } else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(fieldListAction);
    },
    
    /**
     * **********************************************************************************************************************
     * @Description
     * This method calls the apex controller to get the list of fields that should be displayed as part of the table.
     * **********************************************************************************************************************
     * @param	cmp			component passed from the controller
     * **********************************************************************************************************************
     **/
    queryTableFieldList : function(cmp) {
        var fieldListAction = cmp.get("c.getFieldList");
        fieldListAction.setParams({ ApplicationContext : "OrgChartEmployeeList" });
        
        fieldListAction.setCallback(this, function(response) {
            var state = response.getState();
            if (cmp.isValid() && state === "SUCCESS") {
                if(response.getReturnValue() != null) {
                    cmp.set("v.lstFieldApi", response.getReturnValue().sobjectFields);
                    cmp.set("v.lstFieldLabel", response.getReturnValue().displayLabels);
                }
            } else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(fieldListAction);
    },
    
    /**
     * **********************************************************************************************************************
     * @Description
     * This method calls the apex controller to get the list of fields that should be included as part of the export.
     * **********************************************************************************************************************
     * @param	cmp			component passed from the controller
     * **********************************************************************************************************************
     **/
    queryExportFieldList : function(cmp) {
        var fieldListAction = cmp.get("c.getFieldList");
        fieldListAction.setParams({ ApplicationContext : "OrgChartEmployeeExport" });
        
        fieldListAction.setCallback(this, function(response) {
            var state = response.getState();
            if (cmp.isValid() && state === "SUCCESS") {
                if(response.getReturnValue() != null) {
                    cmp.set("v.expFieldApi", response.getReturnValue().sobjectFields);
                    cmp.set("v.expFieldLabel", response.getReturnValue().displayLabels);
                }
            } else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(fieldListAction);
    },
    /**
     * **********************************************************************************************************************
     * @Description
     * This method calls the apex controller to get the url for the export all report.
     * **********************************************************************************************************************
     * @param	cmp			component passed from the controller
     * **********************************************************************************************************************
     **/
    //Export All
    exportAllHelper : function(cmp) {
        var exportAllURLAction = cmp.get("c.retrieveReportURL");
        exportAllURLAction.setCallback(this, function(response) {
            var state = response.getState();
            if (cmp.isValid() && state === "SUCCESS") {
                if(response.getReturnValue() != null) {
                    var url = response.getReturnValue();
                    cmp.set("v.exportALLReportURL",url);
                }
            } else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(exportAllURLAction);
    },
    
    /**
     * **********************************************************************************************************************
     * @Description
     * This method calls the apex controller to get url and display in separate window.
     * **********************************************************************************************************************
     * @param	cmp			component passed from the controller
     * **********************************************************************************************************************
     **/
    downloadDocument : function(cmp) {
        
        var name = cmp.get("v.documentName");
        var actiondownload = cmp.get("c.downloadDocument");
        
        actiondownload.setParams({
            "docName": name
        });
        
        actiondownload.setCallback(this, function(b){
            var url = b.getReturnValue();
            window.open(url,'_blank', 'toolbar=0,location=0,menubar=0');
        });
        $A.enqueueAction(actiondownload);
        
    },
    /**
     * **********************************************************************************************************************
     * @Description
     * This method calls the apex controller to get obj name for the id coming through search.
     * **********************************************************************************************************************
     * @param	cmp			component passed from the controller
     * **********************************************************************************************************************
     **/
    handleSearchUpdate : function(cmp,selectedId) {
        console.log("selectedId "+selectedId);
        
        //Retrive the first 3 letters of the id
        var pre = selectedId.substring(0,3);
        //Call Apex Method
        var getObjName = cmp.get("c.getObjectName");
        getObjName.setParams({
            pre : pre
        });
        getObjName.setCallback(this, function(response) {
            var state = response.getState();
            if (cmp.isValid() && state === "SUCCESS") {
                if(response.getReturnValue() != null) {
                    var selectSearchObjName = response.getReturnValue();
                    if(selectSearchObjName == "Contact") {
                        //Object name is Contact
                        this.queryContactFromSearch(cmp,selectedId);
                    }
                    else if(selectSearchObjName == "Position__c"){
                        //Object name is Position__c
                        this.selectEmployee(cmp,selectedId);
                    }
                }
            } else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(getObjName);
        
    },
    
     /**
     * **********************************************************************************************************************
     * @Description
     * This method calls the apex controller to get the contact if the contact id is recieved from the search after clicking
     * on one of the search results.
     * **********************************************************************************************************************
     * @param	cmp			component passed from the controller
     * **********************************************************************************************************************
     **/
    queryContactFromSearch : function(cmp,selectedId) {
        console.log("This is a contact "+selectedId);
        //Call the Apex method
        var getConAction = cmp.get("c.getContactOnSearch");
        getConAction.setParams({
            id : selectedId
        });
        getConAction.setCallback(this, function(response) {
            var state = response.getState();
            if (cmp.isValid() && state === "SUCCESS") {
                if(response.getReturnValue() != null) {
                    var contact = response.getReturnValue();
                    var positionLookup = contact.PositionLookup__c;
                    cmp.set("v.selectedContact",contact);
                    this.selectEmployee(cmp,positionLookup); 
                }
            } else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(getConAction);
        
    }    
})
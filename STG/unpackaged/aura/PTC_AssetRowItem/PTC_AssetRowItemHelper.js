/*
********************************************************************************************************************************************************************************************************************************************
*	@Name			PTC_AssetRowItemController.js
*	@Author			Deloitte Digital
*	@Created Date	10th May 2018
*	@Used By		PTC App	
*	@Controller		PTC_AssetInstallationController
********************************************************************************************************************************************************************************************************************************************
*	@Description	This is the javascript helper for PTC_AssetRowItem.cmp which handles events and 
 					interaction and forwards the request to helper methods for further processing.

********************************************************************************************************************************************************************************************************************************************
*	@Changes
********************************************************************************************************************************************************************************************************************************************	
*/

({
    /**
     * **********************************************************************************************************************
     * @Description
     * This method sets default options
     * **********************************************************************************************************************
     * @param	cmp		component passed from the controller	
     * **********************************************************************************************************************
     **/
    setDefaultOptions : function(component,event) {
        var defaultVal = [{
            class: "optionClass",
            label: '-- None --',
            value: null
        }];
        component.find('InputSerialNumber').set("v.serialOptions", defaultVal);
    },
    /**
     * **********************************************************************************************************************
     * @Description
     * This method handles comp name change
     * **********************************************************************************************************************
     * @param	cmp		component passed from the controller	
     * **********************************************************************************************************************
     **/
    
    handlerCompNameChange : function(component,event) {
        var componentNamesSelectList = component.find("InputComponentName");
        var selectedCompName = componentNamesSelectList.get("v.value");
        var selectedControlSys = component.get("v.selectedControlSys");
        
        //clear adjoining cells
        this.clearPartNumbers(component,event);
        this.clearSerialNumber(component,event);
        this.clearSwVersionField(component,event);
        this.clearHwVersionField(component,event);
        
        if(!$A.util.isEmpty(selectedCompName)) {
            component.set("v.selectedCompName",selectedCompName);
            var wrapperInstance = component.get("v.wrapperInstance");
            wrapperInstance.componentName = selectedCompName;
            component.set("v.wrapperInstance",wrapperInstance);
            this.getPartNumbers(component,selectedControlSys,selectedCompName);
            
        } else {
            //clear wrapper Instance if --None- selected
            var wrapperInstance = component.get("v.wrapperInstance");
            wrapperInstance.componentName = '';
            component.set('v.wrapperInstance',wrapperInstance);
        }
        
    },
    
    /**
     * **********************************************************************************************************************
     * @Description
     * This method get all the part numbers
     * **********************************************************************************************************************
     * @param	cmp		component passed from the controller	
     * **********************************************************************************************************************
     **/
    getPartNumbers : function(component,selectedControlSys,selectedCompName) {
        console.log('In getPartNumber ');
        console.log('getContValue== '+selectedControlSys);
        console.log('getCompValue== '+selectedCompName);
        var action = component.get("c.getPartNumbers");
        action.setParams({
            selectedControlSys:selectedControlSys,
            selectedComponentName:selectedCompName
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS') {
                var partnumber = response.getReturnValue();
                component.set("v.partNumbers",partnumber);
                console.log('partnumber----'+partnumber);
            }
            else {
                console.error('Error in getting data');
            }
        });
        $A.enqueueAction(action);
    },
    
    /**
     * **********************************************************************************************************************
     * @Description
     * This method handles part number change
     * **********************************************************************************************************************
     * @param	cmp		component passed from the controller	
     * **********************************************************************************************************************
     **/
    handlerPartNumChange : function(component,event) {
        console.log("In handlerPartNumChange");
        var parentRecordId = component.get("v.parentRecordId");
        console.log("In child record ID =="+parentRecordId);
        var partNumberSelectList = component.find("InputPartNumber");
        var selectedPartNumber = partNumberSelectList.get("v.value");
        var selectedPartNumberText = partNumberSelectList.get("v.label");
        var selectedControlSys = component.get("v.selectedControlSys");
        var selectedCompName = component.get("v.selectedCompName");
        
        this.clearSerialNumber(component,event);
        this.clearSwVersionField(component,event);
        this.clearHwVersionField(component,event);
        
        if(!$A.util.isEmpty(selectedPartNumber)) {
            component.set("v.selectedPartNumber",selectedPartNumber);
            console.log("selectedPartNumber ",+selectedPartNumber);
            var wrapperInstance = component.get("v.wrapperInstance");
            wrapperInstance.partNumber = selectedPartNumberText;
            component.set("v.wrapperInstance",wrapperInstance);
            var locomotiveId = component.get("v.parentRecordId");
            this.getVersions(component,selectedPartNumber,locomotiveId);
            this.getSerialNumbers(component,selectedPartNumber);
        } else {
            var wrapperInstance = component.get("v.wrapperInstance");
            wrapperInstance.prodId = '';
            wrapperInstance.partNumber = '';
            component.set('v.wrapperInstance',wrapperInstance);
        }
    },
    
    
    getVersions : function(component,selectedPartNumber,locomotiveId) {
        console.log("selectedPartNumber "+selectedPartNumber);
        console.log("locomotiveId "+locomotiveId)
        
        
        var action = component.get("c.getMinVersions");
        
        
        action.setParams({
            selectedPartNumber:selectedPartNumber,
            LocoId:locomotiveId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS') {
                var versions = response.getReturnValue();
                
                console.log('versions '+versions);
                
                if(versions[0] !== '' && versions[1] !== '') {
                    var wrapperInstance = component.get("v.wrapperInstance");
                    wrapperInstance.minSwVersion = versions[0];
                    wrapperInstance.minHwVersion = versions[1];
                    component.set("v.wrapperInstance",wrapperInstance);
                }
                
                
            }
            else {
                console.error('Error in getting data');
            }
        });
        $A.enqueueAction(action);
    },
    /**
     * **********************************************************************************************************************
     * @Description
     * This method get serial numbers
     * **********************************************************************************************************************
     * @param	cmp		component passed from the controller	
     * **********************************************************************************************************************
     **/    
    getSerialNumbers : function(component,event) {
        var action = component.get("c.getSerialNumbers");
        var parentRecordId = component.get("v.parentRecordId");
        var serialOptions = [];
        var conformingSerialNums = [];
        var nonConformSerialNums = [];
        var selectedPartNumber = component.get("v.selectedPartNumber");
        console.log('recordId in child-----'+parentRecordId);
        action.setParams({
            LocoId:parentRecordId,
            selectedPartNumber:selectedPartNumber
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS') {
                var assetWrapList = response.getReturnValue();
                component.set("v.assetWrapperList",assetWrapList);              
                if(assetWrapList.length > 0) {
                    component.set("v.showSerialSelect",true);
                    component.set("v.showSerialText",false);
                    //Generate Options
                    //serialOptions.push({label: '--None--',value: null});
                    
                    var minSwVersion = '';
                    var minHwVersion = '';
                    
                    //Get the minimum Version for the selected part number
                    var wrapperInstance = component.get("v.wrapperInstance");
                    minSwVersion = wrapperInstance.minSwVersion;
                    minHwVersion = wrapperInstance.minHwVersion;
                    
                    for (var i = 0; i < assetWrapList.length; i++) {
                        var swVersion = assetWrapList[i].swVersion;
                        var hwVersion = assetWrapList[i].hwVersion;
                        if(hwVersion !== '' && swVersion !== '' && minHwVersion !== '' && minSwVersion !== '' && 
                           minSwVersion != 'N/A' && minSwVersion != '0' && minHwVersion != 'N/A' && minHwVersion != '0' ){
                            if(swVersion < minSwVersion || hwVersion <minHwVersion ) {
                                nonConformSerialNums.push({
                                    label: assetWrapList[i].serialNumber,
                                    value: assetWrapList[i].assetId   
                                });
                            } else {
                                conformingSerialNums.push({
                                    label: assetWrapList[i].serialNumber,
                                    value: assetWrapList[i].assetId   
                                });
                            }
                        } else {
                            conformingSerialNums.push({
                                label: assetWrapList[i].serialNumber,
                                value: assetWrapList[i].assetId   
                            });
                        }
                        
                        
                    }
                    
                    component.set("v.nonConformSerialNums",nonConformSerialNums);
                    component.set("v.conformingSerialNums",conformingSerialNums);
                    
                    serialOptions.push({label: 'Add New Serial',value: 'Add'});
                    component.set("v.serialOptions", serialOptions);
                } else {
                    component.set("v.showSerialSelect",false);
                    component.set("v.showSerialText",true);
                }
                
                console.log('assetWrapList.minSwVersion----'+assetWrapList.minSwVersion);
            }
            else {
                console.error('Error in getting data');
            }
        });
        $A.enqueueAction(action);
    },
    /**
     * **********************************************************************************************************************
     * @Description
     * This method clears all the part number upon any change
     * **********************************************************************************************************************
     * @param	cmp		component passed from the controller	
     * **********************************************************************************************************************
     **/    
    clearPartNumbers : function (component,event) {
        var partNumberField = component.find("InputPartNumber");
        var partNumbers = component.get("v.partNumbers");
        if(typeof partNumberField != 'undefined') {
            if(partNumbers.length>0) {
                partNumberField.set("v.value",'');
                component.set("v.partNumbers",[]);
            }
        }
    },
    /**
     * **********************************************************************************************************************
     * @Description
     * This method clears all the serial number upon any change
     * **********************************************************************************************************************
     * @param	cmp		component passed from the controller	
     * **********************************************************************************************************************
     **/    
    clearSerialNumber : function(component,event) {
        var serialNumTextField = component.find("InputSerialNumber1");
        var serialNumSelectListField = component.find("InputSerialNumber");
        var serialNumbers = component.get("v.assetWrapperList");
        
        if(typeof serialNumTextField != 'undefined') {
            var serialNumTextValue = serialNumTextField.get("v.value");
            if(serialNumTextValue != '')
                serialNumTextField.set("v.value",'');
        }
        
        if(typeof serialNumSelectListField != 'undefined') {
            if(serialNumbers.length > 0) {
                serialNumSelectListField.set("v.value",'');
                component.set("v.assetWrapperList",[]);
                component.set("v.serialOptions",[]);
                this.setDefaultOptions(component,event);
                
            }
        }
        
    },
    /**
     * **********************************************************************************************************************
     * @Description
     * This method clear the hw field
     * **********************************************************************************************************************
     * @param	cmp		component passed from the controller	
     * **********************************************************************************************************************
     **/    
    clearHwVersionField : function(component,event) {
        
        var hwVersionField = component.find('InputHwVersion');
        if(typeof hwVersionField != 'undefined') {
            var hwValue = hwVersionField.get("v.value");
            if(hwValue != '')
                hwVersionField.set("v.value",'');
        }
        
    },
    /**
     * **********************************************************************************************************************
     * @Description
     * This method clear the sw field
     * **********************************************************************************************************************
     * @param	cmp		component passed from the controller	
     * **********************************************************************************************************************
     **/    
    clearSwVersionField : function(component,event) {
        var swVersionField = component.find('InputSwVersion');
        if(typeof swVersionField != 'undefined') {
            var swValue = swVersionField.get("v.value");
            if(swValue != '')
                swVersionField.set("v.value",'');
        }
        
    },
    /**
     * **********************************************************************************************************************
     * @Description
     * This method handles serial num change
     * **********************************************************************************************************************
     * @param	cmp		component passed from the controller	
     * **********************************************************************************************************************
     **/    
    
    handleSerialNumChange : function(component,event) {
        
        var assetList = component.get("v.assetWrapperList");
        var serialNumSelectList = component.find("InputSerialNumber");
        //var selectedSerialNum = serialNumSelectList.get("v.value");
        var serialNumText = component.find("InputSerialNumber1");
        console.log('selectedSerialNum'+selectedSerialNum);
        var i;
        //Clear Sw Hw fields
        this.clearSwVersionField(component,event);
        this.clearHwVersionField(component,event);
        
        //If serial created on the fly
        if(typeof(serialNumSelectList) == "undefined" && typeof(serialNumText)!="undefined"){
            var selectedSerialNum = serialNumText.get("v.value");
            if(!$A.util.isEmpty(selectedSerialNum)){
                component.set("v.showSerialSelect",false);
                component.set("v.showSerialText",true);
                var assetWrapInst = component.get("v.wrapperInstance");
                var serialNum = component.get("v.unknownSerialNum");
                var controlSys = component.get("v.selectedControlSys")
                assetWrapInst.status = "INSERT";
                assetWrapInst.serialNumber = serialNum;
                assetWrapInst.controlSys = controlSys;
                component.set("v.wrapperInstance",assetWrapInst);
                console.log("test");
            } else {
                var wrapperInstance = component.get("v.wrapperInstance");
                wrapperInstance.assetId = '';
                wrapperInstance.serialNumber = '';
                component.set('v.wrapperInstance',wrapperInstance);
            }
        }
        else {
            //If add new serial clicked
            var selectedSerialNum = serialNumSelectList.get("v.value");
            if(selectedSerialNum == "Add") {
                component.set("v.showSerialSelect",false);
                component.set("v.showSerialText",true);
            }
            else {
                //If Existing serial selected
                if(!$A.util.isEmpty(selectedSerialNum)) {
                    for (i = 0; i < assetList.length; i++) { 
                        if(assetList[i].assetId == selectedSerialNum){
                            var assetWrapInst = [];
                            var assetWrapInst = component.get("v.wrapperInstance");
                            
                            assetWrapInst.assetId = assetList[i].assetId;
                            assetWrapInst.prodId = assetList[i].prodId;
                            assetWrapInst.controlSys = assetList[i].controlSys;
                            assetWrapInst.componentName = assetList[i].componentName;
                            assetWrapInst.partNumber = assetList[i].partNumber;
                            assetWrapInst.serialNumber = assetList[i].serialNumber;
                            assetWrapInst.hwVersion = assetList[i].hwVersion;
                            assetWrapInst.swVersion = assetList[i].swVersion;
                            assetWrapInst.status = assetList[i].status;
                            assetWrapInst.minHwVersion = assetList[i].minHwVersion;
                            assetWrapInst.minSwVersion = assetList[i].minSwVersion;
                            component.set("v.wrapperInstance",assetWrapInst);
                            console.log('test');
                            break;
                        }
                        
                    } 
                } else {
                    var wrapperInstance = component.get("v.wrapperInstance");
                    wrapperInstance.assetId = '';
                    wrapperInstance.serialNumber = '';
                    component.set('v.wrapperInstance',wrapperInstance); 
                }
            }
        }
        
    },
    
})
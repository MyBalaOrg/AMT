// ****************************************************************************************************************
// Component: Display SObject Fields Component COntroller
// Author:  Nathan Shinn, Deloitte Digital
// Date:    Feb 14, 2017
// Description: Used to render SObject Fields on a page/Component
//
// Modifications: 
// 1.00: Created     
// ****************************************************************************************************************  

({
	doInit : function(component, event, helper) {
        //Get the Object and its values
		var varSobject = component.get("v.objSobject");
        var api = component.get("v.fieldapi");
        var arrayRecords = varSobject[api.split('.')[0]];
        
        //the object may be a lookup to a parent.
        if(arrayRecords != undefined && api.indexOf('.')>= 0)
        	component.set("v.fielvalue", arrayRecords[api.split('.')[1]]);
        else
            component.set("v.fielvalue", varSobject[api]);
	}
})
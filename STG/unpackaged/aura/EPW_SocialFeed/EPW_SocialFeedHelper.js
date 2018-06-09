({

    toggleHeader:function(component,event,secId){
    	var acc = component.find(secId);
        var compBody=component.find('compBody');
        for(var cmp in acc) {
            $A.util.toggleClass(acc[cmp], 'slds-show');  
            $A.util.toggleClass(acc[cmp], 'slds-hide'); 
            
        }
        $A.util.toggleClass(compBody, 'slds-show');
        $A.util.toggleClass(compBody, 'slds-hide');
	}
})
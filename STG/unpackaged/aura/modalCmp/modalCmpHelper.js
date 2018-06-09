({
    showModal: function(cmp) {
        var cmpTarget1, cmpTarget2, isShown;
        isShown = cmp.get('v.isShown')
        cmpTarget1 = cmp.find('modal-parent');
		cmpTarget2 = cmp.find('modal-backdrop');
        if(isShown == true) {
     		$A.util.addClass(cmpTarget1, 'slds-fade-in-open');
			$A.util.addClass(cmpTarget2, 'slds-backdrop--open');         
        } else {
     		$A.util.removeClass(cmpTarget1, 'slds-fade-in-open');
			$A.util.removeClass(cmpTarget2, 'slds-backdrop--open');            
        }        
    }
})
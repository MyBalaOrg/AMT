({
    getModalVal : function(cmp, event, helper) {
        var title, desc;

        title = event.getParam("title");        
        desc = event.getParam("desc");

        if(desc !== undefined) {
            console.log('Firing getModalVal');
            cmp.set('v.title', title);            
            cmp.set('v.description', desc);
            cmp.set('v.isShown', true);		
            helper.showModal(cmp);            
        }
         
	},
	showModal : function(cmp, evt, helper) {
        helper.showModal(cmp);
	},
    cancelModal: function(cmp, event, helper) {
        cmp.set('v.isShown', false);
        helper.showModal(cmp);
    }
})
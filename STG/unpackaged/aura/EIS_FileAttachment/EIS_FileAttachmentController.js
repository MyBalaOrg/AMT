({
    doInit : function(component, event, helper) {
        helper.fireToggleSpinnerEvent(component, false);
        helper.getDocumentList(component, "c.getContentDocumentLinkList", {"parentId" : component.get("v.parentId")});
        //Send LC Host as parameter to VF page so VF page can send message to LC; make it all dynamic
        component.set('v.lcHost', window.location.hostname);
        var frameSrc = '/apex/EIS_FileAttachmentPage?id=' + component.get('v.parentId') + '&lcHost=' + component.get('v.lcHost');
        component.set('v.frameSrc', frameSrc);

        //Add message listener
        window.addEventListener("message", function(event) {
            event.stopPropagation();
            event.preventDefault();
            if (event.data.parentId == component.get("v.parentId")) {
                if(event.data.state == 'LOADED'){
                    component.set('v.vfHost', event.data.vfHost);
                }
                
                if(event.data.state == 'uploadFileSelected'){
                    component.set("v.fileSelectedMsg", "1 file selected");
                }
                
                if(event.data.state == 'fileUploadProcessed'){
                    component.set("v.fileSelectedMsg", "");
                    if (!$A.util.isEmpty(event.data.documentList)) {
                        var documentList = JSON.parse(event.data.documentList);
                        component.set("v.documentList", documentList);
                    }
                    console.log("Upload Completed");
            	}
            }
            helper.fireToggleSpinnerEvent(component, true);
        }, false);
    },
        
    saveFile: function(component, event, helper) {
        helper.fireToggleSpinnerEvent(component, false);
        var message = {
            "uploadFile" : true
        };
        helper.sendMessageAction(component, message);
    },
    
    chooseFile : function(component, event, helper) {
        helper.fireToggleSpinnerEvent(component, false);
        var message = {
            "chooseFileToUpload" : true
        }
        helper.sendMessageAction(component, message);
    },
    
    deleteFile : function(component, event, helper) {
        helper.fireToggleSpinnerEvent(component, false);
        var targetDataset = event.currentTarget.dataset;
        if (!$A.util.isEmpty(targetDataset)) {
            var params = {"documentId" : targetDataset.documentId};
            helper.getDocumentList(component, "c.deleteContentDocumentWithId", params);
            
            var index = targetDataset.documentIndex;
            var documentList = component.get("v.documentList");
            documentList.splice(index, 1);
            component.set("v.documentList", documentList);
        }
    }
})
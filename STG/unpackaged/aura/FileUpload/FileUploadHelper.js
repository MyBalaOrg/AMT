({
    MAX_FILE_SIZE: '4500000',   /* Use a multiple of 4 */ 
    CHUNK_SIZE: '450000', /* Use a multiple of 4 */ 
    
    save : function(component) {  
        var fileInput = component.find("file").getElement();
        var file = fileInput.files[0]; 
        var self = this;
        if (file.size > this.MAX_FILE_SIZE) {
            var msg = 'File size cannot exceed ' + this.MAX_FILE_SIZE + ' bytes.\n' + 'Selected file size: ' + file.size;
            self.showErrorMsg(component,msg);
            return;
        }        
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");        
        var fr = new FileReader();
        
        
        fr.onload = $A.getCallback(function() {
            var fileContents = fr.result;
            var base64Mark = 'base64,';
            var dataStart = fileContents.indexOf(base64Mark) + base64Mark.length;
            
            fileContents = fileContents.substring(dataStart);
            
            self.upload(component, file, fileContents);
        });
        
        fr.readAsDataURL(file);
    },
    
    upload: function(component, file, fileContents) {
        var fromPos = 0;
        var toPos = Math.min(fileContents.length, fromPos + this.CHUNK_SIZE);
        
        // start with the initial chunk
        this.uploadChunk(component, file, fileContents, fromPos, toPos, '');   
    },
    
    uploadChunk : function(component, file, fileContents, fromPos, toPos, attachId) {
        var action = component.get("c.saveTheChunk"); 
        var chunk = fileContents.substring(fromPos, toPos);
        
        action.setParams({
            parentId: component.get("v.parentId"),
            fileName: file.name,
            base64Data: encodeURIComponent(chunk), 
            contentType: file.type,
            fileId: attachId
        });
        
        var self = this;
        action.setCallback(this, function(a) {
            var state = a.getState();
            
            if (state === "SUCCESS") {
                attachId = a.getReturnValue();
                component.set("v.message","");
                fromPos = toPos;
                toPos = Math.min(fileContents.length, fromPos + self.CHUNK_SIZE);
                
                if (fromPos < toPos) {
                    self.uploadChunk(component, file, fileContents, fromPos, toPos, attachId);  
                }else{
                    var spinner = component.find("mySpinner");
                    $A.util.addClass(spinner, "slds-hide");
                    self.showSuccessMsg(component);
                }
            } else if (state === "INCOMPLETE") {
                msg = "An error occured. Please contact administrator.";
                self.showErrorMsg(component,msg);
            } else if (state === "ERROR") {
                msg = "An error occured. Please contact administrator.";
                self.showErrorMsg(component,msg);  
            }
        });
        $A.enqueueAction(action); 
    },
    
    showSuccessMsg : function(component) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "message": "Image uploaded successfully.",
            "type" : "success"
        });
        var fileInput = component.find("file").getElement();
        var fileName = fileInput.value = '';
        component.set("v.fileChosen", "No file chosen");
        toastEvent.fire();
    },
    
    showErrorMsg : function(component,msg) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Error!",
            "message": msg,
            "type" : "error"
        });
        var fileInput = component.find("file").getElement();
        var fileName = fileInput.value = '';
        component.set("v.fileChosen", "No file chosen");         
        toastEvent.fire();
    },    
})
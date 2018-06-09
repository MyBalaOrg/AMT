({
   openModel: function(component, event, helper) {
      // for Display Model,set the "isOpen" attribute to "true"
      component.set("v.isOpen", true);
   },
 
   closeModel: function(component, event, helper) {
      // for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
      component.set("v.isOpen", false);
   },
 
   exportSelectedEntity: function(component, event, helper) {
      
      var selectedEmp = component.get("v.selectedEmployee");
      var positionId = selectedEmp.position.Position_ID__c;
      var positionLevel = selectedEmp.position.Position_Level__c;
      var levelField = component.find("level_select");
      var levelSelected = levelField.get("v.value");
      var lowestLevel = parseInt(levelSelected) + parseInt(positionLevel);
      var exportFilter1 = $A.get("$Label.c.OC_ExportList_Filter1");
      var exportFilter2 = $A.get("$Label.c.OC_ExportList_Filter2");
      var exportFilter3 = $A.get("$Label.c.OC_ExportList_Filter3");
      var reportLink = $A.get("$Label.c.OC_ExportList_URL");
      var fullReportURL = reportLink+
          exportFilter1+
          positionId+
          exportFilter2+
          positionLevel+
          exportFilter3+
          lowestLevel;
      
      console.log(fullReportURL);
       
      if(typeof sforce !== 'undefined'){
      var urlEvent = $A.get("e.force:navigateToURL");
      urlEvent.setParams({
       "url":fullReportURL
      });
      urlEvent.fire();
     }
       else{
           window.open(fullReportURL,'_blank');
       }
   component.set("v.isOpen", false);
   },
})
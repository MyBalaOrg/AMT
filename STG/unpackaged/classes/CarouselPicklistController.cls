/**
*___________________________________________________
*@Name: CarouselPicklistController
*@Author: Tejas
*@Created: Date: 11/5/2017
*@Used_By: Amtrak_Carousal_Slieder component inside Community builer 
*___________________________________________________
*@Description: Used by community builer designer to set picklist values of application field of Amtrak_Carousal_Slider component 
*___________________________________________________
*@Changes: 
* 
**/
global class CarouselPicklistController extends VisualEditor.DynamicPickList{
    
    /**
    *------------------------------------------
    * @Name: getDefaultValue
    * @Description
    * creates default value for application picklist field
    *------------------------------------------
    * @param    
    * @return   VisualEditor.DataRow		Default value
    *------------------------------------------
    **/ 
    global override VisualEditor.DataRow getDefaultValue(){
        VisualEditor.DataRow defaultValue = new VisualEditor.DataRow('', '');
        return defaultValue;
    }
    
    /**
    *------------------------------------------
    * @Name: getValues
    * @Description
    * creates picklist values for application picklist field
    *------------------------------------------
    * @param    
    * @return   	VisualEditor.DynamicPickListRows				picklist values for application picklist field
    *------------------------------------------
    **/ 
    global override VisualEditor.DynamicPickListRows getValues() {
        VisualEditor.DynamicPickListRows  applicationValues = new VisualEditor.DynamicPickListRows();
        List<Schema.PicklistEntry> availableApplications = Carousel__c.Application__c.getDescribe().getPicklistValues();
        if(availableApplications != null && availableApplications.size() > 0) {
            for(Schema.PicklistEntry eachApplication : availableApplications) {
                applicationValues.addRow(new VisualEditor.DataRow(eachApplication.getLabel(), eachApplication.getValue()));
            }
        }
        return applicationValues;
    }
}
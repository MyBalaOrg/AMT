/**
*————————————————————————————————————————————————————
* @Name             FieldSetMemberWrapper
* @Author           Boom Bertetti
* @Created Date     1/26/2018
* @Used By          LightningFieldSetHandler
*————————————————————————————————————————————————————
* @Description
* Common wrapper class contains fieldset properties to be used in lightning component
* (which not currently support fielset binding)
*————————————————————————————————————————————————————
* @Changes
**/
public class FieldSetMemberWrapper {
    @AuraEnabled
    public Boolean dbRequired { get; set; }

    @AuraEnabled
    public String fieldPath { get; set; }

    @AuraEnabled
    public String label { get; set; }

    @AuraEnabled
    public Boolean required { get; set; }

    @AuraEnabled
    public String fieldType { get; set; }

    public FieldSetMemberWrapper(Schema.FieldSetMember f) {
        this.dbRequired = f.DBRequired;
        this.fieldPath  = f.fieldPath;
        this.label      = f.label;
        this.required   = f.required;
        this.fieldType  = String.valueOf(f.getType());
    }
}
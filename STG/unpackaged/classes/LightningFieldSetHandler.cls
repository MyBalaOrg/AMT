/**
*————————————————————————————————————————————————————
* @Name             LightningFieldSetHandler
* @Author           Boom Bertetti
* @Created Date     1/26/2018
* @Used By          Any Lightning Controller that uses fieldset
*————————————————————————————————————————————————————
* @Description
* A handler class that extracts fieldset properties to be used in lightning component
*————————————————————————————————————————————————————
* @Changes
**/
public abstract class LightningFieldSetHandler {
    @AuraEnabled
    public static List<FieldSetMemberWrapper> getFields(String typeName, String fsName) {
        Schema.SObjectType targetType         = Schema.getGlobalDescribe().get(typeName);
        Schema.DescribeSObjectResult describe = targetType.getDescribe();
        Map<String, Schema.FieldSet> fsMap    = describe.fieldSets.getMap();
        Schema.FieldSet fs                    = fsMap.get(fsName);
        if (fs != null) {
            List<Schema.FieldSetMember> fieldSet  = fs.getFields();
            List<FieldSetMemberWrapper> fset      = new List<FieldSetMemberWrapper>();
            for (Schema.FieldSetMember f: fieldSet) {
                fset.add(new FieldSetMemberWrapper(f));
            }
            return fset;
        }
        else {
            return null;
        }
    }


}
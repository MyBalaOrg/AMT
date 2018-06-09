/**
*————————————————————————————————————————————————————
* @Name             AMTRAK_Case_RecordTypeCheck
* @Author           Duy Tran
* @Created Date     10-20-2017
* @Used By          AMTRAK_Case_NewButton.cmp
					AMTRAK_Case_EditButton.cmp
*————————————————————————————————————————————————————
* @Description
* Controller class to generate and handle Record Type values for Lightning components
* to be used in Case Buttons
*————————————————————————————————————————————————————
* @Changes
*
**/
public with sharing class AMTRAK_Case_RecordTypeCheck {
    
/**
*————————————————————————————————————————————————————
* @Description
* Determine if current Record Type for Case should be used in ODILR
*————————————————————————————————————————————————————
* @param    recordTypeId          	Record Type Id
* @return   Map<String, String>     Data to populate lightning component and error messages
*————————————————————————————————————————————————————
**/
	@AuraEnabled
    public static Map<String, String> verifyAppNameForCase_New(String recordTypeId) {
        Map<String, String> response = new Map<String, String>();
        try {
            String recordTypeName = '';
            String appName = '';
            if (String.isBlank(recordTypeId)) {
                List<Schema.RecordTypeInfo> infos = Case.SObjectType.getDescribe().getRecordTypeInfos();
                System.debug(infos);
                if (infos.isEmpty()) {
                    response.put('errorMsg', 'You do not have access to any record type.');
                    return response;
                } else {
                    for (Schema.RecordTypeInfo info : infos) {
                        if (info.isAvailable() && !info.isMaster()) {
                            response.put('recordTypeId', info.getRecordTypeId());
                        	recordTypeName = info.getName();
                            break;
                        }
                    }
                    if (String.isEmpty(recordTypeName)) {
                        response.put('errorMsg', 'You do not have access to any record type.');
                    	return response;
                    }
                }
            } else {
                recordTypeName = [SELECT Name FROM RecordType WHERE Id = :recordTypeId].Name;
            }
            if (recordTypeName.equalsIgnoreCase(Label.ODILR_Discipline_Record_Type) || recordTypeName.equalsIgnoreCase(Label.ODILR_Claims_Record_Type)) {
                appName = 'ODILR';
            }
            
            response.put('appName', appName);
            response.put('recordTypeName', recordTypeName);
        } catch (DmlException e) {
            response.put('errorMsg', e.getDmlMessage(0));
        } catch (Exception e) {
            response.put('errorMsg', e.getMessage());
        }
        return response;
    }

/**
*————————————————————————————————————————————————————
* @Description
* Determine if current Record Type for Case should be used in ODILR
*————————————————————————————————————————————————————
* @param    recordId          		Record Id
* @return   Map<String, String>     Data to populate lightning component and error messages
*————————————————————————————————————————————————————
**/
    @AuraEnabled
    public static Map<String, String> verifyAppNameForCase_Edit(String recordId) {
        Map<String, String> response = new Map<String, String>();
        try {
            String appName = '';
            String recordTypeName = [SELECT RecordType.Name FROM Case WHERE Id = :recordId].RecordType.Name;
            if (recordTypeName.equalsIgnoreCase(Label.ODILR_Discipline_Record_Type) || recordTypeName.equalsIgnoreCase(Label.ODILR_Claims_Record_Type)) {
                appName = 'ODILR';
            }
            
            response.put('appName', appName);
            response.put('recordTypeName', recordTypeName);
        } catch (DmlException e) {
            response.put('errorMsg', e.getDmlMessage(0));
        } catch (Exception e) {
            response.put('errorMsg', e.getMessage());
        }
        return response;
    }
}
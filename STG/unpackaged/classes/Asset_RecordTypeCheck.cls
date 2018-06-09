public with sharing class Asset_RecordTypeCheck {
    
    @AuraEnabled
    public static Map<String, String> verifyAppNameForAsset_New(String recordTypeId) {
        Map<String, String> response = new Map<String, String>();
        try {
            String recordTypeName = '';
            String appName = '';
            if (String.isBlank(recordTypeId)) {
                List<Schema.RecordTypeInfo> infos = Asset.SObjectType.getDescribe().getRecordTypeInfos();
                System.debug(infos);
                if (infos.isEmpty()) {
                    response.put('errorMsg', 'No Record Type');
                    return response;
                } else {
                    Schema.RecordTypeInfo master = null;
                    for (Schema.RecordTypeInfo info : infos) {
                        SYSTEM.debug('info.isAvailable()'+info.isAvailable());
                        if (info.isAvailable() && !info.isMaster()) {
                            response.put('recordTypeId', info.getRecordTypeId());
                            system.debug('@@recordTypeId@@'+info.getRecordTypeId());
                            recordTypeName = info.getName();
                            break;
                        }
                        if (info.isMaster()) {
                            master = info;
                            system.debug('master==='+master);
                        }
                    }
                    if (String.isEmpty(recordTypeName)) {
                        if (master.isAvailable()) {
                            response.put('recordTypeId', master.getRecordTypeId());
                            
                            system.debug('MASTER recordTypeId==='+master.getRecordTypeId());
                            recordTypeName = master.getName();
                            response.put('recordTypeName',recordTypeName);
                            system.debug('recordTypeName===='+recordTypeName);
                        } else {
                            response.put('errorMsg', 'No Record Type');
                            //system.debug('errorMsg==='+errorMsg);
                        }
                        system.debug('response======='+response.get(recordTypeId));
                        //   system.debug('response======='+response.get(recordTypeId));
                        return response;
                    }
                }
            } else {
                recordTypeName = [SELECT Name FROM RecordType WHERE Id = :recordTypeId].Name;
            }
            if (recordTypeName.equalsIgnoreCase('PTC') ) {
                appName = Label.App_Name_PTC;
            }
            
            response.put('appName', appName);
            response.put('recordTypeName', recordTypeName);
            system.debug('appName==='+appName);
            system.debug('recordTypeName------'+recordTypeName);
        } catch (DmlException e) {
            response.put('errorMsg', e.getDmlMessage(0));
        } catch (Exception e) {
            response.put('errorMsg', e.getMessage());
        }
        system.debug('response 2======='+response);
        return response;
    }
}
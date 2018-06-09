/**
*___________________________________________________
*@Name: EPW_CustomRichContentController
*@Author: Tejas Khamakar
*@Created: Date: 12/21/2017
*@Used_By: COE_customRichContentCmp ligtning component
*___________________________________________________
*@Description: used by COE_customRichContentCmp ligtning component
*___________________________________________________
**/

public class EPW_CustomRichContentController {
	  /**
    *————————————————————————————————————————————————————
    * @Name: getRichTextContent
    * @Description
    * fetches record of specified object along with specified field and filters by appication name
    *————————————————————————————————————————————————————
    * @param -  application					application name
    * 			objectName					sobject name
    * 			fieldName					field name
    * 			recordTypeName				record type name of selected object type
    * 			title						title value for Title__c field of selected object type
    * @return - SObject						queried record
    *————————————————————————————————————————————————————
    **/ 
    @AuraEnabled
    public static SObject getRichTextContent(String application, String objectName, String fieldName, String recordTypeName, String title) {
        SObject record = null;
        if(!String.isEmpty(application) && !String.isEmpty(objectName) && !String.isEmpty(fieldName) && !String.isEmpty(recordTypeName) && !String.isEmpty(title)) {
            Id recordTypeID = Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
            DateTime currentDateTime = DateTime.now();
            String query = 'SELECT Image__c, RecordTypeId, ' + fieldName + 
                            ' FROM ' + objectName + 
                            ' WHERE Application__c = \'' + application + '\'' +
                			' AND RecordTypeId = \'' + recordTypeID + '\'' +
                			' AND Title__c = \'' + title + '\'' +
                			'AND IsActive__c = true ORDER BY LastModifiedDate LIMIT 1 ';
            ////Add ORDER BY LAST MODIFIED DATE
            ////ADD LIMIT 1
            ////KEEP ACTIVE
            ////EXPLORE Dynamic tiles
            List<SObject> results = Database.query(query);

            System.debug(query);
            if(results != null && results.size() > 0) {
                record = results[0];
            }
        }
        return record;
    }

}
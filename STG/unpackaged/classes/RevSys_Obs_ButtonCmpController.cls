/**
*___________________________________________________
*@Name: RevSys_Obs_ButtonController
*@Author: Hemanth Kesapragada
*@Created: Date: 03/15/2018
*@Used_By: RevSys_Obs_ButtonsCmp.cmp
*___________________________________________________
*@Description: 
* Query and process data to be populated on the Lightning component.
*
*___________________________________________________
*@Changes: 
**/
public class RevSys_Obs_ButtonCmpController {


	/**
    *————————————————————————————————————————————————————
    * @Name: checkPermission
    * @Description
    * AuraEnabled - Instantiates the record in the RevSys_Obs_BUttonsCmp
    *————————————————————————————————————————————————————
    * @param    empCertId   ID of the employeeCertification record
    * @return   Map<String,String>  Checks if the logged in user has access to the button
    *————————————————————————————————————————————————————
    **/
	@AuraEnabled
    public static Map<String, String> checkPermission() {
    	System.debug('AURAENABLED RevSys_Obs_ButtonController.checkPermission() START');
        
        Map<String, String> response = new Map<String, String>();
        
        //get profile name of logged in user
        Id profileId = userinfo.getProfileId();
        String profileName = [Select Id, Name from Profile where Id = :profileId].Name;
        
        Boolean hasPermission = false;

        //get permission set csv from custom setting
        String permissionSetCsv;
        REVSYS_Custom_Settings__c cs = REVSYS_Custom_Settings__c.getValues('Enable Observation Soft Delete');
        if(cs!=null && String.isNotBlank(cs.CsvString__c)) {

              permissionSetCsv = cs.CsvString__c;
        } 
      
        if(profileName.equalsIgnoreCase('System Administrator')) {
            system.debug('*** profileName : ' + profileName);
            hasPermission = true;
        }
        else {
            system.debug('*** profileName Oters : ' + profileName);
            if(permissionSetCsv != null && permissionSetCsv.length() > 0){
                
                list<String> permissionSetAPIs = permissionSetCsv.split(',');
                
                //get list of all permission set assigned to user
                List<PermissionSetAssignment> permissionSetList = [SELECT Id, PermissionSet.Name, AssigneeId 
                                                                   FROM PermissionSetAssignment 
                                                                   WHERE AssigneeId = :userinfo.getUserId() limit 1000];
                system.debug('*** permissionSetList' + permissionSetList);
                
                if(permissionSetList != null && permissionSetList.size() > 0){
                    for(PermissionSetAssignment permissionSetAssign : permissionSetList){
                        
                        if(permissionSetAPIs.contains(permissionSetAssign.PermissionSet.Name)){
                            hasPermission = true;
                            break;
                        } else {
                            hasPermission = false;
                        }
                        
                    }
                }
            } 
        }
        system.debug('*** hasPermission : ' + hasPermission);
        response.put('hasPermission', JSON.serialize(hasPermission));
    	System.debug('AURAENABLED RevSys_Obs_ButtonController.checkPermission() END');
        return response;
    }

    /**
    *————————————————————————————————————————————————————
    * @Name: softDeleteObservation
    * @Description
    * AuraEnabled - Instantiates the record in the RevSys_Obs_BUttonsCmp
    *————————————————————————————————————————————————————
    * @param    observationId   ID of the observation reocrd.
    * @return   Map<String,String>  changes the status and returns success message
    *————————————————————————————————————————————————————
    **/
    @AuraEnabled
    public static Map<String, String> softDeleteObservation(Id observationId) {
        System.debug('AURAENABLED RevSys_Obs_ButtonController.softDeleteObservation() START');
        
        Map<String, String> response = new Map<String, String>();
        system.debug('*** observationId : ' + observationId);
        if(String.isNotBlank(observationId)) {
            SelectorWrapper wrapper = ObservationSelector.getObservationsbyId(new Set<Id>{observationId});
            if(String.isBlank(wrapper.ErrorMessage) && wrapper.SObjectList.size() > 0) {
                //Since we are fetcing on the basis of ID
                Observation__c obs = ((List<Observation__c>) wrapper.SobjectList).get(0);
                system.debug('*** obs : ' + obs);
                Savepoint sp = Database.setSavepoint();
                obs.Status__c = Label.RevSys_Generic_Removed;
                try {
                    update obs;
                    response.put('success','Record updated successfully');
                } catch (Exception e) {
                    Database.rollback(sp);
                    response.put('errorMsg', e.getMessage());
                    response.put('consolelog', e.getStackTraceString());
                    System.debug(e.getStackTraceString());
                }
            } else {
                response.put('errorMsg',wrapper.ErrorMessage);
                response.put('consoleLog',wrapper.ErrorMessage);
            }
        } else {
            response.put('errorMsg','Error fetching the observation');
        }
        
        
        System.debug('AURAENABLED RevSys_Obs_ButtonController.checkPermission() END');
        return response;
    }

    /**
    *————————————————————————————————————————————————————
    * @Name: searchTest
    * @Description
    * Search and populate wrapper object with OSR information
    *————————————————————————————————————————————————————
    * @param    params                  Map of values retrieved from Lightning Component
    * @return   Map<String, String>     Map of response values to be used by Lightning Component
    *————————————————————————————————————————————————————
    **/ 
    @AuraEnabled
    public static Map<String, String> searchTest(Map<String, String> params) {
        Map<String, String> response = new Map<String, String>();
        try {
            Observation__c obs;
            String whereClause = '';


            whereClause += ' AND RecordTypeId = \'' + RevSys_StaticUtility.OCCSPECREQUIREMENT_DEPTCERT_FOR_OBS_RECTYPE_ID + '\' ';
            whereClause += ' AND Status__c = \'' + Label.SPARTN_Generic_Status_Active + '\' ';
            if (String.isNotBlank(params.get('observationId'))) {
                String observationId = String.escapeSingleQuotes(params.get('observationId'));
                obs = [SELECT Id, Craft__c, Department__c FROM Observation__c WHERE Id = :observationId];
                whereClause += ' AND ObservationDepartment2__c = \'' + obs.Department__c + '\'';
                whereClause += ' AND ( ObservationCraft2__c = \'All\' OR  ObservationCraft2__c = \'' + obs.Craft__c + '\') ';
            }
            // Setting up conditional statement for Name
            if (String.isNotBlank(params.get('searchKey'))) {
                String searchKey = String.escapeSingleQuotes(params.get('searchKey'));
                for (String keyWord : searchKey.split(' ')) {
                    whereClause += ' AND (Observation__r.TestNumber__c LIKE \'%' + keyWord + '%\' OR Observation__r.TestName__c LIKE \'%' + keyWord + '%\')';
                }
            }
            System.debug('=====> whereClause: ' + whereClause);
            whereClause = whereClause.removeStart(' AND');
            if (String.isNotBlank(whereClause)) {
                whereClause += ' AND';
            }
            
            String query = 'SELECT Id,ObservationDepartment2__c, ObservationCraft2__c, Observation__r.TestNumber__c, Observation__r.TestName__c, Observation__r.SpeedCheckMethod__c, Observation__r.Check_Method_Required__c FROM OccupationSpecificRequirement__c';
            if (String.isNotBlank(whereClause)) {
                query += ' WHERE ' + whereClause.removeEnd(' AND');
            }
            query += ' ORDER BY Observation__r.TestNumber__c LIMIT 500';
            System.debug('search query : ' + query);
            
            List<OccupationSpecificRequirement__c> osrList = Database.query(query);
            if (osrList != null && osrList.size() >= 500) {
                response.put('limitBreak', 'There are over 500 results returned. Please make your search more specific for better results.');
            }
            List<SearchTabularItemWrapper> resultList = new List<SearchTabularItemWrapper>();
            for (OccupationSpecificRequirement__c osr : osrList) {
                SearchTabularItemWrapper item = new SearchTabularItemWrapper();
                item.selected = false;
                item.recordId = osr.Id;
                item.fieldNames = new List<String>{'Observation__r.TestNumber__c', 'Observation__r.TestName__c'};
                item.fieldValues = new List<String>();
                item.fieldValues.add(osr.Observation__r.TestNumber__c);
                item.fieldValues.add(osr.Observation__r.TestName__c);

                resultList.add(item);
            }
            response.put('resultList', JSON.serialize(resultList));
            response.put('fieldLabels', JSON.serialize(new List<String>{'Test Number', 'Test Name'}));
        } catch(QueryException qe) {

            response.put('errorMsg', qe.getMessage());
            response.put('consolelog', qe.getStackTraceString());
            System.debug(qe.getStackTraceString());
            System.debug('Error query: ' + qe.getMessage());
        } catch (Exception e) {
            response.put('errorMsg', e.getMessage());
            response.put('consolelog', e.getStackTraceString());
            System.debug('general exception: ' + e.getMessage());
            System.debug(e.getStackTraceString());
        }
        
        return response;
    }

    /**
    *————————————————————————————————————————————————————
    * @Name: updateObservationTest
    * @Description
    * AuraEnabled - Update Observation Occupation Specifc Requirement
    *————————————————————————————————————————————————————
    * @param    params   parameters passed from Lightning Component, contains Observation Id and OSR Id
    * @return   Map<String,String>  changes the OSR Id and returns success message
    *————————————————————————————————————————————————————
    **/
    @AuraEnabled
    public static Map<String, String> updateObservationTest(Map<String, String> params) {
        System.debug('AURAENABLED RevSys_Obs_ButtonController.updateObservationTest() START');
        
        Map<String, String> response = new Map<String, String>();
        if (String.isNotBlank(params.get('observationId'))) {
            String observationId = params.get('observationId');
            if (String.isNotBlank(params.get('osrId'))) {
                String osrId = params.get('osrId');
                
                SelectorWrapper wrapper = ObservationSelector.getObservationsbyId(new Set<Id>{observationId});
                if(String.isBlank(wrapper.ErrorMessage) && wrapper.SObjectList.size()>0) {
                    system.debug('*** wrapper : ' + wrapper);
                    //Since we are fetcing on the basis of ID
                    Observation__c obs = ((List<Observation__c>) wrapper.SobjectList).get(0);
                    system.debug('*** obs : ' + obs);
                    Savepoint sp = Database.setSavepoint();
                    obs.OccupationSpecificRequirement__c = osrId;
                    try {
                        update obs;
                        response.put('success','Record updated successfully');
                    } catch (Exception e) {
                        Database.rollback(sp);
                        response.put('errorMsg', e.getMessage());
                        response.put('consolelog', e.getStackTraceString());
                        System.debug(e.getStackTraceString());
                    }
                } else {
                    response.put('errorMsg',wrapper.ErrorMessage);
                    response.put('consoleLog',wrapper.ErrorMessage);
                }
            } else {
                response.put('errorMsg','Error fetching the Test');
            }
        } else {
            response.put('errorMsg','Error fetching the observation');
        }
        
        
        System.debug('AURAENABLED RevSys_Obs_ButtonController.updateObservationTest() END');
        return response;
    }

}
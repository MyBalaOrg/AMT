/**
*___________________________________________________
*@Name: RevSys_EmpCert_RecordDetailController
*@Author: Hemanth Kesapragada
*@Created: Date: 01/11/2017
*@Used_By: RevSys_EmpCert_ButtonsCmp.cmp
*___________________________________________________
*@Description: 
* Query and process data to be populated on the Lightning component.
*
*___________________________________________________
*@Changes: 
**/
public with sharing class RevSys_EmpCert_RecordDetailController {
    public static Boolean DoFailFlag = FALSE;
	/**
    *————————————————————————————————————————————————————
    * @Name: getEmpCertifications
    * @Description
    * AuraEnabled - Instantiates the record in the RevSys_EmpCert_BUttonsCmp
    *————————————————————————————————————————————————————
    * @param    empCertId   ID of the employeeCertification record
    * @return   EmployeeCertification__c Details of the EC Record
    *————————————————————————————————————————————————————
    **/
	@AuraEnabled
    public static Map<String, String> getEmpCertifications(Id empCertId) {
    	System.debug('AURAENABLED RevSys_EmpCert_RecordDetailController.getEmpCertifications() START');
        
        Map<String, String> response = new Map<String, String>();
        
        //get profile name of logged in user
        Id profileId = userinfo.getProfileId();
        String profileName = [Select Id, Name from Profile where Id = :profileId].Name;
        
        Boolean hasPermission = true;
        if(profileName != 'System Administrator'){

            //get permission set csv from custom setting
            String permissionSetCsv;
            REVSYS_Custom_Settings__c cs = REVSYS_Custom_Settings__c.getValues('Hide Employee Certification Buttons');
            if(cs!=null && String.isNotBlank(cs.CsvString__c)) {

                  permissionSetCsv = cs.CsvString__c;
            } 
          
            
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
                            hasPermission = false;
                            break;
                        }
                        
                    }
                }
                system.debug('*** hasPermission : ' + hasPermission);
                response.put('hasPermission', JSON.serialize(hasPermission));
            }
        } else {
            response.put('hasPermission', JSON.serialize(true));
        }
        
        EmployeeCertification__c ecRecord = new EmployeeCertification__c();

        ecRecord = getEmployeeCertification(empCertId);
        
        response.put('ecRecord', JSON.serialize(ecRecord));
        response.put('sessionId',UserInfo.getSessionId());
        
    	System.debug('AURAENABLED RevSys_EmpCert_RecordDetailController.getEmpCertifications() END');
        return response;
    }

    /**
    *————————————————————————————————————————————————————
    * @Name: getEmpCertifications
    * @Description
    * AuraEnabled - Instantiates the record in the RevSys_EmpCert_BUttonsCmp
    *————————————————————————————————————————————————————
    * @param    empCertId   ID of the employeeCertification record
    * @return   EmployeeCertification__c Details of the EC Record
    *————————————————————————————————————————————————————
    **/
	@AuraEnabled
    public static Map<String, String> saveLastPrintedDetails(Id empCertId) {
    	System.debug('AURAENABLED RevSys_EmpCert_RecordDetailController.saveLastPrintedDetails() START');
    	Map<String, String> response = new Map<String, String>();	
        
        EmployeeCertification__c ecRecordToUpdate = getEmployeeCertification(empCertId);
        
        SelectorWrapper wrapper = EmployeeSpecificRequirementSelector.getEmployeeSpecificRequirementsFrmEmpCert(new Set<Id>{ecRecordToUpdate.id});
        if(wrapper!=null && String.isBlank(wrapper.errorMessage)) {
            List<EmployeeSpecificRequirement__c> esrList = (List<EmployeeSpecificRequirement__c>)wrapper.sObjectList;
			for(EmployeeSpecificRequirement__c esrObj : esrList)
            {
                if(esrObj.Source__c.equalsIgnoreCase(Label.RevSys_Generic_Observation))
                {
                    if(ecRecordToUpdate.CertificationType__c.equalsIgnoreCase(Label.RevSys_ClassOfService_Conductor) && esrObj.SourceRecordType__c.equalsIgnoreCase(Label.RevSys_Observation_RT_Label_Test_1877))
                    {
                        ecRecordToUpdate.LastRideDate__c = esrObj.LastFulfilledDate__c;
                    }
                    if(ecRecordToUpdate.CertificationType__c.equalsIgnoreCase(Label.RevSys_ClassOfService_StudentEngineer) && esrObj.SourceRecordType__c.equalsIgnoreCase(Label.RevSys_Observation_RT_Label_Test_1876))
                    {
                        ecRecordToUpdate.LastRideDate__c = esrObj.LastFulfilledDate__c;
                    }
                    if(ecRecordToUpdate.CertificationType__c.equalsIgnoreCase(Label.RevSys_ClassOfService_Engineer) && esrObj.SourceRecordType__c.equalsIgnoreCase(Label.RevSys_Observation_RT_Label_Test_1875))
                    {
                        ecRecordToUpdate.LastRideDate__c = esrObj.LastFulfilledDate__c;
                    }
                }
                else if(esrObj.Source__c.equalsIgnoreCase(Label.RevSys_ESR_Source_Emp_Result_Summary) && esrObj.SourceRecordType__c.equalsIgnoreCase(Label.RevSys_ESR_Medical_Hearing_and_Vision))
                {
                    if(String.isNotBlank(esrObj.SourceTestType__c) && esrObj.SourceTestType__c.equalsIgnoreCase(Label.RevSys_Generic_Vision_Test))
                    {
                        ecRecordToUpdate.VisionRestrictions__c = esrObj.Restrictions__c;
                    }
                    if(esrObj.SourceTestType__c.equalsIgnoreCase(Label.RevSys_Generic_Hearing_Test))
                    {
                        ecRecordToUpdate.HearingRestrictions__c = esrObj.Restrictions__c;
                    }
                }
            }
        }
    	
        Savepoint sp = Database.setSavepoint();
    	ecRecordToUpdate.LastPrintedDate__c = System.today();
    	ecRecordToUpdate.LastPrintedBy__c = UserInfo.getName();
    	try {
            if(Test.isRunningTest() && doFailFlag) {
                ecRecordToUpdate = null;
            }
    		update ecRecordToUpdate;
    		response.put('empCert', JSON.serialize(ecRecordToUpdate));
            
    	} catch (Exception e) {
            Database.rollback(sp);
            response.put('errorMsg', e.getMessage());
            response.put('consolelog', e.getStackTraceString());
            System.debug(e.getStackTraceString());
        }
        
    	
    	System.debug('AURAENABLED RevSys_EmpCert_RecordDetailController.saveLastPrintedDetails() END');
    	return response;
    }

    @AuraEnabled
    public static Map<String, String> validateCertification(Map<String, String> params) {
        System.debug('AURAENABLED RevSys_EmpCert_RecordDetailController.validateCertification() START');
        Map<String, String> response = new Map<String, String>();
        Boolean oldArchivedStatus=false;
        String certificateNumber = '';
        try{
            System.debug(params);
            if(params!=null && String.isNotBlank(params.get('empCertRecord'))) {
                EmployeeCertification__c ecRecord  = (EmployeeCertification__c) JSON.deserialize(params.get('empCertRecord'),EmployeeCertification__c.class);
                System.debug('Old Archived Status '+ecRecord.Archived__c);
                certificateNumber = ecRecord.CertificationNumber__c;
                oldArchivedStatus = ecRecord.Archived__c;
                List<EmployeeCertification__c> ecList = new List<EmployeeCertification__c>{ecRecord};
                String errMsg;
                //String errMsg = RevSys_EmployeeCertificationHelper.validateCertification(ecList);

                List<RevSys_EmployeeCertificationHelper.EmployeeCertificationWrapper> ecWrapperList = RevSys_EmployeeCertificationHelper.validateCertification(ecList);
                List<EmployeeCertification__c> ecToProcessList = new List<EmployeeCertification__c>();
                RevSys_EmployeeCertificationHelper.EmployeeCertificationWrapper wrapper;
                if(ecWrapperList!=null) {
                    System.debug('$$ response '+ecWrapperList);
                    wrapper= ecWrapperList.get(0);
                    if(wrapper.hasError) {
                        errMsg = wrapper.errorMsg;
                        response.put('errorMsg', wrapper.errorMsg);
                    } else {
                        errMsg = RevSys_EmployeeCertificationHelper.updateCertification(new List<EmployeeCertification__c>{wrapper.ecRecord});
                    }
                }

                if(String.isNotBlank(errMsg)) {
                   response.put('errorMsg', errMsg);
                } else {
                    EmployeeCertification__c updatedEC =  new EmployeeCertification__c();
                    EmployeeCertification__c newEC =  new EmployeeCertification__c();
                    SelectorWrapper newSelectorWrapper = EmployeeCertificationSelector.getAllEmployeeCertification(new Set<Id>{ecRecord.Id});
                    if(newSelectorWrapper!=null && String.isBlank(newSelectorWrapper.ErrorMessage)) {
                        List<EmployeeCertification__c> updatedEcList = (List<EmployeeCertification__c>)newSelectorWrapper.sObjectList;
                        if(updatedEcList!=null && !updatedEcList.isEmpty()) {
                            updatedEC= updatedEcList.get(0);
                            if(oldArchivedStatus!=updatedEC.Archived__c && updatedEC.Archived__c==true) {
                                System.debug('**** EC Updated oldArchivedStatus'+oldArchivedStatus+' updatedEC.Archived__c '+updatedEC.Archived__c);
                                newEC = getLatestCertificationRecord(updatedEC.CertificationNumber__c);
                            }
                        }
                    } else {
                         System.debug('**** newSelectorWrapper '+newSelectorWrapper.ErrorMessage);
                    }
                    response.put('successMsg',System.Label.RevSys_EmpCert_Certify_Success);
                    if(newEC!=null) {
                    System.debug('**** redirectId '+newEC.Id);
                      response.put('redirectId',newEC.Id);  
                    }
                }
            } else {
                response.put('errorMsg', Label.RevSys_ErrorMsg_EmpCert);
            }
        } catch(Exception e) {
            response.put('errorMsg', e.getMessage());
            response.put('consolelog', e.getStackTraceString());
            System.debug(e.getStackTraceString());
        }
        System.debug('AURAENABLED RevSys_EmpCert_RecordDetailController.validateCertification() END');
        return response;
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Name: getEmployeeCertification
    * @Description
    * Get employee certifiaction record based on employee certification id
    *————————————————————————————————————————————————————
    * @param    empCertId   ID of the employeeCertification record
    * @return   EmployeeCertification__c Details of the EC Record
    *————————————————————————————————————————————————————
    **/
    public static EmployeeCertification__c getEmployeeCertification(Id empCertId){
        EmployeeCertification__c ecRecord = new EmployeeCertification__c();
        SelectorWrapper wrapper = EmployeeCertificationSelector.getAllEmployeeCertification(new Set<Id>{empCertId});
        if(wrapper!=null && String.isBlank(wrapper.errorMessage)) {
            List<EmployeeCertification__c> ecList = (List<EmployeeCertification__c>)wrapper.sObjectList;
            if(ecList!=null && !ecList.isEmpty()) {
                ecRecord = ecList.get(0);
            }
        }
        return ecRecord;
    }


     /**
    *————————————————————————————————————————————————————
    * @Name: getLatestCertificationRecord
    * @Description
    * After the record is archived, navigate to the new record.
    *————————————————————————————————————————————————————
    * @param    certificationid   ID of the employeeCertification record
    * @return   response with recordId of the new record.
    *————————————————————————————————————————————————————
    **/
    public static  EmployeeCertification__c getLatestCertificationRecord(String certificationNumber){
        //Get the certification number from the Lightning component
        List<EmployeeCertification__c> empCert = new List<EmployeeCertification__c>();
        EmployeeCertification__c newEmpCert = new EmployeeCertification__c();
        try{
            if(String.isNotBlank(certificationNumber)) {
                //Call selector to get the latest EC record creatd which is not archived
                SelectorWrapper wrapper = EmployeeCertificationSelector.getLatestEmployeeCertification(certificationNumber);
                if(wrapper!=null && String.isBlank(wrapper.ErrorMessage)) {
                    empCert = (List<EmployeeCertification__c>)wrapper.sObjectList;
                    if(!empCert.isEmpty()) {
                            //List will be 1 as we want to navigate only to the latest certification record.
                            newEmpCert = empCert.get(0);
                            System.debug('**** in get latest certification using certificationNumber '+certificationNumber+' returned '+newEmpCert.Id);

                    }
                } else {
                    System.debug('**** latest wrapper.ErrorMessage '+wrapper.ErrorMessage);
                }
            }
        }catch(Exception e) {
            System.debug('Exception '+e.getMessage());
        }
        return newEmpCert;
    }
}
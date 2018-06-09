/**
*___________________________________________________
*@Name:      Revsys_EmpSpecReqHelper    
*@Author:    Chuck Walley   
*@Created:   March 28, 2018
*@Used_By:   SPARTN
*___________________________________________________
*@Description: 
* Handles SPARTN business logic concerning the Hierarchy 
* Assignment object
* be called
*___________________________________________________
*@Changes: 
* 05-21-2018. ETR-1211; ETR-1259: Utilize specific values for Failed Vision and Failed Hearing Tests, 
*                                 instead of "Failed Test."
* 05-24-2018  ETR-1211; ETR-1259: Update logic for Vision Tests (Four methods merged from RVDEV: processMedicalHearingAndVision
*                                                                                                processMedical
*                                                                                                processHearing
*                                                                                                processVision)
**/
public class Revsys_EmpSpecReqHelper {

    private Static Integer NumDaysToCheckForCert; 
    private Static Date    EarliestAmtrakDate; 

    /**
    *————————————————————————————————————————————————————
    * @Name: checkReadyToCertify
    * @Description - Once an ESR is updated with a certification requirement, we want to 
    *  determine if the associated Employee Certification is ready for certification. If so
    *  we mark the EC via the IsReadyToCertify field. 
    * 
    * @param    List<EmployeeSpecificRequirement__c> newEsrList - list from Trigger
    *                                            
    * @returns  String - error message from the process. 
    *————————————————————————————————————————————————————
    **/
    public static String checkReadyToCertify(List<EmployeeSpecificRequirement__c> newEsrList) {  
      
        system.debug('HELPER Revsys_EmpSpecReqHelper checkReadyToCertify-Start');   
        system.debug('newEsrList  ' + newEsrList); 

        String errMsg; 

        Map<Id,EmployeeCertification__c> myEmpCertMap = new Map<Id,EmployeeCertification__c>(); 
        List<EmployeeCertification__c> myUpdateEmpCertList = new List<EmployeeCertification__c>(); 

        // Get the associated Employee Certification Ids and put them in a set 
        Set<Id> myEcIdSet = new Set<Id>(); 

        for(EmployeeSpecificRequirement__c newEsr :newEsrList) {
            if(newEsr.RecordTypeId == RevSys_StaticUtility.EMPSPECREQUIREMENT_SPARTNCERT_RECTYPE_ID && 
               newEsr.EmployeeCertification__c != null) {
                    myEcIdSet.add(newEsr.EmployeeCertification__c); 
            }
        }

        // Get the Employee Certification records 
        SelectorWrapper myEcWrap = EmployeeCertificationSelector.getEmpCertification(myEcIdSet); 

        if(myEcWrap.ErrorMessage == null && myEcWrap.SobjectList.size() > 0) { 

            // Map Employee Certifications 
            for(EmployeeCertification__c myEc :(List<EmployeeCertification__c>)myEcWrap.SObjectList) {
                myEmpCertMap.put(myEc.Id,myEc); 
            }

            // Determine if the Employee is ready to be certified 
            List<RevSys_EmployeeCertificationHelper.EmployeeCertificationWrapper> myEmpCertWrapList 
                = RevSys_EmployeeCertificationHelper.validateCertification(  (List<EmployeeCertification__c>)myEcWrap.SObjectList); 

            if(myEmpCertWrapList.size() > 0 ) {

                for(RevSys_EmployeeCertificationHelper.EmployeeCertificationWrapper myEmpCertWrap :myEmpCertWrapList) {

                    if(myEmpCertWrap.hasError == false) {
                        myEmpCertWrap.ecRecord.IsReadyToCertify__c = true;
                        myEmpCertWrap.ecRecord.ProcessFlag__c = System.Label.RevSys_EmpCert_ProcessFlag;
                        myUpdateEmpCertList.add(myEmpCertWrap.ecRecord); 
                    } 
                }

                if(myUpdateEmpCertList.size() > 0) {
                    errMsg = DmlHelper.updateList(myUpdateEmpCertList); 
                }

            }
        }

        system.debug('HELPER Revsys_EmpSpecReqHelper checkReadyToCertify-End'); 
        return errMsg; 
    }


    /**
    *————————————————————————————————————————————————————
    * @Name: updateReportingFields
    * @Description - Once an ESR is updated with a certification requirement, we want to
    *   to copy the fulfillment date on to the Employee Certification in order to showcase
    *   them on the the Reports without having to refer the ESRs.
    * 
    * @param    List<EmployeeSpecificRequirement__c> newEsrList - list from Trigger
    *                                            
    * @returns  String - error message from the process. 
    *————————————————————————————————————————————————————
    **/
    public static String updateReportingFields(List<EmployeeSpecificRequirement__c> newEsrList) {

        system.debug('HELPER Revsys_EmpSpecReqHelper updateReportingFields-Start'); 
        String errMsg='';


        // Get the associated Employee Certification Ids and put them in a set 
        Set<Id> myEcIdSet = new Set<Id>(); 
        Map<Id,EmployeeCertification__c> myECMap = new Map<Id,EmployeeCertification__c>();
        Map<Id,OccupationRequirement__c> myORMap = new Map<Id,OccupationRequirement__c>();
        Map<Id,List<EmployeeSpecificRequirement__c>> esrToProcess = new Map<Id,List<EmployeeSpecificRequirement__c>>();
        Map<Id,EmployeeCertification__c> ecToUpdate = new Map<Id,EmployeeCertification__c>();
        List<Date> lastEfficiencyTestDate = new List<Date>();
        Set<Id> occReqIdSet = new Set<Id>();

        for(EmployeeSpecificRequirement__c newEsr :newEsrList) {
            if(newEsr.RecordTypeId == RevSys_StaticUtility.EMPSPECREQUIREMENT_SPARTNCERT_RECTYPE_ID && 
             newEsr.EmployeeCertification__c != null && newEsr.LastFulfilledDate__c!=null) {
                myEcIdSet.add(newEsr.EmployeeCertification__c); 
                if(esrToProcess.containsKey(newEsr.EmployeeCertification__c)) {
                    esrToProcess.get(newEsr.EmployeeCertification__c).add(newEsr);
                } else {
                    esrToProcess.put(newEsr.EmployeeCertification__c,new List<EmployeeSpecificRequirement__c>{newEsr});
                }

                if(newEsr.Requirement__c!=null) {
                    occReqIdSet.add(newEsr.Requirement__c);
                }
            }
        }

        if(!myEcIdSet.isEmpty()) {

             // Get the Employee Certification records 
             SelectorWrapper myEcWrap = EmployeeCertificationSelector.getEmpCertification(myEcIdSet); 

             if(myEcWrap.ErrorMessage == null && myEcWrap.SobjectList.size() > 0) { 
                //get the ec and store it in Map
                for(EmployeeCertification__c ecRec : (List<EmployeeCertification__c>)myEcWrap.SObjectList) {
                    myECMap.put(ecRec.Id,ecRec);
                }

             } else {
                errMsg = myEcWrap.ErrorMessage;
             }
        }


        if(!occReqIdSet.isEmpty()) {

            //Get the Occupation Requirement details
            SelectorWrapper myORWrap = OccupationRequirementSelector.getOccRequirements(occReqIdSet);

            if(myORWrap.ErrorMessage==null && myORWrap.SobjectList.size() >0) {
                for(OccupationRequirement__c orRec : (List<OccupationRequirement__c>)myORWrap.SobjectList) {
                    myORMap.put(orRec.Id,orRec);
                }
            } else  {
                errMsg  += myORWrap.ErrorMessage;
            }
        }

        //Process all the ESRs and update the EC.
        if(!myECMap.isEmpty() && !esrToProcess.isEmpty()) {

            for(Id ecId : esrToProcess.keySet()) {
                Boolean isUpdated = false;
                if(myECMap.containsKey(ecId)) {
                    EmployeeCertification__c ecRec =  myECMap.get(ecId);
                    for(EmployeeSpecificRequirement__c esr : esrToProcess.get(ecId)) {
 
                        //Update Last Ride Taken
                        if(String.isNotBlank(esr.Source__c) && esr.Source__c==RevSys_StaticUtility.OBSERVATION &&
                        String.isNotBlank(esr.SourceRecordType__c) && esr.SourceRecordType__c==Label.RevSys_Generic_Form1875_SourceRecordType) {
                            ecRec.Last1875RideDate__c = esr.LastFulfilledDate__c;
                            ecRec.ProcessFlag__c = System.Label.RevSys_EmpCert_ProcessFlag;
                            ecToUpdate.put(ecId, ecRec);
                        }

                        //Update Hearing date details
                        if(String.isNotBlank(esr.Source__c) && esr.Source__c==Label.RevSys_ESR_Source_Emp_Result_Summary &&
                        String.isNotBlank(esr.SourceRecordType__c) && esr.SourceRecordType__c==Label.RevSys_ESR_Medical_Hearing_and_Vision &&
                        String.isNotBlank(esr.SourceTestType__c) && esr.SourceTestType__c==Label.RevSys_Generic_Hearing_Test) {
                            ecRec.LastHearingTestFulfillmentDate__c = esr.LastFulfilledDate__c;
                            ecRec.ProcessFlag__c = System.Label.RevSys_EmpCert_ProcessFlag;
                            ecToUpdate.put(ecId, ecRec);
                        }

                        //Update Medical date details
                        if(String.isNotBlank(esr.Source__c) && esr.Source__c==Label.RevSys_ESR_Source_Emp_Result_Summary &&
                        String.isNotBlank(esr.SourceRecordType__c) && esr.SourceRecordType__c==Label.RevSys_ESR_Medical_Hearing_and_Vision &&
                        String.isNotBlank(esr.SourceTestType__c) && esr.SourceTestType__c==Label.RevSys_Generic_Medical_Examination) {
                            ecRec.LastMedicalExamFulfillmentDate__c = esr.LastFulfilledDate__c;
                            ecRec.ProcessFlag__c = System.Label.RevSys_EmpCert_ProcessFlag;
                            ecToUpdate.put(ecId, ecRec);
                        }

                        //Update National Review details
                        if(String.isNotBlank(esr.Source__c) && esr.Source__c==Label.RevSys_ESR_Source_Emp_Result_Summary &&
                        String.isNotBlank(esr.SourceRecordType__c) && esr.SourceRecordType__c==Label.RevSys_EmpResSumm_RT_Label_Motor &&
                        String.isNotBlank(esr.SourceTestType__c) && esr.SourceTestType__c==Label.RevSys_Generic_National_Review) {
                            ecRec.LastNDRReviewFulfillmentDate__c = esr.LastFulfilledDate__c;
                            ecRec.ProcessFlag__c = System.Label.RevSys_EmpCert_ProcessFlag;
                            ecToUpdate.put(ecId, ecRec);
                        }

                        //Update Vision Test details
                        if(String.isNotBlank(esr.Source__c) && esr.Source__c==Label.RevSys_ESR_Source_Emp_Result_Summary &&
                        String.isNotBlank(esr.SourceRecordType__c) && esr.SourceRecordType__c==Label.RevSys_ESR_Medical_Hearing_and_Vision &&
                        String.isNotBlank(esr.SourceTestType__c) && esr.SourceTestType__c==Label.RevSys_Generic_Vision_Test) {
                            ecRec.LastVisionTestFulfillmentDate__c = esr.LastFulfilledDate__c;
                            ecRec.ProcessFlag__c = System.Label.RevSys_EmpCert_ProcessFlag;
                            ecToUpdate.put(ecId, ecRec);
                        }

                        //Update State Review details
                        if(String.isNotBlank(esr.Source__c) && esr.Source__c==Label.RevSys_ESR_Source_Emp_Result_Summary &&
                        String.isNotBlank(esr.SourceRecordType__c) && esr.SourceRecordType__c==Label.RevSys_EmpResSumm_RT_Label_Motor &&
                        String.isNotBlank(esr.SourceTestType__c) && esr.SourceTestType__c==Label.RevSys_Generic_State_Review) {
                            ecRec.LastStateDRVFulfillmentDate__c = esr.LastFulfilledDate__c;
                            ecRec.ProcessFlag__c = System.Label.RevSys_EmpCert_ProcessFlag;
                            ecToUpdate.put(ecId, ecRec);
                        }

                        //Occupation Requirement Details
                        if(String.isNotBlank(esr.Requirement__c) && myORMap.containsKey(esr.Requirement__c)) {
                            OccupationRequirement__c req =  myORMap.get(esr.Requirement__c);
                      /*      
                            //Efficiency Test (FRA 123)
                            if(String.isNotBlank(req.Name) && req.Name.equalsIgnoreCase(Label.RevSys_EfficiencyTest_FRA123)) {
                                ecRec.EfficiencyTestFRA123__c = esr.LastFulfilledDate__c;
                                ecRec.ProcessFlag__c = System.Label.RevSys_EmpCert_ProcessFlag;
                                ecToUpdate.put(ecId, ecRec);
                            }

                            //Efficiency Test (FRA 125)
                            if(String.isNotBlank(req.Name) && req.Name.equalsIgnoreCase(Label.RevSys_EfficiencyTest_FRA125)) {
                                ecRec.EfficiencyTestFRA125__c = esr.LastFulfilledDate__c;
                                ecRec.ProcessFlag__c = System.Label.RevSys_EmpCert_ProcessFlag;
                                ecToUpdate.put(ecId, ecRec);
                            }

                            //Efficiency Test (FRA 303)
                            if(String.isNotBlank(req.Name) && req.Name.equalsIgnoreCase(Label.RevSys_EfficiencyTest_FRA303)) {
                                ecRec.EfficiencyTestFRA303__c = esr.LastFulfilledDate__c;
                                ecRec.ProcessFlag__c = System.Label.RevSys_EmpCert_ProcessFlag;
                                ecToUpdate.put(ecId, ecRec);
                            }       
                            
                            //Last Efficiency Test Date from FRA 138 or test 117 or test 118
                       /*     if(String.isNotBlank(req.Name) && String.isNotBlank(req.TestNumber__c)){
                                if(req.Name.equalsIgnoreCase(Label.RevSys_EfficiencyTest_FRA138)){
                                    lastEfficiencyTestDate.add(esr.LastFulfilledDate__c);
                                    
                                }
                                if(req.TestNumber__c.equalsIgnoreCase('117')){
                                    lastEfficiencyTestDate.add(esr.LastFulfilledDate__c);
                                }
                                if(req.TestNumber__c.equalsIgnoreCase('118')){
                                    lastEfficiencyTestDate.add(esr.LastFulfilledDate__c);
                                }
                                if(req.Name.equalsIgnoreCase(Label.RevSys_EfficiencyTest_FRA138) || req.TestNumber__c.equalsIgnoreCase('117') || req.TestNumber__c.equalsIgnoreCase('118')){
                                    lastEfficiencyTestDate.sort();
                                    ecRec.LastEfficiencyTestDate__c = lastEfficiencyTestDate[lastEfficiencyTestDate.size() - 1];
                                    ecRec.ProcessFlag__c = System.Label.RevSys_EmpCert_ProcessFlag;
                                    ecToUpdate.put(ecId, ecRec);
                                }
                            } 
                            
                            if(String.isNotBlank(req.Name) && req.Source__c.equalsIgnoreCase(RevSys_StaticUtility.OBSERVATION) 
                               && req.SourceRecordType__c.equalsIgnoreCase(Label.RevSys_Form_1872) && esr.ReportStatus__c.equalsIgnoreCase(Label.Revsys_Generic_Pass)){
                                if(req.Name.equalsIgnoreCase(Label.RevSys_EfficiencyTest_FRA138)){

                                    ecRec.EmergencyPreparednessTest__c = esr.LastFulfilledDate__c;
                                    ecRec.LastRecertificationDate__c = esr.LastFulfilledDate__c;
                                    System.debug('emer &&&'+ecRec.EmergencyPreparednessTest__c);
                                    System.debug('emer &&&'+ecRec.LastRecertificationDate__c);
                                    ecRec.ProcessFlag__c = System.Label.RevSys_EmpCert_ProcessFlag;
                                    ecToUpdate.put(ecId, ecRec);
                                }
                                
                                if(req.Name.equalsIgnoreCase(Label.RevSys_EfficiencyTest_FRA125)){
                                    ecRec.LastOperatingRulesDate__c = esr.LastFulfilledDate__c;
                                    ecRec.ProcessFlag__c = System.Label.RevSys_EmpCert_ProcessFlag;
                                    ecToUpdate.put(ecId, ecRec);
                                }
                            }*/
                        }
                    }
                }
            }
        }

        if(!ecToUpdate.isEmpty()) {
            errMsg += DmlHelper.updateList(ecToUpdate.values());
        }

        system.debug('HELPER Revsys_EmpSpecReqHelper updateReportingFields-End'); 
        return StringUtility.cleanUpMessage(errMsg); 

    }

    /**
    *————————————————————————————————————————————————————
    * @Name: updateNewEsrWithExistingInfo
    * @Description - When Employee Specific Requirements are about to be inserted,
    * we want to see if there are existing records, for an employee, which have 
    * matching attributes.
    *
    * This currently handles everything but those requirements fulfilled with 
    * 1872 Observations. 
    * 
    * @param    List<EmployeeSpecificRequirement__c> newEsrList - list from Trigger
    *                                            
    * @returns  List<EmployeeSpecificRequirement__c> updatedEsrList
    *————————————————————————————————————————————————————
    **/
    public static SelectorWrapper updateNewEsrWithExistingInfo(List<EmployeeSpecificRequirement__c> newEsrList) {
      
        system.debug('HELPER Revsys_EmpSpecReqHelper updateNewEsrWithExistingInfo-Start');   
        system.debug('newEsrList  ' + newEsrList); 

        Set<Id> myEmpIdSet = new Set<Id>(); 
        Set<Id> myReqIdSet = new Set<Id>(); 

        Map<Id,List<EmployeeSpecificRequirement__c>> myEsrByEmpIdMap 
            = new Map<Id,List<EmployeeSpecificRequirement__c>>(); 
        List<EmployeeSpecificRequirement__c> myCertEsr1872List    = new List<EmployeeSpecificRequirement__c>(); 
        List<EmployeeSpecificRequirement__c> myCertEsrErsList     = new List<EmployeeSpecificRequirement__c>(); 
        List<EmployeeSpecificRequirement__c> myCertEsrObsList     = new List<EmployeeSpecificRequirement__c>(); 
        List<EmployeeSpecificRequirement__c> myTgtEsrList         = new List<EmployeeSpecificRequirement__c>(); 
        List<EmployeeSpecificRequirement__c> myOutEsrList         = new List<EmployeeSpecificRequirement__c>(); 

        Map<Id,OccupationRequirement__c> myOccReqMap = new Map<Id,OccupationRequirement__c>(); 

        System.debug('before NumDaysToCheckForCert$$$$');
        SPARTN_Custom_Settings__c customSet = SPARTN_Custom_Settings__c.getValues('Emp Cert: Num Days to Check for Reqs');
        System.debug('between customSet$$$$'+customSet);
        NumDaysToCheckForCert = Integer.valueOf(customSet.CsvString__c);
        System.debug('after NumDaysToCheckForCert$$$$'+NumDaysToCheckForCert);
        
        customSet = SPARTN_Custom_Settings__c.getValues('Earliest Amtrak Date');
        EarliestAmtrakDate = Date.valueOf(customSet.CsvString__c);

        for(EmployeeSpecificRequirement__c newEsr :newEsrList) {
            myEmpIdSet.add(newEsr.Employee__c); 
            myReqIdSet.add(newEsr.Requirement__c); 
        }

        // Build the Requirement Map 

        SelectorWrapper myOrWrap = OccupationRequirementSelector.getOccRequirements(myReqIdSet); 

        if(myOrWrap.ErrorMessage == null && myOrWrap.SobjectList.size() > 0) { 
            for(OccupationRequirement__c myOr :(List<OccupationRequirement__c>)myOrWrap.SObjectList) {
                myOccReqMap.put(myOr.Id, myOr); 
            }
        }

        // Roll through the newEsr  records again and put into one of four lists for processing 
        for(EmployeeSpecificRequirement__c newEsr :newEsrList) {   

            if(newEsr.RecordTypeId == RevSys_StaticUtility.EMPSPECREQUIREMENT_SPARTNCERT_RECTYPE_ID) { 
                OccupationRequirement__c myOccReq = myOccReqMap.get(newEsr.Requirement__c); 

                if(myOccReq != null) {

                    if(myOccReq.Source__c == 'Employee Result Summary') {
                        myCertEsrErsList.add(newEsr);  
                    }
                    else {

                        if(myOccReq.SourceRecordType__c == 'Form-1872') {
                            myCertEsr1872List.add(newEsr); 
                        }
                        else {
                            myCertEsrObsList.add(newEsr); 
                        }
                    }
                }
            }    
            else { 
                myTgtEsrList.add(newEsr); 
            }
        }

        String myErrMsg; 

        // Process one of four ways  

        // Certification ESRs needing to look at past 1872 Observations  
        if(myCertEsr1872List.size() > 0) {
            SelectorWrapper myWrap = apply1872ObsToNewEmpCertRecs(myCertEsr1872List,myOccReqMap);
            myErrMsg = myWrap.ErrorMessage; 
            if(myErrMsg == null) {
                myOutEsrList.addAll( (List<EmployeeSpecificRequirement__c>)myWrap.SObjectList );
            }
        }

        // Certification ESRs needing to look at past 1875 and 1877 Observations  
        if(myCertEsrObsList.size() > 0) {
            SelectorWrapper myWrap = apply1875And1877ObsToNewEmpCertRecs(myCertEsrObsList,myOccReqMap);
            myErrMsg = myWrap.ErrorMessage; 
            if(myErrMsg == null) {
                myOutEsrList.addAll( (List<EmployeeSpecificRequirement__c>)myWrap.SObjectList );
            }
        }

        // Certification ESRs which need to look at past Employee Result Summary records 
        if(myCertEsrErsList.size() > 0) {
            SelectorWrapper myWrap = applyEmpResSumDataToNewCertRecs(myCertEsrErsList,myOccReqMap); 
            myErrMsg = myWrap.ErrorMessage; 
            if(myErrMsg == null) {
                myOutEsrList.addAll( (List<EmployeeSpecificRequirement__c>)myWrap.SObjectList );
            }
        }

        // Target ESRs 
        if(myTgtEsrList.size() > 0) {
            myOutEsrList.addAll(myTgtEsrList); 
        }

        // now we can build the SelectorWrapper to send back 
        List<SObject> mySObjectList = new List<SObject>(); 
        mySObjectList.addAll(myOutEsrList); 

        SelectorWrapper myWrap = new SelectorWrapper(myErrMsg, mySObjectList); 

        system.debug('HELPER Revsys_EmpSpecReqHelper updateNewEsrWithExistingInfo-End');  
        return myWrap; 
    }
    /**
    *————————————————————————————————————————————————————
    * @Name: apply1872ObsToNewEmpCertRecs
    * @Description - When Employee Specific Requirements are about to be inserted,
    * we want to see if there are existing records, for an employee, which have 
    * matching attributes.
    *
    * This currently handles everything but those requirements fulfilled with 
    * 1872 Observations. 
    * 
    * @param    List<EmployeeSpecificRequirement__c> newEsrList - list from Trigger
    *                                            
    * @returns  List<EmployeeSpecificRequirement__c> updatedEsrList
    *————————————————————————————————————————————————————
    **/
    public static SelectorWrapper apply1872ObsToNewEmpCertRecs(List<EmployeeSpecificRequirement__c> newEsrList,
                                                               Map<Id,OccupationRequirement__c> myOccReqMap)    {

        system.debug('HELPER Revsys_EmpSpecReqHelper applyOld1872EsrDataToNewCertRecs-Start');   
        system.debug('newEsrList  ' + newEsrList); 
        system.debug('myOccReqMap  ' + myOccReqMap); 

        String myErrMsg; 

        // ESR - SPARTN Certification records with a SourceRecordType of Form-1872 

        Set<Id> myEcIdSet  = new Set<Id>(); 
        Set<Id> myEmpIdSet = new Set<Id>(); 
        Set<Id> myOsrIdSet = new Set<Id>(); 
        Set<Id> myReqIdSet = new Set<Id>(); 
        Set<String> myTestNumSet = new Set<String>(); 

        Map<Id,List<String>> myObsNumListByReqIdMap = new Map<Id,List<String>>(); 

        for(EmployeeSpecificRequirement__c newEsr :newEsrList) { 
            myEcIdSet.add(newEsr.EmployeeCertification__c);
            myEmpIdSet.add(newEsr.Employee__c);
            myOsrIdSet.add(newEsr.OccupationSpecificRequirement__c); 
            myReqIdSet.add(newEsr.Requirement__c); 
        }

        // I have a set of Employee Ids & a set of Requirement Ids
        // Use the Requirment Ids to Query OSR for the related Test Numbers 

        // OccupationSpecificRequirementSelector.getOsrTargetReq

        SelectorWrapper myOsrWrap = OccupationSpecificRequirementSelector.getOsrTargetReq(myReqIdSet); 

        myErrMsg = myOsrWrap.ErrorMessage; 

        if(myOsrWrap.ErrorMessage == null && myOsrWrap.SobjectList.size() > 0) { 

            for(OccupationSpecificRequirement__c myOsr :(List<OccupationSpecificRequirement__c>)myOsrWrap.SObjectList) {   

                myTestNumSet.add(myOsr.Test_Number__c); 

                List<String> myObsNumList = myObsNumListByReqIdMap.get(myOsr.TargetRequirement__c); 

                if(myObsNumList == null) { 
                    myObsNumList = new List<String>(); 
                }

                myObsNumList.add(myOsr.Test_Number__c); 
                myObsNumListByReqIdMap.put(myOsr.TargetRequirement__c,myObsNumList);
            }

            // We have a set of Employees and Observation Ids. Let's get the Observations 
            // associated with these employees and numbers for the past three years. 

            Integer myDaysToCheck = NumDaysToCheckForCert * -1; 
            DateTime myEarliestDateTime = system.now().addDays(myDaysToCheck); 

            ObservationSelector ObsSel = new ObservationSelector(); 
            SelectorWrapper myObsWrapper = ObsSel.selectByEmployeeAndTestNum(myEmpIdSet, myTestNumSet, myEarliestDateTime); 

            myErrMsg = myOsrWrap.ErrorMessage; 

            if(myObsWrapper.ErrorMessage == null && myObsWrapper.SobjectList.size() > 0) { 

                Map<String,Observation__c> myObservationByMashKeyMap = new Map<String,Observation__c>(); 

                for(Observation__c myObs :(List<Observation__c>)myObsWrapper.SObjectList) { 

                    String myMashKey = myObs.Employee__c + '|' + myObs.TestNumber__c;

                    Observation__c myCheckObs = myObservationByMashKeyMap.get(myMashKey); 

                    if(myCheckObs == null) {
                        myObservationByMashKeyMap.put(myMashKey,myObs); 
                    }
                    else { 
                        if(myObs.EvaluationDateTime__c > myCheckObs.EvaluationDateTime__c) { 
                            myObservationByMashKeyMap.put(myMashKey,myObs); 
                        }
                    }
                }

                // Now, we have a Map of Observations keyed by Employee+TestNumber 
                // Let's roll through our list of ESR and figure out which need to be 
                // updated with past Observations. 

                for(EmployeeSpecificRequirement__c newEsr :newEsrList) {

                    // With the Requirement, get the related list of Test Numbers 
                    // we found earlier in Line 423  

                    List<String> myTestNumList = myObsNumListByReqIdMap.get(newEsr.Requirement__c); 

                    if(myTestNumList != null ) { 

                        for(String myTestNum :myTestNumList) {

                            // Make a mash key of the Employee + Test Number and see if we have
                            // a previous record to apply 
                            String myMashKey = newEsr.Employee__c + '|' + myTestNum; 
                            
                            Observation__c myCheckObs = myObservationByMashKeyMap.get(myMashKey); 

                            if(myCheckObs != null) { 
                                
                                // We found a past observation to apply 

                                newEsr.LastFulfilledDate__c = myCheckObs.Date__c; 

                                if(myCheckObs.Result__c == Label.Revsys_1872_Result_Compliant) { 
                                    newEsr.ReportStatus__c = Label.RevSys_Pass; 
                                }
                                else {
                                    newEsr.ReportStatus__c = Label.RevSys_Fail; 
                                }
                            }
                        }
                    }
                }
            }
        }

        // now we can build the SelectorWrapper to send back 
        List<SObject> mySObjectList = new List<SObject>(); 
        mySObjectList.addAll(newEsrList); 

        SelectorWrapper myWrap = new SelectorWrapper(myErrMsg, mySObjectList); 

        system.debug('HELPER Revsys_EmpSpecReqHelper applyOld1872EsrDataToNewCertRecs-End'); 
        return myWrap; 
    }

    /**
    *————————————————————————————————————————————————————
    * @Name: apply1875And1877ObsToNewEmpCertRecs
    * @Description - When Employee Specific Requirements are about to be inserted,
    * we want to see if there are existing records, for an employee, which have 
    * matching attributes.
    *
    * This currently handles everything but those requirements fulfilled with 
    * 1872 Observations. 
    * 
    * @param    List<EmployeeSpecificRequirement__c> newEsrList - list from Trigger
    *                                            
    * @returns  List<EmployeeSpecificRequirement__c> updatedEsrList
    *————————————————————————————————————————————————————
    **/
    public static SelectorWrapper apply1875And1877ObsToNewEmpCertRecs(List<EmployeeSpecificRequirement__c> newEsrList,
                                                                      Map<Id,OccupationRequirement__c> myOccReqMap)    {

        system.debug('HELPER Revsys_EmpSpecReqHelper apply1875And1877ObsToNewEmpCertRecs-Start');   
        system.debug('newEsrList  ' + newEsrList); 
        system.debug('myOccReqMap  ' + myOccReqMap); 

        String myErrMsg; 

        // ESR - SPARTN Certification records with a SourceRecordType of Form-1875 or Form-1877  

        Set<Id> myEcIdSet  = new Set<Id>(); 
        Set<Id> myEmpIdSet = new Set<Id>(); 
        Set<Id> myOsrIdSet = new Set<Id>(); 
        Set<Id> myReqIdSet = new Set<Id>(); 
        Set<Id> myRecTypeIdSet = new Set<Id>(); 
        Set<String> myTestNumSet = new Set<String>(); 

        Map<Id,List<String>> myObsNumListByReqIdMap = new Map<Id,List<String>>(); 

        for(EmployeeSpecificRequirement__c newEsr :newEsrList) { 
            myEcIdSet.add(newEsr.EmployeeCertification__c);
            myEmpIdSet.add(newEsr.Employee__c);
            myOsrIdSet.add(newEsr.OccupationSpecificRequirement__c); 
            myReqIdSet.add(newEsr.Requirement__c); 
        }

        Id myForm1875Id = Revsys_StaticUtility.OBSERVATION_TEST1875_RECTYPE_ID; 
        Id myForm1877Id = Revsys_StaticUtility.OBSERVATION_TEST1877_RECTYPE_ID; 

        myRecTypeIdSet.add(myForm1875Id); 
        myRecTypeIdSet.add(myForm1877Id); 

        // We have a set of Employees and RecordType Ids. Let's get the Observations 
        // associated with these employees for the past X days  

        Integer myDaysToCheck = NumDaysToCheckForCert * -1; 
        DateTime myEarliestDateTime = system.now().addDays(myDaysToCheck); 

        ObservationSelector ObsSel = new ObservationSelector(); 
        SelectorWrapper myObsWrapper = ObsSel.selectByEmployeeAndRecType(myEmpIdSet, myRecTypeIdSet, myEarliestDateTime); 

        myErrMsg = myObsWrapper.ErrorMessage; 

        if(myObsWrapper.ErrorMessage == null && myObsWrapper.SobjectList.size() > 0) { 

            Map<String,Observation__c> myObservationByMashKeyMap = new Map<String,Observation__c>(); 

            for(Observation__c myObs :(List<Observation__c>)myObsWrapper.SObjectList) { 

                String myRecTypeName = RevSys_RecTypeUtility.convertIdToName(myObs.RecordTypeId); 

                String myMashKey = myObs.Employee__c + '|' + myRecTypeName;

                Observation__c myCheckObs = myObservationByMashKeyMap.get(myMashKey); 

                if(myCheckObs == null) {
                    myObservationByMashKeyMap.put(myMashKey,myObs); 
                }
                else { 
                    if(myObs.EvaluationDateTime__c > myCheckObs.EvaluationDateTime__c) { 
                        myObservationByMashKeyMap.put(myMashKey,myObs); 
                    }
                }
            }

            // Now, we have a Map of Observations keyed by Employee+RecordType 
            // Let's roll through our list of ESR and figure out which need to be 
            // updated with past Observations. 

            for(EmployeeSpecificRequirement__c newEsr :newEsrList) {

                // With the Requirement, get the related list of Test Numbers 
                // we found earlier in Line 423  

                List<String> myTestNumList = myObsNumListByReqIdMap.get(newEsr.Requirement__c); 

                if(myTestNumList != null ) { 

                    for(String myTestNum :myTestNumList) {

                        // Make a mash key of the Employee + Test Number and see if we have
                        // a previous record to apply 
                        String myMashKey = newEsr.Employee__c + '|' + myTestNum; 
                        
                        Observation__c myCheckObs = myObservationByMashKeyMap.get(myMashKey); 

                        if(myCheckObs != null) { 
                            
                            // We found a past observation to apply 

                            newEsr.LastFulfilledDate__c = myCheckObs.Date__c; 

                            if(myCheckObs.QualificationStatus__c == Label.RevSys_Pass)  { 
                                newEsr.ReportStatus__c = Label.RevSys_Pass; 
                            }
                            else {
                                newEsr.ReportStatus__c = Label.RevSys_Fail; 
                            }
                        }
                    }
                }
            }
        }

        // now we can build the SelectorWrapper to send back 
        List<SObject> mySObjectList = new List<SObject>(); 
        mySObjectList.addAll(newEsrList); 

        SelectorWrapper myWrap = new SelectorWrapper(myErrMsg, mySObjectList); 

        system.debug('HELPER Revsys_EmpSpecReqHelper apply1875And1877ObsToNewEmpCertRecs-End'); 
        return myWrap; 
    }

    /**
    *————————————————————————————————————————————————————
    * @Name: applyEmpResSumDataToNewCertRecs
    * @Description - When Employee Specific Requirements are about to be inserted,
    * we want to see if there are existing records, for an employee, which have 
    * matching attributes.
    *
    * This currently handles everything but those requirements fulfilled with 
    * 1872 Observations. 
    * 
    * @param    List<EmployeeSpecificRequirement__c> newEsrList - list from Trigger
    *                                            
    * @returns  List<EmployeeSpecificRequirement__c> updatedEsrList
    *————————————————————————————————————————————————————
    **/
    public static SelectorWrapper applyEmpResSumDataToNewCertRecs(List<EmployeeSpecificRequirement__c> newEsrList,
                                                                  Map<Id,OccupationRequirement__c> myOccReqMap) 
    {  
        system.debug('HELPER Revsys_EmpSpecReqHelper applyEmpResSumDataToNewCertRecs-Start');   
        system.debug('newEsrList  ' + newEsrList); 
        system.debug('myOccReqMap  ' + myOccReqMap); 

        // ESR - SPARTN Certification records with a SourceRecordType of Form-1872 

        Set<Id> myEcIdSet  = new Set<Id>(); 
        Set<Id> myEmpIdSet = new Set<Id>(); 
        Set<Id> myOsrIdSet = new Set<Id>(); 
        Set<Id> myReqIdSet = new Set<Id>(); 
        Set<Id> myRecTypeIdSet = new Set<Id>(); 
        Set<Id> myEmpHistRecTypeIdSet = new Set<Id>(); 
        Set<String> mySourceSet = new Set<String>(); 
        Set<String> mySourceRecTypeSet = new Set<String>(); 
        Set<String> mySourceTestTypeSet = new Set<String>(); 
        Set<String> myTestNumSet = new Set<String>(); 

        Map<Id,List<String>> myObsNumListByReqIdMap = new Map<Id,List<String>>(); 
        Map<String,EmployeeResultSummary__c> myErsByMashKeyMap = new Map<String,EmployeeResultSummary__c>(); 

        // Put important information into appropriate sets 
        for(EmployeeSpecificRequirement__c newEsr :newEsrList) { 
            myEcIdSet.add(newEsr.EmployeeCertification__c);
            myEmpIdSet.add(newEsr.Employee__c);
            myOsrIdSet.add(newEsr.OccupationSpecificRequirement__c); 
            myReqIdSet.add(newEsr.Requirement__c); 
        }

        system.debug('HELPER Revsys_EmpSpecReqHelper applyEmpResSumDataToNewCertRecs-100');   
           
        // Map Occupation Specific Requirements 

        SelectorWrapper myOrWrap = OccupationRequirementSelector.getOccRequirements(myReqIdSet); 

        if(myOrWrap.ErrorMessage == null && myOrWrap.SobjectList.size() > 0) { 
            for(OccupationRequirement__c myOr :(List<OccupationRequirement__c>)myOrWrap.SObjectList) {
                myOccReqMap.put(myOr.Id, myOr); 
                mySourceRecTypeSet.add(myOr.SourceRecordType__c); 
                mySourceTestTypeSet.add(myOr.SourceTestType__c); 
            }
        }

        system.debug('HELPER Revsys_EmpSpecReqHelper applyEmpResSumDataToNewCertRecs-200');   
        //  Convert the Record Type Names to Ids 

        for(String mySourceRecType :mySourceRecTypeSet) {

            system.debug('mySourceRecType  ' + mySourceRecType); 
            Id mySourceRecTypeId 
                = RevSys_RecTypeUtility.convertNameToId(Revsys_StaticUtility.OBJAPI_EMPLOYEE_RESULT_SUMMARY, 
                                                        mySourceRecType); 
                                                            
            // Segregate the Employee History record because we want a separate search with it
            if(mySourceRecType == 'Employment History') { 
                myEmpHistRecTypeIdSet.add(mySourceRecTypeId); 
            }
            else {
                myRecTypeIdSet.add(mySourceRecTypeId);
            } 
        }
        system.debug('HELPER Revsys_EmpSpecReqHelper applyEmpResSumDataToNewCertRecs-300');   

        //Query ERS for Old records  

        Integer myDaysToCheck = NumDaysToCheckForCert * -1; 
        Date myEarliestDate = system.Today().addDays(myDaysToCheck); 
         
        system.debug('HELPER Revsys_EmpSpecReqHelper applyEmpResSumDataToNewCertRecs-400');   


        // Query the Employee Result Summary Records. We use two queries because we want 
        // The Employment History record regardless of when it was added

        List<EmployeeResultSummary__c> myEmpSumList = new List<EmployeeResultSummary__c>(); 

        String wrapErrMsg; 

        if(myRecTypeIdSet.size() > 0) {

            SelectorWrapper myErsWrap  = EmployeeResultSummarySelector.getErsByEmployeeAndSourceInfo(myEmpIdSet, myRecTypeIdSet, mySourceTestTypeSet,myEarliestDate);  

            wrapErrMsg = myErsWrap.ErrorMessage;

            if(myErsWRap.ErrorMessage == null && myErsWrap.SObjectList.size() > 0) { 
                myEmpSumList.addAll( (List<EmployeeResultSummary__c>)myErsWrap.SObjectList ); 
            } 
        }

        if(wrapErrMsg == null && myEmpHistRecTypeIdSet.size() > 0) {

            SelectorWrapper myErsWrap  = EmployeeResultSummarySelector.getErsByEmployeeAndSourceInfo(myEmpIdSet, myEmpHistRecTypeIdSet, null, EarliestAmtrakDate);  

            wrapErrMsg = myErsWrap.ErrorMessage;

            if(myErsWRap.ErrorMessage == null && myErsWrap.SObjectList.size() > 0) { 
                myEmpSumList.addAll( (List<EmployeeResultSummary__c>)myErsWrap.SObjectList ); 
            } 
        }


        // map by Employee + RecordTypeName + TestType 
        if(wrapErrMsg == null && myEmpSumList.size() > 0) { 

            system.debug('HELPER Revsys_EmpSpecReqHelper applyEmpResSumDataToNewCertRecs-500');   

            for(EmployeeResultSummary__c myErs :myEmpSumList) {
                

                String myRecTypeName = RevSys_RecTypeUtility.convertIdToName(myErs.RecordTypeId); 

                String myMashKey = myErs.Employee__c + myRectypeName; 
                if(myErs.Type__c != null) {
                    myMashKey += myErs.Type__c; 
                }

                // Put the latest record in the map
                EmployeeResultSummary__c myEmResSum = myErsByMashKeyMap.get(myMashKey); 

                if(myEmResSum == null) {
                    myErsByMashKeyMap.put(myMashKey,myErs);
                }
                else {
                    if(myErs.RecordTypeId == RevSys_StaticUtility.EMP_RES_SUMM_MOTORVEHICLE_RECTYPE_ID) {
                        if(myErs.StateReviewDate__c > myEmResSum.StateReviewDate__c  || 
                           myErs.NdrReviewDate__c   > myEmResSum.NdrReviewDate__c)  {
                                myErsByMashKeyMap.put(myMashKey,myErs);
                        }

                    }
                    else {
                        if(myErs.EvaluationDate__c > myEmResSum.EvaluationDate__c) { 
                                myErsByMashKeyMap.put(myMashKey,myErs);
                        } 
                    }
                }
            }

            system.debug('HELPER Revsys_EmpSpecReqHelper applyEmpResSumDataToNewCertRecs-600');   
            // 

            for(EmployeeSpecificRequirement__c newEsr :newEsrList) { 

                system.debug('HELPER Revsys_EmpSpecReqHelper applyEmpResSumDataToNewCertRecs-700');  
                system.debug('newEsr ' + newEsr);  

                OccupationRequirement__c myOccReq = myOccReqMap.get(newEsr.Requirement__c); 

                String myMashKey = newEsr.Employee__c + myOccReq.SourceRecordType__c; 

                if(myOccReq.SourceRecordType__c == 'Medical, Hearing and Vision') {
                    myMashKey += myOccReq.SourceTestType__c; 
                }

                system.debug('Mashkey from ESR ' + myMashKey); 

                system.debug('HELPER Revsys_EmpSpecReqHelper applyEmpResSumDataToNewCertRecs-800');   

                EmployeeResultSummary__c myEmResSum = myErsByMashKeyMap.get(myMashKey); 

                if(myEmResSum != null) { 

                    system.debug('HELPER Revsys_EmpSpecReqHelper applyEmpResSumDataToNewCertRecs-900');   
                    system.debug('##### myOccReq.SourceRecordType__c ' + myOccReq.SourceRecordType__c); 

                    // What type of record is this? 

                    // MEDICAL HEARING & VISION 
                    if(myOccReq.SourceRecordType__c == Label.RevSys_EmpResSumm_RT_Label_Medical) {
                        newEsr = processMedicalHearingAndVision(newEsr, myOccReq, myEmResSum); 
                    } 

                    // EMPLOYEE HISTORY
                    else if(myOccReq.SourceRecordType__c == Label.RevSys_EmpResSumm_RT_Label_EmpHistory) {
                        newEsr = processEmployeeHistory(newEsr, myEmResSum); 
                    } 

                    // MOTOR VEHICLE REVIEW 
                    else if(myOccReq.SourceRecordType__c == Label.RevSys_EmpResSumm_RT_Label_Motor) {
                        newEsr = processMotorVehicleReview(newEsr, myOccReq, myEmResSum); 
                    }   

                    system.debug('HELPER Revsys_EmpSpecReqHelper applyEmpResSumDataToNewCertRecs-1000');   

                } 

            }  // END FOR LOOP THRU ESR 

        }

        // now we can build the SelectorWrapper to send back 
        List<SObject> mySObjectList = new List<SObject>(); 
        mySObjectList.addAll(newEsrList); 

        SelectorWrapper myWrap = new SelectorWrapper(wrapErrMsg, mySObjectList); 

        system.debug('HELPER Revsys_EmpSpecReqHelper applyEmpResSumDataToNewCertRecs-End'); 
        system.debug('newEsrList  ' + newEsrList); 
        return myWrap; 
    }

    /**
    *————————————————————————————————————————————————————
    * @Name: processMedicalHearingAndVision
    * @Description - Processes Medical Hearing & Vision Records * 
    * 
    * @param    EmployeeSpecificRequirement     theEmSpecReq 
    *           EmploymentResultSummary         theEmResSum 
    *                                            
    * @returns  EmployeeSpecificRequirement     theEmSpedReq
    *————————————————————————————————————————————————————
    **/
    public static EmployeeSpecificRequirement__c processMedicalHearingAndVision(EmployeeSpecificRequirement__c  theEmSpecReq,
                                                                                OccupationRequirement__c        theOccReq,
                                                                                EmployeeResultSummary__c        theEmResSum)  {   
        system.debug('HELPER Revsys_EmpSpecReqHelper processMedicalHearingAndVision-Start');  



        if(theEmSpecReq.LastFulfilledDate__c == null ||
           theEmSpecReq.LastFulfilledDate__c <  theEmResSum.EvaluationDate__c) {

            
            theEmSpecReq.LastFulfilledDate__c = theEmResSum.EvaluationDate__c; 

            if(theOccReq.SourceTestType__c == Label.RevSys_Generic_Hearing_Test) { 
                
                theEmSpecReq = processHearing(theEmSpecReq,theEmResSum); 
            } 

            else if(theOccReq.SourceTestType__c == Label.RevSys_Generic_Medical_Examination) { 
                
                theEmSpecReq = processMedical(theEmSpecReq,theEmResSum); 
            }

            else if(theOccReq.SourceTestType__c == Label.RevSys_Generic_Vision_Test) {
                
                theEmSpecReq = processVision(theEmSpecReq,theEmResSum); 
            } 
        }

        system.debug('HELPER Revsys_EmpSpecReqHelper processMedicalHearingAndVision-End');  

        return theEmSpecReq; 
    }
    /**
    *————————————————————————————————————————————————————
    * @Name: processMedical
    * @Description - Processes Medical Hearing & Vision Records * 
    * 
    * @param    EmployeeSpecificRequirement     theEmSpecReq 
    *           EmploymentResultSummary         theEmResSum 
    *                                            
    * @returns  EmployeeSpecificRequirement     theEmSpedReq
    *————————————————————————————————————————————————————
    **/
    public static EmployeeSpecificRequirement__c processMedical(EmployeeSpecificRequirement__c  theEmSpecReq,
                                                                EmployeeResultSummary__c        theEmResSum)  {  

        system.debug('HELPER Revsys_EmpSpecReqHelper processMedical-Start'); 

        if(theEmResSum.Result__c == Label.RevSys_ESR_Result_Meets_Medical_Standards)
        {
                theEmSpecReq.ReportStatus__c = Label.RevSys_Generic_Pass;
        }
        else if(theEmResSum.Result__c == Label.RevSys_ESR_Result_DN_Meet_Medical_Standards)
        {
                theEmSpecReq.ReportStatus__c = Label.RevSys_Generic_Fail;
        }
        else if(theEmResSum.Result__c == Label.RevSys_ESR_Result_Pending_Return_of_Exam_Results)
        {
                theEmSpecReq.ReportStatus__c = Label.RevSys_Generic_Pending;
        }    

        system.debug('HELPER Revsys_EmpSpecReqHelper processMedical-End'); 
        return theEmSpecReq; 
    }
    /**
    *————————————————————————————————————————————————————
    * @Name: processHearing
    * @Description - Processes Medical Hearing & Vision Records * 
    * 
    * @param    EmployeeSpecificRequirement     theEmSpecReq 
    *           EmploymentResultSummary         theEmResSum 
    *                                            
    * @returns  EmployeeSpecificRequirement     theEmSpedReq
    *————————————————————————————————————————————————————
    **/
    public static EmployeeSpecificRequirement__c processHearing(EmployeeSpecificRequirement__c  theEmSpecReq,
                                                                      EmployeeResultSummary__c  theEmResSum)  {  

        system.debug('HELPER Revsys_EmpSpecReqHelper processHearing-Start'); 
    
        if(theEmResSum.Result__c == Label.Revsys_Generic_no_restrictions ||
           theEmResSum.Result__c == Label.RevSys_Generic_Restrictions_Hearing) {

            theEmSpecReq.Restrictions__c = theEmResSum.Result__c == Label.RevSys_Generic_Restrictions_Hearing ?  theEmResSum.RestrictionType__c : null;
            theEmSpecReq.ReportStatus__c = Label.RevSys_Generic_Pass;
        }
        else if(theEmResSum.Result__c == Label.RevSys_Medical_Failed_Hearing_Test) {
            theEmSpecReq.ReportStatus__c = Label.RevSys_Generic_Fail;
        }

        else if(theEmResSum.Result__c == Label.RevSys_ESR_Result_Pending_Return_of_Exam_Results) {
            theEmSpecReq.ReportStatus__c = Label.RevSys_Generic_Pending;
        }

        system.debug('HELPER Revsys_EmpSpecReqHelper processHearing-End'); 
        return theEmSpecReq; 
    }
    /**
    *————————————————————————————————————————————————————
    * @Name: processVision
    * @Description - Processes Medical Hearing & Vision Records * 
    * 
    * @param    EmployeeSpecificRequirement     theEmSpecReq 
    *           EmploymentResultSummary         theEmResSum 
    *                                            
    * @returns  EmployeeSpecificRequirement     theEmSpedReq
    *————————————————————————————————————————————————————
    **/
    public static EmployeeSpecificRequirement__c processVision(EmployeeSpecificRequirement__c  theEmSpecReq,
                                                               EmployeeResultSummary__c        theEmResSum)  {  

        system.debug('HELPER Revsys_EmpSpecReqHelper processVision-Start'); 

        // Results Pending 
        if(theEmResSum.Result__c == Label.RevSys_ESR_Result_Pending_Return_of_Exam_Results)
        {
            theEmSpecReq.ReportStatus__c = Label.RevSys_Generic_Pending;
        }

        // Vision Restrictions, Passed Color Vision Test  
        else if(theEmResSum.Result__c == Label.RevSys_Generic_Restrictions_Vision   && 
                theEmResSum.ColorVisionTestResult__c == Label.RevSys_Generic_Pass) 
        {
            theEmSpecReq.Restrictions__c = theEmResSum.RestrictionType__c;
            theEmSpecReq.ReportStatus__c = Label.RevSys_Generic_Pass;
        }

        // Vision Restrictions, Failed Color Vision Test, Passed Field Test 
        else if(theEmResSum.Result__c == Label.RevSys_Generic_Restrictions_Vision   && 
                theEmResSum.ColorVisionTestResult__c == Label.RevSys_Generic_Fail   && 
                theEmResSum.FieldTestResult__c == Label.RevSys_Generic_Pass) 
        {
            theEmSpecReq.Restrictions__c = theEmResSum.RestrictionType__c;
            theEmSpecReq.ReportStatus__c = Label.RevSys_Generic_Pass;
        }

        // No Restrictions, Passed Color Vision Test  
        else if(theEmResSum.Result__c == Label.Revsys_Generic_no_restrictions       && 
                theEmResSum.ColorVisionTestResult__c == Label.RevSys_Generic_Pass) 
        {
            theEmSpecReq.ReportStatus__c = Label.RevSys_Generic_Pass;
        }

        // No Restrictions, Failed Color Vision Test, Passed Field Test  
        else if(theEmResSum.Result__c == Label.Revsys_Generic_no_restrictions       && 
                theEmResSum.ColorVisionTestResult__c == Label.RevSys_Generic_Fail   && 
                theEmResSum.FieldTestResult__c == Label.RevSys_Generic_Pass) 
        {
            theEmSpecReq.ReportStatus__c = Label.RevSys_Generic_Pass;
        }

        // Everything else fails 
        else 
        {
            theEmSpecReq.ReportStatus__c = Label.RevSys_Generic_Fail;
        }

        system.debug('HELPER Revsys_EmpSpecReqHelper processVision-End'); 
        return theEmSpecReq; 
    }

    /**
    *————————————————————————————————————————————————————
    * @Name: processEmployeeHistory
    * @Description - Processes Medical Hearing & Vision Records * 
    * 
    * @param    EmployeeSpecificRequirement     theEmSpecReq 
    *           EmploymentResultSummary         theEmResSum 
    *                                            
    * @returns  EmployeeSpecificRequirement     theEmSpedReq
    *
    * CAUTION: The same logc exist in RevSys_EmployeeResultSummaryHelper - processEmploymentHistory
    * This code should be mergetd when updating this method. 
    *————————————————————————————————————————————————————
    **/
    public static EmployeeSpecificRequirement__c processEmployeeHistory(EmployeeSpecificRequirement__c  theEmSpecReq,
                                                                        EmployeeResultSummary__c        theEmResSum)  {  

        system.debug('HELPER Revsys_EmpSpecReqHelper processEmployeeHistory-Start'); 

        if(theEmSpecReq.LastFulfilledDate__c == null ||
           theEmSpecReq.LastFulfilledDate__c <  theEmResSum.EvaluationDate__c) {
            theEmSpecReq.LastFulfilledDate__c = theEmResSum.EvaluationDate__c; 

            if(theEmResSum.CanEmployeeBeCertified__c == Label.REVSYS_Generic_Yes) {
                theEmSpecReq.ReportStatus__c = Label.RevSys_Generic_Pass;
            }
            else if(theEmResSum.CanEmployeeBeCertified__c == Label.REVSYS_Generic_No) {
                theEmSpecReq.ReportStatus__c = Label.RevSys_Generic_Fail;
            }  
        }

        system.debug('HELPER Revsys_EmpSpecReqHelper processEmployeeHistory-End'); 
        return theEmSpecReq; 
    }

    /**
    *————————————————————————————————————————————————————
    * @Name: processMotorVehicleReview
    * @Description - Processes Medical Hearing & Vision Records * 
    * 
    * @param    EmployeeSpecificRequirement     theEmSpecReq 
    *           EmploymentResultSummary         theEmResSum 
    *                                            
    * @returns  EmployeeSpecificRequirement     theEmSpedReq
    *
    * CAUTION: The same logc exist in RevSys_EmployeeResultSummaryHelper - processMotorVehicleReview
    * This code should be mergetd when updating this method. 
    *————————————————————————————————————————————————————
    **/
    public static EmployeeSpecificRequirement__c processMotorVehicleReview(EmployeeSpecificRequirement__c  theEmSpecReq,
                                                                           OccupationRequirement__c        theOccReq,
                                                                           EmployeeResultSummary__c        theEmResSum)  {  
        system.debug('HELPER Revsys_EmpSpecReqHelper processMotorVehicleReview-Start'); 

        Boolean applyDate = false; 

        if(theOccReq.SourceTestType__c == Label.RevSys_Generic_State_Review) {
            if(theEmSpecReq.LastFulfilledDate__c == null ||
               theEmSpecReq.LastFulfilledDate__c < theEmResSum.StateReviewDate__c) {
                theEmSpecReq.LastFulfilledDate__c = theEmResSum.StateReviewDate__c; 
                applyDate = true; 
            }    
        }

        if(theOccReq.SourceTestType__c == Label.RevSys_Generic_National_Review) {
            if(theEmSpecReq.LastFulfilledDate__c == null ||
               theEmSpecReq.LastFulfilledDate__c < theEmResSum.NdrReviewDate__c) {
                theEmSpecReq.LastFulfilledDate__c = theEmResSum.NdrReviewDate__c; 
                applyDate = true; 
            } 
        }

        if(applyDate == true) {

            if(theEmResSum.Status__c == Label.RevSys_Generic_Pass) {
                theEmSpecReq.ReportStatus__c = Label.RevSys_Generic_Pass;
            }
            else if(theEmResSum.Status__c == Label.RevSys_Generic_Fail) {
                theEmSpecReq.ReportStatus__c = Label.RevSys_Generic_Fail;
            } 
            else if(theEmResSum.Status__c==Label.RevSys_Generic_Pending) {
                theEmSpecReq.ReportStatus__c = Label.RevSys_Generic_Pending;
            }
        }


        system.debug('HELPER Revsys_EmpSpecReqHelper processMotorVehicleReview-End'); 
        return theEmSpecReq; 
    }
}
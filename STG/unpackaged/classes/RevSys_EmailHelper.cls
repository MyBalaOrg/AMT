/**
*___________________________________________________
*@Name: 	RevSys_EmailHelper
*@Author: 	Hemanth Kesapragada
*@Created: 	Date: 12/05/2017
*@Used_By: 	SPARTN
*___________________________________________________
*@Description: Class to produce any email message that requires apex processing, such as those processing through a batch class
* 
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
* 05-10-2018 ETR-1217 Only send email if the supervisor's email address is on the Contact record 
* 05-11-2018 ETR-533  Add a BCC to the email message 
* 06-04-2018 ETR-1285 Combine DML updates 
**/
public with sharing class RevSys_EmailHelper {

	
	/**
    *————————————————————————————————————————————————————
    * @Name: employeeCert
    * @Description
    * Send email to supervisors and managers before 30,60 and 90 days of expiration date.
    * Update the email status on the EC records accordingly.
    * @param	List of Employee Certification records
    * @returns  void
    *————————————————————————————————————————————————————
    **/
	public static void employeeCert(List<EmployeeCertification__c> ecList) {
		//SETUP
		Set<Id> myEmployeeCertificationIdSet = new Set<Id>();
		Map<Date, BatchProcessParameter__mdt> batchProcesParam = new Map<Date, BatchProcessParameter__mdt>();
		List<Date> myParameterDateList  = new List<Date>();
		Map<Date, BatchProcessParameter__mdt> myParameterMap = new Map<Date, BatchProcessParameter__mdt>();
		List<EmployeeCertification__c> myEcToProcessList = new List<EmployeeCertification__c>();
		List<EmployeeCertification__c> myEcCheckNowList = new List<EmployeeCertification__c>();
		List<EmployeeCertification__c> myEcCheckLaterList = new List<EmployeeCertification__c>();
		List<EmployeeCertification__c> employeeCertificationUpdateList = new List<EmployeeCertification__c>();
		List<EmployeeCertification__c> empCertExpiredUpdated = new List<EmployeeCertification__c>();
		Set<Id> employeeIds = new Set<Id>();
		Set<String> templateNames = new Set<String>();
		Map<Id,Id> empSuperId = new Map<Id,Id>();
		Map<Id,Id> empManagerId = new Map<Id,Id>();
		

        // Capture the employees from Employee Certification records.
        // Also capture the employee certification records to update the Email Status
		if(ecList!=null) {
			for(EmployeeCertification__c ecObj : ecList) {
				myEmployeeCertificationIdSet.add(ecObj.Id);
				myEcToProcessList.add(ecObj);
				//related to supervisors
				employeeIds.add(ecObj.Employee__c);
			}

            // Get the Batch Process Parameter configuration records for batch processing.
            SelectorWrapper wrapper = BatchProcessParameterSelector.getBatchProcessParamRecords();
			if(wrapper!=null){
				//for each BPP records, load into map on the basis of the parameter date.
				for(BatchProcessParameter__mdt bppRec : (List<BatchProcessParameter__mdt>) wrapper.sObjectList) {
					Integer lengthOfPeriod = Integer.valueOf(bppRec.LengthOfPeriod__c);
					Date myParameterDate = AMTRAK_DateUtility.determineDate(bppRec.Frequency__c,lengthOfPeriod);
					templateNames.add(bppRec.TemplateAPIName__c);
					myParameterDateList.add(myParameterDate);
					myParameterMap.put(myParameterDate, bppRec);
				}

				if(!myParameterDateList.isEmpty()) {
					myParameterDateList.sort();					
				}

			}

            // Query and get the email template used for sending notifications for expiration
			Map<String,String> templateNameMap = new Map<String,String>();
			List<EmailTemplate> templates = [SELECT Id,DeveloperName FROM EmailTemplate WHERE DeveloperName IN: templateNames];
			for(EmailTemplate em : templates) {
				templateNameMap.put(em.DeveloperName, em.Id);
			}

            // Capture all the contact Ids in a list and gets relavant Supervisor and manager Ids.
			List<Id> contactIdList = new List<Id>();
			contactIdList.addAll(employeeIds);
			empSuperId = RevSys_SupervisorManagerHelper.retrieveSupervisorId(contactIdList);
			empManagerId = RevSys_SupervisorManagerHelper.retrieveManagerId(contactIdList);

            // Get the contacts related to Supervisors 

            Set<Id> mySupervisorIdSet = new Set<Id>(); 
            mySupervisorIdSet.addAll(empSuperId.values()); 
            mySupervisorIdSet.addAll(empManagerId.values()); 
            SelectorWrapper mySuperContWrap = ContactSelector.getContacts(mySupervisorIdSet); 
            Map<Id,Contact> myContactMap = mapContacts(mySuperContWrap.SObjectList); 
         

            //Get the ORG Wide email address to send out notifications.
			//Developer name defined in Custom Labels
			String orgWideEmailId = [SELECT Id, Address,DisplayName FROM OrgWideEmailAddress WHERE Address=:System.Label.RevSys_OrgWideEmailAddress].Id;  

            // For each parameter date, check against the expiration date and store the EC records 
            // in Lists for further processing. Example, EC records expiring first should be processed first.
            
            //PROCESSING LOGIC STARTS..
			
			List<Messaging.SingleEmailMessage> myMessageList = new List<Messaging.SingleEmailMessage>();
			if(!myParameterDateList.isEmpty()) {
				
				// check each parameter date 
				for(Date parameterDate : myParameterDateList) {
					
					// check to see if the expiration date is under the parameter date 
					for(EmployeeCertification__c ecObj : myEcToProcessList) {
						if(ecObj.ExpirationDate__c <= parameterDate) {
							myEcCheckNowList.add(ecObj);
						} else {
							myEcCheckLaterList.add(ecObj);
						}
					}
					
                    //Get the configuration record for each parameter date.
					BatchProcessParameter__mdt bppRecord;
					if(myParameterMap.containsKey(parameterDate)) {
						bppRecord = myParameterMap.get(parameterDate);
					}

                    // Single Email Message records are created based on the EC records for processing and
                    // the Batch Process Parameter records obtained above. 

                    if(!myEcCheckNowList.isEmpty()) {
						for(EmployeeCertification__c ecObj : myEcCheckNowList) {

                            // if the email status is blank or if it does not match that of the value we're checking
							// process the record. (The notification has not been sent)
							
							if(String.isBlank(ecObj.EmailStatus__c) || 
								(String.isNotBlank(ecObj.EmailStatus__c) && String.isNotBlank(bppRecord.SuccessStateValue__c) && 
									!ecObj.EmailStatus__c.equalsIgnoreCase(bppRecord.SuccessStateValue__c))) {
								
								Messaging.SingleEmailMessage messagingRec;
								String templateId = templateNameMap.get(bppRecord.TemplateAPIName__c);

                                //Notification needs to be sent to both Supervisor/Manager. Only One email if the same person.
								//Will be defailted to true if the employee has supervisor or manager.
                                
                                Id myManagerContId;
                                Id mySuperContId; 

                                Boolean hasSupervisor = false;
								if(empSuperId.containsKey(ecObj.Employee__c)) {

                                    hasSupervisor = true;

                                    mySuperContId = empSuperId.get(ecObj.Employee__c); 
                                    Boolean doesSuperHaveEmail = checkIfContactHasEmail(mySuperContId, myContactMap); 

                                    if(doesSuperHaveEmail == TRUE) {
                                        messagingRec = createMessage(empSuperId.get(ecObj.Employee__c),ecObj.Id,bppRecord.Subject__c,templateId,orgWideEmailId);
                                        myMessageList.add(messagingRec);
                                    }
								}
                                
								if(empManagerId.containsKey(ecObj.Employee__c)) {

                                    hasSupervisor = true;

                                    myManagerContId = empManagerId.get(ecObj.Employee__c); 

                                    if(myManagerContId != mySuperContId) {

                                        Boolean doesManagerHaveEmail = checkIfContactHasEmail(myManagerContId, myContactMap); 

                                        if(doesManagerHaveEmail == TRUE) {
                                            messagingRec = createMessage(empManagerId.get(ecObj.Employee__c),ecObj.Id,bppRecord.Subject__c,templateId,orgWideEmailId);
        									myMessageList.add(messagingRec);
                                        }
                                    }
								}
                                
								//Set the value to Email Status if the supervisor/Manager is present for an employee

                                if(hasSupervisor) {
									ecObj.EmailStatus__c = bppRecord.SuccessStateValue__c;
									
									if(ecObj.ExpirationDate__c==System.Today().addDays(-1)) {
        								ecObj.Status__c = RevSys_StaticUtility.EXPIRED;
        				                ecObj.ProcessFlag__c = System.Label.RevSys_EmpCert_ProcessFlag;
        							}
        							
									employeeCertificationUpdateList.add(ecObj);
								}
								else {
								    // We want to ensure we are setting all certifications to expired, regardless of the 
								    // state of their manager or supervisor 
							        if(ecObj.ExpirationDate__c==System.Today().addDays(-1)) {
        								ecObj.Status__c = RevSys_StaticUtility.EXPIRED;
        				                ecObj.ProcessFlag__c = System.Label.RevSys_EmpCert_ProcessFlag;  
        				                employeeCertificationUpdateList.add(ecObj);
							        }
								}
							}
						}
					}

					//Clear of the existing processing list and ready the next set of records ready for Expiration
					myEcToProcessList.clear();
					myEcToProcessList.addAll(myEcCheckLaterList);
					myEcCheckLaterList.clear();
					myEcCheckNowList.clear();
					
				}   // End of working the Dates (line 107)
			}

			Boolean isError = false;
            if(!myMessageList.isEmpty()) {
                
                system.debug('SENDING EMAIL MESSAGES'); 
                
                Messaging.SendEmailResult[] emailResult = Messaging.sendEmail(myMessageList,true);

                for(Messaging.SendEmailResult eR : emailResult) {
					if(!eR.isSuccess()) {
						isError = true;
						break;
					}
				}
			}

            //Update the email status field only if there is not failure in the Email notifications.
            
            system.debug('UPDATING EMPLOYEE CERTIFICATIONS'); 
            system.debug('THE NUMBER OF UPDATED EMPLOYEE CERTIFICATIONS IS ' + employeeCertificationUpdateList.size()); 
            
            if(!isError) {
                Database.update(employeeCertificationUpdateList);
            }
		}
	}

    /**
    *————————————————————————————————————————————————————
    * @Name: createMessage
    * @Description
    * Create Sinle Email Messages records based on the values passed
    * @param	SupOrManagerId -  COntact Id of the Manager
    *			ecId  -  Id of the Employee Certification record
    *			subject -  Subject of the email -  Sent from the configuration in Batch Process Parameter custom metadata
    *			templateId - Id of the HTML Email Template to be used
    *			orgWideEmailId -  Id of the Org wide email address to be used as from address.
    * @returns  Messaging.SingleEmailMessage		instance of Single Email Message class
    *————————————————————————————————————————————————————
    **/
	public static Messaging.SingleEmailMessage createMessage(String supOrManagerId,String ecId,String subject,String templateId,String orgWideEmailId) {

        List<String> myBccList = new List<String>(); 
    
        Messaging.SingleEmailMessage sem = new Messaging.SingleEmailMessage();
		sem.setOrgWideEmailAddressId(orgWideEmailId);
		sem.setTargetObjectId(supOrManagerId);
		sem.setTemplateId(templateId);
		sem.setWhatId(ecId);

        if(label.SPARTN_BCC_Address.endsWith(label.Amtrak_Email_Address_Off_Indicator) == FALSE) { 
            myBccList.add(label.SPARTN_BCC_Address);
            sem.setBccAddresses(myBccList); 
        }

		return sem;
	}


    /**
    *————————————————————————————————————————————————————
    * @Name: mapContacts
    * @Description
    * Create a simple map of contats from a list
    * @param List<Contact> 
    * @return Map<Id,Contact> 
    *————————————————————————————————————————————————————
    **/
    public static Map<Id,Contact> mapContacts(List<Contact> theContactList) {

        Map<Id,Contact> myContactMap = new Map<Id,Contact>(); 

        for(Contact theContact :theContactList) { 
            myContactMap.put(theContact.Id,theContact); 

        }

        return myContactMap; 
    }

    /**
    *————————————————————————————————————————————————————
    * @Name: checkIfContactHasEmail
    * @Description
    * Determines if a contact has an email address
    * @param Id 
    * @param Map<Id,Contact> 
    * @return Boolean 
    *————————————————————————————————————————————————————
    **/
    public static Boolean checkIfContactHasEmail(Id theSupervisorId, Map<Id,Contact> theContactMap) {

        Contact myContact = theContactMap.get(theSupervisorId);  

        Boolean hasEmail = false; 

        if(myContact != null) {

            if(!String.isBlank(myContact.Email)) {
                hasEmail = true; 
            } 
        }

        return hasEmail; 
   }
    

}
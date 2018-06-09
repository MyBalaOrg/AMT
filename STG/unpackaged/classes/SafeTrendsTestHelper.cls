/*
Class Name:     SafeTrendsTestHelper
Author:         Anupama Ajith
Created Date:   2/3/2017 
Description:    This class has all the methods needed to provide data to all the test classes in Safe Trends
*/
 
@isTest(SeeAllData=false)
public with sharing class SafeTrendsTestHelper
{
  //Method to create test users
  public static User createUser(String userName, String lastName, String profileName, String roleName, String email, String federationId, String employeeNumber){

       Profile profile = [SELECT Id FROM Profile WHERE Name =: profileName];
       UserRole role = [SELECT Id FROM UserRole WHERE Name =: RoleName]; 
       
       //Create sample users
       User user= new User(Alias = 't'+lastName, Email=email, 
            EmailEncodingKey='UTF-8', LastName= lastName ,FirstName='Test', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = profile.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName= userName, UserRoleId=role.Id, FederationIdentifier= federationId, EmployeeNumber=employeeNumber);   
            
       insert user; 
       User testUser = [SELECT UserRoleId, Process__c,EmployeeNumber FROM User WHERE email =: user.email];
       system.debug('User Role is '+roleName+' and Process is '+user.Process__c);
       system.debug('From the database: Inserted User Role is '+testUser.UserRoleId+' and Process is '+testUser.Process__c);
       return user;    
  }
  
  //Method to create test process
  public static Process__c createProcess(String processName){
       Process__c process = new Process__c();
       process.Business_Line__c = 'Backshop';
       process.name = processName;
       process.Region__c = 'Backshops';
       process.active_observers__c = 0;
       insert process;
       return process;
  }
  
  //Method to create test location
  public static Location__c createLocation(Process__c process){
       Id recordTypeId_loc= [SELECT Id FROM RecordType WHERE sobjectType='Location__c' AND DeveloperName = 'Location'].Id;
       Id processId = [SELECT Id FROM Process__c WHERE name =: process.Name].id;
       Location__c location = new Location__c();
       location.name = 'Test Central';
       location.RecordTypeId = recordTypeId_loc;
       location.Process__c = processId;
       insert location;
       system.debug('location is '+location.id);
       return location;
  }
  
  //Method to create test area
  public static Location__c createArea(Process__c process, Location__c location){
       Id recordTypeId_area = [SELECT Id FROM RecordType WHERE sobjectType='Location__c' AND DeveloperName = 'Area'].Id;
       Location__c area = new Location__c();
       area.name = 'Test Area';
       area.RecordTypeId = recordTypeId_area;
       area.Process__c = process.Id;
       area.Location__c = location.Id;
       insert area;
       return area;
  }
  
  //Method to create test SBI
  public static SBI__c createSBI(String sbiName){
       SBI__c sbi = new SBI__c();
       sbi.name = sbiName;
       sbi.Category__c = '1.0 Body Attention/Position';
       sbi.department__c = 'Office Environment;Mechanical;Transportation';
       insert sbi;
       return sbi;
  }     
     
    
  //Method to create test observation
  //Method commented out since it is not currently in use as of 4/3/2017 mpaquin@goaldc.com
  /*
  public static Observation__c createObservation(String user, String process, String location){
       Id userId = [SELECT id FROM User WHERE Name =: user].id;
       Id processId = [SELECT id FROM Process__c WHERE Name =: process].id;
       Id locationId = [SELECT id FROM Location__c WHERE Name =: location].id;
       ID recordTypeId_obs = [SELECT Id FROM RecordType WHERE sobjectType='Observation__c' AND DeveloperName = 'Observations'].Id;
       Observation__c observation = new Observation__c();
       observation.RecordTypeId = recordTypeId_obs;
       observation.Observer_ID__c = userId;
       observation.Number_of_Workers_Observed__c = 2;
       observation.date__c = Date.Today();
       observation.process__c = processId;
       observation.location__c = locationId;
       observation.department__c = 'Mechanical';
       observation.craft__c= 'Mechanical';
       insert observation;
       return observation;
 
  }     
 */          
  //Method to create test findings
  //Method commented out since it is not currently in use as of 4/3/2017 mpaquin@goaldc.com
  /*
  public static List<finding__c> createFindings(Observation__c observation, String sbi1, String sbi2){           
       Id sbiId1 = [SELECT id FROM SBI__c WHERE Name =: sbi1].id;
       Id sbiId2= [SELECT id FROM SBI__c WHERE Name =: sbi2].id; 
       List<Finding__c> findings = new List<Finding__c>();
       Finding__c finding1 = new Finding__c();
       finding1.Observation__c = observation.id;
       finding1.SBI_Name__c = sbiId1;
       finding1.Safe_Checkbox__c= true;
       finding1.At_Risk_Checkbox__c= false;
       finding1.Behavior__c = 'Enabled';
       findings.add(finding1);
       
       Finding__c finding2 = new Finding__c();
       finding2.Observation__c = observation.id;
       finding2.SBI_Name__c = sbiId2;
       finding2.At_Risk_Checkbox__c= true;
       finding2.Safe_Checkbox__c= false;
       finding2.Behavior__c = 'Enabled';
       finding2.while__c = 'Test while';
       finding2.was__c = 'Test was';
       finding2.Because__c = 'Test Because';
       finding2.Solution__c = 'Test Solution';
       finding2.try__c = 'Test try';
       findings.add(finding2);
       
       insert findings;
       return findings;
  }
 */

  //Method to create test observation string
  public static String createObservationString(User user, Location__c location){
       date today=system.today();
       string observationDate  =today.format();
      //String observationDate = String.valueOf(system.today().format('MM/DD/YYYY'));
      system.debug('observationDate '+observationDate);
      String observation = user.id+'~'+user.id+'~'+location.id+'~'+null+'~'+'4'+'~'+observationDate+'~'+'Mechanical'+'~'+'Mechanical'+'~'+'7am - 3pm'+'~'+'Comments';           
       return observation;
  }

  //Method to create test findings string
  public static String createFindingsString(SBI__c sbi){
       String finding = sbi.id+'~'+'risk'+'~'+'Enabled'+'~'+'while'+'~'+'was'+'~'+'because'+'~'+'solution'+'~'+'try'; 
       return finding;
  }
    
    //Method to create process team
    public static Process_Team__c createProcessTeam(Process__c process, Contact contact, String teamRole, String teamMemberStatus){        
        Process_Team__c pt = new Process_Team__c();
        pt.Process__c = process.Id;
        pt.Contact__c = contact.Id;
        pt.Team_Role__c = teamRole;
        pt.Team_Member_Status__c = teamMemberStatus;           
        insert pt;
        return pt;
    }
    
    //Method to create Contact
    public static Contact createContact(String firstName,  String lastName, Decimal personnelNumber){        
        Contact contact = new Contact();
        contact.FirstName = firstName;
        contact.LastName = lastName;
        contact.Personnel_Number__c = personnelNumber;
        insert contact;         
        return contact;
    }    
    
    public static Observation__c createObservation(Process__c process,  Process_Team__c pt, Location__c location, Location__c area){
      
       
       Observation__c observation = new Observation__c();
       observation.RecordTypeId = Revsys_StaticUtility.OBSERVATION_OBSERVATIONS_RECTYPE_ID; 
       observation.Observer_ID_Process_Team__c = pt.Id;
       observation.Number_of_Workers_Observed__c = 2;
       observation.date__c = Date.Today();
       observation.process__c = process.Id;
       observation.location__c = location.Id;
        observation.Area__c = area.Id;
       observation.department__c = 'Mechanical';
       //observation.craft__c= 'Mechanical';
       insert observation;
       return observation;
    }        
        
  
}
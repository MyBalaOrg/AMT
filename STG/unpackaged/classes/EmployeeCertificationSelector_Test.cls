/**
*___________________________________________________
*@Name:     EmployeeCertificationSelector_Test
*@Author:   Chuck Walley
*@Created:  Date: April 8, 2018
*@Used_By:  SPARTN
*___________________________________________________
*@Description: Test for EmployeeCertificationSelector
* 
*___________________________________________________
*@Changes: 
* 05-29-2018 [Boom Bertetti] updated test_getEmpCertByEmpIds
**/
@isTest
public class EmployeeCertificationSelector_Test {   
    
   
    //Creating Test Data
    @TestSetup
    public static void loadTestData() {

        Revsys_TestDataHelper2.buildTestData();  

        // Get all Contact records
        QueryUtilityWrapper myQuWrap = QueryUtility.beginDynamicQuery(RevSys_StaticUtility.OBJAPI_CONTACT);   
        String myQuery = myQuWrap.QueryString; 
        List<Contact> myEmpList = Database.query(myQuery); 

        Map<String,Contact> myEmpByFirstNameMap = new Map<String,Contact>(); 

        for(Contact myEmp :myEmpList) {
            myEmpByFirstNameMap.put(myEmp.FirstName, myEmp); 
        }

        // Certifications
        myQuWrap = QueryUtility.beginDynamicQuery(RevSys_StaticUtility.OBJAPI_OCCUPATION_CERTIFICATION);   
        myQuery = myQuWrap.QueryString; 
        List<OccupationCertification__c> myOcList = Database.query(myQuery); 

        Map<String,OccupationCertification__c> myOcByNameMap = new Map<String,OccupationCertification__c>(); 

        for(OccupationCertification__c myOc :myOcList) {
            myOcByNameMap.put(myOc.Name, myOc); 
        }

        Contact myPeep = myEmpByFirstNameMap.get('Amy'); 
        OccupationCertification__c myCert = myOcByNameMap.get('Conductor Certification'); 


        EmployeeCertification__c myEmpCert = new EmployeeCertification__c 
        (  
            RecordTypeId = Revsys_StaticUtility.EMPCERT_SPARTNCERT_RECTYPE_ID, 
            Employee__c         =  myPeep.Id,
            Certification__c    =  myCert.Id,
            Status__c           = 'Pending',
            Archived__c = false,
            CertificationNumber__c = '1'
        );
       
        INSERT myEmpCert; 

    }

    /*************************************************************************
    Test 1:   test_getEmpCertification
    *************************************************************************/
    private static testmethod void test_getEmpCertification() {

         
        // Get the Emp Cert Record 
        QueryUtilityWrapper myQuWrap = QueryUtility.beginDynamicQuery('EmployeeCertification__c');   
        String myQuery = myQuWrap.QueryString; 
        List<EmployeeCertification__c> myEcList = Database.query(myQuery); 

        EmployeeCertification__c myEc = myEcList[0]; 

        Set<Id> myIdSet = new Set<Id>(); 

        myIdSet.add(myEc.Id); 

        // Test Good 

        EmployeeCertificationSelector.DoFailTest = FALSE; 

        SelectorWrapper myWrap = EmployeeCertificationSelector.getEmpCertification(myIdSet);

        system.debug('myWrap.ErrorMessage  ' + myWrap.ErrorMessage); 
        system.assertEquals(null,myWrap.ErrorMessage); 
        system.assertEquals(1,myWrap.SObjectList.size() ); 

        // Test Bad 

        EmployeeCertificationSelector.DoFailTest = TRUE; 

        myWrap = EmployeeCertificationSelector.getEmpCertification(myIdSet);

        system.assertNotEquals(null,myWrap.ErrorMessage); 
        system.assertEquals(0,myWrap.SObjectList.size() ); 
    }

    /*************************************************************************
    Test 2:   test_getOccCertRelated
    *************************************************************************/
    private static testmethod void test_getOccCertRelated() {

         
        // Get the Occupation Certification Records 
        QueryUtilityWrapper myQuWrap = QueryUtility.beginDynamicQuery('OccupationCertification__c');   
        String myQuery = myQuWrap.QueryString; 
        List<OccupationCertification__c> myList = Database.query(myQuery); 

        Set<Id> myIdSet = new Set<Id>(); 

        for(OccupationCertification__c myRec :myList) {
            myIdSet.add(myRec.Id); 
        }

        // Test Good 

        EmployeeCertificationSelector.DoFailTest = FALSE; 

        SelectorWrapper myWrap = EmployeeCertificationSelector.getOccCertRelated(myIdSet);

        system.debug('myWrap.ErrorMessage  ' + myWrap.ErrorMessage); 
        system.assertEquals(null,myWrap.ErrorMessage); 
        system.assertEquals(1,myWrap.SObjectList.size() ); 

        // Test Bad 

        EmployeeCertificationSelector.DoFailTest = TRUE; 

        myWrap = EmployeeCertificationSelector.getOccCertRelated(myIdSet);

        system.assertNotEquals(null,myWrap.ErrorMessage); 
        system.assertEquals(0,myWrap.SObjectList.size() ); 
    }

    /*************************************************************************
    Test 3:   test_getActiveEmpCert
    *************************************************************************/
    private static testmethod void test_getActiveEmpCert() {

         
        // Get the Occupation Certification Records 
        QueryUtilityWrapper myQuWrap = QueryUtility.beginDynamicQuery('OccupationCertification__c');   
        String myQuery = myQuWrap.QueryString; 
        List<OccupationCertification__c> myList = Database.query(myQuery); 

        Set<Id> myIdSet = new Set<Id>(); 

        for(OccupationCertification__c myRec :myList) {
            myIdSet.add(myRec.Id); 
        }

        // Test Good 

        EmployeeCertificationSelector.DoFailTest = FALSE; 

        SelectorWrapper myWrap = EmployeeCertificationSelector.getActiveEmpCert(myIdSet);

        system.debug('myWrap.ErrorMessage  ' + myWrap.ErrorMessage); 
        system.assertEquals(null,myWrap.ErrorMessage); 
        system.assertEquals(0,myWrap.SObjectList.size() ); 

        // Test Bad 

        EmployeeCertificationSelector.DoFailTest = TRUE; 

        myWrap = EmployeeCertificationSelector.getActiveEmpCert(myIdSet);

        system.assertNotEquals(null,myWrap.ErrorMessage); 
        system.assertEquals(0,myWrap.SObjectList.size() ); 
    }

    /*************************************************************************
    Test 4:   test_getSupervisorEmpCert
    *************************************************************************/
    private static testmethod void test_getSupervisorEmpCert() {

         
        // Get all Contact records
        QueryUtilityWrapper myQuWrap = QueryUtility.beginDynamicQuery(RevSys_StaticUtility.OBJAPI_CONTACT);   
        String myQuery = myQuWrap.QueryString; 
        List<Contact> myEmpList = Database.query(myQuery); 

        Map<String,Contact> myEmpByFirstNameMap = new Map<String,Contact>(); 
        Set<Id> MyIdSet = new Set<Id>(); 

        for(Contact myEmp :myEmpList) {
            myEmpByFirstNameMap.put(myEmp.FirstName, myEmp); 
            MyIdSet.add(myEmp.Id); 
        }

        Contact myContact = myEmpByFirstNameMap.get('Amy'); 

        EmployeeCertification__c myNewSup = new EmployeeCertification__c
        (  
            RecordTypeId = Revsys_StaticUtility.EMPCERT_SPARTSUPV_RECTYPE_ID, 
            Employee__c = myContact.Id,
            Status__c   = 'Active',
            Archived__c = false
        );

        INSERT myNewSup;

        // Test Good 

        EmployeeCertificationSelector.DoFailTest = FALSE; 

        SelectorWrapper myWrap = EmployeeCertificationSelector.getSupervisorEmpCert(myIdSet);

        system.debug('myWrap.ErrorMessage  ' + myWrap.ErrorMessage); 
        system.assertEquals(null,myWrap.ErrorMessage); 
        system.assertEquals(1,myWrap.SObjectList.size() ); 

        // Test Bad 

        EmployeeCertificationSelector.DoFailTest = TRUE; 

        myWrap = EmployeeCertificationSelector.getSupervisorEmpCert(myIdSet);

        system.assertNotEquals(null,myWrap.ErrorMessage); 
        system.assertEquals(0,myWrap.SObjectList.size() ); 
    }

    /*************************************************************************
    Test 5:   test_getEccCertFromId
    *************************************************************************/
    private static testmethod void test_getEccCertFromId() {

         
        // Get the Emp Cert Record 
        QueryUtilityWrapper myQuWrap = QueryUtility.beginDynamicQuery('EmployeeCertification__c');   
        String myQuery = myQuWrap.QueryString; 
        List<EmployeeCertification__c> myEcList = Database.query(myQuery); 

        EmployeeCertification__c myEc = myEcList[0]; 

        Set<Id> myIdSet = new Set<Id>(); 

        myIdSet.add(myEc.Id); 

        // Test Good 

        EmployeeCertificationSelector.DoFailTest = FALSE; 

        SelectorWrapper myWrap = EmployeeCertificationSelector.getEccCertFromId(myEcList);

        system.debug('myWrap.ErrorMessage  ' + myWrap.ErrorMessage); 
        system.assertEquals(null,myWrap.ErrorMessage); 
        system.assertEquals(1,myWrap.SObjectList.size() ); 

        // Test Bad 

        EmployeeCertificationSelector.DoFailTest = TRUE; 

        myWrap = EmployeeCertificationSelector.getEccCertFromId(myEcList);

        system.assertNotEquals(null,myWrap.ErrorMessage); 
        system.assertEquals(0,myWrap.SObjectList.size() ); 

    }

    /*************************************************************************
    Test 6:   test_generateCertificationId
    *************************************************************************/
    private static testmethod void test_generateCertificationId() {

        // Test Good 

        EmployeeCertificationSelector.DoFailTest = FALSE; 

        SelectorWrapper myWrap = EmployeeCertificationSelector.generateCertificationId();

        system.debug('myWrap.ErrorMessage  ' + myWrap.ErrorMessage); 
        system.assertEquals(null,myWrap.ErrorMessage); 
        system.assertEquals(1,myWrap.SObjectList.size() ); 

        // Test Bad 

        EmployeeCertificationSelector.DoFailTest = TRUE; 

        myWrap = EmployeeCertificationSelector.generateCertificationId();

        system.assertNotEquals(null,myWrap.ErrorMessage); 
        system.assertEquals(0,myWrap.SObjectList.size() ); 

    }
    /*************************************************************************
    Test 7:   test_getEmpCertFromOccCertId
    *************************************************************************/
    private static testmethod void test_getEmpCertFromOccCertId() {

        // Get the Occupation Certification Records 
        QueryUtilityWrapper myQuWrap = QueryUtility.beginDynamicQuery('OccupationCertification__c');   
        String myQuery = myQuWrap.QueryString; 
        List<OccupationCertification__c> myList = Database.query(myQuery); 

        Set<Id> myIdSet = new Set<Id>(); 

        for(OccupationCertification__c myRec :myList) {
            myIdSet.add(myRec.Id); 
        }

        // Test Good 

        EmployeeCertificationSelector.DoFailTest = FALSE; 

        SelectorWrapper myWrap = EmployeeCertificationSelector.getEmpCertFromOccCertId(myIdSet);

        system.debug('myWrap.ErrorMessage  ' + myWrap.ErrorMessage); 
        system.assertEquals(null,myWrap.ErrorMessage); 
        system.assertEquals(1,myWrap.SObjectList.size() ); 

        // Test Bad 

        EmployeeCertificationSelector.DoFailTest = TRUE; 

        myWrap = EmployeeCertificationSelector.getEmpCertFromOccCertId(myIdSet);

        system.assertNotEquals(null,myWrap.ErrorMessage); 
        system.assertEquals(0,myWrap.SObjectList.size() ); 

    }

    /*************************************************************************
    Test 8:   test_getLatestEmployeeCertification
    *************************************************************************/
    private static testmethod void test_getLatestEmployeeCertification() {

        // Test Good 

        EmployeeCertificationSelector.DoFailTest = FALSE; 

        SelectorWrapper myWrap = EmployeeCertificationSelector.getLatestEmployeeCertification('1');

        system.debug('myWrap.ErrorMessage  ' + myWrap.ErrorMessage); 
        system.assertEquals(null,myWrap.ErrorMessage); 
        system.assertEquals(1,myWrap.SObjectList.size() ); 

        // Test Bad 

        EmployeeCertificationSelector.DoFailTest = TRUE; 

        myWrap = EmployeeCertificationSelector.getLatestEmployeeCertification('1');

        system.assertNotEquals(null,myWrap.ErrorMessage); 
        system.assertEquals(0,myWrap.SObjectList.size() ); 

    }

    /*************************************************************************
    Test 9:   test_getAllEmployeeCertification
    *************************************************************************/
    private static testmethod void test_getAllEmployeeCertification() {

        // Get the Emp Cert Record 
        QueryUtilityWrapper myQuWrap = QueryUtility.beginDynamicQuery('EmployeeCertification__c');   
        String myQuery = myQuWrap.QueryString; 
        List<EmployeeCertification__c> myEcList = Database.query(myQuery); 

        EmployeeCertification__c myEc = myEcList[0]; 

        Set<Id> myIdSet = new Set<Id>(); 

        myIdSet.add(myEc.Id); 

        // Test Good 

        EmployeeCertificationSelector.DoFailTest = FALSE; 

        SelectorWrapper myWrap = EmployeeCertificationSelector.getAllEmployeeCertification(myIdSet);

        system.debug('myWrap.ErrorMessage  ' + myWrap.ErrorMessage); 
        system.assertEquals(null,myWrap.ErrorMessage); 
        system.assertEquals(1,myWrap.SObjectList.size() ); 

        // Test Bad 

        EmployeeCertificationSelector.DoFailTest = TRUE; 

        myWrap = EmployeeCertificationSelector.getAllEmployeeCertification(myIdSet);

        system.assertNotEquals(null,myWrap.ErrorMessage); 
        system.assertEquals(0,myWrap.SObjectList.size() ); 

    }

    /*************************************************************************
    Test 10:   test_getEmpCertByCertAndEmpIds
    *************************************************************************/
    private static testmethod void test_getEmpCertByCertAndEmpIds() {
        // Get the Emp Cert Record 
        QueryUtilityWrapper myQuWrap = QueryUtility.beginDynamicQuery('EmployeeCertification__c');   
        String myQuery = myQuWrap.QueryString; 
        List<EmployeeCertification__c> myEcList = Database.query(myQuery); 

        EmployeeCertification__c myEc = myEcList[0]; 

        Set<Id> myIdSet = new Set<Id>(); 
        Set<Id> myCertIdSet = new Set<Id>(); 
        Set<Id> myEmplIdSet = new Set<Id>(); 

        myIdSet.add(myEc.Id); 
        myCertIdSet.add(myEc.Certification__c); 
        myEmplIdSet.add(myEc.Employee__c); 

        // Test Good 

        EmployeeCertificationSelector.DoFailTest = FALSE; 

        SelectorWrapper myWrap = EmployeeCertificationSelector.getEmpCertByCertAndEmpIds(myCertIdSet,myEmplIdSet );

        system.debug('myWrap.ErrorMessage  ' + myWrap.ErrorMessage); 
        system.assertEquals(null,myWrap.ErrorMessage); 
        system.assertEquals(1,myWrap.SObjectList.size() ); 

        // Test Bad 

        EmployeeCertificationSelector.DoFailTest = TRUE; 

        myWrap = EmployeeCertificationSelector.getEmpCertByCertAndEmpIds(myCertIdSet,myEmplIdSet );

        system.assertNotEquals(null,myWrap.ErrorMessage); 
        system.assertEquals(0,myWrap.SObjectList.size() ); 

    }

    /*************************************************************************
    Test 11:   test_getEmpCertByEmpIds
    *************************************************************************/
    private static testmethod void test_getEmpCertByEmpIds() {
        // Get the Emp Cert Record 
        QueryUtilityWrapper myQuWrap = QueryUtility.beginDynamicQuery('EmployeeCertification__c');   
        String myQuery = myQuWrap.QueryString; 
        List<EmployeeCertification__c> myEcList = Database.query(myQuery); 

        EmployeeCertification__c myEc = myEcList[0]; 

        Set<Id> myIdSet = new Set<Id>(); 
        Set<Id> myCertIdSet = new Set<Id>(); 
        Set<Id> myEmplIdSet = new Set<Id>(); 

        myIdSet.add(myEc.Id); 
        myCertIdSet.add(myEc.Certification__c); 
        myEmplIdSet.add(myEc.Employee__c); 

        // Test Good 

        EmployeeCertificationSelector.DoFailTest = FALSE; 

        SelectorWrapper myWrap = EmployeeCertificationSelector.getEmpCertByEmpIds(myEmplIdSet, '1');

        system.debug('myWrap.ErrorMessage  ' + myWrap.ErrorMessage); 
        system.assertEquals(null,myWrap.ErrorMessage); 
        system.assertEquals(1,myWrap.SObjectList.size() ); 

        // Test Bad 

        EmployeeCertificationSelector.DoFailTest = TRUE; 

        myWrap = EmployeeCertificationSelector.getEmpCertByEmpIds(myEmplIdSet, '1');

        system.assertNotEquals(null,myWrap.ErrorMessage); 
        system.assertEquals(0,myWrap.SObjectList.size() ); 

    }


    /*************************************************************************
    Test 12:   test_getByEmpIdAndCertType
    *************************************************************************/
    private static testmethod void test_getByEmpIdAndCertType() {
        // Get the Emp Cert Record 
        QueryUtilityWrapper myQuWrap = QueryUtility.beginDynamicQuery('EmployeeCertification__c');   
        String myQuery = myQuWrap.QueryString; 
        List<EmployeeCertification__c> myEcList = Database.query(myQuery); 

        EmployeeCertification__c myEc = myEcList[0]; 

        Set<String> myTypeSet = new Set<String>(); 
        Set<Id> myEmplIdSet = new Set<Id>(); 

        myTypeSet.add('Conductor'); 
        myEmplIdSet.add(myEc.Employee__c); 

        // Test Good 

        EmployeeCertificationSelector.DoFailTest = FALSE; 

        SelectorWrapper myWrap = EmployeeCertificationSelector.getByEmpIdAndCertType(myEmplIdSet,myTypeSet );

        system.debug('myWrap.ErrorMessage  ' + myWrap.ErrorMessage); 
        system.assertEquals(null,myWrap.ErrorMessage); 
        system.assertEquals(1,myWrap.SObjectList.size() ); 

        // Test Bad 

        EmployeeCertificationSelector.DoFailTest = TRUE; 

        myWrap = EmployeeCertificationSelector.getByEmpIdAndCertType(myEmplIdSet,myTypeSet );

        system.assertNotEquals(null,myWrap.ErrorMessage); 
        system.assertEquals(0,myWrap.SObjectList.size() ); 
    }

    /*************************************************************************
    Test 13:   test_getEmpCertByEmpId
    *************************************************************************/
    private static testmethod void test_getEmpCertByEmpId() {

        // Get the Occupation Certification Records 
        QueryUtilityWrapper myQuWrap = QueryUtility.beginDynamicQuery('OccupationCertification__c');   
        String myQuery = myQuWrap.QueryString; 
        List<OccupationCertification__c> myList = Database.query(myQuery); 

        Map<String,OccupationCertification__c> myOccCertMap = new Map<String,OccupationCertification__c>(); 

        for(OccupationCertification__c myRec :myList) {
            myOccCertMap.put(myRec.CertificationType__c, myRec);
        }

        OccupationCertification__c myStudEngCert = myOccCertMap.get('Student Engineer'); 

        // Get the Emp Cert Record 
        myQuWrap = QueryUtility.beginDynamicQuery('EmployeeCertification__c');   
        myQuery = myQuWrap.QueryString; 
        List<EmployeeCertification__c> myEcList = Database.query(myQuery); 

        EmployeeCertification__c myEc = myEcList[0]; 

        Set<Id> myIdSet = new Set<Id>(); 
        Set<Id> myCertIdSet = new Set<Id>(); 
        Set<Id> myEmplIdSet = new Set<Id>(); 

        myIdSet.add(myEc.Id); 
        myCertIdSet.add(myEc.Certification__c); 
        myEmplIdSet.add(myEc.Employee__c); 

        myEc.Certification__c =  myStudEngCert.Id; 

        UPDATE myEc; 

        // Test Good 

        EmployeeCertificationSelector.DoFailTest = FALSE; 

        SelectorWrapper myWrap = EmployeeCertificationSelector.getEmpCertByEmpId(myEc.Employee__c);

        system.debug('myWrap.ErrorMessage  ' + myWrap.ErrorMessage); 
        system.assertEquals(null,myWrap.ErrorMessage); 
        system.assertEquals(1,myWrap.SObjectList.size() ); 

        // Test Bad 

        EmployeeCertificationSelector.DoFailTest = TRUE; 

        myWrap = EmployeeCertificationSelector.getEmpCertByEmpId(myEc.Employee__c);

        system.assertNotEquals(null,myWrap.ErrorMessage); 
        system.assertEquals(0,myWrap.SObjectList.size() ); 

    }

    /*************************************************************************
    Test 13:   test_StaticUtility
    *************************************************************************/
    private static testmethod void test_StaticUtility() {

        EmployeeCertificationStaticUtility.TriggerErrorMessage = 'Ping'; 
    }
   
}
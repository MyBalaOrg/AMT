/**
*___________________________________________________
*@Name:     OccupationSpecificReqSelector
*@Author:   Chuck Walley
*@Created:  Date: 11/19/2017
*@Used_By:  Global 
*___________________________________________________
*@Description: Selector class for OccupationSpecificRequirement__c
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/
global with sharing class OccupationSpecificReqSelector {
    public Boolean DoFailTest = FALSE; 
    private Set<Id> observationIdSet;
    private Set<Id> findingIdsSet;
    private List<String> OsrFieldsList = new List<String>{'Id',
                                                          'Certification__c',
                                                          'Craft__c',
                                                          'Department__c',
                                                          'Frequency__c', 
                                                          'LengthOfPeriod__c', 
                                                          'Observation__c', 
                                                          'ObservationCraft2__c', 
                                                          'ObservationDepartment2__c', 
                                                          'RecordTypeId', 
                                                          'Requirement__c', 
                                                          'Source__c', 
                                                          'SourceRecordType__c', 
                                                          'SourceTestType__c', 
                                                          'Status__c', 
                                                          'Target__c', 
                                                          'TargetType__c', 
                                                          'TestName__c', 
                                                          'Test_Number__c',
                                                          'Violation__c'
                                                          };

    private String whereClause;
    private String orderBy;
    private String limitNumber;
    private String offsetNumber;
    private String recTypeId;
    private Set<String> deptNameSet;
    private Set<String> craftNameSet;
    private Set<Id> obsIdSet;
    private Set<Id> vioIdSet;
    private Set<Id> fkeyASet;
    private Set<Id> fkeyBSet;


    /**
    *————————————————————————————————————————————————————
    * @Name: genericQuery
    * @Description
    * Specifically returns records based on Observation Dept & 
    *                                       Observation Craft
    * 
    *————————————————————————————————————————————————————
    * @params   theObsIdSet         A set of Observation Ids  
    * @returns  SelectorWrapper     A wrapper class containing the errorMessage and the List 
    *————————————————————————————————————————————————————
    **/ 
    public SelectorWrapper genericQuery() {    

        system.debug('recTypeId ' + recTypeId );
        system.debug('obsIdSet '  + obsIdSet );

        String myErrorMessage;
        List<SObject> mySObjectList;

        String fields = String.join(OsrFieldsList, ',');
        String soqlStr = new QueryUtility().setSelectFields(OsrFieldsList)
                                            .setWhereClause(whereClause)
                                            .setObjectToSoql(Label.OBJAPI_OCCUPATION_SPECIFIC_REQUIREMENT)
                                            .setOrderBy(orderBy)
                                            .setLimit(limitNumber)
                                            .setOffSet(offsetNumber)
                                            .setSOQLString();  
        try {


            if(Test.isRunningTest() && DoFailTest) {
                soqlStr = soqlStr.replace('SELECT', 'FAIL') ;
            }

            mySObjectList = Database.query(soqlStr); 

            system.debug('mySObjectList ' + mySObjectList );

        } catch(QueryException qe) {

            system.debug(System.Label.SOQL_Query_Error + qe.getMessage());
            myErrorMessage = System.Label.QueryErrorSobjectException + qe.getMessage();
        }

        SelectorWrapper myWrap = new SelectorWrapper(myErrorMessage, mySObjectList); 

        return myWrap; 
    }

           

    /**
    *————————————————————————————————————————————————————
    * @Name: getSubQueryStr
    * @Description
    * Builds my dynamic query
    * 
    *————————————————————————————————————————————————————
    * @params   all Private Global Variables  
    * @returns  soqlStr     A dynamic query
    *————————————————————————————————————————————————————
    **/ 
    @TestVisible
    private static String getSubQueryStr(List<String> OsrFieldsList, 
                                                 String whereClause, 
                                                 String orderBy, 
                                                 String limitNumber, 
                                                 String offsetNumber, 
                                                 String relationshipName) {
        String soqlStr = new QueryUtility().setSelectFields(OsrFieldsList)
                                            .setWhereClause(whereClause)
                                            .setOrderBy(orderBy)
                                            .setLimit(limitNumber)
                                            .setOffSet(offsetNumber)
                                            .setRelationShipName(relationshipName)
                                            .setSOQLString();

        return soqlStr;
    }

    /**
    *————————————————————————————————————————————————————
    * @Name: getOsrObsRecords
    * @Description
    * Specifically returns records based on Observation Dept & 
    *                                       Observation Craft
    * 
    *————————————————————————————————————————————————————
    * @params   theDeptSet          A set of Department Names  
    *           theCraftSet         A set of Craft Names 
    * @returns  SelectorWrapper     A wrapper class containing the errorMessage and the List 
    *————————————————————————————————————————————————————
    **/ 
    public SelectorWrapper getOsrObsRecords(Set<String> theDeptSet, 
                                            Set<String> theCraftSet) {              

        recTypeId = OccupationSpecificReqStaticUtility.OCCSPECREQUIREMENT_DEPTCERT_FOR_OBS_RECTYPE_ID; 
        deptNameSet  = theDeptSet;
        craftNameSet = theCraftSet; 

        whereClause  = 'RecordTypeId = :recTypeId AND '; 
        whereClause += 'ObservationDepartment2__c IN :deptNameSet AND ObservationCraft2__c IN :craftNameSet';

        SelectorWrapper myWrap = genericQuery();

        return myWrap;  
    }
    /**
    *————————————————————————————————————————————————————
    * @Name: getOsrJunctCert
    * @Description
    * Specifically returns records based on Observation Dept & 
    *                                       Observation Craft
    * 
    *————————————————————————————————————————————————————
    * @params   theObsIdSet         A set of Observation Ids  
    * @returns  SelectorWrapper     A wrapper class containing the errorMessage and the List 
    *————————————————————————————————————————————————————
    **/ 
    public SelectorWrapper getOsrJunctCert(Set<Id> theCertIdSet, Set<Id> theReqIdSet) { 

        recTypeId = OccupationSpecificReqStaticUtility.OCCSPECREQUIREMENT_SPARTNCERT_RECTYPE_ID; 

        fkeyASet = new Set<Id>();
        fkeyBSet = new Set<Id>();
        fkeyASet.addAll(theCertIdSet);
        fkeyBSet.addAll(theReqIdSet);

        whereClause  = 'RecordTypeId = :recTypeId AND '; 
        whereClause += 'Certification__c IN :fkeyASet AND ';
        whereClause += 'Requirement__c   IN :fkeyBSet ';

        SelectorWrapper myWrap = genericQuery();

        system.debug('myWrap ' + myWrap);

        return myWrap;  
    }
    /**
    *————————————————————————————————————————————————————
    * @Name: getOsrJunctTarget
    * @Description
    * Specifically returns records based on Observation Dept & 
    *                                       Observation Craft
    * 
    *————————————————————————————————————————————————————
    * @params   theObsIdSet         A set of Observation Ids  
    * @returns  SelectorWrapper     A wrapper class containing the errorMessage and the List 
    *————————————————————————————————————————————————————
    **/ 
    public SelectorWrapper getOsrJunctTarget(Set<Id> theObsIdSet, Set<Id> theTgtIdSet) { 

        recTypeId = OccupationSpecificReqStaticUtility.OCC_SPEC_REQ_SPARTNTARGET_RECTYPE_ID; 

        fkeyASet = new Set<Id>();
        fkeyBSet = new Set<Id>();
        fkeyASet.addAll(theObsIdSet);
        fkeyBSet.addAll(theTgtIdSet);

        whereClause  = 'RecordTypeId = :recTypeId AND '; 
        whereClause += 'Observation__c IN :fkeyASet AND ';
        whereClause += 'Target__c      IN :fkeyBSet ';

        SelectorWrapper myWrap = genericQuery();

        system.debug('myWrap ' + myWrap);

        return myWrap;  
    }
    /**
    *————————————————————————————————————————————————————
    * @Name: getOsrObsByIdRecords
    * @Description
    * Specifically returns records based on Observation Dept & 
    *                                       Observation Craft
    * 
    *————————————————————————————————————————————————————
    * @params   theObsIdSet         A set of Observation Ids  
    * @returns  SelectorWrapper     A wrapper class containing the errorMessage and the List 
    *————————————————————————————————————————————————————
    **/ 
    public SelectorWrapper getOsrObsRecsById(Set<Id> theObsIdSet) { 

        recTypeId = OccupationSpecificReqStaticUtility.OCCSPECREQUIREMENT_DEPTCERT_FOR_OBS_RECTYPE_ID; 

        obsIdSet = new Set<Id>();
        obsIdSet.addAll(theObsIdSet);

        system.debug('obsIdSet ' + obsIdSet);

        whereClause  = 'RecordTypeId = :recTypeId AND '; 
        whereClause += 'Id IN :obsIdSet ';

        SelectorWrapper myWrap = genericQuery();

        system.debug('myWrap ' + myWrap);

        return myWrap;  
    }


}
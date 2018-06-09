/**
*___________________________________________________
*@Name: 	OccupationCertificationSelector
*@Author: 	Hemanth Kesapragada
*@Created: 	Date: 11/21/2017
*@Used_By: 	Global 
*___________________________________________________
*@Description: Selector class for OccupationCertification__c object 
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/
global with sharing class OccupationCertificationSelector {
    public static Boolean DoFailTest = FALSE; 
    /**
    *————————————————————————————————————————————————————
    * @Name: getTargets
    * @Description
    * Specifically returns records 
    * 
    *————————————————————————————————————————————————————
    * @params  	
    * @returns  SelectorWrapper		A wrapper class containing the errorMessage and the List 
    *————————————————————————————————————————————————————
    **/
    public static SelectorWrapper getTargets(Set<String> deptSet,String context) {  
        String myQuery; 

        String myErrorMessage; 
        List<OccupationCertification__c> occCertificationList = new List<OccupationCertification__c>(); 

        QueryUtilityWrapper myQuWrap = QueryUtility.beginDynamicQuery(Label.OBJAPI_OCCUPATION_CERTIFICATION);   
        if(myQuWrap.ErrorMessage == null) { 

            myQuery = myQuWrap.QueryString; 
            myQuery += System.Label.WHERE +' recordTypeId =\''+OccupationCertificationStaticUtility.OCCUPCERTIFICATION_SPARTNTARGET_RECTYPE_ID+'\''; 
            if(context == Label.OBJAPI_OCCUPATION_CERTIFICATION_TARGETTYPE_IS_OCCUPATION)
            {
                myQuery += ' '+System.Label.AND +' TargetType__c =\''+ Label.OBJAPI_OCCUPATION_CERTIFICATION_TARGETTYPE_IS_OCCUPATION +'\''; 
            }
            else if(context == Label.OBJAPI_OCCUPATION_CERTIFICATION_TARGETTYPE_IS_SUPERVISOR)
            {
                myQuery += ' '+System.Label.AND +' TargetType__c =\'' + Label.OBJAPI_OCCUPATION_CERTIFICATION_TARGETTYPE_IS_SUPERVISOR + '\''; 
                myQuery += ' '+System.Label.AND +' DivisionOfObservation__c = \'\''; 
            }
            myQuery += ' '+System.Label.AND+' status__c = \'Active\'';
            myQuery += ' '+System.Label.AND+' Department__c IN :  deptSet';
            if(Test.isRunningTest() && DoFailTest) {
                myQuery = myQuery.replace('SELECT', 'FAIL') ;
            }
            try {
                System.debug('&&&& myQuery '+myQuery);
                System.debug('&&&& deptSet '+deptSet);
                occCertificationList = Database.query(myQuery); 

            } catch(QueryException qe) {

                system.debug(System.Label.SOQL_Query_Error + qe.getMessage() );
                myErrorMessage = System.Label.QueryErrorSobjectException + qe.getMessage();
            }
        }

        SelectorWrapper myWrap = new SelectorWrapper(myErrorMessage, occCertificationList); 

        return myWrap;
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Name: getTargetsById
    * @Description
    * Specifically returns certificate records 
    * 
    *————————————————————————————————————————————————————
    * @params  	
    * @returns  SelectorWrapper		A wrapper class containing the errorMessage and the List 
    *————————————————————————————————————————————————————
    **/
    public static SelectorWrapper getTargetsById(Set<ID> OccCertSet) {  
        String myQuery; 

        String myErrorMessage; 
        List<OccupationCertification__c> occCertificationList = new List<OccupationCertification__c>(); 

        QueryUtilityWrapper myQuWrap = QueryUtility.beginDynamicQuery(Label.OBJAPI_OCCUPATION_CERTIFICATION);   
        if(myQuWrap.ErrorMessage == null) { 
            
            myQuery = myQuWrap.QueryString; 
            myQuery += System.Label.WHERE +' recordTypeId =\''+OccupationCertificationStaticUtility.OCCUPCERTIFICATION_SPARTNTARGET_RECTYPE_ID+'\''; 
            myQuery += ' '+System.Label.AND+' ID IN :  OccCertSet';
            if(Test.isRunningTest() && DoFailTest) {
                myQuery = myQuery.replace('SELECT', 'FAIL') ;
            }            
            try {
                
                occCertificationList = Database.query(myQuery); 

            } catch(QueryException qe) {

                system.debug(System.Label.SOQL_Query_Error + qe.getMessage() );
                myErrorMessage = System.Label.QueryErrorSobjectException + qe.getMessage();
            }
        }

        SelectorWrapper myWrap = new SelectorWrapper(myErrorMessage, occCertificationList); 
        return myWrap;
    }  

    /**
    *————————————————————————————————————————————————————
    * @Name: getCertifications
    * @Description
    * Specifically returns certificate records 
    * 
    *————————————————————————————————————————————————————
    * @params   
    * @returns  SelectorWrapper     A wrapper class containing the errorMessage and the List 
    *————————————————————————————————————————————————————
    **/
    public static SelectorWrapper getCertifications(Set<ID> OccCertSet) {  
        String myQuery; 

        String myErrorMessage; 
        List<OccupationCertification__c> occCertificationList = new List<OccupationCertification__c>(); 

        QueryUtilityWrapper myQuWrap = QueryUtility.beginDynamicQuery(Label.OBJAPI_OCCUPATION_CERTIFICATION);   
        if(myQuWrap.ErrorMessage == null) { 
            
            myQuery = myQuWrap.QueryString; 
            myQuery += System.Label.WHERE +' recordTypeId =\''+OccupationCertificationStaticUtility.OCCUPCERTIFICATION_SPARTNCERT_RECTYPE_ID+'\''; 
            myQuery += ' '+System.Label.AND+' status__c = \'Active\'';
            myQuery += ' '+System.Label.AND+' ID IN :  OccCertSet';
            if(Test.isRunningTest() && DoFailTest) {
                myQuery = myQuery.replace('SELECT', 'FAIL') ;
            }           
            try {
                
                occCertificationList = Database.query(myQuery); 

            } catch(QueryException qe) {

                system.debug(System.Label.SOQL_Query_Error + qe.getMessage() );
                myErrorMessage = System.Label.QueryErrorSobjectException + qe.getMessage();
            }
        }

        SelectorWrapper myWrap = new SelectorWrapper(myErrorMessage, occCertificationList); 
        return myWrap;
    }  

     /**
    *————————————————————————————————————————————————————
    * @Name: getCetificationTargets
    * @Description
    * Specifically returns certification targets 
    * 
    *————————————————————————————————————————————————————
    * @params   
    * @returns  SelectorWrapper     A wrapper class containing the errorMessage and the List 
    *————————————————————————————————————————————————————
    **/
    public static SelectorWrapper getCertificationTargets(Set<Id> occCertIdSet) {  
        String myQuery; 

        String myErrorMessage; 
        List<OccupationCertification__c> occCertificationList = new List<OccupationCertification__c>(); 

        QueryUtilityWrapper myQuWrap = QueryUtility.beginDynamicQuery(Label.OBJAPI_OCCUPATION_CERTIFICATION);   
        if(myQuWrap.ErrorMessage == null) { 

            myQuery = myQuWrap.QueryString; 
            myQuery += System.Label.WHERE +' recordTypeId =\''+OccupationCertificationStaticUtility.OCCUPCERTIFICATION_SPARTNTARGET_RECTYPE_ID+'\''; 
            myQuery += ' '+System.Label.AND+' TargetType__c = \''+Label.OBJAPI_OCCUPATION_CERTIFICATION_TARGETTYPE_IS_CERTIFICATION+'\'';
            myQuery += ' '+System.Label.AND+' ParentCertification__c in :occCertIdSet '; 
            myQuery += ' '+System.Label.AND+' Status__c = \'Active\'';
            if(Test.isRunningTest() && DoFailTest) {
                myQuery = myQuery.replace('SELECT', 'FAIL') ;
            } 
            try {
                
                occCertificationList = Database.query(myQuery); 

            } catch(QueryException qe) {

                system.debug(System.Label.SOQL_Query_Error + qe.getMessage() );
                myErrorMessage = System.Label.QueryErrorSobjectException + qe.getMessage();
            }
        }

        SelectorWrapper myWrap = new SelectorWrapper(myErrorMessage, occCertificationList); 

        return myWrap;
    }  
     /**
    *————————————————————————————————————————————————————
    * @Name: getViolationTargets
    * @Description
    * Specifically returns certification targets 
    * 
    *————————————————————————————————————————————————————
    * @params   
    * @returns  SelectorWrapper     A wrapper class containing the errorMessage and the List 
    *————————————————————————————————————————————————————
    **/
    public static SelectorWrapper getViolationTargets(Set<Id> occCertIdSet) {  
        String myQuery; 

        String myErrorMessage; 
        List<OccupationCertification__c> occCertificationList = new List<OccupationCertification__c>(); 

        QueryUtilityWrapper myQuWrap = QueryUtility.beginDynamicQuery(label.OBJAPI_OCCUPATION_CERTIFICATION);   
        if(myQuWrap.ErrorMessage == null) { 

            myQuery = myQuWrap.QueryString; 
            myQuery += System.Label.WHERE +' recordTypeId =\''+OccupationCertificationStaticUtility.OCC_CERT_SPARTN_VIOLATION_RECTYPE_ID+'\''; 
            myQuery += ' '+System.Label.AND+' Id in :occCertIdSet '; 
            myQuery += ' '+System.Label.AND+' Status__c = \'Active\'';
            if(Test.isRunningTest() && DoFailTest) {
                myQuery = myQuery.replace('SELECT', 'FAIL') ;
            }
            try {
                
                occCertificationList = Database.query(myQuery); 

            } catch(QueryException qe) {

                system.debug(System.Label.SOQL_Query_Error + qe.getMessage() );
                myErrorMessage = System.Label.QueryErrorSobjectException + qe.getMessage();
            }
        }

        SelectorWrapper myWrap = new SelectorWrapper(myErrorMessage, occCertificationList); 

        return myWrap;
    }  
    /**
    *————————————————————————————————————————————————————
    * @Name: getDeptCraftRecs
    * @Description
    * Specifically returns Dept/CraftForObs records 
    * 
    *————————————————————————————————————————————————————
    * @params   
    * @returns  SelectorWrapper     A wrapper class containing the errorMessage and the List 
    *————————————————————————————————————————————————————
    **/
    public static SelectorWrapper getDeptCraftRecs(Set<String> theDeptCodeSet) { 
                                                    
        String myQuery; 

        String myErrorMessage; 
        List<OccupationCertification__c> occCertificationList = new List<OccupationCertification__c>(); 

        QueryUtilityWrapper myQuWrap = QueryUtility.beginDynamicQuery(Label.OBJAPI_OCCUPATION_CERTIFICATION);   
        if(myQuWrap.ErrorMessage == null) { 

            myQuery = myQuWrap.QueryString; 
            myQuery += System.Label.WHERE + ' recordTypeId =\''+OccupationCertificationStaticUtility.OCCUPCERTIFICATION_DEPTCERT_FOR_OBS_RECTYPE_ID+'\''; 
            myQuery += ' '+System.Label.AND+' status__c = \'Active\'';
            myQuery += ' '+System.Label.AND+' Department__c IN :theDeptCodeSet ';
            if(Test.isRunningTest() && DoFailTest) {
                myQuery = myQuery.replace('SELECT', 'FAIL') ;
            }
            try {
                
                occCertificationList = Database.query(myQuery); 

            } catch(QueryException qe) {

                system.debug(System.Label.SOQL_Query_Error + qe.getMessage() );
                myErrorMessage = System.Label.QueryErrorSobjectException + qe.getMessage();
            }
        }

        SelectorWrapper myWrap = new SelectorWrapper(myErrorMessage, occCertificationList); 

        return myWrap;
    }
    
     /**
    *————————————————————————————————————————————————————
    * @Name: getactiveTargetforDeptCraft
    * @Description
    * Specifically returns Target Record
    * 
    *————————————————————————————————————————————————————
    * @params   
    * @returns  SelectorWrapper     A wrapper class containing the errorMessage and the List 
    *————————————————————————————————————————————————————
    **/
    /*public static SelectorWrapper getactiveSupervisorTargetforDeptCraft(Set<String> craftSet, Set<String> deptSet) { 
                                                    
        String myQuery; 
        String myErrorMessage; 
        List<OccupationCertification__c> occCertificationList = new List<OccupationCertification__c>(); 
 		String currentDate = AMTRAK_DateUtility.processDate(System.today());
        
        QueryUtilityWrapper myQuWrap = QueryUtility.beginDynamicQuery(RevSys_StaticUtility.OBJAPI_OCCUPATION_CERTIFICATION);   
        if(myQuWrap.ErrorMessage == null) { 

            myQuery = myQuWrap.QueryString; 
          //  myQuery += System.Label.WHERE + ' recordTypeId =\''+RevSys_StaticUtility.OCCUPCERTIFICATION_DEPTCERT_FOR_OBS_RECTYPE_ID+'\''; 
            myQuery += System.Label.WHERE+' status__c = \''+RevSys_StaticUtility.ACTIVE+'\'';
          	myQuery += ' '+System.Label.AND+' Craft__c IN :craftSet ';
          	myQuery += ' '+System.Label.AND+' Department__c IN :deptSet ';
            myQuery += ' '+System.Label.AND+' EndDate__c >= '+ currentDate;

            system.debug('myQueryOCCCERT$$' + myQuery );
            
            try {
                
                occCertificationList = Database.query(myQuery); 

            } catch(QueryException qe) {

                system.debug(System.Label.SOQL_Query_Error + qe.getMessage() );
                myErrorMessage = System.Label.QueryErrorSobjectException + qe.getMessage();
            }
        }

        SelectorWrapper myWrap = new SelectorWrapper(myErrorMessage, occCertificationList); 

        return myWrap;
    }*/
    /**
    *————————————————————————————————————————————————————
    * @Name: getAppliesToAllObsTargets
    * @Description
    * Specifically returns certification targets 
    * 
    *————————————————————————————————————————————————————
    * @params   
    * @returns  SelectorWrapper     A wrapper class containing the errorMessage and the List 
    *————————————————————————————————————————————————————
    **/
    public static SelectorWrapper getAppliesToAllObsTargets() {  
        String myQuery; 

        String myErrorMessage; 
        List<OccupationCertification__c> occCertificationList = new List<OccupationCertification__c>(); 

        QueryUtilityWrapper myQuWrap = QueryUtility.beginDynamicQuery(Label.OBJAPI_OCCUPATION_CERTIFICATION);   
        if(myQuWrap.ErrorMessage == null) { 

            myQuery = myQuWrap.QueryString; 
            myQuery += System.Label.WHERE +' recordTypeId =\''+OccupationCertificationStaticUtility.OCCUPCERTIFICATION_SPARTNTARGET_RECTYPE_ID+'\''; 
            myQuery += ' '+System.Label.AND+' Status__c = \'Active\'';
            if(Test.isRunningTest() && DoFailTest) {
                myQuery = myQuery.replace('SELECT', 'FAIL') ;
            }
            try {
                
                occCertificationList = Database.query(myQuery); 

            } catch(QueryException qe) {

                system.debug(System.Label.SOQL_Query_Error + qe.getMessage() );
                myErrorMessage = System.Label.QueryErrorSobjectException + qe.getMessage();
            }
        }

        SelectorWrapper myWrap = new SelectorWrapper(myErrorMessage, occCertificationList); 

        return myWrap;
    }  
   
    /**
    *————————————————————————————————————————————————————
    * @Name: getOccCertByName
    * @Description
    * Specifically frames the query 
    * 
    *————————————————————————————————————————————————————
    * @params   
    * @returns  String      A method to frame the query
    *————————————————————————————————————————————————————
    **/
    
    public static SelectorWrapper getOccCertByName(Set<String> OccCertNameSet) {
        
        String myQuery; 

        String myErrorMessage; 
        List<OccupationCertification__c> occCertificationList = new List<OccupationCertification__c>(); 

        QueryUtilityWrapper myQuWrap = QueryUtility.beginDynamicQuery(Label.OBJAPI_OCCUPATION_CERTIFICATION);   
        if(myQuWrap.ErrorMessage == null) { 

            myQuery = myQuWrap.QueryString; 
            myQuery += System.Label.WHERE + ' Name IN :OccCertNameSet '; 
            if(Test.isRunningTest() && DoFailTest) {
                myQuery = myQuery.replace('SELECT', 'FAIL') ;
            }
            try {
                
                occCertificationList = Database.query(myQuery); 

            } catch(QueryException qe) {

                system.debug(System.Label.SOQL_Query_Error + qe.getMessage() );
                myErrorMessage = System.Label.QueryErrorSobjectException + qe.getMessage();
            }
        }

        SelectorWrapper myWrap = new SelectorWrapper(myErrorMessage, occCertificationList); 

        return myWrap;
    }
   
    /**
    *————————————————————————————————————————————————————
    * @Name: getTargetsByViolation
    * @Description
    * Specifically returns certification targets 
    * 
    *————————————————————————————————————————————————————
    * @params   
    * @returns  SelectorWrapper     A wrapper class containing the errorMessage and the List 
    *————————————————————————————————————————————————————
    **/
    public static SelectorWrapper getTargetsByViolation(Set<Id> violationIdSet) {  
        String myQuery; 

        String myErrorMessage; 
        List<OccupationCertification__c> occCertificationList = new List<OccupationCertification__c>(); 

        QueryUtilityWrapper myQuWrap = QueryUtility.beginDynamicQuery(Label.OBJAPI_OCCUPATION_CERTIFICATION);   
        if(myQuWrap.ErrorMessage == null) { 

            myQuery = myQuWrap.QueryString; 
            myQuery += System.Label.WHERE +' recordTypeId =\''+OccupationCertificationStaticUtility.OCC_CERT_SPARTN_VIOLATION_RECTYPE_ID+'\''; 
            myQuery += ' '+System.Label.AND+' Violation__c in :violationIdSet '; 

            if(Test.isRunningTest() && DoFailTest) {
                myQuery = myQuery.replace('SELECT', 'FAIL') ;
            }
            try {
                
                occCertificationList = Database.query(myQuery); 

            } catch(QueryException qe) {

                system.debug(System.Label.SOQL_Query_Error + qe.getMessage() );
                myErrorMessage = System.Label.QueryErrorSobjectException + qe.getMessage();
            }
        }

        SelectorWrapper myWrap = new SelectorWrapper(myErrorMessage, occCertificationList); 

        return myWrap;
    }  

}
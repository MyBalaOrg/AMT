/*
Author: Raj Kumar Pandy
Decsription: The Wrapper class for JSON parameters in the MuleSoft API call
*/
public class ODILR_JSONWrapper {
    
    //Declaring variables for the JSON
    public Integer Refno;
    public String CaseTypeCd;
    public String sapNo;
    public String UnionAcronymNm;
    public String ScndLvlCaseFileNbr;
    public String ScndLvlDecisionDt;
    public String ThirdLvlCaseFileNbr;
    public String ThirdLvlDecisionDt;
    public String BoardCaseNbr;
    public String BoardNbr;
    public String AwardDt;
    public String firstName;
    public String lastName;

    //Constructor method
    public ODILR_JSONWrapper(Case caseObj)
    {
        //Condition to check for NULL values
        if(caseObj.CaseNumber != NULL)
            RefNo = Integer.ValueOf(caseObj.CaseNumber);
        else             
            RefNo = NULL;
        
        //RecordType Assignment
        if(caseObj.RecordType.Name != NULL){
            if(caseObj.RecordType.Name == System.Label.ODILR_Discipline_Record_Type)
                CaseTypeCd = System.Label.ODILR_Documentum_Discipline_Type;
            else if(caseObj.RecordType.Name == System.Label.ODILR_Claims_Record_Type)
                CaseTypeCd = System.Label.ODILR_Documentum_Claims_Type;           
            else
                CaseTypeCd = '';
        }
        else
            CaseTypeCd = '';
        
        //SAP Number assignment - If SAP number is not present on the contact record, then a default SAP number defined in the custom settings is passed to the API.
        if(caseObj.SAP_Number__c != NULL)
            sapNo = caseObj.SAP_Number__c;
        else            
            sapNo = ODILR_Hierarchy_Setting__c.getOrgDefaults().Default_SAP_Number__c;
            
        //Union Name assignment  - If union is not present on the contact record, then a default value for union defined in the custom settings is passed to the API.   
        if(caseObj.Union__c != NULL)
            UnionAcronymNm = caseObj.Union__r.Name;
        else            
            UnionAcronymNm = ODILR_Hierarchy_Setting__c.getOrgDefaults().Default_Union_Name__c;
        
        //Second level date assignment    
        if(caseObj.Decision_Date_Second_Level__c != NULL)
            ScndLvlDecisionDt = String.ValueOf(caseObj.Decision_Date_Second_Level__c);
        else
            ScndLvlDecisionDt = '';
        
        //Second Level file number assignment                     
        if(caseObj.ODILR_File_Number_Second_Level__c != NULL)
            ScndLvlCaseFileNbr = caseObj.ODILR_File_Number_Second_Level__c;
        else
            ScndLvlCaseFileNbr = '';
            
        //Third level file Number assignment    
        if(caseObj.ODILR_File_Number_Third_Level__c!= NULL)
            ThirdLvlCaseFileNbr = caseObj.ODILR_File_Number_Third_Level__c;
        else
            ThirdLvlCaseFileNbr = '';
            
        //Third level decision date assignment    
        if(caseObj.Decision_Date_Third_Level__c != NULL)
            ThirdLvlDecisionDt = String.ValueOf(caseObj.Decision_Date_Third_Level__c);
        else
            ThirdLvlDecisionDt = ''; 
            
        //Case Number assignment         
        if(caseObj.Board_Level_Case_Number__c != NULL)
            BoardCaseNbr = caseObj.Board_Level_Case_Number__c;
        else
            BoardCaseNbr = '';
            
        //Board level assignment     
        if(caseObj.Board_Number__c != NULL)
            BoardNbr = caseObj.Board_Number__c;
        else
            BoardNbr = '';
            
        //Entered date assignment    
        if(caseObj.Entered_Date__c != NULL)
            AwardDt = String.ValueOf(caseObj.Entered_Date__c);
        else
            AwardDt = '';  
            
        //First Name - If first name is not present on the contact record, then a default value for first name defined in the custom settings is passed to the API.         
        if(caseObj.First_Name__c != NULL)
            firstName = caseObj.First_Name__c;
        else
            firstName = ODILR_Hierarchy_Setting__c.getOrgDefaults().Default_First_Name__c; 
            
        //Last Name    
        if(caseObj.Last_Name__c!= NULL)
            lastName = caseObj.Last_Name__c;
        else
            lastName = '';      
    }
}
/*
Author: Raj Kumar Pandy
Decsription: The Controller for the LR Activity Report VF Page. The fucntionality of this controller is to fetch the Case records for the specified time period by grouping them on the basis of Union__c
*/
public class ODILR_LRActivityReportController {
    
    //Constructor method for the controller
    public ODILR_LRActivityReportController(ApexPages.StandardController controller) {
        
    }
    
    
    //Declaring the variables with set and get property
    public Date fromDate {get;set;}
    public Date endDate {get;set;}
    public Date currentDate{get;set;}
    
    public Boolean clicked{get;set;}
    public Boolean pclicked{get;set;}
    
    public String renderType{get;set;}
    
    public Set<String> previousUnionNames{get;set;}
    public Set<String> currentUnionNames{get;set;}
    public Set<String> nextUnionNames{get;set;}
    
    public Set<String> unionNamesSet{get;set;}
    
    public String lrOffice {get;set;}
    public Set<String> lrOptions {get;set;}
    
    public Map<String,Map<String,integer>> previousUnion{get;set;}
    public Map<String,Map<String,integer>> currentUnion{get;set;}
    public Map<String,Map<String,integer>> nextUnion{get;set;}
    
    @TestVisible String selectedlevel = null;
    @TestVisible String selectedlrlevel = null;
    @TestVisible String selectedtype = null;
    
    //Method for initiating the values for the Radio buttons on the VF Page
    public List<SelectOption> getlevel()
    {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Level 2','2nd Level'));
        options.add(new SelectOption('Level 3','3rd Level'));
        options.add(new SelectOption('Board Level','Board Level'));
        return options;
    }
    
    public List<SelectOption> getreportType()
    {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','None'));
        options.add(new SelectOption('ODILR Claims','ODILR Claims'));
        options.add(new SelectOption('ODILR Discipline','ODILR Discipline'));
        return options;
    }
    public String getselectedlevel() {
        
        return selectedlevel;
    }
    public void setselectedlevel(String selectedlevel) { this.selectedlevel = selectedlevel ; }
    
    //Method for initiating the values for the Drop down list on the VF Page
    public List<SelectOption> getLRLevel()
    {
        
        List<SelectOption> optionsLR = new List<SelectOption>();
        lrOptions = new Set<String>();
        optionsLR.add(new SelectOption('None','None'));
        optionsLR.add(new SelectOption('ALL','ALL')); 
        
        Schema.DescribeFieldResult fieldResult = Case.ODILR_LR_Office__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        //Loop for fetching the LR Office picklist from the Case object
        for(Schema.PicklistEntry f : ple)
        {
            optionsLR.add(new SelectOption(f.getLabel(), f.getValue()));
            lrOptions.add(f.getValue());
        }       
        return optionsLR;
    }
    
    public String getselectedlrlevel() {
        
        return selectedlrlevel;
    }
    public void setselectedlrlevel(String selectedlrlevel) { this.selectedlrlevel = selectedlrlevel ; }
    
    public String getselectedtype() {
        
        return selectedtype;
    }
    public void setselectedtype(String selectedtype) { this.selectedtype = selectedtype ; }
    
    //Method for fetching the case records and also to group them on the basis of Union__c records
    public PageReference fetchRecords() {
        String decision2 = System.Label.ODILR_Decision_Second_Level;
        String decision3 = System.Label.ODILR_Decision_Third_Level;
        String decision4 = System.Label.ODILR_Decision_Board_Level;
        String decision= '';
        clicked = true;
        
        previousUnion = new Map<String,Map<String,integer>>();
        currentUnion = new Map<String,Map<String,integer>>();
        nextUnion = new Map<String,Map<String,integer>>();
        if(selectedtype == NULL)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please enter the Report Type'));
            return null;
        }
        system.debug(selectedtype);
        previousUnionNames = new Set<String>();
        currentUnionNames = new Set<String>();
        nextUnionNames = new Set<String>();
        if(selectedlrlevel != 'ALL' && selectedlrlevel != 'None')
        {
            system.debug(lrOptions);
            lrOptions.clear();
            lrOptions.add(selectedlrlevel);
            system.debug(lrOptions);
        }
        else if(selectedlrlevel == 'None')
        {
            lrOptions.clear();
            lrOptions.add('');
        }
        
        //Fetching and grouping the case records for 2nd Level
        if(selectedLevel=='Level 2')
        {
            decision = decision2;
            //Loop for fetching the Case records on the 2nd Level for the period before the from date
            for(AggregateResult[] ar : [SELECT  Union__r.Name,Decision_Second_Level__c, COUNT(ID) Cnt FROM CASE where (Decision_Date_Second_Level__c < :fromDate) AND Case_Level__c=:selectedLevel AND Union__c!=NULL AND (ODILR_LR_Office__c IN : lrOptions) AND RecordType.Name =:selectedtype GROUP BY Union__r.Name, Decision_Second_Level__c ])
            {
                previousUnion = assembleUnions(ar, decision);
                system.debug(ar);
            }
            //Loop for fetching the Case records on the 2nd Level for the period after from date and before the end date
            for(AggregateResult[] ar : [SELECT  Union__r.Name,Decision_Second_Level__c, COUNT(ID) Cnt FROM CASE where (Decision_Date_Second_Level__c >= :fromDate AND Decision_Date_Second_Level__c <= :endDate) AND Case_Level__c=:selectedLevel AND Union__c!=NULL AND (ODILR_LR_Office__c IN : lrOptions) AND RecordType.Name =:selectedtype GROUP BY Union__r.Name, Decision_Second_Level__c ])
            {
                currentUnion = assembleUnions(ar, decision);
                system.debug(ar);
            }
            for(AggregateResult[] ar: [SELECT  Union__r.Name, COUNT(ID) Cnt FROM CASE where (Appeal_Received_Date_Second_Level__c >= :fromDate AND Appeal_Received_Date_Second_Level__c <= :endDate) AND Case_Level__c=:selectedLevel AND Union__c!=NULL AND (ODILR_LR_Office__c IN : lrOptions) AND RecordType.Name =:selectedtype GROUP BY Union__r.Name])
            {
                receivedUnions(ar);
            }
            //Loop for fetching the Case records on the 2nd Level for the period after the end date
            for(AggregateResult[] ar : [SELECT  Union__r.Name,Decision_Second_Level__c, COUNT(ID) Cnt FROM CASE where (Decision_Date_Second_Level__c > :endDate) AND Case_Level__c=:selectedLevel AND Union__c!=NULL AND (ODILR_LR_Office__c IN : lrOptions) AND RecordType.Name =:selectedtype GROUP BY Union__r.Name, Decision_Second_Level__c ])
            {
                nextUnion = assembleUnions(ar, decision);
                system.debug(ar);
            }
        }
        else if(selectedLevel=='Level 3')
        {
            decision = decision3;
            //Loop for fetching the Case records on the 3rd Level for the period before the from date
            for(AggregateResult[] ar : [SELECT  Union__r.Name,Decision_Third_Level__c, COUNT(ID) Cnt FROM CASE where (Decision_Date_Third_Level__c < :fromDate) AND Case_Level__c=:selectedLevel AND Union__c!=NULL AND (ODILR_LR_Office__c IN : lrOptions) AND RecordType.Name =:selectedtype GROUP BY Union__r.Name, Decision_Third_Level__c ])
            {
                previousUnion = assembleUnions(ar, decision);
            }
            //Loop for fetching the Case records on the 3rd Level for the period after from date and before the end date
            for(AggregateResult[] ar : [SELECT  Union__r.Name,Decision_Third_Level__c, COUNT(ID) Cnt FROM CASE where (Decision_Date_Third_Level__c >= :fromDate AND Decision_Date_Third_Level__c <= :endDate) AND Case_Level__c=:selectedLevel AND Union__c!=NULL AND (ODILR_LR_Office__c IN : lrOptions) AND RecordType.Name =:selectedtype GROUP BY Union__r.Name, Decision_Third_Level__c ])
            {
                currentUnion = assembleUnions(ar, decision);
            }
            for(AggregateResult[] ar: [SELECT  Union__r.Name, COUNT(ID) Cnt FROM CASE where (Appeal_Received_Date_Third_Level__c >= :fromDate AND Appeal_Received_Date_Third_Level__c <= :endDate) AND Case_Level__c=:selectedLevel AND Union__c!=NULL AND (ODILR_LR_Office__c IN : lrOptions) AND RecordType.Name =:selectedtype GROUP BY Union__r.Name])
            {
                receivedUnions(ar);
            }
            //Loop for fetching the Case records on the 3rd Level for the period after the end date
            for(AggregateResult[] ar : [SELECT  Union__r.Name,Decision_Third_Level__c, COUNT(ID) Cnt FROM CASE where (Decision_Date_Third_Level__c > :endDate) AND Case_Level__c=:selectedLevel AND Union__c!=NULL AND (ODILR_LR_Office__c IN : lrOptions) AND RecordType.Name =:selectedtype GROUP BY Union__r.Name, Decision_Third_Level__c ])
            {
                nextUnion = assembleUnions(ar, decision);
            }
            
        }
        else if(selectedLevel=='Board Level')
        {
            decision = decision4;
            //Loop for fetching the Case records on the Board Level for the period before the from date
            for(AggregateResult[] ar : [SELECT  Union__r.Name,Decision_Board_Level__c, COUNT(ID) Cnt FROM CASE where (Entered_Date__c < :fromDate) AND Case_Level__c=:selectedLevel AND Union__c!=NULL AND (ODILR_LR_Office__c IN : lrOptions) AND RecordType.Name =:selectedtype GROUP BY Union__r.Name, Decision_Board_Level__c ])
            {
                previousUnion = assembleUnions(ar, decision);
                system.debug(ar);
            }
            //Loop for fetching the Case records on the Board Level for the period after from date and before the end date
            for(AggregateResult[] ar : [SELECT  Union__r.Name,Decision_Board_Level__c, COUNT(ID) Cnt FROM CASE where (Entered_Date__c >= :fromDate AND Entered_Date__c <= :endDate) AND Case_Level__c=:selectedLevel AND Union__c!=NULL AND (ODILR_LR_Office__c IN : lrOptions) AND RecordType.Name =:selectedtype GROUP BY Union__r.Name, Decision_Board_Level__c ])
            {
                currentUnion = assembleUnions(ar, decision);
                system.debug(ar);
            }
            for(AggregateResult[] ar: [SELECT  Union__r.Name, COUNT(ID) Cnt FROM CASE where (Date_Appealed_Board__c >= :fromDate AND Date_Appealed_Board__c <= :endDate) AND Case_Level__c=:selectedLevel AND Union__c!=NULL AND (ODILR_LR_Office__c IN : lrOptions) AND RecordType.Name =:selectedtype GROUP BY Union__r.Name])
            {
                receivedUnions(ar);
                system.debug(ar);
            }
            //Loop for fetching the Case records on the Board Level for the period after the end date
            for(AggregateResult[] ar : [SELECT  Union__r.Name,Decision_Board_Level__c, COUNT(ID) Cnt FROM CASE where (Entered_Date__c > :endDate) AND Case_Level__c=:selectedLevel AND Union__c!=NULL AND (ODILR_LR_Office__c IN : lrOptions) AND RecordType.Name =:selectedtype GROUP BY Union__r.Name, Decision_Board_Level__c ])
            {
                nextUnion = assembleUnions(ar, decision);
                system.debug(ar);
            }
        }
        
        if(previousUnion.Keyset()!=NULL)
        {
            previousUnionNames.addAll(previousUnion.KeySet());
        }
        if(currentUnion.Keyset()!=NULL)
        {
            currentUnionNames.addAll(currentUnion.KeySet());
        }
        if(nextUnion.Keyset()!=NULL)
        {
            nextUnionNames.addAll(nextUnion.KeySet());
        }
        groupUnionMaps();
        return null;//Returning null for refreshing the page
        
    }
    
    //Method for grouping the case records on the basis of Union by assigning the record values on to the maps.
    public Map<String, Map<String,integer>> assembleUnions(AggregateResult[] tempAR, String decision)
    {
        Map<String, Map<String,integer>> tempUnionMap = new Map<String, Map<String,integer>>();
        //Loop for grouping the case records on the basis of union
        for(AggregateResult a : tempAR)
        {
            Map<String,Integer> ctemp = new Map<String,Integer>();
            ctemp = intialiseMap();
            integer actve = 0;
            integer other = 0;
            integer handle = 0;
            if(tempUnionMap.containsKey((String)a.get('Name')))
            {
                ctemp = tempUnionMap.get((String)a.get('Name'));
                ctemp.put((String)a.get(decision),(Integer)a.get('Cnt'));
                if((String)a.get(decision)==null)
                {
                    actve = (Integer)a.get('Cnt');
                    ctemp.put('Active',actve);
                }
                if((String)a.get(decision)!=null && (String)a.get(decision)!='Abeyance')
                {
                    other = ctemp.get('Others');
                    other = other + (Integer)a.get('Cnt');
                    ctemp.put('Others',other);
                    if((String)a.get(decision)!='Withdrawn'&& (String)a.get(decision)!='Dormant')
                    {
                        handle = ctemp.get('Handled');
                        handle = handle + (Integer)a.get('Cnt');
                        ctemp.put('Handled',handle);
                    }
                }
                tempUnionMap.put((String)a.get('Name'),ctemp);
            }
            else
            {
                ctemp.put((String)a.get(decision),(Integer)a.get('Cnt'));
                if((String)a.get(decision)==null)
                {
                    actve = (Integer)a.get('Cnt');
                    ctemp.put('Active',actve);
                }
                if((String)a.get(decision)!=null && (String)a.get(decision)!='Abeyance')
                {
                    other = ctemp.get('Others');
                    other = other + (Integer)a.get('Cnt');
                    ctemp.put('Others',other);
                    if((String)a.get(decision)!='Withdrawn'&& (String)a.get(decision)!='Dormant')
                    {
                        handle = ctemp.get('Handled');
                        handle = handle + (Integer)a.get('Cnt');
                        ctemp.put('Handled',handle);
                    }
                }
                tempUnionMap.put((String)a.get('Name'),ctemp);
            }
            
        }
        return tempUnionMap;
    }
    
    public void receivedUnions(AggregateResult[] tempAR)
    {
        Map<String, Map<String,integer>> tempUnionMap = new Map<String, Map<String,integer>>();
        Map<String,Integer> ctemp = new Map<String,Integer>();
        ctemp = intialiseMap();
        for(AggregateResult a : tempAR)
        {
            if(currentUnion.containsKey((String)a.get('Name')))
            {
                ctemp = currentUnion.get((String)a.get('Name'));
                ctemp.put('Received',(Integer)a.get('Cnt'));
                currentUnion.put((String)a.get('Name'),ctemp);
            }
            else
            {
                ctemp.put('Received',(Integer)a.get('Cnt'));
                currentUnion.put((String)a.get('Name'),ctemp);
            }
        }
    }
    
    //Method for assigning values to the Map
    public void groupUnionMaps()
    {
        unionNamesSet = new Set<String>();
        Map<String,Integer> tempCountMap = new Map<String,Integer>();
        tempCountMap = intialiseMap();
        if(previousUnion.Keyset()!=NULL)
        {
            unionNamesSet.addAll(previousUnion.KeySet());
        }
        if(currentUnion.Keyset()!=NULL)
        {
            unionNamesSet.addAll(currentUnion.KeySet());
        }
        if(nextUnion.Keyset()!=NULL)
        {
            unionNamesSet.addAll(nextUnion.KeySet());
        }
        //Initialising the values for all the values in the map
        for(String tempUnionName : unionNamesSet)
        {
            if(!previousUnion.containsKey(tempUnionName))
            {
                previousUnion.put(tempUnionName,tempCountMap);
            }
            if(!currentUnion.containsKey(tempUnionName))
            {
                currentUnion.put(tempUnionName,tempCountMap);
            }
            if(!nextUnion.containsKey(tempUnionName))
            {
                nextUnion.put(tempUnionName,tempCountMap);
            }
        }
    }
    
    //Method for initilaising the maps.
    public Map<String,Integer> intialiseMap(){
        Map<String,Integer> tempMap = new Map<String,Integer>();
        //Initialising all the Variable values
        tempMap.put('Abeyance',0);
        tempMap.put('Compromise',0);
        tempMap.put('Paid',0);
        tempMap.put('In-Part',0);
        tempMap.put('Dormant',0);
        tempMap.put('Withdrawn',0);
        tempMap.put('Denied',0);
        tempMap.put('NWB',0);
        tempMap.put('Active',0);
        tempMap.put('Others',0);
        tempMap.put('Received',0);
        tempMap.put('Handled',0);
        return tempMap;
    }
    
    //Method for rendering as PDF
    public void renderPage()
    {
        renderType = 'pdf';
        pclicked=true;
        currentDate = Date.Today();
    }
    
    
    
}
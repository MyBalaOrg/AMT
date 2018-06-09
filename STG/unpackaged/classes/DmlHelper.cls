public with sharing class DmlHelper         
{   
    /*---------------------------------------------------------------------------------------------------
	insertList
	---------------------------------------------------------------------------------------------------*/      
    public static String insertList(List<SObject> theList)
    {   
        system.debug('DmlHelper insertList - Start');

        String errorMsg; 

        try { INSERT theList; } catch(DmlException dex) { errorMsg = dex.getMessage(); crash(dex); } 

        system.debug('DmlHelper insertList - End');
        return errorMsg;     
    }       
    /*---------------------------------------------------------------------------------------------------
	updateList
	---------------------------------------------------------------------------------------------------*/      
    public static String updateList(List<SObject> theList)
    {   
        system.debug('DmlHelper updateList - Start');

        String errorMsg; 

        try { UPDATE theList; } catch(DmlException dex) { errorMsg = dex.getMessage(); crash(dex); }

        system.debug('DmlHelper updateList - End');
        return errorMsg; 
    }  

    /*---------------------------------------------------------------------------------------------------
    upsertList
    ---------------------------------------------------------------------------------------------------*/      
    public static String upsertList(List<SObject> theList)
    {   
        system.debug('DmlHelper insertList - Start');

        String errorMsg; 

        try { UPSERT theList; } catch(DmlException dex) { errorMsg = dex.getMessage(); crash(dex); } 

        system.debug('DmlHelper insertList - End');
        return errorMsg;     
    }       
    
    /*---------------------------------------------------------------------------------------------------
	crash
	---------------------------------------------------------------------------------------------------*/      
    public static void crash(DmlException dex)
    {   
        system.debug('XXXX DML EXCEPTION: ' + dex); 
    }       

}
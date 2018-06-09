//Test class for the PTC_AssetInstallationController
@isTest
public class PTC_AssetInstallationController_Test{

  
    @testSetup static void setup() {
     //   try {
        
            List<RecordType> ptcCSRecType = [Select Id from RecordType WHERE Name = 'PTC' AND SObjectType = 'PTC_Control_System__c'];
            List<RecordType> ptcCNRecType = [Select Id from RecordType WHERE Name = 'PTC' AND SObjectType = 'PTC_Component_Name__c'];
            List<RecordType> ptcCSCNRecType = [Select Id from RecordType WHERE Name = 'PTC' AND SObjectType = 'PTC_Control_System_Component_Name__c'];
            List<RecordType> ptcPrdRecType = [Select Id from RecordType WHERE Name = 'PTC' AND SObjectType = 'Product2'];
            List<RecordType> ptcRevRecType = [Select Id from RecordType WHERE Name = 'PTC' AND SObjectType = 'PTC_Revision_Levels__c'];
            List<RecordType> ptcLocoRecType = [Select Id from RecordType WHERE Name = 'PTC' AND SObjectType = 'PTC_Locomotive__c'];
            List<RecordType> ptcLocoCSRecType = [Select Id from RecordType WHERE Name = 'PTC' AND SObjectType = 'PTC_Locomotive_Control_Systems__c'];
            List<RecordType> ptcLocRecType = [Select Id from RecordType WHERE Name = 'Location Main' AND SObjectType = 'Location__c'];
            List<RecordType> ptcAssetRecType = [Select Id from RecordType WHERE Name = 'PTC' AND SObjectType = 'Asset'];
            List<RecordType> ptcAccRecType = [Select Id from RecordType WHERE Name = 'PTC Vendor' AND SObjectType = 'Account'];
            List<RecordType> ptcConRecType = [Select Id from RecordType WHERE Name = 'PTC Vendor' AND SObjectType = 'Contact'];
            
            
            PTC_Control_System__c ptcCS = new PTC_Control_System__c(RecordTypeId = ptcCSRecType[0].Id, Name = 'ACSES', Active__c = TRUE);
            insert ptcCS;
            
            PTC_Component_Name__c ptcCN = new PTC_Component_Name__c(RecordTypeId = ptcCNRecType[0].Id, Name = 'Tachometer 1', Active__c = TRUE);
            insert ptcCN;
            
            PTC_Component_Name__c ptcCN1 = new PTC_Component_Name__c(RecordTypeId = ptcCNRecType[0].Id, Name = 'Tachometer 2', Active__c = TRUE);
            insert ptcCN1;
            
            PTC_Control_System_Component_Name__c ptcCSCN = new PTC_Control_System_Component_Name__c(RecordTypeId = ptcCSCNRecType[0].Id, Name = 'ACSES_Tachometer 1', Control_Systems__c = ptcCS.Id, Component_Names__c = ptcCN.ID,Active__c = TRUE);
            insert ptcCSCN;
            
            PTC_Control_System_Component_Name__c ptcCSCN1 = new PTC_Control_System_Component_Name__c(RecordTypeId = ptcCSCNRecType[0].Id, Name = 'ACSES_Tachometer 2', Control_Systems__c = ptcCS.Id, Component_Names__c = ptcCN1.ID,Active__c = TRUE);
            insert ptcCSCN1;
            
            Product2 prdAscesTach = new Product2(RecordTypeId = ptcPrdRecType[0].Id, PTC_Control_Systems_Component_Name__c = ptcCSCN.Id, Name = 'D490H123', IsActive = TRUE);
            insert prdAscesTach;
            
            Product2 prdAscesTach1 = new Product2(RecordTypeId = ptcPrdRecType[0].Id, PTC_Control_Systems_Component_Name__c = ptcCSCN1.Id, Name = 'D490H124', IsActive = TRUE, PTC_ParentProduct__c = prdAscesTach.Id);
            insert prdAscesTach1;
            
            
            
            PTC_Revision_Levels__c ptcRevLev = new PTC_Revision_Levels__c(RecordTypeId = ptcRevRecType[0].Id, Product__c = prdAscesTach.Id, Hardware_Version__c = '5', Software_Revision__c = '3', Locomotive_Type__c = 'P42', Active__c = TRUE);
            insert ptcRevLev;
            
            PTC_Revision_Levels__c ptcRevLev1 = new PTC_Revision_Levels__c(RecordTypeId = ptcRevRecType[0].Id, Product__c = prdAscesTach1.Id, Hardware_Version__c = '5', Software_Revision__c = '3', Locomotive_Type__c = 'P42', Active__c = TRUE);
            insert ptcRevLev1;
        
            PTC_Revision_Levels__c ptcRevLev2 = new PTC_Revision_Levels__c(RecordTypeId = ptcRevRecType[0].Id, Product__c = prdAscesTach.Id, Hardware_Version__c = 'N/A', Software_Revision__c = 'N/A', Locomotive_Type__c = null, Active__c = TRUE);
            insert ptcRevLev2;
            
            PTC_Locomotive__c ptcLoco = new PTC_Locomotive__c(RecordTypeId = ptcLocoRecType[0].Id, Name = '1001', Locomotive_Initial__c = 'AMTK', Locomotive_Type__c = 'P42', Active__c = TRUE);
            insert ptcLoco;
            
            PTC_Locomotive__c ptcLoco1 = new PTC_Locomotive__c(RecordTypeId = ptcLocoRecType[0].Id, Name = '101', Locomotive_Initial__c = 'AMTK', Locomotive_Type__c = 'F59', Active__c = TRUE);
            insert ptcLoco1;
            
            PTC_Locomotive_Control_Systems__c ptcLocoCS = new PTC_Locomotive_Control_Systems__c(RecordTypeId = ptcLocoCSRecType[0].Id, Locomotive__c = ptcLoco.Id, Control_Systems__c = ptcCS.Id, Active__c = TRUE);
            insert ptcLocoCS;
            
            Location__c loc = new Location__c(RecordTypeId = ptcLocRecType[0].Id, Name = 'Wilmington', City__c = 'Wilmington', EIS_State__c = 'DE', PTC_Location_Code__c = 'WIL',Active__c = TRUE);
            insert loc;
            
            Asset ptcAsset1 = new Asset(RecordTypeId = ptcAssetRecType[0].Id, PTC_Control_Systems_Component_Name__c = ptcCSCN.Id, Product2Id = prdAscesTach.Id, PTC_Vendor_Part_Number__c = prdAscesTach.Id, Name = '23456', SerialNumber = '23456',PTC_Location__c = loc.Id, PTC_Locomotive_Id__c = ptcLoco.Id, InstallDate = Date.Today(), Active__c = TRUE);
            insert ptcAsset1;
            Asset ptcAsset2 = new Asset(RecordTypeId = ptcAssetRecType[0].Id, PTC_Control_Systems_Component_Name__c = ptcCSCN.Id, Product2Id = prdAscesTach.Id, PTC_Vendor_Part_Number__c = prdAscesTach.Id,Name = '123456', SerialNumber = '123456',PTC_Location__c = loc.Id, PTC_Locomotive__c = NULL, PTC_Locomotive_Id__c = NULL, InstallDate = Date.Today(), Active__c = TRUE, PTC_Hardware_Installed__c  = '1', PTC_Software_Installed__c = '1');
            insert ptcAsset2;
            Asset ptcAsset3 = new Asset(RecordTypeId = ptcAssetRecType[0].Id, PTC_Control_Systems_Component_Name__c = ptcCSCN.Id, Product2Id = prdAscesTach.Id, PTC_Vendor_Part_Number__c = prdAscesTach.Id,Name = '34567', SerialNumber = '34567', PTC_Location__c = loc.Id, PTC_Locomotive__c = ptcLoco.Id, PTC_Locomotive_Id__c = ptcLoco.Id, InstallDate = Date.Today(), Active__c = TRUE);
            insert ptcAsset3;
            
            
            Account ptcAcc = new Account(RecordTypeId = ptcAccRecType[0].Id, Name = 'Seimens', Active__c = TRUE);
            insert ptcAcc;
            
            Contact ptcCon = new Contact(RecordTypeId = ptcConRecType[0].Id, AccountId = ptcAcc.Id, FirstName = 'John', LastName = 'Smith');
            insert ptcCon;
        /*} catch (DMLException e) {
            System.debug(e.getDmlMessage(0));
        }*/
    }
    
  @isTest
    public static void TestAssetInstallation() {
            
        List<PTC_Locomotive__c> ptcLocos = [Select Id from PTC_Locomotive__c];
        system.debug('ptcLocos'+ptcLocos);
        List<Product2> ptcPrds = [Select Id from Product2];
        system.debug('ptcPrds'+ptcPrds);
        List<Asset> ptcAssets1 = [Select Id, Name, PTC_Locomotive__r.Name, PTC_Locomotive__c, PTC_Not_conforming_SW_HW_Version__c, PTC_Hardware_Installed__c, PTC_Software_Installed__c, PTC_New_Location__c, PTC_New_Status__c, PTC_Employee__c, InstallDate, PTC_New_Transaction_Date__c FROM Asset WHERE Name = '123456' Limit 1];
        List<Asset> ptcAssets2 = [Select Id, Name, PTC_Locomotive__r.Name, PTC_Locomotive__c, PTC_Not_conforming_SW_HW_Version__c, PTC_Hardware_Installed__c, PTC_Software_Installed__c, PTC_New_Location__c, PTC_New_Status__c, PTC_Employee__c, InstallDate, PTC_New_Transaction_Date__c FROM Asset WHERE Name = '34567' Limit 1];
        
        List<String> cont = PTC_AssetInstallationController.getControlSystemsValues(ptcLocos[0].Id);
        System.assert(cont.size() > 0);
        
        List<String> comp = PTC_AssetInstallationController.getComponentNames(ptcLocos[0].Id,'ACSES');
        System.assert(comp.size() > 0);
               
        List<Product2> part = PTC_AssetInstallationController.getPartNumbers('ACSES', 'Tachometer 1') ;
        System.assert(part.size() > 0);
       
        List<PTC_AssetWrapperClass> ser = PTC_AssetInstallationController.getSerialNumbers(ptcLocos[0].Id,ptcPrds[0].Id);
        System.assert(ser.size() > 0);
        
        List<PTC_AssetWrapperClass> ser1 = PTC_AssetInstallationController.getSerialNumbers(ptcLocos[0].Id,ptcPrds[1].Id);
        System.assert(ser1.size() > 0);
                
        List<Location__c> loc = PTC_AssetInstallationController.findAllLocations('Wilmington');
        System.assert(loc.size() > 0);
        
        List<Contact> con = PTC_AssetInstallationController.findAllContacts('John');
        System.assert(con.size() > 0);
        
        List<PTC_AssetWrapperClass> exist = PTC_AssetInstallationController.getExistingRecords(ptcLocos[0].Id, 'ACSES');
        System.assert(exist.size() > 0);
        
        List<PTC_AssetWrapperClass> exist1 = PTC_AssetInstallationController.getExistingRecords(ptcLocos[0].Id, 'NONE');
        System.assertequals(exist1,NULL);
        
        List<String> min = PTC_AssetInstallationController.getMinVersions(ptcPrds[0].Id, ptcLocos[0].Id);
        System.assert(min.size() > 0);
        
        List<String> min1 = PTC_AssetInstallationController.getMinVersions(ptcPrds[0].Id, ptcLocos[1].Id);
        System.assert(min1.size() > 0);
        
        List<PTC_AssetWrapperClass> awcupdateList = new List<PTC_AssetWrapperClass>();
        //PTC_AssetWrapperClass awc1 = new PTC_AssetWrapperClass(ptcAssets1[0].Id,ptcPrds[0].Id,'ACSES','Tachometer 1','D490H123','23456','3','4','UPDATE_ASSET','1','2',TRUE);
        PTC_AssetWrapperClass awc1 = new PTC_AssetWrapperClass(ptcAssets1[0].Id,ptcPrds[0].Id,'ACSES','Tachometer 1','D490H123','123456','3','4','UPDATE_ASSET','5','5',TRUE);
        PTC_AssetWrapperClass awc2 = new PTC_AssetWrapperClass(NULL,ptcPrds[0].Id,'ACSES','Tachometer 1','D490H123','90123','3','4','INSERT','1','2',TRUE);
        
        awcupdateList.Add(awc1);
        awcupdateList.Add(awc2);
        
        List<PTC_AssetWrapperClass> awcRemoveList = new List<PTC_AssetWrapperClass>();
        PTC_AssetWrapperClass awc3 = new PTC_AssetWrapperClass(ptcAssets2[0].Id,ptcPrds[0].Id,'ACSES','Tachometer 1','D490H123','34567','3','4','UPDATE_ASSET','1','2',TRUE);        
        awcRemoveList.Add(awc3);    
        
        string toAdd = json.Serialize(awcupdateList);
        string toRemove= json.Serialize(awcRemoveList);        
        PTC_AssetInstallationController.updateAssets(ptcLocos[0].Id,toAdd,toRemove,loc[0].Id,con[0].Id,'5/15/2018');
               
    }

}
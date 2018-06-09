/*
********************************************************************************************************************************************************************************************************************************************
*	@Name			PTC_AssetInstallationController.apxc
*	@Author			Deloitte Digital
*	@Created Date	10th May 2018
*	@Used By		PTC App	
********************************************************************************************************************************************************************************************************************************************
*	@Description	This is the apex contoller which handles component requests and performs DML operations

********************************************************************************************************************************************************************************************************************************************
*	@Changes
********************************************************************************************************************************************************************************************************************************************	
*/
public class PTC_AssetInstallationController {
    
    /**
*————————————————————————————————————————————————————
* @Name             getControlSystemsValues
*
*————————————————————————————————————————————————————
* @Description
* Method used to get Control Systems depending on Locomotive Record Id.
* 
*————————————————————————————————————————————————————
* 
**/
    @auraEnabled
    public static List<String> getControlSystemsValues(String LocoId) {
        List<String> controlSysPickListValues = new List<String>();
        List<PTC_Locomotive_Control_Systems__c> locoControlSys = new List<PTC_Locomotive_Control_Systems__c>(); 
        PTC_Locomotive__c LocoObj = new PTC_Locomotive__c();
        
        try {
            LocoObj = [Select Locomotive_Type__c from PTC_Locomotive__c where Id =: LocoId And Active__c = true];
            
            locoControlSys = [select id,name ,Control_Systems__r.Name from  
                              PTC_Locomotive_Control_Systems__c where 
                              Locomotive__c =: LocoId And 
                              Control_Systems__r.Active__c = true And 
                              Active__c = true And RecordType.Name=:System.Label.PTC_Locomotive_Control_System_Record_Type_Label];
            
            for(PTC_Locomotive_Control_Systems__c l : locoControlSys) {
                controlSysPickListValues.add(l.Control_Systems__r.Name);
            }
            
        } catch(Exception e) {
            system.debug('ERROR '+e.getMessage());
        }
        return controlSysPickListValues;    
    }
    
    /**
*————————————————————————————————————————————————————
* @Name             getComponentNames
*————————————————————————————————————————————————————
* @Description
* Method used to get Component Name depending on Control System selected and Locomotive Record Id.
* 
*————————————————————————————————————————————————————
* 
**/
    @auraEnabled
    public static List<String> getComponentNames(String locoId ,String selectedControlSys) {
        List<String> componentNames = new List<String>();
        try {
            componentNames = findComponentNamesNotInstalled(locoId,selectedControlSys);
        } catch(Exception e) {
            system.debug('ERROR '+e.getMessage());
        }
        return componentNames;
    }
    /**
*————————————————————————————————————————————————————
* @Name             findComponentNamesNotInstalled
*
*————————————————————————————————————————————————————
* @Description
* Method to get List of components not installed.
* 
*————————————————————————————————————————————————————
* 
**/
    private static List<String> findComponentNamesNotInstalled(String locoId,String selectedControlSys) {
        List<String> componentNamesNotInstalled = new List<String>();
        
        Set<id> mappingIds = getMappingSetByLocoId(locoId);
        List<PTC_Control_System_Component_Name__c> contMapping = new List<PTC_Control_System_Component_Name__c>();
        try {
            
            contMapping = [Select id, Control_Systems__r.Name,Component_Names__r.Name from 
                           PTC_Control_System_Component_Name__c 
                           where id not in :mappingIds 
                           and Control_Systems__r.Active__c = true 
                           and Component_Names__r.Active__c = true and RecordType.Name=:System.Label.PTC_CS_CN_Record_Type_Label];
            system.debug('contMapping=='+contMapping);
            system.debug('mappingIds==='+mappingIds);
            for(PTC_Control_System_Component_Name__c obj:contMapping) {
                if(obj.Control_Systems__r.Name == selectedControlSys)
                    componentNamesNotInstalled.add(obj.Component_Names__r.Name);
            }
        } catch(Exception e) {
            system.debug('ERROR '+e.getMessage());
        }
        return componentNamesNotInstalled;
    }
    
    /**
*————————————————————————————————————————————————————
* @Name             getMappingSetByLocoId
*
*————————————————————————————————————————————————————
* @Description
* Method to get Id of Asset Records.
* 
*————————————————————————————————————————————————————
* 
**/
    private static Set<Id> getMappingSetByLocoId(String locoId) {
        List<Asset> assetList = new List<Asset>();
        Set<Id> mappingIds = new Set<ID>();
        
        try {
            assetList = [select id,PTC_Control_Systems_Component_Name__c from Asset where PTC_Locomotive__c =: locoId 
                         and RecordType.Name=:System.Label.PTC_Asset_Record_Type_Label];
            
            system.debug('assetList '+assetList);
            
            for(asset a : assetList) {
                mappingIds.add(a.PTC_Control_Systems_Component_Name__c);
            }
            
            system.debug('mappingIds '+mappingIds);
        } catch(Exception e) {
            system.debug('ERROR '+e.getMessage());
        } 
        return mappingIds;
    }
    /**
*————————————————————————————————————————————————————
* @Name             getPartNumbers
*
*————————————————————————————————————————————————————
* @Description
* Method used to get Part Number depending on Selected Control System and selected Component Name.
* 
*————————————————————————————————————————————————————
* 
**/
    @auraEnabled
    public static List<Product2> getPartNumbers(String selectedControlSys,String selectedComponentName) {
        
        List<Product2> partNumbers = new List<Product2>();
        List<Product2> prodList = new List<Product2>();
        Map<Product2,List<String>> productToRevMap = new Map<Product2,List<String>>();
        
        try {
            prodList = [Select Id,Name,PTC_Amtrak_Part_number__c,PTC_Component_Name__c,PTC_Control_System__c from 
                        Product2 where PTC_Control_System__c=:selectedControlSys AND 
                        PTC_Component_Name__c=:selectedComponentName and RecordType.Name=:System.Label.PTC_Product_Record_Type_Label and IsActive = true];
            for(Product2 obj:prodList)
                partNumbers.add(obj);
        } catch(Exception e){
            system.debug('ERROR '+e.getMessage());
        }
        return partNumbers;
        
    }
    /**
*————————————————————————————————————————————————————
* @Name             getSerialNumbers
*
*————————————————————————————————————————————————————
* @Description
* Method used to get Serial Number depending on Selected Part Number and Locomotive Record Id.
* 
*————————————————————————————————————————————————————
* 
**/
    @auraEnabled
    public static List<PTC_AssetWrapperClass> getSerialNumbers(String LocoId,String selectedPartNumber) {
        system.debug('LocoId==='+LocoId);
        List<PTC_AssetWrapperClass> assetWrapperList = new List<PTC_AssetWrapperClass>();
        List<Asset> assetList = new List<Asset>();
        list<string> versionList = getMinVersions(selectedPartNumber,LocoId);     
        Product2 productObj = [Select id, PTC_ParentProduct__c from Product2 
                               where Id=:selectedPartNumber and RecordType.Name =: System.Label.PTC_Product_Record_Type_Label];
        String parProduct = selectedPartNumber;
        
        try {
            
            if(productObj.PTC_ParentProduct__c != null)
                parProduct = productObj.PTC_ParentProduct__c;
            
            if(versionList[0] != '' && versionList[1] != ''){        
                assetList = [SELECT Id, name,PTC_Control_Systems_Component_Name__r.Component_Names__r.Name,
                             PTC_Control_Systems_Component_Name__r.Name,
                             Product2.Name, SerialNumber,PTC_Software_Installed__c, 
                             PTC_Hardware_Installed__c, PTC_Locomotive__c,PTC_Control_Systems_Component_Name__r.Control_Systems__r.Name from Asset where 
                             Product2Id =: parProduct and PTC_Locomotive__c = null and RecordType.Name=:System.Label.PTC_Asset_Record_Type_Label and Active__c = true];
                
                system.debug('assetList '+assetList);
                
                for(asset a : assetList) {
                    PTC_AssetWrapperClass assetWrapper = new PTC_AssetWrapperClass(a.Id,
                                                                                   a.Product2Id,
                                                                                   a.PTC_Control_Systems_Component_Name__r.Control_Systems__r.Name,
                                                                                   a.PTC_Control_Systems_Component_Name__r.Component_Names__r.Name,a.Product2.Name,
                                                                                   a.name,a.PTC_Hardware_Installed__c,a.PTC_Software_Installed__c,Label.PTC_UPDATE_ASSET,versionList[1],versionList[0],false);
                    system.debug('assetWrapper..'+ assetWrapper);
                    assetWrapperList.add(assetWrapper);
                } 
            }
        } catch(Exception e){
            system.debug('ERROR '+e.getMessage());
        }
        return assetWrapperList;
    }
    
    /**
*————————————————————————————————————————————————————
* @Name             updateAssets
*
*————————————————————————————————————————————————————
* @Description
* Method used to Update Assets. Includes updation, deletion and creation.
* 
*————————————————————————————————————————————————————
* 
**/
    @AuraEnabled
    public static void updateAssets(String locoId,String listToUpdate,String listToUninstall,String locationId,String contactId,String installedDate) {
        
        List<PTC_AssetWrapperClass> uninstallWrapList = (List<PTC_AssetWrapperClass>)System.JSON.deserialize(listToUninstall, List<PTC_AssetWrapperClass>.class);
        List<PTC_AssetWrapperClass> updateWrapMasterList = (List<PTC_AssetWrapperClass>)System.JSON.deserialize(listToUpdate, List<PTC_AssetWrapperClass>.class);
        List<PTC_AssetWrapperClass> insertWrapList = new List<PTC_AssetWrapperClass>();
        List<PTC_AssetWrapperClass> updateWrapList = new List<PTC_AssetWrapperClass>();
        List<Asset> uninstallAssetList = new List<Asset>();
        List<Asset> assetsToUninstall = new List<Asset>();
        List<Asset> assetUpdateList = new List<Asset>();
        List<Asset> assetsToUpdate = new List<Asset>();
        List<asset> assetsToInsert = new List<Asset>();
        
        Id assetRecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByName().get(System.Label.PTC_Asset_Record_Type_Label).getRecordTypeId();
        
        
        Map<Id,PTC_AssetWrapperClass> assetToWrapperMap = new Map<Id,PTC_AssetWrapperClass>();
        Set<Id> setIds = new Set<Id>();
        
        try {
            //Create two separate lists for insert and update
            if(updateWrapMasterList.size() > 0) {
                for(PTC_AssetWrapperClass assetWrap : updateWrapMasterList) {
                    if(assetWrap.status == Label.PTC_UPDATE_ASSET) {
                        updateWrapList.add(assetWrap); 
                    } else if(assetWrap.status == Label.PTC_INSERT) {
                        insertWrapList.add(assetWrap);
                    }
                }
                
            } 
            
            system.debug('updateWrapMasterList '+updateWrapMasterList);
            
            //populate Map asset Id --> assetWrap
            for(PTC_AssetWrapperClass assetWrap : updateWrapList) {
                assetToWrapperMap.put(assetWrap.assetId,assetWrap);
            }
            
            //Get all the assets
            assetUpdateList = [select id,
                               name,InstallDate,PTC_Hardware_Installed__c,
                               PTC_Locomotive__c,PTC_Software_Installed__c,PTC_Employee__c,PTC_New_Status__c,
                               PTC_New_Transaction_Date__c,PTC_New_Location__c,PTC_Not_conforming_SW_HW_Version__c 
                               from Asset where Id in :assetToWrapperMap.KeySet()];
            
            system.debug('assetUpdateList '+assetUpdateList);
            
            //Update locomotive , location , contact and non confirming flag
            for(asset a : assetUpdateList){
                PTC_AssetWrapperClass assetWrap = assetToWrapperMap.get(a.Id);
                // a.PTC_Locomotive__c = locoId;
                a.PTC_Locomotive_Id__c = locoId;
                //PTC_Not_conforming_SW_HW_Version__c
                
                if(assetWrap.hwVersion < assetWrap.minHwVersion) a.PTC_Not_Confirming_HW__c = True;
                if(assetWrap.swVersion < assetWrap.minSwVersion) a.PTC_Not_Confirming_SW__c = True;
                
                a.PTC_Software_Installed__c = assetWrap.swVersion;
                a.PTC_Hardware_Installed__c = assetWrap.hwVersion;
                a.PTC_New_Location__c = locationId;
                a.PTC_New_Status__c = Label.PTC_Asset_Installed_Status;
                a.PTC_Employee__c = contactId;
                a.InstallDate = Date.parse(installedDate);
                a.PTC_New_Transaction_Date__c = Date.parse(installedDate);
                assetsToUpdate.add(a);
            }
            
            system.debug('assetsToUpdate '+assetsToUpdate);
            
            //Uninstall Assets
            if(uninstallWrapList.size() > 0 ){
                for(PTC_AssetWrapperClass obj: uninstallWrapList)
                {
                    setIds.add(obj.assetId);
                }
                uninstallAssetList = [Select Id, 
                                      PTC_Locomotive__c, 
                                      PTC_New_Status__c,PTC_New_Transaction_Date__c,PTC_New_Location__c from Asset 
                                      where Id IN: setIds and RecordType.Name =: System.Label.PTC_Asset_Record_Type_Label];
                assetsToUninstall = new List<Asset>();
                for(Asset astObj:uninstallAssetList)
                {
                    astObj.PTC_Locomotive__c = null;
                    astObj.PTC_New_Location__c = locationId;
                    astObj.PTC_New_Status__c = Label.PTC_Asset_Removed_Status;
                    astObj.PTC_New_Transaction_Date__c = Date.parse(installedDate);
                    astObj.InstallDate = NULL;
                    assetsToUninstall.add(astObj);
                }
                
                system.debug('UNISNTALL LIST '+assetsToUninstall);
                
            } else system.debug('Uinstall List is Empty');
            
            //Combine both assets to be installed and assets to be uninstalled in to one list
            assetUpdateList.addAll(assetsToUninstall);
            
            if(assetUpdateList.size()>0) update assetUpdateList;
            
            Set<Id> prodId = new Set<Id>();
            
            //Process Insert Records
            if(insertWrapList.size()>0) {
                for(PTC_AssetWrapperClass inserWrap :insertWrapList ) {
                    prodId.add(inserWrap.prodId);
                }
            }  
            
            system.debug('prodId '+prodId+'size '+prodId.size());        
            Map<Id,Product2> prodToMapping = new Map<Id,Product2>([select id,PTC_Control_Systems_Component_Name__c from Product2 
                                                                   where id in: prodId and RecordType.Name =: System.Label.PTC_Product_Record_Type_Label]);
            system.debug('prodToMapping '+prodToMapping+'size '+prodToMapping.size());
            
            
            for(PTC_AssetWrapperClass assetWrap :insertWrapList ){
                Asset a = new Asset();
                list<string> versionList = getMinVersions(assetWrap.prodId, locoId);
                
                if(assetWrap.hwVersion < versionList[1]) a.PTC_Not_Confirming_HW__c = True;
                if(assetWrap.swVersion < versionList[0]) a.PTC_Not_Confirming_SW__c = True;
                
                a.name = assetWrap.serialNumber;
                a.serialNumber = assetWrap.serialNumber;
                a.PTC_Software_Installed__c = assetWrap.swVersion;
                a.PTC_Hardware_Installed__c = assetWrap.hwVersion;
                a.PTC_New_Location__c = locationId;
                a.PTC_New_Status__c = Label.PTC_Asset_Received_Installed_Status;
                a.PTC_Employee__c = contactId;
                a.InstallDate = Date.parse(installedDate);
                a.PTC_New_Transaction_Date__c = Date.parse(installedDate);
                a.PTC_Control_Systems_Component_Name__c = prodToMapping.get(assetWrap.prodId).PTC_Control_Systems_Component_Name__c;
                a.Product2Id = assetWrap.prodId;
                a.PTC_Vendor_Part_Number__c = assetWrap.prodId;
                a.PTC_Locomotive_Id__c = locoId;
                a.PTC_Hardware_Installed__c = assetWrap.hwVersion;
                a.PTC_Software_Installed__c = assetWrap.swVersion;
                a.RecordTypeId = assetRecordTypeId;
                a.Active__c = true;
                assetsToInsert.add(a);
                
            }
            
            system.debug('assetsToInsert '+assetsToInsert+'size '+assetsToInsert.size());
            
            //insert assets
            if(assetsToInsert.size()>0) insert assetsToInsert;
        } catch(Exception e) {
            throw new AuraHandledException('Darn it!! Something went wrong:'+e.getMessage());
        }
        
    }
    
    /**
*————————————————————————————————————————————————————
* @Name             findAllLocations
*
*————————————————————————————————————————————————————
* @Description
*Method which search location based on input and return list of locations.
* 
*————————————————————————————————————————————————————
* 
**/
    @AuraEnabled
    public static List<Location__c> findAllLocations(String searchKey){
        String searchWildCard = '%'+searchKey+'%';
        List<Location__c> locationList = new List<Location__c>();
        try {
            locationList = [SELECT Id, Name FROM Location__c WHERE Name LIKE :searchWildCard and RecordType.Name =: System.Label.EIS_Location_Main_Record_Type_Label limit 5];
            system.debug('location list '+locationList);
        } catch(Exception e){
            system.debug('ERROR '+e.getMessage());
        }
        return locationList;
    }
    /**
*————————————————————————————————————————————————————
* @Name             findAllContacts
*
*————————————————————————————————————————————————————
* @Description
*Method which search contact based on input and return list of locations
* 
*————————————————————————————————————————————————————
* 
**/    
    @AuraEnabled
    public static List<Contact> findAllContacts(String searchKey){
        String searchWildCard = '%'+searchKey+'%';
        List<Contact> contactList = new List<Contact>();
        
        try {
            contactList = [SELECT Id, email,Name FROM Contact WHERE Name LIKE :searchWildCard limit 5];
            
        } catch(Exception e) {
            system.debug(e.getMessage());
        }
        
        return contactList;
    }
    /**
*————————————————————————————————————————————————————
* @Name             getExistingRecords
* @Author           Mona Bhutada
*
*————————————————————————————————————————————————————
* @Description
*Method to retrieve all the asset records
* 
*————————————————————————————————————————————————————
* 
**/    
    @AuraEnabled
    public static List<PTC_AssetWrapperClass> getExistingRecords(String recordId, String controlSystem){
        
        String currentControlSystem= '%'+controlSystem+'%';
        List<Asset> assetList = new List<Asset>();
        List<PTC_AssetWrapperClass> assetWrapperList = new List<PTC_AssetWrapperClass>();
        
        try{
            if(controlSystem == Label.PTC_None || controlSystem == NULL || controlSystem == '')
            {
                assetList = NULL;
                system.debug('assetList=='+assetList);
                return null;
                
            }
            else
            {
                assetList = [SELECT Id, name,PTC_Control_Systems_Component_Name__r.Component_Names__r.Name,
                             PTC_Control_Systems_Component_Name__r.Name,Product2.Name, 
                             SerialNumber, PTC_Control_System__c, PTC_Software_Installed__c, 
                             PTC_Hardware_Installed__c, PTC_Locomotive__c FROM Asset 
                             where PTC_Locomotive__c =:recordId 
                             AND PTC_Control_Systems_Component_Name__r.Name LIKE :currentControlSystem
                             AND RecordType.Name =: System.Label.PTC_Asset_Record_Type_Label and Active__c = true];
            }
            
            
            for(Asset p:assetList)
            {
                PTC_AssetWrapperClass assetWrapperObj = new PTC_AssetWrapperClass(p.Id,
                                                                                  p.Product2Id,
                                                                                  p.PTC_Control_Systems_Component_Name__r.Name,
                                                                                  p.PTC_Control_Systems_Component_Name__r.Component_Names__r.Name,p.Product2.Name,
                                                                                  p.name,p.PTC_Hardware_Installed__c,p.PTC_Software_Installed__c,Label.PTC_UNINSTALL_ASSET,'','',false);
                assetWrapperList.add(assetWrapperObj);    
            }
        } catch(Exception e){
            system.debug('ERROR '+e.getMessage());
        }
        return assetWrapperList;
    }
    /**
*————————————————————————————————————————————————————
* @Name             getMinVersions
*
*————————————————————————————————————————————————————
* @Description
*Method to retrieve minimum hardware and software versions.
* 
*————————————————————————————————————————————————————
* 
**/    
    @AuraEnabled
    public static List<String> getMinVersions(String selectedPartNumber, String LocoId){
        List<PTC_Revision_Levels__c> RevLevelList = new List<PTC_Revision_Levels__c>();
        RevLevelList = [Select 
                        Locomotive_Type__c,
                        Hardware_Version__c, 
                        Software_Revision__c from PTC_Revision_Levels__c 
                        where Product__c=:selectedPartNumber and Active__c = true and RecordType.Name=:System.Label.PTC_Revision_Level_Record_Type_Label];
        
        string HwVersion = '';
        string SwVersion = '';
        List<String> versionList = new String[1];
        try{
            if(!RevLevelList.isEmpty() && RevLevelList != null){
                
                
                PTC_Locomotive__c LocoObj = new PTC_Locomotive__c();
                LocoObj = [Select Id,Locomotive_Type__c from PTC_Locomotive__c where Id =: LocoId];
                
                
                //If version found with locomotive type then use that else use which ever is found.
                for(PTC_Revision_Levels__c r : RevLevelList){
                    if(LocoObj != NULL && r.Locomotive_Type__c == LocoObj.Locomotive_Type__c){
                        HwVersion = r.Hardware_Version__c;
                        SwVersion = r.Software_Revision__c;
                        break;
                    }
                    else if (r.Locomotive_Type__c == null || r.Locomotive_Type__c == ''){
                        HwVersion = r.Hardware_Version__c;
                        SwVersion = r.Software_Revision__c; 
                    }
                }
                if(HwVersion.toUpperCase() == 'N/A' || HwVersion.toUpperCase() == 'NA')
                    HwVersion = '0';
                if(SwVersion.toUpperCase() == 'N/A' || SwVersion.toUpperCase() == 'NA')
                    SwVersion = '0';
            }//end of if(!RevLevelList.isEmpty() && RevLevelList != null)
            
            versionList.add(0, swVersion);
            versionList.add(1, HwVersion);
        } catch(Exception e){
            system.debug('ERROR '+e.getMessage());
        }
        return versionList;
    }//end of getMinVersions
}
global class PTC_AssetWrapperClass {
    
    @AuraEnabled
    global String assetId{get;set;}
    
    @AuraEnabled
    global String prodId{get;set;}
    
    @AuraEnabled
    global String controlSys{get;set;}
    
    @AuraEnabled
    global String componentName{get;set;}
    
    @AuraEnabled
    global String partNumber{get;set;}
    
    @AuraEnabled
    global String serialNumber{get;set;}
    
    @AuraEnabled
    global String hwVersion{get;set;}
    
    @AuraEnabled
    global String swVersion{get;set;}
    
    @AuraEnabled 
    public Boolean selected;
        
    @AuraEnabled
    global String status{get;set;}
    
    @AuraEnabled
    global String minHwVersion{get;set;}
    
    @AuraEnabled
    global String minSwVersion{get;set;}
    
    public PTC_AssetWrapperClass(String assetId,
                                 String prodId,
                                 String controlSys,
                                 String componentName,
                                 String partNumber ,
                                 String serialNumber,
                                 String hwVersion,
                                 String swVersion,
                                 String status,
                                 String minHwVersion,
                                 String minSwVersion,
                                 Boolean selected) {
                                     this.assetId = assetId;
                                     this.prodId = prodId;
                                     this.controlSys = controlSys;
                                     this.componentName = componentName;
                                     this.partNumber = partNumber;
                                     this.serialNumber = serialNumber;
                                     this.hwVersion = hwVersion;
                                     this.swVersion = swVersion;
                                     this.status = status;
                                     this.minHwVersion = minHwVersion;
                                     this.minSwVersion = minSwVersion;
                                     this.selected = false;
                                 }
    
}
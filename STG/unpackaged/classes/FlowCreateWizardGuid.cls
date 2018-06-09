/*-------------------------------------------------------------------------------------------
FlowCreateWizardGuid  
Used to complement Flows where Dynamic Record Choices are used and multile results 
are required. 
Test Class:     FlowCreateWizardGuid_Test
Modifications:  
04/22/2018      Chuck Walley   New   
--------------------------------------------------------------------------------------------*/
global class FlowCreateWizardGuid {
    @InvocableMethod
    public static List<List<String>> convert(List<String> theStringList) {   

        List<List<String>> myAnswerListList = new List<List<String>>(); 
        List<String> myAnswerList = new List<String>(); 

        for(String theEmployeeId :theStringList) {

            String hashString = theEmployeeId + String.valueOf(Datetime.now().formatGMT('yyyy-MM-dd HH:mm:ss.SSS'));
            Blob hash = Crypto.generateDigest('MD5', Blob.valueOf(hashString));
            String hexDigest = EncodingUtil.convertToHex(hash);

            myAnswerList.add(hexDigest); 

            myAnswerListList.add(myAnswerList); 
        }
        return myAnswerListList; 

    }
}
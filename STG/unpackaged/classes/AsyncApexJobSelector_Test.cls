@isTest
public class AsyncApexJobSelector_Test {
    
    public static testMethod Void testGetAsyncApexJobs(){
        Test.startTest();
        AsyncApexJob apexJobs = new AsyncApexJob();
       // SelectorWrapper wrapper = AsyncApexJobSelector.getAsyncApexJobs(bc.getJobId());
        Id batchId = apexJobs.Id;
        String batchIdString = (String) batchId;
        SelectorWrapper selWrap = AsyncApexJobSelector.getAsyncApexJobs(batchIdString);
        AsyncApexJobSelector.DoFailTest = true;
        selWrap= AsyncApexJobSelector.getAsyncApexJobs(batchIdString);
        
        Test.stopTest();
    }

}
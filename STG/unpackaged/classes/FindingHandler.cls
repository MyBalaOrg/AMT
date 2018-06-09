public class FindingHandler extends Triggerhandler {
    
    public override void afterInsert() {
    	SafeTrend_FindingHandler.shareFindingAfterInsert(newList);
	 }
}
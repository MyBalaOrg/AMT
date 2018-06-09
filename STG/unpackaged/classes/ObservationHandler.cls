public class ObservationHandler extends Triggerhandler {
    

	public override void afterInsert() {
    	SafeTrend_ObservationHandler.shareObservationAfterInsert(newList);
	}

    public override void afterUpdate() {
    	SafeTrend_ObservationHandler.shareObservationAfterUpdate(newList);
    }

}
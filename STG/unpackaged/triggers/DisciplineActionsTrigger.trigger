trigger DisciplineActionsTrigger on Disciplinary_Action__c (before insert, before update, before delete, after insert, after update, after delete) {
        new ODILR_DisciplineActionsHandler().process();
}
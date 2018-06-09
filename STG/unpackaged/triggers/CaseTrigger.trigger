/*
Author: Raj Kumar Pandy
Description: The Trigger on Case Object
*/
trigger CaseTrigger on Case (before insert, before update, after insert) {
    new CaseTriggerHandler().process();
    system.debug('The Trigger is invoked');
}
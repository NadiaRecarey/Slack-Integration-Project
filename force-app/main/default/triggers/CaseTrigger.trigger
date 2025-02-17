trigger CaseTrigger on Case (after update) {
    
    CaseTriggerHandler.handleCaseUpdates(Trigger.new, Trigger.oldMap);
}
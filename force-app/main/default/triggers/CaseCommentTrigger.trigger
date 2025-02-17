trigger CaseCommentTrigger on CaseComment (after insert, after update) {
    
    CaseCommentTriggerHandler.handleCaseCommentEvents(Trigger.new);
}
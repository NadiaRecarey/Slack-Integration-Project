public with sharing class CaseTriggerHandler {

    public static void handleCaseUpdates(List<Case> newCases, Map<Id, Case> oldCaseMap) {

        for (Case caseRecord : newCases) {
            Case oldCase = oldCaseMap.get(caseRecord.Id);

            // In this case we will handle owner and status change, separately we will
            // have a CaseComment trigger to notify the user on new case comments
            if (caseRecord.OwnerId != oldCase.OwnerId || caseRecord.Status != oldCase.Status) {
                // We are going to have to make a single callout per case, since 
                // each endpoint is fixed to a single slack channel (I didn't find in the documentation
                // if there is a way to send a list of channels and their messages in a single callout)
                System.enqueueJob(new CaseSlackNotifierQueueable(caseRecord, '', 0));
            }
        }
    }
}
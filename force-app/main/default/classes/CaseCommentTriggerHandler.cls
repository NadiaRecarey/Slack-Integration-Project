public with sharing class CaseCommentTriggerHandler {

    public static void handleCaseCommentEvents(List<CaseComment> newCaseComments) {
        Map<Id, String> caseCommentByCaseId = new Map<Id, String>();

        for (CaseComment comment : newCaseComments) {
            caseCommentByCaseId.put(comment.ParentId, comment.CommentBody);
        }

        List<Case> relatedCases = [SELECT Id, OwnerId FROM Case WHERE Id IN :caseCommentByCaseId.keySet()];

        for (Case caseRecord : relatedCases) {
            System.enqueueJob(new CaseSlackNotifierQueueable(caseRecord, caseCommentByCaseId.get(caseRecord.Id), 0));
        }
    }
}
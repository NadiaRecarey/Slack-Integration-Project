public with sharing class CaseSlackNotifierHelper {

    @future
    public static void retrySlackNotification(String caseId, String comment, Integer retryAttempts) {
        Case caseRecord = [SELECT Id FROM Case WHERE Id = :caseId LIMIT 1];
        System.enqueueJob(new CaseSlackNotifierQueueable(caseRecord, comment, retryAttempts));
    }

    @future
    public static void updateUser(String userId, String slackbotChannelId ) {
        User user = [SELECT Id, Slackbot_Channel_ID__c, Email FROM User WHERE Id = :userId LIMIT 1];
        user.Slackbot_Channel_ID__c = slackbotChannelId;
        update user;    
    }

    public static Boolean userHasPermissionSet(String permissionSetName) {
        Id userId = UserInfo.getUserId();
        List<PermissionSetAssignment> assignments = [SELECT PermissionSet.Name 
                                                       FROM PermissionSetAssignment 
                                                      WHERE AssigneeId = :userId];
    
        for (PermissionSetAssignment psa : assignments) {
            if (psa.PermissionSet.Name == permissionSetName) {
                return true;
            }
        }
        return false;
    }    
}

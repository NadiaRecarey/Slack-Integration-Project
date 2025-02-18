public with sharing class CaseSlackNotifierQueueable implements Queueable, Database.AllowsCallouts {
    private Case caseRecord;
    private String comment;
    private Integer retryAttempts;

    public CaseSlackNotifierQueueable(Case caseRecord, String comment, Integer retryAttempts) {
        this.caseRecord = caseRecord;
        this.comment = comment;
        this.retryAttempts = retryAttempts;
    }

    public void execute(QueueableContext context) {

        if (!CaseSlackNotifierHelper.userHasPermissionSet('Slack_Notifier')) {
            logError(caseRecord.Id, 'User does not have required permissions to send slack notifications.');
            return;
        }

        Slack_Integration_Config__mdt config = [SELECT Max_Retries__c, Slack_Bot_Token__c, Domain__c
                                                  FROM Slack_Integration_Config__mdt LIMIT 1];
        String domain = config.Domain__c;

        Decimal MAX_RETRIES = (Test.isRunningTest() || config.Max_Retries__c == null) ? 1 : config.Max_Retries__c;

        if (retryAttempts >= MAX_RETRIES) {
            return;
        }

        try {
            User user = [SELECT Id, Slackbot_Channel_ID__c, Email FROM User WHERE Id = :caseRecord.OwnerId LIMIT 1];
            String slackbotChannelId;

            if (String.isEmpty(user.Slackbot_Channel_ID__c)) {
                slackbotChannelId = createSlackChannel(user.Email, config.Slack_Bot_Token__c);
                CaseSlackNotifierHelper.updateUser(user.Id, slackbotChannelId);       
            } else {
                slackbotChannelId = user.Slackbot_Channel_ID__c;
            }

            String text;
            if (comment != '' ) {
                text = 'There is a new comment on one of your cases: \n' + comment + '\n';
                text += '\nClick here to view the case: ' + domain + '/' + caseRecord.Id;
            } else {
                text = 'There is an update on the following case \n ';
                text += '\nCase Number: ' + caseRecord.CaseNumber;
                text += '\nPriority: ' + caseRecord.Priority;
                text += '\nSubject: ' + caseRecord.Subject;
                text += '\nStatus: ' + caseRecord.Status;
                text += '\nClick here to view the case: ' + domain + '/' + caseRecord.Id;
            }
            sendSlackNotification(slackbotChannelId, text, config.Slack_Bot_Token__c);

        } catch (Exception ex) {
            logError(caseRecord.Id, ex.getMessage());
            CaseSlackNotifierHelper.retrySlackNotification(caseRecord.Id, comment, retryAttempts + 1);
        }
    }

    private String getSlackUserID(String userEmail, String slackBotToken) {
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://slack.com/api/users.lookupByEmail?email=' + userEmail);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json; charset=utf-8');
        request.setHeader('Authorization', 'Bearer ' + slackBotToken);

        HttpResponse res = new Http().send(request);

        if (res.getStatusCode() == 200) {
            Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            if ((Boolean) result.get('ok')) {
                return (String) ((Map<String, Object>) result.get('user')).get('id');
            } else {
                throw new CalloutException('Error getting user id: ' + result.get('error'));
            }
        } else {
            throw new CalloutException('Slack API failed: ' + res.getBody());
        }
    }

    private String createSlackChannel(String userEmail, String slackBotToken) {
        String slackUserID = getSlackUserID(userEmail, slackBotToken);

        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://slack.com/api/conversations.open');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json; charset=utf-8');
        request.setHeader('Authorization', 'Bearer ' + slackBotToken);
        request.setBody('{"users": "' + slackUserID + '"}');

        HttpResponse response = new Http().send(request);

        if (response.getStatusCode() == 200) {
            Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            if ((Boolean) result.get('ok')) {
                return (String) ((Map<String, Object>) result.get('channel')).get('id');
            } else {
                throw new CalloutException('Error creating channel: ' + result.get('error'));
            }
        } else {
            throw new CalloutException('Slack API failed: ' + response.getBody());
        }
    }

    private void sendSlackNotification(String channelId, String text, String slackBotToken) {

        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://slack.com/api/chat.postMessage');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json; charset=utf-8');
        request.setHeader('Authorization', 'Bearer ' + slackBotToken);
        request.setBody('{"channel": "' + channelId + '", "text": "' + text + '"}');

        HttpResponse response = new Http().send(request);

        if (response.getStatusCode() != 200) {
            throw new CalloutException('Error sending Slack message: ' + response.getBody());
        }
    }

    private void logError(Id recordId, String errorMessage) {
        Integration_Log__c logRecord = new Integration_Log__c(
            RecordId__c = recordId,
            Status__c = 'Failed',
            Error_Message__c = errorMessage,
            Timestamp__c = System.now()
        );
        insert logRecord;
    }
}

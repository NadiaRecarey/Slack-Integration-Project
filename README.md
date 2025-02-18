# Salesforce to Slack Integration Design Document

## 1. Overview
This project aims to develop a robust integration between Salesforce and Slack to improve response times for support cases. This integration will ensure that agents receive real-time notifications when cases are assigned and updated with new comments or status changes. We will utilize the Slack developer sandbox as provided in the requirements documentation. The pre-deployment steps, including the necessary configurations, are outlined in the final section.

## 2. High-Level Architecture
The integration will be built using Salesforce’s native capabilities:
- **Apex Triggers** to detect case assignments, status updates, and case comments creation/updates
  - `CaseTrigger`
  - `CaseCommentTrigger`
- **Apex Trigger Handlers** to follow best practices, ensuring trigger logic is encapsulated in separate classes.
- **Apex REST Callouts** to send notifications to Slack.
- **Queueable Apex** for asynchronous execution and error handling.

### Why use Queueable Apex?
Queueable Apex is chosen for its ability to handle callouts, retry logic, and asynchronous execution:
- Handles Callouts ✅
- Allows Chaining (Retry Logic) 🔄
- Runs Asynchronously ⚡

If retries and chaining are not needed, a simple @future method could work, but Queueable is a better fit for this integration.

## 3. Data Flow Diagram
1. A Case is created or updated in Salesforce.
2. An Apex Trigger identifies if the case is assigned or updated.
3. The trigger calls a Queueable Apex class to handle the integration asynchronously.
4. The Queueable Apex class checks if the user has a Slackbot channel ID.
5. If the user does not have a Slackbot channel ID:
   - A callout is made to retrieve the channel ID from Slack’s API.
6. The retrieved Slackbot channel ID is updated on the User record.
7. A REST callout is made to Slack’s API to send the notification using the user’s Slackbot Channel ID.
8. Slack receives the request and sends a notification to the designated channel or user.
9. If the callout fails, an error is logged in the `Integration_Log__c` and the message is retried.

## 4. Salesforce Objects & Fields
### Standard Objects:
- **Case**  
  - `CaseNumber`
  - `OwnerId` (to identify the assigned agent)
  - `Priority`
  - `Subject`
  - `Status`
  - **Case Comments**
- **User**  
  - `Slackbot_Channel_ID__c` (Text - Channel ID between the user and the Slackbot)

### Custom Objects:
- **Integration_Log__c**  
  - `RecordId__c` (Related Case ID)
  - `Status__c` (Success/Failed)
  - `Error_Message__c`
  - `Timestamp__c` (DateTime)

## 5. Integration Development

### API Selection
- **Slack API**: OAuth-based API for better security and control.
- **Salesforce Callouts**: REST-based HTTP POST requests to Slack.

### Slack API Endpoints:
- `https://slack.com/api/users.lookupByEmail?email=`
- `https://slack.com/api/conversations.open`
- `https://slack.com/api/chat.postMessage`

## 6. Security & Authentication
The integration uses Remote Site Settings for secure communication between Salesforce and Slack. While OAuth authentication is planned for iterative improvement, the use of Remote Site Settings provides secure functionality and scalability. 

- **Remote Site Settings**:
  - Remote Site Name: `Slack_API`
  - Remote Site URL: `https://slack.com`
  
- **Slack Configuration: Bot Token Scopes**
  - `channels:manage`
  - `chat:write`
  - `users:read`
  - `groups:write`

## 7. Custom Metadata Type
The custom metadata type stores configuration for the integration, including API URLs, webhook URLs, and retry settings.

### Custom Metadata Type: `Slack_Integration_Settings__mdt`
- `Slack_Bot_Token__c`
- `Domain__c` (Org domain)
- `Max_Retries__c` (Maximum retries, default is 1)

## 8. Error Handling & Logging
### Retry Mechanism:
Failed callouts will be retried once (or up to the maximum retries specified in the custom metadata type).

### Logging System:
Errors will be logged in `Integration_Log__c` for troubleshooting.

## 9. Testing & Validation

### Unit Tests
Apex test classes with mock callouts to cover all scenarios.

### User Acceptance Testing

#### 1. Create a Slack Channel for a Case
- **Test Steps**: Create a new case, assign it to a user without an existing Slack channel ID, and confirm Slack channel creation.
- **Expected Results**: Slack channel is created, and the channel ID is populated in `Slackbot_Channel_ID__c`.

#### 2. Send a Slack Notification
- **Test Steps**: After Slack channel creation, add a comment to the case.
- **Expected Results**: A Slack notification is sent to the correct Slack channel.

#### 3. Handle Missing Slack Channel ID
- **Test Steps**: Assign a case to a user without a Slackbot Channel ID and trigger the integration.
- **Expected Results**: The system should create a Slack channel for the user.

#### 4. Error Handling and Retries
- **Test Steps**: Simulate an error during Slack channel creation or notification sending.
- **Expected Results**: The system logs the error and retries the process.

#### 5. Basic User Interaction
- **Test Steps**: Ensure the Slack channel is created and interact with it (e.g., add a comment).
- **Expected Results**: A message is sent to the Slack channel indicating the new comment.

## 10. Deployment Plan

### Pre-Deployment Steps
- Configure **Remote Site Settings** in Salesforce for Slack API communication.
- Install necessary **Slack App** in the workspace and configure bot token scopes.
- Configure **Custom Metadata Types** in Salesforce for API URLs and retry settings.

### Elements to Deploy
- Custom Objects (`Integration_Log__c`)
- Custom Fields (`Slackbot_Channel_ID__c`)
- Custom Metadata Type (`Slack_Integration_Settings__mdt`)
- Apex Classes and Triggers
- Remote Site Settings

### Post-Deployment Steps
- Test the integration using the provided test cases.
- Monitor logs for any errors and verify retry functionality.

---

## 11. Conclusion
This integration between Salesforce and Slack will enhance agent responsiveness and case management by delivering real-time notifications. By following the design and deployment guidelines, the system will ensure reliable and secure communication, with built-in error handling and retry mechanisms.


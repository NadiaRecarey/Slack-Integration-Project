@isTest
public class CaseTriggerTest {

    @testSetup static void setupData() {
        // User
        User newUser = new TestDataFactory.UserBuilder().
                                            setAlias('alias1').
                                            setEmail('user@test.com').
                                            setFirstName('First Name').
                                            setLastName('Last Name').
                                            setUserName('evolve1@test.com').
                                            build();                       
        insert newUser;

        User newUser2 = new TestDataFactory.UserBuilder().
                                            setAlias('alias2').
                                            setEmail('user2@test.com').
                                            setFirstName('First Name').
                                            setLastName('Last Name').
                                            setUserName('evolve2@test.com').
                                            build();                       
        insert newUser2;

        // Case
        Case newCase = new TestDataFactory.CaseBuilder().
                                            setSubject('Test Case Subject').
                                            setStatus('New').
                                            setPriority('High').
                                            setOwnerId(newUser.Id).
                                            build();
        insert newCase;
    }

    @isTest
    static void testCaseTrigger() {
        User testUser = [SELECT Slackbot_Channel_ID__c FROM User WHERE userName = 'evolve1@test.com'];
        Case testCase = [SELECT Id FROM Case WHERE Subject = 'Test Case Subject' LIMIT 1];
            
        Test.startTest();
            System.enqueueJob(new CaseSlackNotifierQueueable(testCase, '', 0));
        Test.stopTest();

        List<AsyncApexJob> jobs = [SELECT Id, Status FROM AsyncApexJob WHERE JobType = 'Queueable'];
        System.assertEquals(1, jobs.size(), 'Queueable job was not enqueued');
    }

    @isTest
    static void testSlackCalloutFailure() {
        Test.setMock(HttpCalloutMock.class, new MockSlackHttpResponseFailure());
        Case testCase = [SELECT Id FROM Case WHERE Subject = 'Test Case Subject' LIMIT 1];

        Test.startTest();
            testCase.Status = 'Escalated';
            update testCase;
        Test.stopTest();

        Integration_Log__c logRecord = [SELECT Status__c FROM Integration_Log__c WHERE RecordId__c = :testCase.Id LIMIT 1];
        System.assertEquals('Failed', logRecord.Status__c, 'Notification should be logged as failed.');
    }
}

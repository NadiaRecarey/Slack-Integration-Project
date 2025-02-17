@isTest
private class CaseSlackNotifierQueueableTest {

    @testSetup static void setupData() {
        // User
        User newUser = new TestDataFactory.UserBuilder().
                                            setAlias('TstAlias').
                                            setEmail('user@test.com').
                                            setFirstName('First Name').
                                            setLastName('Last Name').
                                            setUserName('evolve1@test.com').
                                            build();                       
        insert newUser;

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
    static void testCaseSlackNotifierQueueable() {
        
        Case testCase = [SELECT Id FROM Case WHERE Subject = 'Test Case Subject' LIMIT 1];

        Test.setMock(HttpCalloutMock.class, new MockSlackHttpResponse());

        Test.startTest();
            System.enqueueJob(new CaseSlackNotifierQueueable(testCase, '', 0));
        Test.stopTest();

        List<AsyncApexJob> jobs = [SELECT Id, Status FROM AsyncApexJob WHERE JobType = 'Queueable'];
        System.assertEquals(1, jobs.size(), 'Queueable job was not enqueued');
    }

    @isTest
    static void testCaseSlackNotifierQueueableError() {
        Case testCase = [SELECT Id FROM Case WHERE Subject = 'Test Case Subject' LIMIT 1];

        Test.setMock(HttpCalloutMock.class, new MockSlackHttpResponseFailure());

        Test.startTest();
            System.enqueueJob(new CaseSlackNotifierQueueable(testCase, '', 0));
        Test.stopTest();

        List<Integration_Log__c> logs = [SELECT Id, Status__c, Error_Message__c FROM Integration_Log__c];
        System.assert(logs.size() > 0, 'Error log was not created');
        System.assertEquals('Failed', logs[0].Status__c, 'Status is not set to Failed');
    }
}
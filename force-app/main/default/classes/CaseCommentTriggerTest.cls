@isTest
public class CaseCommentTriggerTest {

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

        // Case
        Case newCase = new TestDataFactory.CaseBuilder().
                                            setSubject('Test Case Subject').
                                            setStatus('New').
                                            setPriority('High').
                                            setOwnerId(newUser.Id).
                                            build();
        insert newCase;

        // Case Comment
        CaseComment  newCaseComment = new TestDataFactory.CaseCommentBuilder().
                                            setParentId(newCase.Id).
                                            setCommentBody('This is a comment.').
                                            build();
        insert newCaseComment;
    }

    @isTest
    static void testCaseCommentTrigger() {
        Case testCase = [SELECT Id FROM Case WHERE Subject = 'Test Case Subject' LIMIT 1];
        List<CaseComment> comments = [SELECT Id, ParentId, CommentBody FROM CaseComment WHERE ParentId = :testCase.Id];

        Test.setMock(HttpCalloutMock.class, new MockSlackHttpResponse());

        Test.startTest();
            CaseCommentTriggerHandler.handleCaseCommentEvents(comments);
        Test.stopTest();

        List<AsyncApexJob> jobs = [SELECT Id, Status FROM AsyncApexJob WHERE JobType = 'Queueable'];
        System.assertEquals(true, jobs.size() > 0, 'Queueable job was not enqueued');
    }
}